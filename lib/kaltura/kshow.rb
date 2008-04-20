require 'kaltura/base'
require 'kaltura/entry'
require 'kaltura/user'

module Kaltura
  class Kshow < Base
    admin_session_for :generate_widget, :clone_kshow, :destroy

    define_attributes :name, :description, :thumbnailUrl

    self.method_paths = { :create => "addkshow", :update => "updatekshow", :destroy => "deletekshow", :find => "getkshow", :find_all => "listkshows", :generate_widget => "generatewidget", :clone_kshow => "clonekshow" }

    class << self
    
      def collection_from_response(response)
        (Hpricot(response)/:result/:kshows).first.children
      end

      def find(id, options = {})
        options.update(:kshow_id => id)
        super(id, options)
      end

      def primary_node_name
        :kshow
      end

    end
  
    def generate_widget
      return @widget_code if @widget_code
      retrieve_session_for(:generate_widget)
      response = post(:generate_widget, @attributes)
      parse_response(response.body)
      @widget_code = (Hpricot.XML(result[:widget_code])/:generic_code).inner_html
    end
    
    def clone_kshow
      self.class.user_id = attributes[:user_id] if attributes[:user_id]
      attributes[:kshow_id] = id
      attributes.assert_required_keys(:kshow_id)
      
      retrieve_session_for(:clone_kshow)
      response = post(:clone_kshow, @attributes)
      parse_response(response.body)
      self.class.find(id_from_result)
    end
    
    def destroy
      self.class.user_id = attributes[:user_id] if attributes[:user_id]
      attributes[:kshow_id] = id
      attributes.assert_required_keys(:kshow_id)
      
      retrieve_session_for(:destroy)
      response = post(:destroy, @attributes)
      parse_response(response.body)
      deleted_id = Hpricot.XML(result[:deleted_kshow]).search("/id").inner_text
      deleted_id == id.to_s
    end
    
    def add_entry(entry_attributes)
      Kaltura::Entry.create(entry_attributes.merge(:kshow_id => id))
    end
    
    def entries
      return [] unless attributes[:entrys]
      Hpricot.XML(attributes[:entrys]).children.inject([]) do |entries, node|
        next entries if node.name == "num_0"
        entries << Kaltura::Entry.new_from_node(node)
        entries
      end
    end
    
    def views_count
      attributes[:plays].to_i
    end
    
    def entries_count
      entries.size
    end
    
    def show_entry
      return @show_entry if @show_entry
      return nil unless attributes[:showEntry]
      node = Hpricot.XML(attributes[:showEntry])
      @show_entry = Kaltura::Entry.new_from_node(node)
    end
    
    def thumbnail_url
      return nil unless show_entry
      show_entry.thumbnail_url
    end
  
  protected
    
    def before_create
      self.class.user_id = attributes[:user_id] if attributes[:user_id]
      self.class.prefix_attributes!(attributes)
    end
    
    def before_update
      self.class.user_id = attributes[:user_id] if attributes[:user_id]
      self.class.prefix_attributes!(attributes)
      attributes[:kshow_id] = id
      attributes.assert_required_keys(:kshow_id)
    end

  end
end