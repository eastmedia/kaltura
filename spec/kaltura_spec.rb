require File.dirname(__FILE__) + '/spec_helper'

describe Kaltura do
  describe "sessions" do
    before(:each) do
      @session_key = "foo"
    end
    
    after(:each) do
      Kaltura.admin_session_key = nil
      Kaltura.session_key = nil
    end
    
    it "should create an admin session when none exists" do
      Kaltura.should_receive(:create_session).with(true, {}).once.and_return(@session_key)
      Kaltura.admin_session_key.should == @session_key
    end
    
    it "should re-use an existing admin session when none exists" do
      Kaltura.should_receive(:create_session).with(true, {}).once.and_return(@session_key)
      Kaltura.admin_session_key
      Kaltura.admin_session_key.should == @session_key
    end
    
    it "should create a regular session when none exists" do
      Kaltura.should_receive(:create_session).with(false, {}).once.and_return(@session_key)
      Kaltura.session_key.should == @session_key
    end
    
    it "should re-use an existing regular session when one exists" do
      Kaltura.should_receive(:create_session).with(false, {}).once.and_return(@session_key)
      Kaltura.session_key
      Kaltura.session_key.should == @session_key
    end
  end
  
end

describe Kaltura, "using the real Kaltura backend" do
  before(:each) do
    load_config
    @user_id = "user_#{String.random}"
  end
  
  after(:each) do
    Kaltura.clear_sessions!
  end

  it "should create an admin session when none exists" do
    Kaltura.admin_session_key(:uid => @user_id).should_not be_nil
  end

end