source :gemcutter

# Project requirements
gem 'rack-flash'
gem 'fastercsv'

# Component requirements
gem 'haml', ">= 2.2.0"
#gem 'less', ">= 1.2.20"
#gem 'rack-lesscss', ">= 0.2", :group => "development"
gem 'mongo_ext', "0.18.3", :require => false
gem 'mongo', "0.18.3"
gem 'mongo_mapper', ">= 0.7.0"

# Test requirements
group :test do
  gem 'mcmire-mocha'
  # We have to use this b/c we get infinite recursion with 1.3.0 for some reason
  gem 'rspec', "1.2.8", :require => false
  # I don't know why capybara doesn't require this automatically...
  #gem 'launchy', ">= 0.3.5"
  gem 'mongrel'
  gem 'capybara', ">= 0.3.0"
  gem 'factory_girl', ">= 1.2.3"
end

# Padrino
gem 'thin' # or mongrel
#gem 'padrino', "0.9.5"
gem 'padrino-core', "0.9.5"#, :path => "vendor/padrino-framework/padrino-core"
gem 'padrino-helpers', "0.9.5"#, :path => "vendor/padrino-framework/padrino-helpers"
gem 'padrino-gen', "0.9.5"#, :path => "vendor/padrino-framework/padrino-helpers"