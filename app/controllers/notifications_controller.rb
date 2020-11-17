require "uri"
require "net/http"

class NotificationsController < ApplicationController

    def test_notification
        # Get  infectedIDs (temp_id, created_date) from Infection API
        infectedIDs = get_infected_ids
        payloadChunks = infectedIDs.each_slice(19)

        # Get deviceKeys from Auth API
        device_tokens = get_device_tokens
        
        # Send notifications to all users
        device_tokens.each do |device_token|
            payloadChunks.each do |payloadChunk|
                send_notification(device_token, JSON.generate(payloadChunk))
            end
        end
        render json: {status: "Successfully sent notifications"}

    end

    private 

    def get_infected_ids
        url_string = ENV['INFECTION_URI'] + "/temp_ids"
        url = URI(url_string)
        http = Net::HTTP.new(url.host, url.port);
        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request.body = "{\n  \"accessToken\":\"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo3LCJ0eXBlIjoiYWNjZXNzIiwic2FsdCI6IkRuUUxDNUBaIn0.XYP-vxVsgGKc0rrzD3oOB-tQll3RDnNJHWAUudWysIg\"\n}"
        
        response = http.request(request)
        # Format the response
        result_json = JSON.parse(response.read_body)
        rawInfectedIDs = result_json['temp_ids']
        # Remove null entries
        rawInfectedIDs -= [nil]
    end

    def get_device_tokens
        url_string = ENV['AUTH_URI'] + "/device_keys"
        url = URI(url_string)
        http = Net::HTTP.new(url.host, url.port);
        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/json"
        request.body = "{\n    \"accessToken\": \"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo2LCJ0eXBlIjoiYWNjZXNzIiwic2FsdCI6IlNwVlc0QlBLIn0.86XNvLqt7Hb9bNCDymtflsim89I4B0iIoYEXbKd0JxI\"\n}"
        # Send Request
        response = http.request(request)
        # Format the response
        result_json = JSON.parse(response.read_body)
        device_tokens = result_json['device_keys']
        # Remove null entries
        device_tokens -= [nil]
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
        n.app = Rpush::Apns::App.find_by_name("parliament_ios_prod_test")
        n.device_token = device_token
        n.alert = {
            title: "Parliament",
            body: "Check the Notifications Tab!"
        }
        # pass any custom data here
        n.data = {
            type: 'message',
            infectedIDs: payloadChunk,
        }
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
        request.body = "{\n    \"to\":\"#{device_token}\",\n    \"notification\" : {\n     \"body\" : \"please work\",\n     \"title\": \"Notification from postman\"\n    },\n    \"data\" : {\n        \"body\" : \"please work\",\n        \"title\": \"Notification from postman\",\n        \"infectedIDs\": #{payloadChunk}  }\n}"
        # Send Request
        response = https.request(request)
    end

end
