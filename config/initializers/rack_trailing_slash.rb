module RackTrailingSlashInitializer
  # Rather than serving a resource at both /foo and /foo/, I'd rather just serve it
  # at /foo, and return a 301 for /foo/, so that Google won't think I have separate
  # pages with the same content, and I won't be keeping duplicate content in caches.
  #
  # This middleware handles this. Another strategy would be to handle this in Nginx 
  # instead of middleware.
  #
  # http://flowcoder.com/83
  module Rack
    class TrailingSlash

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['PATH_INFO'] =~ %r{^/(.*)/$}
          location = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}/#{$1}"
          location = "#{location}?#{env['QUERY_STRING']}" if env['QUERY_STRING'].to_s =~ /\S/
          [301, {"Location" => location}, []]
        else
          @app.call(env)
        end
      end

    end
  end
  
  def self.registered(app)
    app.use(Rack::TrailingSlash)
  end
end