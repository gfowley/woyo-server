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

end

