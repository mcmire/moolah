class RoundedLinkRenderer < WillPaginate::ViewHelpers::LinkRenderer
private
  def page_number(page)
    unless page == current_page
      link(page, page, :rel => rel_value(page), :class => "mrounded")
    else
      tag(:em, page, :class => "mrounded")
    end
  end
  
  def previous_or_next_page(page, text, classname)
    if page
      link(text, page, :class => classname + ' mrounded')
    else
      tag(:span, text, :class => classname + ' mrounded disabled')
    end
  end
end

WillPaginate::ViewHelpers.pagination_options.merge!(:renderer => 'RoundedLinkRenderer')