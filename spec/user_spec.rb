require File.dirname(__FILE__) + '/spec_helper'

describe Kaltura::User do
  it "should require an admin session for :create" do
    Kaltura::User.admin_session_for?(:create).should be_true
  end

  it "should not require an admin session for :foo" do
    Kaltura::Kshow.class_eval do
      admin_session_for :foo
    end
    Kaltura::User.admin_session_for?(:foo).should be_false
  end
end

describe Kaltura::User, "using the real Kaltura backend" do
  before(:each) do
    load_config
    @uid = "uid_#{String.random}"
    @user_id = "user_#{String.random}"
    @attributes = {
      :user_id      => @user_id,
      :screenName   => "Screen #{String.random}", 
      :fullName     => "Fullname #{String.random}",
      :email        => "#{String.random}@#{String.random}.com",
      :aboutMe      => "About #{String.random}",
      :uid          => @uid
    }
  end
  
  after(:each) do
    Kaltura.clear_sessions!
  end
  
  it "should be able to create a user" do
    user = Kaltura::User.create(@attributes)
    user.should be_a_kind_of(Kaltura::User)
    user.id.should == @user_id
  end

  describe "retrieving a user" do
    before(:each) do
      Kaltura::User.create(@attributes)
      @user = Kaltura::User.find(@user_id, :uid => @user_id)
    end
    
    it "should be able to retrieve the correct user" do
      @user.id.should == @user_id
    end
    
    it "should have the same attributes it was created with" do
      @user.full_name.should == @attributes[:fullName]
      @user.screen_name.should == @attributes[:screenName]
    end
    
    xit "should be able to update a user" do
      pending "Kaltura fails indicating screen name already exists, but none was included in the POST" do
        full_name = "Fun #{String.random}"
        @user.full_name = full_name
        @user.attributes.delete(:screenName)
        @user.save
        new_user = Kaltura::User.find(@user.id)
        new_user.full_name.should == full_name
      end
    end
  end
  
end