require 'zeusd/system/process'

module Zeusd
  module System

    class << self

      def process_records(cmd)
        header, *rows = `#{cmd}`.split("\n")
        keys          = header.downcase.split
        glob_columns  = 0...(keys.length-1)
        cmd_columns   = (keys.length-1)..-1
        rows.map(&:split).map do |parts|
          Hash[keys.zip(parts[glob_columns] << parts[cmd_columns].join(" "))] # command will have spaces
        end
      end

      def processes(options = {})
        cmd = options.fetch(:command, "ps -j")
        process_records(cmd).map{|x| Process.new(x)}
      end

    end

  end
end