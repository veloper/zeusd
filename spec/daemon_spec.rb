require 'spec_helper'

describe Zeusd::Daemon do
  let(:daemon) { Zeusd::Daemon.new(:cwd => DUMMY_APP_PATH) }
  after(:each) { daemon.stop! }
  describe ".start!" do

    context "blocking" do
      it "returns a Zeusd::System::Process instance" do
        process = daemon.start!(:block => true, :verbose => true)
        expect(process).to be_a Zeusd::System::Process
      end

      it "returns a zeus process" do
        process = daemon.start!(:block => true, :verbose => true)
        expect(process.zeus_start?).to be_true, "Process Command: " + process.command
      end
    end

    context "non-blocking" do
      it "returns a Zeusd::System::Process instance" do
        process = daemon.start!(:verbose => true)
        expect(process).to be_a Zeusd::System::Process
      end
    end

  end

end