/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap;

import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.TiFileProxy;
import org.appcelerator.titanium.util.TiConvert;

import ti.ldap.RequestProxies.ConnectRequestProxy;
import ti.ldap.RequestProxies.RequestProxy;
import ti.ldap.RequestProxies.SaslBindRequestProxy;
import ti.ldap.RequestProxies.SearchRequestProxy;
import ti.ldap.RequestProxies.SimpleBindRequestProxy;

import android.util.Log;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import javax.net.SocketFactory;

import com.unboundid.ldap.sdk.LDAPConnection;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPConnectionOptions;
import com.unboundid.util.ssl.SSLUtil;
import com.unboundid.util.ssl.TrustAllTrustManager;
import com.unboundid.util.ssl.TrustStoreTrustManager;
import com.unboundid.ldap.sdk.LDAPURL;


@Kroll.proxy(creatableInModule=LdapModule.class, propertyAccessors = { "useTLS", "certFile" })

public class ConnectionProxy extends KrollProxy
{
	// Standard Debugging variables
	private static final String LCAT = "LDAP";
	
    private LDAPConnection _ld = null;
    
    private LDAPConnectionOptions _options = new LDAPConnectionOptions();
    private Boolean _bound = false;
    
	// Constructor
	public ConnectionProxy()
	{
		super();
	}
	
	@Override
	public void release()
	{
		disconnect();
		super.release();
	}

	@Override
	public void handleCreationDict(KrollDict props)
	{
		super.handleCreationDict(props);

        if (!props.containsKey("useTLS")) {
        	setProperty("useTLS", false);
        }
	}
	
	public LDAPConnection getLd()
	{
		return _ld;
	}
	
	public void setLd(LDAPConnection ld)
	{
		_ld = ld;
	}
	
	public void setBound(Boolean bound)
	{
		_bound = bound;
	}

	public Boolean isBound()
	{
		return ((_ld != null) && _bound);
	}
	
	public LDAPConnectionOptions options()
	{
		return _options;
	}
	
	// Public proxy methods
	
    @Kroll.method
    public void connect(HashMap hm, @Kroll.argument(optional=true) KrollFunction success, @Kroll.argument(optional=true) KrollFunction error)
    {
    	// Create the request that implements the connection and handles the callbacks
    	ConnectRequestProxy request = new ConnectRequestProxy(this);
    	request.sendRequest(hm, success, error);
    }
    	   
	@Kroll.method
	public void disconnect()
	{
		if (_ld != null) {
			_ld.close();
			_ld = null;
			_bound = false;
		}
	}
	
    @Kroll.method
    public RequestProxy simpleBind(HashMap hm, @Kroll.argument(optional=true) KrollFunction success, @Kroll.argument(optional=true) KrollFunction error)
    {
    	// Create the request that implements the bind and handles the callbacks
    	SimpleBindRequestProxy request = new SimpleBindRequestProxy(this);
    	request.sendRequest(hm, success, error);
    	
    	return request;
    }
	
    @Kroll.method
    public RequestProxy saslBind(HashMap hm, @Kroll.argument(optional=true) KrollFunction success, @Kroll.argument(optional=true) KrollFunction error)
    {
    	// Create the request that implements the bind and handles the callbacks
    	SaslBindRequestProxy request = new SaslBindRequestProxy(this);
    	request.sendRequest(hm, success, error);
    	
    	return request;
    }
    
    @Kroll.method
    public SearchRequestProxy search(HashMap hm, @Kroll.argument(optional=true) KrollFunction success, @Kroll.argument(optional=true) KrollFunction error)
    {
    	// Create the request that implements the bind and handles the callbacks
    	SearchRequestProxy request = new SearchRequestProxy(this);
    	request.sendRequest(hm, success, error);
    	
    	return request;
    }
	
	// --- TLS Support Functions
	
	private String getFilePath(Object url)
	{
		String filePath = null;
		if (url instanceof TiFileProxy) {
			TiFileProxy tiFile = (TiFileProxy) url;
			filePath = tiFile.getBaseFile().getNativeFile().getAbsolutePath();
		} else if (url instanceof String) {
			filePath = resolveUrl(null, (String) url);
		} else if (url instanceof TiBlob) {
			TiBlob blob = (TiBlob) url;
			if (blob.getType() == TiBlob.TYPE_FILE) {
				filePath = blob.getFile().getNativePath();
			}
		} 	
		
		return filePath;
	}
	
	public SocketFactory startTLS()
	{
		SSLUtil sslUtil;
		SocketFactory socketFactory = null;
		
        if (hasProperty("useTLS")) {
	        Boolean useTLS = TiConvert.toBoolean(getProperty("useTLS"));
	        if (useTLS) {
	        	String certFilePath = null;
	        	if (hasProperty("certFile")) {
	        		certFilePath = getFilePath(getProperty("certFile"));
	        		Log.d(LCAT, "Using certificate: " + certFilePath);
	        		sslUtil = new SSLUtil(new TrustStoreTrustManager(certFilePath));
	        	} else {
	        		sslUtil = new SSLUtil(new TrustAllTrustManager());
	        	}
	        	
        		try {
        			Log.d(LCAT, "Initializing TLS");
					socketFactory = sslUtil.createSSLSocketFactory();
					Log.d(LCAT, "TLS initialized");
				} catch (GeneralSecurityException e) {
					Log.e(LCAT, "Error initializing TLS: " + e.toString());
				}
	        }
        }
        
        return socketFactory;
	}
	
    // --- Public Proxy Properties
    
	@Kroll.setProperty
	public void setSizeLimit(int value)
	{
		_options.setMaxMessageSize(value);
	}
	
	@Kroll.getProperty
	public int getSizeLimit()
	{
		return _options.getMaxMessageSize();
	}
	
	@Kroll.setProperty
	public void setTimeLimit(int value)
	{
		// Negative values indicate no timeLimit is desired
		if (value < 0) {
			value = 0;
		}
		_options.setConnectTimeoutMillis(value * 1000);
		_options.setResponseTimeoutMillis(value * 1000);
	}
	
	@Kroll.getProperty
	public int getTimeLimit()
	{
		return _options.getConnectTimeoutMillis() / 1000;
	}    
}