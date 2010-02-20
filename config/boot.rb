# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development" unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path(File.dirname(__FILE__) + '/..') unless defined? PADRINO_ROOT

begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require 'rubygems'
  gem 'bundler', '0.9.5'
  require 'bundler'
  Bundler.setup(:default, PADRINO_ENV)
end

Bundler.require(:default, PADRINO_ENV)
puts "=> Located #{Padrino.bundle} Gemfile for #{Padrino.env}"

Padrino.load!