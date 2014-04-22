require 'rack/test'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure { |c| c.include RSpecMixin }

require 'woyo/server'

describe Woyo::WebServer do

  it 'starts a server' do
    get '/'
    last_response.should be_ok
  end

  it 'describes a location' do
    get '/'
    (last_response.body =~ /id='location_home'/).should be_true
    (last_response.body =~ /class='location'/).should be_true
    (last_response.body =~ /class='name'/).should be_true
    (last_response.body =~ /class='description'/).should be_true
    (last_response.body =~ /id='way_out'/).should be_true
    (last_response.body =~ /class='way'/).should be_true
    (last_response.body =~ /class='name'/).should be_true
    (last_response.body =~ /class='description'/).should be_true
    (last_response.body =~ /id='way_down'/).should be_true
    (last_response.body =~ /class='way'/).should be_true
    (last_response.body =~ /class='name'/).should be_true
    (last_response.body =~ /class='description'/).should be_true
  end               

  it 'can go ways to other locations' do
    get '/'
    pending 'capybara to click ways to other locations'
  end

end

