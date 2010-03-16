#puts "spec/spec_helper.rb loaded, from:"
#puts caller
#puts

require 'rubygems'
#require 'spork'
$:.unshift "/Users/elliot/code/vendor/cli/spork/lib"
require 'spork'

#class MissingSourceFile < LoadError; end

#$app ||= Moolah.new

Spork.prefork do
  Object.const_set(:PADRINO_ENV, 'test') unless defined?(PADRINO_ENV)
  require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
  require 'spec/autorun'
  #require 'spec/rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  Spec::Runner.configure do |config|
    config.mock_with :mocha
  end
  
  Object.const_set(:TEST_DIR, "#{PADRINO_ROOT}/test")
end

Spork.each_run do
  # ...
end