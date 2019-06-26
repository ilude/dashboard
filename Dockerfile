FROM ruby:2.6.3-alpine3.9

ENV APP=/app
ENV HOME=/root
ENV RAILS_ENV=production

ENV NPM_CONFIG_PREFIX /node_modules
ENV PATH $NPM_CONFIG_PREFIX:$PATH

ENV GEM_HOME /gems
ENV BUNDLE_BIN $GEM_HOME/bin
ENV PATH $GEM_HOME/bin:$PATH

ENV BUNDLE_JOBS 20
ENV BUNDLE_RETRY 3

ENV TZ=America/New_York
ENV RAILS_TIMEZONE='Eastern Time (US & Canada)'

RUN apk update \
  && apk add --no-cache bash build-base curl libc-dev libffi-dev libressl-dev libxml2-dev libxslt-dev linux-headers nodejs nodejs-npm readline readline-dev sqlite sqlite-dev tzdata yarn \
  && bundle config build.nokogiri --use-system-libraries \
  && ln -snf /etc/localtime /usr/share/zoneinfo/$TZ && echo $TZ > /etc/timezone \
  && mkdir -p $GEM_HOME \
  && echo "alias l='ls --color -lha --group-directories-first'" >> ~/.bashrc \
  && rm -rf /var/cache/apk/* \
            /tmp/* \
            /var/tmp/*

WORKDIR $APP

COPY Gemfile Gemfile.lock package.json yarn.lock $APP/
RUN bundle install 
RUN yarn install

COPY . $APP
COPY config/containers/web/docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "bundle", "exec", "puma", "-C", "config/puma.rb" ]