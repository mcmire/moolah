require 'rake/testtask'

desc "Runs all code examples in spec"
Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  #test.test_files = ["test/test_helper.rb"]
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end
namespace :test do
  [:models, :integration].each do |sub|
    desc "Runs the code examples in spec/#{sub}"
    Rake::TestTask.new(sub) do |test|
      test.libs << 'test'
      #test.test_files = ["test/test_helper.rb"]
      test.pattern = "test/#{sub}/**/*_test.rb"
      test.verbose = true
    end
  end
end

task :default => :test
