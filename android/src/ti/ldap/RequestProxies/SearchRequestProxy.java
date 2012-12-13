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

@Kroll.proxy
public class SearchRequestProxy extends RequestProxy {
	
	private static final String LCAT = "LDAP";
	
	public SearchRequestProxy(ConnectionProxy connection, KrollDict args) {
		super("search", connection, args);
	}
	
	@Override
	public void release()
	{
		super.release();
	}
	
	private class localAsyncSearchResultListener implements AsyncSearchResultListener
	{
		private static final long serialVersionUID = 1L;
		
		private final SearchRequestProxy _proxy;
		private final List<SearchResultEntry> _entryList;
		private final List<SearchResultReference> _referenceList;
		
		public localAsyncSearchResultListener(SearchRequestProxy proxy) {
			super();
			_proxy = proxy;
			_entryList = new ArrayList<SearchResultEntry>();
			_referenceList = new ArrayList<SearchResultReference>();
		}
		
		@Override
		public void searchResultReceived(AsyncRequestID requestID, SearchResult searchResult) 
		{
			final ResultCode rc = searchResult.getResultCode();
			if (rc != ResultCode.SUCCESS) {
				handleError(searchResult);
			} else {
				_proxy._ldapResult = new SearchResult(searchResult.getMessageID(),
						searchResult.getResultCode(),
						searchResult.getDiagnosticMessage(),
						searchResult.getMatchedDN(),
						searchResult.getReferralURLs(),
						_entryList,
						_referenceList,
						_entryList.size(),
						_referenceList.size(),
						searchResult.getResponseControls());
				_proxy.handleSuccess(null);
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
		Log.i(LCAT, ">>> handleSuccess for Search <<<");
		
		SearchResult searchResult = (SearchResult)_ldapResult;

        for (SearchResultEntry entry : searchResult.getSearchEntries())
        {
            Log.w(LCAT,"Search Result: " + entry.toString());
        }
		super.handleSuccess(null);
	}
	
	@Override
	public LDAPResult execute(KrollDict args, Boolean async)
	{
		if (!isConnectionBound()) {
			return new LDAPResult(-1, ResultCode.UNAVAILABLE);
		}
		
		String base = args.optString("base", "");
		int scope = args.optInt("scope", LdapModule.SCOPE_DEFAULT);
		String filter = args.optString("filter", "*");

        Object obj = args.get("attrs");
        ArrayList<String> attrs = null;
        if (obj != null) {
            if (obj.getClass().isArray()) {
                Object[] arr = (Object[])obj;
                attrs = new ArrayList<String>();
                for (int i=0; i<arr.length; i++) {
                    attrs.add((String)arr[i]);
                }
            }
        }

        Boolean attrsOnly = args.optBoolean("attrsOnly", false);
        int sizeLimit = args.optInt("sizeLimit", 0);
        int timeout = args.optInt("timeout", 0);	// ms
        
        try {
        	SearchRequest searchRequest;
        	if (async) {
        		searchRequest = new SearchRequest(new localAsyncSearchResultListener(this), base, SearchScope.definedValueOf(scope), filter);
        	} else {
	            searchRequest = new SearchRequest(base, SearchScope.definedValueOf(scope), filter);
        	}
	        searchRequest.setTypesOnly(attrsOnly);
	        searchRequest.setSizeLimit(sizeLimit);
	        searchRequest.setTimeLimitSeconds((timeout + 999) / 1000);
	        if (attrs != null) {
	            searchRequest.setAttributes(attrs);
	        }
	
	        if (async) {
	        	_ldapResult = null;
	        	_requestId = _connection.getLd().asyncSearch(searchRequest);
	        } else {
	        	_ldapResult = _connection.getLd().search(searchRequest);
	        }
	        
	        return _ldapResult;
        }
        catch (LDAPSearchException lse) {
            Log.e(LCAT,"Error occurred in search: " + lse.toString());
            return null;
        }
        catch  (LDAPException e) {
        	Log.e(LCAT,"Error occurred in search: " + e.toString());
        	return null;
        }
	}
}