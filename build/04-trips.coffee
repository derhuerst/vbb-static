path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
Q =				require 'q'
csv =			require 'csv-parse'
ndjson =		require 'ndjson'
md5 =			require 'md5'





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
	return (entries) ->
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
		for id, entry of entries
			stringify.write entry
		stringify.end()

		return task.promise





# todo: `data.pickup_type` & `data.drop_off_type` ?



processTrip = (trips) ->
	return (data) ->
		trips[data.trip_id] =
			id:				parseInt data.trip_id
			lineId:			parseInt data.route_id
			scheduleId:		data.service_id   # todo: use integers.
			name:			data.trip_headsign
			stations:		[]



processTripStation = (trips) ->
	return (data) ->
		trips[data.trip_id].stations[parseInt data.stop_sequence] =
			s:	parseInt data.stop_id
			t:	moment.duration(data.departure_time).asMilliseconds()
			# todo: check if `data.arrival_time` differs and store it



findPatternsInTrips = (trips, schedules) ->
	return (trips) ->
		scheduleId = 0
		for id, trip of trips

			start = null
			stations = []
			# `trip.stations` may have gaps because `stop_sequence` may not increase continously.
			for stop in trip.stations
				continue if not stop
				if start is null then start = stop.t
				stations.push
					s:	stop.s
					t:	stop.t - start

			hash = md5 JSON.stringify stations
			schedules[hash] ?=
				id:			scheduleId
				stations:	stations

			trips['' + trip.id].start = start
			delete trips['' + trip.id].stations
			delete trips['' + trip.id].id

			scheduleId++
		return trips





trips = {}
schedules = {}

console.log 'Merging trips.csv & trips-stations.csv into trips.ndjson and schedules.ndjson:'

# read & accumulate data
readCsv 'trips.csv', processTrip trips
.then () ->
	return readCsv 'trips-stations.csv', processTripStation trips

# pass `trips` in
.then () ->
	return trips

.then findPatternsInTrips trips, schedules
.catch (err) ->
	console.error err.message
	console.error err.stack if err.stack
	process.exit 1

.then () ->
	console.log 'writing trips'
	return (writeNdjson 'trips.ndjson') trips
.then () ->
	console.log 'writing schedules'
	return (writeNdjson 'schedules.ndjson') schedules
.then () ->
	console.log 'Done.'
