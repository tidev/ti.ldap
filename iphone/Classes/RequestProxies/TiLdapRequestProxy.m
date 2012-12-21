/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapRequestProxy.h"
#import "TiUtils.h"

@implementation TiLdapRequestProxy

-(id)initRequest:(NSString*)method connection:(TiLdapConnectionProxy*)connection
{
    if (self = [self _initWithPageContext:[connection pageContext]]) {
        _method = [method retain];
        _connection = [connection retain];
    }
    
    return self;
}

-(void)_destroy
{
    RELEASE_TO_NIL(_method);
    RELEASE_TO_NIL(_connection);
    RELEASE_TO_NIL(_successCallback);
    RELEASE_TO_NIL(_errorCallback);
    
    if (_ldapMessage) {
        ldap_msgfree(_ldapMessage);
        _ldapMessage = NULL;
    }
    
    [super _destroy];
}

-(BOOL)isConnectionValid
{
    // Verify that we have a connection
    if (_connection != nil) {
        return YES;
    }
    [self handleError:-1
         errorMessage:@"[ERROR] Connection is not valid"];
    
    return NO;
}

-(BOOL)isConnectionBound
{
    // Verify that we have not only a connection but that it is also bound
    if ([self isConnectionValid]) {
        if ([_connection isBound]) {
            return YES;
        }
        [self handleError:-2
             errorMessage:@"[ERROR] Connection is not bound."];
    }
    
    return NO;
}

-(void)handleSuccess:(id)result
{
    if (_successCallback != nil) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               _method, @"method",
                               result, @"result",
                               nil];
        [_connection _fireEventToListener:@"success" withObject:event listener:_successCallback thisObject:nil];
    }
}

-(void)handleError:(int)errorCode errorMessage:(NSString *)errorMessage
{
    if (_errorCallback != nil) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               _method, @"method",
                               NUMINT(errorCode), @"error",
                               errorMessage, @"message",
                               nil ];
        [_connection _fireEventToListener:@"error" withObject:event listener:_errorCallback thisObject:nil];
    }
}

-(void)waitForResultInThread
{
    int err = -1;
    
    int result = ldap_result(_connection.ld, _messageId, LDAP_MSG_ALL, NULL, &_ldapMessage);
    switch (result) {
        case LDAP_RES_BIND:
        case LDAP_RES_SEARCH_ENTRY:
        case LDAP_RES_SEARCH_RESULT: {
            //NOTE: DO NOT FREE THE MESSAGE
            int rc = ldap_parse_result(_connection.ld, _ldapMessage, &err, NULL, NULL, NULL, NULL, 0 );
            if ((rc == LDAP_SUCCESS) && (err == LDAP_SUCCESS)) {
                [self handleSuccess:nil];
            }
            break;
        }
        case 0:
        case -1: {
            // An error occurred for the asynchronous operation. Get the actual error code.
            ldap_get_option(_connection.ld, LDAP_OPT_RESULT_CODE, &err);
            [self handleError:err
                 errorMessage:[NSString stringWithUTF8String:ldap_err2string(err)]];
            break;
        }
        default: {
            NSLog(@"[ERROR] Unexpected response from ldap_result");
            [self handleError:result
                 errorMessage:@"Unexpected response from ldap_result"];
            break;
        }
    }
    
    [self forgetSelf];
}

-(int)execute:(NSDictionary*)args async:(BOOL)async
{
    // There is no default implementation -- this method should be overridden by a specific request type
    return LDAP_SUCCESS;
}

-(void)sendRequest:(id)args
{
    enum Args {
        kArgOptions = 0,
        kArgSuccess,
        kArgError,
        kArgNumArguments
    };
    
    ENSURE_ARRAY(args)
    ENSURE_ARG_OR_NIL_AT_INDEX(_successCallback, args, kArgSuccess, KrollCallback);
    ENSURE_ARG_OR_NIL_AT_INDEX(_errorCallback, args, kArgError, KrollCallback);
    ENSURE_ARG_AT_INDEX(args, args, kArgOptions, NSDictionary);
    
    [_successCallback retain];
    [_errorCallback retain];
    
    // Determine if this is a synchronous or asynchronous request
    BOOL async = [TiUtils boolValue:@"async" properties:args def:NO];
    
    _messageId = -1;
    int result = [self execute:args async:async];
    
    // If we have a messageId then this is a valid asynchronouse request and we need to start
    // polling for the result. Otherwise, if it was successful then we need to return the
    // result. Otherwise, an error occurred and we need to report that and clean up.
    
    if (async && (_messageId >= 0)) {
        [self waitForResultInThread];
    } else if (result == LDAP_SUCCESS) {
        [self handleSuccess:nil];
    } else {
        [self handleError:result
             errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]];
    }
}

-(void)abandon:(id)args
{
    // First make sure that we have a valid connection
    if (![self isConnectionValid]) {
        return;
    }
    
    if (_messageId < 0) {
        NSLog(@"[ERROR] Attempted to abandon request that is not active");
        return;
    }
    
    ldap_abandon_ext(_connection.ld, _messageId, NULL, NULL);
}

@end
