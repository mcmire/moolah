#puts "config/boot.rb loaded, from:"
#puts caller
#puts

# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development" unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path(File.dirname(__FILE__) + '/..') unless defined? PADRINO_ROOT

require File.expand_path(File.dirname(__FILE__) + '/../lib/require_profiling')
RequireProfiling.profile do
  puts "Booting Padrino..."
  
  begin
    # Require the preresolved locked set of gems.
    require File.expand_path('../../.bundle/environment', __FILE__)
  rescue LoadError
    # Fallback on doing the resolve at runtime.
    require 'rubygems'
    gem 'bundler', '>= 0.9.7'
    require 'bundler'
    Bundler.setup(:default, PADRINO_ENV.to_sym)
  end

  Bundler.require(:default, PADRINO_ENV.to_sym)
  #puts "=> Located #{Padrino.bundle} Gemfile for #{Padrino.env}"
  puts

  Padrino.load!
end