require 'spec_helper'

describe Pubby::Pubnub do

  describe "#initialize" do
    
    let(:pubnub) { stub }
    subject { Pubby::Pubnub.new(pubnub) }
    
    its(:pubnub) { should == pubnub }
    
  end

  describe "#publish" do
    let(:pubnub) { stub }
    let(:channel_name) { 'bobby' }
    let(:message) { 'bob' }
    
    subject { Pubby::Pubnub.new(pubnub) }

    it "should send the message through to pubnub" do
      pubnub.should_receive(:publish).with('channel' => channel_name, 'message' => message)
      subject.publish(channel_name, message)
    end
  end
  
  describe "::from_config" do
    {
      {
        'publish_key' => 'abc',
        'subscribe_key' => 'def',
        'secret_key' => 'xyz',
        'ssl_on' => true
      } => 
        ['abc', 'def', 'xyz', true],
        
      {
        'publish_key' => 'abc',
      } => 
        ['abc', '', '', false]
    }.each do |config, (publish_key, subscribe_key, secret_key, ssl_on)|
  
      it "should create a pubnub object with the right settings from #{config.inspect}" do
        Pubnub.should_receive(:new).with(publish_key, subscribe_key, secret_key, ssl_on)
        Pubby::Pubnub.from_config(config)
      end
      
    end
    
    it "should require publish_key" do
      lambda { Pubby::Pubnub.from_config({}) }.should raise_error("publish_key is required")
    end
    
    describe "return value" do
      
      it "should be a Pubby::Pubsub" do
        Pubby::Pubnub.from_config({'publish_key' => 'demo'}).should be_a(Pubby::Pubnub)
      end
    
      it "should have the correct Pubnub" do
        pubnub = stub
        Pubnub.stub!(:new => pubnub)
        Pubby::Pubnub.from_config({'publish_key' => 'demo'}).pubnub.should == pubnub
      end

    end
  end

end
