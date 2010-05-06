require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Deleting transactions" do
  story <<-EOT
    As a user
    I want to be able to delete a transaction
    In case I mess up or something
  EOT
  
  scenario "Deleting one transaction" do
    account = Factory(:account, :name => "Checking")
    trans1 = Factory(:transaction,
      :account => account, 
      :original_description => "Transaction 1", 
      :amount => -100, 
      :settled_on => Time.local(2009)
    )
    trans2 = Factory(:transaction,
      :account => account, 
      :original_description => "Transaction 2", 
      :amount => -200, 
      :settled_on => Time.local(2009)
    )
    
    visit "/"
    within("#transaction_#{trans1.id}") do
      click "Delete"
    end
    click "Yes, delete"
    
    body.should =~ /Transaction was successfully deleted/
    tableish('#transactions tr', 'th,td').should == [
      ["", "Account", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "Checking", "01/01/2009",  "", "Transaction 2", "-$2.00", "Edit", "Delete"]
    ]
  end
  
  scenario "Deleting one transaction from a specific account" do
    checking = Factory(:account, :name => "Checking")
    savings = Factory(:account, :name => "Savings")
    trans1 = Factory(:transaction,
      :account => checking, 
      :original_description => "Transaction 1", 
      :amount => -100, 
      :settled_on => Time.local(2009)
    )
    trans2 = Factory(:transaction,
      :account => savings, 
      :original_description => "Transaction 2", 
      :amount => -200, 
      :settled_on => Time.local(2009)
    )
    visit "/"
    
    click "Checking"
    within("#transaction_#{trans1.id}") do
      click "Delete"
    end

    click "Yes, delete"
    
    body.should =~ /Transaction was successfully deleted/
    
    click "All"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Account", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "Savings", "01/01/2009",  "", "Transaction 2", "-$2.00", "Edit", "Delete"]
    ]
  end
  
  scenario "Deleting some multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    
    visit "/"
    check "to_delete_#{trans1.id}"
    check "to_delete_#{trans2.id}"
    click "Delete checked"

    click "Yes, delete"

    body.should =~ /2 transactions were successfully deleted/
  end
  
  scenario "Deleting some multiple transactions from a specific account" do
    account = Factory(:account, :name => "Checking")
    trans1 = Factory(:transaction, :account => account, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :account => account, :original_description => "Transaction 2")
    visit "/"
    
    click "Checking"
    check "to_delete_#{trans1.id}"
    check "to_delete_#{trans2.id}"
    click "Delete checked"

    click "Yes, delete"

    body.should =~ /2 transactions were successfully deleted/
  end
  
  scenario "Deleting no multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    
    visit "/"
    click "Delete checked"

    body.should =~ /You didn't select any transactions to delete/
  end
  
  scenario "Deleting no multiple transactions from a specific account" do
    account = Factory(:account, :name => "Checking")
    trans1 = Factory(:transaction, :account => account, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :account => account, :original_description => "Transaction 2")
    visit "/"
    
    click "Checking"
    click "Delete checked"
    
    body.should =~ /You didn't select any transactions to delete/
  end
  
  under_javascript do
    scenario "Deleting one transaction" do
      trans1 = Factory(:transaction, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :original_description => "Transaction 2")
      
      visit "/"
      browser.confirm(true) do
        within("#transaction_#{trans1.id}") do
          click "Delete"
        end
      end
      
      body.should =~ /Transaction was successfully deleted/
      body.should_not =~ /Transaction 1/
    end
    
    scenario "Deleting one transaction from a specific account" do
      account = Factory(:account, :name => "Checking")
      trans1 = Factory(:transaction, :account => account, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :account => account, :original_description => "Transaction 2")
      visit "/"
      
      click "Checking"
      browser.confirm(true) do
        within("#transaction_#{trans1.id}") do
          click "Delete"
        end
      end

      body.should =~ /Transaction was successfully deleted/
      body.should_not =~ /Transaction 1/
    end
    
    # FIXME
    xscenario "Deleting some multiple transactions" do
      trans1 = Factory(:transaction, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :original_description => "Transaction 2")
      
      visit "/"
      check "to_delete_#{trans1.id}"
      check "to_delete_#{trans2.id}"
      browser.confirm(true) do
        within('#form') do
          click_button "Delete checked"
        end
      end

      body.should =~ /2 transactions were successfully deleted/
    end
    
    # FIXME
    xscenario "Deleting some multiple transactions from a specific account" do
      account = Factory(:account, :name => "Checking")
      trans1 = Factory(:transaction, :account => account, :original_description => "Transaction 1")
      trans2 = Factory(:transaction, :account => account, :original_description => "Transaction 2")
      visit "/"
      
      click "Checking"
      check "to_delete_#{trans1.id}"
      check "to_delete_#{trans2.id}"
      browser.confirm(true) do
        within('#form') do
          click_button "Delete checked"
        end
      end

      body.should =~ /2 transactions were successfully deleted/
    end
  end
end