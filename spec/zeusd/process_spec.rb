require 'spec_helper'
require 'benchmark'
require 'zeusd'

describe Zeusd::Process do

  def spawn_dummy_process(ttl = 1, usr1delay = 0.5, options = {})
    ttl       = ttl.to_f.to_s
    usr1delay = usr1delay.to_f.to_s
    script    = File.expand_path("../../support/dummy_process.rb", __FILE__)
    p         = ChildProcess.build(script, ttl, usr1delay)
    p.cwd     = options[:cwd] if options[:cwd]
    p.detach  = true
    p.start
    p
  end

  before(:each) do
    @dummy_ttl       = 1
    @dummy_usr1delay = 0.5
    @dummy_process   = spawn_dummy_process(@dummy_ttl, @dummy_usr1delay)
  end
  subject(:model) { Zeusd::Process }


  describe "process instance" do
    subject { model.find(@dummy_process.pid) }
    it { should be_a Zeusd::Process }
    it { should be_alive }
    it { should_not be_dead }
  end

  describe "instance methods" do
    subject { model.find(@dummy_process.pid) }

    describe ".cwd" do
      it "return the current working directory" do
        subject.cwd.to_path == Dir.pwd
      end
    end

    describe ".kill!" do
      context "when process exists" do
        it "kills the process and returns true" do
          subject.kill!(:wait => true).should be_true
          subject.should be_dead
        end
      end

      context "when processes does not exists" do
        it "returns false" do
          subject.kill!(:wait => true).should be_true
          subject.kill!.should be_false
        end
      end
    end
  end


  describe "class methods" do

    describe "::kill!" do
      it "kills a process in under 0.1 seconds" do
        model.kill!(@dummy_process.pid)
        sleep 0.1
        model.find(@dummy_process.pid).should be_nil
      end

      it "blocks until the process exits" do
        Benchmark.realtime do
          model.kill!(@dummy_process.pid, :signal => "USR1", :wait => true).should be_true
        end.should be < 1.0
      end
    end

    describe "::wait" do
      it "blocks until the process exits" do
        Benchmark.realtime { model.wait(@dummy_process.pid) }.should be > 1
      end
    end

    describe "::ps" do
      subject { model.ps }
      it { should be_an Array }
      it "contains only Hash objects" do
        subject.all?{|x| x.is_a?(Hash)}.should be_true
      end
      it "includes the dummy process" do
        subject.map{|x|x["pid"]}.should include(@dummy_process.pid.to_s)
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
          subject {model.where(:pid => @dummy_process.pid, :pgid => 9999999999999)}
          it { should be_an Array }
          it { should be_empty }
        end
      end
    end

    describe "::find" do
      subject { model.find(@dummy_process.pid) }
      context "existing process" do
        it { should be_a Zeusd::Process }
        it { should be_alive }
        it { subject.pid.should eq(@dummy_process.pid) }
      end
      context "non-existant process" do
        before(:each) { @dummy_process.stop }
        it { should be_nil }
      end
    end
  end

end