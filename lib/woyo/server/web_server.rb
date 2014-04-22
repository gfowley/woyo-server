require 'sinatra/base'

module Woyo

class WebServer < Sinatra::Application

  get '/' do
    # current location
    'Hello world!'
  end

  get '/go/:way' do
    # way.to location (from current location)
  end

  get '/action/:thing' do
    # default action on thing
  end

end

end
