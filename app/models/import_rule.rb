class ImportRule
  include Mongoid::Document
  
  field :pattern, :type => Regexp
  belongs_to_related :account
  belongs_to_related :category
  field :description, :type => String
  
  validates_presence_of :pattern
  
  alias_method :set_pattern, :pattern=
  # BUG: MongoMapper doesn't do this by default??
  def pattern=(value)
    value = Regexp.new(value) unless value.is_a?(Regexp)
    set_pattern(value)
  end
  
  def apply_to_all_transactions!
    txns = Transaction.where(:original_description => pattern)
    txns.each {|txn| txn.apply_import_rule!(self) }
  end
end