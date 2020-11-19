FROM ruby:2.7.1

# Create a local folder for the app assets
RUN mkdir /notification-backend
WORKDIR /notification-backend

# Install required tooling
RUN apt-get update && apt-get install -qq -y build-essential nodejs libpq-dev postgresql-client --fix-missing --no-install-recommends

# Set our environment variables
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true 
ENV RAILS_LOG_TO_STDOUT true 

# Copy and install Gems from our Gemfile
COPY Gemfile /notification-backend/Gemfile 
COPY Gemfile.lock /notification-backend/Gemfile.lock

RUN gem install bundler -v 2.0.2

RUN bundle config set deployment 'true'
RUN bundle install
#RUN bundle exec rpush init --active-record false
RUN bundle exec redis-server
RUN bundle exec sidekiq

COPY . ./

# Append the rpush setup for iOS app in the config/initializers/rpush.rb file 
# RUN echo "\
# if (!Rpush::Apns::App.find_by_name(\"parliament_ios\")) \n\
#   app = Rpush::Apns::App.new \n\
#   app.name = \"parliament_ios\" \n\
#   env = Rails.env.development? ? \"development\" : \"production\" \n\
#   app.certificate = File.read(\"config/#{env}.pem\") \n\
#   app.environment = env # APNs environment. \n\
#   app.password = \"parliament\" \n\
#   app.connections = 1 \n\
#   app.save! \n\
# end" >> ./config/initializers/rpush.rb

EXPOSE 3000

# Start the puma server
CMD bundle exec puma -p 3000