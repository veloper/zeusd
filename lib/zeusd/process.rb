module Zeusd
  class Process
    CASTINGS = {
      "pid"     => ->(x){x.to_i},
      "ppid"    => ->(x){x.to_i},
      "pgid"    => ->(x){x.to_i},
      "stat"    => ->(x){x.to_s},
      "command" => ->(x){x.to_s}
    }
    attr_accessor :attributes
    attr_accessor :children

    def initialize(attributes_or_pid)
      case attributes_or_pid
      when Hash
        self.attributes = attributes_or_pid
      else
        self.attributes = {"pid" => attributes_or_pid.to_i}
        reload!
      end
    end

    def self.ps(options = {})
      keywords = Array(options[:keywords]) | %w[pid ppid pgid stat command]
      command  = ["ps"].tap do |ps|
        ps << "-o #{keywords.join(',')}"
        ps << "-p #{options[:pid].to_i}" if options[:pid]
      end.join(" ")
      header, *rows = `#{command}`.split("\n")
      keys          = header.downcase.split
      glob_columns  = 0...(keys.length-1)
      cmd_columns   = (keys.length-1)..-1
      Array(rows.map(&:split)).map do |parts|
        Hash[keys.zip(parts[glob_columns] << parts[cmd_columns].join(" "))] # Attributes
      end
    end

    def self.all(options = {})
      ps(options).map do |attributes|
        self.new(attributes)
      end
    end

    def self.where(criteria, options = {})
      all(options).select do |process|
        criteria.all? do |key, value|
          process.send(key) == value
        end
      end
    end

    def self.find(pid)
      if attributes = ps(:pid => pid).first
        self.new(attributes)
      end
    end

    def self.wait(pids = [])
      pids = Array(pids).map(&:to_s)
      loop do
        break if (self.ps.map{|x| x["pid"]} & pids).length.zero?
        sleep(0.1)
      end
    end

    def self.kill!(pids, options = {})
      pids      = Array(pids).map(&:to_i).select{|x| x > 0}
      processes = pids.map{|pid| self.new(pid)}
      signal    = options.fetch(:signal, "TERM")
      wait      = options.fetch(:wait, false)
      return false if processes.any?(&:dead?)

      if system("kill -#{signal} #{processes.map(&:pid).join(' ')}")
        self.wait(pids) if wait
        true
      else
        false
      end
    end

    def reload!
      self.attributes = self.class.ps(:pid => pid).first || {}
      @children       = nil
      !attributes.empty?
    end

    def cwd
      @cwd ||= (path = `lsof -p #{pid}`.split("\n").find{|x| x[" cwd "]}.split.last.strip) ? Pathname.new(path).realpath : nil
    end

    def pid
      attributes["pid"]
    end

    def ppid
      attributes["ppid"]
    end

    def pgid
      attributes["pgid"]
    end

    def state
      reload!
      attributes["stat"]
    end

    def command
      attributes["command"]
    end

    def asleep?
      !!state.to_s["S"]
    end

    def alive?
      reload!
      !attributes.empty?
    end

    def dead?
      !alive?
    end

    def kill!(options = {})
      return false if dead?
      self.class.kill!(pid, options)
    end

    def descendants(options = {})
      children(options).map do |child_process|
        [child_process].concat(Array(child_process.descendants))
      end.flatten.compact
    end

    def children(options = {})
      @children = self.class.where("ppid" => pid)
    end

    def attributes=(hash)
      @attributes = hash.reduce({}) do |seed, (key, value)|
        value = CASTINGS[key] ? CASTINGS[key].call(value) : value
        seed.merge(key => value)
      end
    end

  end
end