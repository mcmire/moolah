Factory.define :account do |f|
  f.add_attribute(:id, "checking")
  f.name "Checking"
end

Factory.define :transaction do |f|
  f.transaction_type_id 1
  f.association :account
  f.amount 100
  f.original_description "Some transaction"
  f.settled_on Date.new(2010, 1, 1)
end