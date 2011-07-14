class Pubby::SimpleAsync

  attr_reader :pubby
  attr_reader :thread_count
  attr_reader :queue
  attr_reader :threads
  
  # you probably want the pubby used here to be threadsafe if there's more than one thread...
  def initialize(pubby, thread_count = 1)
    @pubby = pubby
    @thread_count = thread_count
    @queue = Queue.new
    @threads = []
    
    start_threads!
  end
  
  def publish(channel, message)
    @queue << [channel, message]
  end
  
  def shutdown!
    until @queue.empty?
      sleep 0.05
    end
    
    kill!
  end
  
  def kill!
    @threads.each { |t| t.kill; t.join }
  end
    
  private
  
  def start_threads!
    @thread_count.times do
      @threads << Thread.new do
        Thread.abort_on_exception = false
        process_messages!
      end
    end
  end

  def process_messages!
    until @shutdown
      args = @queue.pop
      @pubby.publish(*args)
    end
  end

end
