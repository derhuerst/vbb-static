var Q =				require('q');
var request =		require('request');
var parse =			require('csv-parse');
var through =		require('through');





module.exports = function (file, transform) {
	var deferred = Q.defer();
	request('https://raw.githubusercontent.com/derhuerst/vbb-gtfs/master/' + file)
	.pipe(parse({
		columns:	true
	}))
	.pipe(through(transform, function end () {
		this.emit('end');
	}))
	.on('error', function (err) {
		deferred.reject(err);
	})
	.on('end', function () {
		deferred.resolve();
	});
	return deferred.promise;
};
