require 'spec_helper'

describe Pubby do

  describe "::from_config" do
  
    it "should raise an error if type is missing" do
      lambda { Pubby.from_config({}) }.should raise_error("type is required")
    end
  
    it "should raise an error if type is garbage" do
      lambda { Pubby.from_config({'type' => 'fish'}) }.should raise_error("unknown type #{"fish".inspect}")
    end

    [true, false, nil].each do |async_setting|
      {
        'stub' => Pubby::Stub,
        'pubnub' => Pubby::Pubnub
      }.each do |type, klass|
        it "should call from_config on #{klass} when type is #{type.inspect} when async #{async_setting.inspect}" do
          config = { 'type' => type }
          config['async'] = async_setting unless async_setting.nil?
          
          pubby = stub
          klass.should_receive(:from_config).with(config).and_return(pubby)
          
          result = Pubby.from_config(config)
          
          if async_setting
            result.should be_a(Pubby::SimpleAsync)
            result.pubby.should == pubby
            result.shutdown!
          else
            result.should == pubby
          end
        end
      end
    end
        
  end
  
  describe "::logger" do
  
    before { @old_logger = Pubby.logger }
    after { Pubby.logger = @old_logger }
      
    its(:logger) { should_not be_nil }
    its(:logger) { should respond_to(:warn) }    
  
    it "should never be nil" do
      Pubby.logger = nil
      Pubby.logger.should_not be_nil
    end
    
    it "should be settable" do
      new_logger = stub
      Pubby.logger = new_logger
      Pubby.logger.should == new_logger
    end
  
  end

end
