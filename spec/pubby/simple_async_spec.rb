require 'spec_helper'

describe Pubby::SimpleAsync do

  after { subject.kill! if subject.is_a?(Pubby::SimpleAsync) }

  describe "#initialize" do
  
    let(:pubby) { stub }
    subject { Pubby::SimpleAsync.new(pubby, 1) }
  
    its(:pubby) { should == pubby }
    its(:thread_count) { should == 1 }
  
  end
  
  describe "#publish" do
  
    let(:pubby) { stub }
    subject { Pubby::SimpleAsync.new(pubby, 1) }
  
    it "should call publish on the pubby eventually" do
      pubby.should_receive(:publish).with('channel', 'message')
      subject.publish('channel', 'message')
      
      20.times do
        break if subject.queue.empty?
        sleep 0.05
      end
    end
  
  end
  
  describe "#shutdown" do
  
    let(:pubby) { stub(:publish => true) }
    subject { Pubby::SimpleAsync.new(pubby, 10) }
  
    before do
      1000.times do |i|
        subject.publish('channel', i.to_s)
      end
    end
    
    it "should have an empty queue" do
      subject.queue.should_not be_empty
      subject.shutdown!
      subject.queue.should be_empty
    end
  
    it "should call pubby the correct number of times" do
      pubby.should_receive(:publish).exactly(1000).times
      subject.shutdown!
    end

    it "should kill all the threads" do
      subject.shutdown!
      subject.threads.each { |t| t.should_not be_alive }
    end

  end
  
end
