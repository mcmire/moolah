# Copied from http://github.com/sickill/rack-lesscss/blob/master/lib/rack-lesscss.rb
# and then modified to handle @imports better, as well as errors

require 'less'
 
module Rack
  class LessCss
    
    def initialize(app, opts)
      @app = app
      @less_path = opts[:less_path] or raise ArgumentError, "You must specify less_path (path to directory containing .less files)"
      @rootless_less_path = relativize_path(@less_path)
      @css_route = opts[:css_route].chomp("/") || "/stylesheets"
      @css_route_regexp = /#{Regexp.escape(@css_route)}\/([^\.]+)\.css/
    end
 
    def call(env)
      time = Time.now
      if env['PATH_INFO'] =~ @css_route_regexp
        begin
          path = $1
          source_path = get_source_path($1)
          relative_path = relativize_path(source_path, true)
          if source_path =~ /\.le?ss$/
            body = "/* Generated from #{$1}.less by Rack::LessCss middleware */\n\n"
            less = ::File.open(source_path) {|f| Less::Engine.new(f) }
            body << less.to_css
            logger.debug "rack-lesscss: Processed %s (%0.4f)" % [relative_path, Time.now - time]
          else
            body = ::File.read(source_path)
            logger.debug "rack-lesscss: Passing thru %s (%0.4f)" % [relative_path, Time.now - time]
          end
          headers = {
            'Content-Type' => 'text/css',
            'Cache-Control' => 'private',
            'Content-Length' => body.size.to_s
          }
          return [200, headers, [body]]
        rescue Less::ImportError => e
          barf("#{e.class}: #{e.message}")
        rescue SyntaxError, StandardError => e
          barf(e)
        end
      end
      @app.call(env)
    end
    
  private
    def get_source_path(stylesheet)
      starting_path = ::File.join(@less_path, stylesheet)
      path = starting_path + ".less"
      path = starting_path + ".css" unless ::File.exists?(path)
      path
    end
    
    def relativize_path(path, with_leading_slash=false)
      path.sub(Padrino.root + (with_leading_slash ? "/" : ""), "")
    end
    
    def barf(msg)
      if Exception === msg
        puts "!! Rack::LessCss Error"
        puts "#{msg.class}: #{msg.message}"
        puts msg.backtrace.join("\n")
      else
        puts "!! Rack::LessCss Error"
        puts msg
      end
    end
  end
end