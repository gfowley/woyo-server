require 'rack/test'
require 'capybara/rspec'
# Capybara.app = Woyo::WebServer

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() described_class end
end

RSpec.configure { |c| c.include RSpecMixin }

