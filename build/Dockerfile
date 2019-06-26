FROM ruby:2.6.3-alpine3.9

RUN apk update \
&& apk add --no-cache bash build-base curl libc-dev libffi-dev libressl-dev libxml2-dev libxslt-dev linux-headers readline readline-dev sqlite sqlite-dev \
\
&& bundle config build.nokogiri --use-system-libraries \
&& rm -rf //var/cache/apk/* \
          /tmp/* \
          /var/tmp/*

RUN gem install json nokogiri sqlite3 --no-document
RUN gem install rails --version 6.0.0.rc1 --no-document
# RUN gem install puma --version 3.11 --no-document
# RUN gem install sass-rails --no-document
# RUN gem install webpacker --no-document

WORKDIR /usr/src