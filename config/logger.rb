Padrino::Logger::Config[:integration] = Padrino::Logger::Config[:test] = { :log_level => :debug, :stream => :to_file }
Padrino::Logger.setup!