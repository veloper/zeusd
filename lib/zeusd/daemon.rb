require 'thread'
require 'childprocess'
require 'pathname'

module Zeusd
  class DaemonException < StandardError; end

  class Daemon
    attr_reader :cwd, :verbose
    attr_reader :queue
    attr_reader :state
    attr_reader :child_process, :reader, :writer

    def initialize(options = {})
      @cwd     = Pathname.new(options.fetch(:cwd, Dir.pwd)).realpath
      @verbose = options.fetch(:verbose, false)
      @queue   = Queue.new
      @state   = StateInterpreter.new
      on_update(&method(:puts)) if verbose
    end

    def stop!
      processes = process ? Array([process.descendants, process]).flatten : []
      if processes.any?
        Zeusd::Process.kill!(processes.map(&:pid))
      end
      (socket_file.delete rescue nil) if socket_file.exist?
      if (alive_processes = processes).all?(&:alive?)
        raise DaemonException, "Unable to KILL processes: " + alive_processes.join(', ')
      else
        @process = nil
        true
      end
    end

    def start!(options = {})
      @process = Zeusd::Process.find(start_child_process!.pid)

      if options.fetch(:block, false)
        loop do
          if loaded?
            puts state.last_status
            break
          end
          sleep(0.1)
        end
      end

      process
    end

    def process
      @process ||= Process.all.find do |p|
        !!p.command[/zeus.*start$/] && p.cwd == cwd
      end
    end

    def loaded?
      process.descendants.all?(&:asleep?)
    end

    def on_update(&block)
      @on_update = block if block_given?
      @on_update
    end

    def socket_file
      cwd.join('.zeus.sock')
    end

    protected

    def start_child_process!
      @reader, @writer = IO.pipe
      @child_process = ChildProcess.build("zeus", "start")
      @child_process.environment["BUNDLE_GEMFILE"] = cwd.join("Gemfile").to_path
      @child_process.io.stdout = @child_process.io.stderr = @writer
      @child_process.cwd       = cwd.to_path
      @child_process.detach    = true
      @child_process.start
      @writer.close

      Thread.new do
        while (buffer = (reader.readpartial(10000) rescue nil)) do
          state << buffer
          queue << buffer
        end
      end

      if on_update.is_a?(Proc)
        Thread.new do
          while output = queue.pop
            on_update.call(output)
          end
        end
      end

      sleep(0.1) until state.commands.any?

      @child_process
    end

  end
end