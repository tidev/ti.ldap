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
	title: 'Simple',
	top: 4,
	width: 200,
	height: 40
});
win.add(btnSimple);
btnSimple.addEventListener('click', doSimple);

var btnSASL = Ti.UI.createButton({
	title: 'SASL',
	top: 4,
	width : 200,
	height: 40
});
win.add(btnSASL);
btnSASL.addEventListener('click', doSASL);
win.open();

// TODO: write your module tests here
var ldap = require('ti.ldap');
Ti.API.info("module is => " + ldap);


function doSimple() {
	//BUGBUG: Should these continue to be single APIs or properties on the connection proxy that
	//are evaluated at the time of bind?
	var connection = ldap.createConnection({
		success: function () {},
		error: function() {}
	});
	
	var result;
	result = connection.initialize({
		uri: "ldap://50.18.181.104:389"
	});
	
	result = connection.setOption(connection.OPT_PROTOCOL_VERSION, connection.VERSION3);
	
	result = connection.simpleBind({} );
	
	var searchResult1 = connection.search({
		dn: "dc=appcelerator,dc=com",
		scope: connection.SCOPE_SUBTREE,
		filter: "(ou=people)"
	});
	showSearchResults(searchResult1);
	
	var searchResult2 = connection.search({
		dn: "ou=people,dc=appcelerator,dc=com",
		scope: connection.SCOPE_CHILDREN
	});
	showSearchResults(searchResult2);
	
	var searchResult3 = connection.search({
		dn: "ou=people,dc=appcelerator,dc=com",
		scope: connection.SCOPE_CHILDREN,
		filter: "(cn=Kailun Shi)",
		attrs: [ 'mobile', 'homePhone', 'title', 'mail']
	});
	showSearchResults(searchResult3);
	
	connection.unBind();
}

function doSASL() {
	//BUGBUG: Should these continue to be single APIs or properties on the connection proxy that
	//are evaluated at the time of bind?
	var connection = ldap.createConnection({
		success: function () {},
		error: function() {}
	});
	
	var result;

	result = connection.initialize({
		uri: "ldap://10.0.1.80:389"
	});
	
	result = connection.setOption(connection.OPT_PROTOCOL_VERSION, connection.VERSION3);
	
	var caCert = Titanium.Filesystem.getFile(Ti.Filesystem.resourcesDirectory, "ca-certs.pem");
	if (caCert && caCert.exists()) {
		result = connection.setOption(connection.OPT_X_TLS_CACERTFILE, caCert);
	}
	
	result = connection.saslBind({
		//mech: "DIGEST-MD5",
		mech: "PLAIN",
		user: "diradmin",
		//realm: 
		passwd: "s3c4et99&n",
		cert: true
	});
	
	var searchResult1 = connection.search({
		dn: "dc=appcelerator,dc=com",
		scope: connection.SCOPE_SUBTREE,
		filter: "(ou=people)"
	});
	showSearchResults(searchResult1);
	
	connection.unBind();
}

function showSearchResults(searchResult)
{
	if (searchResult) {
		var count = searchResult.countEntries();
		Ti.API.info("Search Result Count: " + count);
		
		var entry = searchResult.firstEntry();
		
		while (entry) {
			var dn = entry.getDn();
			Ti.API.info("dn: " + dn);
			
			var attribute = entry.firstAttribute();
			while (attribute) {
				//var values = entry.getValues(attribute);
				var values = entry.getValuesLen(attribute);
				for (var i=0; i<values.length; i++) {
					Ti.API.info("blob length: " + values[i].length);
					Ti.API.info("blob mimeType: " + values[i].mimeType);
					Ti.API.info(attribute + " : " + values[i]);
				}
				
				attribute = entry.nextAttribute();
			}
			
			entry = searchResult.nextEntry(entry);
		}
	}
}




