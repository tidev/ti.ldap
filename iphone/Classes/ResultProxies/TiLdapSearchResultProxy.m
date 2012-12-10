/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSearchResultProxy.h"
#import "TiLdapEntryProxy.h"

@implementation TiLdapSearchResultProxy

-(id)initWithLDAPMessage:(LDAPMessage*)searchResult connection:(TiLdapConnectionProxy*)connection
{
    if (self = [super _initWithPageContext:[connection pageContext]]) {
        _searchResult = searchResult;
        _connection = [connection retain];
    }
    
    return self;
}

+(TiLdapSearchResultProxy*)searchResultWithLDAPMessage:(LDAPMessage*)searchResult connection:(TiLdapConnectionProxy*)connection
{
    return [[[self alloc] initWithLDAPMessage:searchResult connection:connection] autorelease];
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

-(TiLdapConnectionProxy*)connection
{
    return _connection;
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
    
    TiLdapEntryProxy *entryProxy = [TiLdapEntryProxy entryWithLDAPMessage:entry searchResult:self];
    
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
    
    TiLdapEntryProxy *entryProxy = [TiLdapEntryProxy entryWithLDAPMessage:entry searchResult:self];
    
    return entryProxy;
}

@end
