# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Line::Command do

  NAME = "dbconsole"
  let(:crashed) { Zeusd::Log::Line::Command.new "\e[31mzeus #{NAME}\e[K\e[0m" }
  let(:ready)   { Zeusd::Log::Line::Command.new "\e[32mzeus #{NAME}\e[K\e[0m" }
  let(:waiting) { Zeusd::Log::Line::Command.new "\e[33mzeus #{NAME}\e[K\e[0m" }

  describe ".name" do
    subject { ready.name }
    it { should eq NAME }
  end

  describe "checking status of command" do
    context ".ready?" do
      subject { ready }
      it { should be_ready }
    end
    context ".waiting?" do
      subject { waiting }
      it { should be_waiting }
    end
    context ".crashed?" do
      subject { crashed }
      it { should be_crashed }
    end
  end

end
