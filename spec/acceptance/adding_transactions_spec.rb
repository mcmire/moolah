require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Adding transactions" do
  story <<-EOT
    As a user
    I want to be able to add a transaction
    Such as cash payments, or something like that
  EOT
  
  scenario "Adding a transaction" do
    visit "/transactions/new"
    select "Debit", :from => "transaction_kind"
    fill_in "transaction_description", :with => "The best transaction"
    fill_in "transaction_amount", :with => "123.45"
    fill_in "transaction_settled_on", :with => "2010-01-01"
    click "Save"
    current_path.should == "/transactions/"
    body.should =~ /Transaction successfully added/
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "01/01/2010",  "", "The best transaction", "-$123.45", "Edit", "Delete"]
    ]
  end
end