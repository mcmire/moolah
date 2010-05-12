=begin
begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = ['--no-private']
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
=end

require 'yaml'

$:.unshift File.expand_path(File.dirname(__FILE__))
Dir["#{File.dirname(__FILE__)}/lib/tasks/**/*.rake"].sort.each {|ext| load ext }