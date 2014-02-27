module Zeusd
  class Interpreter
    STATES = %w[ready crashed running connecting waiting]

    attr_reader :lines
    attr_reader :state_colors, :commands, :errors
    attr_reader :last_status

    def initialize(*args)
      @state_colors = Hash[STATES.zip([nil]*STATES.length)]
      @commands     = {}
      @errors       = []
      @lines        = []
    end

    def translate(zeus_output)
      zeus_output.split("\n").map{|x| Line.new(x) }.each do |line|
        # State Colors
        if @state_colors.values.any?(&:nil?) && line.state_legend?
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

      # Garbage Collection
      if @lines.length > 100
        @lines = @lines.last(100)
      end
    end

    def complete?
      return false if errors.any?
      return true if commands.all? {|command, status| %[crashed ready].include?(status)}
      false
    end

    def last_update
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
        if @match ||= self.match(/^(\e.*?)zeus\s(.*?)(\s|\e)/)
          { :name => @match[2], :color => @match[1] }
        end
      end

      def state_legend?
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

    end

  end
end