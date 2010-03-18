require 'digest/sha1'

class Transaction
  include MongoMapper::Document
  
  key :sha1, String
  #key :parent_id, Integer
  key :account_id, String # checking, savings
  key :transaction_type_id, Integer  # cc, atm, etc.
  key :category_id, Integer # gas, rent, etc.
  key :check_number, Integer
  key :amount, Float
  key :original_description, String
  key :description, String
  key :settled_on, Date
  timestamps!
  
  belongs_to :account
  
  before_create :store_sha1
  
  validate :amount_must_not_be_zero
  
  def kind
    (amount > 0 ? "credit" : "debit")
  end
  
  def amount_as_currency
    (amount < 0 ? "-" : "") + "$" + ("%.2f" % (amount.abs / 100.0))
  end
  
  def amount_as_decimal
    amount.abs / 100.0
  end
  
  # TODO: Instead of saving each transaction one by one,
  # is there a way we can save them all at once?
  def self.import!(file, account_id)
    # accepts a String or IO object
    csv = FasterCSV.new(file)
    rows = csv.read
    num_transactions_saved = 0
    rows.each_with_index do |row, i|
      next if i == 0 # skip header row
      row = row.map {|col| col.strip }
      transaction = Transaction.new(
        :account_id => account_id,
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
  
  def store_sha1
    self.sha1 ||= calculate_sha1
  end
  def calculate_sha1
    Digest::SHA1.hexdigest("#{account_id}#{settled_on}#{check_number}#{original_description}#{amount}")
  end
  
  def amount_must_not_be_zero
    self.errors.add(:amount, "cannot be zero") if amount == 0
  end
end