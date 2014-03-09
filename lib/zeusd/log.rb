require 'zeusd/log/last_line_array'
require 'zeusd/log/line'
require 'zeusd/log/status'
require 'zeusd/log/tailer'

module Zeusd
  module Log

    COLOR_TO_ANSI = {
      :red     => "\e[31m",
      :green   => "\e[32m",
      :yellow  => "\e[33m",
      :blue    => "\e[34m",
      :magenta => "\e[35m"
    }

    STATUS_TO_COLOR = {
      :ready      => :green,
      :crashed    => :red,
      :waiting    => :yellow,
      :running    => :blue,
      :connecting => :magenta
    }

    STATUS_TO_ANSI = Hash[STATUS_TO_COLOR.map{|status, color| [status, COLOR_TO_ANSI[color]]}]

  end
end