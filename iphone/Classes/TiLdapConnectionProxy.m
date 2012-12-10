/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapConnectionProxy.h"
#import "TiLdapSimpleBindRequestProxy.h"
#import "TiLdapSaslBindRequestProxy.h"
#import "TiLdapSearchRequestProxy.h"
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

-(BOOL)isBound
{
    return (_ld && bound);
}

-(void)connect:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1:389"];
  
    NSLog(@"[DEBUG] LDAP initialize with url: %@", uri);

    int result = ldap_initialize(&_ld, [uri UTF8String]);
    if (result == LDAP_SUCCESS) {
        // Set protocol version to 3 by default
        int protocolVersion = LDAP_VERSION3;
        ldap_set_option(_ld, LDAP_OPT_PROTOCOL_VERSION, &protocolVersion);
        
        [TiLdapOptions processOptions:self args:[self allProperties]];
        
        KrollCallback *successCallback = [args objectForKey:@"success"];
        if (successCallback) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"connect", @"method",
                                   uri, @"uri",
                                   nil];
            [self _fireEventToListener:@"success" withObject:event listener:successCallback thisObject:nil];
        }
    } else {
        KrollCallback *errorCallback = [args objectForKey:@"error"];
        if (errorCallback) {
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"connect", @"method",
                                   NUMINT(result), @"error",
                                   [NSString stringWithUTF8String:ldap_err2string(result)], @"message",
                                   nil];
            [self _fireEventToListener:@"error" withObject:event listener:errorCallback thisObject:nil];
        }
    }
    
    return NUMINT(result);
}

-(TiLdapRequestProxy*)simpleBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary)
    
    // Create the request that implements the bind and handles the callbacks
    TiLdapSimpleBindRequestProxy *request = [TiLdapSimpleBindRequestProxy requestWithProxyAndArgs:self args:args];
    [request sendRequest:args];
    
    return request;
}

-(TiLdapRequestProxy*)saslBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the request that implements the bind and handles the callbacks
    TiLdapSaslBindRequestProxy *request = [TiLdapSaslBindRequestProxy requestWithProxyAndArgs:self args:args];
    [request sendRequest:args];
    
    return request;
}

-(void)unBind:(id)args
{
    if (_ld && bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        bound = NO;
    }
}

-(TiLdapRequestProxy*)search:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);

    // Create the delegate that implements the search and handles the callbacks
    TiLdapSearchRequestProxy *request = [TiLdapSearchRequestProxy requestWithProxyAndArgs:self args:args];
    [request sendRequest:args];
    
    return request;
}

@end
