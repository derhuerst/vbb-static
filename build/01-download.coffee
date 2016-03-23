#!env coffee

path =     require 'path'
pFs =      require 'fs-promise'
Download = require 'download'





base = path.join __dirname, '../data/csv'
paths =
	'agency.txt':			'agencies.csv'
	'routes.txt':			'lines.csv'
	'trips.txt':			'trips.csv'
	'stop_times.txt':		'trips-stations.csv'
	'stops.txt':			'stations.csv'
	'transfers.txt':		'transfers.csv'
	'calendar.txt':			'calendar.csv'
	'calendar_dates.txt':	'calendar-exceptions.csv'



module.exports = ->

	pFs.mkdir base

	.then -> new Promise (resolve, reject) ->
		console.log 'Downloading & extracting GTFS zip file.'
		new Download extract: true, mode: '755'
			.get 'https://codeload.github.com/derhuerst/vbb-gtfs/zip/master'
			.dest base
			.run (err) -> if err then reject err else resolve()

	.catch (err) -> console.error(err.stack)
	.then -> console.log 'Done'
