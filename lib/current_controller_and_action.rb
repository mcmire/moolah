module Padrino
  module Rendering
    module InstanceMethods
    private
      # Override render to store the current template being rendered so we can refer to it in the view
      # This works with Padrino >= 0.9.10
      def render(engine, data=nil, options={}, locals={}, &block)
        # If engine is a hash then render data converted to json
        return engine.to_json if engine.is_a?(Hash)

        # Data can actually be a hash of options in certain cases
        options.merge!(data) && data = nil if data.is_a?(Hash)

        # If an engine is a string then this is a likely a path to be resolved
        data, engine = *resolve_template(engine, options) if data.nil?

        # PATCH: Store the current template being rendered
        # This method will also get executed for partials and stuff
        # so we just need to store it the first time we're called
        @_template ||= data

        # Sinatra 1.0 requires an outvar for erb and erubis templates
        options[:outvar] ||= '@_out_buf' if [:erb, :erubis] & [engine]

        # Resolve layouts similar to in Rails
        if (options[:layout].nil? || options[:layout] == true) && !settings.templates.has_key?(:layout)
          options[:layout] = resolved_layout || false # We need to force layout false so sinatra don't try to render it
          logger.debug "Resolving layout #{options[:layout]}" if defined?(logger) && options[:layout].present?
        end

        # Pass arguments to Sinatra render method
        super(engine, data, options.dup, locals, &block)
      end
    end
  end
end