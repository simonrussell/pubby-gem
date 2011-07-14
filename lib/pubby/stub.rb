class Pubby::Stub

  def initialize(initial_messages = {})
    @messages = Hash.new { |h, k| h[k] = [] }
    
    initial_messages.each do |channel, messages|
      messages.each do |message|
        publish(channel, message)
      end
    end
  end

  def publish(channel_name, message)
    @messages[channel_name] << message
  end
  
  def messages
    @messages
  end

  def channels
    @messages.keys
  end
  
  def empty?
    @messages.empty? || @messages.all? { |k, v| v.empty? }
  end
  
  def self.from_config(config)
    new
  end

end
