/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

package ti.ldap;

import com.unboundid.ldap.sdk.ResultCode;
import com.unboundid.ldap.sdk.SearchRequest;
import com.unboundid.ldap.sdk.SearchScope;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;

@Kroll.module(name = "Ldap", id = "ti.ldap")
public class LdapModule extends KrollModule
{
	public LdapModule()
	{
		super();
	}

	@Kroll.constant
	public static final int SUCCESS = ResultCode.SUCCESS_INT_VALUE;

	@Kroll.constant
	public static final int SCOPE_BASE = SearchScope.BASE_INT_VALUE;
	@Kroll.constant
	public static final int SCOPE_ONELEVEL = SearchScope.ONE_INT_VALUE;
	@Kroll.constant
	public static final int SCOPE_SUBTREE = SearchScope.SUB_INT_VALUE;
	@Kroll.constant
	public static final int SCOPE_CHILDREN = SearchScope.SUBORDINATE_SUBTREE_INT_VALUE;
	@Kroll.constant
	public static final int SCOPE_DEFAULT = -1;

	@Kroll.constant
	public static final String ALL_USER_ATTRIBUTES = SearchRequest.ALL_USER_ATTRIBUTES;
	@Kroll.constant
	public static final String ALL_OPERATIONAL_ATTRIBUTES = SearchRequest.ALL_OPERATIONAL_ATTRIBUTES;
	@Kroll.constant
	public static final String NO_ATTRS = SearchRequest.NO_ATTRIBUTES;

	@Override
	public String getApiName()
	{
		return "Ti.LDAP";
	}
}
