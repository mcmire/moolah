require 'rubygems'
require 'rake'

require 'pp'

def jeweler_present?
  begin
    require 'jeweler'
    true
  rescue LoadError => e
    puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
    puts e.message
    false
  end
end

def bundler_present?
  begin
    gem 'bundler', '>= 0.9.7'
    require 'bundler'
    true
  rescue LoadError => e
    puts "Bundler (or a dependency) not available. Install it with: gem install bundler"
    puts e.message
  end
end

if jeweler_present? && bundler_present?
  Jeweler::Tasks.new do |gem|
    gem.name = "moolah"
    gem.summary = %Q{Some description goes here}
    gem.description = %Q{Some description goes here}
    gem.email = "elliot.winkler@gmail.com"
    gem.homepage = "http://github.com/mcmire/moolah"
    gem.authors = ["Elliot Winkler"]
    # Convert the Gemfile back to a gemspec since Jeweler doesn't know
    # how to work with Bundler directly right now
    Bundler.definition.dependencies.each do |dep|
      if dep.groups.include?(:test)
        gem.add_development_dependency(dep)
      else
        gem.add_dependency(dep)
      end
    end
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
  
  #task :check_bundler_dependencies do
  #  if bundler_present?
  #    require 'bundler/cli'
  #    Bundler::CLI.new.check 
  #  end
  #end
  #
  #task :test => :check_bundler_dependencies
end

=begin
begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--no-private']
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
=end

$:.unshift File.expand_path(File.dirname(__FILE__))
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each {|ext| load ext }