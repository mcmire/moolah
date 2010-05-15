require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Deleting categories" do
  story <<-EOT
    As a user
    I want to be able to delete a category
    In case I mess up or something
  EOT
  
  scenario "Deleting one category" do
    category1 = Factory(:category, :name => "Category 1")
    category2 = Factory(:category, :name => "Category 2")
    visit "/"
    
    click "Categories"
    within("#category_#{category1.id}") do
      click "Delete"
    end

    click "Yes, delete"
    
    current_path.should == "/categories"
    body.should =~ /Category was successfully deleted/
    body.should_not =~ /Category 1/
  end
  
  scenario "Deleting some multiple categories" do
    category1 = Factory(:category, :name => "Category 1")
    category2 = Factory(:category, :name => "Category 2")
    visit "/"
    
    click "Categories"
    check "to_delete_#{category1.id}"
    check "to_delete_#{category2.id}"
    click "Delete checked"
    
    click "Yes, delete"
    
    current_path.should == "/categories"
    body.should =~ /2 categories were successfully deleted/
  end
  
  scenario "Deleting no multiple categories" do
    category1 = Factory(:category, :name => "Category 1")
    category2 = Factory(:category, :name => "Category 2")
    visit "/"
    
    click "Categories"
    click "Delete checked"

    current_path.should == "/categories"
    body.should =~ /You didn't select any categories to delete/
  end
  
  javascript do
    scenario "Deleting one category" do
      category1 = Factory(:category, :name => "Category 1")
      category2 = Factory(:category, :name => "Category 2")
      visit "/"
      
      click "Categories"
      accepting_confirm_boxes do
        within("#category_#{category1.id}") do
          click "Delete"
        end
      end

      current_path.should == "/categories"
      body.should =~ /Category was successfully deleted/
      body.should_not =~ /Category 1/
    end
    
    scenario "Deleting some multiple categories" do
      category1 = Factory(:category, :name => "Category 1")
      category2 = Factory(:category, :name => "Category 2")
      visit "/"
      
      click "Categories"
      check "to_delete_#{category1.id}"
      check "to_delete_#{category2.id}"
      accepting_confirm_boxes do
        within('#form') do
          click_button "Delete checked"
        end
      end
    
      current_path.should == "/categories"
      body.should =~ /2 categories were successfully deleted/
    end
    
    scenario "Deleting no multiple categories" do
      category1 = Factory(:category, :name => "Category 1")
      category2 = Factory(:category, :name => "Category 2")
      visit "/"

      click "Categories"
      accepting_confirm_boxes do
        within('#form') do
          click_button "Delete checked"
        end
      end

      current_path.should == "/categories"
      body.should =~ /You didn't select any categories to delete/
    end
  end
end