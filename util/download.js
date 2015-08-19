var Q =				require('q');
var url =			require('url');
var path =			require('path');
var download =		require('download-file');





var base = path.join(__dirname, '..', 'data');

// takes a file name
// return a promise for a file name
module.exports = function (file) {
	var deferred = Q.defer();

	var source = url.parse('https://raw.githubusercontent.com/derhuerst/vbb-gtfs/master');
	source.pathname = path.join(source.pathname, file);
	source = url.format(source);

	download(source, {
		directory:	base,
		filename:	file
	}, function (err) {
		if (err) deferred.reject(err);
		else deferred.resolve(file);
	});

	return deferred.promise;
};
