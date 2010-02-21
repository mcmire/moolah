Protest::TestCase.class_eval do
  # Remove all the collections in the current database before each test
  # since Mongo doesn't have support for transactions
  def setup
    MongoMapper.database.collections.each {|coll| coll.remove }
  end
end