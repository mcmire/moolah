require 'pp'

class Moolah < Padrino::Application
  configure do
    ##
    # Application-specific configuration options
    # 
    # set :raise_errors, true     # Show exceptions (default for development)
    # set :public, "foo/bar"      # Location for static assets (default root/public)
    # set :sessions, false        # Enabled by default
    # set :reload, false          # Reload application files (default in development)
    # set :default_builder, "foo" # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"     # Set path for I18n translations (default your_app/locales)
    # enable :auto_locale         # Auto Set locale if url match /:locale/foo/bar (disabled by default)
    # disable :padrino_helpers    # Disables padrino markup helpers (enabled by default if present)
    # disable :padrino_mailer     # Disables padrino mailer (enabled by default if present)
    # disable :flash              # Disables rack-flash (enabled by default)
    # enable  :authentication     # Enable padrino-admin authentication (disabled by default)
    # layout :foo                 # Layout can be in views/layouts/foo.ext or views/foo.ext (:application is default)
    # 
    
    # For some reason after upgrading to 0.9.10 we have to do this..
    enable :sessions
    enable :flash
    
    register RestfulActions
    
    # use Rack::LessCss, :less_path => "#{PADRINO_ROOT}/app/stylesheets", :css_route => "/stylesheets"
    use Rack::TrailingSlash
    
    layout "application"
  end

  configure :test do
    # Sinatra < 1.0 always disable sessions for the test environment, so if you
    # need them it's necessary to force the use of Rack::Session::Cookie.
    # (You can handle all Padrino applications using `Padrino.application` instead.)
    use Rack::Session::Cookie
  end
  
  #Padrino::Logger::Config[:test] = { :log_level => :debug, :stream => :to_file }
  #Padrino::Logger.setup!
end