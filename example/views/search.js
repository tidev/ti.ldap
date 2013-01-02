/*
 * View for specifying search information
 */

var ldap = require('ti.ldap');	
var platform = require('utility/platform');

var searchRequest = null;
var connection = null;
var loading = null;
var u = platform.u;

exports.initialize = function(viewInfo) {
	// The connection property contains the connection proxy
	connection = viewInfo.connection;
};

exports.cleanup = function() {
	if (searchRequest) {
		searchRequest.abandon();
		searchRequest = null;
	}
	connection = null;
	loading = null;
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
    
    var timeLimit = Ti.UI.createTextField({
    	hintText: 'timeLimit (seconds)',
    	top: 10+u, left: 10+u, right: 10+u,
    	height: 40+u,
    	borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED
    });
    win.add(timeLimit);
    
    var view = Ti.UI.createView({
    	backgroundColor: 'white',
    	top: 10+u, left: 10+u,	right: 10+u,
    	height: 40+u,
    	layout: 'horizontal'
  	});
	var asyncLabel = Ti.UI.createLabel({
		text: 'Asynchronous:',
		height: Ti.UI.SIZE || 'auto',
		width: Ti.UI.SIZE || 'auto',
		top: 0, left: 0
	});
	var asyncSwitch = Ti.UI.createSwitch({
		value: true,
		isSwitch: true,
		top: 0, left: 4+u,
		height: Ti.UI.SIZE || 'auto',
		width: Ti.UI.SIZE || 'auto'
	});
	view.add(asyncLabel);
	view.add(asyncSwitch);
	win.add(view);
    
	var searchButton = Ti.UI.createButton({
		title: 'Search',
		top: 10+u, left: 10+u, right: 10+u,
		height: 40+u
	});
	win.add(searchButton);

    searchButton.addEventListener('click', function() {
    	doSearch({
    		base: base.value,
   			scope: ldap.SCOPE_CHILDREN,
     		filter: filter.value.length > 0 ? filter.value : null,
    		attrs: attrs.value.length > 0 ? attrs.value.split(',') : null,
    		async: asyncSwitch.value,
    		timeLimit: timeLimit.value.length > 0 ? timeLimit.value : null
    	});
    });
    
	loading = platform.addActivityIndicator(win, "Searching...");
};

function doSearch(data) {
	loading.show();
   	searchRequest = connection.search(data,
   		function(e) {
    		loading.hide();
    		searchRequest = null;
    		require('utility/navigator').push({
    			searchResult: e.result,
    			viewName: 'entries'
    		})
    	},
    	function(e) {
    		loading.hide();
    		searchRequest = null;
    		alert(e.message);
    	});
}