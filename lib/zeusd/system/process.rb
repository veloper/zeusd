require 'timeout'
module Zeusd
  module System
    class Process
      attr_accessor :user, :pid, :ppid, :pgid, :sess, :jobc, :stat, :tt, :time, :command
      attr_accessor :children

      def initialize(data)
        data.each {|key, value| self.send("#{key}=", value) if respond_to?(key) }
      end

      def self.find(pid)
        (record = System.process_records("ps -j -p #{pid}").first) ? self.new(record) : nil
      end

      def cwd
        @cwd ||= (path = `lsof -p #{pid}`.split("\n").find{|x| x[" cwd "]}.split.last.strip) ? Pathname.new(path).realpath : nil
      end

      def zeus_start?
        !!command[/zeus.*start$/]
      end

      def sleeping?
        (state || "")["S"]
      end

      def state
        `ps -o stat -p #{pid}`.split("\n")[1]
      end

      def alive?
        !!system("ps -p #{pid} > /dev/null")
      end

      def dead?
        !alive?
      end

      def kill!(signal = "INT")
        ::Process.kill(signal, pid.to_i)
      end

      def descendants(options = {})
        children(options).map {|cp| [cp].concat(Array(cp.descendants)) }.flatten.compact
      end

      def children(options = {})
        @children = Array(System.processes.find_all {|p| p.ppid == pid}.tap{|cp| cp.each(&:children)})
      end

    end
  end
end