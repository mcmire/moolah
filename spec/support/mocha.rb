Spec::Runner.configure do |config|
  config.mock_with :mocha
  config.ignore_backtrace_patterns /mocha/
end