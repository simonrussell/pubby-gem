module Pubby

  autoload :Stub, File.join(File.dirname(__FILE__), 'pubby/stub')
  autoload :Pubnub, File.join(File.dirname(__FILE__), 'pubby/pubnub')
  autoload :SimpleAsync, File.join(File.dirname(__FILE__), 'pubby/simple_async')

  def self.from_config(config)
    type = config.fetch('type') { raise "type is required" }
    
    klass = case type
            when 'stub'
              Pubby::Stub
            when 'pubnub'
              Pubby::Pubnub
            else
              raise "unknown type #{type.inspect}"
            end
            
    klass.from_config(config)
  end

end
