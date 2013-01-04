# connection Object

## Desription

The `connection` object provides access to the LDAP operations. It is created by a call to the [createConnection][createconnection] method.

## Methods

### void connect(options, success, error)

Initializes a connection to the specified LDAP server, starting TLS if necessary.

* uri[string]: A string containing the uri of the server. (default: 'ldap://127.0.0.1:389')
* success[function]: A callback function that is executed if the request succeeds (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
* error[function]: A callback function that is executed if the request fails (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
    * error[int]: Error code
    * message[string]: Error message

#### Example
   	connection.connect({
			uri: "ldap://10.10.1.0:389"
		}, function(e) {
			// Success
			Ti.API.info(JSON.stringify(e));
		}, function(e) {
			// Error
			Ti.API.error(JSON.stringify(e));
			alert(e.message);
		});

### void disconnect()

Disconnects from the LDAP server.

### object simpleBind(options, success, error)

Performs an LDAP simple bind operation, which authenticates using a bind DN and password, and returns
a [request][connection.request] object.

* options[object]: An object that specifies properties for the request
	* dn[string]: The bind DN (optional)
	* password[string]: The password (optional)
* success[function]: A callback function that is executed if the request succeeds (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
* error[function]: A callback function that is executed if the request fails (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
    * error[int]: Error code
    * message[string]: Error message

#### Example
	connection.simpleBind({
			dn: dn.value,
			password: password.value
		}, function(e) {
			// Success
			Ti.API.info(JSON.stringify(e));
		}, function(e) {
			// Error
			Ti.API.error(JSON.stringify(e));
			alert(e.message);
		});

### object saslBind(options, success, error)

Performs an LDAP SASL bind request and returns a [request][connection.request] object. A SASL bind includes a SASL mechanism name and optional
set of credentials.

* options[object]: An object that specifies properties for the request
	* password[string]: The password to use (optional)
	* mech[string]: The name of the SASL mechanism to use (ANONYMOUS, CRAM-MD5, DIGEST-MD5, EXTERNAL, GSSAPI, PLAIN)
	* realm[string]: The realm for the request (optional)
	* authorizationId[string]: The authentication ID (optional)
	* authenticationId[string]: The authorization ID (optional)
* success[function]: A callback function that is executed if the request succeeds (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
* error[function]: A callback function that is executed if the request fails (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
    * error[int]: Error code
    * message[string]: Error message

#### Example
	connection.saslBind({
			mech: "DIGEST-MD5",
			password: password.value,
			authorizationId: authorizationId.value,
			authenticationId: authenticationId.value
		}, function(e) {
			// Success
			Ti.API.info(JSON.stringify(e));
		}, function(e) {
			// Error
			Ti.API.error(JSON.stringify(e));
			alert(e.message);
		});

### object search(options, success, error)

Performs a search on an LDAP directory server and returns a [request][connection.request] object. If the
search is successful, a [searchResult][searchrequest.searchresult] object is returned in the `result` property
of the `success` callback.

* options[object]: An object that specifies properties for the request
	* async[boolean]: Whether the request should be done asynchronously (optional) (default: true)
	* base[string]: The base DN to use
	* scope[constant]: The range of entries relative to the base DN that may be considered potential matches (optional). One of the following scope constants:
		* SCOPE\_BASE
        * SCOPE\_ONELEVEL
        * SCOPE\_SUBTREE
        * SCOPE\_CHILDREN
        * SCOPE\_DEFAULT
	* filter[string]: The criteria for determining which entries should be returned (optional)
	* attrs[array]: The set of attributes that should be included in matching entries (optional). If no attributes
	are provided, then the server will default to returning all user attributes. If a specified set of
	attributes is given, then only those attributes will be included. Values that may be included to
	indicate a special meaning include the following constants:
		* ALL\_USER\_ATTRIBUTES
    	* ALL\_OPERATIONAL\_ATTRIBUTES
    	* NO\_ATTRS
	* attrsOnly[boolean]: Whether matching entries should include only attribute names, or both attribute names and values (optional)
	* sizeLimit[int]: The maximum number of entries that should be returned from the search (optional)
	* timeLimit[int]: The maximum length of time in seconds that the server should spend processing the search (optional)
* success[function]: A callback function that is executed if the request succeeds (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
    * result[object]: A [searchResult][searchrequest.searchresult] object containing the results of the search
* error[function]: A callback function that is executed if the request fails (optional). Parameters passed to the callback function are:
    * method[string]: Name of the method called.
    * error[int]: Error code
    * message[string]: Error message

#### Example
   	var searchRequest = connection.search({
			async: true,
			base: base.value,
			scope: ldap.SCOPE_CHILDREN,
			filter: filter.value.length > 0 ? filter.value : null,
			attrs: attrs.value.length > 0 ? attrs.value.split(',') : null,
			async: asyncSwitch.value,
			timeLimit: timeLimit.value.length > 0 ? timeLimit.value : null
		}, function(e) {
			showSearchResult(e.result);
		}, function(e) {
			// Error
			Ti.API.error(JSON.stringify(e));
			alert(e.message);
		});

## Properties

* sizeLimit[int]: The maximum size in bytes for an LDAP message that a connection will attempt to read from the directory server, or 0 if no limit will be enforced.
* timeLimit[int]: The maximum length of time (in seconds) that a request should be allowed to continue before giving up.
* useTLS[boolean]: Indicates whether to use TLS when sending requests to the LDAP server
* certFile[string/Titanium.Blob/Titanium.Filesystem.File]: Path of the certificate file

## License

Copyright(c) 2011-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[createconnection]: index.html
[connection.request]: request.html
[searchrequest.searchresult]: searchresult.html