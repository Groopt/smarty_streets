require 'cgi'
require 'json'
require 'smarty_streets/version'
require 'smarty_streets/configuration'
require 'smarty_streets/location'
require 'smarty_streets/request'

module SmartyStreets
  class << self
    attr_accessor :configuration

    # Call this method to set your configuration.
    #
    #   SmartyStreets.configure do |config|
    #     config.auth_id = 'AUTHID'
    #     config.auth_token = 'AUTHTOKEN'
    #     config.candidates = 1
    #     config.request_read_timeout = 5
    #     config.request_open_timeout = 5
    #   end
    def configure
      self.configuration = Configuration.new
      yield(configuration)
    end

    # Request standardization for an address
    def standardize
      location = Location.new
      yield(location)
      Request.new(location).standardize!
    end
  end
end
