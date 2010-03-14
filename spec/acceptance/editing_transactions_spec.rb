require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Editing transactions" do
  story <<-EOT
    As a user
    I want to be able to edit a transaction
  EOT
  
  scenario "Editing a transaction" do
    trans = Factory(:transaction,
      :settled_on => Date.new(2010, 3, 1),
      :original_description => "Transaction 1",
      :amount => 2000
    )
    visit "/transactions/checking"
    within("#transaction_#{trans.id}") do
      click "Edit"
    end
    select "Debit", :from => "transaction_kind"
    fill_in "transaction_description", :with => "The best transaction"
    fill_in "transaction_amount", :with => "123.45"
    click "Update"
    current_path.should == "/transactions/checking"
    body.should =~ /Transaction successfully updated/
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "03/01/2010",  "", "The best transaction", "-$123.45", "Edit", "Delete"]
    ]
  end
end