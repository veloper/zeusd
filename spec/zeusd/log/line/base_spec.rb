# encoding: utf-8

require 'spec_helper'
require 'zeusd'


describe Zeusd::Log::Line::Base do

  class ExampleLine < Zeusd::Log::Line::Base

    def status_substring
      "example"
    end

  end

  RED    = "\e[31m"
  GREEN  = "\e[32m"
  YELLOW = "\e[33m"

  let(:line) { Zeusd::Log::Line::Base.new("#{RED}This line starts with red but then#{GREEN}changes to green after a bit") }

  describe ".color" do
    subject { line.color }
    it { should eq RED }
  end

  describe ".color_of" do
    context "far from color set" do
      subject { line.color_of("bit") }
      it { should eq GREEN }
    end

    context "close to color set" do
      subject { line.color_of("This") }
      it { should eq RED }
    end

    context "color itself" do
      subject { line.color_of(GREEN) }
      it { should eq GREEN }
    end

  end

  describe "checking status of substring" do
    Zeusd::Log::STATUS_TO_ANSI.each do |status, color|
      context "when in a #{status} state" do
        subject { ExampleLine.new "#{color}zeus example\e[K\e[0m" }
        it { should send("be_#{status}") }
      end
    end
  end

end
