MongoMapper.connection = Mongo::Connection.new('localhost', nil, :logger => logger)

case Padrino.env
  when :development then MongoMapper.database = 'moolah'
  when :production  then MongoMapper.database = 'moolah'
  when :test        then MongoMapper.database = 'moolah_test'
end
