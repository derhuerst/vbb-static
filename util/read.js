var path =			require('path');
var fs =			require('fs');





var base = path.join(__dirname, '..', 'data');

// takes a file name
// returns a stream
module.exports = function (file) {
	return fs.createReadStream(path.join(base, file));
};
