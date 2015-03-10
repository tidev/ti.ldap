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
#import "TiLdapConnectRequestProxy.h"

#import "TiFile.h"
#import "TiUtils.h"

@implementation TiLdapConnectionProxy

-(id)init
{
    if (self = [super init]) {
        _ld = NULL;
        _bound = NO;
        [self initializeProperty:@"useTLS" defaultValue:NUMBOOL(NO)];
    }
    
    return self;
}

-(void)_destroy
{
    [self disconnect:nil];
    
    [super _destroy];
}

-(LDAP*)ld
{
    return _ld;
}

-(void)setld:(LDAP*)ld
{
    _ld = ld;
}

-(void)setBound:(BOOL)bound
{
    _bound = bound;
}

-(BOOL)isBound
{
    return (_ld && _bound);
}

-(void)connect:(id)args
{
    // Create the request that implements the bind and handles the callbacks
    TiLdapConnectRequestProxy *request = [TiLdapConnectRequestProxy requestWithProxy:self];
    [request sendRequest:args];
}


-(void)disconnect:(id)args
{
    if (_ld && _bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        _bound = NO;
    }
    _ld = NULL;
}

-(TiLdapRequestProxy*)simpleBind:(id)args
{
    // Create the request that implements the bind and handles the callbacks
    TiLdapSimpleBindRequestProxy *request = [TiLdapSimpleBindRequestProxy requestWithProxy:self];
    [request sendRequest:args];
    
    return request;
}

-(TiLdapRequestProxy*)saslBind:(id)args
{    
    // Create the request that implements the bind and handles the callbacks
    TiLdapSaslBindRequestProxy *request = [TiLdapSaslBindRequestProxy requestWithProxy:self];
    [request sendRequest:args];
    
    return request;
}

-(TiLdapRequestProxy*)search:(id)args
{
    // Create the delegate that implements the search and handles the callbacks
    TiLdapSearchRequestProxy *request = [TiLdapSearchRequestProxy requestWithProxy:self];
    [request sendRequest:args];
    
    return request;
}

#pragma mark TLS Support Functions

-(NSString*)getFilePath:(id)url
{
    NSString *filePath = nil;
    if ([url isKindOfClass:[TiFile class]])	{
        filePath = [(TiFile*)url path];
    } else if ([url isKindOfClass:[NSString class]]) {
        filePath = [TiUtils stringValue:url];
    } else if ([url isKindOfClass:[TiBlob class]]) {
        filePath = [(TiBlob*)url path];
    }
    return filePath;
}

-(void)startTLS
{
    bool useTLS = [TiUtils boolValue:[self valueForUndefinedKey:@"useTLS"] def:NO];
    if (useTLS) {
        id certFile = [self valueForUndefinedKey:@"certFile"];
        if (!IS_NULL_OR_NIL(certFile)) {
            NSString *certFilePath = [self getFilePath:certFile];
            NSLog(@"[DEBUG] Using certificate: %@", certFilePath);
            ldap_set_option(NULL, LDAP_OPT_X_TLS_CERTFILE, [certFilePath UTF8String]);
            
            id caCertFile = [self valueForUndefinedKey:@"caCertFile"];
            if (!IS_NULL_OR_NIL(caCertFile)) {
                NSString *caCertFilePath = [self getFilePath:caCertFile];
                NSLog(@"[DEBUG] Using ca certificate: %@", caCertFilePath);
                ldap_set_option(NULL, LDAP_OPT_X_TLS_CACERTFILE, [caCertFilePath UTF8String]);
            }
        } else {
            int allow = LDAP_OPT_X_TLS_ALLOW;
            ldap_set_option(NULL, LDAP_OPT_X_TLS_REQUIRE_CERT, &allow);
        }
        
        NSLog(@"[INFO] Initializing TLS");
        int result = ldap_start_tls_s(_ld, NULL, NULL);
        if (result != LDAP_SUCCESS) {
            char *msg;
            ldap_get_option(_ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
            NSLog(@"[ERROR] Error initializing TLS: %s (%s)", ldap_err2string(result), msg);
            ldap_memfree(msg);
        } else {
            NSLog(@"[INFO] TLS initialized");
        }
    }
}

#pragma mark Public Proxy Properties

-(NSNumber*)getSizeLimit
{
    id value = [self valueForUndefinedKey:@"sizeLimit"];
    if (IS_NULL_OR_NIL(value)) {
        int sizeLimit;
        int result = ldap_get_option(_ld, LDAP_OPT_SIZELIMIT, &sizeLimit);
        if (result == LDAP_SUCCESS) {
            value = NUMINT(sizeLimit);
        }
    }
    
    return value;
}

-(NSNumber*)getTimeLimit
{
    id value = [self valueForUndefinedKey:@"timeLimit"];
    if (IS_NULL_OR_NIL(value)) {
        int timeLimit;
        int result = ldap_get_option(_ld, LDAP_OPT_TIMELIMIT, &timeLimit);
        if (result == LDAP_SUCCESS) {
            value = NUMINT(timeLimit);
        }
    }
    
    return value;
}

-(void)setSizeLimit
{
    id optionValue = [self valueForUndefinedKey:@"sizeLimit"];
    if (!IS_NULL_OR_NIL(optionValue)) {
        int value = [TiUtils intValue:optionValue];
        int result = ldap_set_option(_ld, LDAP_OPT_SIZELIMIT, &value);
        if (result != LDAP_SUCCESS) {
            NSLog(@"[ERROR] Error setting sizeLimit to %d", value);
        }
    }
}

-(void)setTimeLimit
{
    // TimeLimit is specified in seconds
    id optionValue = [self valueForUndefinedKey:@"timeLimit"];
    if (!IS_NULL_OR_NIL(optionValue)) {
        int value = [TiUtils intValue:optionValue];
        struct timeval timeVal;
    
        // Negative values indicate no timeLimit is desired
        if (value < 0) {
            timeVal.tv_sec = -1;
            timeVal.tv_usec = -1;
        } else {
            timeVal.tv_sec = value;
            timeVal.tv_usec = 0;
        }
        // We set all three timeout/timelimits with this single value
        int result = ldap_set_option(_ld, LDAP_OPT_TIMELIMIT, &timeVal);
        if (result == LDAP_SUCCESS) {
            result = ldap_set_option(_ld, LDAP_OPT_TIMEOUT, &timeVal);
        }
        if (result == LDAP_SUCCESS) {
            result = ldap_set_option(_ld, LDAP_OPT_NETWORK_TIMEOUT, &timeVal);
        }
        if (result != LDAP_SUCCESS) {
            NSLog(@"[ERROR] Error setting timeLimit to %d", value);
        }
    }
}

@end
