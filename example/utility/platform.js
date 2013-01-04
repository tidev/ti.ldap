/*
 * Platform-specific helpers
 */

exports.addActivityIndicator = function(win, message) {
	var activityIndicator = Ti.UI.createActivityIndicator({
		height: Ti.UI.SIZE || 'auto',
		width: Ti.UI.SIZE || 'auto',
		borderRadius: 10,
	  	style: (Ti.Platform.name === 'iPhone OS' ? Ti.UI.iPhone.ActivityIndicatorStyle.DARK : Ti.UI.ActivityIndicatorStyle.DARK),
		message: message
	});
	
	if ((Ti.Platform.name === 'iPhone OS') || (Ti.version >= "3.0.0")) {
		win.add(activityIndicator);
	}	
	
	return activityIndicator;
}

exports.u = Ti.Android != undefined ? 'dp' : 0;