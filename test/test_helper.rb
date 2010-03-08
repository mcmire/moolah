require 'rubygems'
require File.expand_path(File.dirname(__FILE__) + '/../lib/require_benchmarking')

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")

TEST_DIR = "#{PADRINO_ROOT}/test"

def app
  # Sinatra < 1.0 always disable sessions for the test environment, so if you
  # need them it's necessary to force the use of Rack::Session::Cookie.
  # (You can handle all Padrino applications using `Padrino.application` instead.)
  @app ||= Moolah.new
end

Dir["#{TEST_DIR}/support/*.rb"].each {|file| require file }