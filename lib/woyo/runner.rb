require_relative 'server'
require 'logger'

module Woyo

class Runner

  def self.run args, out: $stdout, err: $stderr

    @args = args.dup
    @out = out
    @err = err
    $stderr = @err if @err
    $stdout = @out if @out

    code = case @args.first
      when 'new'     then mode_new
      when 'update'  then mode_update
      when 'server'  then mode_server
      when 'console' then mode_console
      end
    return code if code
      
    if @args.empty? || @args.include?('-h') || @args.include?('--help')
      print_help
      return 0
    end

    if @args.include?('-v') || @args.include?('--version')
      print_version
      return 0
    end

  end

  def self.mode_new
    if @args.include?('-h') || @args.include?('--help')
      print_help_new
      return 0
    end
    mode, dir = @args.shift 2
    if dir.nil?
      print_error 'No directory provided'
      return -1
    end
    if File.exists? dir
      if Dir.exists? dir
        unless @args.include?('-f') || @args.include?('--force')
          print_error 'Directory already exists'
          return -2 
        end
      else
        print_error 'File exists with same name'
        return -3 
      end
    end
    FileUtils.mkdir_p dir
    [ 'public', 'views', 'world' ].each do |subdir|
      FileUtils.cp_r File.join( __dir__, '../../', subdir ), dir, preserve: true
    end
    FileUtils.ln_s 'foundation-5.2.2', File.join(dir,'public/server/foundation')
    FileUtils.ln_s 'jquery-2.1.1', File.join(dir,'public/server/jquery')
    return 0
  end

  def self.mode_update
    if @args.include?('-h') || @args.include?('--help')
      print_help_update
      return 0
    end
    unless in_server_directory?
      unless @args.include?('-f') || @args.include?('--force')
        print_error 'This is not a Woyo::Server directory'
        return -4
      end
    end
    [ 'public', 'views', 'world' ].each do |subdir|
      FileUtils.cp_r File.join( __dir__, '../../', subdir ), '.', preserve: true
    end
    FileUtils.ln_s 'foundation-5.2.2', 'public/server/foundation' unless File.exists? 'public/server/foundation'
    FileUtils.ln_s 'jquery-2.1.1', 'public/server/jquery' unless File.exists? 'public/server/jquery'
    return 0
  end

  def self.mode_server
    if @args.include?('-h') || @args.include?('--help')
      print_help_server
      return 0
    end
    unless in_server_directory?
      print_error 'This is not a Woyo::Server directory'
      return -4
    end
    Woyo::Server.run!
    return 0
  end

  def self.mode_console
    if @args.include?('-h') || @args.include?('--help')
      print_help_console
      return 0
    end
    unless in_server_directory?
      print_error 'This is not a Woyo::Server directory'
      return -4
    end
  end

  def self.in_server_directory?
    Dir['{public,views,world}'] == %w( public views world )
  end

  def self.print_help
    @err.puts "Usage: woyo ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_help_new
    @err.puts "Usage: woyo new ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_help_update
    @err.puts "Usage: woyo update ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_help_server
    @err.puts "Usage: woyo server ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_help_console
    @err.puts "Usage: woyo console ..."
    @err.puts
    @err.puts "............."
    @err.puts "............."
    @err.puts "............."
  end

  def self.print_error msg
    @err.puts "Error: #{msg}"
  end

  def self.print_version
    @err.puts "woyo server version #{Woyo::SERVER_VERSION}"
    @err.puts "woyo world  version #{Woyo::WORLD_VERSION}"
  end

end

end

