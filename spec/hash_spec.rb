require File.dirname(__FILE__) + '/spec_helper'

describe Hash do
  before(:each) do
    @a = { :a => 'a' }
  end
  
  it "should not raise when required keys are present" do
    lambda { @a.assert_required_keys(:a) }.should_not raise_error
  end

  it "should raise when required keys are not present" do
    lambda { @a.assert_required_keys(:b) }.should raise_error(ArgumentError)
  end
end
