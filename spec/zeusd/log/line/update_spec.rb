# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Line::Update do

  let(:update) { Zeusd::Log::Line::Update.new "==== UPDATED Sat Mar  1 00:07:24 EST 2014 =====" }

  describe ".time" do
    subject { update.time }
    it { should eq Time.parse("1/3/2014 00:07:24 EST") }
  end

end
