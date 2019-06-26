FROM ruby:2.6.3-alpine3.9

RUN apk update \
&& apk add --no-cache bash build-base curl libc-dev libffi-dev libressl-dev libxml2-dev libxslt-dev linux-headers nodejs readline readline-dev sqlite sqlite-dev \
\
&& bundle config build.nokogiri --use-system-libraries \
&& rm -rf //var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

ENV APP=/app
WORKDIR $APP

COPY Gemfile* $APP/
RUN bundle install

COPY . $APP