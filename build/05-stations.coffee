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

processLine = (lines) ->
	return (data) -> lines[data.id] = typeWeight[data.type] or 0



processTrip = (trips) ->
	return (data) -> trips[data.id] = data.lineId



processStation = (stations) ->
	return (data) ->
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

processTripStation = (lines, trips, stations) ->
	return (data) ->
		weight = lines[trips[parseInt data.trip_id]] or 1
		weight *= (dropOffWeight[data.drop_off_type] or 0) + (dropOffWeight[data.pickup_type] or 0)
		stations[parseInt data.stop_id].weight += weight





readNdjson = (file, handle) ->
	task = Q.defer()

	parse = fs.createReadStream path.join __dirname, '../data', file
	.pipe ndjson.parse()
	parse.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		task.reject err
	parse.on 'data', handle
	parse.on 'end', task.resolve

	return task.promise



readCsv = (file, handle) ->
	task = Q.defer()

	parse = fs.createReadStream path.join __dirname, '../data/csv', file
	.pipe csv
		columns:	true
	parse.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		task.reject err
	parse.on 'data', handle
	parse.on 'end', task.resolve

	return task.promise



writeNdjson = (file) ->
	return (stations) ->
		task = Q.defer()

		stringify = ndjson.stringify()
		stringify.on 'error', (err) ->
			console.error err.stack   # todo: remove?
			task.reject err

		writeStream = fs.createWriteStream path.join __dirname, '../data', file

		writeStream.on 'error', (err) ->
			console.error err.stack   # todo: remove?
			task.reject err
		writeStream.on 'finish', task.resolve

		stringify.pipe writeStream
		for id, station of stations
			stringify.write station
		stringify.end()

		return task.promise





lines = []
trips = []
stations = {}

console.log 'Merging stations.csv & trips-stations.csv:'

readNdjson 'lines.ndjson', processLine lines
.then () ->
	return readNdjson 'trips.ndjson', processTrip trips
.then () ->
	return readCsv 'stations.csv', processStation stations
.then () ->
	return readCsv 'trips-stations.csv', processTripStation lines, trips, stations

.then () ->
	console.log 'Done.'
	console.log 'Downloading & merging entrances from Open Street Map:'
	return downloadEntrances()
.then (entrances) ->
	return mapEntrances stations, entrances
.then (stations) ->
	console.log 'Done.'
	console.log 'Writing into stations.ndjson:'
	return stations

# write data
.then writeNdjson 'stations.ndjson'
.catch (err) ->
	console.error err.stack

.then () ->
	console.log 'Done.'
