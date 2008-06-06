require 'kaltura/base'

module Kaltura
  class Moderation < Base
    OBJECT_TYPES = [
      KSHOW = 1,
      ENTRY = 2,
      KUSER = 3
    ]

    MODERATION_STATUS = [
      PENDING = 1,
      ALLOW   = 2,
      BLOCK   = 3,
      DELETE  = 4,
      REVIEW  = 5
    ]

    define_attributes :id, :status, :comments, :objectType, :objectId
    admin_session_for :create, :update, :destroy, :find

    self.method_paths = { :find => "listmoderations", :update => "handlemoderation", :create => "addmoderation" }
    
    class << self
      def find(id, options = {})
        attributes[:moderation_id] = id
        attributes.assert_required_keys(:moderation_id)
        super(id, options)
      end

      def primary_node_name
        :moderation
      end
      
      def attribute_prefix
        "moderation"
      end

      def attributes_from_result(result)
        attributes_from_node(Hpricot.XML(result[primary_node_name]))
      end

      def id_from_result(result)
        Hpricot(result[primary_node_name]).search("moderation/id").inner_text
      end
    end
    
  private
    
    def before_create
      self.class.prefix_attributes!(attributes)
    end

    def before_update
      self.class.prefix_attributes!(attributes)
    end
  end
end