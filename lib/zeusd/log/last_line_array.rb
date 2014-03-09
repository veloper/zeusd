require 'forwardable'
module Zeusd
  class LastLineArray
    extend Forwardable

    def_delegators *[:to_a].concat(Array.instance_methods.select{|x| x[/^[a-z]+.*?[^!]{1}$/]} - instance_methods(true))

    def initialize(*args)
      @hash = Hash[args.zip(args)]
    end

    def <<(line)
      @hash[line.id] = line
    end

    def to_a
      @hash.values
    end

  end
end