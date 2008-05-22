require 'net/http'
require 'hpricot'

module Kaltura
  class Base
    class_inheritable_accessor :admin_session_methods
    class_inheritable_accessor :defined_attributes
    class_inheritable_accessor :method_paths
    self.admin_session_methods = []
    self.defined_attributes = []
    self.method_paths = {}
    
    class << self
      def logger
        Kaltura.logger
      end

      def post(path, options = {})
        options[:uid] ||= options[:user_id]
        Kaltura.post(self.method_paths[path], options)
      end

      attr_accessor_with_default(:primary_key, :id)

      def create(attributes = {})
        self.new(attributes).save
      end

      def destroy(attributes = {})
        self.new(attributes).destroy
      end

      def find_all(options)
        options[:ks] = retrieve_session_for(:find_all, options[:uid])
        response = post(:find_all, options)
        collection = collection_from_response(response.body) || []
        collection.map { |record| instantiate_record(record) }
      end

      def find(id, options = {})
        options[:ks] = retrieve_session_for(:find, options[:uid])
        response = post(:find, options)
        instantiate_record(response.body)
      end

      def instantiate_record(node)
        result = parse_node_from_response(:result, node)
        self.new(attributes_from_result(result))
      end

      def new_from_node(node)
        self.new(attributes_from_node(node))
      end

      def attributes_from_node(node)
        node.children.inject({}) do |nodes,el|
          nodes[el.name.to_sym] = el.inner_html
          nodes
        end
      end
      
      def id_from_result(result)
        Hpricot(result[primary_node_name]).search("/id").inner_text
      end
      
      def attributes_from_result(result)
        attributes_from_node(Hpricot.XML(result[primary_node_name]))
      end
      
      def parse_node_from_response(node, response)
        attributes_from_node((Hpricot.XML(response)/node).first)
      end

      def prefix_attributes!(attributes)
        defined_attributes.each do |key|
          if attributes[key]
            camelized_key = "#{attribute_prefix}_#{key.to_s.camelize(:lower)}".to_sym
            attributes[camelized_key] = attributes[key]
            attributes.delete(key)
          end
        end
        attributes
      end
      
      def attribute_prefix
        primary_node_name
      end
      
      def primary_node_name
        raise NotImplementedError.new("must define primary_node_name")
      end
      
      def define_attributes(*attribute_names)
        attribute_names.each do |attribute_name|
          underscored_name = attribute_name.to_s.underscore
          define_method(underscored_name) { attributes[attribute_name].blank? ? nil : attributes[attribute_name] }
          define_method("#{underscored_name}=") { |value| attributes[attribute_name] = value }
          defined_attributes << attribute_name
        end
      end

      def admin_session_for(*method_names)
        method_names.each do |method_name|
          admin_session_methods << method_name.to_sym
        end
      end
      
      def admin_session_for?(method_name)
        admin_session_methods.include?(method_name)
      end

      def retrieve_session_for(method_name, uid)
        admin_session_for?(method_name) ? Kaltura.admin_session_key(:uid => uid) : Kaltura.session_key(:uid => uid)
      end

    end
    
    attr_accessor :attributes
    attr_accessor :errors
    attr_accessor :result
    attr_accessor :debug
    
    def initialize(attributes = {})
      @attributes = {}
      @errors     = {}
      @debug      = {}
      @result     = {}
      load(attributes)
    end
    
    def new?
      id.nil?
    end

    def has_errors?
      errors.any?
    end

    def id
      attributes[self.class.primary_key]
    end

    def id=(id)
      attributes[self.class.primary_key] = id
    end
    
    def save
      new? ? create : update
    end
    
    def destroy
      do_destroy
    end

    def parse_response(response)
      if response['Content-Length'] != "0" && response.strip.size > 0
        @errors = self.class.parse_node_from_response(:error, response)
        @debug  = self.class.parse_node_from_response(:debug, response)
        @result = self.class.parse_node_from_response(:result, response)
      end
    end
    
    def load(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.symbolize_keys.each do |key, value|
        @attributes[key] = value.dup rescue value
      end
      self
    end
    
  private
    
    def post(path, options = {})
      self.class.post(path, options)
    end
    
    def update
      before_update
      retrieve_session_for(:update, @attributes[:uid])
      response = post(:update, @attributes)
      self.parse_response(response.body)
      load_attributes_from_result
    end

    def create
      before_create
      retrieve_session_for(:create, @attributes[:uid])
      response = post(:create, @attributes)
      self.parse_response(response.body)
      self.id = id_from_result
      load_attributes_from_result
    end

    def do_destroy
      before_destroy
      retrieve_session_for(:destroy, @attributes[:uid])
      response = post(:destroy, @attributes)
      self.parse_response(response.body)
      self.id = id_from_result
      load_attributes_from_result
    end

    def load_attributes_from_result
      load(self.class.attributes_from_result(result))
    end

    def id_from_result
      self.class.id_from_result(result)
    end
    
    def before_create
      # Stub to be overridden
    end

    def before_update
      # Stub to be overridden
    end
    
    def before_destroy
      # Stub to be overriden
    end

    def retrieve_session_for(method_name, uid)
      @attributes[:ks] = self.class.retrieve_session_for(method_name, uid)
    end
    
    def logger
      self.class.logger
    end
    
  end
end
