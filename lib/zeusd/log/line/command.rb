# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Command < Base
        def self.matches_line?(line)
          line[/^\e.*?zeus\s(.*?)(\s|\e)/]
        end

        def name
          self[/^\e.*?zeus\s(.*?)(\s|\e)/, 1]
        end

        def status_substring
          name
        end
      end

    end
  end
end