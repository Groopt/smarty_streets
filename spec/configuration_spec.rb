require 'spec_helper'

describe SmartyStreets::Configuration do
  before do
    SmartyStreets.configure do |c|
      c.api_url = 'apiurl'
      c.auth_id = 'MYAUTHID'
      c.auth_token = 'MYAUTHTOKEN'
      c.candidates = 1
      c.request_read_timeout = 1
      c.request_open_timeout = 1
    end
  end

  it 'sets the api_url' do
    expect(SmartyStreets.configuration.api_url).to eq 'apiurl'
  end

  it 'sets the auth_id' do
    expect(SmartyStreets.configuration.auth_id).to eq 'MYAUTHID'
  end

  it 'sets the auth_token' do
    expect(SmartyStreets.configuration.auth_token).to eq 'MYAUTHTOKEN'
  end

  it 'sets the candidates' do
    expect(SmartyStreets.configuration.candidates).to eq 1
  end

  it 'sets the request timeout' do
    expect(SmartyStreets.configuration.request_read_timeout).to eq 1
    expect(SmartyStreets.configuration.request_open_timeout).to eq 1
  end
end
