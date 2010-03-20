require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

describe Transaction::Graph do
  
  describe '.balance' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.balance.should == {
        :data => [
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
      }
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.balance.should == {:data => []}
    end
  end
  
  describe '.checking_balance' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.checking_balance.should == {
        :data => [
          [Date.new(2010, 1, 3),  5.00],
          [Date.new(2010, 1, 4),  5.00],
          [Date.new(2010, 1, 5),  20.00]
        ]
      }
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.checking_balance.should == {:data => []}
    end
  end
  
  describe '.savings_balance' do
    it "returns an array of points, squashing days and filling in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => 1000)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 3), :amount => -500)
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1500)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 10), :amount => -200)
      Factory(:transaction, :account_id => "savings",  :settled_on => Date.new(2010, 1, 20), :amount => 25000)
      Transaction::Graph.savings_balance.should == {
        :data => [
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
      }
    end
    it "returns an empty array if there aren't any transactions" do
      Transaction::Graph.savings_balance.should == {:data => []}
    end
  end
  
  describe '.monthly_income' do
    it "groups all transactions by month and tallies the income per month" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 300) # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 1), :amount => -500) #  800
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 2, 20), :amount => 2500) # 3300
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 3, 1), :amount => 1500)  # 4800
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 3, 2), :amount => -1500) # 3300
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 4, 11), :amount => -200) # 3100
      Transaction::Graph.monthly_income.should == {
        :data => [-2.00, 40.00, -15.00, -2.00],
        :xlabels => ["1/1/10 - 2/1/10", "2/1/10 - 3/1/10", "3/1/10 - 4/1/10", "4/1/10 - 5/1/10"]
      }
    end
    it "fills in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 300) # 1300
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 3, 1), :amount => 1500)  # 2800
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 3, 2), :amount => -1500) # 1300
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 5, 11), :amount => -200) # 1100
      Transaction::Graph.monthly_income.should == {
        :data => [3.00, 15.00, -15.00, 0, -2.00],
        :xlabels => ["1/1/10 - 2/1/10", "2/1/10 - 3/1/10", "3/1/10 - 4/1/10", "4/1/10 - 5/1/10", "5/1/10 - 6/1/10"]
      }
    end
    it "correctly handles datasets that start on the 1st of the month" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 1), :amount => 1000)  # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 300)  # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 10), :amount => -500) #  800
      Transaction::Graph.monthly_income.should == {
        :data => [3.00, -5.00],
        :xlabels => ["1/1/10 - 2/1/10", "2/1/10 - 3/1/10"]
      }
    end
    it "correctly handles datasets that end on the 1st of the month" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 5), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 300) # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 1), :amount => -500) #  800
      Transaction::Graph.monthly_income.should == {
        :data => [-2.00, 0],
        :xlabels => ["1/1/10 - 2/1/10", "2/1/10 - 3/1/10"]
      }
    end
    it "returns an empty result set if there aren't any transactions" do
      Transaction::Graph.monthly_income.should == {
        :data => [],
        :xlabels => []
      }
    end
  end
  
  describe '.bimonthly_income' do
    it "groups all transactions by 2-week periods and tallies the income per period" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2009, 12, 28), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 7), :amount => 300)    # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 500)   # 1800
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 20), :amount => -900)  #  900
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 1), :amount => 500)    # 1400
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 2, 5), :amount => 2500)    # 3900
      Transaction::Graph.bimonthly_income.should == {
        :data => [8.00, -9.00, 30.00],
        :xlabels => ["12/27/09 - 1/10/10", "1/10/10 - 1/24/10", "1/24/10 - 2/7/10"]
      }
    end
    it "fills in the gaps in time" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2009, 12, 28), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 7), :amount => 300)    # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 500)   # 1800
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 20), :amount => -900)  #  900
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 8), :amount => 500)    # 1400
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 2, 16), :amount => 2500)    # 3900
      Transaction::Graph.bimonthly_income.should == {
        :data => [8.00, -9.00, 0, 30.00],
        :xlabels => ["12/27/09 - 1/10/10", "1/10/10 - 1/24/10", "1/24/10 - 2/7/10", "2/7/10 - 2/21/10"]
      }
    end
    it "correctly handles datasets that start at the beginning of a period" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2009, 12, 27), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 7), :amount => 300)    # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 500)   # 1800
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 20), :amount => -900)  #  900
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 8), :amount => 500)    # 1400
      Factory(:transaction, :account_id => "savings", :settled_on => Date.new(2010, 2, 16), :amount => 2500)    # 3900
      Transaction::Graph.bimonthly_income.should == {
        :data => [8.00, -9.00, 0, 30.00],
        :xlabels => ["12/27/09 - 1/10/10", "1/10/10 - 1/24/10", "1/24/10 - 2/7/10", "2/7/10 - 2/21/10"]
      }
    end
    it "correctly handles datasets that end on the beginning of a period" do
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2009, 12, 28), :amount => 1000) # 1000
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 7), :amount => 300)    # 1300
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 10), :amount => 500)   # 1800
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 1, 20), :amount => -900)  #  900
      Factory(:transaction, :account_id => "checking", :settled_on => Date.new(2010, 2, 7), :amount => 500)    # 1400
      Transaction::Graph.bimonthly_income.should == {
        :data => [8.00, -9.00, 5.00, 0.00],
        :xlabels => ["12/27/09 - 1/10/10", "1/10/10 - 1/24/10", "1/24/10 - 2/7/10", "2/7/10 - 2/21/10"]
      }
    end
    it "returns an empty result set if there aren't any transactions" do
      Transaction::Graph.bimonthly_income.should == {
        :data => [],
        :xlabels => []
      }
    end
  end
  
end