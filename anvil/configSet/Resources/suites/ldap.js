/*
 * Appcelerator Titanium Mobile
 * Copyright (c) 2011-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

module.exports = new function ()
{
	var finish;
	var valueOf;
	var ldap;
	var LDAP_SERVER = Ti.App.Properties.getString("ldap.server");
	this.init = function (testUtils)
	{
		finish = testUtils.finish;
		valueOf = testUtils.valueOf;
		ldap = require('ti.ldap');
	};

	this.name = "ldap";

	// Test that module is loaded
	this.testModule = function (testRun)
	{
		// Verify that the module is defined
		valueOf(testRun, ldap).shouldBeObject();
		finish(testRun);
	};

	// Test that all of the namespace APIs are available
	this.testApi = function (testRun)
	{
		// Verify that all of the methods are exposed
		finish(testRun);
	};

	// Test that all of the properties are defined
	this.testProperties = function (testRun)
	{
		// Verify that all of the properties are exposed
		finish(testRun);
	};

	// Test that all of the constants are defined
	this.testConstants = function (testRun)
	{
		// Verify that all of the constants are exposed
		valueOf(testRun, ldap.SUCCESS).shouldNotBeUndefined();

		valueOf(testRun, ldap.SCOPE_BASE).shouldNotBeUndefined();
		valueOf(testRun, ldap.SCOPE_ONELEVEL).shouldNotBeUndefined();
		valueOf(testRun, ldap.SCOPE_SUBTREE).shouldNotBeUndefined();
		valueOf(testRun, ldap.SCOPE_CHILDREN).shouldNotBeUndefined();
		valueOf(testRun, ldap.SCOPE_DEFAULT).shouldNotBeUndefined();

		valueOf(testRun, ldap.ALL_USER_ATTRIBUTES).shouldBeString();
		valueOf(testRun, ldap.ALL_OPERATIONAL_ATTRIBUTES).shouldBeString();
		valueOf(testRun, ldap.NO_ATTRS).shouldBeString();

		finish(testRun);
	};

	// Test that all of the methods of the connection are defined
	this.testConnectionApi = function (testRun)
	{
		var connection = ldap.createConnection({});
		valueOf(testRun, connection).shouldBeObject();
		valueOf(testRun, connection.connect).shouldBeFunction();
		valueOf(testRun, connection.disconnect).shouldBeFunction();
		valueOf(testRun, connection.simpleBind).shouldBeFunction();
		valueOf(testRun, connection.saslBind).shouldBeFunction();
		valueOf(testRun, connection.search).shouldBeFunction();

		finish(testRun);
	};

	// Test that all of the properties of the connection are accessible
	this.testConnectionProperties = function (testRun)
	{
		var connection = ldap.createConnection({});
		valueOf(testRun, connection).shouldBeObject();
		valueOf(testRun, connection.useTLS).shouldBeFalse();
		valueOf(testRun, connection.certFile).shouldBeUndefined();
		valueOf(testRun, connection.sizeLimit).shouldBeNumber();
		valueOf(testRun, connection.timeLimit).shouldBeNumber();

		finish(testRun);
	};

	// Test a connection
	this.testConnectSuccess = function (testRun)
	{
		var connection = ldap.createConnection({});
		connection.connect({
				uri: LDAP_SERVER
			}, function (e) {
				valueOf(testRun, e.method).shouldBe("connect");
				valueOf(testRun, e.result).shouldBeUndefined();
				finish(testRun);
			}, function () {
				valueOf(testRun, false).shouldBeTrue();
			}
		);
	};

	// Test a connection failure
	this.testConnectFailure = function (testRun)
	{
		var connection = ldap.createConnection({
			timeLimit:5
		});
		connection.connect({
				uri: "1.1.1.1"
			}, function ()	{
				valueOf(testRun, false).shouldBeTrue();
			}, function (e)	{
				valueOf(testRun, e.method).shouldBe("connect");
				valueOf(testRun, e.error).shouldBeNumber();
				valueOf(testRun, e.message).shouldBeString();
				finish(testRun);
			}
		);
	};

	// Test a simpleBind with no authentication
	this.testSimpleBindNoAuthentication = function (testRun)
	{
		var connection = ldap.createConnection({});
		var bind = function () {
			connection.simpleBind({
				}, function (e)	{
					valueOf(testRun, e.method).shouldBe("simpleBind");
					valueOf(testRun, e.result).shouldBeUndefined();
					finish(testRun);
				}, function () {
					valueOf(testRun, false).shouldBeTrue();
				}
			);
		};

		connection.connect({
				uri: LDAP_SERVER
			}, function (e)	{
				valueOf(testRun, e.method).shouldBe("connect");
				valueOf(testRun, e.result).shouldBeUndefined();
				bind();
			}, function ()	{
				valueOf(testRun, false).shouldBeTrue();
			}
		);
	};

	// Test a search
	this.testSearch = function (testRun)
	{
		var connection = ldap.createConnection({});
		var checkEntries = function (result) {
			valueOf(testRun, result.countEntries).shouldBeFunction();
			valueOf(testRun, result.firstEntry).shouldBeFunction();
			valueOf(testRun, result.nextEntry).shouldBeFunction();
			valueOf(testRun, result.countEntries()).shouldBeNumber();
			var entry = result.firstEntry();
			valueOf(testRun, entry).shouldBeObject();
			valueOf(testRun, entry.getDn).shouldBeFunction();
			valueOf(testRun, entry.firstAttribute).shouldBeFunction();
			valueOf(testRun, entry.nextAttribute).shouldBeFunction();
			valueOf(testRun, entry.getValues).shouldBeFunction();
			valueOf(testRun, entry.getValuesLen).shouldBeFunction();
			valueOf(testRun, entry.getDn()).shouldBeString();
			var attribute = entry.firstAttribute();
			valueOf(testRun, attribute).shouldBeString();
			valueOf(testRun, entry.getValues(attribute)).shouldBeArray();
			attribute = entry.nextAttribute();
			valueOf(testRun, attribute).shouldBeString();
			valueOf(testRun, entry.getValuesLen(attribute)).shouldBeArray();
			finish(testRun);
		};

		var search = function () {
			connection.search({
					base: "ou=people,dc=appcelerator,dc=com",
					scope: ldap.SCOPE_CHILDREN,
					async: true
				}, function (e)	{
					valueOf(testRun, e.method).shouldBe("search");
					valueOf(testRun, e.result).shouldBeObject();
					checkEntries(e.result);
				}, function () {
					valueOf(testRun, false).shouldBeTrue();
				}
			);
		};

		var bind = function () {
			connection.simpleBind({
				}, function (e)	{
					valueOf(testRun, e.method).shouldBe("simpleBind");
					valueOf(testRun, e.result).shouldBeUndefined();
					search();
				}, function () {
					valueOf(testRun, false).shouldBeTrue();
				}
			);
		};

		connection.connect({
				uri:LDAP_SERVER
			}, function (e)	{
				valueOf(testRun, e.method).shouldBe("connect");
				valueOf(testRun, e.result).shouldBeUndefined();
				bind();
			}, function () {
				valueOf(testRun, false).shouldBeTrue();
			}
		);
	};

	// Test disconnect
	this.testDisconnect = function (testRun)
	{
		var connection = ldap.createConnection({});
		var disconnect = function () {
			connection.disconnect();
			finish(testRun);
		};

		connection.connect({
				uri:LDAP_SERVER
			}, function (e)	{
				valueOf(testRun, e.method).shouldBe("connect");
				valueOf(testRun, e.result).shouldBeUndefined();
				disconnect();
			}, function ()	{
				valueOf(testRun, false).shouldBeTrue();
			}
		);
	};

	// Test that all of the properties of the connection are accessible
	this.testConnectionPropSetGet = function (testRun)
	{
		var connection = ldap.createConnection({});

		connection.useTLS = true;
		valueOf(testRun, connection.useTLS).shouldBeTrue();
		connection.useTLS = false;
		valueOf(testRun, connection.useTLS).shouldBeFalse();

		connection.certFile = "test";
		valueOf(testRun, connection.certFile).shouldBe("test");

		connection.sizeLimit = 100;
		valueOf(testRun, connection.sizeLimit).shouldBe(100);

		connection.timeLimit = 50;
		valueOf(testRun, connection.timeLimit).shouldBe(50);

		finish(testRun);
	};

	// Populate the array of tests based on the 'hammer' convention
	this.tests = require('hammer').populateTests(this);
};
