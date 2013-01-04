# ti.ldap Module

## Desription

Provides access to LDAP directory servers by utilizing the [OpenLDAP library][openldap] (iOS) and [UnboundID LDAP SDK for Java][unboundid] (Android).

## Dependencies

This module requires Release 2.1.2 or newer of the Titanium SDK.

## Getting Started

View the [Using Titanium Modules](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_Titanium_Modules) document for instructions on getting
started with using this module in your application.

## Accessing the Module

Use `require` to access this module from JavaScript:

	var ldap = require("ti.ldap");

The `ldap` variable is a reference to the module object.

## LDAP Resources

Visit the [OpenLDAP][openldap] or [UnboundID LDAP SDK for Java][unboundid] websites for details on the LDAP implementations used in this module.

## LDAP Version

This module supports version 3 of the Lightweight Directory Access Protocol (LDAPv3).

## Interaction

The basic interaction for accessing an LDAP directory server is as follows:

1. Create a connection object (`createConnection`)
2. Connect to the server (`connect`)
3. Bind to the server (`simpleBind` or `saslBind`)
4. Search the directory (`search`)
5. Iterate on the search results (`firstEntry`, `nextEntry`, `firstAttribute`, `nextAttribute`)
6. Disconnect from the server (`disconnect`)

## Methods

### object createConnection(options)
Creates a new [connection][ldap.connection] object for interacting with an LDAP server.

* options[object]: An object that specifies properties for the connection.
    * sizeLimit[int]: The maximum size in bytes for an LDAP message that a connection will attempt to read from the directory server, or 0 if no limit will be enforced.
    * timeLimit[int]: The maximum length of time (in seconds) that a request should be allowed to continue before giving up.
	* useTLS[boolean]: Indicates whether to use TLS when sending requests to the LDAP server
	* certFile[string/Titanium.Blob/Titanium.Filesystem.File]: Path of the certificate file

#### Example
	var connection = ldap.createConnection({
		// Set global request time limit to 5 seconds
		timeLimit: 5
	});

## Constants

### Search Scope

#### SCOPE\_BASE
#### SCOPE\_ONELEVEL
#### SCOPE\_SUBTREE
#### SCOPE\_CHILDREN
#### SCOPE\_DEFAULT

### Search Attributes

#### ALL\_USER\_ATTRIBUTES
#### ALL\_OPERATIONAL\_ATTRIBUTES
#### NO\_ATTRS

## Usage

See the example application in the `example` folder of the module.

## Author

Jeff English

## Module History

View the [change log](changelog.html) for this module.

## Feedback and Support

Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=ti.ldap%20Module).

## License

Copyright(c) 2011-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[openldap]: http://www.openldap.org/
[unboundid]: https://www.unboundid.com/products/ldap-sdk/
[ldap.connection]: connection.html
