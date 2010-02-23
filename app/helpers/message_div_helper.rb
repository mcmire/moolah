Moolah.helpers do
  def message_div_for(kind, *args, &block)
    div_options = args.extract_options!
    options = args.extract_options!
    value = args.first
  
    kind = kind.to_sym
    options[:unless_blank] = true unless options.include?(:unless_blank)
    options[:image] = true if [:notice, :success, :error].include?(kind) && !options.include?(:image)
    div_options[:class] ||= kind.to_s
  
    div_content = block ? capture(&block).chomp : value
    return "" if options[:unless_blank] && div_content.blank?
  
    if options.delete(:image)
      image = case kind
        when :notice  then "information"
        when :success then "accept"
        when :error   then "exclamation"
      end
      div_content = image_tag("vendor/silk/#{image}.png", :style => "vertical-align: middle") + "&nbsp; " + div_content
    end
    content_tag(:div, div_content, div_options)
  end
  def message_divs
    message_div_for(:success, (flash[:success] || @success)) +
    message_div_for(:error,   (flash[:error]   || @error)) +
    message_div_for(:notice,  (flash[:notice]  || @notice))
  end
end