class ImportRule
  include MongoMapper::Document
  key :pattern, Regexp, :required => true
  key :account_id, String
  key :category_id, ObjectId
  key :description, String
end