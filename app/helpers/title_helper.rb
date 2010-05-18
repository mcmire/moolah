Moolah.helpers do
  def window_title(title=nil)
    [Moolah[:site_title], title || @window_title || @title].select {|x| x.present? }.join(": ")
  end
  
  def page_title
    @page_title || @title
  end
end