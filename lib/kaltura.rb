require 'colored'
require 'active_support'
require 'active_resource'
require 'kaltura/kshow'
require 'kaltura/user'

unless defined?(RAILS_DEFAULT_LOGGER)
  Object.const_set(:RAILS_DEFAULT_LOGGER, Logger.new(File.dirname(__FILE__) + '/../test.log'))
  ActiveResource::Base.logger = RAILS_DEFAULT_LOGGER
else
  ActiveResource::Base.logger = Logger.new(RAILS_ROOT + '/log/kaltura.log')
end

class Hash
  def assert_required_keys(*required_keys)
    missing_keys = ([required_keys].flatten - keys)
    raise(ArgumentError, "The following key(s) are required but were not found: #{missing_keys.inspect}.") unless missing_keys.empty?
  end
end

module Kaltura
  @@config = {}
  mattr_reader :config
  FORMATS = { :xml => 2 }

  class << self
    def config=(options)
      @@config = options
    end
  
    def site
      config[:staging] == true ? URI.parse("http://sandbox.kaltura.com/") : URI.parse("http://www.kaltura.com/")
    end
  
    def site_path(path)
      "/index.php/partnerservices2/#{path}"
    end
  
    def session_key=(session_key)
      @session_key = session_key
    end
  
    def admin_session_key=(admin_session_key)
      @admin_session_key = admin_session_key
    end
  
    def session_key(options = {})
      if @session_key && uid_from_session_key(@session_key) == options[:uid]
        @session_key
      else
        @session_key = create_session(false, options)
      end
    end

    def admin_session_key(options = {})
      if @admin_session_key && uid_from_session_key(@admin_session_key) == options[:uid]
        @admin_session_key
      else
        @admin_session_key = create_session(true, options)
      end
    end
    
    def uid_from_session_key(key)
      Base64.decode64(key).split(";").last
    end

    def connection
      @connection ||= ActiveResource::Connection.new(site, ActiveResource::Formats[:xml])
    end

    def create_session(admin_session, options = {})
      session_params = {}
      session_params[:admin]  = admin_session ? 1 : 0
      session_params[:secret] = admin_session ? config[:admin_secret] : config[:secret]

      response = post("startsession", session_params.merge(options))
      (Hpricot.XML(response.body)/:result/:ks).inner_text
    end
  
    def to_form_data(form_params = {})
      params = {
        :format       => FORMATS[:xml],
        :partner_id   => config[:partner_id],
        :subp_id      => config[:subpartner_id],
        :detailed     => 1
      }.merge(form_params.symbolize_keys)
      params.assert_required_keys(:format, :partner_id, :subp_id, :uid)
      logger.info "TO_FORM_DATA: #{params.inspect}".magenta
      serialize_params(params)
    end
    
    def serialize_params(params)
      params.keys.map {|key| key.to_s }.sort.map {|key|
        "#{escape(key)}=#{escape(params[key.to_sym])}"
      }.join("&")
    end
    
    def post(path, options)
      connection.post(site_path(path), to_form_data(options), headers)
    end
  
    def headers
      @headers ||= { 'Content-Type' => 'application/x-www-form-urlencoded' }
    end
  
    # Escapes a query parameter. Stolen from RFuzz
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%' + $1.unpack('H2'*$1.size).join('%').upcase
      }.tr(' ', '+')
    end
    
    def logger
      ActiveResource::Base.logger
    end
    
    def clear_sessions!
      @session_key = nil
      @admin_session_key = nil
    end
    
  end
  
end