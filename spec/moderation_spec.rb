require File.dirname(__FILE__) + '/spec_helper'

describe Kaltura::Moderation do
  before(:each) do
    @moderation = Kaltura::Moderation.new
  end
  
  it "should have nil attributes for id, :status, :comments, :objectType, :objectId" do
    @moderation.id.should be_nil
    @moderation.status.should be_nil
    @moderation.comments.should be_nil
    @moderation.object_type.should be_nil
    @moderation.object_id.should be_nil
  end
end

describe Kaltura::Moderation, "using the real Kaltura backend" do
  before(:each) do
    load_config
    @uid = "uid_#{String.random}"
    @kshow = Kaltura::Kshow.create(:name => String.random, :description => String.random, :uid => @uid)

    entry_attributes = { 
      :name       => String.random,
      :media_type => Kaltura::Entry::IMAGE, 
      :source     => Kaltura::Entry::FLICKR, 
      :url        => "http://www.flickr.com/photos/14516334@N00/345009210/",
      :kshow_id   => @kshow.id,
      :uid        => @uid
    }
    @entry = Kaltura::Entry.create(entry_attributes)
  end
  
  it "should be able to create a moderation record" do
    attributes = {
      :objectType => Kaltura::Moderation::ENTRY,
      :objectId   => @entry.id
    }
    moderation = Kaltura::Moderation.create(attributes)
    moderation.should be_a_kind_of(Kaltura::Moderation)
    moderation.id.to_i.should > 0
    moderation.object_id.should == @entry.id
  end

  it "should be able to update a moderation record" do
    pending "Waiting on Kaltura to complete moderation API"
    attributes = {
      :objectType => Kaltura::Moderation::ENTRY,
      :objectId   => @entry.id
    }
    moderation = Kaltura::Moderation.create(attributes)
    moderation.should be_a_kind_of(Kaltura::Moderation)
    moderation.id.to_i.should > 0
    moderation.object_id.should == @entry.id

    moderation.status = Kaltura::Moderation::BLOCK
    moderation.save
    moderation.status.should == Kaltura::Moderation::BLOCK
  end
end