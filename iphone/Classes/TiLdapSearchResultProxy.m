/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSearchResultProxy.h"
#import "TiLdapEntryProxy.h"

@implementation TiLdapSearchResultProxy

-(id)initWithLDAPMessage:(LDAPMessage *)result connection:(TiLdapConnectionProxy *)connection {
    if (self = [super _initWithPageContext:[connection pageContext]]) {
        _connection = [connection retain];
        _searchResult = result;
    }
    
    return self;
}

+(id)resultWithLDAPMessage:(LDAPMessage*)result connection:(TiLdapConnectionProxy*)connection
{
    return [[[self alloc] initWithLDAPMessage:result connection:connection] autorelease];
}

-(void)_destroy
{
    RELEASE_TO_NIL(_connection);
    
    if (_searchResult) {
        ldap_msgfree(_searchResult);
        _searchResult = NULL;
    }
    
	[super _destroy];
}

-(NSNumber*)countEntries:(id)args
{
    int result = ldap_count_entries(_connection.ld, _searchResult);
    if (result == -1) {
        NSLog(@"[ERROR] Error occurred in countEntries");
    }
    
    return NUMINT(result);
}

-(id)firstEntry:(id)args
{
    LDAPMessage *entry = ldap_first_entry(_connection.ld, _searchResult);
    if (entry == NULL) {
        NSLog(@"[ERROR] Error occurred in firstEntry");
        return nil;
    }
    
    TiLdapEntryProxy *entryProxy = [TiLdapEntryProxy entryWithLDAPMessage:entry connection:_connection];
    
    return entryProxy;
}

-(id)nextEntry:(id)arg
{
    ENSURE_SINGLE_ARG(arg, TiLdapEntryProxy);
    
    LDAPMessage *entry = ldap_next_entry(_connection.ld, [arg entry]);
    if (entry == NULL) {
        // NULL is returned when there are no more entries
        return nil;
    }
    
    TiLdapEntryProxy *entryProxy = [TiLdapEntryProxy entryWithLDAPMessage:entry connection:_connection];
    
    return entryProxy;
}

@end
