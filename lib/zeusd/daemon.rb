require 'logger'
require 'thread'
require 'childprocess'
require 'pathname'
require 'hooks'
require 'file-tail'
require 'json'

module Zeusd
  class DaemonException < StandardError; end

  class Daemon
    include Hooks

    define_hooks :before_action, :after_action, :after_output

    before_action do |action|
      details = {}
      details[:process] = process.attributes if process
      log_event("Before: #{action}", details)
    end

    after_action do |action|
      details = {}
      details[:process] = process.attributes if process
      log_event("After: #{action}", details)
    end

    after_output do |output|
      interpreter.translate(output)
      puts output if verbose
    end

    attr_reader :cwd, :verbose, :log_file, :interpreter, :child_process

    def initialize(options = {})
      @cwd         = Pathname.new(options[:cwd] || Dir.pwd).realpath
      @verbose     = !!options[:verbose]
      @interpreter = Interpreter.new
    end

    def start!(options = {})
      run_hook :before_action, __method__

      start_child_process!

      @process = Zeusd::Process.find(child_process.pid)

      if options.fetch(:block, false)
        sleep(0.1) until loaded?
      end

      run_hook :after_action, __method__

      self
    end

    def restart!(options = {})
      run_hook :before_action, __method__

      stop!.start!(options)

      run_hook :after_action, __method__

      self
    end

    def stop!
      run_hook :before_action, __method__

      return self unless process

      # Kill process tree and wait for exits
      process.kill!(:recursive => true, :wait => true)

      # Clean up socket file if stil exists
      (zeus_socket_file.delete rescue nil) if zeus_socket_file.exist?

      # Check for remaining processes
      if[process, process.descendants].flatten.select(&:alive?).any?
        raise DaemonException, "Unable to KILL processes: " + alive_processes.join(', ')
      end

      @process = nil

      run_hook :after_action, __method__

      self
    end

    def process
      @process ||= Process.all.find {|p| !!p.command[/zeus.*start$/] && p.cwd == cwd }
    end

    def loaded?
      interpreter.complete?
    end

    def zeus_socket_file
      cwd.join('.zeus.sock')
    end

    def zeus_log_file
      cwd.join('log', 'zeus.log').tap do |path|
        FileUtils.touch(path.to_path)
      end
    end

    protected

    def log_event(type, details = nil)
      logger.info do
        "\e[35m[Event] (#{type})\e[0m" + (!details.empty? ? " " + JSON.pretty_generate(details) : "")
      end
    end

    def logger
      @logger ||= Logger.new(cwd.join('log', 'zeusd.log').to_path).tap do |x|
        x.formatter = proc do |severity, datetime, progname, msg|
          prefix    = "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}]"
          "\e[36m#{prefix}\e[0m" + " #{msg}\n"
        end
      end
    end

    def start_child_process!
      # Truncate and cast to File
      zeus_log_file.open("w") {}
      std_file = File.new(zeus_log_file, 'w+').tap{|x| x.sync = true}

      # Prep and Start child process
      @child_process = ChildProcess.build("zeus", "start")
      @child_process.environment["BUNDLE_GEMFILE"] = cwd.join("Gemfile").to_path
      @child_process.io.stderr = std_file
      @child_process.io.stdout = std_file
      @child_process.cwd       = cwd.to_path
      @child_process.detach    = true
      @child_process.start

      # Start tailing child process output
      Thread.new do
        File.open(std_file.to_path) do |log|
          log.extend(File::Tail)
          log.interval = 0.1
          log.backward(100)
          log.tail {|line| run_hook(:after_output, line) }
        end
      end

      # Block until the first zeus command has been registered
      sleep 0.1 until interpreter.commands.any?

      @child_process
    end

  end
end