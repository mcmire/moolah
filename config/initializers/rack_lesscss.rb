module RackLessCssInitializer
  def self.registered(app)
    app.configure :development do
      require 'rack-lesscss' # this should already be required but whatever
      use Rack::LessCss, :less_path => "#{ROOT_DIR}/app/stylesheets", :css_route => "/stylesheets"
    end
  end
end