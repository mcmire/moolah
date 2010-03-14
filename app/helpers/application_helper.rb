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
  
end