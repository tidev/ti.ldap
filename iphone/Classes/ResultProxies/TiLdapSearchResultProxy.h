/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import "TiLdapConnectionProxy.h"

@interface TiLdapSearchResultProxy : TiProxy {
    TiLdapConnectionProxy *_connection;
    LDAPMessage *_searchResult;
    LDAPMessage *_entry;
}

+(TiLdapSearchResultProxy*)searchResultWithLDAPMessage:(LDAPMessage*)searchResult connection:(TiLdapConnectionProxy*)connection;

-(id)initWithLDAPMessage:(LDAPMessage*)searchResult connection:(TiLdapConnectionProxy*)connection;

-(TiLdapConnectionProxy*)connection;

@end
