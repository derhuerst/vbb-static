var util =		require('vbb-util');





var routeTypes = {  // @vbb: wtf?
	'100':	'regional',
	'102':	'regional',
	'109':	'suburban',
	'400':	'subway',
	'700':	'bus',
	'900':	'bus',
	'1000':	'ferry'
};



module.exports = {

	parseAgency: function (agency) {
		return agency.replace(/[-_]+$/, '');
	},

	parseRouteType: function (type) {
		return routeTypes[type] || 'unknown';
	},

	parseDate: function (date) {
		return new Date([
			date.substr(0, 4),
			date.substr(4, 2),
			date.substr(6, 2)
		].join('-'));
	},

	stringifyDate: util.dateTime.stringifyToDate

};
