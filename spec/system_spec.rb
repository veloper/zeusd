require 'spec_helper'
require 'zeusd'

describe Zeusd::System do
  let(:sys) { Zeusd::System }

  describe "#process_records" do
    subject(:records) {sys.process_records("ps -j")}
    it { should be_an Array }

    it "contains only hashes" do
      records.all?{|x| x.is_a?(Hash) }.should be_true
    end

    it "properly interprets the `ps -j` command" do
      records.first.keys.should eq(%w[user pid ppid pgid sess jobc stat tt time command])
    end
  end

  describe "#processes" do
    it "returns an array of Zeusd::System::Process objects" do
      sys.processes.should        be_an(Array)
      sys.processes.should_not    be_empty
      sys.processes.first.should  be_a(Zeusd::System::Process)
    end

  end

end