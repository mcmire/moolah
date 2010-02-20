#$:.unshift "#{ENV["HOME"]}/code/github/forks/protest/lib"
#require 'protest'

Protest.report_with :documentation
Protest::Utils::BacktraceFilter::ESCAPE_PATHS << %r|test/unit| << %r|matchy| << %r|mocha-protest-integration|
#Protest::Utils::BacktraceFilter::ESCAPE_PATHS.clear