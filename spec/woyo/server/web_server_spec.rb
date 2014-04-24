require 'spec_helper.rb'
require 'woyo/server'

describe Woyo::WebServer, :type => :feature do

  it 'requires a world' do
    # run this before setting :world because setting.world becomes a class variable!?
    #expect{ get '/' }.to raise_error
    get '/'
    last_response.should_not be_ok
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
    visit '/'
    page.should have_selector '.location#location_home'
    page.should have_selector '.location#location_home .name',                      text: 'Home'
    page.should have_selector '.location#location_home .description',               text: 'Where the heart is.'
    page.should have_selector '.location#location_home .way#way_out'
    page.should have_selector '.location#location_home .way#way_out .name',         text: 'Door'
    page.should have_selector '.location#location_home .way#way_out .description',  text: 'A sturdy wooden door'
    page.should have_selector '.location#location_home .way#way_down'
    page.should have_selector '.location#location_home .way#way_down .name',        text: 'Stairs'
    page.should have_selector '.location#location_home .way#way_down .description', text: 'Rickety stairs lead down'
  end               

  it 'can go ways to other locations' do
    get '/'
    pending 'capybara to click ways to other locations'
  end

end

