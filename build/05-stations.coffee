#!env coffee

oboe =			require 'oboe'
Autocomplete =	require 'vbb-stations-autocomplete'
path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
Q =				require 'q'
csv =			require 'csv-parse'
ndjson =		require 'ndjson'





downloadEntrances = () ->
	deferred = Q.defer()
	entrances = []

	parser = oboe
		url: [
			'http://overpass.osm.rambler.ru/cgi'
			'/interpreter?data='
			'[out:json];'
			'('
			'node(around: 10000, 52.4964393, 13.3864079)["highway"="bus_stop"];'
			'node(around: 10000, 52.4964393, 13.3864079)["railway"="tram_stop"];'
			'node(around: 10000, 52.4964393, 13.3864079)["railway"="station"];'
			'node(around: 10000, 52.4964393, 13.3864079)["public_transport"="stop_position"];'
			');out;'
		].join ''

	parser.node '!.elements[*]', (node, path) ->
		return unless node.tags
		return unless node.tags.name
		entrances.push
			name:		node.tags.name
			latitude:	node.lat
			longitude:	node.lon

	parser.done () ->
		deferred.resolve entrances
	return deferred.promise



mapEntrances = (stations, entrances) ->
	deferred = Q.defer()
	autocomplete = Autocomplete 1

	step = (i) ->
		if i >= entrances.length then return deferred.resolve stations

		autocomplete.suggest entrances[i].name
		.then (results) ->
			station = stations[results[0].id]
			if station
				station.entrances ?= []
				station.entrances.push
					latitude:	entrances[i].latitude
					longitude:	entrances[i].longitude
			step ++i

	step 0
	return deferred.promise





# todo: `data.pickup_type` & `data.drop_off_type` ?



typeWeight =
	'regional':	1
	'suburban':	.8
	'subway':	.7
	'bus':		.3
	'tram':		.35
	'ferry':	.6

processLine = (lines) -> (data) -> lines[data.id] = typeWeight[data.type] or 0

processTrip = (trips) -> (data) -> trips[data.id] = data.lineId



processStation = (stations) -> (data) ->
	stations[data.stop_id] =
		id:				parseInt data.stop_id
		name:			data.stop_name
		latitude:		parseFloat data.stop_lat
		longitude:		parseFloat data.stop_lon
		weight:			0



dropOffWeight =
	'0':	5
	'2':	1
	'3':	3

processTripStation = (lines, trips, stations) -> (data) ->
	weight = lines[trips[parseInt data.trip_id]] or 1
	weight *= (dropOffWeight[data.drop_off_type] or 0) + (dropOffWeight[data.pickup_type] or 0)
	stations[parseInt data.stop_id].weight += weight





readNdjson = (file, handle) -> new Promise (resolve, reject) ->
	parser = ndjson.parse()
	parser.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	parser.on 'data', handle
	parser.on 'end', resolve

	fs.createReadStream path.join __dirname, '../data', file
	.pipe parser



readCsv = (file, handle) -> new Promise (resolve, reject) ->
	parser = csv columns: true
	parser.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	parser.on 'data', handle
	parser.on 'end', resolve

	fs.createReadStream path.join __dirname, '../data/csv', file
	.pipe parser



writeNdjson = (file) -> (stations) -> new Promise (resolve, reject) ->
	stringify = ndjson.stringify()
	stringify.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err

	writeStream = fs.createWriteStream path.join __dirname, '../data', file
	writeStream.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	writeStream.on 'finish', resolve

	stringify.pipe writeStream
	for id, station of stations
		stringify.write station
	stringify.end()





showError = (err) ->
	console.error err.stack
	process.exit err.code || 1

lines = []
trips = []
stations = {}

console.log 'Merging stations.csv & trips-stations.csv:'

readNdjson 'lines.ndjson', processLine lines
.then -> readNdjson 'trips.ndjson', processTrip trips
.then -> readCsv 'stations.csv', processStation stations
.then -> readCsv 'trips-stations.csv', processTripStation lines, trips, stations
.then ->
	console.log 'Done.'
	console.log 'Writing into stations.ndjson:'
	return stations

# write data
.then writeNdjson 'stations.ndjson'
.catch showError
.then -> console.log 'Done.'
