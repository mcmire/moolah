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
    visit "/"
    within("#transaction_#{trans1.id}") do
      click "Delete"
    end
    current_path.should =~ %r{^/delete}
    click "Yes, destroy"
    current_path.should == "/"
    body.should =~ /Transaction was successfully deleted/
    body.should_not =~ /Transaction 1/
  end
  
  scenario "Deleting one transaction (Javascript)"
  
  scenario "Deleting some multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    visit "/"
    check "to_delete_#{trans1.id}"
    check "to_delete_#{trans2.id}"
    click "Delete checked"
    current_path.should == "/"
    body.should =~ /2 transactions were successfully deleted/
  end
  
  scenario "Deleting no multiple transactions" do
    trans1 = Factory(:transaction, :original_description => "Transaction 1")
    trans2 = Factory(:transaction, :original_description => "Transaction 2")
    visit "/"
    click "Delete checked"
    current_path.should == "/"
    body.should =~ /No transactions were deleted/
  end
end