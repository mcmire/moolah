class Db < Thor
  desc "seed [--env ENV]", "Seeds a database of your choice (default: development) with bootstrap data. The relevant tables are truncated first so you don't have to."
  method_options :env => "development"
  def seed
    invoke :plow, [], options
    Moolah.seed_database(options)
  end

  desc "plow [--env ENV] [--all]", "Truncates tables in a database of your choice (default: development). By default this just truncates the seed tables, if you want all of them pass ALL=true."
  method_options :env => "development", :all => false
  def plow
    Moolah.plow_database(options)
  end
end