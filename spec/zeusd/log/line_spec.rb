# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Line do

  describe "determining line type" do

    context "update" do
      subject { Zeusd::Log::Line.create("==== UPDATED Sat Mar  1 00:07:24 EST 2014 =====") }
      it { should be_a Zeusd::Log::Line::Update }
    end

    context "error" do
      subject { Zeusd::Log::Line.create("\e[31mThis would be a typical zeus error") }
      it { should be_a Zeusd::Log::Line::Error }
    end

    context "process" do
      subject { Zeusd::Log::Line.create("\e[33m    \e[33m└── \e[33mtest_environment\e[K\e[0m") }
      it { should be_a Zeusd::Log::Line::Process }
    end

    context "command" do
      subject { Zeusd::Log::Line.create("\e[33mzeus generate (alias: g)\e[K\e[0m") }
      it { should be_a Zeusd::Log::Line::Command }
    end

    context "unknown" do
      subject { Zeusd::Log::Line.create("!#!@$$@#%$#%%!$43154}") }
      it { should be_a Zeusd::Log::Line::Base }
    end

  end

end
