/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import "TiLdapModule.h"

#define LDAP_DEPRECATED 1
#import "ldap.h"

@implementation TiLdapModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"4cf02ff0-f57e-4643-b0bd-98077e9956ec";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.ldap";
}

// Constants

MAKE_SYSTEM_PROP(SUCCESS, LDAP_SUCCESS);

MAKE_SYSTEM_PROP(SCOPE_BASE, LDAP_SCOPE_BASE);
MAKE_SYSTEM_PROP(SCOPE_ONELEVEL, LDAP_SCOPE_ONELEVEL);
MAKE_SYSTEM_PROP(SCOPE_SUBTREE, LDAP_SCOPE_SUBTREE);
MAKE_SYSTEM_PROP(SCOPE_CHILDREN, LDAP_SCOPE_CHILDREN);
MAKE_SYSTEM_PROP(SCOPE_DEFAULT, LDAP_SCOPE_DEFAULT);

MAKE_SYSTEM_STR(ALL_USER_ATTRIBUTES, LDAP_ALL_USER_ATTRIBUTES);
MAKE_SYSTEM_STR(ALL_OPERATIONAL_ATTRIBUTES, LDAP_ALL_OPERATIONAL_ATTRIBUTES);
MAKE_SYSTEM_STR(NO_ATTRS, LDAP_NO_ATTRS);

@end
