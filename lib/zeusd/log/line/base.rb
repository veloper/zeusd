# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Base < String

        def self.matches_line?(line)
          true
        end

        def status_substring
          color
        end

        def status?(status)
          color_of(status_substring) == STATUS_TO_ANSI[status]
        end

        def ready?
          status? :ready
        end

        def crashed?
          status? :crashed
        end

        def waiting?
          status? :waiting
        end

        def running?
          status? :running
        end

        def connecting?
          status? :connecting
        end

        def color_of(substring)
          if stop_point = index(substring) + (substring.length - 1)
            if color_start = rindex(/\e/, stop_point)
              color_end = index('m', color_start)
              self[color_start..color_end]
            end
          end
        end

        def color
          if self[0] == "\e" && !self.index('m').nil?
            self[0..self.index('m')]
          end
        end

      end


    end
  end
end