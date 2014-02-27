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

    define_hooks :after_start!, :after_stop!, :before_stop!, :after_output

    after_start! { log_event :start, :process => process ? process.attributes : nil }
    before_stop! { log_event :stop, :process => process ? process.attributes : nil }

    after_stop! do
      (zeus_socket_file.delete rescue nil) if zeus_socket_file.exist?
    end

    after_output do |output|
      interpreter.translate(output)
      # logger.info("Zeus"){output}
      puts(output) if verbose
    end

    attr_reader :cwd, :verbose, :log_file, :interpreter, :child_process

    def initialize(options = {})
      @cwd         = Pathname.new(options[:cwd] || Dir.pwd).realpath
      @verbose     = !!options[:verbose]
      @interpreter = Interpreter.new
    end

    def start!(options = {})
      start_child_process!

      @process = Zeusd::Process.find(child_process.pid)

      if options.fetch(:block, false)
        sleep(0.1) until loaded?
      end

      run_hook :after_start!

      self
    end

    def restart!(options = {})
      stop!.start!(options)
    end

    def stop!
      run_hook :before_stop!

      return self unless process

      # Kill process tree and wait for exits
      process.kill!(:recursive => true, :wait => true)

      # Check for remaining processes
      if[process, process.descendants].flatten.select(&:alive?).any?
        raise DaemonException, "Unable to KILL processes: " + alive_processes.join(', ')
      end

      @process = nil

      run_hook :after_stop!

      self
    end

    def process
      @process ||= Process.all.find {|p| !!p.command[/zeus.*start$/] && p.cwd == cwd }
    end

    def loaded?
      interpreter.complete?
    end

    def log_event(type, details = nil)
      logger.info("EVENT") do
        ">>> #{type.to_s.upcase}" + (details ? (" >>> " + JSON.pretty_generate(details)) : "")
      end
    end

    def logger
      @logger ||= Logger.new(log_file.to_path).tap do |x|
        x.formatter = proc do |severity, datetime, type, msg|
          prefix    = "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}][#{type}]"
          msg       = msg.chomp.gsub("\n", "\n".ljust(prefix.length) + "\e[36m|\e[0m ")
          "\e[36m#{prefix}\e[0m" + " #{msg}\n"
        end
      end
    end

    def zeus_socket_file
      cwd.join('.zeus.sock')
    end

    def log_file
      cwd.join('log/zeusd.log')
    end

    def zeus_log_file
      cwd.join('.zeus.log').tap do |path|
        FileUtils.touch(path.to_path)
      end
    end

    protected

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