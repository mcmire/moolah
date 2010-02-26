#$:.unshift "#{ENV["HOME"]}/code/github/forks/protest/lib"
#require 'protest'

Protest.report_with :documentation
Protest::Utils::BacktraceFilter::ESCAPE_PATHS << %r{
  test/unit |
  matchy |
  mocha-protest-integration |
  sinatra |
  padrino |
  capybara |
  rack-test
}x
#Protest::Utils::BacktraceFilter::ESCAPE_PATHS.clear