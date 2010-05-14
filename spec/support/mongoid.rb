Spec::Runner.configure do |config|
  config.before do
    Moolah.plow_database(:level => :none, :all => true)
    Moolah.seed_database(:level => :none)
  end
  config.ignore_backtrace_patterns /mongoid(?!\.rb)/
end