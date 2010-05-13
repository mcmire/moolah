require 'digest/sha1'
require 'money'

class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :sha1, :type => String
  #key :parent_id, Integer
  belongs_to_related :account # checking, savings
  belongs_to_related :transaction_type # cc, atm, etc.
  belongs_to_related :category # gas, rent, etc.
  field :check_number, :type => Integer
  field :amount, :type => Money
  field :original_description, :type => String
  field :description, :type => String
  field :settled_on, :type => Date
  
  #validates_presence_of :sha1  # should be here?
  validates_presence_of :amount
  #validates_presence_of :description
  validates_presence_of :settled_on
  validate :amount_must_not_be_zero
  
  before_validate :store_sha1, :on => :create
  before_validate :set_description_from_original_description, :unless => :description?, :on => :create
  after_save :create_and_apply_import_rule!, :if => :creating_import_rule?
  
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
  
  def type
    amount && amount.type
  end
  
  def amount_as_currency
    amount && amount.value_as_currency
  end
  
  # TODO: Instead of saving each transaction one by one,
  # is there a way we can save them all at once?
  # Like through the Ruby driver?
  def self.import!(file, account)
    # accepts a String or IO object
    csv = FasterCSV.new(file)
    rows = csv.read
    num_txns_saved = 0
    rows.each_with_index do |row, i|
      next if i == 0 # skip header row
      row = row.map {|col| col.strip }
      txn = Transaction.new(
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
      txn.amount = number
      txn.apply_import_rule(txn.import_rule) if txn.import_rule
      # TODO: Make this automatic
      txn.sha1 = txn.calculate_sha1
      # Don't add the transaction if it's already been added
      if Transaction.where(:sha1 => txn.sha1).count == 0
        txn.save!
        num_txns_saved += 1
      end
    end
    num_txns_saved
  ensure
    csv.close if csv
  end
  
  def import_rule
    return if original_description.nil?
    @import_rule ||= begin
      desc = Regexp.escape(original_description)
      ImportRule.where("this.pattern.test(\"#{desc}\")").first
    end
  end
  def import_rule?
    !!import_rule
  end
  
  def apply_import_rule(rule)
    self.account_id = rule.account_id   if rule.account_id
    self.category_id = rule.category_id if rule.category_id
    self.description = rule.description if rule.description
  end
  def apply_import_rule!(rule)
    apply_import_rule(rule)
    save!
  end
  
  def create_and_apply_import_rule!
    rule = ImportRule.create!(
      :pattern => Regexp.new('^' + Regexp.escape(original_description) + '$'),
      :account_id => account_id,
      :category_id => category_id,
      :description => description
    )
    rule.apply_to_all_transactions!
    rule
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