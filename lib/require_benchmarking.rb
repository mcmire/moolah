require 'benchmark'
require 'yaml'
require 'set'

=begin
Let's say we have this hierarchy of requires:

  file1
    file2
      file3
      file4
      file5
    file6
      file7
      file8
  file9

After requiring file1, we might have

  @files = [
    [
      :path => 'file1',
      :fullpath => '/path/to/file1',
      :time => time,
      :backtrace => backtrace
    ]
  ]

Upon requiring file2, we have to put it under file1 so we might have

  @files = [
    [
      :path => 'file1',
      :fullpath => '/path/to/file1',
      :time => time,
      :backtrace => backtrace,
      :inner_paths => [
        [
          :path => 'file2',
          :fullpath => '/path/to/file2',
          :time => time,
          :backtrace => backtrace
        ]
      ]
    ],
  ]
  
but then upon requiring file3 we'd have to look inside file1 to find file2,
so instead we do

  @files = [
    [
      :path => 'file1',
      :fullpath => '/path/to/file1',
      :time => time,
      :backtrace => backtrace,
      :parent => nil,
    ],
    [
      :path => 'file2',
      :fullpath => '/path/to/file2',
      :time => time,
      :backtrace => backtrace,
      :parent => '/path/to/file1'
    ]
  ]
  
Of course, we know to put file1 as a parent of file2 because we know that
file2 was required from file1. And we know that because file1 is first in the
backtrace when we require file2. So what we do is we take that path, and we
look in @files for an entry whose :fullpath is that path, and then put the
fullpath as the :parent.

But where did file1's fullpath come from? It's there because when file1 was
required, we took the path passed to require and derived the full path
ourselves. The best way to do that is to copy what Ruby and ActiveSupport are
going to do anyway and that is to look through the load paths (Ruby + ActiveSupport)
and find the file.

The other files are required in the same fashion.

That leaves the question, how do we print out this monster? Ideally we want this:

  /path/to/file1 (450 ms, required in /some/file)
    /path/to/file2 (100.3 ms)
      /path/to/file3 (92 s)
      /path/to/file4 (40 ms)
      /path/to/file5 (82 ms)
    /path/to/file6 (34 ms)
      /path/to/file7 (90 ms)
      /path/to/file8 (200 ms)
  /path/to/file9 (1.2 s, required in /some/other/file)
  
Oh, except that we want each level sorted by time reverse, so that'd be:

  /path/to/file9 (1.2 s, required in /some/other/file)
  /path/to/file1 (450 ms, required in /some/file)
    /path/to/file2 (100.3 ms)
      /path/to/file3 (92 s)
      /path/to/file5 (82 ms)
      /path/to/file4 (40 ms)
    /path/to/file6 (34 ms)
      /path/to/file8 (200 ms)
      /path/to/file7 (90 ms)

Right. So how do we do this? Well first we have to file all the root files,
i.e., all the files that don't have a parent. Unfortunately we can't simply
say files.select {|file| file[:parent].nil? } because our "parent" is really
a caller (i.e. where the file was required from), and all files have callers,
even parents. So what we need to do is store an :is_root key as files are added:

  @files = [
    [
      :path => 'file1',
      :fullpath => '/path/to/file1',
      :time => time,
      :backtrace => backtrace,
      :parent => '/some/file',
      :is_root => true
    ],
    [
      :path => 'file2',
      :fullpath => '/path/to/file2',
      :time => time,
      :backtrace => backtrace,
      :parent => '/path/to/file1',
      :is_root => false
    ]
  ]

Basically, a file is a root file if the caller of that file is not already
present in @files.

Now that we know where to start, we loop through the root files and print them
out. To find the children, we find the @files whose :parent is the same as the
fullpath of the root file we're on. Then, per level, we sort it by time reverse.
=end

# This overrides 'require' to records the time it takes to require a file, and
# then generate a report. It's intelligent enough to figure out where files were
# required from and construct a hierarchy of the required files.
#
# To use, copy this file to lib/require_benchmarking.rb, then add this to the
# top of the Rails::Initializer block in environment.rb:
#
#   # Benchmark requires
#   require File.dirname(__FILE__) + '/../lib/require_benchmarking'
#   RequireBenchmarking.hook(config)
#
# Then, start your Rails app using script/server. After the app has been initialized,
# the report will be generated and saved to RAILS_ROOT/boot.log. If you need
# to regenerate this report, simply run `ruby lib/require_benchmarking.rb`.
# By default, this will generate a flat report of only top-level requires, but
# pass `--all` to list all files in their respective hierarchy.
#
module RequireBenchmarking
  class << self
    def measuring_requires?
      @measuring_requires
    end
    
    def measuring_requires(&block)
      start_measuring_requires
      yield
      stop_measuring_requires
    end
    
    def start_measuring_requires
      return unless ENV["DEBUG"] or $DEBUG
      [ Kernel, (class << Kernel; self; end) ].each do |klass|
        klass.class_eval do
          alias_method :__require_benchmarking_old_require, :require
          def require(path, *args)
            RequireBenchmarking.require(path, caller) { __require_benchmarking_old_require(path, *args) }
          end
          alias_method :__require_benchmarking_old_load, :load
          def load(path, *args)
            RequireBenchmarking.require(path, caller) { __require_benchmarking_old_load(path, *args) }
          end
        end
      end
      @measuring_requires = true
    end
    
    def stop_measuring_requires
      return unless ENV["DEBUG"] or $DEBUG
      [ Kernel, (class << Kernel; self; end) ].each do |klass|
        klass.class_eval do
          alias_method :require, :__require_benchmarking_old_require
          alias_method :load, :__require_benchmarking_old_load
        end
      end
      store_benchmark_data
      @measuring_requires = false
    end
    
    def require(path, full_backtrace, &block)
      output = nil
      backtrace = full_backtrace.reject {|x| x =~ /require|dependencies/ }
      caller = File.expand_path(backtrace[0].split(":")[0])
      parent = required_files.find {|f| f[:fullpath] == caller }
      unless parent
        parent = {
          :index => required_files.size,
          :fullpath => caller,
          :parent => nil,
          :is_root => true
        }
        required_files << parent
      end
      fullpath = find_file(path)
      expanded_path = path; expanded_path = expand_absolute_path(path) if path =~ /^\//
      new_file = {
        :index => required_files.size,
        :path => expanded_path,
        :fullpath => fullpath,
        :backtrace => full_backtrace,
        :parent => parent,
        :is_root => false
      }
      # add this before the file is required so that anything that is required
      # within the file that's about to be required already has a parent present
      required_files << new_file
      benchmark = Benchmark.measure do
        output = yield  # do the require here
      end
      new_file[:time] = benchmark.real
      output
    end
 
    def store_benchmark_data
      File.open(data_file, "w") {|f| YAML.dump(@required_files, f) }
      puts "Wrote data to #{data_file}."
      generate_benchmark_report(false)
      exit
    end

    def generate_benchmark_report(regenerating_report=true)
      puts "Now generating benchmark report, please wait..."
      if regenerating_report
        @required_files = File.open(data_file) {|f| YAML.load(f) }
      end
      @report_fh = File.open(report_file, "w")
      @indent_level = 0
      root_files = @required_files.select {|file| file[:is_root] }
      if ARGV.include?("--all")
        generate_benchmark_report_level(root_files, true)
      else
        #generate_benchmark_report_level(@required_files.select {|file| !file[:is_root] && file[:time] }, true)
        generate_benchmark_report_level(@required_files)
      end
      @report_fh.close
      out = "Wrote report to #{report_file}."
      out << " Run `ruby lib/require_benchmarking.rb` if you want to regenerate the report." unless regenerating_report
      puts(out)
    end
    
  private
    def required_files
      @required_files ||= []
    end
    
    def printed_files
      @printed_files ||= []
    end
    
    def data_file
      "#{proj_dir}/boot.yml"
    end
    
    def report_file
      "#{proj_dir}/boot.log"
    end
    
    def proj_dir
      @proj_dir ||= File.expand_path(File.dirname(__FILE__) + "/..")
    end
  
    def find_file(path)
      return expand_absolute_path(path) if path =~ /^\//
      expanded_path = nil
      load_paths = []
      load_paths += ActiveSupport::Dependencies.load_paths if defined?(ActiveSupport)
      load_paths += $:
      # Try to find the path in the ActiveSupport load paths and then the built-in load paths
      catch :found_path do
        %w(rb bundle so).each do |ext|
          path_suffix = path; path_suffix = "#{path}.#{ext}" unless path_suffix =~ /\.#{ext}$/
          load_paths.each do |path_prefix|
            possible_path = File.join(path_prefix, path_suffix)
            if File.file? possible_path
              expanded_path = File.expand_path(possible_path)
              throw :found_path
            end
          end
          expanded_path
        end
      end
      #warn "find_file: Couldn't find '#{path}'" if expanded_path.nil?
      expanded_path
    end
    
    def expand_absolute_path(path)
      return File.expand_path(path) if path =~ /\.[^.]+$/
      %w(rb bundle so).each do |ext|
        newpath = File.expand_path(path + "." + ext)
        return newpath if File.exists?(newpath)
      end
      raise "Couldn't expand path '#{path}'!"
    end
  
    def generate_benchmark_report_level(files, printing_all=false)
      #pp :files => files
      if printing_all
        files = files.sort_by {|f| [(f[:parent] ? 1 : 0), -(f[:time] || 0), f[:index]] }
        #files = files.sort_by {|f| [(f[:parent] ? 1 : 0), f[:index]] }
      else
        #files = files.sort {|a,b| b[:time] <=> a[:time] }
        files = files.sort {|a,b| a[:index] <=> b[:index] }
      end
      for file in files
        already_printed = printed_files.include?(file[:fullpath])
        # don't print this file if it's already been printed,
        # or it will have been printed
        next if already_printed
        if file[:parent] && printing_all
          next if file[:index] < file[:parent][:index]
        end

        path = file[:fullpath] ? format_path(file[:fullpath]) : file[:path]

        out = "#{file[:index]+1}) "
        if file[:time] && !already_printed
          #if file[:time] >= 0.5
          #  out << "%s: %.4f s" % [path, file[:time]]
          #else
            ms = file[:time].to_f * 1000
            out << "%s: %.1f ms" % [path, ms]
          #end
        else
          out << path
        end
        if file[:is_root] && file[:parent]
          out << " (required by #{file[:parent][:fullpath]})" 
        end
        unless file[:parent]
          out << " (already loaded)"
        end
        if already_printed
          out << " (already printed)"
        end
        write(out)

        unless already_printed
          printed_files << file[:fullpath]
          if printing_all
            children = @required_files.select {|f| !f[:is_root] && f[:parent] && f[:parent][:fullpath] == file[:fullpath] }
            if children.any?
              @indent_level += 1
              generate_benchmark_report_level(children, printing_all)
              @indent_level -= 1
            end
          end
        end
      end
    end
    
    def write(msg)
      @report_fh.print("  " * @indent_level)
      @report_fh.puts(msg)
    end

    def format_path(path)
      path.sub(proj_dir, "PROJ_DIR")
    end
  end
end

RequireBenchmarking.generate_benchmark_report if __FILE__ == $0