require 'test_helper'

Protest.feature "Uploading transactions" do
  story <<-EOT
    As a user
    I want to be able to upload a CSV of my transactions
    So that I do not have to spend time entering all of them by hand
  EOT
  scenario "Uploading a CSV of transactions" do
    visit "/upload"
    attach_file "File", "#{TEST_DIR}/fixtures/transactions.csv"
    click "Upload"
    visit "/"
    tableish('#transactions tr', 'th,td').should == [
      ["Date",       "Check #", "Description",                   "Amount"],
      ["1/14/2008",  "",        "TARGET T0695 C  TARGET T0695",  "-124.88"],
      ["1/7/2008",   "",        "MAPCO-EXPRESS #",               "-40.79"],
      ["1/7/2008",   "",        "SONIC DRIVE IN  SONIC DRIVE I", "-6.87"],
      ["12/31/2007", "1012",    "CHECK #1012",                   "-250.00"],
      ["12/28/2007", "",        "CHICKEN NICKS",                 "-8.61"]
    ]
  end
end