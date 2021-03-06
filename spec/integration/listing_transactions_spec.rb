require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing transactions" do
  story <<-EOT
    As a user
    I want to be able to view a list of all transactions in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  
  scenario "Listing no transactions" do
    visit "/"
    click "Transactions"
    body.should =~ /No transactions/
  end
  
  scenario "Listing all transactions" do
    checking = Factory(:account, :name => "Checking")
    savings = Factory(:account, :name => "Savings")
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
    visit "/"
    click "Transactions"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Account", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "Savings", "02/01/2009",  "", "Another transaction", "-$5.00", "Edit", "Delete"],
      ["", "Checking", "01/01/2009",  "", "Some transaction", "-$10.00", "Edit", "Delete"]
    ]
  end
  
  scenario "Listing no transactions in a certain account" do
    Factory(:account, :name => "Checking")
    visit "/"
    click "Transactions"
    click "Checking"
    body.should =~ /No transactions/
  end
  
  scenario "Listing transactions in a certain account" do
    checking = Factory(:account, :name => "Checking")
    savings = Factory(:account, :name => "Savings")
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
    visit "/"
    click "Transactions"
    click "Savings"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "02/01/2009",  "", "Another transaction", "-$5.00", "Edit", "Delete"],
    ]
  end
  
  scenario "Displaying 30 transactions at a time" do
    account = Factory(:account)
    60.times { Factory(:transaction, :account => account) }
    visit "/"
    click "Transactions"
    tableish('#transactions tr', 'th,td').size.should == 31
    find('.pagination > em').text.should == "1"
    a = find('.pagination > a')
    a['href'].should =~ %r{/transactions\?page=2$}
    a.text.should == "2"
    find('.pagination').text.should =~ /1.*2/
  end
end