Factory.define :account do |f|
  f.name "Checking"
end

Factory.define :category do |f|
  f.name "Some Category"
end

Factory.define :transaction do |f|
  f.association :account
  f.transaction_type_id 1
  f.association :category
  f.amount 100
  f.original_description "Some transaction"
  f.settled_on Date.new(2010, 1, 1)
end

Factory.define :import_rule do |f|
  f.association :account
  f.association :category
  f.pattern "^foo$"
  f.description "Some description"
end