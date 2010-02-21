# Project requirements
gem 'rack-flash'
gem 'fastercsv'

# Component requirements
gem 'haml', ">= 2.2.0"
gem 'less', ">= 1.2.20"
gem 'rack-lesscss', ">= 0.2", :group => "development"
gem 'mongo', "0.18.3"
gem 'mongo_ext', "0.18.3"
gem 'mongo_mapper', ">= 0.7.0"

# Test requirements
group :test do
  gem 'mcmire-protest', "0.3.2", :require => "protest", :path => "vendor/protest"
  gem 'mcmire-mocha', :require => "mocha"
  # mocha-protest-integration must be required before matchy
  # since mocha-protest-integration completely overrides the current
  # test case's #run method (and matchy simply patches it)
  gem 'mocha-protest-integration'
  gem 'mcmire-matchy', ">= 0.5.2", :require => "matchy"
  gem 'capybara', ">= 0.3.0"
end

# Padrino
gem 'thin' # or mongrel
#gem 'padrino', "0.8.5"
gem 'padrino-core', "0.8.5"
gem 'padrino-helpers', "0.8.5"