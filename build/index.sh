#!/bin/sh

./node_modules/.bin/coffee ./build/01-download.coffee
./node_modules/.bin/coffee ./build/02-csv-ndjson.coffee
./node_modules/.bin/coffee ./build/03-schedules.coffee
./node_modules/.bin/coffee ./build/04-cleanup.coffee
