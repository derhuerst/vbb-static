#!env coffee

path =     require 'path'
pFs =      require 'fs-promise'
Download = require 'download'





base = path.join __dirname, '../data/csv'

module.exports = ->

	pFs.mkdir base

	.then -> new Promise (resolve, reject) ->
		console.log 'Downloading & extracting GTFS zip file.'
		new Download extract: true, mode: '755'
			.get 'https://codeload.github.com/derhuerst/vbb-gtfs/zip/master'
			.dest base
			.run (err) -> if err then reject err else resolve()

	.catch (err) -> console.error(err.stack)
	.then -> console.log 'Done'
