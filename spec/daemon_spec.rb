require 'spec_helper'
require 'zeusd'

describe Zeusd::Daemon do
  subject(:daemon) { Zeusd::Daemon.new(:cwd => DUMMY_RAILS_APP_PATH, :debug => true) }

  describe "#start!" do
    it "returns a pid" do
      daemon.start!.should be_a Fixnum
      block_until_loaded
    end
  end

end