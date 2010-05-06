require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Transaction do
  before do
    @transaction = Transaction.new
  end
  
  context "validation" do
    it "fails if the amount is 0" do
      @transaction.amount = 0
      @transaction.save
      Array(@transaction.errors.on(:amount)).should include("cannot be zero")
    end
  end
  
  context "before validation on create" do
    it "gets a SHA1 hash based on the account, date, check number, original description, and amount" do
      account = Factory(:account, :id => "4be22ee69d0895d8df000003", :name => "Checking")
      transaction = Factory(:transaction,
        :account => account,
        :settled_on => Date.new(2009, 1, 1),
        :check_number => 1001,
        :original_description => "A transaction",
        :amount => -2092
      )
      transaction.sha1.should == "1339b7cd738f4842cee3707446c52b85c949ee51"
    end  
  
    it "sets description to original_description if description is blank" do
      transaction = Factory(:transaction, :original_description => "blah", :description => nil)
      transaction.description.should == "blah"
      transaction = Factory(:transaction, :original_description => "blah", :description => "")
      transaction.description.should == "blah"
    end
  end
  
  # TODO: Don't stub these out
  context "after save" do  
    it "calls create_import_rule if create_import_rule checkbox was checked" do
      transaction = Factory.build(:transaction)
      transaction.stubs(:create_import_rule!)
      transaction.creating_import_rule = true
      transaction.save
      transaction.should have_received(:create_import_rule!)
    end
    
    it "doesn't call create_import_rule if create_import_rule checkbox was not checked" do
      transaction = Factory.build(:transaction)
      transaction.stubs(:create_import_rule!)
      transaction.creating_import_rule = false
      transaction.save
      transaction.should have_received(:create_import_rule!).never
    end
  end
  
  #describe '#type' do
  #  it "returns debit if the amount is under 0" do
  #    @transaction.amount = -1
  #    @transaction.kind.should == "debit"
  #  end
  #  it "returns credit if the amount is above 0" do
  #    @transaction.amount = 1
  #    @transaction.kind.should == "credit"
  #  end
  #end
  
  #describe '#amount_as_money=' do
  #  it "sets @amount_as_money to a Money object" do
  #    @transaction.amount_as_money = {"value" => "32.95", "type" => "debit"}
  #    @transaction.instance_variable_get("@amount_as_money").value.should == 32.95
  #    @transaction.instance_variable_get("@amount_as_money").type.should == "debit"
  #  end
  #  it "also accepts a Money object" do
  #    money = Money.new(:value => 32.95, :type => :debit)
  #    @transaction.amount_as_money = money
  #    @transaction.instance_variable_get("@amount_as_money").should == money
  #  end
  #  it "sets @amount to the integer version of the amount" do
  #    @transaction.amount_as_money = {"value" => "32.95", "type" => "debit"}
  #    @transaction.amount.should == -3295
  #  end
  #end
  #describe '#amount_as_money' do
  #  it "returns @amount_as_money if that's set" do
  #    money = Money.new(:value => 32.95, :type => :debit)
  #    @transaction.instance_variable_set("@amount_as_money", money)
  #    @transaction.amount_as_money.should == money
  #  end
  #  it "converts amount to a Money object and then sets @amount_to_money to that" do
  #    @transaction.amount = -3295
  #    money = Money.new(:value => 32.95, :type => :debit)
  #    @transaction.amount_as_money.should == money
  #    @transaction.instance_variable_get("@amount_as_money").should == money
  #  end
  #end
  
  describe ".import!" do
    it "reads the transactions in the given file and imports them into the database" do
      checking = Factory(:account, :name => "Checking")
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), checking)
      num_transactions_saved.should == 5
      rows = Transaction.all.map {|t| [t.account, t.settled_on, t.check_number, t.original_description, t.amount] }
      rows.size.should == 5
      rows[0].should == [ checking, Date.new(2008, 1, 14), nil, "TARGET T0695 C  TARGET T0695", -12488 ]
      rows[1].should == [ checking, Date.new(2008, 1, 7), nil, "MAPCO-EXPRESS #", -4079 ]
      rows[2].should == [ checking, Date.new(2008, 1, 7), nil, "SONIC DRIVE IN  SONIC DRIVE I", -687 ]
      rows[3].should == [ checking, Date.new(2007, 12, 31), 1012, "CHECK #1012", -25000 ]
      rows[4].should == [ checking, Date.new(2007, 12, 28), nil, "PAYROLL", 98339 ]
    end
    it "applies any matching import rules" do
      account = Factory(:account)
      category1 = Factory(:category, :name => "Stores")
      ImportRule.create!(:pattern => /^TARGET/, :category_id => category1.id, :description => "Target")
      category2 = Factory(:category, :name => "Food")
      ImportRule.create!(:pattern => /SONIC/, :category_id => category2.id, :description => "Sonic")
      Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), account)
      rows = Transaction.all.map {|t| [t.category_id, t.description] }
      rows[0].should == [category1.id, "Target"]
      rows[2].should == [category2.id, "Sonic"]
    end
    it "doesn't import transactions that have already been imported" do
      account = Factory(:account)
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), account)
      num_transactions_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), account)
      num_transactions_saved.should == 0
      rows = Transaction.all.map {|t| [t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
    end
  end
  
  describe '#create_import_rule!' do
    it "creates an import rule from the description, category, and account" do
      category_id = Mongo::ObjectID.new
      account = Factory(:account)
      transaction = Transaction.new(:account => account, :category_id => category_id, :original_description => "SOME TRANSACTION", :description => "Some transaction")
      transaction.create_import_rule!
      rule = ImportRule.first
      rule.pattern.should == /^SOME\ TRANSACTION$/
      rule.account.should == account
      rule.category_id.should == category_id
      rule.description.should == "Some transaction"
    end
    it "escapes regex characters when creating the regex" do
      transaction = Transaction.new(:original_description => "SOME $TRANSAC*ION")
      transaction.create_import_rule!
      rule = ImportRule.first
      rule.pattern.should == /^SOME\ \$TRANSAC\*ION$/
    end
  end
  
  describe '#apply_import_rules' do
    it "sets the description per the import rule that applies" do
      ImportRule.create!(:pattern => /^TARGET/, :description => "Target")
      transaction = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
      transaction.apply_import_rules
      transaction.description.should == "Target"
    end
    it "sets the category per the import rule that applies" do
      category = Factory(:category, :name => "Stores")
      ImportRule.create!(:pattern => /^TARGET/, :category_id => category.id)
      transaction = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
      transaction.apply_import_rules
      transaction.category_id.should == category.id
    end
    it "sets the account per the import rule that applies" do
      account = Factory(:account)
      ImportRule.create!(:pattern => /^TARGET/, :account_id => account.id)
      transaction = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
      transaction.apply_import_rules
      transaction.account_id.should == account.id
    end
    it "sets multiple attributes that the rule may have" do
      category = Factory(:category, :name => "Stores")
      ImportRule.create!(:pattern => /^TARGET/, :description => "Target", :category_id => category.id)
      transaction = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
      transaction.apply_import_rules
      transaction.description.should == "Target"
      transaction.category_id.should == category.id
    end
    it "treats the pattern as a regex and matches it against description" do
      ImportRule.create!(:pattern => /T0695/, :description => "Target")
      transaction = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
      transaction.apply_import_rules
      transaction.description.should == "Target"
    end
  end
end