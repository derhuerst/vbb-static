#!env coffee

path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
csv = require 'csv-parser'
ndjson =		require 'ndjson'

progress = require './progress'





# todo: `data.pickup_type` & `data.drop_off_type` ?



processTrip = (trips) -> (data) ->
	progress()
	trips[data.trip_id] =
		id:				parseInt data.trip_id
		lineId:			parseInt data.route_id
		scheduleId:		parseInt data.service_id
		name:			data.trip_headsign
		stations:		[]



processTripStation = (trips) -> (data) ->
	progress()
	trips[data.trip_id].stations[parseInt data.stop_sequence] =
		s:	parseInt data.stop_id
		t:	moment.duration(data.departure_time).asMilliseconds()
		# todo: check if `data.arrival_time` differs and store it



tripFilterStations = (trips) ->
	for id, trip of trips
		# `trip.stations` may have gaps because `stop_sequence` may not increase continously.
		trip.stations = trip.stations.filter (a) -> a
	return trips





readCsv = (file, handle) -> new Promise (resolve, reject) ->
	parser = csv()
	parser.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	parser.on 'data', handle
	parser.on 'end', resolve

	fs.createReadStream path.join __dirname, '../data/csv', file
	.pipe parser



writeNdjson = (file) -> (trips) -> new Promise (resolve, reject) ->
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
		for id, trip of trips
			stringify.write trip
		stringify.end()





showError = (err) ->
	console.error err.stack
	process.exit err.code || 1

module.exports = ->

	trips = {}

	console.log 'Merging trips.csv & trips-stations.csv into trips.ndjson:'

	# read & accumulate data
	readCsv 'trips.csv', processTrip trips
	.then -> readCsv 'trips-stations.csv', processTripStation trips

	# pass `trips` in
	.then -> trips

	.then tripFilterStations

	# write data
	.then writeNdjson 'trips.ndjson'
	.catch showError

	.then -> console.log 'Done.'
