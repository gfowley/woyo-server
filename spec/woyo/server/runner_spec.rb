require_relative '../../../lib/woyo/runner'
require 'fileutils'
require 'stringio'
require 'open-uri'

describe Woyo::Runner do

  before :each do
    @output = StringIO.new
    @error  = StringIO.new
  end

  before :all do
    @original_path = Dir.pwd
    File.basename(@original_path).should eq 'woyo-server'
    @test_dir = 'tmp/test'
  end

  it 'prints a helpful message to stderr for help (-h/--help) switch' do
    [['-h'],['--help']].each do |args|
      Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
      @error.string.should include 'woyo'
    end
  end

  it 'prints version info to stderr for version (-v/--version) switch' do
    [['-v'],['--version']].each do |args|
      Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
      @error.string.should include 'woyo'
      @error.string.should include Woyo::SERVER_VERSION 
      @error.string.should include Woyo::WORLD_VERSION 
    end
  end

  context 'new' do

    before :all do
      # @original_path = Dir.pwd
      # File.basename(@original_path).should eq 'woyo-server'
      # @test_dir = 'tmp/test'
      @expected_entries = [ '.', '..', 'public', 'views', 'world' ]
    end

    before :each do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
    end

    after :each do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'requires a directory be specified' do
      Woyo::Runner.run( ['new'], out: @output, err: @error ).should eq -1
    end

    it 'creates a world application directory' do
      [['new','testworld'],['new','test/testworld']].each do |args|
        Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
        Dir.should exist args[1]
        Dir.entries(args[1]).sort.should eq @expected_entries
      end
    end

    it 'requires force (-f/--force) for existing directory' do
      [['new','testworld'],['new','test/testworld'],['new','.']].each do |args|
        dir = args[1]
        FileUtils.mkdir_p dir
        Dir.should exist dir
        Woyo::Runner.run( args, out: @output, err: @error ).should eq -2
        [['--force'],['-f']].each do |force|
          FileUtils.mkdir_p dir
          Dir.should exist dir
          Woyo::Runner.run( args + force, out: @output, err: @error ).should eq 0
          Dir.should exist dir
          (Dir.entries(dir) & @expected_entries).sort.should eq @expected_entries      # subset
          FileUtils.rm_rf dir
        end                                     
      end
    end

    it 'help (-h/--help) explains new command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['new'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo new'
      end
    end

  end

  context 'server' do

    before :all do
      Dir.pwd.should eq @original_path
      FileUtils.rm_rf @test_dir
      FileUtils.mkdir_p @test_dir
      Dir.chdir @test_dir
      Dir.pwd.should eq File.join( @original_path, @test_dir )
      Woyo::Runner.run( ['new','testworld'], out: @output, err: @error ).should eq 0
      Dir.chdir 'testworld'
      Dir.pwd.should eq File.join( @original_path, @test_dir, 'testworld' )
    end

    after :all do
      Dir.chdir @original_path
      Dir.pwd.should eq @original_path
    end

    it 'starts a world application server' do
      File.open 'world/test.rb','w' do |f|
        f.puts "
          location :home do
            name 'Home'
            desciption 'No place like'
          end
        "
      end
      thread = Thread.new { Woyo::Runner.run( ['server'], out: @output, err: @error ) }
      thread.should be_alive
      sleep 2 
      @error.string.should include 'has taken the stage'
      expect { page = open("http://127.0.0.1:4567/").read }.to_not raise_error
      page.should include 'Home'
      page.should include 'No place like'
      Woyo::Server.stop!
      thread.join
    end

    it 'help (-h/--help) explains server command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['server'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo server'
      end
    end

  end

  context 'console' do

    it 'starts a world application console'

    it 'help (-h/--help) explains console command' do
      [['-h'],['--help']].each do |help|
        Woyo::Runner.run( ['console'] + help, out: @output, err: @error ).should eq 0
        @error.string.should include 'woyo console'
      end
    end

  end

end
