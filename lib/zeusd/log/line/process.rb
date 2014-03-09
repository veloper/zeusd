# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Process < Base
        def self.matches_line?(line)
          !!line[/(boot|─)/]
        end

        def id
          name
        end

        def name
          self[/(\e\[[0-9]{1,2}m)([a-z_]+)/, 2]
        end

        def status_substring
          name
        end
      end

    end
  end
end