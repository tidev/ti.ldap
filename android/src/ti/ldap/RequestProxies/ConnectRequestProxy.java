/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap.RequestProxies;

import android.util.Log;
import com.unboundid.ldap.sdk.LDAPConnection;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.LDAPURL;
import com.unboundid.ldap.sdk.ResultCode;
import java.util.HashMap;
import javax.net.SocketFactory;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import ti.ldap.ConnectionProxy;

@Kroll.proxy
public class ConnectRequestProxy extends RequestProxy
{

	private static final String LCAT = "LDAP";

	public ConnectRequestProxy(ConnectionProxy connection)
	{
		super("connect", connection);
	}

	@Override
	public LDAPResult execute(KrollDict args, Boolean async)
	{
		String host;
		int port;
		try {
			LDAPURL url = new LDAPURL(args.optString("uri", "ldap://127.0.0.1:389"));
			host = url.getHost();
			port = url.getPort();
		} catch (LDAPException e) {
			Log.e(LCAT, "Invalid uri specified: " + e.toString());
			return null;
		}

		Log.d(LCAT, "LDAP initialize with host: " + host + " and port: " + port);

		try {
			SocketFactory socketFactory = _connection.startTLS();

			LDAPConnection ld = new LDAPConnection(socketFactory, _connection.options(), host, port);
			_connection.setLd(ld);

			return new LDAPResult(0, ResultCode.SUCCESS);
		} catch (LDAPException e) {
			Log.e(LCAT, "Error occurred during LDAP initialization: " + e.toString());
			return e.toLDAPResult();
		}
	}
}
