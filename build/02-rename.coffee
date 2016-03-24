#!env coffee

path = require 'path'
fs =   require 'fs-promise'





base = path.join __dirname, '../data/csv'

rename = (from, to) ->
	console.log path.join(base, from), '->', path.join base, to
	fs.rename path.join(base, from), path.join base, to



module.exports = ->

	console.log 'Renaming:'

	Promise.resolve()
	.then -> rename 'agency.txt',         'agencies.csv'
	.then -> rename 'routes.txt',         'lines.csv'
	.then -> rename 'trips.txt',          'trips.csv'
	.then -> rename 'stop_times.txt',     'trips-stations.csv'
	.then -> rename 'stops.txt',          'stations.csv'
	.then -> rename 'transfers.txt',      'transfers.csv'
	.then -> rename 'calendar.txt',       'calendar.csv'
	.then -> rename 'calendar_dates.txt', 'calendar-exceptions.csv'

	.then -> console.log 'Done.'
