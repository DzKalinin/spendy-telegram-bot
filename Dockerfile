FROM ruby:3.1.2

# install rails dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

# create a folder /spendy-telegram-bot in the docker container and go into that folder
RUN mkdir /spendy-telegram-bot
WORKDIR /spendy-telegram-bot

# Copy the Gemfile and Gemfile.lock from app root directory into the /spendy-telegram-bot/ folder in the docker container
COPY Gemfile /spendy-telegram-bot/Gemfile
COPY Gemfile.lock /spendy-telegram-bot/Gemfile.lock

ADD config/application.yml.sample /spendy-telegram-bot/config/application.yml

# Run bundle install to install gems inside the gemfile
RUN bundle install

# Copy the whole app
COPY . /spendy-telegram-bot

CMD ["bundle","exec","ruby","bot.rb"]
