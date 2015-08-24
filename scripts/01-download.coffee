download =		require 'download-stream'
unzip =			require 'unzip2'
path =			require 'path'
fs =			require 'fs'





base = path.join __dirname, '../data'
paths =
	'agency.txt':			'agencies.csv'
	'calendar.txt':			'calendar.csv'
	'calendar_dates.txt':	'calendar-exceptions.csv'
	'routes.txt':			'routes.csv'
	'stop_times.txt':		'trip-stations.csv'
	'stops.txt':			'stations.csv'
	'transfers.txt':		'transfers.csv'
	'trips.txt':			'trips.csv'



console.log 'Downloading & extracting GTFS zip file:'

zip = unzip.Parse()
download 'https://codeload.github.com/derhuerst/vbb-gtfs/zip/master'
.pipe zip

zip.on 'entry', (entry) ->
	name = path.basename entry.path
	if entry.type != 'File' or not paths[name]
		return entry.autodrain()
	console.info '-', name, '->', paths[name]
	entry.pipe fs.createWriteStream path.join base, paths[name]

zip.on 'error', (err) ->
	console.error err.stack

zip.on 'finish', () ->
	console.info 'Done.'
