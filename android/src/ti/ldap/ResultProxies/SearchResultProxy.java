package ti.ldap.ResultProxies;

import java.util.Iterator;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.unboundid.ldap.sdk.SearchResult;
import com.unboundid.ldap.sdk.SearchResultEntry;


@Kroll.proxy
public class SearchResultProxy extends KrollProxy {
	
	private final SearchResult _searchResult;
	private Iterator<SearchResultEntry> _iterator = null;
	
	public SearchResultProxy(SearchResult searchResult) {
		super();
		_searchResult = searchResult;
	}
	
	@Kroll.method
	public int countEntries()
	{
		int result = _searchResult.getEntryCount();
		
		return result;
	}
	
	@Kroll.method
	public EntryProxy firstEntry()
	{
		_iterator = _searchResult.getSearchEntries().iterator();
		if (_iterator.hasNext()) {
			SearchResultEntry entry = _iterator.next();
			EntryProxy entryProxy = new EntryProxy(entry);
			return entryProxy;
		}
		
		return null;
	}
	
	@Kroll.method
	public EntryProxy nextEntry()
	{
		if ((_iterator != null) && _iterator.hasNext()) {
			SearchResultEntry entry = _iterator.next();
			EntryProxy entryProxy = new EntryProxy(entry);
			return entryProxy;
		}
		
		return null;
	}
}