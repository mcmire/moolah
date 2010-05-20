Moolah.helpers do
  def nav_link_to(text, url, options={})
    options.reverse_merge!(:class => "")
    re = Regexp.new(Regexp.escape(url)+'$')
    options[:class] += " active" if request.path =~ re
    link_to(text, url, options)
  end
  
  def format_message(number, thing, msg)
    out = ""
    out += (number == 0) ? "No" : pluralize(number, thing)
    out += (number > 1 ? " were " : " was ")
    out += msg
    out
  end
  
  def resourceful_form_for(record, options={}, &block)
    unless options[:url]
      controller_name = record.class.to_s.underscore.pluralize.to_sym
      if record.new_record?
        url = url(controller_name, :create)
        method = "post"
      else
        url = url(controller_name, :update, :id => record.id)
        method = "put"
      end
    end
    form_for(record, url || options[:url], {:method => method}.merge(options[:html] || {}), &block)
  end
  
  def button_submit_tag(caption, options={})
    content_tag(:button, caption, options.merge(:type => "submit"))
  end
end