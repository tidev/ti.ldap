# request Object

## Desription

The `request` object provides access to an outstanding asynchronous request. It is created by a call to the [connection.simpleBind][connection.simplebind],
 [connection.saslBind][connection.saslbind], or [connection.search][connection.search] methods.

## Methods

### void abandon()

Sends a LDAP abandon request for an outstanding asynchronous operation in progress.

#### Example
	searchRequest.abandon();

## License

Copyright(c) 2011-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[connection.simplebind]: connection.html
[connection.saslbind]: connection.html
[connection.search]: connection.html