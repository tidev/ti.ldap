/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapConnectionProxy.h"
#import "TiLdapSearchResultProxy.h"
#import "TiLdapDelegate.h"
#import "TiLdapBindDelegate.h"
#import "TiLdapSaslBindDelegate.h"
#import "TiLdapSearchDelegate.h"
#import "TiLdapOptions.h"

#import "TiUtils.h"

@implementation TiLdapConnectionProxy

@synthesize useTLS, bound;

-(id)init
{
    if (self = [super init]) {
        _ld = NULL;
        bound = NO;
    }
    
    return self;
}

-(void)_destroy
{
    if (_ld && bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        bound = NO;
    }
    
    [super _destroy];
}

-(LDAP*)ld
{
    return _ld;
}

-(BOOL)isValid
{
    return (_ld && bound);
}

-(void)connect:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the delegate for the callbacks eventhough this method
    // is synchronous. This allows us to centrally handle the callbacks
    TiLdapDelegate *delegate = [TiLdapDelegate delegateWithProxyAndArgs:self args:args];
    
    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1:389"];
  
    NSLog(@"[DEBUG] LDAP initialize with url: %@", uri);

    int result = ldap_initialize(&_ld, [uri UTF8String]);
    if (result == LDAP_SUCCESS) {
        // Set protocol version to 3 by default
        int protocolVersion = LDAP_VERSION3;
        ldap_set_option(_ld, LDAP_OPT_PROTOCOL_VERSION, &protocolVersion);
        
        [TiLdapOptions processOptions:self args:[self allProperties]];
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               uri, @"uri",
                               nil ];
        [delegate handleSuccess:event];
    } else {
        [delegate handleError:result
                 errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]
                       method:@"connect"];
    }
    
    return NUMINT(result);
}

-(void)simpleBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary)
    
    // Create the delegate that implements the bind and handles the callbacks
    TiLdapBindDelegate *delegate = [TiLdapBindDelegate delegateWithProxyAndArgs:self args:args];
    [delegate simpleBind:args];
}

-(void)unBind:(id)args
{
    if (_ld && bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        bound = NO;
    }
}

//BUGBUG: See comment in TiLdapDelegate.h

-(void)search:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);

    // Create the delegate that implements the search and handles the callbacks
    TiLdapSearchDelegate *delegate = [TiLdapSearchDelegate delegateWithProxyAndArgs:self args:args];
    [delegate search:args];
}

-(void)saslBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the delegate that implements the bind and handles the callbacks
    TiLdapSaslBindDelegate *delegate = [TiLdapSaslBindDelegate delegateWithProxyAndArgs:self args:args];
    [delegate saslBind:args];
}

@end
