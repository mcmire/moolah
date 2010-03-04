require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
Dir["#{TEST_DIR}/support/integration/*.rb"].each {|file| require file }

Protest.report_with(:features)

class Protest::IntegrationTestCase
  def current_path
    URI.parse(current_url).path
  end
end