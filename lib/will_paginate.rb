# http://web.elctech.com/2010/02/25/using-will_paginate-in-sinatra/

require 'will_paginate/view_helpers/link_renderer'
require 'will_paginate/view_helpers/base'

module WillPaginateExtensions
  def page_entries_info(*)
    super.sub("Displaying", "Showing")
  end
end

Padrino::Application.class_eval do
  include WillPaginate::ViewHelpers::Base
  include WillPaginateExtensions
end
 
Array.class_eval do
  def paginate(opts = {})
    opts  = {:page => 1, :per_page => 15}.merge(opts)
    WillPaginate::Collection.create(opts[:page], opts[:per_page], size) do |pager|
      pager.replace self[pager.offset, pager.per_page].to_a
    end
  end
end
 
WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected
  def url(page)
    url = @template.request.url
    if page == 1
      # strip out page param and trailing ? if it exists
      url.gsub(/page=[0-9]+/, '').gsub(/\?$/, '')
    else
      if url =~ /page=[0-9]+/
        url.gsub(/page=[0-9]+/, "page=#{page}")
      else
        url + "?page=#{page}"
      end
    end
  end
end
