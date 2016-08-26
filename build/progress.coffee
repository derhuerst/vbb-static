i = 0

progress = () ->
	i = (i + 1) % 10000
	if i is 0 then process.stdout.write '.'
	null

module.exports = progress
