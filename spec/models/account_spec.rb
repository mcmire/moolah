require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Account do
  before do
    @account = Account.new
  end
  
  describe 'on create' do
    it "sets the webkey to a downcased version of the name" do
      account = Factory(:account, :name => "Blah")
      account.webkey.should == "blah"
    end
    
    it "doesn't set the webkey if already set" do
      account = Factory(:account, :name => "Blah", :webkey => "foo")
      account.webkey.should == "foo"
    end
  end
  
  describe 'on update' do
    it "sets the webkey to a downcased version of the name" do
      account = Factory(:account, :name => "Blah")
      account.webkey = ""
      account.save!
      account.webkey.should == "blah"
    end
    
    it "doesn't set the webkey if already set" do
      account = Factory(:account, :name => "Blah", :webkey => "foo")
      account.webkey = "zing"
      account.save!
      account.webkey.should == "zing"
    end
  end
end