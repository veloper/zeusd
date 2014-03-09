require 'spec_helper'

describe Zeusd::Daemon do
  let(:daemon) { Zeusd::Daemon.new(:cwd => DUMMY_APP_PATH) }
  after(:each) { daemon.stop! }

  describe ".start!" do
    subject { daemon.start! }
    it { should be daemon }
    it { should_not be_finished }

    describe ":block option" do
      subject { daemon.start!(:block => true) }
      it { should be_finished }
    end
  end

  describe ".stop!" do
    subject { daemon.start!.stop! }
    it { should be daemon }
    it { should_not be_finished }
  end

  describe ".restart!" do
    subject { daemon }
    context "when daemon is already running" do
      before { subject.start!.restart!(:block => true) }
      it { should be_finished }
    end
  end

  describe ".process" do
    context "before start" do
      subject { daemon.process }
      it { should be_nil }
    end

    context "after start" do
      subject { daemon.start!.process }
      it { should be_a Zeusd::Process}
      it { should be_alive }
      its "a zeus start process" do
        subject.command.should match(/zeus.*?start$/)
      end
    end

    context "after start and stop" do
      subject { daemon.start!.stop!.process }
      it { should be_nil }
    end
  end

end