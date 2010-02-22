require File.expand_path(File.dirname(__FILE__) + "/test_helper")

Protest.describe Transaction do
  it "gets a SHA1 hash on creation based on the date, check number, original description, and amount" do
    transaction = Transaction.create!(
      :settled_on => Date.new(2009, 1, 1),
      :check_number => 1001,
      :original_description => "A transaction",
      :amount => -2092
    )
    transaction._hash.should == "38afef6864369e30455d627b136ab6319a705b93"
  end
  
  context ".import!" do
    it "reads the transactions in the given file and imports them into the database" do
      Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"))
      rows = Transaction.all.map {|t| [t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
      rows[0].should == [ Date.new(2008, 1, 14), nil, "TARGET T0695 C  TARGET T0695", "TARGET T0695 C  TARGET T0695", -12488 ]
      rows[1].should == [ Date.new(2008, 1, 7), nil, "MAPCO-EXPRESS #", "MAPCO-EXPRESS #", -4079 ]
      rows[2].should == [ Date.new(2008, 1, 7), nil, "SONIC DRIVE IN  SONIC DRIVE I", "SONIC DRIVE IN  SONIC DRIVE I", -687 ]
      rows[3].should == [ Date.new(2007, 12, 31), 1012, "CHECK #1012", "CHECK #1012", -25000 ]
      rows[4].should == [ Date.new(2007, 12, 28), nil, "PAYROLL", "PAYROLL", 98339 ]
    end
    it "doesn't import transactions that have already been imported" do
      Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"))
      Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"))
      rows = Transaction.all.map {|t| [t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
      rows[0].should == [ Date.new(2008, 1, 14), nil, "TARGET T0695 C  TARGET T0695", "TARGET T0695 C  TARGET T0695", -12488 ]
      rows[1].should == [ Date.new(2008, 1, 7), nil, "MAPCO-EXPRESS #", "MAPCO-EXPRESS #", -4079 ]
      rows[2].should == [ Date.new(2008, 1, 7), nil, "SONIC DRIVE IN  SONIC DRIVE I", "SONIC DRIVE IN  SONIC DRIVE I", -687 ]
      rows[3].should == [ Date.new(2007, 12, 31), 1012, "CHECK #1012", "CHECK #1012", -25000 ]
      rows[4].should == [ Date.new(2007, 12, 28), nil, "PAYROLL", "PAYROLL", 98339 ]
    end
  end
end