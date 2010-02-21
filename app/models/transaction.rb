class Transaction
  include MongoMapper::Document
  
  #key :parent_id, Integer
  #key :account_id, Integer
  key :transaction_type_id, Integer
  key :category_id, Integer
  key :check_number, Integer
  key :amount, Integer
  key :original_description, String
  key :description, String
  key :settled_on, Date
  timestamps!
  
  def self.import!(file)
    # accepts a String or IO object
    csv = FasterCSV.new(file)
    rows = csv.read
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
      transaction.save!
    end
  ensure
    csv.close
  end
end