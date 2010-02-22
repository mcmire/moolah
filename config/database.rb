MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)
MongoMapper.database = Moolah.settings['database']