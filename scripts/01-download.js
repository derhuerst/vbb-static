#!/usr/bin/env node

var download =		require('download-stream');
var unzip =			require('unzip2');
var path =			require('path');
var fs =			require('fs');





var base = path.join(__dirname, '../data');
var paths = {
	'agency.txt':			'agencies.csv',
	'calendar.txt':			'calendar.csv',
	'calendar_dates.txt':	'calendar-exceptions.csv',
	'routes.txt':			'routes.csv',
	'stop_times.txt':		'trip-stations.csv',
	'stops.txt':			'stations.csv',
	'transfers.txt':		'transfers.csv',
	'trips.txt':			'trips.csv'
};



console.log('Downloading & extracting GTFS zip file:')

var zip = unzip.Parse();
download('https://codeload.github.com/derhuerst/vbb-gtfs/zip/master')
.pipe(zip);

zip.on('entry', function (entry) {
	var name = path.basename(entry.path);
	if (entry.type != 'File' || !paths[name])
		return entry.autodrain();
	console.info('-', name, '->', paths[name]);
	entry.pipe(fs.createWriteStream(path.join(base, paths[name])));
});

zip.on('error', function (err) {
	console.err(err.stack);
});

zip.on('finish', function () {
	console.info('Done.');
});
