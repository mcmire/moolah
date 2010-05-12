namespace :db do
  desc "Seeds a database of your choice (default: development) with bootstrap data. The relevant tables are truncated first so you don't have to."
  task :seed, [:env] => :init do |t, args|
    env = args.env || "development"
    Rake::Task['db:plow'].invoke(env)
    Moolah.seed_database(:env => env)
  end
  
  desc "Truncates tables in a database of your choice (default: development). By default this just truncates the seed tables, if you want all of them pass ALL=true."
  task :plow, [:env] => :init do |t, args|
    env = args.env || "development"
    Moolah.plow_database(:env => env)
  end
end