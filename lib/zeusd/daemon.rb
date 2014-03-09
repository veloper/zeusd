module Zeusd
  class Daemon
    attr_reader :cwd, :verbose, :child_process, :status

    def initialize(options = {})
      @cwd     = Pathname.new(options[:cwd] || Dir.pwd).realpath
      @verbose = !!options[:verbose]
    end

    def start!(options = {})
      start_child_process!

      @process = Zeusd::Process.find(child_process.pid)

      if options.fetch(:block, false)
        sleep(3) until status.finished?
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
      (zeus_socket.delete rescue nil) if zeus_socket.exist?

      @process = nil

      self
    end

    def status_queue
      queue  = Queue.new
      status = Log::Status.new(File.new(zeus_log.to_path, 'r'))

      queue << status.to_cli
      status.on_update {|x| queue << x.to_cli }
      status.record!

      queue
    end

    def process
      @process ||= Process.all.find {|p| !!p.command[/zeus.*start$/] && p.cwd == cwd }
    end

    def finished?
      status.finished?
    end

    def zeus_socket
      cwd.join('.zeus.sock')
    end

    def zeus_log
      cwd.join('log', 'zeus.log').tap do |path|
        FileUtils.touch(path.to_path)
      end
    end

    def verbose?
      !!verbose
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
      zeus_log.open("w") {}
      std_file = File.new(zeus_log.to_path, 'w+')
      std_file.sync = true

      # Prep and Start child process
      @child_process = ChildProcess.build("zeus", "start")
      @child_process.environment["BUNDLE_GEMFILE"] = cwd.join("Gemfile").to_path
      @child_process.io.stderr = std_file
      @child_process.io.stdout = std_file
      @child_process.cwd       = cwd.to_path
      @child_process.detach    = true
      @child_process.start

      @status = Log::Status.new(std_file)
      @status.on_update do |status, line|
        puts status.to_cli if verbose?
      end
      @status.record!

      sleep 0.1 until @status.started?

      @child_process
    end

    include Zeusd::DaemonTracker
  end
end