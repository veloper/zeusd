# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Update < Base

        def self.matches_line?(line)
          !!line[/\s=====$/]
        end

        def time
          Time.parse(self[/UPDATED\s(.*?)\s=/, 1])
        end
      end

    end
  end
end