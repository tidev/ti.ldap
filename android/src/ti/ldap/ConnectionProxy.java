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

import ti.ldap.RequestProxies.RequestProxy;
import ti.ldap.RequestProxies.SaslBindRequestProxy;
import ti.ldap.RequestProxies.SearchRequestProxy;
import ti.ldap.RequestProxies.SimpleBindRequestProxy;

import android.util.Log;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.net.URI;
import java.net.URISyntaxException;
import javax.net.SocketFactory;

import com.unboundid.ldap.sdk.LDAPConnection;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPConnectionOptions;
import com.unboundid.util.ssl.SSLUtil;
import com.unboundid.util.ssl.TrustAllTrustManager;
import com.unboundid.util.ssl.TrustStoreTrustManager;


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
		close();
		super.release();
	}
	
	private void close() {
		if (_ld != null) {
			_ld.close();
			_ld = null;
			_bound = false;
		}
	}

	public LDAPConnectionOptions options()
	{
		return _options;
	}
	
	public void setBound(Boolean bound)
	{
		_bound = bound;
	}
	
	public LDAPConnection getLd()
	{
		return _ld;
	}

	public Boolean isBound()
	{
		return ((_ld != null) && _bound);
	}
	
	// Public proxy methods
	
    @Kroll.method
    public void connect(HashMap hm)
    {
        KrollDict args = new KrollDict(hm);

        int port = 389;
        String host = "";
        try {
            URI uri = new URI(args.optString("uri", "ldap://127.0.0.1"));
            // NOTE: Need to strip off scheme
            host = uri.getHost();
            port = uri.getPort();
            if (port == -1) {
                port = 389;
            }
        }
        catch (URISyntaxException e) {
            Log.e(LCAT, "Invalid uri specified: " + e.toString());
            return;
        }

        Log.d(LCAT, "LDAP initialize with host: " + host + " and port: " + port);

        SocketFactory socketFactory = startTLS();

		HashMap<String,Object> event = new HashMap<String,Object>();
		event.put("method", "connect");
			
		try {
       		_ld = new LDAPConnection(socketFactory, _options, host, port);
       		KrollFunction successCallback = (KrollFunction)args.get("success");
       		if (successCallback != null) {
    			event.put("uri", _ld.getConnectedAddress() + ":" + _ld.getConnectedPort());
    			successCallback.callAsync(getKrollObject(), event);
    			return;
       		}
        }
        catch (LDAPException e) {
            Log.e(LCAT, "Error occurred during LDAP initialization: " + e.toString());    
	        KrollFunction errorCallback = (KrollFunction)args.get("error");
	        if (errorCallback != null) {
	        	event.put("error", e.getResultCode().intValue());
	        	event.put("message", e.getMessage());
	        	errorCallback.callAsync(getKrollObject(), event);
	        }
        }
    }
    
    @Kroll.method
    public RequestProxy simpleBind(HashMap hm)
    {
    	KrollDict args = new KrollDict(hm);
    	
    	// Create the request that implements the bind and handles the callbacks
    	SimpleBindRequestProxy request = new SimpleBindRequestProxy(this, args);
    	request.sendRequest(args);
    	
    	return request;
    }
	
    @Kroll.method
    public RequestProxy saslBind(HashMap hm)
    {
    	KrollDict args = new KrollDict(hm);
    	
    	// Create the request that implements the bind and handles the callbacks
    	SaslBindRequestProxy request = new SaslBindRequestProxy(this, args);
    	request.sendRequest(args);
    	
    	return request;
    }
    
    @Kroll.method
    public SearchRequestProxy search(HashMap hm)
    {
    	KrollDict args = new KrollDict(hm);
    	
    	// Create the request that implements the bind and handles the callbacks
    	SearchRequestProxy request = new SearchRequestProxy(this, args);
    	request.sendRequest(args);
    	
    	return request;
    }
    
	@Kroll.method
	public void unBind()
	{
		close();
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
	
	private SocketFactory startTLS()
	{
		SSLUtil sslUtil;
		SocketFactory socketFactory = null;
		
        if (hasProperty("useTLS")) {
	        Boolean useTLS = TiConvert.toBoolean(getProperty("useTLS"));
	        if (useTLS) {
	        	String certFilePath = null;
	        	if (hasProperty("certFile")) {
	        		certFilePath = getFilePath(getProperty("certFile"));
	        		Log.i(LCAT, "Using certificate: " + certFilePath);
	        		sslUtil = new SSLUtil(new TrustStoreTrustManager(certFilePath));
	        	} else {
	        		sslUtil = new SSLUtil(new TrustAllTrustManager());
	        	}
	        	
        		try {
        			Log.i(LCAT, "Initializing TLS");
					socketFactory = sslUtil.createSSLSocketFactory();
					Log.i(LCAT, "TLS initialized");
				} catch (GeneralSecurityException e) {
					Log.e(LCAT, "Error initializing TLS: " + e.toString());
				}
	        }
        }
        
        return socketFactory;
	}
	
    // --- Public Proxy Properties
    
	@Kroll.setProperty
	public void setAsync(Boolean value)
	{
		_options.setUseSynchronousMode(!value);
	}
	
	@Kroll.getProperty
	public Boolean getAsync()
	{
		return !_options.useSynchronousMode();
	}
	
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
	public void setTimeout(int value)
	{
		// Negative values indicate no timeout is desired
		if (value < 0) {
			value = 0;
		}
		_options.setConnectTimeoutMillis(value);
		_options.setResponseTimeoutMillis(value);
	}
	
	@Kroll.getProperty
	public int getTimeout()
	{
		return _options.getConnectTimeoutMillis();
	}    
}