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
#import "TiFilesystemFileProxy.h"

#import "TiUtils.h"

@implementation TiLdapConnectionProxy

@synthesize useTLS, certFile = _certFile;

-(id)init
{
    if (self = [super init]) {
        _ld = NULL;
        _bound = NO;
        self.useTLS = NO;
        self.certFile = nil;
    }
    
    return self;
}

-(void)_destroy
{
    if (_ld && _bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        _bound = NO;
    }
    self.certFile = nil;
    
    [super _destroy];
}

-(LDAP*)ld
{
    return _ld;
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
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1:389"];
  
    NSLog(@"[DEBUG] LDAP initialize with uri: %@", uri);

    int result = ldap_initialize(&_ld, [uri UTF8String]);
    if (result == LDAP_SUCCESS) {
        // Set protocol version to 3 by default
        int protocolVersion = LDAP_VERSION3;
        ldap_set_option(_ld, LDAP_OPT_PROTOCOL_VERSION, &protocolVersion);
        
        [self startTLS];
        
        // Apply all of the supported properties (need to do this after _ld is created)
        [self setAsync];
        [self setSizeLimit];
        [self setTimeout];
        
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

-(TiLdapRequestProxy*)search:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the delegate that implements the search and handles the callbacks
    TiLdapSearchRequestProxy *request = [TiLdapSearchRequestProxy requestWithProxyAndArgs:self args:args];
    [request sendRequest:args];
    
    return request;
}

-(void)unBind:(id)args
{
    if (_ld && _bound) {
        ldap_unbind_ext(_ld, NULL, NULL);
        _bound = NO;
    }
}

#pragma mark TLS Support Functions

-(NSString*)getFilePath:(id)url
{
    NSString *filePath = nil;
	if ([url isKindOfClass:[TiFilesystemFileProxy class]])	{
        filePath = [(TiFilesystemFileProxy*)url nativePath];
	} else if ([url isKindOfClass:[NSString class]]) {
		filePath = [TiUtils stringValue:url];
    } else if ([url isKindOfClass:[TiBlob class]]) {
        filePath = [(TiBlob*)url nativePath];
	}
}

-(void)startTLS
{
    if (useTLS) {
        if (self.certFile) {
            NSString *certFilePath = [self getFilePath:self.certFile];
            NSLog(@"[DEBUG] Using certificate: %@", certFilePath);
            ldap_set_option(_ld, LDAP_OPT_X_TLS_CERTFILE, [certFilePath UTF8String]);
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

-(NSNumber*)getAsync
{
    int async;
    int result = ldap_get_option(_ld, LDAP_OPT_CONNECT_ASYNC, &async);
    if (result == LDAP_SUCCESS) {
        return (async == 0) ? NUMBOOL(NO) : NUMBOOL(YES);
    }
    
    NSLog(@"[ERROR] Error retrieving async");
    
    return NUMBOOL(NO);
}

-(NSNumber*)getSizeLimit
{
    int sizeLimit;
    int result = ldap_get_option(_ld, LDAP_OPT_SIZELIMIT, &sizeLimit);
    if (result == LDAP_SUCCESS) {
        return NUMINT(sizeLimit);
    }
    
    NSLog(@"[ERROR] Error retrieving sizeLimit");
    
    return NUMINT(0);
}

-(NSNumber*)getTimeout
{
    struct timeval *timeVal;
    int result = ldap_get_option(_ld, LDAP_OPT_TIMEOUT, &timeVal);
    if (result == LDAP_SUCCESS) {
        NSNumber *timeout = NUMINT((timeVal->tv_sec * 1000) + (timeVal->tv_usec / 1000));
        ldap_memfree(timeVal);
        return timeout;
    }
    
    NSLog(@"[ERROR] Error retrieving timeout");
    
    return NUMINT(0);
}

-(void)setAsync
{
    id optionValue = [self valueForUndefinedKey:@"async"];
    if (optionValue != nil) {
        int value = ([TiUtils boolValue:optionValue] == YES) ? 1 : 0;
        int result = ldap_set_option(_ld, LDAP_OPT_CONNECT_ASYNC, &value);
        if (result != LDAP_SUCCESS) {
            NSLog(@"[ERROR] Error setting async to %d", value);
        }
    }
}

-(void)setSizeLimit
{
    id optionValue = [self valueForUndefinedKey:@"sizeLimit"];
    if (optionValue != nil) {
        int value = [TiUtils intValue:optionValue];
        int result = ldap_set_option(_ld, LDAP_OPT_SIZELIMIT, &value);
        if (result != LDAP_SUCCESS) {
            NSLog(@"[ERROR] Error setting sizeLimit to %d", value);
        }
    }
}

-(void)setTimeout
{
    // Timeout is specified in milliseconds
    id optionValue = [self valueForUndefinedKey:@"timeout"];
    if (optionValue != nil) {
        int value = [TiUtils intValue:optionValue];
        struct timeval timeVal;
    
        // Negative values indicate no timeout is desired
        if (value < 0) {
            timeVal.tv_sec = -1;
            timeVal.tv_usec = -1;
        } else {
            timeVal.tv_sec = value / 1000;
            timeVal.tv_usec = (value % 1000) * 1000;
        }
        int result = ldap_set_option(_ld, LDAP_OPT_TIMEOUT, &timeVal);
        if (result == LDAP_SUCCESS) {
            result = ldap_set_option(_ld, LDAP_OPT_NETWORK_TIMEOUT, &timeVal);
        }
        if (result != LDAP_SUCCESS) {
            NSLog(@"[ERROR] Error setting timeout to %d", value);
        }
    }
}

@end
