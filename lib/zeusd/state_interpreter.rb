require 'stringio'
module Zeusd
  class StateInterpreter
    STATES = %w[ready crashed running connecting waiting]

    attr_reader :lines
    attr_reader :state_colors, :commands, :errors

    def initialize(*args)
      @state_colors = Hash[STATES.zip([nil]*STATES.length)]
      @commands     = {}
      @errors       = []
      @lines        = []
      super(*args)
    end

    def <<(input)
      input.split("\n").map{|x| Line.new(x) }.each do |line|
        # State Colors
        if @state_colors.values.any?(&:nil?) && line.legend?
          STATES.each do |state|
            state_colors[state] = line.color_of(state)
          end
        end

        # Errors
        @errors << line if line.color == state_colors["crashed"]

        # Commands
        @commands[line.command[:name]] = state_colors.invert[line.command[:color]] if line.command?

        # Add Line
        @lines << line
      end
    end

    def is_complete?
      return false if errors.any?
      return true if commands.all? {|command, status| %[crashed running].include?(status)}
      false
    end

    def last_status
      @lines[@lines.rindex(&:update?)..-1].join("\n").to_s
    end

    class Line < String

      def update?
        self =~ /\=\=\=\=$/
      end

      def command?
        !!command
      end

      def command
        if match = self.match(/^(\e.*?)zeus\s(.*?)(\s|\e)/)
          { :name => match[2], :color => match[1] }
        end
      end

      def legend?
        STATES.all?{|state| !!self[state]}
      end

      def color_of(substring)
        if stop_point = index(substring) + substring.length
          if color_start = rindex(/\e/, stop_point)
            color_end = index('m', color_start)
            self[color_start..color_end]
          end
        end
      end

      def color
        if self[0] == "\e" && !self.index('m').nil?
          self[0..self.index('m')]
        end
      end

      def color?
        !!color
      end

    end

  end
end