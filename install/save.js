var path =			require('path');
var Q =				require('q');
var fs =			require('fs');





base = path.join(__dirname, '..', 'data');

module.exports = function (file, data) {
	var deferred = Q.defer();
	data = JSON.stringify(data);
	fs.writeFile(path.join(base, file), data, {
		flags:	'w'
	}, function (err) {
		if (err) return deferred.reject(err);
		deferred.resolve();
	});
	return deferred.promise;
};
