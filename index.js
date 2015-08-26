var path =		require('path');
var Q =			require('q');
var fs =		require('fs');
var ndjson =	require('ndjson');





var base = path.join(__dirname, 'data');

function loadCsv (file, filter) {
	var deferred = Q.defer();
	var results = [];

	var read = fs.createReadStream(path.join(base, file));
	read.on('error', deferred.reject);

	var parse = ndjson.parse();
	read.pipe(parse);
	parse.on('error', deferred.reject);
	parse.on('end', function () {
		deferred.resolve(results);
	});

	parse.on('data', function (data) {
		filter(results, data);
	});

	return deferred.promise;
}





module.exports = {

	agency: function (id) {
		return loadCsv('agencies.ndjson', function (results, data) {
			if (data.id === id) results.push(data);
		});
	},

	route: function (id) {
		return loadCsv('routes.ndjson', function (results, data) {
			if (data.id === id) results.push(data);
		});
	},

	schedule: function (id) {
		return loadCsv('schedules.ndjson', function (results, data) {
			if (data.id === id) results.push(data);
		});
	},

	station: function (id) {
		return loadCsv('stations.ndjson', function (results, data) {
			if (data.id === id) results.push(data);
		});
	},

	// todo: transfers.ndjson

	trip: function (id) {
		return loadCsv('trips.ndjson', function (results, data) {
			if (data.id === id) results.push(data);
		});
	}

};
