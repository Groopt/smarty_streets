module SmartyStreets
  class Configuration
    # API url for SmartyStreets
    attr_accessor :api_url

    # AUTH ID from SmartyStreets
    attr_accessor :auth_id

    # AUTH TOKEN from SmartyStreets
    attr_accessor :auth_token

    # Number of candidates to provide when making a request.
    attr_accessor :candidates

    # HTTP Request Timeout
    attr_accessor :request_read_timeout
    attr_accessor :request_open_timeout

    def initialize
      @api_url = 'api.smartystreets.com'
      @candidates = 1
      @request_read_timeout = 5
      @request_open_timeout = 5
    end
  end
end
