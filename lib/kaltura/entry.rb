require 'kaltura/base'

module Kaltura
  class Entry < Base
    MEDIA_TYPES = [
      VIDEO = 1,
      IMAGE = 2,
      AUDIO = 5
    ]

    MEDIA_SOURCES = [
      KALTURA       = 20,
      MYCLIPS       = 21,
      FILE          = 1,
      WEBCAM        = 2,
      FLICKR        = 3,
      YOUTUBE       = 4,
      URL           = 5,
      MYSPACE       = 7,
      PHOTO_BUCKET  = 8,
      JAMENDO       = 9,
      CCMIXTER      = 10,
      NYPL          = 11,
      CURRENT       = 12,
      MEDIA_COMMONS = 13,
    ]
    
    self.method_paths = { :find => "getentry", :update => "updateentry", :create => "addentry" }

    define_attributes :name, :sourceLink, :mediaType, :type, :thumbnailUrl, :kshowId
    
    class << self
      def find(id, options = {})
        attributes[:entry_id] = id
        attributes.assert_required_keys(:entry_id)
        super(id, options)
      end

      def primary_node_name
        :entry
      end
      
      def attribute_prefix
        "entry1"
      end

      def attributes_from_result(result)
        attributes_from_node(Hpricot(result[:entries]).children.first)
      end

      def id_from_result(result)
        Hpricot(result[:entries]).search("entry1_/id").inner_text
      end
    end
    
  private
  
    def before_create
      self.class.prefix_attributes!(attributes)
      attributes.assert_required_keys(:kshow_id)
    end

  end
end