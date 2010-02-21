#!/usr/bin/env ruby

# Load the test files from the command line.

require 'lib/require_benchmarking'
#RequireBenchmarking.measuring_requires do
  ARGV.each { |f| load f unless f =~ /^-/  }
#end