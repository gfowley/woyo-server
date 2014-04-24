require 'woyo/server'
require 'rack/test'
require 'capybara/rspec'
Capybara.app = Woyo::Server::Server

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Woyo::Server::Server end
end

RSpec.configure { |c| c.include RSpecMixin }

