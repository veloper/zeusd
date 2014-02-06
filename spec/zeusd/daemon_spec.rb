require 'spec_helper'

describe Zeusd::Daemon do
  let(:daemon) { Zeusd::Daemon.new(:cwd => DUMMY_APP_PATH) }
  after(:each) { daemon.stop! }
  describe ".start!" do

    context "blocking" do
      subject { daemon.start!(:block => true) }
      it { should be_a Zeusd::Process }

      it "should be a zeus start process" do
        process = daemon.start!(:block => true)
        process.command[/zeus.*?start$/].should_not be_nil, "Process Command: " + process.command
      end
    end

    context "non-blocking" do
      subject { daemon.start! }
      it { should be_a Zeusd::Process }
    end

  end

end