var connection = null;
var loading = null;

exports.initialize = function(viewInfo) {
	connection = viewInfo.connection;
}

exports.cleanup = function() {
	connection = null;
	loading = null;
}

exports.create = function(win) {
	win.title = 'Simple Bind';
    
	win.add(Ti.UI.createLabel({
        text: 'Enter bind information',
        top: 10+u, left: 10+u, right: 10+u,
        color: '#000', textAlign: 'left',
        height: Ti.UI.SIZE || 'auto'
    }));

    var dn = Ti.UI.createTextField({
        hintText: 'dn (uid=joeuser,ou=people,dc=appcelerator,dc=com)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(dn);
    
    var password = Ti.UI.createTextField({
        hintText: 'password',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        passwordMask: true,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(password);
	
	var bindButton = Ti.UI.createButton({
		title: 'Bind',
		top: 10+u, left: 10+u, right: 10+u,
		height: 40+u
	});
	win.add(bindButton);

    bindButton.addEventListener('click', function(e) {
    	doBind({
    		dn: dn.value,
    		password: password.value
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

function doBind(data) {
	Ti.API.info("Timeout: " + connection.timeout);
	
	loading.show();
	connection.simpleBind({
    	dn: data.dn,
    	password: data.password,
        success: function(e) {
        	loading.hide();
        	require('navigator').push({
        		viewName: 'search',
        		connection: connection
        	});
        },
        error: function(e) {
        	loading.hide();
        	alert(e.message);
        }
    });
}