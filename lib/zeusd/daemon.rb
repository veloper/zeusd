require 'thread'
require 'childprocess'
require 'pathname'
require 'file-tail'

require 'zeusd/daemon_exception'
require 'zeusd/daemon_logging'

module Zeusd
  class Daemon
    attr_reader :cwd, :verbose, :interpreter, :child_process

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

      self
    end

    def restart!(options = {})
      stop!.start!(options)
    end

    def stop!
      return self unless process

      # Kill process tree and wait for exits
      process.kill!(:recursive => true, :signal => "KILL", :wait => true)

      # Clean up socket file if stil exists
      (zeus_socket_file.delete rescue nil) if zeus_socket_file.exist?

      # Check for remaining processes
      living_processes = processes.select(&:alive?)
      raise DaemonException, "Unable to KILL processes: " + living_processes.join(', ') if living_processes.any?

      @process = nil

      self
    end

    def processes
      process ? [process, process.descendants].flatten : []
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

    def to_json(*args)
      {
        :class   => self.class.name,
        :cwd     => cwd.to_path,
        :verbose => verbose,
        :process => process
      }.to_json(*args)
    end

    protected

    def start_child_process!
      # Truncate and cast to File instance
      zeus_log_file.open("w") {}
      std_file = File.new(zeus_log_file, 'w+')
      std_file.sync = true

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
          log.tail do |line|
            interpreter.translate(line)
            puts line if verbose
          end
        end
      end

      # Block until the first zeus command has been registered
      sleep 0.1 until interpreter.commands.any?

      @child_process
    end

    include Zeusd::DaemonLogging
  end
end