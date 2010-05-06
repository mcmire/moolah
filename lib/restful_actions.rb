module RestfulActions
  def restful(action, custom_options={}, &block)
    method, path = case action
      when :index   then [:get,    ""]
      when :show    then [:get,    ":id"]
      when :new     then [:get,    "new"]
      when :create  then [:post,   "(/)"]
      when :edit    then [:get,    ":id/edit"]
      when :update  then [:put,    ":id(/)"]
      when :delete  then [:get,    ":id/delete"]
      when :destroy then [:delete, ":id(/)"]
    end
    options = {:path => path}.merge(custom_options)
    send(method, action, options, &block)
  end
  
  def parse_route(path, options)
    # We need save our originals path/options so we can perform correctly cache.
    original = [path, options.dup]

    # We need check if path is a symbol, if that it's a named route
    map = options.delete(:map)

    if path.kind_of?(Symbol) # path i.e :index or :show
      name = path                                        # The route name
      # PATCH: Allow :path as a path suffix
      # Like :map but parents/controller are still prepended
      path = map || options.delete(:path) || path.to_s   # The route path
    end

    if path.kind_of?(String) # path i.e "/index" or "/show"
      # Now we need to parse our 'with' params
      if with_params = options.delete(:with)
        path = process_path_for_with_params(path, with_params)
      end

      # Now we need to parse our provides with :respond_to backward compatibility
      options[:provides] ||= options.delete(:respond_to)
      options.delete(:provides) if options[:provides].nil?

      if format_params = options[:provides]
        path = process_path_for_provides(path, format_params)
      end

      # Build our controller
      controller = Array(@_controller).collect { |c| c.to_s }

      unless controller.empty?
        # Now we need to add our controller path only if not mapped directly
        if map.blank?
          controller_path = controller.join("/")
          path.gsub!(%r{^\(/\)|/\?}, "")
          path = File.join(controller_path, path)
        end
        # Here we build the correct name route
        if name
          controller_name = controller.join("_")
          name = "#{controller_name}_#{name}".to_sym unless controller_name.blank?
        end
      end

      # Now we need to parse our 'parent' params and parent scope
      # PATCH: Only do this if the path doesn't start with a slash or an open parenthesis
      if path.gsub(/[()]/, "") !~ %r{^/} && (parent_params = options.delete(:parent) || @_parents)
        parent_params = Array(@_parents) + Array(parent_params)
        path = process_path_for_parent_params(path, parent_params)
      end

      # Small reformats
      path.gsub!(%r{/?index/?}, '')                  # Remove index path
      path = "/"        if path.blank?               # Add a trailing delimiter if path is empty
      path = "/" + path if path !~ %r{^\(?/} && path # Paths must start with a trailing delimiter
      path.sub!(%r{/\?$}, '(/)')                     # Sinatra compat '/foo/?' => '/foo(/)'
      path.sub!(%r{/$}, '') if path != "/"           # Remove latest trailing delimiter
    end

    # Merge in option defaults
    options.reverse_merge!(:default_values => @_defaults)

    [path, name, options]
  end
end