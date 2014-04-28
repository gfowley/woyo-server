require 'woyo/runner'
require 'fileutils'
require 'stringio'

describe Woyo::Runner do

  before :all do
    @original_path = Dir.pwd
    File.basename(@original_path).should eq 'woyo-server'
    @test_dir = 'tmp/test'
    @expected_entries = [ '.', '..', 'public', 'views', 'world' ]
  end

  before :each do
    Dir.pwd.should eq @original_path
    FileUtils.rm_rf @test_dir
    FileUtils.mkdir_p @test_dir
    Dir.chdir @test_dir
    Dir.pwd.should eq File.join( @original_path, @test_dir )
    @output = StringIO.new
    @error  = StringIO.new                 
  end

  after :each do
    Dir.chdir @original_path
    Dir.pwd.should eq @original_path
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

  it 'new <dir> command creates a world application directory' do
    [['new','testworld'],['new','test/testworld']].each do |args|
      Woyo::Runner.run( args, out: @output, err: @error ).should eq 0
      Dir.should exist args[1]
      Dir.entries(args[1]).sort.should eq @expected_entries
    end
  end

  it 'new command requires a directory be specified' do
    Woyo::Runner.run( ['new'], out: @output, err: @error ).should eq -1
  end

  it 'new <dir> requires force (-f/--force) for existing directory' do
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

  it 'new command + help (-h/--help) explains new command' do
    [['-h'],['--help']].each do |help|
      Woyo::Runner.run( ['new'] + help, out: @output, err: @error ).should eq 0
      @error.string.should include 'woyo new'
    end
  end

  it 'server command starts a world application server'

  it 'server command + help (-h/--help) explains server command'

  it 'console command starts a world application conosle'

  it 'console command + help (-h/--help) explains console command'

end
