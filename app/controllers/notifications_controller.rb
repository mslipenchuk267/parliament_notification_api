require "uri"
require "net/http"

class NotificationsController < ApplicationController

    def test_notification
        # # Get  infectedIDs (temp_id, created_date) from Infection API
        infectedIDs = get_infected_ids
        payloadChunks = infectedIDs.each_slice(18)

        # Get deviceKeys from Auth API
        device_tokens = get_device_tokens

        #Test sending notifications with sidekiq jobs
        payloadChunks.each_with_index do |payloadChunk,index|
            puts "Chunk number #{index}:\n #{payloadChunk}"
            TestNotificationWorker.perform_async(device_tokens,JSON.generate(payloadChunk))
        end

        render json: {status: "Successfully sent notifications"}

    end

    def send_notification
        # # Get  infectedIDs (temp_id, created_date) from Infection API
        infectedIDs = get_infected_ids
        payloadChunks = infectedIDs.each_slice(15)

        # Get deviceKeys from Auth API
        device_tokens = get_device_tokens

        #Test sending notifications with sidekiq jobs
        payloadChunks.each_with_index do |payloadChunk,index|
            puts "Chunk number #{index}:\n #{payloadChunk}"
            NotificationWorker.perform_async(device_tokens,JSON.generate(payloadChunk))
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


end
