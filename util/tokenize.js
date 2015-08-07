module.exports = function (name) {
	return name
	.replace(' Bhf', '')
	.replace(' (Berlin)', '')
	.replace('S+U ', '')
	.replace('S ', '')
	.replace(/[+-.()\[\]]/, ' ')
	.toLowerCase()
	.split(' ');
};
