require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Editing import_rules" do
  story <<-EOT
    As a user
    I want to be able to edit an import rule
  EOT
  
  scenario "Editing an import rule" do
    account = Factory(:account, :name => "Checking")
    category = Factory(:category, :name => "Some Category")
    import_rule = Factory(:import_rule,
      :account => account,
      :category => category,
      :pattern => /^foo$/,
      :description => "Some description"
    )
    visit "/import_rules"
    within("#import_rule_#{import_rule.id}") do
      click "Edit"
    end
    current_path.should =~ %r|^/import_rules/([^/]+)/edit$|
    fill_in "import_rule_pattern", :with => "^lakdflskjdf$"
    click "Update"
    current_path.should == "/import_rules"
    body.should =~ /Import rule successfully updated/
    tableish('#import_rules tr', 'th,td').should == [
      ["", "Pattern", "Account", "Category", "Description", "", ""],
      ["", "/^lakdflskjdf$/", "Checking", "Some Category", "Some description", "Edit", "Delete"]
    ]
  end
end