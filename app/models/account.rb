class Account
  include MongoMapper::Document
  key :_id, String, :required => true
  key :name, String, :required => true
end