#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e 

# enable this for testing/debugging, to print out commands as they are run
if [ ! -z ${DEBUG_ENTRYPOINT} ] && [ "$DEBUG_ENTRYPOINT" == "true" ]; then
set -x
set -o xtrace 
fi

# setup timezone 
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

 # clean up old pid files
mkdir -p /app/tmp/pids || true
rm /app/tmp/pids/*.pid 2> /dev/null || /bin/true;

#yarn install --check-files

if [ ! -z ${PRIMARY_INSTANCE} ] && [ "$PRIMARY_INSTANCE" == "true" ] && [ "$RAILS_ENV" != "development" ]; then
    echo "Running database migrations"
    bundle exec rake db:migrate
fi

$@