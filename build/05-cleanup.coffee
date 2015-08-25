path =			require 'path'
del =			require 'delete'





console.log 'Deleting `data/*.csv`:'

del.promise path.join __dirname, '../data/csv'
.then () ->
	console.log 'Done.'
.catch (err) ->
	console.err 'Failed.'
	console.err err.stack
