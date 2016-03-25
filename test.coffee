sink      = require 'stream-sink'
isStream  = require 'is-stream'
isPromise = require 'is-promise'

s = require './index.js'



module.exports =

	'pass': (t) ->
		t.expect 2
		t.strictEqual s._.pass(), true
		t.strictEqual s._.pass('foo'), true
		t.done()

	'filterById': (t) ->
		predicate = s._.filterById 2
		t.expect 6
		t.strictEqual predicate(),          false
		t.strictEqual predicate({}),        false
		t.strictEqual predicate([2]),       false
		t.strictEqual predicate({id:  1 }), false
		t.strictEqual predicate({id: '2'}), false
		t.strictEqual predicate({id:  2 }), true
		t.done()

	'filterByKeys':

		'returns false for invalid data': (t) ->
			predicate = s._.filterByKeys a: 'foo'
			t.expect 3
			t.strictEqual predicate(),    false
			t.strictEqual predicate([2]), false
			t.strictEqual predicate({}),  false
			t.done()

		'compares strictly': (t) ->
			predicate = s._.filterByKeys a: '1'
			t.expect 2
			t.strictEqual predicate({a:  1 }), false
			t.strictEqual predicate({a: '1'}), true
			t.done()

		'compares only *own* properties': (t) ->
			predicate = s._.filterByKeys a: 'foo'
			x = Object.create a: 'foo'
			t.expect 1
			t.strictEqual predicate(x), false
			t.done()

		'compares multiple keys': (t) ->
			predicate = s._.filterByKeys a: 'foo', b: 'bar'
			t.expect 4
			t.strictEqual predicate({a:  'bar', b: 'bar'}), false
			t.strictEqual predicate({a:  'bar', b: 'foo'}), false
			t.strictEqual predicate({a:  'foo', b: 'foo'}), false
			t.strictEqual predicate({a:  'foo', b: 'bar'}), true
			t.done()



	"reader('agencies.ndjson')":

		'without `promised` flag':

			'returns a stream': (t) ->
				read = s._.reader 'agencies.ndjson'
				t.ok isStream read 'VBB'
				t.done()

			'filters correctly': (t) ->
				read = s._.reader 'agencies.ndjson'
				t.expect 2
				sink = read('VBB').pipe sink objectMode: true
				sink.on 'data', (data) ->
					t.strictEqual data.length, 1
					t.strictEqual data[0].id,  'VBB'
					t.done()

		'with `promised` flag':

			'returns a promise': (t) ->
				read = s._.reader 'agencies.ndjson'
				t.ok isPromise read true, 'VBB'
				t.done()

			'filters correctly': (t) ->
				read = s._.reader 'agencies.ndjson'
				t.expect 2
				read(true, 'VBB').then (data) ->
					t.strictEqual data.length, 1
					t.strictEqual data[0].id,  'VBB'
					t.done()



	'examples from readme':

		'agencies': (t) -> s.agencies(true, 'VBB').then (data) ->
			t.strictEqual data.length,  1
			t.strictEqual data[0].id,   'VBB'
			t.strictEqual data[0].name, 'Verkehrsverbund Brandenburg-Berlin'
			t.done()

		'lines': (t) -> s.lines(true, 248).then (data) ->
			t.strictEqual data.length,      1
			t.strictEqual data[0].id,       248
			t.strictEqual data[0].name,     '100'
			t.strictEqual data[0].type,     'bus'
			t.done()

		'stations': (t) -> s.stations(true, 9042101).then (data) ->
			t.strictEqual data.length,      1
			t.strictEqual data[0].id,       9042101
			t.strictEqual data[0].name,     'U Spichernstr. (Berlin)'
			t.done()

		'trips': (t) -> s.trips(true, 98239).then (data) ->
			t.strictEqual data.length,      1
			t.strictEqual data[0].id,       98239
			t.strictEqual data[0].lineId,   541 # U9
			t.done()
