# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Tailer do

  let(:log_file)    { Tempfile.new("Zeusd_Log_Tailer") }
  let(:tailer)      { Zeusd::Log::Tailer.new(log_file) }

  describe "after initialization" do
    subject { tailer }
    it { should_not be_following }
    it { should respond_to :start! }
    it { should respond_to :stop! }
    it { should respond_to :restart! }
    it { should respond_to :following? }
    it { should respond_to :lines }
    it { should respond_to :file }
  end

end
