Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post "/test_notification", to: "notifications#test_notification"
  post "/testjob", to: "notifications#notify"
end
