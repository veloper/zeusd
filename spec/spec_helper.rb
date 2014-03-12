# encoding: utf-8
require 'coveralls'
Coveralls.wear!

require 'tempfile'

require File.expand_path('../support/helpers.rb', __FILE__)
require File.expand_path('../support/constants.rb', __FILE__)

require 'zeusd'

RSpec.configure do |c|
  c.include Helpers
end
