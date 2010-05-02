require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Import rules" do
  story <<-EOT
    As a user
    I want to be able to create import rule based on existing transactions
    So that after I import I don't have to spend as much time categorizing transactions or whatever
    (It just does it for me)
  EOT
  
  scenario "Creating an import rule for future imports" do
    category = Factory(:category, :name => "Shopping")
    Factory(:transaction,
      :category => category,
      :original_description => "TARGET T0695 C  TARGET T0695",
      :settled_on => Date.new(2008, 1, 14)
    )
    
    visit "/transactions/checking"
    click "Edit"
    fill_in "transaction_description", :with => "Target"
    select "Shopping", :from => "transaction_category_id"
    check "Auto-assign these settings to TARGET T0695 C  TARGET T0695 transactions from now on"
    click "Update"
    # .. todo: view import rules
    
    visit "/transactions/checking/upload"
    attach_file "file", "#{PADRINO_ROOT}/spec/fixtures/transactions2.csv"
    click "Upload"
    
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date", "Check #", "Description", "Amount", "", ""],
      ["", "02/01/2009", "", "Target", "-$3.00", "Edit", "Delete"],
      ["", "01/14/2008", "", "Target", "-$1.00", "Edit", "Delete"]
    ]
  end
end