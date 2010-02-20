require 'rubygems'

PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.dirname(__FILE__) + "/../config/boot"

TEST_DIR = "#{PADRINO_ROOT}/test"

def app
  # Sinatra < 1.0 always disable sessions for the test environment, so if you
  # need them it's necessary to force the use of Rack::Session::Cookie.
  # (You can handle all Padrino applications using `Padrino.application` instead.)
  @app ||= Moolah.tap {|app| app.use Rack::Session::Cookie }.new
end

Dir[File.dirname(__FILE__) + "/support/*.rb"].each {|file| require file }