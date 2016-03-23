pFs =      require 'fs-promise'
fs =       require 'fs'
#!env coffee

path =     require 'path'
so =       require 'so'





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



so(->

	yield pFs.mkdir base

	console.log 'Downloading GTFS zip file.'
	# todo: download promise API

	console.log 'Extracting.'
	# todo: unzip promise API

	console.log 'Deleting zip file.'
	pFs.unlink path.join base, 'gtfs.zip'

)()
.catch (err) -> console.error(err.stack)
.then -> console.log 'Done'
