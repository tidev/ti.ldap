/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap.RequestProxies;

import android.util.Log;
import com.unboundid.ldap.sdk.BindResult;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.SimpleBindRequest;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import ti.ldap.ConnectionProxy;

@Kroll.proxy
public class SimpleBindRequestProxy extends RequestProxy
{

	private static final String LCAT = "LDAP";

	public SimpleBindRequestProxy(ConnectionProxy connection)
	{
		super("simpleBind", connection);
	}

	@Override
	public void handleSuccess(Object result)
	{
		_connection.setBound(true);
		super.handleSuccess(result);
	}

	@Override
	public LDAPResult execute(KrollDict args, Boolean async)
	{
		String dn = args.optString("dn", null);
		String passwd = args.optString("password", null);

		Log.d(LCAT, "LDAP simpleBind with dn: " + dn);

		try {
			// There is no support for asynchronous bind in the Unbound LDAP SDK.
			// All bind requests will be performed synchronously
			SimpleBindRequest bindRequest = new SimpleBindRequest(dn, passwd);
			BindResult bindResult = _connection.getLd().bind(bindRequest);
			return bindResult;
		} catch (LDAPException e) {
			Log.e(LCAT, "Error occurred in simple bind: " + e.toString());
			return e.toLDAPResult();
		}
	}
}
