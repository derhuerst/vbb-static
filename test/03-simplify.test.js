var mocha = require('mocha');
var should = require('should');
var simplify = require('../scripts/03-simplify');





var setBit = simplify.setBit;
var processService = simplify.processService;
var applyException = simplify.applyException;


describe('scripts/03-simplify.js:setBit', function() {
	it('should set the lowest bit', function () {
		setBit(2, 0, 1).should.equal(3);
	});
	it('should set the 4th bit to 0', function () {
		setBit(9, 3, 0).should.equal(1);
	});
});



describe('scripts/03-simplify.js:processService', function() {
	it('should create a service buffer for 24 days with the length of 3', function () {
		var services = {};
		processService(services)({
			start_date: '20000101',
			end_date: '20000123',
			service_id: 'a'
		})
		should.exist(services.a);
		services.a.availableOn.length.should.equal(3);
	});
});

describe('scripts/03-simplify.js:applyException', function() {
	it('should ', function () {
		var services = {
			a: {
				start: Date.parse('2000-01-01'),
				availableOn: new Buffer(2)
			}
		};
		services.a.availableOn.fill(0);
		applyException(services)({
			service_id: 'a',
			date: '20000108'
		})
		applyException(services)({
			service_id: 'a',
			date: '20000116'
		})
		console.log('services.a.availableOn.readUInt8(0)', services.a.availableOn.readUInt8(0))
		console.log('services.a.availableOn.readUInt8(1)', services.a.availableOn.readUInt8(1))
		services.a.availableOn.readUInt8(0).should.equal(1);
		services.a.availableOn.readUInt8(1).should.equal(1);
	});
});
