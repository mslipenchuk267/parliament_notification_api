class TestNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: false
  
    def perform(deviceTokens,payloadChunk)
      puts "SIDEKIQ WORKER TESTING SENDING NOTIFICATIONS"
      sleep 5
      deviceTokens.each do |deviceToken|
        test_notif_workers(deviceToken, JSON.generate(payloadChunk))
      end
    end

    def test_notif_workers(device_token,payloadChunk)
        if device_token.length < 4
            test_send_apns_notification(device_token, payloadChunk)
        else 
            test_send_fcm_notification(device_token, payloadChunk)
        end
    end

    def test_send_apns_notification(device_token,payloadChunk)
        puts "\n \033[36m Worker identification number #{self.jid} Sent apns notification to #{device_token} with #{payloadChunk}\n"
    end

    def test_send_fcm_notification(device_token,payloadChunk)
        puts "\n \033[32m Worker identification number #{self.jid} Sent android notification to #{device_token} with #{payloadChunk}\n"
    end

end