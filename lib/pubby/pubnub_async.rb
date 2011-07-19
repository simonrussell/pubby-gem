require 'eventmachine'
require 'em-http-request'
require 'json'

class Pubby::PubnubAsync
  
  class << self
    attr_accessor :requests
  end

  def initialize(publish_key, subscribe_key, secret_key = '', ssl_on = false)
    @base_url = "http#{'s' if ssl_on}://pubsub.pubnub.com"
  
    @publish_key = publish_key
    @publish_key_escaped = EscapeUtils.escape_url(@publish_key)
    
    @subscribe_key = subscribe_key
    @subscribe_key_escaped = EscapeUtils.escape_url(@subscribe_key)
    
    @secret_key = secret_key
    @ssl_on = ssl_on
  end

  def publish(channel_name, message)
    if EM.reactor_thread?
      publish_in_reactor(channel_name, message)
    else
      EM.next_tick { publish_in_reactor(channel_name, message) }
    end
    
    true
  end

  def self.from_config(config)
    new(
      config.fetch('publish_key') { raise "publish_key is required" },
      config.fetch('subscribe_key') { raise "subscribe_key is required" },
      config.fetch('secret_key', ''),
      config.fetch('ssl_on', false)
    )
  end
  
  def self.start_em_reactor!
    return if EM.reactor_running?
    Thread.new { EM.run }
    EM.next_tick { @requests = [] }
    Thread.pass
    sleep 0.05 until EM.reactor_running?
  end
  
  def self.stop_em_reactor!
    return unless EM.reactor_running?
    thread = EM.reactor_thread
    EM.add_periodic_timer(0.05) { EM.stop_event_loop if @requests.empty? }
    thread.join
  end
  
  def build_url(channel_name, message)
    channel_escaped = EscapeUtils.escape_url(channel_name).gsub('+', '%20')
    message_escaped = EscapeUtils.escape_url(message.to_json).gsub('+', '%20')
    
    "#{@base_url}/publish/#{@publish_key_escaped}/#{@subscribe_key_escaped}/0/#{channel_escaped}/0/#{message_escaped}"
  end
  
  private
  
  def publish_in_reactor(channel_name, message)
    url = build_url(channel_name, message)
    
    request = EM::HttpRequest.new(url).get
    self.class.requests << request

    request.callback do
      self.class.requests.delete(request)
    end

    request.errback do
      self.class.requests.delete(request)
    end
  end

end
