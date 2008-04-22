require File.dirname(__FILE__) + '/spec_helper'

describe Kaltura::Entry do
  before(:each) do
    @entry = Kaltura::Entry.new
  end
  
  it "should have nil attributes for name, media_type, source_link and thumbnail_url" do
    @entry.name.should be_nil
    @entry.source_link.should be_nil
    @entry.media_type.should be_nil
    @entry.thumbnail_url.should be_nil
  end
end

describe Kaltura::Entry, "using the real Kaltura backend" do
  before(:each) do
    load_config
    @uid = "uid_#{String.random}"
    @kshow = Kaltura::Kshow.create(:name => String.random, :description => String.random, :uid => @uid)
  end
  
  it "should be able to create an entry" do
    attributes = { 
      :name       => String.random,
      :media_type => Kaltura::Entry::IMAGE, 
      :source     => Kaltura::Entry::FLICKR, 
      :url        => "http://www.flickr.com/photos/14516334@N00/345009210/",
      :kshow_id   => @kshow.id,
      :uid        => @uid
    }
    entry = Kaltura::Entry.create(attributes)
    entry.should be_a_kind_of(Kaltura::Entry)
    entry.id.to_i.should > 0
  end
end