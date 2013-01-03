# searchResult Object

## Desription

The `searchResult` object provides access to the result of a `search` request.
It is created by a call to the [connection.search][connection.search] method and is returned in the `result` property
of the success callback.

## Methods

### int countEntries()

Retrieves the number of matching entries for the search operation

#### Example
   	var count = searchResult.countEntries();

### object firstEntry()

Retrieves the first [entry][searchresult.entry] in the search results list. Returns null if there are no entries.

#### Example
	var entry = searchResult.firstEntry();

### object nextEntry()

Retrieves the next [entry][searchresult.entry] in the search results list. Returns null if there are no more entries.

#### Example
	var entry = searchResult.nextEntry();

## License

Copyright(c) 2011-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[searchresult.entry]: entry.html
[connection.search]: connection.html