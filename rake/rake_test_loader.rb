#!/usr/bin/env ruby

# Load the test files from the command line.

#require File.expand_path(File.dirname(__FILE__) + '/../lib/require_measurements')
#RequireMeasurements.measuring_requires do
  ARGV.each { |f| load f unless f =~ /^-/  }
#end