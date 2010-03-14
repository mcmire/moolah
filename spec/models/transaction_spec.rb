require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Transaction do
  before do
    @transaction = Transaction.new
  end
  
  it "can't be saved if the amount is 0" do
    @transaction.amount = 0
    @transaction.save
    Array(@transaction.errors.on(:amount)).should include("cannot be zero")
  end
  
  it "gets a SHA1 hash on creation based on the account, date, check number, original description, and amount" do
    transaction = Transaction.create!(
      :account_id => "checking",
      :settled_on => Date.new(2009, 1, 1),
      :check_number => 1001,
      :original_description => "A transaction",
      :amount => -2092
    )
    transaction.sha1.should == "c40d4a8a92d643df6d4d8e4851f948b9a0254ea4"
  end
  
  context '#type' do
    it "returns debit if the amount is under 0" do
      @transaction.amount = -1
      @transaction.kind.should == "debit"
    end
    it "returns credit if the amount is above 0" do
      @transaction.amount = 1
      @transaction.kind.should == "credit"
    end
  end
  
  context '#amount_as_currency' do
    it "returns the amount formatted as currency" do
      @transaction.amount = 3929
      @transaction.amount_as_currency.should == "$39.29"
    end
    it "deals with negative numbers correctly" do
      @transaction.amount = -3929
      @transaction.amount_as_currency.should == "-$39.29"
    end
  end
  
  context '#amount_as_decimal' do
    it "converts the amount to a decimal number" do
      @transaction.amount = 3939
      @transaction.amount_as_decimal.should == 39.39
    end
    it "removes the negative sign" do
      @transaction.amount = -2929
      @transaction.amount_as_decimal.should == 29.29
    end
  end
  
  context ".import!" do
    it "reads the transactions in the given file and imports them into the database" do
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), "checking")
      num_transactions_saved.should == 5
      rows = Transaction.all.map {|t| [t.account_id, t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
      rows[0].should == [ "checking", Date.new(2008, 1, 14), nil, "TARGET T0695 C  TARGET T0695", "TARGET T0695 C  TARGET T0695", -12488 ]
      rows[1].should == [ "checking", Date.new(2008, 1, 7), nil, "MAPCO-EXPRESS #", "MAPCO-EXPRESS #", -4079 ]
      rows[2].should == [ "checking", Date.new(2008, 1, 7), nil, "SONIC DRIVE IN  SONIC DRIVE I", "SONIC DRIVE IN  SONIC DRIVE I", -687 ]
      rows[3].should == [ "checking", Date.new(2007, 12, 31), 1012, "CHECK #1012", "CHECK #1012", -25000 ]
      rows[4].should == [ "checking", Date.new(2007, 12, 28), nil, "PAYROLL", "PAYROLL", 98339 ]
    end
    it "doesn't import transactions that have already been imported" do
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), "checking")
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), "checking")
      num_transactions_saved.should == 0
      rows = Transaction.all.map {|t| [t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
    end
  end
end