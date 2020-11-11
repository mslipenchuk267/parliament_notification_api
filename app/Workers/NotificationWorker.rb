class NotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  # def perform(start_date, end_date)
  def perform()
    # puts "SIDEKIQ WORKER GENERATING A REPORT FROM #{start_date} to #{end_date}"
    puts "SIDEKIQ WORKER SENDING NOTIFICATIONS"
    sleep 30
  end

end