require 'thread'
module Zeusd
  class Daemon
    attr_accessor :opts
    attr_reader :pid, :process, :update_queue, :utility_queue

    def initialize(options = {})
      @opts = {
        :cwd     => options.fetch(:cwd, Dir.pwd),
        :pidfile => options.fetch(:pidfile, '.zeusd.pid'),
        :logfile => options.fetch(:logfile, 'log/zuesd.log'),
        :debug   => !!options.fetch(:debug, false)
      }
      @utility_queue = Queue.new
      @update_queue  = Queue.new
      on_update(&method(:puts)) if opts[:debug]
    end

    def process
      p = nil

      if pid.to_i > 0
        System::Process.find(pid).tap{|x| p = x if x}
      end

      if p.nil?
        System.processes.find{|x| x.zeus_start? && x.cwd == opts[:cwd]}.tap{|x| p = x if x}
      end

      p
    end

    def process?
      !process.nil?
    end

    def process?
      !process.nil?
    end

    def stop!
      process.kill_group! if process?
      socket_file.delete  if socket_file.exist?
    end

    def start!
      process_id = nil
      Thread.new do
        IO.popen("zeus start 2>&1 &") do |io|
          process_id = io.pid #not right, off by one
          while (buffer = (io.readpartial(4096) rescue nil)) do
            update_queue  << buffer
            utility_queue << buffer
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

      sleep 0.5 until process?

      pid
    end

    def loaded?
      process.descendants.all?(&:sleeping?)
    end

    def on_update(&block)
      @on_update = block if block_given?
      @on_update
    end

    def block_until_loaded
      while utility_queue.pop
        break if loaded?
      end
    end

    protected

    def under_cwd(&block)
      Dir.chdir(opts[:cwd], &block)
    end

    def socket_file
      Pathname.new('.zeus.sock')
    end

    def log_file
      opts[:logfile] ? Pathname.new(opts[:logfile]) : nil
    end


  end
end