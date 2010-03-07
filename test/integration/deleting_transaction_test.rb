require File.expand_path(File.dirname(__FILE__) + "/test_helper")

Protest.feature "Deleting transactions" do
  story <<-EOT
    As a user
    I want to be able to delete a transaction
    In case I mess up or something
  EOT
  
  scenario "Deleting one transaction" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    visit "/transactions"
    within("#transaction_#{trans1.id}") do
      click "Delete"
    end
    current_path.should =~ %r|^/transactions/delete|
    click "Yes, delete"
    current_path.should == "/transactions"
    body.should =~ /Transaction was successfully deleted/
    body.should_not =~ /Transaction 1/
  end
  
  scenario "Deleting some multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    visit "/transactions"
    check "to_delete_#{trans1.id}"
    check "to_delete_#{trans2.id}"
    click "Delete checked"
    click "Yes, delete"
    current_path.should == "/transactions"
    body.should =~ /2 transactions were successfully deleted/
  end
  
  scenario "Deleting no multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    visit "/transactions"
    click "Delete checked"
    current_path.should == "/transactions"
    body.should =~ /You didn't select any transactions to delete/
  end
  
  javascript_scenarios do
    scenario "Deleting one transaction" do
      trans1 = Factory(:transaction, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :original_description => "Transaction 2")
      visit "/transactions"
      browser.confirm(true) do
        within("#transaction_#{trans1.id}") do
          click "Delete"
        end
      end
      current_path.should == "/transactions"
      body.should =~ /Transaction was successfully deleted/
      body.should_not =~ /Transaction 1/
    end
  end
end