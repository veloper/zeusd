module Zeusd
  module Log
    class Observer
      include Hooks
      include Hooks::InstanceHooks

      define_hook :after_line

      attr_reader :log_file, :lines

      def initialize(log_file)
        @log_file = log_file
        @lines    = []
      end

      def watching?
        !!@watch_thread
      end

      def start_watching!
        @watch_thread ||= Thread.new do
          File.open(log_file.to_path) do |log|
            log.extend(File::Tail)
            log.interval = 0.1
            log.backward(100000)
            log.tail do |line|
              @lines << (line = Line.new(line))
              Thread.new { run_hook :after_line, line }
            end
          end
        end
      end

      def stop_watching!
        if @watch_thread
          @watch_thread.terminate
          @watch_thread = nil
          true
        else
          false
        end
      end

    end
  end
end