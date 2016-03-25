#!/usr/bin/env coffee

download  = require './01-download'
rename    = require './02-rename'
convert   = require './03-csv-ndjson'
schedules = require './04-schedules'
trips     = require './05-trips'
stations  = require './06-stations'
cleanup   = require './07-cleanup'



showError = (err) ->
	console.error err.stack
	process.exit err.code || 1

download()
.catch showError
.then -> rename()
.catch showError
.then -> convert()
.catch showError
.then -> schedules()
.catch showError
.then -> trips()
.catch showError
.then -> stations()
.catch showError
.then -> cleanup()
.catch showError
