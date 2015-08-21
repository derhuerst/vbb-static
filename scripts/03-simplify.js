#!/usr/bin/env node

var path =			require('path');
var fs =			require('fs');
var Q =				require('q');
var csv =			require('csv-parse');





var base = path.join(__dirname, '../data');

var parseDate = function (date) {
	return new Date([
		date.substr(0,4),
		date.substr(4,2),
		date.substr(6,2)
	].join('-')).valueOf();
};

var setBit = function (value, offset, bit) {
	return ((value >> (offset+1)) << (offset+1)) | (value & (Math.pow(2, offset)-1)) | (bit << offset);
};



//var services = {};

function processService (services) {
	return function (data) {
		var start = parseDate(data.start_date);
		var end = parseDate(data.end_date);
		var days = Math.round((end - start) / 86400 / 1000);
		var service = services[data.service_id] = {
			start:			start,
			days: 			days,
			availableOn:	new Buffer(Math.ceil(days / 8))
		};
		service.availableOn.fill(0);

		// todo: parse days of week and apply to `service.availableOn`
	}
}

function applyException (services) {
	return function (data) {
		var day = parseDate(data.date);
		var service = services[data.service_id];
		if (!service || !service.start)
			return console.log('ignoring', data.service_id);   // todo: what about `data.service_id === 0`?
		var offset = Math.round((day - service.start) / 86400 / 1000);
		var offsetByte = Math.floor(offset / 8);
		var chunk = service.availableOn.readUInt8(offsetByte, true);
		chunk = setBit(chunk, 7 - (offset % 8), (!(data.exception_type - 1) + 0));
		service.availableOn.writeUInt8(chunk, offsetByte, true);
	}
}


module.exports = function () {
	var services = {};
	return (function () {

		var deferred = Q.defer();

		var parse = fs.createReadStream(path.join(base, 'calendar.csv'))
		.pipe(csv({
			columns:	true
		}));
		parse.on('error', function (err) {
			console.error(err.stack);
		});
		parse.on('data', processService(services));
		parse.on('end', function (end) {
			deferred.resolve();
		});

		return deferred.promise;

	})()
	.then(function () {

		var deferred = Q.defer();
		var parse = fs.createReadStream(path.join(base, 'calendar-exceptions.csv'))
		.pipe(csv({
			columns:	true
		}));
		parse.on('error', function (err) {
			console.error(err.stack);
		});
		parse.on('data', applyException(services));
		parse.on('end', function (end) {
			deferred.resolve();
		});
		return deferred.promise;
	})
	.then(function () {
		for (var service_id in services) {
			var start = services[service_id].start;
			var availableOn = services[service_id].availableOn;
			var days = services[service_id].days;
			var daysOfWeek = [[],[],[],[],[],[],[]];
			var startDay = new Date(start).getDay();
			for (var day = 0; day < days; day++) {
				var offsetByte = Math.floor(day / 8);
				var chunk = availableOn.readUInt8(offsetByte, true);
				var isAvailable = (chunk >> (7 - (day % 8))) & 1;
				daysOfWeek[(startDay + day) % 7].push({
					day: new Date(start + day * 86400 * 1000),
					isAvailable: isAvailable
				});
			}

			var keys = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
			var result = {};

			services[service_id].daysOfWeek = daysOfWeek.map(function (availabilities, dow) {
				var availables = [];
				var notAvailables = [];

				for (var i = 0; i < availabilities.length; i++) {
					if (availabilities[i].isAvailable)
						availables.push(availabilities[i].day);
					else
						notAvailables.push(availabilities[i].day);
				}

				result[keys[dow]] = {
					available: !!(availables.length > notAvailables.length),
					exceptions: availables.length > notAvailables.length ? notAvailables : availables
				};
			});
			if (result.monday.available === true) {
				console.log(service_id, result);
				break;
			}
		}
	});
};


module.exports.processService = processService;
module.exports.applyException = applyException;
module.exports.setBit = setBit;
