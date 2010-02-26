# Go ahead and drop the entire test database
MongoMapper.connection.drop_database(MongoMapper.database.name)

Protest::TestCase.class_eval do
  # Remove all documents in all the collections in the current database
  # before each test since Mongo doesn't have support for transactions.
  # Don't delete system.indexes b/c this is special to Mongo and it seems to mess things up.
  def setup
    (MongoMapper.database.collections - ["system.indexes"]).each {|coll| coll.remove }
  end
end