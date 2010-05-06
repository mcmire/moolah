require 'digest/sha1'
require 'money'

class Transaction
  include MongoMapper::Document
  
  key :sha1, String#, :required => true
  #key :parent_id, Integer
  key :account_id, ObjectId#, :required => true # checking, savings
  key :transaction_type_id, Integer  # cc, atm, etc.
  key :category_id, ObjectId # gas, rent, etc.
  key :check_number, Integer
  key :amount, Money, :required => true
  key :original_description, String
  key :description, String, :required => true
  key :settled_on, Date, :required => true
  timestamps!
  
  belongs_to :account
  belongs_to :transaction_type
  belongs_to :category
  
  before_validation_on_create :store_sha1
  before_validation_on_create :set_description_from_original_description, :unless => :description?
  after_save :create_import_rule!, :if => :creating_import_rule?
  
  validate :amount_must_not_be_zero
  
  def creating_import_rule?
    @creating_import_rule
  end
  def creating_import_rule=(value)
    @creating_import_rule = case value
      when "1" then true
      when "0" then false
      else value
    end
  end
  
  def kind
    amount && amount.type
  end
  
  def amount_as_currency
    amount && amount.value_as_currency
  end
  
  #def amount_as_money=(money_or_attrs)
  #  @amount_as_money = attrs.is_a?(Hash) ? Money.new(money_or_attrs) : money_or_attrs
  #  self.amount = @amount_as_money.to_amount
  #end
  #def amount_as_money
  #  return @amount_as_money if defined?(@amount_as_money)
  #  @amount_as_money = Money.from_amount(amount)
  #end
  
  # TODO: Instead of saving each transaction one by one,
  # is there a way we can save them all at once?
  def self.import!(file, account)
    # accepts a String or IO object
    csv = FasterCSV.new(file)
    rows = csv.read
    num_transactions_saved = 0
    rows.each_with_index do |row, i|
      next if i == 0 # skip header row
      row = row.map {|col| col.strip }
      transaction = Transaction.new(
        :account => account,
        :settled_on => Date.fast_parse(row[0]),
        :check_number => row[1],
        :original_description => row[2],
        :description => row[2]
      )
      number = (row[3].present? ? row[3] : row[4])
      integer, precision = number.split(".")
      number = (integer + precision[0..1]).to_i
      number = -number if row[3].present?
      # MongoMapper: Something interesting is that this doesn't cast
      # the number to an int if the key is int (even though update_attributes/attributes= does)
      transaction.amount = number
      transaction.apply_import_rules
      # TODO: Make this automatic
      transaction.sha1 = transaction.calculate_sha1
      # Don't add the transaction if it's already been added
      unless Transaction.exists?(:sha1 => transaction.sha1)
        transaction.save!
        num_transactions_saved += 1
      end
    end
    num_transactions_saved
  ensure
    csv.close
  end
  
  def import_rule
    return if original_description.nil?
    @import_rule ||= begin
      desc = Regexp.escape(original_description)#.inspect
      ImportRule.first("$where" => "this.pattern.test(\"#{desc}\")")
    end
  end
  def import_rule?
    !!import_rule
  end
  
  def apply_import_rules  # well, one rule
    if rule = import_rule
      self.account_id = rule.account_id if rule.account_id
      self.category_id = rule.category_id if rule.category_id
      self.description = rule.description if rule.description
    end
  end
  
  def create_import_rule!
    ImportRule.create!(
      :pattern => Regexp.new('^' + Regexp.escape(original_description) + '$'),
      :account_id => account_id,
      :category_id => category_id,
      :description => description
    )
  end
  
  def store_sha1
    self.sha1 ||= calculate_sha1
  end
  def calculate_sha1
    Digest::SHA1.hexdigest("#{account_id}#{settled_on}#{check_number}#{original_description}#{amount}")
  end
  
  def set_description_from_original_description
    self.description = original_description
  end
  
  def amount_must_not_be_zero
    self.errors.add(:amount, "cannot be zero") if amount == 0
  end
end