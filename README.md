# Parliament Notification API

This API is responsible for notifying users of potential infection exposure

## Configuration

* Ruby version = 2.7.1
* Notification: Rpush
* Database = Postgresql

# Deployment Instructions
## Production Environment
### Host
http://a434a2b341eec42dd860776cfa521615-1630259772.us-east-1.elb.amazonaws.com

## Development Environment
- Run ``` bundle install ``` in project root directory
- Start server with ``` rails s -p 3003```
- In another terminal run ``` redis-server ```
- In another terminal run ``` bundle exec Sidekiq ``` in project root directory
### Host
http://localhost:3003

## Endpoints:
- ```/send_notification ```
    - Send out notifications to devices

    - Example Successful Return:
    ```
    {
      status: "Successfully Started Notification Workers"
    }
     
- ```/test_notification ```
    - Create local sidekiq workers to mock sending notifications

    - Example Successful Return:
    ```
    {
      status: "Successfully Started Test Notification Workers"
    }
    
- ```/sidekiq ```
    - Displays a web UI for monitoring the current status of Sidekiq workers
