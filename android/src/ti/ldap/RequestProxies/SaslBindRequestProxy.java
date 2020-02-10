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
import com.unboundid.ldap.sdk.SASLBindRequest;
import com.unboundid.util.SASLUtils;
import java.util.ArrayList;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import ti.ldap.ConnectionProxy;

@Kroll.proxy
public class SaslBindRequestProxy extends RequestProxy
{

	private static final String LCAT = "LDAP";

	public SaslBindRequestProxy(ConnectionProxy connection)
	{
		super("saslBind", connection);
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
		// dn is always ignored on sasl bind
		String dn = null;
		String passwd = args.optString("password", null);
		String mech = args.optString("mech", null);
		String realm = args.optString("realm", null);
		String authorizationId = args.optString("authorizationId", null);
		String authenticationId = args.optString("authenticationId", null);

		ArrayList<String> optionsList = new ArrayList<String>();
		if (authorizationId != null) {
			optionsList.add(SASLUtils.SASL_OPTION_AUTHZ_ID + "=" + authorizationId);
		}
		if (authenticationId != null) {
			optionsList.add(SASLUtils.SASL_OPTION_AUTH_ID + "=" + authenticationId);
		}
		if (realm != null) {
			optionsList.add(SASLUtils.SASL_OPTION_REALM + "=" + realm);
		}
		if (mech != null) {
			optionsList.add(SASLUtils.SASL_OPTION_MECHANISM + "=" + mech);
		}

		Log.d(LCAT, "LDAP SASLBind");

		try {
			// There is no support for asynchronous bind in the Unbound LDAP SDK.
			// All bind requests will be performed synchronously
			SASLBindRequest bindRequest = SASLUtils.createBindRequest(dn, passwd, mech, optionsList);
			BindResult bindResult = _connection.getLd().bind(bindRequest);
			return bindResult;
		} catch (LDAPException e) {
			Log.e(LCAT, "Error occurred in SASL bind: " + e.toString());
			return e.toLDAPResult();
		}
	}
}
