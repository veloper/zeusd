require 'spec_helper'
require 'zeusd'

describe Zeusd::Daemon do
  subject(:daemon) { Zeusd::Daemon.new(:cwd => DUMMY_RAILS_APP_PATH) }

  describe ".start!" do
    it "returns a pid of the zeus stating process" do
      pid = daemon.start!
      expect(pid).to be_a Fixnum
    end
  end

end