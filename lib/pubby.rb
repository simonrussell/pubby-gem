module Pubby

  autoload :Stub, File.join(File.dirname(__FILE__), 'pubby/stub')
  autoload :Pubnub, File.join(File.dirname(__FILE__), 'pubby/pubnub')
  autoload :PubnubAsync, File.join(File.dirname(__FILE__), 'pubby/pubnub_async')
  autoload :SimpleAsync, File.join(File.dirname(__FILE__), 'pubby/simple_async')
  
  def self.from_config(config)
    type = config.fetch('type') { raise "type is required" }
    
    klass = case type
            when 'stub'
              Pubby::Stub
            when 'pubnub'
              Pubby::Pubnub
            when 'pubnub-async'
              Pubby::PubnubAsync
            else
              raise "unknown type #{type.inspect}"
            end
            
    result = klass.from_config(config)
    result = Pubby::SimpleAsync.new(result) if config['async']
    result
  end
  
  def self.logger
    @logger ||= begin
                  require 'logger'
                  l = Logger.new(STDERR)
                  l.progname = name
                  l.level = Logger::ERROR
                  l
                end
  end
  
  def self.logger=(logger)
    @logger = logger
  end

end
