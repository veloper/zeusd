# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Line::Process do

  let(:crashed)    { Zeusd::Log::Line::Process.new "\e[31mboot\e[K\e[0m" }
  let(:ready)      { Zeusd::Log::Line::Process.new "\e[32m└── \e[32mdefault_bundle\e[K\e[0m" }
  let(:waiting)    { Zeusd::Log::Line::Process.new "\e[33m    \e[33m├── \e[33mdevelopment_environment\e[K\e[0m" }
  let(:running)    { Zeusd::Log::Line::Process.new "\e[34m    \e[34m└── \e[34mtest_environment\e[K\e[0m" }
  let(:connecting) { Zeusd::Log::Line::Process.new "\e[35m    \e[35m    \e[35m└── \e[35mtest_helper\e[K\e[0m" }

  describe ".name" do
    context "when deeply nested" do
      subject { waiting.name }
      it { should eq "development_environment" }
    end
    context "when boot" do
      subject { crashed.name }
      it { should eq "boot" }
    end
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
    context ".running?" do
      subject { running }
      it { should be_running }
    end
    context ".connecting?" do
      subject { connecting }
      it { should be_connecting }
    end
  end

end
