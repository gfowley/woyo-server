require_relative '../../../lib/woyo/server'
require 'spec_helper.rb'
require 'fileutils'

describe Woyo::Server, :type => :feature  do

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
      page.should have_link '', href: 'https://iqeo.github.io/woyo-world/'
      page.should have_link '', href: 'https://iqeo.github.io/woyo-server/'
    end

    it 'uses foundation framework' do
      visit '/'
      status_code.should eq 200
      page.should have_css 'head link[href="foundation-5.2.2/css/foundation.css"]'
      page.should have_css 'head script[src="foundation-5.2.2/js/vendor/modernizr.js"]'
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
      visit '/'
      click_on 'start'
      status_code.should eq 200
      page.should have_title /^Small$/
    end

    it 'start location' do 
      Woyo::Server.set :world, @home_world
      visit '/'
      click_on 'start'
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

  end

  context 'ways' do

    before :all do
      @ways_world = Woyo::World.new do
        start :home
        location :home do
          way :door do
            description open: 'A sturdy wooden door',                       closed: 'Never closed'
            going       open: 'The door opens, leading to a sunlit garden', closed: 'Never closed'
            to :garden
          end
          way :stairs do
            description closed: 'Broken stairs lead down into darkness.', open: 'Never open' 
            going       closed: 'The broken stairs are impassable.',      open: 'Never open' 
          end
          way :window do
            description 'A nice view.'
            going       'Makes no difference.'
            to :yard
          end
        end
      end
      Woyo::Server.set :world, @ways_world
    end

    context 'are described' do

      before :each do
        visit '/'
        click_on 'start'
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

    context 'are described with default' do

      it 'open' do
        window = @ways_world.locations[:home].ways[:window]
        window.open!
        window.should be_open
        visit '/'
        click_on 'start'
        status_code.should eq 200
        page.should have_selector '.way#way_window a#go_window'
        page.should have_selector '.way#way_window .name',         text: 'Window'
        page.should have_selector '.way#way_window .description',  text: 'A nice view.'
      end

      it 'closed' do
        window = @ways_world.locations[:home].ways[:window]
        window.close!
        window.should be_closed
        visit '/'
        click_on 'start'
        status_code.should eq 200
        page.should have_selector '.way#way_window a#go_window'
        page.should have_selector '.way#way_window .name',         text: 'Window'
        page.should have_selector '.way#way_window .description',  text: 'A nice view.'
      end

    end

    context 'are described going', :js => true do

      before :each do
        visit '/'
        page.find('body', visible: true)
        click_on 'start'
      end

      it 'open' do
        page.should have_selector '.way#way_door a#go_door'
        click_link 'go_door'
        page.should have_selector '.way#way_door .going',            text: 'The door opens, leading to a sunlit garden' 
        sleep 3
        page.should have_selector '.location#location_garden .name', text: 'Garden'
      end

      it 'closed' do
        page.should have_selector '.way#way_stairs a#go_stairs'
        click_link 'go_stairs'
        page.should have_selector '.way#way_stairs .going',        text: 'The broken stairs are impassable.'
        page.should have_selector '.location#location_home .name', text: 'Home'
      end

    end

    context 'are described going with default', :js => true do

      it 'open' do
        window = @ways_world.locations[:home].ways[:window]
        window.open!
        window.should be_open
        visit '/'
        click_on 'start'
        page.should have_selector '.way#way_window a#go_window'
        click_link 'go_window'
        page.should have_selector '.way#way_window .going',        text: 'Makes no difference.' 
        sleep 3
        page.should have_selector '.location#location_yard .name', text: 'Yard'
      end

      it 'closed' do
        window = @ways_world.locations[:home].ways[:window]
        window.close!
        window.should be_closed
        visit '/'
        click_on 'start'
        page.should have_selector '.way#way_window a#go_window'
        click_link 'go_window'
        page.should have_selector '.way#way_window .going',        text: 'Makes no difference.' 
        page.should have_selector '.location#location_home .name', text: 'Home'
      end

    end

  end

end

