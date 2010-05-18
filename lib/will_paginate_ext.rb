module WillPaginateExtensions
  def page_entries_info(*)
    super.sub("Displaying", "Showing")
  end
end

Padrino::Application.class_eval do
  include WillPaginateExtensions
end