#!env coffee

path =   require 'path'
fs =     require 'fs'
moment = require 'moment'
csv =    require 'csv-parse'
ndjson = require 'ndjson'

progress = require './progress'





parseDate = (date) -> moment [
	date.substr 0,4
	date.substr 4,2
	date.substr 6,2
].join '-'

# structure according to `moment().day()`
daysOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']





processSchedule = (schedules) -> (data) ->
	progress()
	start = parseDate(data.start_date).valueOf()
	end = parseDate(data.end_date).valueOf()
	schedule = schedules[data.service_id] =
		id:				parseInt data.service_id
		start:			start
		days: 			Math.round moment.duration(end - start).asDays()
		available:		[]
		notAvailable:	[]
	# todo: parse & apply days of week



processScheduleException = (schedules) -> (data) ->
	progress()
	schedule = schedules[data.service_id]
	# todo: there are records with `data.service_id === 0`. what about them?
	if not schedule or not schedule.start then return

	date = parseDate(data.date).valueOf()
	if not (data.exception_type - 1)
		schedule.available.push date
	else schedule.notAvailable.push date



computeDaysInSchedules = (schedules) ->
	for id, schedule of schedules
		days = [   # structure according to `moment().day()`
			{ available: [], notAvailable: [] }   # sunday
			{ available: [], notAvailable: [] }   # monday
			{ available: [], notAvailable: [] }   # tuesday
			{ available: [], notAvailable: [] }   # wednesday
			{ available: [], notAvailable: [] }   # thursday
			{ available: [], notAvailable: [] }   # friday
			{ available: [], notAvailable: [] }   # saturday
		]
		for date in schedule.available
			days[moment(date).day()].available.push date
		for date in schedule.notAvailable
			days[moment(date).day()].notAvailable.push date

		for day, name in days
			if day.available.length > day.notAvailable.length
				schedule[daysOfWeek[name]] =
					default:	true
					exceptions:	day.notAvailable
			else
				schedule[daysOfWeek[name]] =
					default:	false
					exceptions:	day.available

		delete schedule.available
		delete schedule.notAvailable
	return schedules





readCsv = (file, handle) -> new Promise (resolve, reject) ->
	parser = csv columns: true
	parser.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	parser.on 'data', handle
	parser.on 'end', resolve

	fs.createReadStream path.join __dirname, '../data/csv', file
	.pipe parser



writeNdjson = (file) -> (schedules) -> new Promise (resolve, reject) ->
	stringify = ndjson.stringify()
	stringify.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err

	writeStream = fs.createWriteStream path.join __dirname, '../data', file
	writeStream.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		reject err
	writeStream.on 'finish', resolve

	stringify.pipe writeStream
	for id, schedule of schedules
		delete schedule.start
		delete schedule.days
		stringify.write schedule
	stringify.end()





showError = (err) ->
	console.error err.stack
	process.exit err.code || 1

module.exports = ->

	schedules = {}
	console.log 'Merging calendar.csv & calendar-exceptions.csv into schedule.ndjson:'

	# read & accumulate data
	readCsv 'calendar.csv', processSchedule schedules
	.catch showError
	.then -> readCsv 'calendar-exceptions.csv', processScheduleException schedules
	.catch showError

	# pass `schedules` in
	.then -> schedules

	# process data
	.then computeDaysInSchedules
	.catch showError

	# write data
	.then writeNdjson 'schedules.ndjson'
	.catch (err) -> console.error err.stack

	.then -> console.log 'Done.'
