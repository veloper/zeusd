# encoding: utf-8
module Zeusd
  module Log
    module Line

      class Error < Base

        def self.matches_line?(line)
          !!line["\e[31m"]
        end

        alias_method :message, :to_s

      end

    end
  end
end