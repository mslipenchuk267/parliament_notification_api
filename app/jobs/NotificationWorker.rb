class NotificationWorker
    include Sidekiq::Worker
    sidekiq_options :queue => :notification_queue, retry: false
  
    def perform(deviceTokens,payloadChunk)
      puts "SIDEKIQ WORKER SENDING NOTIFICATIONS"
      deviceTokens.each do |deviceToken|
        send_notification(deviceToken, JSON.generate(payloadChunk))
      end
    end

    def send_notification(device_token, payloadChunk)
        if device_token.length < 162
            send_apns_notification(device_token, payloadChunk)
        else 
            send_fcm_notification(device_token, payloadChunk)
        end
    end

    def send_apns_notification(device_token, payloadChunk)
        # Create notification
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("parliament_ios_distributed")
        n.device_token = device_token
        n.alert = {
            title: "Potential Exposure",
            body: "Check the Notifications Tab!"
        }
        # pass any custom data here
        n.data = {
            type: 'message',
            infectedIDs: payloadChunk,
        }
        #headers: {
        #    'apns-push-type': "background",
        #    'apns-priority': "5"
        #},
        n.sound = "water_droplet_3.wav"
        n.content_available = true
        n.save!
        # Send Notification
        Rpush.push
    end

    def send_fcm_notification(device_token, payloadChunk)
        # Assemble Request
        url = URI("https://fcm.googleapis.com/fcm/send")
        https = Net::HTTP.new(url.host, url.port);
        https.use_ssl = true
        request = Net::HTTP::Post.new(url)
        request["Authorization"] = "key=AAAAQPfWnqU:APA91bELotc45F69FyZUtQL5A4NnrIVwS-CsiMOE2OaWWgrcf53v3tvrbVdkZoL-b7ApjfgygOdN3Dd8neo45NGnpIhof8WfQ1pllAxXv3DWL3nVu1x36oOVnrTL09AH0sc9CnfRMir1"
        request["Content-Type"] = "application/json"
        request["Host"] = "fcm.googleapis.com"
        request.body = "{\n    \"to\":\"#{device_token}\",\n    \"notification\" : {\n     \"body\" : \"Check the Notifications Tab!\",\n     \"title\": \"Potential Exposure\"\n    },\n    \"data\" : {\n        \"body\" : \"Check the Notifications Tab!\",\n        \"title\": \"Potential Exposure\",\n        \"infectedIDs\": #{payloadChunk}  }\n}"
        # Send Request
        response = https.request(request)
    end

end