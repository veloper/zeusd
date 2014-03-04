# encoding: utf-8

require 'spec_helper'
require 'zeusd'

describe Zeusd::Log::Line::Error do

  ERROR_STRING = "\e[31This would be a typical \e[33mZeus\e[31 error to see.\e[0m"

  let(:error) { Zeusd::Log::Line::Error.new ERROR_STRING }
  describe ".message" do
    subject { error.message }
    it { should eq ERROR_STRING }
  end

end
