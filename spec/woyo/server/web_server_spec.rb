require 'spec_helper.rb'
require 'woyo/server'

describe Woyo::WebServer do

  it 'requires a world' do
    # run this before setting :world because setting.world becomes a class variable!?
    expect{ get '/' }.to raise_error
  end

  it 'accepts a world' do
    small_world = Woyo::World.new do
      location :small
    end
    Woyo::WebServer.set :world, small_world
    get '/'
    last_response.should be_ok
  end

  it 'describes a location' do
    home_world = Woyo::World.new do
      location :home do
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
    end
    Woyo::WebServer.set :world, home_world
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

