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

    def initialize(attributes = {})
      self.attributes = attributes
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

    # Note: Non-chinable, AND joined, Proc allowed for value
    # {"attr" => value}
    def self.where(criteria, options = {})
      all(options).select do |process|
        criteria.all? do |key, value|
          case value
          when Array then value.include?(process.send(key))
          when Proc  then !!value.call(process)
          else
            process.send(key) == value
          end
        end
      end
    end

    def self.find(pid)
      if attributes = ps(:pid => pid).first
        self.new(attributes)
      end
    end

    def self.kill!(pids, options = {})
      signal = options.fetch(:signal, "INT")
      pids   = Array(pids).map(&:to_i).select{|x| x > 0}
      if pids.any?
        system("kill -#{signal} #{pids.join(' ')}")
        $?.success?
      else
        false
      end
    end

    def reload!
      self.attributes = self.class.ps(:pid => pid).first || {}
      @children   = nil
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
      self.class.kill!(pid, options)
      reload!
    end

    def descendants(options = {})
      children(options).map do |child_process|
        [child_process].concat(Array(child_process.descendants))
      end.flatten.compact
    end

    def children(options = {})
      @children = self.class.where("ppid" => pid).tap do |processes|
        if options.fetch(:recursive, false)
          processes.each{|p| p.children(options)}
        end
      end
    end

    def attributes=(hash)
      @attributes = hash.reduce({}) do |seed, (key, value)|
        value = CASTINGS[key] ? CASTINGS[key].call(value) : value
        seed.merge(key => value)
      end
    end

  end
end