# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'config/version'
 
Gem::Specification.new do |s|
  s.name        = "moolah"
  s.version     = Moolah::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Elliot Winkler"]
  s.email       = ["elliot.winkler@gmail.com"]
  s.homepage    = "http://github.com/mcmire/bundler"
  s.summary     = "A tiny money management app"
  s.description = "Moolah lets you manage your money sensibly without all the features you don't need"
 
  s.required_rubygems_version = ">= 1.3.6"
 
  # Convert the Gemfile to gemspec dependencies
  Bundler.definition.dependencies.each do |dep|
    if dep.groups.include?(:test)
      s.add_development_dependency(dep)
    else
      s.add_dependency(dep)
    end
  end
 
  s.files        = Dir.glob("{app,config,lib,public}/**/*") + %w(config.ru Gemfile moolah.gemspec README.md TODO)
  s.require_path = 'lib'
end