require_relative '../../../lib/woyo/server'
require 'spec_helper.rb'
require 'fileutils'

describe Woyo::Server, :type => :feature do

  before :all do
    # directories
    @original_path = Dir.pwd
    File.basename(@original_path).should eq 'woyo-server'
    @test_dir = 'tmp/test'
    # worlds
    @small_world = Woyo::World.new do
      name "Small World"
      description "It's a small world after all"
      location :small
    end
    @home_world = Woyo::World.new do
      start :home
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
      location :garden do
        name 'Garden'
        description 'A peaceful green oasis of life in the midst of a gray city'
        way :in do
          name 'Door'
          description 'Door leads inside a cute cottage'
          to :home
        end
        way :down do
          name 'Bulkhead'
          description 'Rusty bulkhead door and stairs'
          to :cellar
        end
      end
      location :cellar do
        name 'Cellar'
        description 'Dark and damp, full of shadows and strange sounds'
        way :out do
          name 'Bulkhead'
          description 'Rusty bulkhead stairs and door'
          to :garden
        end
        way :up do
          name 'Stairs'
          description 'Rickety stairs lead up into light'
          to :home
        end
      end
    end
  end

  # these must be the first tests so that Woyo::Server.setting.world is not set
  # that is why this file is named 1_server_spec.rb

  context 'with no world' do

    it 'welcome page is displayed if there is no world' do
      visit '/'
      status_code.should eq 200
      page.should have_content 'Woyo'
    end

    it 'welcome page links to github docs' do
      visit '/'
      status_code.should eq 200
      page.should have_link '', href: 'https://github.com/iqeo/woyo-world/wiki'
      page.should have_link '', href: 'https://github.com/iqeo/woyo-server/wiki'
    end

    it 'uses foundation framework' do
      visit '/'
      status_code.should eq 200
      page.should have_css 'head link[href="foundation/css/foundation.css"]'
      page.should have_css 'head script[src="foundation/js/vendor/modernizr.js"]'
    end

  end

  context 'loads the world' do

    it 'from files in directory' do
      content1 = "
        name 'Simple'
        start :one
        location :one do
          description 'First'
        end
      "
      content2 = "
        location :two do
          description 'Second'
        end
      "
      FileUtils.mkdir_p @test_dir
      File.write File.join( @test_dir, 'file1.rb' ), content1
      File.write File.join( @test_dir, 'file2.rb' ), content2
      world = nil
      expect { world = Woyo::Server.load_world File.join( @test_dir, '*.rb' ) }.to_not raise_error
      Woyo::Server.set :world, world
      visit '/'
      status_code.should eq 200
      page.should have_title /^Simple$/
    end

    it 'shows filename and lineno in backtrace upon error' do
      bad_world = "
        location :bad do
          raise 'boom'
        end
      "
      expect { Woyo::Server.eval_world bad_world, 'bad_world' }.to raise_error { |e|
        e.message.should eq 'boom'
        e.backtrace.first.should =~ /^bad_world.3/
      }
    end

  end

  context 'describes the world' do

    it 'title is world name' do
      Woyo::Server.set :world, @small_world
      visit '/'
      status_code.should eq 200
      page.should have_title /^Small World$/
    end

    it 'without start location' do
      Woyo::Server.set :world, @small_world
      visit '/'
      #STDOUT.puts page.html
      #save_page
      status_code.should eq 200
      page.should have_selector '.world .name',        text: "Small World"
      page.should have_selector '.world .description', text: "It's a small world after all"
      page.should have_selector '.world .no-start'
      page.should_not have_selector '.world .start'
    end

    it 'with start location' do
      @small_world.start = :small
      Woyo::Server.set :world, @small_world
      visit '/'
      status_code.should eq 200
      page.should have_selector '.world .name',                      text: "Small World"
      page.should have_selector '.world .description',               text: "It's a small world after all"
      page.should have_selector '.world .start a[href="/location"]', text: "Start"
      page.should_not have_selector '.world .no-start'
    end

  end

  context 'describes locations' do

    it 'title is location name'  do
      Woyo::Server.set :world, @small_world
      visit '/location'
      status_code.should eq 200
      page.should have_title /^Small$/
    end

    it 'start location' do 
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home'
      page.should have_selector '.location#location_home .name',                      text: 'Home'
      page.should have_selector '.location#location_home .description',               text: 'Where the heart is.'
      page.should have_selector '.way#way_out'
      page.should have_selector '.way#way_out .name',         text: 'Door'
      page.should have_selector '.way#way_out .description',  text: 'A sturdy wooden door'
      page.should have_selector '.way#way_down'
      page.should have_selector '.way#way_down .name',        text: 'Stairs'
      page.should have_selector '.way#way_down .description', text: 'Rickety stairs lead down'
    end               

    it 'goes way to another location' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name', text: 'Garden'
    end

    it 'tracks location (go and come back)' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_in a#go_in'
      click_on 'go_in'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
    end

    it 'tracks location (loop both directions)' do
      Woyo::Server.set :world, @home_world
      visit '/location'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_down a#go_down'
      click_on 'go_down'
      status_code.should eq 200
      page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
      page.should have_selector '.way#way_up a#go_up'
      click_on 'go_up'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
      page.should have_selector '.way#way_down a#go_down'
      click_on 'go_down'
      status_code.should eq 200
      page.should have_selector '.location#location_cellar .name',              text: 'Cellar'
      page.should have_selector '.way#way_out a#go_out'
      click_on 'go_out'
      status_code.should eq 200
      page.should have_selector '.location#location_garden .name',              text: 'Garden'
      page.should have_selector '.way#way_in a#go_in'
      click_on 'go_in'
      status_code.should eq 200
      page.should have_selector '.location#location_home .name',                text: 'Home'
    end
  end

  context 'ways' do

    before :all do
      @ways_world = Woyo::World.new do
        start :home
        location :home do
          way :door do
            description open: 'A sturdy wooden door'
            going       open: 'The door opens, leading to a sunlit garden'
            to :garden
          end
          way :stairs do
            description closed: 'Broken stairs lead down into darkness.'
            going       closed: 'The broken stairs is impassable.'
          end
        end
      end
      Woyo::Server.set :world, @ways_world
    end

    context 'are described being' do

      before :each do
        visit '/location'
        status_code.should eq 200
      end

      it 'open' do
        page.should have_selector '.way#way_door a#go_door'
        page.should have_selector '.way#way_door .name',         text: 'Door'
        page.should have_selector '.way#way_door .description',  text: 'A sturdy wooden door'
      end

      it 'closed' do
        page.should have_selector '.way#way_stairs a#go_stairs'
        page.should have_selector '.way#way_stairs .name',         text: 'Stairs'
        page.should have_selector '.way#way_stairs .description',  text: 'Broken stairs lead down into darkness.'
      end

    end

    context 'are described going' do

      it 'closed'

      it 'open'

    end

  end

end

