path =			require 'path'
fs =			require 'fs'
moment =		require 'moment'
Q =				require 'q'
csv =			require 'csv-parse'
ndjson =		require 'ndjson'





parseDate = (date) ->
	return moment [
		date.substr 0,4
		date.substr 4,2
		date.substr 6,2
	].join '-'

# structure according to `moment().day()`
daysOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']





processSchedule = (schedules) ->
	return (data) ->
		start = parseDate(data.start_date).valueOf()
		end = parseDate(data.end_date).valueOf()
		schedule = schedules[data.service_id] =
			start:			start
			days: 			Math.round moment.duration(end - start).asDays()
			available:		[]
			notAvailable:	[]
		# todo: parse & apply days of week



processScheduleException = (schedules) ->
	return (data) ->
		schedule = schedules[data.service_id]
		# todo: there are records with `data.service_id === 0`. what about them?
		if not schedule or not schedule.start then return

		date = parseDate(data.date).valueOf()
		# if not schedule.available or not schedule.notAvailable
		# 	console.log schedule
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
			days[moment(date).day()].available.push day
		for date in schedule.notAvailable
			days[moment(date).day()].notAvailable.push day

		for day, name in days
			if day.available.length > day.notAvailable
				schedule[daysOfWeek[name]] =
					default:	true
					exceptions:	schedule.notAvailable
			else
				schedule[daysOfWeek[name]] =
					default:	false
					exceptions:	schedule.available

		delete schedule.available
		delete schedule.notAvailable
	return schedules





readCsv = (file, handle) ->
	task = Q.defer()

	parse = fs.createReadStream path.join __dirname, '../data', file
	.pipe csv
		columns:	true
	parse.on 'error', (err) ->
		console.error err.stack   # todo: remove?
		task.reject err
	parse.on 'data', handle
	parse.on 'end', task.resolve

	return task.promise



writeNdjson = (file) ->
	return (schedules) ->
		#return console.log schedules   # todo: remove
		task = Q.defer()

		stringify = ndjson.stringify()
		file.on 'error', (err) ->
			console.error err.stack   # todo: remove?
			task.reject err

		file = stringify
		.pipe fs.createWriteStream path.join __dirname, '../data', file

		file.on 'error', (err) ->
			console.error err.stack   # todo: remove?
			task.reject err
		file.on 'finish', (end) -> task.resolve()

		for id, schedule of schedules
			return console.log schedule   # todo: remove
			stringify.write schedule

		return task.promise





simplify = Q.defer()
schedules = {}

# read & accumulate data
readCsv 'calendar.csv', processSchedule schedules
.then () ->
	return readCsv 'calendar-exceptions.csv', processScheduleException schedules

# pass `schedules` in
.then () ->
	console.log schedules
	return schedules

# process data
.then computeDaysInSchedules
.catch (err) ->
	console.error err.stack

# write data
.then writeNdjson 'schedules.ndjson'
