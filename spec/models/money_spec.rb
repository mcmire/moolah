require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe Money do
  describe '.get' do
    it "feeds the given value straight to Money.new" do
      Money.get(-2354).should == Money.new(-2354)
      Money.get("value" => "23.54", "type" => "debit").should == Money.new(-2354)
    end
    it "returns the given value if it's already a Money object" do
      Money.get(Money.new(-2354)).should == Money.new(-2354)
    end
  end
  
  describe '.set' do
    it "simply returns the integer amount stored inside the Money object" do
      Money.set(Money.new(-2354)).should == -2354
    end
    it "returns the given value if it's already an integer" do
      Money.set(-2354).should == -2354
    end
    it "also accepts a hash which it pipes straight through Money.new" do
      Money.set(:value => "23.54", :type => "debit").should == -2354
    end
  end
  
  describe '.new' do
    #context "when given a Money object" do
    #  it "sets @value to the money's value" do
    #    Money.new(Money.new(-2354)).value.should == "23.54"
    #  end
    #  it "sets @type to the money's type" do
    #    Money.new(Money.new(-2354)).type.should == "debit"
    #  end
    #  it "sets @amount to the money's amount" do
    #    Money.new(Money.new(-2354)).amount.should == -2354
    #  end
    #end
    context "when given a hash" do
      it "bails if the given hash is missing a value" do
        lambda { Money.new("value" => 23.54) }.should raise_error(ArgumentError)
      end
      it "bails if the given hash is missing a type" do
        lambda { Money.new("type" => "debit") }.should raise_error(ArgumentError)
      end
      it "sets @value to an unsigned dollars-and-cents version of the amount" do
        Money.new("value" => "23.54", "type" => "debit").value.should == "23.54"
      end
      it "converts value to a string" do
        Money.new("value" => 23.54, "type" => "debit").value.should == "23.54"
      end
      it "sets @type to the given type" do
        Money.new("value" => 23.54, "type" => "debit").type.should == "debit"
        Money.new("value" => 23.54, "type" => "credit").type.should == "credit"
      end
      it "converts type to a string" do
        Money.new("value" => 23.54, "type" => :debit).type.should == "debit"
        Money.new("value" => 23.54, "type" => :credit).type.should == "credit"
      end
      it "sets @amount to the amount in cents, as an integer" do
        Money.new("value" => "23.54", "type" => "debit").amount.should == -2354
        Money.new("value" => "23.54", "type" => "credit").amount.should == 2354
      end
    end
    context "when given an integer" do
      it "sets @value to an unsigned dollars-and-cents version of the amount" do
        Money.new(-2354).value.should == "23.54"
        Money.new(2354).value.should == "23.54"
      end
      it "sets @type to the detected type" do
        Money.new(-2354).type.should == "debit"
        Money.new(2354).type.should == "credit"
      end
      it "sets @amount to the given integer" do
        Money.new(-2354).amount.should == -2354
        Money.new(2354).amount.should == 2354
      end
    end
    context "when given nil" do
      it "doesn't set @value" do
        Money.new(nil).value.should == nil
      end
      it "doesn't set @type" do
        Money.new(nil).type.should == nil
      end
      it "doesn't set @amount" do
        Money.new(nil).amount.should == nil
      end
    end
    it "bails if given anything else" do
      lambda { Money.new(:something_else) }.should raise_error(ArgumentError)
    end
  end
  
  describe '#value_as_currency' do
    it "returns the value formatted as currency" do
      Money.new(3929).value_as_currency.should == "$39.29"
    end
    it "deals with negative numbers correctly" do
      Money.new(-3929).value_as_currency.should == "-$39.29"
    end
    it "returns nothing if no value stored" do
      Money.new(nil).value_as_currency.should == nil
    end
  end
  
  describe '#+' do
    it "works" do
      (Money.new(500) + 10).should == 510
    end
  end
  
  describe '#-' do
    it "works" do
      (Money.new(500) - 10).should == 490
    end
  end
  
  describe '#*' do
    it "works" do
      (Money.new(500) * 10).should == 5000
    end
  end
  
  describe '#/' do
    it "works" do
      (Money.new(500) / 10).should == 50
    end
  end
  
  describe '#==' do
    it "returns true if the given Money object has the same value as this one" do
      Money.new(:value => 23.54, :type => :debit).should == Money.new(:value => 23.54, :type => :debit)
      Money.new(:value => 23.54, :type => :debit).should == Money.new(-2354)
    end
    it "returns false if the given Money object doesn't have the same value as this one" do
      Money.new(:value => 23.54, :type => :debit).should_not == Money.new(:value => 23.59, :type => :debit)
      Money.new(:value => 23.54, :type => :debit).should_not == Money.new(-2359)
    end
    it "returns false if the given Money object doesn't have the same type as this one" do
      Money.new(:value => 23.54, :type => :debit).should_not == Money.new(:value => 23.54, :type => :credit)
      Money.new(:value => 23.54, :type => :debit).should_not == Money.new(2354)
    end
  end
  
  describe '#to_s' do
    it "returns the amount in cents (as a string, of course)" do
      Money.new(2354).to_s.should == "2354"
    end
  end
end