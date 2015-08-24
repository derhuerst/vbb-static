#!/bin/sh

./node_modules/.bin/coffee ./build/01-download.coffee
./node_modules/.bin/coffee ./build/02-csv-ndjson.coffee
./node_modules/.bin/coffee ./build/03-simplify.coffee
