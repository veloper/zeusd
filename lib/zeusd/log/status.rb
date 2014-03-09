module Zeusd
  module Log

    class Status

      attr_reader :file, :tailer, :updated_at, :line_print_count
      attr_reader :errors
      attr_reader :commands
      attr_reader :processes

      def initialize(file)
        @line_print_count = 0
        @file             = File.new(file)
        @updated_at       = Time.now
        @errors           = LastLineArray.new
        @commands         = LastLineArray.new
        @processes        = LastLineArray.new
        @tailer           = Tailer.new(file)

        file.each {|line| process(line)} unless file.size.zero?
      end

      def record!
        tailer.on_update {|line| process(line)}
        tailer.start!
        self
      end

      def pause!
        tailer.stop!
        self
      end

      def paused?
        !tailer.following?
      end

      def recording?
        tailer.following?
      end

      def process(line)
        line = Line.create(line)
        case line
        when Line::Command then @commands << line
        when Line::Process then @processes << line
        when Line::Error   then @errors << line
        end
        @updated_at = Time.now
        on_update.call(self, line) if on_update
      end

      def on_update(&block)
        @on_update = block if block_given?
        @on_update
      end

      def started?
        commands.any?
      end

      def finished?
        return true if errors.any?
        return true if [commands, processes].map(&:to_a).flatten.all?(&:done?)
        false
      end

      def empty?
        [errors, commands, processes].all?(&:empty?)
      end

      def to_cli
        output = [
          "\e[36mZeusd Status\e[0m - Updated: #{updated_at.to_s}\e[K\e[0m\n",
          "\e[K\e[0m\n",
          "Legend: \e[32m[ready] \e[31m[crashed] \e[34m[running] \e[35m[connecting] \e[33m[waiting]\e[K\e[0m\n",
          "\e[K\e[0m\n",
          "\e[4mProcess Tree\e[K\e[0m\n",
          [processes.map(&:to_s)],
          "\e[K\e[0m\n",
          "\e[4mCommands\e[K\e[0m\n",
          [commands.map(&:to_s)],
        ].tap do |x|
          if errors.any?
            x << "\e[K"
            x << "\e[4mErrors\e[K\e[0m\n"
            x << errors.map(&:to_s)
          end
        end.flatten
        if line_print_count > 0
          output = output.unshift("\e[#{line_print_count}A\e[K\e[0m\n")
        end
        @line_print_count = output.length
        output
      end

    end
  end
end