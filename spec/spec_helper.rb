#puts "spec/spec_helper.rb loaded, from:"
#puts caller
#puts

require 'rubygems'
#require 'spork'
$:.unshift "/Users/elliot/code/github/forks/spork/lib"
require 'spork'

#class MissingSourceFile < LoadError; end

#$app ||= Moolah.new

Spork.prefork do
  # UGH... fag
  #Object.const_set(:I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2, true)
  
  Object.const_set(:PADRINO_ENV, 'test')# unless defined?(PADRINO_ENV)
  require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
  require 'spec/autorun'
  #require 'spec/rails'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }
  
  Object.const_set(:TEST_DIR, "#{PADRINO_ROOT}/spec")
  
  Spec::Runner.configure do |config|
    config.ignore_backtrace_patterns /sinatra/, /padrino-framework/, /rack/, /spork/
  end
end

Spork.each_run do
  # ...
end