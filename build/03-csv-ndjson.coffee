#!env coffee

path =      require 'path'
fs =        require 'fs'
csv =       require 'csv-parse'
through =   require 'through'
ndjson =    require 'ndjson'
waterfall = require 'promise.waterfall'





sourceBase = path.join __dirname, '../data/csv'
targetBase = path.join __dirname, '../data'

cleanAgency = (agency) -> agency.replace /[^a-zA-Z0-9]+$/, ''

types =
	'100':	'regional'
	'102':	'regional'
	'109':	'suburban'
	'400':	'subway'
	'700':	'bus'
	'900':	'tram'
	'1000':	'ferry'



filters =
	'agencies.csv': (data) ->
		this.queue
			id:				cleanAgency data.agency_id
			name:			data.agency_name
			url:			data.agency_url

	'lines.csv': (data) ->
		if not data.route_short_name then return
		this.queue
			id:				parseInt data.route_id
			name:			data.route_short_name
			agencyId:		cleanAgency data.agency_id
			type:			types[data.route_type] || 'unknown'

	'transfers.csv': (data) ->
		this.queue
			stationFromId:	parseInt data.from_stop_id
			stationToId:	parseInt data.to_stop_id
			time:			parseInt data.min_transfer_time



showError = (err) ->
	console.error err.stack
	process.exit err.code || 1

module.exports = ->

	console.log 'Converting CSV to newline-delimited JSON:'

	tasks = Object.keys(filters)
	.map (sourceFile) -> -> new Promise (resolve, reject) ->
		filter = filters[sourceFile]

		targetFile = path.basename(sourceFile, '.csv') + '.ndjson'
		console.log '-', sourceFile, '->', targetFile

		parse = csv columns: true
		parse.on 'error', showError

		stringify = ndjson.stringify()
		stringify.on 'error', showError

		fs.createReadStream path.join sourceBase, sourceFile
		.pipe parse
		.pipe through filter
		.pipe stringify
		.pipe fs.createWriteStream path.join targetBase, targetFile
		.on 'finish', resolve
		.on 'error', reject

	waterfall tasks
	.catch showError
