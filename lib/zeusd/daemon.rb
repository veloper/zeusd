require 'thread'
module Zeusd
  class Daemon
    attr_reader :cwd, :logfile, :process, :update_queue, :loaded_queue

    def initialize(options = {})
      @cwd          = options.fetch(:cwd, Dir.pwd)
      @logfile      = options.fetch(:logfile, 'log/zuesd.log')
      @verbose      = options.fetch(:verbose, false)
      @loaded_queue = Queue.new
      @update_queue = Queue.new
      on_update(&method(:puts)) if @verbose
    end

    def process
      System.processes.find do |p|
        p.zeus_start? && p.cwd == cwd
      end
    end

    def process?
      !!process
    end

    def stop!
      process.kill_group! if process?
      socket_file.delete  if socket_file.exist?
    end

    def start!(options = {})
      Thread.new do
        IO.popen("zeus start 2>&1 &") do |io|
          while (buffer = (io.readpartial(4096) rescue nil)) do
            update_queue << buffer
            loaded_queue << buffer
          end
        end
      end

      if on_update.is_a?(Proc)
        Thread.new do
          while output = update_queue.pop
            on_update.call(output)
          end
        end
      end

      block_until_loaded unless options.fetch(:non_block, false)
    end

    def loaded?
      process.descendants.all?(&:sleeping?)
    end

    def on_update(&block)
      @on_update = block if block_given?
      @on_update
    end

    def block_until_loaded
      while loaded_queue.pop
        break if loaded?
      end
    end

    def socket_file
      Pathname.new('.zeus.sock')
    end

    def log_file
      @logfile ? Pathname.new(@logfile) : nil
    end

    def under_cwd(&block)
      Dir.chdir(@cwd, &block)
    end

  end
end