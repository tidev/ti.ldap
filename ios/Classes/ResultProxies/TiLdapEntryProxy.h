/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import "TiLdapSearchResultProxy.h"

@interface TiLdapEntryProxy : TiProxy {
@private
    TiLdapSearchResultProxy *_searchResult;
    LDAPMessage *_entry;
    BerElement *_ber;
}

+(TiLdapEntryProxy*)entryWithLDAPMessage:(LDAPMessage*)entry searchResult:(TiLdapSearchResultProxy*)searchResult;

-(id)initWithLDAPMessage:(LDAPMessage*)entry searchResult:(TiLdapSearchResultProxy*)searchResult;

-(LDAPMessage*)entry;

@end
