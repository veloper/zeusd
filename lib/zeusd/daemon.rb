require 'thread'
require 'childprocess'
require 'pathname'
require 'hooks'

module Zeusd
  class DaemonException < StandardError; end

  class Daemon
    attr_reader :cwd, :verbose, :log_file, :log_queue, :interpreter, :child_process


    include Hooks
    define_hooks :after_start!, :after_stop!, :after_output

    after_start!  { log(:start) }
    after_stop!   { log(:stop) }
    after_output  {|x| log(x, :zeus) }

    after_stop! do
      (socket_file.delete rescue nil) if socket_file.exist?
    end

    after_output do |output|
      interpreter.translate(output)
      puts(output) if verbose?
    end

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
    ensure
      run_hook :after_start!
    end

    def restart!(options = {})
      stop!.start!(options)
    end

    def stop!
      return self unless process

      # Kill process tree and wait for exits
      process.kill!(:recursive => true, :wait => true)

      # Check for remaining processes
      if[process, process.descendants].flatten.select(&:alive?).any?
        raise DaemonException, "Unable to KILL processes: " + alive_processes.join(', ')
      end

      @process = nil

      self
    ensure
      run_hook :after_stop!
    end

    def process
      @process ||= Process.all.find {|p| !!p.command[/zeus.*start$/] && p.cwd == cwd }
    end

    def loaded?
      interpreter.complete?
    end

    def log_file
      cwd.join('log/zeusd.log')
    end

    def socket_file
      cwd.join('.zeus.sock')
    end

    def verbose?
      !!verbose
    end

    protected

    def log(entry, type = :zeusd)
      log_queue << "<#{type.to_s} utc='#{Time.now.utc}'>#{entry}</#{type.to_s}>\n"
    end

    def log_queue
      @log_queue ||= Queue.new
    end

    def ensure_log_worker
      @log_worker ||= Thread.new do
        while value = log_queue.shift
          log_file.open("a+") {|f| f.write(value) }
        end
      end
    end

    def start_child_process!
      @reader, @writer = IO.pipe
      @child_process = ChildProcess.build("zeus", "start")
      @child_process.environment["BUNDLE_GEMFILE"] = cwd.join("Gemfile").to_path
      @child_process.io.stdout = @child_process.io.stderr = @writer
      @child_process.cwd = cwd.to_path
      @child_process.detach = true
      @child_process.start

      @writer.close

      ensure_log_worker

      Thread.new do
        while (buffer = (@reader.readpartial(10000) rescue nil)) do
          run_hook :after_output, buffer
        end
      end

      sleep 0.1 until interpreter.commands.any?

      @child_process
    end

  end
end