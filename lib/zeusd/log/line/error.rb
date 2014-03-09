# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Error < Base

        def self.matches_line?(line)
          !!line[0..5]["\e[31m"]
        end

        def id
          message
        end

        alias_method :message, :to_s

      end

    end
  end
end