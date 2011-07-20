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
    
    Pubby.logger.info "#{self.class.name} created for publish key: #{@publish_key.inspect}, subscribe key: #{@subscribe_key.inspect}, secret key: #{@secret_key.inspect}, base_url: #{@base_url}"
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
    if EM.reactor_running?
      Pubby.logger.warn "Not starting EM reactor, already running."
      return
    end
    
    Pubby.logger.debug "Attempting start of EM reactor."

    Thread.new { EM.run }
    EM.next_tick { @requests = [] }
    Thread.pass
    sleep 0.05 until EM.reactor_running?

    Pubby.logger.info "Started EM reactor."
  end
  
  def self.stop_em_reactor!
    unless EM.reactor_running?
      Pubby.logger.warn "Not stopping EM reactor, not running."
      return
    end
    
    Pubby.logger.debug "Attempting stop of EM reactor."

    thread = EM.reactor_thread
    EM.add_periodic_timer(0.05) { EM.stop_event_loop if @requests.empty? }
    
    Pubby.logger.debug "Waiting for requests to complete."
    thread.join
    
    Pubby.logger.info "Stopped EM reactor."    
  end
  
  def build_url(channel_name, message)
    channel_escaped = EscapeUtils.escape_url(channel_name).gsub('+', '%20')
    message_escaped = EscapeUtils.escape_url(message.to_json).gsub('+', '%20')
    
    "#{@base_url}/publish/#{@publish_key_escaped}/#{@subscribe_key_escaped}/0/#{channel_escaped}/0/#{message_escaped}"
  end
  
  private
  
  def publish_in_reactor(channel_name, message)
    url = build_url(channel_name, message)
    
    Pubby.logger.debug "Message attempt: #{channel_name.inspect} <- #{message.inspect}"
    request = EM::HttpRequest.new(url).get
    self.class.requests << request

    request.callback do
      self.class.requests.delete(request)
      
      success, error_message = parse_response(request.response)
      
      if success
        Pubby.logger.debug "Message SUCCESS: #{channel_name.inspect} <- #{message.inspect}"
      else
        Pubby.logger.error "Message FAILURE: #{channel_name.inspect} <- #{message.inspect}: #{error_message}"
      end      
    end

    request.errback do
      self.class.requests.delete(request)
      Pubby.logger.error "Message FAILURE: #{channel_name.inspect} <- #{message.inspect}: #{request.error.inspect}"
    end
  end
  
  def parse_response(response)
    parsed = JSON.parse(response)
    
    if parsed.first == 1
      true
    else
      [false, parsed.last]
    end
  rescue JSON::ParserError
    [false, "Invalid JSON: #{response}"]
  end

end
