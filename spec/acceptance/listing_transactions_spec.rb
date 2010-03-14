require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Listing transactions" do
  story <<-EOT
    As a user
    I want to be able to view a list of all transactions in my bank accounts in various ways
    So that I can look over them and edit them if need be
  EOT
  scenario "Normal view with no transactions" do
    visit "/transactions"
    #tableish('#transactions tr', 'th,td').should == []
    body.should =~ /No transactions/
  end
  scenario "Normal view when transactions exist" do
    Factory(:transaction, :settled_on => Date.new(2009, 1, 1), :description => "Some transaction", :amount => -1000)
    visit "/transactions"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount"],
      ["", "01/01/2009",  "", "Some transaction", "-$10.00"],
    ]
  end
end