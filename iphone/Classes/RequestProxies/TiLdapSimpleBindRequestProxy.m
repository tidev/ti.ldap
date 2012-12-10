/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSimpleBindRequestProxy.h"
#import "TiUtils.h"

@implementation TiLdapSimpleBindRequestProxy

+(id)requestWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initRequest:@"simpleBind" connection:connection args:args] autorelease];
}

// Override the handleSuccess method so that we can set the bound state of the connection
-(void)handleSuccess:(id)result
{
    _connection.bound = YES;
    [super handleSuccess:result];
}

-(int)execute:(NSDictionary*)args async:(BOOL)async
{   
    NSString *dn = [TiUtils stringValue:@"dn" properties:args def:nil];
    NSString *passwd = [TiUtils stringValue:@"password" properties:args def:nil];
    
    NSLog(@"[DEBUG] LDAP simpleBind with dn: %@", dn);
    
    /*
     
     From the UnboundID documentation:
     
     Note, however, that LDAP does place restrictions on asynchronous operation processing.
     In particular, bind operations and StartTLS operations must always be processed in a
     synchronous manner. If a client is going to process asynchronous operations, then it
     must take care to ensure that it does not attempt to process bind or StartTLS operations
     while other operations may be in progress.
     
    */
    
    int result;
    
    if (async) {
        _messageId = ldap_simple_bind(_connection.ld, [dn UTF8String], [passwd UTF8String]);
        // Get the last result code
        ldap_get_option(_connection.ld, LDAP_OPT_RESULT_CODE, &result);
    } else {
        result = ldap_simple_bind_s(_connection.ld, [dn UTF8String], [passwd UTF8String]);
    }
    
    return result;
}

@end
