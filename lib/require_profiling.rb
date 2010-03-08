require 'benchmark'
require 'yaml'
require 'set'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end
Term::ANSIColor.coloring = false

# This overrides 'require' and `load` to record the time it takes to require
# files within a section of your code, and then generates a report afterward.
# It's intelligent enough to figure out where files were required from and
# construct a hierarchy of the required files.
#
# To use, copy this file to lib/require_profiling.rb, require it somewhere, then
# wrap the code you want to measure in a `profile` block. Like so:
#
#   require 'lib/require_profiling'
#   RequireProfiling.profile do
#     # load, say, your boot or environment file here
#   end
#
# Alternatively, you can use `start` and `stop`:
#
#   require 'lib/require_profiling'
#   RequireProfiling.start
#   # load, say, your boot or environment file here
#   RequireProfiling.stop
#
# When profiling stops, a report will be written to APP_DIR/tmp/require_profile.log.
# If you ever need to regenerate the report, simply run:
#
#   ruby lib/require_profiling.rb
#
# There are several command options that let you customize the report. To view
# them, say:
#
#   ruby lib/require_profiling.rb --help
#
#---
#
# Bugs:
#
# * Files that are autoload'ed (as is common these days) are not caught by this
#   script. This is because Kernel.autoload doesn't call Kernel#require or even
#   Kernel.require, but an internal require method (<http://is.gd/9VtxI>).
#   See next point.
# * Files that are required within the Ruby source using rb_safe_require() or
#   anything like that aren't caught, either. In order to measure these requires,
#   you'd have to override the relevant C methods, too. Unfortunately I don't
#   know how to do this, but if you want to take a crack at it, feel free!
#   Be sure to let me know so I can try it out too.
#
##---
#
# Author: Elliot Winkler <elliot.winkler@gmail.com>
#
module RequireProfiling
  class << self
    def profiling_enabled?
      @profiling_enabled
    end
    
    def options
      @options ||= default_options.dup
    end
    attr_writer :options
    
    def profile(tmp_options={}, &block)
      current_options = options
      @options = tmp_options
      start
      yield
    ensure
      stop
      self.options = current_options
    end
    
    def start(tmp_options={})
      return unless ENV["RPROFILE"] or $RPROFILE
      @start_time = Time.now
      [ Kernel, (class << Kernel; self; end) ].each do |klass|
        klass.class_eval do
          def require_with_profiling(path, *args)
            RequireProfiling.measure(path, caller, :require) { require_without_profiling(path, *args) }
          end
          alias_method :require_without_profiling, :require
          alias_method :require, :require_with_profiling
          
          def load_with_profiling(path, *args)
            RequireProfiling.measure(path, caller, :load) { load_without_profiling(path, *args) }
          end
          alias_method :load_without_profiling, :load
          alias_method :load, :load_with_profiling
        end
      end
      @profiling_enabled = true
    end
    
    def stop
      return unless ENV["RPROFILE"] or $RPROFILE
      @stop_time = Time.now
      [ Kernel, (class << Kernel; self; end) ].each do |klass|
        klass.class_eval do
          alias_method :require, :require_without_profiling
          alias_method :load, :load_without_profiling
        end
      end
      store_profile_data
      @profiling_enabled = false
    end
    
    def measure(path, full_backtrace, mechanism, &block)
      # Don't worry about measuring the require if the file's already in $"
      # (since Ruby will just not require it, anyway)
      return yield if $".include?(path)
      
      num_files = required_files.size
      
      output = nil
      backtrace = full_backtrace.reject {|x| x =~ /require|dependencies/ }
      caller = File.expand_path(backtrace[0].split(":")[0])
      parent = required_files.find {|f| f[:full_path] == caller }
      unless parent
        #puts "Couldn't find parent '#{caller}' for '#{path}', making fake"
        #puts backtrace.join("\n")
        #puts
        parent = {
          :index => required_files.size,
          :full_path => caller,
          :parent => nil,
          :is_root => true,
          :fake => true
        }
        required_files << parent
      end
      full_path = find_file(path)
      expanded_path = path; expanded_path = expand_absolute_path(path) if path =~ /^\//
      new_file = {
        :index => required_files.size,
        :original_path => path,
        :path => expanded_path,
        :full_path => full_path,
        :backtrace => full_backtrace,
        :parent => parent,
        :is_root => false,
        :is_fake_root => parent[:fake],
        :loaded_via => mechanism
      }
      # add this before the file is required so that anything that is required
      # within the file that's about to be required already has a parent present
      required_files << new_file
      time = Time.now
      begin
        output = yield  # do the require or load here
        new_file[:time] = (Time.now - time)
      rescue LoadError => e
        # Hmm, looks like the file didn't exist. Remove this file and any files
        # that may have been required inside it. Oh and if we created a fake parent,
        # remove that too.
        #puts "Hmm, had a problem loading '#{path}'. Rolling back:"
        #required_files[num_files..required_files.size-1].each do |file|
        #  puts " - #{file[:full_path] || file[:original_path]}"
        #end
        #puts
        required_files.slice!(num_files..required_files.size-1)
        raise(e)
      end
      output
    end
 
    def store_profile_data
      FileUtils.mkdir_p(File.dirname(data_file))
      report_data = {
        :start_time => @start_time,
        :stop_time => @stop_time,
        :required_files => @required_files
      }
      File.open(data_file, "w") {|f| YAML.dump(report_data, f) }
      puts "Wrote data to #{data_file}." unless options[:stdout]
      generate_profile_report
    end

    def generate_profile_report(regenerating_report=false)
      unless options[:stdout]
        puts "Now generating profile report, please wait..."
      end
      
      if regenerating_report
        report_data = File.open(data_file) {|f| YAML.load(f) }
        @start_time = report_data[:start_time]
        @stop_time = report_data[:stop_time]
        @required_files = report_data[:required_files]
      end
      
      @required_files = remove_duplicate_files(@required_files)
      
      if options[:stdout]
        report_fh = $stdout
      else
        FileUtils.mkdir_p(File.dirname(report_file))
        report_fh = File.open(report_file, "w")
      end
      report_fh.puts(("Total time: %.2f seconds" % (@stop_time - @start_time)).bold.white)
      report_fh.puts
      if options[:nested] || options[:list] == :root
        if options[:nested]
          root_files = @required_files.select {|file| file[:is_root] }
        else
          root_files = @required_files.select {|file| file[:is_root] || file[:is_fake_root] }
        end
        out, total_time, children_total_time = generate_profile_report_level(root_files)
      else
        #generate_profile_report_level(@required_files.select {|file| !file[:is_root] && file[:time] }, true)
        out, total_time, children_total_time = generate_profile_report_level(@required_files)
      end
      report_fh.write(out)
      report_fh.close unless options[:stdout]
      
      unless options[:stdout]
        out = "Wrote report to #{report_file}."
        out << " Run `ruby lib/require_profiling.rb` if you want to regenerate the report." unless regenerating_report
        puts(out)
      end
    end
    
    def parse_argv(argv)
      return if argv.empty?
      argv = argv.dup
      @options = {}
      while arg = argv.shift
        case arg
        when "--help"
          puts
          puts "ruby #{$0} [OPTIONS]"
          puts
          puts "OPTIONS:"
          puts "--list (all|root)        - Lists all files, or just the top-level ones."
          puts "--all                    - Short for --list all."
          puts "--root                   - Short for --list root."
          puts "--nested                 - Arranges files in a hierarchy. Implies --all."
          puts "--sort (time|index)      - Sorts files by how long it took to require them, or the order in which they were required."
          puts "                           (Technically, --sort time is really --sort time,index, and index is always ascending.)"
          puts "--order (asc|desc)       - For --sort time, orders files by earliest-to-latest, or latest-to-earliest."
          puts "                           For --sort index, orders files by first-to-last, or last-to-first."
          puts "--ascending, --asc       - Short for --order asc."
          puts "--descending, --desc     - Short for --order desc."
          puts "--stdout                 - Prints report to stdout instead of storing in a file."
          puts "--color                  - Colors parts of the report so you can read it better (try it!)."
          puts "                           Most useful with --stdout."
          puts
          puts "Default options, if none are specified: --list root --sort time --descending"
          puts
          exit
        when "--descending", "--desc"
          @options[:order] = :desc
        when "--ascending", "--asc"
          @options[:order] = :asc
        when "--all"
          @options[:list] = :all
          @options[:order] ||= :asc
        when "--root"
          @options[:list] = :root
          @options[:order] ||= :asc
        when "--nested"
          @options[:list] = :all
          @options[:nested] = true
        when "--stdout"
          @options[:stdout] = true
        when "--color"
          Term::ANSIColor.coloring = true
        when /--(.+)/
          @options[$1.to_sym] = argv.shift.to_sym
          @options[:order] ||= :asc if $1 == "list"
        end
      end
      @options = default_options.merge(@options)
    end
    
  private
    def default_options
      {:sort => :time, :order => :desc, :list => :root, :nested => false, :color => true}
    end
  
    def required_files
      @required_files ||= []
    end
    
    def data_file
      "#{app_dir}/tmp/require_profile.yml"
    end
    
    def report_file
      "#{app_dir}/tmp/require_profile.log"
    end
    
    def app_dir
      @app_dir ||= File.expand_path(File.dirname(__FILE__) + "/..")
    end
  
    def find_file(path)
      return expand_absolute_path(path) if path =~ /^\//
      expanded_path = nil
      # Try to find the path in the ActiveSupport load paths and then the built-in load paths
      load_paths = []
      load_paths += ActiveSupport::Dependencies.load_paths if defined?(ActiveSupport) && defined?(ActiveSupport::Dependencies)
      load_paths += $:
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
    
    def remove_duplicate_files(files)
      #if file[:parent] && options[:list] == :all
      #  next if file[:index] < file[:parent][:index]
      #end
      files
    end
    
    def sort_proc
      # WOW this is really horrendous
      @sort_proc ||= begin
=begin
        if options[:list] == :all && options[:nested]
          if options[:sort] == :time
            if options[:order] == :desc
              lambda {|f| [ (f[:parent] ? 1 : 0), -(f[:time] || 0), f[:index] ] }
            else
              lambda {|f| [ (f[:parent] ? 1 : 0), (f[:time] || 0), f[:index] ] }
            end
          else
            if options[:order] == :desc
              lambda {|f| [ (f[:parent] ? 1 : 0), -f[:index] ] }
            else
              lambda {|f| [ (f[:parent] ? 1 : 0), f[:index] ] }
            end
          end
        else
=end
          if options[:sort] == :time
            if options[:order] == :desc
              lambda {|f| [ -(f[:time] || 0), f[:index] ] }
            else
              lambda {|f| [ (f[:time] || 0), f[:index] ] }
            end
          else
            if options[:order] == :desc
              lambda {|f| -f[:index] }
            else
              lambda {|f| f[:index] }
            end
          end
=begin
        end
=end
      end
    end
  
    def generate_profile_report_level(files, indent_level=0)
      files = files.sort_by(&sort_proc)
      out = ""
      total_time = 0
      children_total_time = 0
      for file in files
        child_out, child_total_time = nil, nil
        if options[:nested]
          #children = @required_files.select {|f| !f[:is_root] && f[:parent] && f[:parent][:full_path] == file[:full_path] && f[:index] != file[:index] }
          children = @required_files.select {|f| f[:parent] == file }
          #require 'pp'
          #pp :file => file
          #pp :children => children
          if children.any?
            child_out, child_total_time, child_children_total_time = generate_profile_report_level(children, indent_level+1)
            children_total_time += child_children_total_time
          end
        end
        
        path = file[:full_path] ? format_path(file[:full_path]) : file[:path]

        line = ""
        line << ("%d)" % (file[:index]+1)).rjust(4).yellow
        line << " #{path}"
        if file[:loaded_via]
          line << " (#{file[:loaded_via]})".bold.black
        end
        if file[:time]
          ms = file[:time].to_f * 1000
          line << (" [%.1f ms]" % ms).magenta.bold
          total_time += file[:time]
        end
        if child_total_time
          ms = child_total_time.to_f * 1000
          line << (" [%.1f ms children]" % ms).green.bold
        end
        #if file[:is_root] && file[:parent]
        #  out << " (required by #{file[:parent][:full_path]})".bold.black
        #end
        if !file[:parent] && file[:fake]
          line << " (already loaded)".bold.black
        end
        out << ("  " * indent_level) + line + "\n"
        out << child_out if child_out
      end
      [out, total_time, children_total_time]
    end

    def format_path(path)
      path.sub(app_dir, "APP_DIR")
    end
  end
end

if __FILE__ == $0
  RequireProfiling.parse_argv(ARGV)
  RequireProfiling.generate_profile_report(true)
end