require 'spec_helper'
require 'net/http'

describe SmartyStreets do
  let(:auth_id) { 'MYAUTHID' }
  let(:auth_token) { 'MYAUTHTOKEN' }
  let(:request_read_timeout) { 5 }
  let(:request_open_timeout) { 5 }
  let(:candidates) { 1 }

  before do
    SmartyStreets.configure do |c|
      c.auth_id    = auth_id
      c.auth_token = auth_token
      c.candidates = candidates
      c.request_read_timeout = request_read_timeout
      c.request_open_timeout = request_open_timeout
    end

    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to receive(:request)
      .with(an_instance_of(Net::HTTP::Get))
      .and_return(Net::HTTPResponse)
  end

  context SmartyStreets::Request do
    context 'unauthorized request' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(401)
      end

      specify 'raises an InvalidCredentials error' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::InvalidCredentials
      end
    end

    context 'malformed data' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(400)
      end

      specify 'raises a MalformedData error' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::MalformedData
      end
    end

    context 'payment required' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(402)
      end

      specify 'raises a PaymentRequired error' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::PaymentRequired
      end
    end

    context 'remote server error' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(500)
      end

      specify 'raises an RemoteServerError error' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::RemoteServerError
      end
    end

    context 'successful request' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(200)

        allow(Net::HTTPResponse).to receive(:body)
          .and_return(successful_response_data)
      end

      let(:successful_response_data) { '[{"input_index":0,"candidate_index":0,"delivery_line_1":"1 Infinite Loop","delivery_line_2":"PO Box 123","lastline":"Cupertino CA 95014-2083","delivery_point_barcode":"950142083017","components":{"primary_number":"1","street_name":"Infinite","street_suffix":"Loop","city_name":"Cupertino","state_abbreviation":"CA","zipcode":"95014","plus4_code":"2083","delivery_point":"01","delivery_point_check_digit":"7"},"metadata":{"record_type":"S","county_fips":"06085","county_name":"Santa Clara","carrier_route":"C067","congressional_district":"18","rdi":"Commercial","elot_sequence":"0031","elot_sort":"A","latitude":37.33118,"longitude":-122.03062,"precision":"Zip9"},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y"}},{"input_index":0,"candidate_index":1,"addressee":"Apple Computer","delivery_line_1":"1 Infinite Loop","lastline":"Cupertino CA 95014-2084","delivery_point_barcode":"950142084016","components":{"primary_number":"1","street_name":"Infinite","street_suffix":"Loop","city_name":"Cupertino","state_abbreviation":"CA","zipcode":"95014","plus4_code":"2084","delivery_point":"01","delivery_point_check_digit":"6"},"metadata":{"record_type":"F","county_fips":"06085","county_name":"Santa Clara","carrier_route":"C067","congressional_district":"18","rdi":"Commercial","elot_sequence":"0032","elot_sort":"A","latitude":37.33118,"longitude":-122.03062,"precision":"Zip9"},"analysis":{"dpv_match_code":"Y","dpv_footnotes":"AABB","dpv_cmra":"N","dpv_vacant":"N","active":"Y"}}]' }

      specify 'makes a request for a standardized address' do
        locations = SmartyStreets.standardize do |location|
          location.street = '1 infinite loop'
          location.street2 = 'PO Box 123'
          location.city = 'cupertino'
          location.state = 'calforna'
          location.zipcode = '95014'
        end

        expect(locations.first.street).to eq '1 Infinite Loop'
        expect(locations.first.city).to eq 'Cupertino'
        expect(locations.first.state).to eq 'CA'
        expect(locations.first.zipcode).to eq '95014-2083'
      end
    end

    context 'address with no candidates' do
      before do
        allow(Net::HTTPResponse).to receive(:code)
          .and_return(200)

        allow(Net::HTTPResponse).to receive(:body)
          .and_return(nil)
      end

      specify 'makes a request for a standardized address' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::NoValidCandidates
      end
    end

    context 'Connection Timeout' do
      before do
        allow(Net::HTTP).to receive(:start).and_raise(Net::OpenTimeout)
      end

      specify 'it times out trying to open connection' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error SmartyStreets::Request::RequestTimeOut
      end
    end

    context 'Read Timeout' do
      before do
        allow(Net::HTTP).to receive(:start).and_raise(Net::ReadTimeout)
      end

      specify 'it times out trying to read data' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error(SmartyStreets::Request::RequestTimeOut)
      end
    end

    context 'Connection Refused' do
      before do
        allow(Net::HTTP).to receive(:start).and_raise(Errno::ECONNREFUSED)
      end

      specify 'it refuses connection' do
        expect do
          SmartyStreets.standardize {}
        end.to raise_error(SmartyStreets::Request::RequestTimeOut)
      end
    end
  end

end
