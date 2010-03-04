require File.expand_path(File.dirname(__FILE__) + "/test_helper")

Protest do
  js_feature "Deleting transactions" do
    story <<-EOT
      As a user
      I want to be able to delete a transaction
      In case I mess up or something
    EOT
  
    #scenario "Deleting one transaction" do
    #  trans1 = Factory(:transaction, :original_description => "Transaction 1")
    #  trans2 = Factory(:transaction, :original_description => "Transaction 2")
    #  visit "/transactions"
    #  browser.confirm(true) do
    #    within("#transaction_#{trans1.id}") do
    #      click_link "Delete"
    #    end
    #  end
    #  current_path.should == "/transactions"
    #  body.should =~ /Transaction was successfully deleted/
    #  body.should_not =~ /Transaction 1/
    #end
    
    scenario "Deleting some multiple transactions" do
      trans1 = Factory(:transaction, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :original_description => "Transaction 2")
      visit "/transactions"
      #body.should_not =~ /No transactions/
      check "to_delete_#{trans1.id}"
      check "to_delete_#{trans2.id}"
      #browser.confirm(true) do
        #within('#form') do
          click_button "Delete checked"
        #end
      #end
      #current_path.should == "/transactions"
      body.should =~ /2 transactions were successfully deleted/
    end
  end
end