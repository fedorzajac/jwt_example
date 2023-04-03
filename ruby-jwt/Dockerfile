# Use an official Ruby runtime as a parent image
FROM ruby:3.2-alpine

# Set the working directory to /app
WORKDIR /app

# Copy the Gemfile and Gemfile.lock files to the container
COPY Gemfile Gemfile.lock ./


RUN apk add --no-cache bash
# RUN /bin/sh
RUN apk update && apk add --virtual build-dependencies build-base

# Install dependencies
RUN gem install bundler
RUN bundle install

# Copy the rest of the application code to the container
COPY . .

# Expose port 4567 for the Sinatra app
EXPOSE 4567

# Start the app
CMD [ "bundle", "exec", "ruby", "main.rb", "-o", "0.0.0.0" ]
