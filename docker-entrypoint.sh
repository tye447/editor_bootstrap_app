#!/bin/bash

bundle check || bundle install --binstubs="$BUNDLE_BIN"
yarn install

if [ ! -f 'tmp/db_created' ]; then
  echo "create database"
  rake db:create &&
  rake db:migrate &&
  mkdir -p tmp &&
  touch tmp/db_created
fi

exec "$@"
