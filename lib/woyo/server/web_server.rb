require 'sinatra/base'
require 'haml'
require 'woyo/dsl'

module Woyo

class WebServer < Sinatra::Application

  configure do
    set root: '.'
  end

  get '/' do
    @location = Woyo::Location.new :home do
      name 'Home'
      description 'Where the heart is.'
      way :out do
        name 'Door'
        description 'A sturdy wooden door, old fashioned farmhouse style of a bygone era.'
        to :garden
      end
      way :down do
        name 'Stairs'
        description 'Rickety stairs lead down into darkness. A dank smell emanates from the darkness below'
        to :cellar
      end
    end
    haml :location
  end

  get '/go/:way' do
    # way.to location (from current location)
  end

  get '/action/:thing' do
    # default action on thing
  end

end

end
