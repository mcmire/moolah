require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing transactions" do
  story <<-EOT
    As a user
    I want to be able to view a list of all transactions in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  
  scenario "Listing no transactions" do
    visit "/transactions"
    body.should =~ /No transactions/
  end
  
  scenario "Listing all transactions" do
    checking = Factory(:account, :id => "checking")
    savings = Factory(:account, :id => "savings")
    Factory(:transaction,
      :account => checking,
      :settled_on => Date.new(2009, 1, 1),
      :description => "Some transaction",
      :amount => -1000
    )
    Factory(:transaction, 
      :account => savings,
      :settled_on => Date.new(2009, 2, 1),
      :description => "Another transaction",
      :amount => -500
    )
    visit "/transactions"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount"],
      ["", "02/01/2009",  "", "Another transaction", "-$5.00"],
      ["", "01/01/2009",  "", "Some transaction", "-$10.00"]
    ]
  end
  
  scenario "Listing transactions in a certain account" do
    checking = Factory(:account, :id => "checking")
    savings = Factory(:account, :id => "savings")
    Factory(:transaction,
      :account => checking,
      :settled_on => Date.new(2009, 1, 1),
      :description => "Some transaction",
      :amount => -1000
    )
    Factory(:transaction, 
      :account => savings,
      :settled_on => Date.new(2009, 2, 1),
      :description => "Another transaction",
      :amount => -500
    )
    visit "/transactions/savings"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount"],
      ["", "02/01/2009",  "", "Another transaction", "-$5.00"],
    ]
  end
end