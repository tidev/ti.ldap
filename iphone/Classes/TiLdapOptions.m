//
//  LdapOptions.m
//  ldap
//
//  Created by Jeff English on 12/4/12.
//
//

#import "TiLdapOptions.h"
#import "TiUtils.h"

@implementation TiLdapOptions

static NSDictionary *keyMap = nil;

// Static class initializer
+(void)initialize
{
    if (self == [TiLdapOptions class]) {
        keyMap = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithInt:LDAP_OPT_PROTOCOL_VERSION], @"protocolVersion",
                  [NSNumber numberWithInt:LDAP_OPT_CONNECT_ASYNC], @"connectAsync",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CACERTDIR], @"tlsCACertDir",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CACERTFILE], @"tlsCACertFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_CERTFILE], @"tlsCertFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_KEYFILE], @"tlsKeyFile",
                  [NSNumber numberWithInt:LDAP_OPT_X_TLS_REQUIRE_CERT], @"tlsRequireCert",
                  [NSNumber numberWithInt:LDAP_OPT_DEBUG_LEVEL], @"debugLevel",
                  [NSNumber numberWithInt:LDAP_OPT_SIZELIMIT], @"sizeLimit",
                  
                  [NSNumber numberWithInt:LDAP_OPT_NETWORK_TIMEOUT], @"networkTimeout",
                  [NSNumber numberWithInt:LDAP_OPT_TIMEOUT], @"timeout",
                  [NSNumber numberWithInt:LDAP_OPT_TIMELIMIT], @"timeLimit",

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
        case LDAP_OPT_TIMELIMIT:
        case LDAP_OPT_PROTOCOL_VERSION:
        {
            int value = [TiUtils intValue:optionValue];
            NSLog(@"[DEBUG] Setting LDAP_OPT_PROTOCOL_VERSION to %d", value);
            result = ldap_set_option(connection.ld, option, &value);
            break;
        }
        case LDAP_OPT_X_TLS_REQUIRE_CERT:
        case LDAP_OPT_CONNECT_ASYNC:
        {
            int value = (int)[TiUtils boolValue:optionValue];
            NSLog(@"[DEBUG] Setting LDAP_OPT_CONNECT_ASYNC to %d", value);
            result = ldap_set_option(connection.ld, option, &value);
            break;
        }
        case LDAP_OPT_NETWORK_TIMEOUT:
        case LDAP_OPT_TIMEOUT:
        {
            struct timeval *timeVal = NULL;
            if (optionValue) {
                struct timeval timeVal;
                timeVal.tv_sec = [TiUtils intValue:@"sec" properties:optionValue def:1];
                timeVal.tv_usec = [TiUtils intValue:@"usec" properties:optionValue def:0];
                NSLog(@"[DEBUG] Setting LDAP_OPT_TIMEOUT to %d, %d", timeVal.tv_sec, timeVal.tv_usec);
                result = ldap_set_option(connection.ld, option, &timeVal);
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
