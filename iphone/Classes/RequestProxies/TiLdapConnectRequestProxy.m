/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapConnectRequestProxy.h"
#import "TiUtils.h"

@implementation TiLdapConnectRequestProxy

+(id)requestWithProxy:(TiLdapConnectionProxy*)connection
{
    return [[[self alloc] initRequest:@"connect" connection:connection] autorelease];
}

-(int)execute:(NSDictionary*)args async:(BOOL)async
{
    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1:389"];
    
    NSLog(@"[DEBUG] LDAP initialize with uri: %@", uri);
    
    LDAP *ld;
    int result = ldap_initialize(&ld, [uri UTF8String]);
    if (result == LDAP_SUCCESS) {
        // Set protocol version to 3 by default
        int protocolVersion = LDAP_VERSION3;
        ldap_set_option(ld, LDAP_OPT_PROTOCOL_VERSION, &protocolVersion);
        
        [_connection setld:ld];
        
        // Start TLS if needed
        [_connection startTLS];
        
        // Apply all of the supported properties (need to do this after _ld is created)
        [_connection setSizeLimit];
        [_connection setTimeLimit];
    }

    return result;
}

@end