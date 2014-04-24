require 'woyo/server'
require 'rack/test'
require 'capybara/rspec'
Capybara.app = Woyo::WebServer

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Woyo::WebServer end
end

RSpec.configure { |c| c.include RSpecMixin }

