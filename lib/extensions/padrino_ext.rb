module PadrinoExtensions
  # PATCH: Pluralize the param initially
  def process_path_for_parent_params(path, parent_params)
    parent_prefix = parent_params.uniq.collect { |param| "#{param.to_s.pluralize}/:#{param}_id" }.join("/")
    File.join(parent_prefix, path)
  end
  
  def route(verb, path, options={}, &block)
    # Do padrino parsing. We dup options so we can build HEAD request correctly
    path, name, options = *parse_route(path, options.dup)

    # Usher Conditions
    options[:conditions] ||= {}
    options[:conditions][:request_method] = verb
    options[:conditions][:host] = options.delete(:host) if options.key?(:host)

    # Sinatra defaults
    define_method "#{verb} #{path}", &block
    unbound_method = instance_method("#{verb} #{path}")
    block =
      if block.arity != 0
        proc { unbound_method.bind(self).call(*@block_params) }
      else
        proc { unbound_method.bind(self).call }
      end
    invoke_hook(:route_added, verb, path, block)

    # Usher route
    route = router.add_route(path, options).to(block)
    route.name(name) if name

    # Add Sinatra conditions
    # PATCH: Only call callback if it exists
    options.each { |option, args| send(option, *args) if respond_to?(option) }
    conditions, @conditions = @conditions, []
    route.custom_conditions = conditions

    # Add Application defaults
    if @_controller
      route.before_filters = @before_filters
      route.after_filters  = @after_filters
      route.use_layout     = @layout
    else
      route.before_filters = []
      route.after_filters  = []
    end

    route
  end
  
  def url(*names)
    params =  names.extract_options! # parameters is hash at end
    name = names.join("_").to_sym    # route name is concatenated with underscores
    if params.is_a?(Hash)
      # PATCH: Remove valueless params
      params.reject! {|k,v| v.nil? }
      params[:format] = params[:format].to_s if params.has_key?(:format)
      params.each { |k,v| params[k] = v.to_param if v.respond_to?(:to_param) }
    end
    url = router.generator.generate(name, params)
    url = File.join(uri_root, url) if defined?(uri_root) && uri_root != "/"
    url = File.join(ENV['RACK_BASE_URI'].to_s, url) if ENV['RACK_BASE_URI']
    url = "/" if url.blank?
    url
  rescue Usher::UnrecognizedException
    route_error = "route mapping for url(#{name.inspect}) could not be found!"
    raise Padrino::Routing::UnrecognizedException.new(route_error)
  end
  alias :url_for :url
end
class Padrino::Application
  register PadrinoExtensions
end