FROM ruby:3.0.0-alpine

RUN mkdir /app
WORKDIR /app
COPY . /app

RUN apk add --update --no-cache \
    build-base \
    sqlite-dev

RUN bundle install

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]