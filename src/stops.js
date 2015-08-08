var NeDB =			require('nedb');
var Q =				require('q');





module.exports = {



	db:		null,



	init: function (dir) {
		if (!dir) throw new Error('Missing `dir` parameter.');
		this.db = new NeDB({
			filename:	dir
		});
		this.db.loadDatabase(function (err) {
			if (err) throw err;
		});

		return this;
	},



	byId: function (id) {
		var deferred = Q.defer();
		this.db.findOne({
			_id: id
		}, function (err, results) {
			if (err) deferred.reject(err);
			deferred.resolve(results);
		});
		return deferred.promise;
	},

	byName: function (name) {
		var deferred = Q.defer();
		this.db.find({
			name: name
		}, function (err, results) {
			if (err) deferred.reject(err);
			deferred.resolve(results);
		});
		return deferred.promise;
	}



};
