module Zeusd
  module System
    class Process
      attr_accessor :user, :pid, :ppid, :pgid, :sess, :jobc, :stat, :tt, :time, :command
      attr_accessor :children

      def initialize(data)
        data.each {|key, value| self.send("#{key}=", value) if respond_to?(key) }
      end

      def self.find(pid)
        (record = System.process_records("ps -jp #{pid}").first) ? self.new(record) : nil
      end

      def cwd
        @cwd ||= `lsof -p #{pid}`.split("\n").find{|x| x[" cwd "]}.split.last.strip
      end

      def zeus_start?
        !!command[/zeus.*start$/]
      end

      def sleeping?
        !!stat["S"]
      end

      def kill!(signal = "INT")
        ::Process.kill(signal, pid.to_i)
      end

      def kill_group!(signal = "INT")
        ::Process.kill(signal, -pgid.to_i)
      end

      def descendants(options = {})
        children(options).map {|child| [child].concat(Array(child.descendants)) }.flatten.compact
      end

      def children(options = {})
        @children = Array(System.processes.find_all {|x| x.ppid == pid}.tap{|c| c.each(&:children)})
      end

    end
  end
end