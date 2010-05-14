require Padrino.root("config/integration_logger")
# lib/ is loaded after config/database.rb now, that's why we need this here
require Padrino.root("lib/database_preparation")

class Padrino::Application
  extend DatabasePreparation
  extend DatabasePreparation::WebFrameworks::Padrino
  extend DatabasePreparation::DatabaseAdapters::Mongoid
  
  establish_database
end