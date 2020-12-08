# Parliament Notification API

This API is responsible for notifying users of potential infection exposure

## Configuration

* Ruby version = 2.7.1
* Notification: Rpush
* Database = Postgresql

# Deployment Instructions
## Production Environment
### Host

## Development Environment
- Run ``` bundle install ``` in root directory
- Start server with ``` rails s -p 3003```
- Run ``` bundle exec Sidekiq ``` in root directory
- Run ``` redis-server ``` in root directory
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
