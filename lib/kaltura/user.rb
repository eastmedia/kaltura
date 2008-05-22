require 'kaltura/base'

module Kaltura
  class User < Base
    define_attributes :screenName, :fullName, :email, :aboutMe, :tags, :gender
    admin_session_for :create, :update, :destroy, :update_user_id, :find
    
    self.method_paths = { :create => "adduser", :update => "updateuser", :find => "getuser", :destroy => "deleteuser",
                          :update_user_id => "updateuserid", :find => "getuser" }
    
    class << self
      def primary_key
        :puserId
      end
      
      def primary_node_name
        :user
      end
    
      def attribute_prefix
        "user"
      end
      
      def attributes_from_result(result)
        attributes_from_node((Hpricot.XML(result[primary_node_name])/:kuser).first)
      end
      
      def id_from_result(result)
        (Hpricot(result[primary_node_name])/:kuser/:puserid).first.inner_text
      end
      
      def find(id, options = {})
        options.update(:user_id => id)
        super(id, options)
      end

    end

    def update_user_id(new_user_id)
      attributes[:user_id] = id
      attributes[:new_user_id] = new_user_id
      attributes.assert_required_keys(:user_id, :new_user_id)
      
      retrieve_session_for(:update_user_id, attributes[:puserId])
      response = post(:update_user_id, attributes)
      parse_response(response.body)
      self.class.find(id_from_result, :uid => new_user_id)
    end

  private
  
    def before_create
      self.class.prefix_attributes!(attributes)
    end

    def before_update
      self.class.prefix_attributes!(attributes)
      attributes[:uid] = id
    end

  end
end