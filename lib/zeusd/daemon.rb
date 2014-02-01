require 'thread'
require 'childprocess'
require 'pathname'

module Zeusd
  class Daemon
    attr_reader :cwd, :verbose, :update_queue, :activity_queue

    def initialize(options = {})
      @cwd            = Pathname.new(options.fetch(:cwd, Dir.pwd)).realpath
      @verbose        = options.fetch(:verbose, false)
      @update_queue   = Queue.new
      @activity_queue = Queue.new
      on_update(&method(:puts)) if verbose
    end


    def stop!
      process.kill_group! if process
      socket_file.delete if socket_file.exist?
    end

    def start!(options = {})
      reader, writer = IO.pipe

      p = ChildProcess.build("zeus", "start")
      p.environment["BUNDLE_GEMFILE"] = cwd.join("Gemfile").to_path
      p.io.stdout = p.io.stderr = writer
      p.cwd = cwd.to_path
      p.start

      writer.close

      Thread.new do
        while (buffer = (reader.readpartial(4024) rescue nil)) do
          update_queue   << buffer
          activity_queue << buffer
        end
      end

      if on_update.is_a?(Proc)
        Thread.new do
          while output = update_queue.pop
            on_update.call(output)
          end
        end
      end

      unless options.fetch(:block, false)
        break if loaded? while activity_queue.pop
      end

      p.pid
    end

    def process
      System.processes.find do |p|
        p.zeus_start? && p.cwd.to_path == cwd.to_path
      end
    end

    def loaded?
      process.descendants.all?(&:sleeping?)
    end

    def on_update(&block)
      @on_update = block if block_given?
      @on_update
    end

    def socket_file
      cwd.join('.zeus.sock')
    end

  end
end