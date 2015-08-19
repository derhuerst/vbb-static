var Q =				require('q');

var read =			require('../util/read');
var parse =			require('../util/parse-csv');
var save =			require('../util/save');





// takes data
// returns a promise for data
exports.parse = function (data) {
	var deferred = Q.defer();

	var parser = read('stops.txt')
	.pipe(parse());
	parser.on('error', deferred.reject);
	parser.on('data', function (station) {

		data[station.stop_id] = {
			id:			station.stop_id,
			name:		station.stop_name,
			latitude:	parseFloat(station.stop_lat),
			longitude:	parseFloat(station.stop_lon),
			weight:		0
		};

	});
	parser.on('end', function () {
		deferred.resolve(data);
	});
	return deferred.promise;
};





var dropOffWeight = {
	'0':	5,
	'2':	1,
	'3':	3,
};



// takes data
// returns a promise for data
exports.weights = function (data) {
	var deferred = Q.defer();

	var parser = read('stop_times.txt')
	.pipe(parse());
	parser.on('error', deferred.reject);
	parser.on('data', function (station) {

		data[station.stop_id].weight += dropOffWeight[station.drop_off_type] || 0;

	});
	parser.on('end', function () {
		deferred.resolve(data);
	});
	return deferred.promise;
};





// takes data
// returns a promise for data
exports.save = function (data) {
	return save('stations.json', JSON.stringify(data));
};
