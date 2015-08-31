path =			require 'path'
fs =			require 'fs'
csv =			require 'csv-parse'
through =		require 'through'
ndjson =		require 'ndjson'





sourceBase = path.join __dirname, '../data/csv'
targetBase = path.join __dirname, '../data'

parseAgency = (agency) ->
	return agency.replace /[^a-zA-Z0-9]+$/, ''



filters =
	'agencies.csv': (data) ->
		this.queue
			id:				parseAgency data.agency_id
			name:			data.agency_name
			url:			data.agency_url

	'lines.csv': (data) ->
		if not data.route_short_name then return
		this.queue
			id:				parseInt data.route_id
			name:			data.route_short_name
			agencyId:		parseAgency data.agency_id

	'transfers.csv': (data) ->
		this.queue
			stationFromId:	parseInt data.from_stop_id
			stationToId:	parseInt data.to_stop_id
			time:			parseInt data.min_transfer_time



console.log 'Converting CSV to newline-delimited JSON:'

for sourceFile, filter of filters

	targetFile = path.basename(sourceFile, '.csv') + '.ndjson'
	console.log '-', sourceFile, '->', targetFile

	parse = csv
		columns:	true
	parse.on 'error', (err) -> console.error err.stack

	stringify = ndjson.stringify()
	stringify.on 'error', (err) -> console.error err.stack

	fs.createReadStream path.join sourceBase, sourceFile
	.pipe parse
	.pipe through filter
	.pipe stringify
	.pipe fs.createWriteStream path.join targetBase, targetFile
