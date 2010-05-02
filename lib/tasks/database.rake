namespace :db do
  def seed_from_hashes(rows, collection_name)
    for row in rows
      MongoMapper.database.collection(collection_name).insert(row)
    end
  end
  
  def seed_from_csv_fixture(lines, collection_name)
    columns = lines.shift.sub(/^#[ ]*/, "").split(/,[ ]*/)
    rows = []
    for line in lines
      values = line.split(/\t|[ ]{2,}/).map {|v| v =~ /^null$/i ? nil : v }
      zip = columns.zip(values).flatten
      #p :columns => columns, :values => values, :zip => zip
      row = Hash[*zip]
      rows << row
    end
    seed_from_hashes(rows, collection_name)
  end
  
  def seed_collections
    Dir[Padrino.root("data/*")].map do |file|
      collection_name = File.basename(file).sub(/\.([^.]+)$/, "")
      MongoMapper.database.collection(collection_name)
    end
  end
  
  desc "Seeds a database of your choice (default: development) with bootstrap data. The relevant tables are truncated first so you don't have to."
  task :seed, [:env] => :init do |t, args|
    env = args[:env] || "development"
    Rake::Task['db:truncate'].invoke(env)
    puts "Seeding #{env} database..."
    MongoMapper.database = Moolah.settings(env)['database']
    Dir[Padrino.root("data/*")].each do |file|
      collection_name = File.basename(file).sub(/\.([^.]+)$/, "")
      ext = file.match(/\.([^.]+)$/i)[1].downcase
      if ext == "rb"
        records = eval(File.read(file))
        puts " - Adding data for #{collection_name}..."# if standalone
        seed_from_hashes(records, collection_name)
      elsif ext == "yml" || ext == "yaml"
        data = YAML.load_file(file)
        # not sure if this works exactly
        table = (Hash === data) ? data[data.keys.first] : data
        puts " - Adding data for #{collection_name}..."# if standalone
        seed_from_hashes(records, collection_name)
      else
        lines = File.read(file).split(/\n/)
        puts " - Adding data for #{collection_name}..."# if standalone
        seed_from_csv_fixture(lines, collection_name)
      end
    end
  end
  
  desc "Truncates tables in a database of your choice (default: development). By default this just truncates the seed tables, if you want all of them pass ALL=true."
  task :truncate, [:env] => :init do |t, args|
    env = args[:env] || "development"
    truncate_all = ENV["ALL"]
    MongoMapper.database = Moolah.settings(env)['database']
    collections = truncate_all ? MongoMapper.database.collections : seed_collections
    collections.each {|coll| coll.drop }
    puts "Dropped collections: #{collections.map {|coll| coll.name }.join(", ")}"
  end
end