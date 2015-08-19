var parser =		require('csv-parse');





// returns a streaming csv parser
module.exports = function () {
	return parser({
		columns: true
	});
};
