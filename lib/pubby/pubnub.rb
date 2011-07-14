require 'pubnub-ruby'

class Pubby::Pubnub

  attr_reader :pubnub

  def initialize(pubnub)
    @pubnub = pubnub
  end

  def publish(channel_name, message)
    @pubnub.publish('channel' => channel_name, 'message' => message)
    true
  end

  def self.from_config(config)
    new(
      Pubnub.new(
        config.fetch('publish_key') { raise "publish_key is required" },
        config.fetch('subscribe_key') { raise "subscribe_key is required" },
        config.fetch('secret_key', ''),
        config.fetch('ssl_on', false)
      )
    )
  end

end
