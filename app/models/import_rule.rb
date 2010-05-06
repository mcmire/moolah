class ImportRule
  include MongoMapper::Document
  key :pattern, Regexp, :required => true
  key :account_id, ObjectId
  key :category_id, ObjectId
  key :description, String
  
  belongs_to :account
  belongs_to :category
  
  alias_method :set_pattern, :pattern=
  # BUG: MongoMapper doesn't do this by default??
  def pattern=(value)
    value = Regexp.new(value) unless value.is_a?(Regexp)
    set_pattern(value)
  end
end