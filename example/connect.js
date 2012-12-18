var connection = null;
var ldap = null;
var loading = null;

exports.initialize = function(viewInfo) {
	ldap = require('ti.ldap');	
}

exports.cleanup = function() {
	ldap = null;
	connection = null;
	loading = null;
}

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

    connect.addEventListener('click', function(e) {
    	doConnect({
    		uri: uri.value
    	});
    });
    
	loading = Ti.UI.createActivityIndicator({
		height:50, width:50,
		color:'white',
		backgroundColor:'black', borderRadius:10,
		style:Ti.UI.iPhone.ActivityIndicatorStyle.BIG
	});
	if (Ti.Platform.name === 'iPhone OS') {
		win.add(loading);
	}
}

function doConnect(data) {
	loading.show();
	connection = ldap.createConnection({
		timeout: 5000
	});
   	connection.connect({
    	uri: data.uri,
        success: function(e) {
        	loading.hide();
        	require('navigator').push({
        		viewName: 'bind',
        		connection: connection
        	});
        },
        error: function(e) {
        	loading.hide();
         	alert(e.message);
        }
    });
}
