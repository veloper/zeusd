#!/usr/bin/env ruby

Signal.trap('USR1') do
  sleep (ARGV[1] || 1).to_f
  exit 0
end

stop_time = Time.now.to_f + (ARGV[0] || 2).to_f

sleep 0.01 until Time.now.to_i.to_f >= stop_time
