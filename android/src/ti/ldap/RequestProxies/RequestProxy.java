/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap.RequestProxies;

import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import android.util.Log;

import com.unboundid.ldap.sdk.AsyncRequestID;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.ResultCode;

import ti.ldap.ConnectionProxy;

@Kroll.proxy
public class RequestProxy extends KrollProxy {
	
	private static final String LCAT = "LDAP";
	
	protected final ConnectionProxy _connection;
	private final String _method;
	protected KrollFunction _successCallback;
	protected KrollFunction _errorCallback;
	protected AsyncRequestID _asyncRequestId = null;
	protected LDAPResult _ldapResult;
	
	public RequestProxy(final String method, final ConnectionProxy connection) {
		super();
		_method = method;
		_connection = connection;
		_successCallback = null;
		_errorCallback = null;
	}
	
	public Boolean isConnectionValid()
	{
		if (_connection != null) {
			return true;
		}
		handleError(-1, "Connection is not valid");
		
		return false;
	}
	
	public Boolean isConnectionBound()
	{
		// Verify that we have not only a connection but that it is also bound
		if (isConnectionValid()) {
			if (_connection.isBound()) {
				return true;
			}
			handleError(-2, "Connection is not bound");
		}
		
		return false;
	}
	
	public void handleSuccess(Object result)
	{
		if (_successCallback != null) {
			HashMap<String,Object> event = new HashMap<String,Object>();
			event.put("method", _method);
			event.put("result", result);
			_successCallback.callAsync(_connection.getKrollObject(), event);
		}
	}
	
	public void handleError(int errorCode, String errorMessage)
	{
		if (_errorCallback != null) {
			HashMap<String,Object> event = new HashMap<String,Object>();
			event.put("method", _method);
			event.put("error", errorCode);
			event.put("message", errorMessage);
			_errorCallback.callAsync(_connection.getKrollObject(), event);
		}
	}
	
	public void handleError(LDAPResult result)
	{
		String message = result.getDiagnosticMessage();
		if (message == null) {
			message = result.getResultCode().getName();
		}
		handleError(result.getResultCode().intValue(), message);
	}
	
	public LDAPResult execute(KrollDict args, Boolean async)
	{
		return new LDAPResult(-1, ResultCode.SUCCESS);
	}
	
	public void sendRequest(final HashMap<String, Object> hm, final KrollFunction success, final KrollFunction error)
	{		
		KrollDict args = new KrollDict(hm);
		_successCallback = success;
		_errorCallback = error;
		
		// Determine if this is a synchronous or asynchronous request
		Boolean async = args.optBoolean("async", false);
		
		_asyncRequestId = null;
		LDAPResult result = execute(args, async);
		
		if (async && (_asyncRequestId != null)) {
			Log.d(LCAT, "Successfully initiated asynchronous request");
		} else if (result == null) {
			handleError(-1, "Unknown error occurred");
		} else if (result.getResultCode() == ResultCode.SUCCESS) {
			handleSuccess(null);
		} else {
			handleError(result);
		}
	}
	
	@Kroll.method
	public void abandon()
	{
		if (_asyncRequestId != null) {
			try {
			_connection.getLd().abandon(_asyncRequestId);
			_asyncRequestId = null;
			} catch (LDAPException e) {
	            Log.e(LCAT, "Error occurred in abandon: " + e.toString());
			}
		}
	}
}