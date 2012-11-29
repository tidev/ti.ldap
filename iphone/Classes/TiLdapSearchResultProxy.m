/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSearchResultProxy.h"
#import "TiLdapEntryProxy.h"

@implementation TiLdapSearchResultProxy


-(id)initWithLDAPMessage:(LDAPMessage *)result_ callback:(KrollCallback *)callback_ connection:(TiLdapConnectionProxy *)connection_ pageContext:(id<TiEvaluator>)context
{
    if (self = [super _initWithPageContext:context]) {
        callback = [callback_ retain];
        searchResult = result_;
        connection = [connection_ retain];
    }
    
    return self;
}

-(id)initWithMsgId:(int)msgId_ callback:(KrollCallback *)callback_ connection:(TiLdapConnectionProxy *)connection_ pageContext:(id<TiEvaluator>)context{
    if (self = [super _initWithPageContext:context]) {
        callback = [callback_ retain];
        msgId = msgId_;
        searchResult = NULL;
        connection = [connection_ retain];
    }
    
    return self;
}

-(void)_destroy
{
	RELEASE_TO_NIL(callback);
    RELEASE_TO_NIL(connection);
    
    if (searchResult) {
        ldap_msgfree(searchResult);
        searchResult = NULL;
    }
    
	[super _destroy];
}

-(NSNumber*)getResult
{
    int result = ldap_result(connection.ld, msgId, 1, NULL, &searchResult);
    
    return NUMINT(result);
}

-(NSNumber*)countEntries:(id)args
{
    int result = ldap_count_entries(connection.ld, searchResult);
    if (result == -1) {
        NSLog(@"[ERROR] Error occurred in countEntries");
    }
    
    return NUMINT(result);
}

-(id)firstEntry:(id)args
{
    LDAPMessage *entry = ldap_first_entry(connection.ld, searchResult);
    if (entry == NULL) {
        NSLog(@"[ERROR] Error occurred in firstEntry");
        return nil;
    }
    
    TiLdapEntryProxy *entryProxy = [[[TiLdapEntryProxy alloc] initWithLDAPMessage:entry connection:connection pageContext:[self pageContext]] autorelease];
    
    return entryProxy;
}

-(id)nextEntry:(id)arg
{
    ENSURE_SINGLE_ARG(arg, TiLdapEntryProxy);
    
    LDAPMessage *entry = ldap_next_entry(connection.ld, [arg entry]);
    if (entry == NULL) {
        // NULL is returned when there are no more entries
        return nil;
    }
    
    TiLdapEntryProxy *entryProxy = [[[TiLdapEntryProxy alloc] initWithLDAPMessage:entry connection:connection pageContext:[self pageContext]] autorelease];
    
    return entryProxy;
}

@end
