path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
Q =				require 'q'
csv =			require 'csv-parse'
ndjson =		require 'ndjson'





# todo: `data.pickup_type` & `data.drop_off_type` ?



processTrip = (trips) ->
	return (data) ->
		trips[data.trip_id] =
			id:				parseInt data.trip_id
			routeId:		parseInt data.route_id
			scheduleId:		data.service_id   # todo: use integers.
			name:			data.trip_headsign
			stations:		[]



processTripStation = (trips) ->
	return (data) ->
		trips[data.trip_id].stations[parseInt data.stop_sequence] =
			s:	parseInt data.stop_id
			t:	moment.duration(data.departure_time).asMilliseconds()
			# todo: check if `data.arrival_time` differs and store it



tripFilterStations = (trips) ->
	for id, trip of trips
		# `trip.stations` may have gaps because `stop_sequence` may not increase continously.
		trip.stations = trip.stations.filter (a) -> a
	return trips





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
	return (trips) ->
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
		for id, trip of trips
			stringify.write trip
		stringify.end()

		return task.promise





simplify = Q.defer()
trips = {}

console.log 'Merging trips.csv & trips-stations.csv into trips.ndjson:'

# read & accumulate data
readCsv 'trips.csv', processTrip trips
.then () ->
	return readCsv 'trips-stations.csv', processTripStation trips

# pass `trips` in
.then () ->
	return trips

.then tripFilterStations

# write data
.then writeNdjson 'trips.ndjson'
.catch (err) ->
	console.error err.stack

.then () ->
	console.log 'Done.'
