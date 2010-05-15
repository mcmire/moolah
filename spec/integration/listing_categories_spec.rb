require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing categories" do
  story <<-EOT
    As a user
    I want to be able to view a list of all categories in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  
  scenario "Listing no categories" do
    visit "/"
    click "Categories"
    body.should =~ /No categories/
  end
  
  scenario "Listing all categories" do
    Factory(:category, :name => "Poppy Seeds")
    Factory(:category, :name => "Abracadabra")
    Factory(:category, :name => "Zing Way")
    visit "/"
    click "Categories"
    tableish('#categories tr', 'th,td').should == [
      ["", "Name", "", ""],
      ["", "Abracadabra", "Edit", "Delete"],
      ["", "Poppy Seeds", "Edit", "Delete"],
      ["", "Zing Way", "Edit", "Delete"]
    ]
  end
end