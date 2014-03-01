require 'logger'
require 'json'

module Zeusd
  module DaemonLogging

    def log_file
      cwd.join('log', 'zeusd.log')
    end

    def track(occurred, method, details = nil)
      logger.info do
        "\e[35m[Track] [#{occurred.to_s.upcase}] .#{method}()\e[0m" + (details ? " " + JSON.pretty_generate(details) : "")
      end
    end

    def logger
      @logger ||= Logger.new(log_file.to_path).tap do |l|
        l.formatter = proc do |severity, datetime, progname, msg|
          "\e[36m[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}]\e[0m" + " #{msg}\n"
        end
      end
    end

    def self.included(base)
      tracked_methods = [:start!, :stop!, :restart!, :start_child_process!]
      base.instance_eval do
        tracked_methods.each do |method_name|
          original_method = instance_method(method_name)
          track           = instance_method(:track)

          define_method(method_name) do |*args, &block|
            track.bind(self).call(:before, method_name, :args => args)
            original_method.bind(self).call(*args, &block).tap do |x|
              track.bind(self).call(:after, method_name, :return => x)
            end
          end
        end
      end
    end


  end
end