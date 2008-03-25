$: << File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'test/unit'
require 'spec'
require 'kaltura'

unless defined?(RAILS_ENV)
  RAILS_ENV = "test"
end

PENDING_KALTURA_KS_ERROR = "We get an 'invalid ks' error when calling this. Awaiting feedback from Kaltura dev team."

def load_config
  # You can use a local kaltura.yml at the base dir of this plugin if you don't have this in a Rails app
  kaltura_yml = File.expand_path(File.dirname(__FILE__) + '/../kaltura.yml')
  # Try to use the kaltura.yml from the Rails app if we can't find a local one (should end up being the common practice)
  kaltura_yml = File.expand_path(File.dirname(__FILE__) + '/../../../../config/kaltura.yml') unless File.exists?(kaltura_yml)
  unless File.exists?(kaltura_yml)
    raise RuntimeError, "Unable to find \"config/kaltura.yml\" file."
  end
  
  Kaltura.config = YAML.load_file(kaltura_yml)[RAILS_ENV].symbolize_keys

  unless [:partner_id, :subpartner_id, :secret].all? {|key| Kaltura.config.key?(key) }
    raise RuntimeError, "Kaltura.config requires :partner_id, :subpartner_id, and :secret keys"
  end
end

class String
  def self.random(length=10)
    chars = ("a".."z").to_a
    string = ""
    1.upto(length) { |i| string << chars[rand(chars.size-1)]}
    return string
  end
end

