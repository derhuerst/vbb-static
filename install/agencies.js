var Q =				require('q');

var read =			require('../util/read');
var parse =			require('../util/parse-csv');
var save =			require('../util/save');





var parseAgency = function (agency) {
	return agency.replace(/[-_]+$/, '');
};



// takes data
// returns a promise for data
exports.parse = function (data) {
	var deferred = Q.defer();

	var parser = read('agency.txt')
	.pipe(parse());
	parser.on('error', deferred.reject);
	parser.on('data', function (agency) {

		data[parseAgency(agency.agency_id)] = {
			name:	agency.agency_name,
			url:	agency.agency_url,
			phone:	agency.agency_phone
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
	return save('agencies.json', JSON.stringify(data));
};
