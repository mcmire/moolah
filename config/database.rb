require File.expand_path("../../lib/settings", __FILE__)
MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => Padrino.logger)
MongoMapper.database = Padrino::Application.settings['database']