path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
Q =				require 'q'
csv =			require 'csv-parse'
ndjson =		require 'ndjson'





# todo: `data.pickup_type` & `data.drop_off_type` ?



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

processTripStation = (stations) ->
	return (data) ->
		stations[parseInt data.stop_id].weight += dropOffWeight[data.drop_off_type] or 0





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





stations = {}

console.log 'Merging stations.csv & trips-stations.csv into stations.ndjson:'

# read & accumulate data
readCsv 'stations.csv', processStation stations
.then () ->
	return readCsv 'trips-stations.csv', processTripStation stations

# pass `stations` in
.then () ->
	return stations

# write data
.then writeNdjson 'stations.ndjson'
.catch (err) ->
	console.error err.stack

.then () ->
	console.log 'Done.'
