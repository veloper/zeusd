# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Status do

  let(:log_file) { Tempfile.new("Zeusd_Log_Status").tap {|f| f.sync = true} }
  let(:status) { Zeusd::Log::Status.new(log_file) }

  describe "after initialization" do
    subject { status }
    it { should be_paused }
    its(:tailer) { should be_a Zeusd::Log::Tailer }
    its(:errors) { should be_empty }

    context "when the log file is empty" do
      its(:commands)  { should be_empty }
      its(:processes) { should be_empty }
    end

    context "when log file has data" do
      before(:each) { file_write(log_file, ZEUS_LOG_LINES[:all].join, :rewind => true) }
      its(:commands)  { should_not be_empty }
      its(:processes) { should_not be_empty }
    end
  end

  describe ".process" do
    subject do
      lines.each {|line| status.process(line)}
      status
    end

    context "command" do
      let(:lines) { ZEUS_LOG_LINES[:commands] }
      its(:commands) { should have(lines.length).items }
    end

    context "process" do
      let(:lines) { ZEUS_LOG_LINES[:processes] }
      its(:processes) { have(lines.length).items }
    end
  end

  describe "recording" do
    subject { status.record! }
    it { should be status }
    it { should be_recording }
  end

end
