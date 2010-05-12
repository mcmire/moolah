Spec::Runner.configure do |config|
  config.before do
    Moolah.plow_database(:level => :debug, :all => true)
    Moolah.seed_database(:level => :debug)
  end
  config.ignore_backtrace_patterns /mongoid(?!\.rb)/
end