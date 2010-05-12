require 'database_preparation'

class Padrino::Application
  extend DatabasePreparation
  extend DatabasePreparation::WebFrameworks::Padrino
  extend DatabasePreparation::DatabaseAdapters::Mongoid
  
  establish_database
end