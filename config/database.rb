MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'your_db_development'
  when :production  then MongoMapper.database = 'your_db_production'
  when :test        then MongoMapper.database = 'your_db_test'
end
