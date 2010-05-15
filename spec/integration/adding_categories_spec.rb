require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Adding categories" do
  story <<-EOT
    As a user
    I want to be able to add a category
    So I can assign it to a new or existing transaction
    And help make sense of my transactions
  EOT
  
  scenario "Adding a category" do
    visit "/"
    click "Categories"
    
    click "Add a category"
    fill_in "Name", :with => "Some Category"
    click "Save"
    
    current_path.should == "/categories"
    body.should =~ /Category successfully added/
    tableish('#categories tr', 'th,td').should == [
      ["", "Name", "", ""],
      ["", "Some Category", "Edit", "Delete"]
    ]
  end
end