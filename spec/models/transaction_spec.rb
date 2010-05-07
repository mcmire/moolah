require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Transaction do
  before do
    @txn = Transaction.new
  end
  
  context "validation" do
    it "fails if the amount is 0" do
      @txn.amount = 0
      @txn.save
      Array(@txn.errors.on(:amount)).should include("cannot be zero")
    end
  end
  
  context "before validation on create" do
    it "gets a SHA1 hash based on the account, date, check number, original description, and amount" do
      account = Factory(:account, :id => "4be22ee69d0895d8df000003", :name => "Checking")
      txn = Factory(:transaction,
        :account => account,
        :settled_on => Date.new(2009, 1, 1),
        :check_number => 1001,
        :original_description => "A transaction",
        :amount => -2092
      )
      txn.sha1.should == "1339b7cd738f4842cee3707446c52b85c949ee51"
    end  
  
    it "sets description to original_description if description is blank" do
      txn = Factory(:transaction, :original_description => "blah", :description => nil)
      txn.description.should == "blah"
      txn = Factory(:transaction, :original_description => "blah", :description => "")
      txn.description.should == "blah"
    end
  end
  
  # TODO: Don't stub these out
  context "after save" do  
    it "calls #create_and_apply_import_rule! if @creating_import_rule is set" do
      txn = Factory.build(:transaction)
      txn.stubs(:create_and_apply_import_rule!)
      txn.creating_import_rule = true
      txn.save
      txn.should have_received(:create_and_apply_import_rule!)
    end
    
    it "doesn't call #create_and_apply_import_rule! if @creating_import_rule is not set" do
      txn = Factory.build(:transaction)
      txn.stubs(:create_and_apply_import_rule!)
      txn.creating_import_rule = false
      txn.save
      txn.should have_received(:create_and_apply_import_rule!).never
    end
  end
  
  describe ".import!" do
    it "reads the transactions in the given file and imports them into the database" do
      checking = Factory(:account, :name => "Checking")
      num_txns_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), checking)
      num_txns_saved.should == 5
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
      num_txns_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), account)
      num_txns_saved = Transaction.import!(File.read("#{TEST_DIR}/fixtures/transactions.csv"), account)
      num_txns_saved.should == 0
      rows = Transaction.all.map {|t| [t.settled_on, t.check_number, t.original_description, t.description, t.amount] }
      rows.size.should == 5
    end
  end
  
  describe '#create_and_apply_import_rule!' do
    it "creates an import rule from the description, category, and account" do
      category_id = Mongo::ObjectID.new
      account = Factory(:account)
      txn = Factory.build(:transaction,
        :account => account,
        :category_id => category_id,
        :original_description => "SOME TRANSACTION",
        :description => "Some transaction"
      )
      rule = txn.create_and_apply_import_rule!
      rule.pattern.should == /^SOME\ TRANSACTION$/
      rule.account.should == account
      rule.category_id.should == category_id
      rule.description.should == "Some transaction"
    end
    it "escapes regex characters when creating the regex" do
      txn = Factory.build(:transaction, :original_description => "SOME $TRANSAC*ION")
      rule = txn.create_and_apply_import_rule!
      rule.pattern.should == /^SOME\ \$TRANSAC\*ION$/
    end
    it "immediately applies the import rule to all transactions before this one" do
      txn = Factory.build(:transaction)
      rule = stub(:apply_to_all_transactions!)
      ImportRule.stubs(:create! => rule)
      txn.create_and_apply_import_rule!
      rule.should have_received(:apply_to_all_transactions!)
    end
  end
  
  describe '#apply_import_rule' do
    before do
      @txn = Transaction.new(:original_description => "TARGET T0695 C  TARGET T0695")
    end
    it "sets the description to the description per the given rule" do
      rule = ImportRule.new(:description => "Target")
      @txn.apply_import_rule(rule)
      @txn.description.should == "Target"
    end
    it "sets the category to the category per the given rule" do
      category = Factory(:category, :name => "Stores")
      rule = ImportRule.new(:category => category)
      @txn.apply_import_rule(rule)
      @txn.category_id.should == category.id
    end
    it "sets the account to the account per the given rule" do
      account = Factory(:account)
      rule = ImportRule.new(:account => account)
      @txn.apply_import_rule(rule)
      @txn.account_id.should == account.id
    end
  end
  
  describe '#apply_import_rule!' do
    it "is like #apply_import_rule except it calls save after" do
      @txn.stubs(:apply_import_rule => nil, :save! => nil)
      @txn.apply_import_rule!(:the_rule)
      @txn.should have_received(:apply_import_rule).with(:the_rule)
      @txn.should have_received(:save!)
    end
  end
end