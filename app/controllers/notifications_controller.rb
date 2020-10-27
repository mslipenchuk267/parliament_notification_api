require "uri"
require "net/http"

class NotificationsController < ApplicationController

    def test_notification
        device_token = params[:deviceToken]

        send_notification(device_token)
        
    end

    private 

    def send_notification(device_token)
        if device_token.length < 162
            send_apns_notification(device_token)
        else 
            send_fcm_notification(device_token)
        end
    end

    def send_apns_notification(device_token)
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("parliament_ios")
        n.device_token = device_token
        n.alert = {
            title: "From Notification API",
            body: "Hello World 2"
        }
        # pass any custom data here
        n.data = {
            type: 'message',
            user_name: 'Bob',
        }
        n.sound = "water_droplet_3.wav"
        n.content_available = true
        n.save!
        
        Rpush.push
    end

    def send_fcm_notification(device_token)
        url = URI("https://fcm.googleapis.com/fcm/send")

        https = Net::HTTP.new(url.host, url.port);
        https.use_ssl = true
        
        request = Net::HTTP::Post.new(url)
        request["Authorization"] = "key=AAAAQPfWnqU:APA91bELotc45F69FyZUtQL5A4NnrIVwS-CsiMOE2OaWWgrcf53v3tvrbVdkZoL-b7ApjfgygOdN3Dd8neo45NGnpIhof8WfQ1pllAxXv3DWL3nVu1x36oOVnrTL09AH0sc9CnfRMir1"
        request["Content-Type"] = "application/json"
        request["Host"] = "fcm.googleapis.com"
        request.body = "{\n    \"to\":\"#{device_token}\",\n    \"notification\" : {\n     \"body\" : \"please work\",\n     \"title\": \"Notification from postman\"\n    },\n    \"data\" : {\n        \"body\" : \"please work\",\n        \"title\": \"Notification from postman\",\n        \"key_1\" : \"Value for key_1\",\n        \"key_2\" : \"Value for key_2\"\n    }\n}"
        
        response = https.request(request)

        render json: response.read_body
    end

end
