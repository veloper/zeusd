module Zeusd
  module Log
    class Status

      def complete?
        return false if errors.any?
        return true if commands.all? {|command, status| %[crashed ready].include?(status)}
        false
      end

    end
  end
end