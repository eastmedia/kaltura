$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'kaltura'

kaltura_yml = File.join(RAILS_ROOT, 'config', 'kaltura.yml')
unless File.exists?(kaltura_yml)
  raise RuntimeError, "Unable to find \"config/kaltura.yml\" file."
end

Kaltura.config = YAML.load_file(kaltura_yml).recursively_symbolize_keys[RAILS_ENV.to_sym]

unless [:partner_id, :subpartner_id, :secret].all? {|key| Kaltura.config.key?(key) }
  raise RuntimeError, "Kaltura.config requires :partner_id, :subpartner_id, and :secret keys"
end

