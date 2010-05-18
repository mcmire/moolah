# http://web.elctech.com/2010/02/25/using-will_paginate-in-sinatra/

require 'will_paginate/view_helpers/link_renderer'
require 'will_paginate/view_helpers/base'

Padrino::Application.class_eval do
  include WillPaginate::ViewHelpers::Base
end
 
WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected
  def url(page)
    url = @template.request.url
    if page == 1
      # strip out page param and trailing ? if it exists
      url.gsub(/page=\d+/, '').gsub(/\?$/, '')
    else
      if url =~ /page=\d+/
        url.gsub(/page=\d+/, "page=#{page}")
      else
        url + "?page=#{page}"
      end
    end
  end
end