FROM ruby:2.5-alpine

RUN apk update && \
    apk add git && \
    mkdir -p /app/lib/jet_black

WORKDIR /app

COPY Gemfile* jet_black.gemspec /app/
COPY lib/jet_black/version.rb /app/lib/jet_black/version.rb

RUN bundle install --jobs=4 --retry=3

COPY . /app
