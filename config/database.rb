require "#{Padrino.root}/config/integration_logger"
# lib/ is loaded after config/database.rb, that's why we need this
require 'database_preparation'

class Padrino::Application
  extend DatabasePreparation
  extend DatabasePreparation::WebFrameworks::Padrino
  extend DatabasePreparation::DatabaseAdapters::Mongoid
  
  establish_database
end