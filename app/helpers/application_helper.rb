Moolah.helpers do
  
  def window_title(title)
    [Moolah[:window_title], @title].select {|x| x.present? }.join(": ")
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
      controller_name = record.class.to_s.downcase.pluralize.to_sym
      if record.new_record?
        url = url(controller_name, :create)
        method = "post"
      else
        url = url(controller_name, :update, :id => record.id)
        method = "put"
      end
    end
    form_for(record, url || settings[:url], {:method => method}.merge(settings[:html] || {}), &block)
  end
  
end