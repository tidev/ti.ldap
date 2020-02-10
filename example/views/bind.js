/*
 * View for specifying bind information
 */

var platform = require('utility/platform');

var connection = null;
var loading = null;
var u = platform.u;

exports.initialize = function (viewInfo) {
	// The connection property contains the connection proxy
	connection = viewInfo.connection;
};

exports.cleanup = function () {
	// Disconnect when leaving the bind window
	connection.disconnect();
	connection = null;
	loading = null;
};

exports.create = function (win) {
	win.title = 'Simple Bind';

	win.add(Ti.UI.createLabel({
		text: 'Enter bind information',
		top: 10 + u, left: 10 + u, right: 10 + u,
		color: '#000', textAlign: 'left',
		height: Ti.UI.SIZE || 'auto'
	}));

	var dn = Ti.UI.createTextField({
		hintText: 'dn (uid=joeuser,ou=people,dc=appcelerator,dc=com)',
		top: 10 + u, left: 10 + u, right: 10 + u,
		height: 40 + u,
		borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
		autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
	});
	win.add(dn);

	var password = Ti.UI.createTextField({
		hintText: 'password',
		top: 10 + u, left: 10 + u, right: 10 + u,
		height: 40 + u,
		passwordMask: true,
		borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
		autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
	});
	win.add(password);

	var bindButton = Ti.UI.createButton({
		title: 'Bind',
		top: 10 + u, left: 10 + u, right: 10 + u,
		height: 40 + u
	});
	win.add(bindButton);

	bindButton.addEventListener('click', function () {
		doBind({
			dn: dn.value,
			password: password.value
		});
	});

	loading = platform.addActivityIndicator(win, 'Binding...');
};

function doBind(data) {
	loading.show();
	connection.simpleBind(data,
		function () {
			loading.hide();
			require('../utility/navigator').push({
				viewName: 'search',
				connection: connection
			});
		},
		function (e) {
			loading.hide();
			// eslint-disable-next-line no-alert
			alert(e.message);
		});
}
