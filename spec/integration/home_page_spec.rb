require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

feature "Home page" do
  
  scenario "Home page" do
    # Not really a good test, but, whatever
    visit "/"
    current_path.should == "/transactions"
  end
  
end