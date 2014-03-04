# encoding: utf-8

require 'zeusd/log/line/base'
require 'zeusd/log/line/command'
require 'zeusd/log/line/process'
require 'zeusd/log/line/update'
require 'zeusd/log/line/error'

module Zeusd
  module Log
    module Line

      class << self

        def create(line)
          [Command, Process, Update, Error, Base].find do |klass|
            klass.matches_line?(line) ? klass.new(line) : false
          end
        end

      end

    end
  end
end