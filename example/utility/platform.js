/*
 * Platform-specific helpers
 */
const IOS = (Ti.Platform.osname === 'iphone' || Ti.Platform.osname === 'ipad');

exports.addActivityIndicator = function (win, message) {
	var activityIndicator = Ti.UI.createActivityIndicator({
		height: Ti.UI.SIZE || 'auto',
		width: Ti.UI.SIZE || 'auto',
		borderRadius: 10,
		style: IOS ? Ti.UI.iPhone.ActivityIndicatorStyle.DARK : Ti.UI.ActivityIndicatorStyle.DARK,
		message: message
	});

	if (IOS || (Ti.version >= '3.0.0')) {
		win.add(activityIndicator);
	}

	return activityIndicator;
};

exports.u = Ti.Android ? 'dp' : 0;
