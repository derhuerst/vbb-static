var path =			require('path');
var Q =				require('q');
var fs =			require('fs');





var base = path.join(__dirname, '..', 'data');

// takes a file name
// return a promise for success
module.exports = function (file) {
	var deferred = Q.defer();

	fs.unlink(path.join(base, file), function (err) {
		if (err) deferred.reject(err);
		else deferred.resolve(file);
	});

	return deferred.promise;
};
