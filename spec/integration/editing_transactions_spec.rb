require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Editing transactions" do
  story <<-EOT
    As a user
    I want to be able to edit a transaction
  EOT
  
  scenario "Editing a transaction" do
    account = Factory(:account, :name => "Checking")
    trans = Factory(:transaction,
      :account => account,
      :settled_on => Date.new(2010, 3, 1),
      :original_description => "Transaction 1",
      :amount => 2000
    )
    visit "/"
    
    click "Checking"
    within("#transaction_#{trans.id}") do
      click "Edit"
    end

    fill_in "transaction_description", :with => "The best transaction"
    click "Update"

    body.should =~ /Transaction successfully updated/
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "03/01/2010",  "", "The best transaction", "$20.00", "Edit", "Delete"]
    ]
  end
end