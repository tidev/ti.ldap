/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapEntryProxy.h"
#import "TiUtils.h"
#import "TiBlob.h"

@implementation TiLdapEntryProxy

-(id)initWithLDAPMessage:(LDAPMessage*)entry_ connection:(TiLdapConnectionProxy*)connection_ pageContext:(id<TiEvaluator>)context
{
    if (self = [super _initWithPageContext:context]) {
        entry = entry_;
        connection = [connection_ retain];
        ber = NULL;
    }
    
    return self;
}

-(void)_destroy
{
    RELEASE_TO_NIL(connection);
    if (ber != NULL) {
        ber_free(ber, 0);
        ber = NULL;
    }
    
	[super _destroy];
}

-(LDAPMessage*)entry
{
    return entry;
}

-(NSString*)getDn:(id)args
{
    NSString *result = nil;
    if (entry) {
        char *dn = ldap_get_dn(connection.ld, entry);
        if (dn != NULL) {
            result = [NSString stringWithUTF8String:dn];
            ldap_memfree(dn);
        } else {
            NSLog(@"[ERROR] Error occurred in getDn");
        }
    }
    
    return result;
}

-(NSString*)firstAttribute:(id)args
{
    NSString *result = nil;
    
    if (ber != NULL) {
        ber_free(ber, 0);
        ber = NULL;
    }
    
    char *attribute = ldap_first_attribute(connection.ld, entry, &ber);
    if (attribute != NULL) {
        result = [NSString stringWithUTF8String:attribute];
        ldap_memfree(attribute);
    } else {
        NSLog(@"[ERROR] Error occurred in firstAttribute");
    }
    
    return result;
    
}

-(NSString*)nextAttribute:(id)args
{
    NSString *result = nil;
    
    char *attribute = ldap_next_attribute(connection.ld, entry, ber);
    if (attribute != NULL) {
        result = [NSString stringWithUTF8String:attribute];
        ldap_memfree(attribute);
    }
    // NULL is returned when there are no more attributes
    
    return result;
    
}

-(NSArray*)getValues:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSString);
    
    NSMutableArray *result = nil;
    
    char **vals = ldap_get_values(connection.ld, entry, [arg UTF8String]);
    if (vals) {
        int count = ldap_count_values(vals);
        result = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
        if (result) {
            for (int i=0; i<count; i++) {
                [result addObject:[NSString stringWithUTF8String:vals[i]]];
            }
        }
        ldap_value_free(vals);
    } else {
        NSLog(@"[ERROR] Error occurred in getValues");
    }
    
    return result;
    
}

-(NSArray*)getValuesLen:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSString);
    
    NSMutableArray *result = nil;
    
    struct berval** vals = ldap_get_values_len(connection.ld, entry, [arg UTF8String]);
    if (vals) {
        int count = ldap_count_values_len(vals);
        result = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
        if (result) {
            for (int i=0; i<count; i++) {
                NSData *data = [NSData dataWithBytes:vals[i]->bv_val length:vals[i]->bv_len];
                [result addObject:[[[TiBlob alloc] initWithData:data mimetype:@"binary/octet-stream"] autorelease]];
            }
        }
        ldap_value_free_len(vals);
    }
    
    return result;
}

@end
