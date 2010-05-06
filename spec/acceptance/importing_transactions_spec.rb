require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Importing transactions" do
  story <<-EOT
    As a user
    I want to be able to upload a CSV of my transactions
    So that I do not have to spend time entering all of them by hand
  EOT
  
  before do
    Factory(:account)
  end
  
  scenario "Importing a CSV of transactions" do
    visit "/accounts/checking/transactions/import"
    attach_file "file", "#{PADRINO_ROOT}/spec/fixtures/transactions.csv"
    click "Import"
    current_path.should == "/accounts/checking/transactions"
    tableish('#transactions tr', 'th,td').should == [
      ["", "Date",        "Check #", "Description",                   "Amount", "", ""],
      ["", "01/14/2008",  "",        "TARGET T0695 C  TARGET T0695",  "-$124.88", "Edit", "Delete"],
      ["", "01/07/2008",  "",        "MAPCO-EXPRESS #",               "-$40.79", "Edit", "Delete"],
      ["", "01/07/2008",  "",        "SONIC DRIVE IN  SONIC DRIVE I", "-$6.87", "Edit", "Delete"],
      ["", "12/31/2007",  "1012",    "CHECK #1012",                   "-$250.00", "Edit", "Delete"],
      ["", "12/28/2007",  "",        "PAYROLL",                       "$983.39", "Edit", "Delete"]
    ]
    body.should =~ /5 transactions were successfully imported/
  end
  
  scenario "Importing duplicate transactions" do
    visit "/accounts/checking/transactions/import"
    attach_file "file", "#{PADRINO_ROOT}/spec/fixtures/transactions.csv"
    click "Import"
    visit "/accounts/checking/transactions/import"
    attach_file "file", "#{PADRINO_ROOT}/spec/fixtures/transactions.csv"
    click "Import"
    body.should =~ /No transactions were imported/
  end
end