mocha =		require 'mocha'
assert =	require 'assert'
concat =	require 'concat-stream'

vbbStatic =	require '../index.js'





tests = [
	{
		method:			'agencies'
		filter:			'VIB'
		result: [{
			id:			'VIB'
			name:		'Verkehrsbetrieb Potsdam GmbH'
			url:		'http://www.vip-potsdam.de'
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
	{
		method:			'routes'
		filter:			1
		result: [{
			id:			1
			name:		'SXF2'
			agencyId:	'ANG'
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
	{
		method:			'stations'
		filter:			5100071
		result: [{
			id:			5100071,
			name:		'Zbaszynek'
			latitude:	52.242504
			longitude:	15.818087
			weight:		25
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
	{
		method:			'transfers'
		filter:
			stationFromId:	9003104
			stationToId:	9003174
		result: [{
			stationFromId:	9003104
			stationToId:	9003174
			time:			180
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
	{
		method:			'trips'
		filter:			1
		result: [{
			id:			1
			routeId:	1
			scheduleId:	'000511'
			name:		'Flughafen Schönefeld Terminal (Airport)'
			stations: [
				{ s: 9230999, t: 17100000 }
				{ s: 9230400, t: 17460000 }
				{ s: 9220019, t: 17940000 }
				{ s: 9220070, t: 18360000 }
				{ s: 9220114, t: 18660000 }
				{ s: 9220001, t: 18780000 }
				{ s: 9260024, t: 19920000 }
			]
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
	{
		method:			'schedules'
		filter:			1
		result: [{
			id:			1
			sunday: { default: true, exceptions: [] }
			monday: { default: true, exceptions: [] }
			tuesday: { default: true, exceptions: [] }
			wednesday: { default: true, exceptions: [] }
			thursday: { default: true, exceptions: [] }
			friday: { default: true, exceptions: [] }
			saturday: { default: true, exceptions: [] }
			# todo: This `offset` field is weird, because it doesn't appear in `data/agencies.ndjson`. One of the transform stream seems to add it.
			offset:		0
		}]
	}
]



for test in tests

	describe test.method, () ->

		it 'should return a stream that is correctly filtered', () ->
			vbbStatic[test.method] test.filter
			.pipe concat { encoding: 'object' }, (result) ->
				assert.deepEqual result, test.result

		it 'should return a promise that resolves with the right data point', () ->
			vbbStatic[test.method] true, test.filter
			.then (result) ->
				assert.deepEqual result, test.result
