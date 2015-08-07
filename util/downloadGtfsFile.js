var NeDB =			require('nedb');
var request =		require('request');
var path =			require('path');
var parse =			require('csv-parse');
var sTransform =	require('stream-transform');





module.exports = function (url, file, transform) {
	var db = new NeDB({
		filename:	path.join(__dirname, '../data', file),
		autoload:	true
	});
	request(url)
	.pipe(parse({
		columns:	true
	}))
	.pipe(sTransform(function (data) {
		db.insert(transform(data));
	}))
};
