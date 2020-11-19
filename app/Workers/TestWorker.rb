class TestWorker
    include Sidekiq::Worker
    sidekiq_options retry: false
  
    def perform(deviceTokens,payloadChunk)
      puts "SIDEKIQ WORKER TESTING NOTIFICATION CHUNKING"
      deviceTokens.each do |deviceToken|
        send_notification(deviceToken, JSON.generate(payloadChunk))
      end
    end
  
  end