'use strict'

const path   = require('path')
const fs     = require('fs')
const ndjson = require('ndjson')
const Filter = require('streamfilter')
const sink   = require('stream-sink')



const base = path.join(__dirname, 'data')

const pass = _ => true
const filterById = (id) => (data) => data.id === id
const filterByKeys = (pattern) => (data) =>
	Object.keys(data).every((key) => data[key] === pattern[key])

const matcher = (pattern) =>
	( pattern === 'all' ? pass
	: ('object' === typeof pattern ? filterByKeys(pattern)
	: filterByKeys(pattern)))



const reader = (file) => (promised, filter) => {
	let args = Array.prototype.slice.call(arguments)
	filter = args.pop()
	promised = !!args.shift()

	filter = new Filter(matcher(filter), {objectMode: true})
	const reader = fs.createReadStream(path.join(base, file))
	const parser = ndjson.parse()
	reader.pipe(parser).pipe(filter)

	if (!promised) return filter
	else return new Promise((resolve, reject) => {

		reader.on('error', reject)
		parser.on('error', reject)
		filter.on('error', reject)

		const results = sink({objectMode: true})
		filter.pipe(results)

		results.on('error', reject)
		results.on('data', resolve)

	})
}



module.exports = {
	_: {pass, filterById, filterByKeys, matcher, reader},
	agencies:	reader('agencies.ndjson'),
	lines:		reader('lines.ndjson'),
	stations:	reader('stations.ndjson'),
	transfers:	reader('transfers.ndjson'),
	trips:		reader('trips.ndjson'),
	schedules:	reader('schedules.ndjson')
}
