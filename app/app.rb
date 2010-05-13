require 'pp'

class Moolah < Padrino::Application
  # This is necessary in >= 0.9.11
  register Padrino::Helpers
  
  configure do
    ##
    # Application configuration options
    #
    # set :raise_errors, true     # Show exceptions (default for development)
    # set :public, "foo/bar"      # Location for static assets (default root/public)
    # set :reload, false          # Reload application files (default in development)
    # set :default_builder, "foo" # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, "bar"     # Set path for I18n translations (default your_app/locales)
    # enable  :sessions           # Disabled by default
    # disable :flash              # Disables rack-flash (enabled by default if sessions)
    # layout  :my_layout          # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #
    
    # This is necessary in >= 0.9.10
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
  
  #error 404 do
  #  # ...
  #end
  
  #error 500 do
  #  # ...
  #end
end