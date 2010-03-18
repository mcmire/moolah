require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Transaction::Graph do
  
  describe '.get_balance_data' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.get_balance_data.should == [
        [Date.new(2010, 1, 3),  5.00],
        [Date.new(2010, 1, 4),  5.00],
        [Date.new(2010, 1, 5),  20.00],
        [Date.new(2010, 1, 6),  20.00],
        [Date.new(2010, 1, 7),  20.00],
        [Date.new(2010, 1, 8),  20.00],
        [Date.new(2010, 1, 9),  20.00],
        [Date.new(2010, 1, 10), 18.00],
        [Date.new(2010, 1, 11), 18.00],
        [Date.new(2010, 1, 12), 18.00],
        [Date.new(2010, 1, 13), 18.00],
        [Date.new(2010, 1, 14), 18.00],
        [Date.new(2010, 1, 15), 18.00],
        [Date.new(2010, 1, 16), 18.00],
        [Date.new(2010, 1, 17), 18.00],
        [Date.new(2010, 1, 18), 18.00],
        [Date.new(2010, 1, 19), 18.00],
        [Date.new(2010, 1, 20), 268.00]
      ]
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.get_balance_data.should == []
    end
  end
  
  describe '.get_checking_balance_data' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.get_checking_balance_data.should == [
        [Date.new(2010, 1, 3),  5.00],
        [Date.new(2010, 1, 4),  5.00],
        [Date.new(2010, 1, 5),  20.00]
      ]
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.get_checking_balance_data.should == []
    end
  end
  
  describe '.get_savings_balance_data' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.get_savings_balance_data.should == [
        [Date.new(2010, 1, 10), -2.00],
        [Date.new(2010, 1, 11), -2.00],
        [Date.new(2010, 1, 12), -2.00],
        [Date.new(2010, 1, 13), -2.00],
        [Date.new(2010, 1, 14), -2.00],
        [Date.new(2010, 1, 15), -2.00],
        [Date.new(2010, 1, 16), -2.00],
        [Date.new(2010, 1, 17), -2.00],
        [Date.new(2010, 1, 18), -2.00],
        [Date.new(2010, 1, 19), -2.00],
        [Date.new(2010, 1, 20), 248.00]
      ]
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.get_savings_balance_data.should == []
    end
  end
  
end