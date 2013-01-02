/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap.RequestProxies;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;

import com.unboundid.ldap.sdk.AsyncRequestID;
import com.unboundid.ldap.sdk.AsyncSearchResultListener;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.LDAPSearchException;
import com.unboundid.ldap.sdk.ResultCode;
import com.unboundid.ldap.sdk.SearchRequest;
import com.unboundid.ldap.sdk.SearchResult;
import com.unboundid.ldap.sdk.SearchResultEntry;
import com.unboundid.ldap.sdk.SearchResultReference;
import com.unboundid.ldap.sdk.SearchScope;

import android.util.Log;
import java.util.ArrayList;
import java.util.List;

import ti.ldap.ConnectionProxy;
import ti.ldap.LdapModule;
import ti.ldap.ResultProxies.SearchResultProxy;

@Kroll.proxy
public class SearchRequestProxy extends RequestProxy {
	
	private static final String LCAT = "LDAP";
	
	public SearchRequestProxy(ConnectionProxy connection) {
		super("search", connection);
	}
	
	private class localAsyncSearchResultListener implements AsyncSearchResultListener
	{
		private static final long serialVersionUID = 1L;
		
		private final List<SearchResultEntry> _entryList;
		private final List<SearchResultReference> _referenceList;
		
		public localAsyncSearchResultListener(SearchRequestProxy proxy) {
			super();
			_entryList = new ArrayList<SearchResultEntry>();
			_referenceList = new ArrayList<SearchResultReference>();
		}
		
		@Override
		public void searchResultReceived(AsyncRequestID requestID, SearchResult searchResult) 
		{
			// The search request has finally finished.
			final ResultCode rc = searchResult.getResultCode();
			if (rc != ResultCode.SUCCESS) {
				handleError(searchResult);
			} else {
				_ldapResult = new SearchResult(searchResult.getMessageID(),
						searchResult.getResultCode(),
						searchResult.getDiagnosticMessage(),
						searchResult.getMatchedDN(),
						searchResult.getReferralURLs(),
						_entryList,
						_referenceList,
						_entryList.size(),
						_referenceList.size(),
						searchResult.getResponseControls());
				handleSuccess(null);
			}
		}

		@Override
		public void searchEntryReturned(SearchResultEntry searchEntry) {
			_entryList.add(searchEntry);
		}

		@Override
		public void searchReferenceReturned(SearchResultReference searchReference) {
			_referenceList.add(searchReference);
		}
	}
	
	@Override
	public void handleSuccess(Object result)
	{
		SearchResultProxy searchResultProxy = new SearchResultProxy((SearchResult)_ldapResult);

		super.handleSuccess(searchResultProxy);
	}
	
	@Override
	public LDAPResult execute(KrollDict args, Boolean async)
	{
		if (!isConnectionBound()) {
			return new LDAPResult(-1, ResultCode.UNAVAILABLE);
		}
		
		String base = "";
		if (args.containsKeyAndNotNull("base")) {
			base = args.getString("base");
		}
		int scope = LdapModule.SCOPE_DEFAULT;
        if (args.containsKeyAndNotNull("scope")) {
        	scope = args.getInt("scope");
        }
		
		// Use the same default value that openLDAP uses when a filter is not provided
        String filter = "(objectClass=*)";
        if (args.containsKeyAndNotNull("filter")) {
        	filter = args.getString("filter");
        }

        ArrayList<String> attrs = null;
        if (args.containsKeyAndNotNull("attrs")) {
            Object obj = args.get("attrs");
            if (obj.getClass().isArray()) {
                Object[] arr = (Object[])obj;
                attrs = new ArrayList<String>();
                for (int i=0; i<arr.length; i++) {
                    attrs.add((String)arr[i]);
                }
            }
        }

        Boolean attrsOnly = false;
        if (args.containsKeyAndNotNull("attrsOnly")) {
        	attrsOnly = args.getBoolean("attrsOnly");
        }
        
        int sizeLimit = 0;
        if (args.containsKeyAndNotNull("sizeLimit")) {
        	sizeLimit = args.getInt("sizeLimit");
        }
        
        int timeLimit = 0;
        if (args.containsKeyAndNotNull("timeLimit")) {
        	timeLimit = args.getInt("timeLimit");	// seconds
        }

        try {
        	SearchRequest searchRequest;
        	if (async) {
        		searchRequest = new SearchRequest(new localAsyncSearchResultListener(this), base, SearchScope.definedValueOf(scope), filter);
        	} else {
	            searchRequest = new SearchRequest(base, SearchScope.definedValueOf(scope), filter);
        	}
	        searchRequest.setTypesOnly(attrsOnly);
	        searchRequest.setSizeLimit(sizeLimit);
	        searchRequest.setTimeLimitSeconds(timeLimit);
	        if (attrs != null) {
	            searchRequest.setAttributes(attrs);
	        }

	        if (async) {
	        	_ldapResult = null;
	        	_asyncRequestId = _connection.getLd().asyncSearch(searchRequest);
	        } else {
	        	_ldapResult = _connection.getLd().search(searchRequest);
	        }
	        
	        return _ldapResult;
        }
        catch (LDAPSearchException lse) {
            Log.e(LCAT,"Error occurred in search: " + lse.toString());
            return lse.toLDAPResult();
        }
        catch  (LDAPException e) {
        	Log.e(LCAT,"Error occurred in search: " + e.toString());
        	return e.toLDAPResult();
        }
	}
}