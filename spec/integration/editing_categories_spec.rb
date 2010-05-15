require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Editing categories" do
  story <<-EOT
    As a user
    I want to be able to edit a category
  EOT
  
  scenario "Editing a category" do
    category = Factory(:category, :name => "Some Category")
    visit "/"
    
    click "Categories"
    within("#category_#{category.id}") do
      click "Edit"
    end
    
    fill_in "category_name", :with => "Awesome Category"
    click "Update"
    
    current_path.should == "/categories"
    body.should =~ /Category successfully updated/
    tableish('#categories tr', 'th,td').should == [
      ["", "Name", "", ""],
      ["", "Awesome Category", "Edit", "Delete"]
    ]
  end
end