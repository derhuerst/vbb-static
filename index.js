'use strict'

const path         = require('path')
const fs           = require('fs')
const ndjson       = require('ndjson')
const filterStream = require('stream-filter')
const sink         = require('stream-sink')



const base = path.join(__dirname, 'data')

const pass = _ => true
const filterById = (id) => (data) =>
	!!(data && ('object' === typeof data) && data.id === id)
const filterByKeys = (pattern) => (data) => {
	if (!data || 'object' !== typeof data) return false
	for (let key in pattern) {
		if (!data.hasOwnProperty(key)) return false
		if (data[key] !== pattern[key]) return false
	}
	return true
}

const matcher = (pattern) =>
	( pattern === 'all' ? pass
	: ('object' === typeof pattern ? filterByKeys(pattern)
	: filterById(pattern)))



const reader = (file) => function (/* promised, filter */) {
	const args = Array.prototype.slice.call(arguments)
	let   filter = args.pop()
	let   promised = !!args.shift()

	filter = filterStream(matcher(filter))
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
