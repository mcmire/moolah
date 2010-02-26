require 'digest/sha1'

class Transaction
  include MongoMapper::Document
  
  key :_hash, String
  #key :parent_id, Integer
  #key :account_id, Integer
  key :transaction_type_id, Integer  # cc, atm, etc.
  key :category_id, Integer # gas, rent, etc.
  key :check_number, Integer
  key :amount, Integer
  key :original_description, String
  key :description, String
  key :settled_on, Date
  timestamps!
  
  before_create :set_hash
  
  def amount_as_currency
    (amount < 0 ? "-" : "") + "$" + ("%.2f" % (amount.abs / 100.0))
  end
  
  def self.import!(file)
    # accepts a String or IO object
    csv = FasterCSV.new(file)
    rows = csv.read
    num_transactions_saved = 0
    rows.each_with_index do |row, i|
      next if i == 0 # skip header row
      row = row.map {|col| col.strip }
      transaction = Transaction.new(
        :settled_on => Date.fast_parse(row[0]),
        :check_number => row[1],
        :original_description => row[2],
        :description => row[2]
      )
      number = (row[3].present? ? row[3] : row[4])
      integer, precision = number.split(".")
      number = (integer + precision[0..1]).to_i
      number = -number if row[3].present?
      transaction.amount = number
      transaction.set_hash
      # Don't add the transaction if it's already been added
      unless Transaction.exists?(:_hash => transaction._hash)
        transaction.save!
        num_transactions_saved += 1
      end
    end
    num_transactions_saved
  ensure
    csv.close
  end
  
  def set_hash
    self._hash ||= calculate_hash
  end
  def calculate_hash
    Digest::SHA1.hexdigest("#{settled_on}#{check_number}#{original_description}#{amount}")
  end
end