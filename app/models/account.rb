class Account
  include MongoMapper::Document
  key :_id, String
  key :name, String
end