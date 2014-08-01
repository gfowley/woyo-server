require 'pry'
#require 'pry-rescue'
require 'rack/test'
ENV['RACK_ENV'] = 'test'

require 'capybara/rspec'
Capybara.app = Woyo::Server
Capybara.ignore_hidden_elements = false
#Capybara.default_driver = :selenium #:rack_test

module RSpecMixin
  include Rack::Test::Methods
  def app() Woyo::Server end
end

RSpec.configure { |c| c.include RSpecMixin }

