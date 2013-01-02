/*
 * View for specifying connection information
 */

var ldap = require('ti.ldap');
var platform = require('utility/platform');

var connection = null;
var loading = null;
var u = platform.u;

exports.initialize = function() {
};

exports.cleanup = function() {
	connection = null;
	loading = null;
};

exports.create = function(win) {
	win.title = 'Connect';
	
	win.add(Ti.UI.createLabel({
        text: 'Enter server connection information',
        top: 10+u, left: 10+u, right: 10+u,
        color: '#000', textAlign: 'left',
        height: Ti.UI.SIZE || 'auto'
    }));

    var uri = Ti.UI.createTextField({
        hintText: 'host (ldap://127.0.0.1:389)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(uri);
 
    var connect = Ti.UI.createButton({
        title: 'Connect',
        top: 10+u, left: 10+u, right: 10+u, bottom: 10+u,
        height: 40+u
    });
    win.add(connect);

    connect.addEventListener('click', function() {
    	doConnect({
    		uri: uri.value
    	});
    });
    
	loading = platform.addActivityIndicator(win, "Connecting...");
};

function doConnect(data) {
	loading.show();
	connection = ldap.createConnection({
		// Set global request timelimit to 5 seconds
		timeLimit: 5
	});
   	connection.connect(data,
   		function() {
        	loading.hide();
         	require('utility/navigator').push({
        		viewName: 'bind',
        		connection: connection
        	});
        },
        function(e) {
        	loading.hide();
         	alert(e.message);
        });
}
