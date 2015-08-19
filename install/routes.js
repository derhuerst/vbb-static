var Q =				require('q');

var read =			require('../util/read');
var parse =			require('../util/parse-csv');
var save =			require('../util/save');





var parseAgency = function (agency) {
	return agency.replace(/[-_]+$/, '');
};



var routeTypes = {  // @vbb: wtf?
	'100':	'regional',
	'102':	'regional',
	'109':	'suburban',
	'400':	'subway',
	'700':	'bus',
	'900':	'bus',
	'1000':	'ferry'
};

var parseRouteType = function (type) {
	return routeTypes[type] || 'unknown';
};



// takes data
// returns a promise for data
exports.parse = function (data) {
	var deferred = Q.defer();

	var parser = read('routes.txt')
	.pipe(parse());
	parser.on('error', deferred.reject);
	parser.on('data', function (route) {

		if (!route.route_short_name) return;
		data[route.route_short_name] = {
			agency:	parseAgency(route.agency_id),
			type:	parseRouteType(route.route_type)
		};

	});
	parser.on('end', function () {
		deferred.resolve(data);
	});
	return deferred.promise;
};





// takes data
// returns a promise for data
exports.save = function (data) {
	return save('routes.json', JSON.stringify(data));
};
