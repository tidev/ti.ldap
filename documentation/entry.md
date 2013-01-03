# entry Object

## Desription

The `entry` object provides access to the entry object retrieved from a call to [searchResult.firstEntry][searchresult.firstentry]
or [searchResult.nextEntry][searchresult.nextentry].

## Methods

### string getDn()

Retrieves the DN for this search entry

#### Example
   	var DN = entry.getDn();

### string firstAttribute()

Retrieves the name of the first attribute for the entry. Returns null if there are no attributes.

#### Example
	var attribute = entry.firstAttribute();

### string nextAttribute()

Retrieves the name of the next attribute for the entry. Returns null if there are no more attributes.

#### Example
	var attribute = entry.nextAttribute();

### array getValues(name)

Retrieves an array of string values for the specified attribute. Returns null if there are no values.

* name[string]: The name of the attribute to retrieve

#### Example
	var values = entry.getValues(attributeName);
	if (values) {
		for (var i=0; i<values.length; i++) {
			Ti.API.info(attributeName + ":" + values[i]);
		}
	}

### array getValuesLen(name)

Retrieves an array of Titanium.Blob values for the specified attribute. This method should be used when the
attribute values are binary in nature and not suitable to be returned as an array of strings. Returns null
if there are no values.

* name[string]: The name of the attribute to retrieve

#### Example
	var values = entry.getValuesLen(attributeName);
	if (values) {
		for (var i=0; i<values.length; i++) {
			var blob = values[i];
			Ti.API.info(attributeName + ":" + blob.size;
		}
	}

## License

Copyright(c) 2011-2013 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[searchresult.firstentry]: searchresult.html
[searchresult.nextentry]: searchresult.html