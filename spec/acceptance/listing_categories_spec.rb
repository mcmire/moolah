require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing categories" do
  story <<-EOT
    As a user
    I want to be able to view a list of all categories in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  
  scenario "Listing no categories" do
    visit "/categories"
    body.should =~ /No categories/
  end
  
  scenario "Listing all categories" do
    Factory(:category, :name => "Something")
    Factory(:category, :name => "Something Else")
    visit "/categories"
    tableish('#categories tr', 'th,td').should == [
      ["", "Name", "", ""],
      ["", "Something", "Edit", "Delete"],
      ["", "Something Else", "Edit", "Delete"]
    ]
  end
end