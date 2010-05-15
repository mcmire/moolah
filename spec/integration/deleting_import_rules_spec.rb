require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Deleting import_rules" do
  story <<-EOT
    As a user
    I want to be able to delete an import rule
    In case I mess up or something
  EOT
  
  scenario "Deleting one import rule" do
    import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
    import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
    visit "/"
    
    click "Import Rules"
    within("#import_rule_#{import_rule1.id}") do
      click "Delete"
    end

    click "Yes, delete"

    current_path.should == "/import_rules"
    body.should =~ /Import rule was successfully deleted/
    body.should_not =~ /Import rule 1/
  end
  
  scenario "Deleting some multiple import rules" do
    import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
    import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
    visit "/"
    
    click "Import Rules"
    check "to_delete_#{import_rule1.id}"
    check "to_delete_#{import_rule2.id}"
    click "Delete checked"
    
    click "Yes, delete"
    
    current_path.should == "/import_rules"
    body.should =~ /2 import rules were successfully deleted/
  end
  
  scenario "Deleting no multiple import rules" do
    import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
    import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
    visit "/"
    
    click "Import Rules"
    click "Delete checked"

    current_path.should == "/import_rules"
    body.should =~ /You didn't select any import rules to delete/
  end
  
  javascript do
    scenario "Deleting one import rule" do
      import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
      import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
      visit "/"
      
      click "Import Rules"
      accepting_confirm_boxes do
        within("#import_rule_#{import_rule1.id}") do
          click "Delete"
        end
      end

      current_path.should == "/import_rules"
      body.should =~ /Import rule was successfully deleted/
      body.should_not =~ /Import rule 1/
    end
    
    scenario "Deleting some multiple import rules" do
      import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
      import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
      visit "/"
      
      click "Import Rules"
      check "to_delete_#{import_rule1.id}"
      check "to_delete_#{import_rule2.id}"
      accepting_confirm_boxes do
        within('#form') do
          click_button "Delete checked"
        end
      end
    
      current_path.should == "/import_rules"
      body.should =~ /2 import rules were successfully deleted/
    end
    
    scenario "Deleting no multiple import rules" do
      import_rule1 = Factory(:import_rule, :pattern => "Import rule 1")
      import_rule2 = Factory(:import_rule, :pattern => "Import rule 2")
      visit "/"

      click "Import Rules"
      accepting_confirm_boxes do
        within('#form') do
          click_button "Delete checked"
        end
      end

      current_path.should == "/import_rules"
      body.should =~ /You didn't select any import rules to delete/
    end
  end
end