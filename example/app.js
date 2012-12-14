// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white',
	layout: 'vertical'
});

var btnSimple = Ti.UI.createButton({
	title: 'Connect Simple',
	top: 4,
	width: 200,
	height: 40
});
win.add(btnSimple);
btnSimple.addEventListener('click', doSimple);

var btnSASL = Ti.UI.createButton({
	title: 'Connect SASL',
	top: 4,
	width : 200,
	height: 40
});
win.add(btnSASL);
btnSASL.addEventListener('click', doSASL);

var btnSearch = Ti.UI.createButton({
	title: "Search",
	top: 4,
	width: 200,
	height: 40
});
win.add(btnSearch);
btnSearch.addEventListener('click', doSearch);

var btnUnbind = Ti.UI.createButton({
	title: "Disconnect",
	top: 4,
	width: 200,
	height: 40
});
win.add(btnUnbind);
btnUnbind.addEventListener('click', doUnbind);

win.open();

var ldap = require('ti.ldap');
Ti.API.info("module is => " + ldap);

var connection = null;

function doSimple() {
	connection = ldap.createConnection({
		//useTLS: true,
		//certFile: Titanium.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "ca-certs.pem"),
		//certFile: Ti.Filesystem.resourcesDirectory + "ca-certs.pem",
		//timeout: 2000,
		async: true
	});
	
	Ti.API.info("useTLS: " + connection.useTLS);
	Ti.API.info("certFile: " + connection.certFile);
	Ti.API.info("async: " + connection.async);
	Ti.API.info("sizeLimit: " + connection.sizeLimit);
	Ti.API.info("timeout: " + connection.timeout);
	
	connection.connect({
		uri: "ldap://50.18.181.104:389",
		success: doBind,
		error: logError
	});
}

function doBind() {
	connection.simpleBind({
		//dn: "uid=jenglish,ou=people,dc=appcelerator,dc=com",
		//password: "password",
		success: logSuccess,
		error: logError
	});
}

function doUnbind() {
	connection.unBind();
	connection = null;
}

function logSuccess (e)
{
	Ti.API.info("SUCCESS: " + JSON.stringify(e));
}

function logError (e) {
	Ti.API.error("ERROR: " + JSON.stringify(e));
}

function doSearch() {

	Ti.API.info(">>>Search 1");
	connection.search({
		base: "dc=appcelerator,dc=com",
		scope: ldap.SCOPE_SUBTREE,
		filter: "(ou=people)",
		async: true,
		success: showSearchResults1,
		error: logError
	});

	Ti.API.info(">>>Search 2");
	connection.search({
		base: "ou=people,dc=appcelerator,dc=com",
		scope: ldap.SCOPE_CHILDREN,
		async: true,
		success: showSearchResults2,
		error: logError
	});
	
	Ti.API.info(">>>Search 3");
	connection.search({
		base: "ou=people,dc=appcelerator,dc=com",
		scope: ldap.SCOPE_CHILDREN,
		filter: "(cn=Jeff English)",
		attrs: [ 'mobile', 'homePhone', 'title', 'mail'],
		async: true,
		success: showSearchResults3,
		error: logError
	});
	
	
}



function doSASL() {
	connection = ldap.createConnection({
		useTLS: true,
		async: true
		//tlsCACertFile: Titanium.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "ca-certs.pem")
	});	
	
	connection.connect({
		//uri: "ldap://63.140.112.162", //bindlebinaries.com
		uri: "ldap://50.18.181.104:389",
		success: doSaslBind,
		error: logError
	})
}

function doSaslBind() {	
	connection.saslBind({
		mech: "PLAIN",
		//mech: "DIGEST-MD5",
		authenticationId: "u:jeffenglish",
		//authorizationId: "dn:Jeff English",
		//realm: "", 
		password: "password",
		success: logSuccess,
		error: logError
	});
}

function showSearchResults(e)
{
	Ti.API.info(">>> ShowSearchResults");
	Ti.API.info(JSON.stringify(e));
	
	var searchResult = e.result;
	if (searchResult) {
		var count = searchResult.countEntries();
		Ti.API.info("Search Result Count: " + count);
		
		var entry = searchResult.firstEntry();
		
		while (entry) {
			var dn = entry.getDn();
			Ti.API.info("dn: " + dn);
			
			var attribute = entry.firstAttribute();
			while (attribute) {
				Ti.API.info("attribute: " + attribute);
				//var values = entry.getValues(attribute);
				var values = entry.getValuesLen(attribute);
				if (values) {
					for (var i=0; i<values.length; i++) {
						Ti.API.info("  blob length: " + values[i].length);
						Ti.API.info("  blob mimeType: " + values[i].mimeType);
						Ti.API.info("  value: " + values[i]);
					}
				}
				
				attribute = entry.nextAttribute();
			}
			
			entry = searchResult.nextEntry(entry);
		}
	}
}

function showSearchResults1(e)
{
	Ti.API.info(">>>>> 1 <<<<<");
	showSearchResults(e);
}
function showSearchResults2(e)
{
	Ti.API.info(">>>>> 2 <<<<<");
	showSearchResults(e);
}
function showSearchResults3(e)
{
	Ti.API.info(">>>>> 3 <<<<<");
	showSearchResults(e);
}


