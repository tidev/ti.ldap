/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapOptions.h"
#import "TiUtils.h"

@implementation TiLdapOptions

static NSDictionary *keyMap = nil;

// Static class initializer
+(void)initialize
{
    if (self == [TiLdapOptions class]) {
        keyMap = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithInt:LDAP_OPT_CONNECT_ASYNC], @"connectAsync",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CACERTDIR], @"tlsCACertDir",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CACERTFILE], @"tlsCACertFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CERTFILE], @"tlsCertFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_KEYFILE], @"tlsKeyFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_REQUIRE_CERT], @"tlsRequireCert",
                  [NSNumber numberWithInt:LDAP_OPT_DEBUG_LEVEL], @"debugLevel",
                  [NSNumber numberWithInt:LDAP_OPT_SIZELIMIT], @"sizeLimit",
                  [NSNumber numberWithInt:LDAP_OPT_TIMEOUT], @"timeout"

                  nil];
        [keyMap retain];
    }
}

+(void)processOptions:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    int result;
    
    for (NSString* key in args) {
        NSNumber* option = (NSNumber*)[keyMap objectForKey:key];
        if (option != nil) {
            id value = [args objectForKey:key];
            result = [TiLdapOptions set:connection option:[option intValue] value:value];
            if (result != LDAP_SUCCESS) {
                NSLog(@"[ERROR] Failed to set %@. Error code: %d", key, result);
            }
        }
    }
}

+(int)set:(TiLdapConnectionProxy*)connection option:(int)option value:(id)optionValue
{
    int result = LDAP_UNDEFINED_TYPE;
    
    switch (option) {
        case LDAP_OPT_DEBUG_LEVEL:
        case LDAP_OPT_SIZELIMIT:
        {
            int value = [TiUtils intValue:optionValue];
            result = ldap_set_option(connection.ld, option, &value);
            break;
        }
        case LDAP_OPT_X_TLS_REQUIRE_CERT:
        case LDAP_OPT_CONNECT_ASYNC:
        {
            int value = (int)[TiUtils boolValue:optionValue];
            result = ldap_set_option(connection.ld, option, &value);
            break;
        }
        case LDAP_OPT_TIMEOUT:
        {
            // Timeout is specified in milliseconds
            int value = [TiUtils intValue:optionValue];
            struct timeval timeVal;
            if (value == -1) {
                timeVal.tv_sec = -1;
                timeVal.tv_usec = -1;
            } else {
                timeVal.tv_sec = value / 1000;
                timeVal.tv_usec = (value % 1000) * 1000;
            }
            result = ldap_set_option(connection.ld, LDAP_OPT_NETWORK_TIMEOUT, &timeVal);
            if (result == LDAP_SUCCESS) {
                result = ldap_set_option(connectino.ld, LDAP_OPT_TIMEOUT, &timeVal);
            }
            break;
        }
        case LDAP_OPT_X_TLS_CACERTDIR:
        case LDAP_OPT_X_TLS_CACERTFILE:
        case LDAP_OPT_X_TLS_CERTFILE:
        case LDAP_OPT_X_TLS_KEYFILE:
        {
            if ([optionValue isKindOfClass:[TiFile class]]) {
                TiFile *file = (TiFile*)optionValue;
                NSString *path = [file path];
                NSLog(@"[DEBUG] Setting LDAP_OPT_X_TLS_CACERTFILE to file: %@", path);
                result = ldap_set_option(connection.ld, option, [path UTF8String]);
                if (result == LDAP_SUCCESS) {
                    connection.useTLS = YES;
                }
            }
            break;
        }
    }

    return result;
}

@end
