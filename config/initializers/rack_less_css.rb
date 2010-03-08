module RackLessCssInitializer
  def self.registered(app)
    #app.configure :development do
    #  require 'rack-lesscss' # this should already be required but whatever
    #  app.use Rack::LessCss, :less_path => "#{PADRINO_ROOT}/app/stylesheets", :css_route => "/stylesheets"
    #end
  end
end