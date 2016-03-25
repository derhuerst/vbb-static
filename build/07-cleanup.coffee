#!env coffee

path =   require 'path'
rimraf = require 'rimraf-promise'

module.exports = ->

	dir = path.join __dirname, '../data/csv'
	rimraf dir
	.then -> console.log "Deleted #{dir}."
