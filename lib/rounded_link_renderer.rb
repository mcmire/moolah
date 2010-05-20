class RoundedLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
private
  def page_number(page)
    unless page == current_page
      link(page, page, :rel => rel_value(page), :class => "button small light yellow")
    else
      tag(:em, page, :class => "button small dark")
    end
  end
  
  def previous_or_next_page(page, text, classname)
    if page
      link(text, page, :class => classname + ' button small light yellow')
    else
      tag(:span, text, :class => classname + ' button small light yellow disabled')
    end
  end
end

WillPaginate::ViewHelpers.pagination_options.merge!(:renderer => 'RoundedLinkRenderer')