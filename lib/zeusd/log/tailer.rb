module Zeusd
  module Log
    class Tailer
      attr_reader :file, :lines

      def initialize(file)
        @file  = file
        @lines = []
      end

      def on_update(&block)
        @on_update = block if block_given?
        @on_update
      end

      def following?
        !!@thread
      end

      def restart!
        stop!.start!
      end

      def start!
        @thread = Thread.new do
          File.open(file) do |log|
            log.extend(File::Tail)
            log.interval = 0.1
            log.backward(0)
            log.tail do |line|
              @lines << line
              on_update.call(line) if on_update
            end
          end
        end
        self
      end

      def stop!
        if @thread
          @thread.terminate
          @thread = nil
        end
        self
      end

    end
  end
end