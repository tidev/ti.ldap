/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"

#define LDAP_DEPRECATED 1
#import "ldap.h"

@interface TiLdapConnectionProxy : TiProxy {
    LDAP        *ld;
}

-(LDAP*)ld;

@end
