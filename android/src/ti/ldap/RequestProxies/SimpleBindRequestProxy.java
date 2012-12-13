package ti.ldap.RequestProxies;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;

import com.unboundid.ldap.sdk.BindResult;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.SimpleBindRequest;

import android.util.Log;

import ti.ldap.ConnectionProxy;

@Kroll.proxy
public class SimpleBindRequestProxy extends RequestProxy {
	
	private static final String LCAT = "LDAP";
	
	public SimpleBindRequestProxy(ConnectionProxy connection, KrollDict args) {
		super("simpleBind", connection, args);
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
        }
        catch (LDAPException e) {
            Log.e(LCAT, "Error occurred in simple bind: " + e.toString());
            return null;
        }
	}
}
