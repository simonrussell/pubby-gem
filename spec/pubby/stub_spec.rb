require 'spec_helper'

describe Pubby::Stub do

  describe "#initialize" do
  
    context "zero arguments" do

      it "should create an empty queue" do
        Pubby::Stub.new.messages.should be_empty
      end
      
    end  
    
    context "one argument" do
      
      let(:messages) { { 'channel1' => %w(a b c), 'channel2' => %w(d e f) } }
      
      subject { Pubby::Stub.new(messages) }
      
      it "should copy the items into the queue" do
        subject.messages.should == messages
      end
      
    end
    
  end

  describe "::from_config" do
    
    it "should return a new stub" do
      Pubby::Stub.from_config({}).should be_a(Pubby::Stub)
    end
    
  end

  describe "#publish" do
  
    subject { Pubby::Stub.new }

    it "should work" do
      subject.publish("channel-name", "message")
      subject.messages['channel-name'].should == ['message']
    end
  
  end
  
  describe "#messages" do
  
    subject { Pubby::Stub.new }

    it "should return a hash" do
      subject.messages.should be_a(Hash)
    end
  
    it "should be empty to start with" do
      subject.messages.should be_empty
    end

    context "unpublished channel" do

      it "should be an array" do
        subject.messages['unknown'].should be_a(Array)
      end

      it "should be empty" do
        subject.messages['unknown'].should be_empty
      end
      
    end
    
    context "published channel with one message" do
    
      let(:channel_name) { "biff" }
      let(:message) { "says hello" }
    
      subject { Pubby::Stub.new(channel_name => [message]) }
    
      it "should be an array containing the message" do
        subject.messages[channel_name].should == [message]
      end
      
    end
    
  end
  
  describe "#channels" do
    context "no messages" do
      it "should be empty" do
        Pubby::Stub.new.channels.should == []
      end
    end
    
    context "with messages" do    
      let(:messages) { { 'channel1' => %w(a b c), 'channel2' => %w(d e f) } }
      subject { Pubby::Stub.new(messages) }
 
      it "should be the channels" do
        subject.channels.should =~ messages.keys
      end
    end
  end

  describe "#empty?" do
    context "no messages" do
      it "should be true" do
        Pubby::Stub.new.should be_empty
      end
    end
    
    context "with messages" do    
      let(:messages) { { 'channel1' => %w(a b c), 'channel2' => %w(d e f) } }
      subject { Pubby::Stub.new(messages) }
 
      it "should be false" do
        subject.should_not be_empty
      end
    end
  end

end
