class MyJob
    include Sidekiq::Worker
  
    def perform(args)
      
      # block that will be retried in case of failure
    end
  end