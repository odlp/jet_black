FROM ruby:2.7

WORKDIR /app

COPY Gemfile* jet_black.gemspec /app/
COPY lib/jet_black/version.rb /app/lib/jet_black/version.rb

RUN bundle install --jobs=4 --retry=3

COPY . /app
