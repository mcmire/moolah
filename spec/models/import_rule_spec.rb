require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe ImportRule do
  before do
    @rule = ImportRule.new
  end
  
  describe '#apply_to_all_transactions!' do
    it "applies the rule to every matching transaction in the database" do
      txn1 = Factory(:transaction, :original_description => "SOME TXN")
      txn2 = Factory(:transaction, :original_description => "SOME TXN")
      txn3 = Factory(:transaction, :original_description => "SOME TXN")
      account = Factory(:account)
      category = Factory(:category)
      rule = ImportRule.new(
        :account => account,
        :category => category,
        :pattern => /SOME TXN/,
        :description => "Some transaction"
      )
      rule.apply_to_all_transactions!
      Transaction.all.map {|t| [t.id, t.account_id, t.category_id, t.description] }.should == [
        [txn1.id, account.id, category.id, "Some transaction"],
        [txn2.id, account.id, category.id, "Some transaction"],
        [txn3.id, account.id, category.id, "Some transaction"]
      ]
    end
    it "doesn't apply the rule to transactions that don't match" do
      account1 = Factory(:account)
      category1 = Factory(:category)
      Factory(:transaction,
        :account => account1,
        :category => category1,
        :original_description => "LAMERZ"
      )
      account2 = Factory(:account)
      category2 = Factory(:category)
      rule = ImportRule.new(
        :account => account2,
        :category => category2,
        :pattern => /SOME TXN/,
        :description => "Some transaction"
      )
      rule.apply_to_all_transactions!
      Transaction.all.map {|t| [t.account_id, t.category_id, t.description] }.should == [
        [account1.id, category1.id, "LAMERZ"]
      ]
    end
  end

  describe '#pattern=' do
    it "ensures that pattern is stored as a Regexp" do
      @rule.pattern = "zing"
      @rule.pattern.should == /zing/
    end
  end
end