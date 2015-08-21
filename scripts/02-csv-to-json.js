#!/usr/bin/env node

var path =			require('path');
var fs =			require('fs');
var csv =			require('csv-parse');
var through =		require('through');
var ndjson =		require('ndjson');





var base = path.join(__dirname, '../data');

var filters = {
	'agencies.csv':				function (data) {
		this.queue({
			id:				data.agency_id,
			name:			data.agency_name,
			url:			data.agency_url
		});
	},
	'routes.csv':				function (data) {
		if (!data.route_short_name) return;
		this.queue({
			id:				parseInt(data.route_id),
			name:			data.route_short_name,
			agencyId:		data.agency_id
		});
	},
	'trip-stations.csv':		function (data) {
		this.queue({
			tripId:			parseInt(data.trip_id),
			stationId:		parseInt(data.stop_id),
			index:			parseInt(data.stop_sequence)
			// todo: `data.pickup_type` & `data.drop_off_type` ?
		});
	},
	'stations.csv':				function (data) {
		this.queue({
			id:				parseInt(data.stop_id),
			name:			data.stop_name,
			latitude:		parseFloat(data.stop_lat),
			longitude:		parseFloat(data.stop_lon)
		});
	},
	'transfers.csv':			function (data) {
		this.queue({
			stationFromId:	parseInt(data.from_stop_id),
			stationToId:	parseInt(data.to_stop_id),
			time:			parseInt(data.min_transfer_time),
			tripFromId:		parseInt(data.from_trip_id),
			tripToId:		parseInt(data.to_trip_id)
		});
	},
	'trips.csv':				function (data) {
		this.queue({
			id:				parseInt(data.trip_id),
			routeId:		parseInt(data.route_id),
			calendarId:		parseInt(data.service_id),
			name:			data.trip_headsign
		});
	}
};



console.log('Converting CSV to newline-delimited JSON:')

var sourceFile, targetFile, parse, stringify, transform;
for (sourceFile in filters) {

	targetFile = path.basename(sourceFile, '.csv') + '.ndjson';
	console.log('-', sourceFile, '->', targetFile);

	parse = csv({
		columns:	true
	});
	parse.on('error', function (err) {
		console.err(err.stack);
	});

	stringify = ndjson.stringify();
	stringify.on('error', function (err) {
		console.err(err.stack);
	});

	fs.createReadStream(path.join(base, sourceFile))
	.pipe(parse)
	.pipe(through(filters[sourceFile]))
	.pipe(stringify)
	.pipe(fs.createWriteStream(path.join(base, targetFile)));

}
