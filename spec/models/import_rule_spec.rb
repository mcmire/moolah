require File.expand_path(File.dirname(__FILE__) + "/spec_helper")

describe ImportRule do
  before do
    @rule = ImportRule.new
  end

  describe '#pattern=' do
    it "ensures that pattern is stored as a Regexp" do
      @rule.pattern = "zing"
      @rule.pattern.should == /zing/
    end
  end
end