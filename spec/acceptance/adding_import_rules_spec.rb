require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Adding import rules" do
  story <<-EOT
    As a user
    I want to be able to add import rules
    So that after I import I don't have to spend as much time categorizing transactions or whatever
    (It just does it for me)
  EOT
  
  scenario "Adding an import rule" do
    Factory(:account, :name => "Checking")
    Factory(:category, :name => "Some Category")
    visit "/"
    click "Import Rules"
    
    click "Add an import rule"
    fill_in "import_rule_pattern", :with => "^whatever"
    select "Checking", :from => "import_rule_account_id"
    select "Some Category", :from => "import_rule_category_id"
    fill_in "import_rule_description", :with => "The description"
    click "Save"

    body.should =~ /Import rule successfully added/
    tableish('#import_rules tr', 'th,td').should == [
      ["", "Pattern", "Account", "Category", "Description", "", ""],
      ["", "/^whatever/", "Checking", "Some Category", "The description", "Edit", "Delete"]
    ]
  end
  
  scenario "Adding an import rule for future imports from an existing transaction" do
    account = Factory(:account, :name => "Checking")
    category = Factory(:category, :name => "Shopping")
    Factory(:transaction,
      :account => account,
      :category => category,
      :original_description => "TARGET T0695 C  TARGET T0695",
      :settled_on => Date.new(2008, 1, 14)
    )
    visit "/"
    click "Checking"
    
    click "Edit"
    fill_in "transaction_description", :with => "Target"
    select "Shopping", :from => "transaction_category_id"
    check "Auto-assign these settings to TARGET T0695 C  TARGET T0695 transactions from now on"
    click "Update"
    # .. todo: view import rules
    
    click "Import transactions into checking account"
    attach_file "file", "#{PADRINO_ROOT}/spec/fixtures/transactions2.csv"
    click "Import"
    
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "02/01/2009", "", "Target", "-$3.00", "Edit", "Delete"],
      ["", "01/14/2008", "", "Target", "-$1.00", "Edit", "Delete"]
    ]
  end
end