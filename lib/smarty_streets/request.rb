module SmartyStreets
  class Request
    class InvalidCredentials < Exception; end
    class MalformedData < Exception; end
    class PaymentRequired < Exception; end
    class NoValidCandidates < Exception; end
    class RemoteServerError < Exception; end
    class RequestTimeOut < Exception; end

    attr_accessor :location

    def initialize(location)
      @location = location
    end

    def standardize!
      url = build_request_url(@location)
      handle_response(send_request(url))
    end

    private

    def handle_response(response)
      fail InvalidCredentials if response.code.to_i == 401
      fail MalformedData      if response.code.to_i == 400
      fail PaymentRequired    if response.code.to_i == 402
      fail RemoteServerError  if response.code.to_i == 500
      fail NoValidCandidates  if response.body.nil?

      JSON.parse(response.body).collect do |l|
        location = Location.new
        location.street                 = l['delivery_line_1']
        location.street2                = l['delivery_line_2']
        location.city                   = l['components']['city_name']
        location.state                  = l['components']['state_abbreviation']
        location.zipcode                = l['components']['zipcode'] + '-' + l['components']['plus4_code']
        location.delivery_point_barcode = l['delivery_point_barcode']
        location.components             = l['components']
        location.metadata               = l['metadata']
        location.analysis               = l['analysis']
        location
      end
    end

    def send_request(url)
      uri = URI.parse(url)

      Net::HTTP.start(
        uri.host, uri.port,
        read_timeout: SmartyStreets.configuration.request_read_timeout,
        open_timeout: SmartyStreets.configuration.request_open_timeout,
        use_ssl: uri.port == 443
      ) do |http|
        http.request(Net::HTTP::Get.new(uri))
      end
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED
      raise RequestTimeOut
    end

    def build_request_url(location)
      parameters = {
        input_id: location.input_id,
        street: location.street,
        street2: location.street2,
        secondary: location.secondary,
        city: location.city,
        state: location.state,
        zipcode: location.zipcode,
        lastline: location.lastline,
        addressee: location.addressee,
        urbanization: location.urbanization,
        candidates: location.candidates || SmartyStreets.configuration.candidates,
        "auth-id" => SmartyStreets.configuration.auth_id,
        "auth-token" => SmartyStreets.configuration.auth_token
      }

      parameter_string = parameters.collect { |k,v|
        "#{k.to_s}=#{CGI.escape(v.to_s)}"
      }.join('&')

      'https://' + SmartyStreets.configuration.api_url + '/street-address/?' + parameter_string
    end
  end
end
