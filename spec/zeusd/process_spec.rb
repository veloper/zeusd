require 'spec_helper'
require 'zeusd'

describe Zeusd::Process do

  def spawn_dummy_process(ttl_seconds = 1)
    spawn("while [ $(date +\"%s\") -le #{Time.now.to_i + ttl_seconds} ]; do continue; done")
  end

  subject(:model) { Zeusd::Process }

  describe "process management class methods" do
    before(:each) { @dummy_pid = spawn_dummy_process }

    describe "::ps" do
      subject { model.ps }
      it { should be_an Array }
      it "contains only Hash objects" do
        subject.all?{|x| x.is_a?(Hash)}.should be_true
      end
      it "includes the dummy process" do
        subject.map{|x|x["pid"]}.should include(@dummy_pid.to_s)
      end
      it "allows additional -o keywords" do
        model.ps(:keywords => "user").first.should include("user")
      end
      describe "array element" do
        subject { model.ps.first }
        it { should be_a Hash }
        it "has required keys" do
          should include(*%w[pid ppid pgid stat command])
        end
        its "keys are all strings" do
          subject.keys.all?{|x| x.is_a?(String)}.should be_true
        end
        its "values are all strings" do
          subject.values.all?{|x| x.is_a?(String)}.should be_true
        end
      end
    end

    describe "::all" do
      subject { model.all }
      it { should be_an(Array) }
      it { should_not be_empty }
      it { subject.all?{|x| x.is_a?(Zeusd::Process)}.should be_true }
    end

    describe "::where" do
      describe "using multiple criteria" do
        subject {model.where(:pid => ::Process.pid, :pgid => ::Process.getpgrp)}
        it { should be_an Array }
        it { should have_exactly(1).items }
      end

      describe "results" do
        context "criteria met" do
          subject {model.where(:pgid => ::Process.getpgrp)}
          it { should be_an Array }
          it { should have_at_least(2).items }
        end
        context "criteria not met" do
          subject {model.where(:pid => @dummy_pid, :pgid => 9999999999999)}
          it { should be_an Array }
          it { should be_empty }
        end
      end
    end

    describe "::find" do
      subject { model.find(@dummy_pid) }
      context "existing process" do
        it { should be_a Zeusd::Process }
        it { should be_alive }
        it { subject.pid.should eq(@dummy_pid) }
      end
      context "non-existant process" do
        before(:each) { ::Process.kill("KILL", @dummy_pid); ::Process.waitpid(@dummy_pid) }
        it { should be_nil }
      end
    end
  end

end