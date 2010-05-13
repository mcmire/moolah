require 'spec/rake/spectask'

#desc "Run all specs in spec directory (excluding plugin specs)"
#Spec::Rake::SpecTask.new(:spec) do |t|
#  t.spec_opts = ['--options', "spec/spec.opts"]
#  t.spec_opts += ['--example', ENV["EXAMPLE"]] if ENV["EXAMPLE"]
#  t.spec_opts += ['--line', ENV["LINE"]] if ENV["LINE"]
#  t.spec_files = FileList['spec/**/*_spec.rb']
#end

namespace :spec do
  [:models, :integration].each do |sub|
    desc "Run the code examples in spec/#{sub}"
    Spec::Rake::SpecTask.new(sub) do |t|
      t.spec_opts = ['--options', "spec/spec.opts"]
      t.spec_opts += ['--example', ENV["EXAMPLE"]] if ENV["EXAMPLE"]
      t.spec_opts += ['--line', ENV["LINE"]] if ENV["LINE"]
      if sub == :integration
        t.spec_opts += ['--format', 'nested']
        # Since any environment variables executed along with 'rake spec' are not
        # propagated to the specs themselves, store the options in a file which
        # we'll then read later when we run the specs.
        #
        # To run the javascript tests, simply pass JS=1 to 'rake spec'.
        #
        FileUtils.mkdir_p("tmp")
        options = {}
        options[:javascript] = (ENV["JS"] == "1")
        File.open("tmp/integration_spec.opts", "w") {|f| YAML.dump(options, f) }
      else
        t.spec_opts += ['--format', 'specdoc']
      end
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end
end

#task :default => :spec
