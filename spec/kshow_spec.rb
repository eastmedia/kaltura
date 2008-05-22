require File.dirname(__FILE__) + '/spec_helper'

describe Kaltura::Kshow do
  before(:each) do
    @kshow = Kaltura::Kshow.new
  end
  
  it "should indicate zero views" do
    @kshow.views_count.should == 0
  end
end

describe Kaltura::Kshow, "using the real Kaltura backend" do
  before(:each) do
    load_config
    @uid = "uid_#{String.random}"
    @attr = {
      :name         => String.random,
      :description  => String.random,
      :uid          => @uid
    }
    @kshow = Kaltura::Kshow.create(@attr)
  end
  
  after(:each) do
    Kaltura.clear_sessions!
  end

  it "should be able to create a kshow" do
    @kshow.should_not be_new
  end
  
  it "should correctly save attributes" do
    kshow = Kaltura::Kshow.find(@kshow.id, :uid => @attr[:uid])
    kshow.name.should        == @attr[:name]
    kshow.description.should == @attr[:description]
  end
  
  it "should be able to find a kshow" do
    kshow = Kaltura::Kshow.find(@kshow.id, :uid => @attr[:uid])
    kshow.id.should == @kshow.id
  end
  
  it "should be able to update a kshow" do
    new_name = String.random
    @kshow.name = new_name
    @kshow.id.should_not be_nil
    @kshow.save
    kshow = Kaltura::Kshow.find(@kshow.id, :uid => @attr[:uid])
    kshow.name.should == new_name
  end
  
  it "should be able to generate a widget" do
    @kshow.generate_widget.should_not be_nil
  end

  it "should be able to add a widget" do
    @kshow.add_widget.should_not be_nil
  end

  it "should be able to clone a kshow" do
    cloned_kshow = @kshow.clone_kshow(@kshow.puser_id)
    cloned_kshow.should be_kind_of(Kaltura::Kshow)
  end
  
  it "should be able to destroy a kshow" do
    @kshow.destroy.should be_true
  end
  
  describe "concerning entries" do
    before(:each) do
      @attributes = { 
        :name       => String.random,
        :media_type => Kaltura::Entry::IMAGE, 
        :source     => Kaltura::Entry::FLICKR, 
        :url        => "http://www.flickr.com/photos/14516334@N00/345009210/",
        :uid        => @kshow.puser_id
      }
    end
    
    it "should be able to add an entry" do
      @entry = @kshow.add_entry(@attributes)
      @entry.should be_a_kind_of(Kaltura::Entry)
      @entry.should_not be_new
    end
    
    it "should correctly read its entries array" do
      @entry = @kshow.add_entry(@attributes)
      kshow = Kaltura::Kshow.find(@kshow.id, :uid => @kshow.puser_id)
      kshow.entries.should_not == []
      kshow.entries.first.id.should == @entry.id
    end
  end
end
