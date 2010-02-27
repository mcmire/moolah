#gem 'mcmire-matchy'
require 'matchy'

# Matchy/Protest integration
Matchy.adapter :protest, "Protest" do
  def assertions_module; Test::Unit::Assertions; end
  def test_case_class; Protest::TestCase; end
  def assertion_failed_error; Protest::AssertionFailed; end
end
Matchy.use(:protest)