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


  describe ".ansi_color" do
    subject { line.ansi_color }
    it { should eq RED }
  end


  describe ".ansi_color_of" do
    context "far from setting of color" do
      subject { line.ansi_color_of("bit") }
      it { should eq GREEN }
    end

    context "near setting of color" do
      subject { line.ansi_color_of("This") }
      it { should eq RED }
    end

    context "color itself" do
      subject { line.ansi_color_of(GREEN) }
      it { should eq GREEN }
    end
  end

  describe ".status_substring" do
    subject { line }
    it { should be_crashed }
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
