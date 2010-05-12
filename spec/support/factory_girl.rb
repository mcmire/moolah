# For some reason this isn't happening automatically anymore
Factory.definition_file_paths = [
  Padrino.root('spec', 'factories')
]
Factory.find_definitions

Spec::Runner.configure do |config|
  #config.ignore_backtrace_patterns /factory_girl(?!\.rb)/
end