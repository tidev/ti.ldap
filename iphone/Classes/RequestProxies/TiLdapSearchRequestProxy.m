/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSearchRequestProxy.h"
#import "TiLdapSearchResultProxy.h"
#import "TiUtils.h"

@implementation TiLdapSearchRequestProxy

+(id)requestWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initRequest:@"search" connection:connection args:args] autorelease];
}

// Override and create search result proxy
-(void)handleSuccess:(id)result
{
    // Create a search result proxy to be returned in the callback
    TiLdapSearchResultProxy *searchResultProxy = [TiLdapSearchResultProxy searchResultWithLDAPMessage:_ldapMessage connection:_connection];

    // NOTE: Since the search result proxy is taking ownership of the _ldapMessage we need to
    // reset the pointer to null after creating the proxy so that the request proxy cleanup
    // logic does not free the _ldapMessage.
    _ldapMessage = NULL;
    
    [super handleSuccess:searchResultProxy];
}

-(int)execute:(NSDictionary*)args async:(BOOL)async
{
    if (![self isConnectionBound]) {
        return -1;
    }
    
    NSString *base = [TiUtils stringValue:@"base" properties:args];
    int scope = [TiUtils intValue:@"scope" properties:args def:LDAP_SCOPE_DEFAULT];
    NSString *filter = [TiUtils stringValue:@"filter" properties:args def:nil];
    
    // Attributes are passed as an array of strings. Convert to an array of UTF8 strings.
    NSArray *inAttrs = [args objectForKey:@"attrs"];
    int count = [inAttrs count];
    const char** attrs = NULL;
    if (count > 0) {
        attrs = malloc(sizeof(const char*) * (count+1));
        if (attrs) {
            for (int i=0; i<count; i++) {
                attrs[i] = [[inAttrs objectAtIndex:i] UTF8String];
            }
            // Null terminate the array
            attrs[count] = NULL;
        }
    }
    
    BOOL attrsOnly = [TiUtils boolValue:@"attrsOnly" properties:args def:0];

    //Timeout is specified in ms
    id timeout = [args objectForKey:@"timeout"];
    struct timeval *timeVal = NULL;
    if (timeout) {
        timeVal = (struct timeval *)malloc(sizeof(struct timeval));
        timeVal->tv_sec = [TiUtils intValue:@"sec" properties:timeout def:1];
        timeVal->tv_usec = [TiUtils intValue:@"usec" properties:timeout def:0];
    }
    
    int sizeLimit = [TiUtils intValue:@"sizeLimit" properties:args def:0];
    
    int result;
    
    if (async) {
        result = ldap_search_ext(_connection.ld,
                                 [base UTF8String],
                                 scope,
                                 [filter UTF8String],
                                 (char**)attrs,
                                 attrsOnly,
                                 NULL,
                                 NULL,
                                 timeVal,
                                 sizeLimit,
                                 &_messageId);
        // Get the last result code
        ldap_get_option(_connection.ld, LDAP_OPT_RESULT_CODE, &result);
    } else {
        result = ldap_search_ext_s(_connection.ld,
                                   [base UTF8String],
                                   scope,
                                   [filter UTF8String],
                                   (char**)attrs,
                                   attrsOnly,
                                   NULL,
                                   NULL,
                                   timeVal,
                                   sizeLimit,
                                   &_ldapMessage);
    }
    
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    if (timeVal) {
        free(timeVal);
        timeVal = NULL;
    }
    
    return result;
}

@end
