#require 'yaml'
require 'rubygems'
require 'spec/rake/spectask'
require 'thor/rake_compat'

class Rspec < Thor
  include Thor::RakeCompat
  
  namespace :spec

  [:all, :models, :mailers, :integration].each do |spec_level|
    task_name = (spec_level == :all ? "spec" : "spec:#{spec_level}")
    dir = File.expand_path('../../../', __FILE__) + '/' + (spec_level == :all ? "spec" : "spec/#{spec_level}")
    desc "#{spec_level} [EXAMPLE] [--js]", "Runs specs in spec/#{spec_level}"
    argument :example, :optional => true
    method_options :js => false
    define_method spec_level do
      cmd = ["spec"]
      cmd += %W(--options spec/spec.opts)
      if spec_level == :integration || spec_level == :all
        cmd += %w(--format nested)
        # Since any environment variables executed along with 'rake spec' are not
        # propagated to the specs themselves, store the options in a file which
        # we'll then read later when we run the specs.
        #
        # To run the javascript tests, simply pass JS=1 to 'rake spec'.
        #
        FileUtils.mkdir_p("tmp")
        options = {}
        options[:javascript] = @options[:js]
        File.open("tmp/integration_spec.opts", "w") {|f| YAML.dump(options, f) }
      else
        cmd += %w(--format specdoc)
      end
      if @example
        cmd << @example
      else
        cmd += Dir["#{dir}/**/*_spec.rb"]
      end
      #puts "Command: #{cmd}"
      system(*cmd)
    end
  end
end