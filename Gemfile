source :gemcutter

# Padrino
gem 'thin' # or mongrel
#gem 'padrino', "0.9.7"
gem 'padrino-core', :path => "/Users/elliot/code/vendor/cli/padrino-framework/padrino-core"
gem 'padrino-helpers', :path => "/Users/elliot/code/vendor/cli/padrino-framework/padrino-helpers"
gem 'padrino-gen', :path => "/Users/elliot/code/vendor/cli/padrino-framework/padrino-gen"

# Component requirements
gem 'haml', ">= 3.0.0"
gem 'less', ">= 1.2.20"
#gem 'rack-lesscss', ">= 0.2", :group => "development"
#gem 'mongoid', "2.0.0.beta4"
gem 'mongoid', :git => "git://github.com/durran/mongoid.git"
#gem 'bson_ext', "0.20.1"

# Project requirements
gem 'rack-flash'
gem 'fastercsv'
gem 'will_paginate', :git => "git://github.com/mislav/will_paginate", :branch => "rails3"

# Test requirements
group :test do
  gem 'spork'
  gem 'mcmire-mocha'
  gem 'rspec', "1.3.0", :require => false
  # I don't know why capybara doesn't require this automatically...
  gem 'launchy', ">= 0.3.5"
  gem 'capybara', ">= 0.3.0"
  gem 'capybara-envjs'
  gem 'factory_girl', ">= 1.2.3"
end

