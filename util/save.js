var Q =				require('q');
var path =			require('path');
var fs =			require('fs');





var base = path.join(__dirname, '..', 'data');

// takes a file name & content
// returns a promise for the content
module.exports = function (file, data) {
	var deferred = Q.defer();

	saveStream = fs.writeFile(path.join(base, file), data, function (err) {
		if (err) deferred.reject(err);
		else deferred.resolve(data);
	});

	return deferred.promise;
};
