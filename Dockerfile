FROM ruby:2.7.1

# Downgrade SSL to make APNs happy
RUN sed -i '1s/^/openssl_conf = default_conf /' /etc/ssl/openssl.cnf
RUN echo '[ default_conf ]' >> /etc/ssl/openssl.cnf
RUN echo 'ssl_conf = ssl_sect' >> /etc/ssl/openssl.cnf
RUN echo '[ssl_sect]' >> /etc/ssl/openssl.cnf
RUN echo 'system_default = ssl_default_sect' >> /etc/ssl/openssl.cnf
RUN echo '[ssl_default_sect]' >> /etc/ssl/openssl.cnf
RUN echo 'MinProtocol = TLSv1.2' >> /etc/ssl/openssl.cnf
RUN echo 'CipherString = DEFAULT:@SECLEVEL=0' >> /etc/ssl/openssl.cnf


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

COPY . ./

EXPOSE 3000

# Start the puma server
CMD bundle exec puma -p 3000