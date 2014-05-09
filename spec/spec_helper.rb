require 'rack/test'
require 'capybara/rspec'
Capybara.app = Woyo::Server
Capybara.ignore_hidden_elements = false

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() Woyo::Server end
end

RSpec.configure { |c| c.include RSpecMixin }

