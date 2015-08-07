Data =	require('./Data');





module.exports = function (dir) {
	instance = Object.create(Data);
	instance.init(dir);
	return instance;
};
