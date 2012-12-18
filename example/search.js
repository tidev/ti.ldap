var connection = null;
var ldap = require('ti.ldap');

exports.initialize = function(viewInfo) {
	connection = viewInfo.connection;
};

exports.cleanup = function() {
	connection = null;
};

exports.create = function(win) {
	win.title = 'Search';
    
	win.add(Ti.UI.createLabel({
        text: 'Enter search criteria',
        top: 10+u, left: 10+u, right: 10+u,
        color: '#000', textAlign: 'left',
        height: Ti.UI.SIZE || 'auto'
    }));

    var base = Ti.UI.createTextField({
        hintText: 'baseDn (ou=people,dc=appcelerator,dc=com)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(base);

    var filter = Ti.UI.createTextField({
        hintText: 'filter (objectClass=*)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(filter);
    

    var attrs = Ti.UI.createTextField({
        hintText: 'attrs (mobile, homePhone, title)',
        top: 10+u, left: 10+u, right: 10+u,
        height: 40+u,
        borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
        autocapitalization: Titanium.UI.TEXT_AUTOCAPITALIZATION_NONE
    });
    win.add(attrs);
    
	var searchButton = Ti.UI.createButton({
		title: 'Search',
		top: 10+u, left: 10+u, right: 10+u,
		height: 40+u
	});
	win.add(searchButton);

    searchButton.addEventListener('click', function(e) {
    	var attrsArray = attrs.value.length > 0 ? attrs.value.split(',') : null;
    	doSearch({
    		base: base.value,
    		filter: filter.value,
    		attrs: attrsArray
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
};

function doSearch(data) {
	loading.show();
   	connection.search({
   		base: data.base,
  		filter: data.filter,
   		attrs: data.attrs,
   		scope: ldap.SCOPE_CHILDREN,
        success: function(e) {
        	loading.hide();
        	require('navigator').push({
        		searchResult: e.result,
        		viewName: 'entries'
        	});
        },
        error: function(e) {
        	loading.hide();
        	alert(e.message);
        }
    });
};