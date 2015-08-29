var path =		require('path');
var fs =		require('fs');
var ndjson =	require('ndjson');
var select =	require('select-stream');
var Q =			require('q');





var base = path.join(__dirname, 'data');



function allFilter () {
	return true;
}

function createFilter (pattern) {
	if (pattern === 'all')
		return allFilter;
	else if (pattern && typeof pattern === 'object')   // field filter
		return function (data) {
			for (var key in pattern) {
				if (pattern.hasOwnProperty(key) && pattern[key] !== data[key])
					return false;
			}
			return true;
		};
	else   // primary key filter
		return function (data) {
			return data.id === pattern
		};
}



function createMethod (file) {
	return function (promised, filter) {
		if (arguments.length === 1) {
			filter = promised;
			promised = false;
		}

		filter = select(createFilter(filter));
		var reader = fs.createReadStream(path.join(base, file));
		reader.on('error', function (err) {
			filter.emit('error', err);
		});
		var parser = ndjson.parse()
		parser.on('error', function () {
			filter.emit('error', err);
		});

		reader.pipe(parser).pipe(filter);

		if (promised) {
			// todo: maybe use `concat-stream-promise` once it supports object mode
			var results = [];
			var deferred = Q.defer();
			filter.on('data', function (data) {
				results.push(data);
			});
			filter.on('error', function (err) {
				deferred.reject(err);
			});
			filter.on('end', function () {
				deferred.resolve(results);
			});
			return deferred.promise;
		}

		else return filter;
	};
}





module.exports = {

	agencies:	createMethod('agencies.ndjson'),
	routes:		createMethod('routes.ndjson'),
	stations:	createMethod('stations.ndjson'),
	transfers:	createMethod('transfers.ndjson'),
	trips:		createMethod('trips.ndjson'),
	schedules:	createMethod('schedules.ndjson')

};
