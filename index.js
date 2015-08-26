var path =		require('path');
var Q =			require('q');
var fs =		require('fs');
var ndjson =	require('ndjson');
var select =	require('select-stream');





var base = path.join(__dirname, 'data');

function loadCsv (file, filter, collect, finalize) {
	var deferred = Q.defer();
	var results = [];

	var stream = fs.createReadStream(path.join(base, file))
	.pipe(ndjson.parse())
	.pipe(select(filter));
	stream.on('error', deferred.reject);

	stream.on('data', function (data) {
		collect(results, data);
	});
	stream.on('end', function () {
		results = finalize(results);
		deferred.resolve(results);
	});

	return deferred.promise;
}

function filter (pattern) {
	if (typeof pattern === 'object')
		return function (data) {
			for (var key in pattern) {
				if (pattern.hasOwnProperty(key))
					if (pattern[key] !== data[key]) return false;
			}
			return true;
		};
	else
		return function (data) {
			return data.id === pattern
		};
}

function collect (results, data) {
	results.push(data);
}

function finalize (results) {
	if (results.length === 0) return null;
	if (results.length === 1) return results[0];
	else return results;
}





function method (file, filter, collect, finalize) {
	return function (pattern) {
		return loadCsv(file, filter(pattern), collect, finalize);
	};
}

module.exports = {

	agency:		method('agencies.ndjson', filter, collect, finalize),
	route:		method('routes.ndjson', filter, collect, finalize),
	station:	method('stations.ndjson', filter, collect, finalize),
	transfer:	method('transfers.ndjson', filter, collect, finalize),
	trip:		method('trips.ndjson', filter, collect, finalize)

};
