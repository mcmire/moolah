require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing import rules" do
  story <<-EOT
    As a user
    I want to be able to view a list of all import_rules in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  
  scenario "Listing no import rules" do
    visit "/import_rules"
    body.should =~ /No import rules/
  end
  
  scenario "Listing all import rules" do
    account = Factory(:account, :name => "Checking")
    category = Factory(:category, :name => "Some Category")
    Factory(:import_rule,
      :account => account,
      :category => category,
      :pattern => /^foo$/,
      :description => "Some description"
    )
    Factory(:import_rule,
      :account => account,
      :category => category,
      :pattern => /bar/,
      :description => "Another description"
    )
    visit "/import_rules"
    tableish('#import_rules tr', 'th,td').should == [
      ["", "Pattern", "Account", "Category", "Description", "", ""],
      ["", "/^foo$/", "Checking", "Some Category", "Some description", "Edit", "Delete"],
      ["", "/bar/", "Checking", "Some Category", "Another description", "Edit", "Delete"]
    ]
  end
end