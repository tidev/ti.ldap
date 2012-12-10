/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "TiLdapConnectionProxy.h"

#define LDAP_DEPRECATED 1
#import "ldap.h"

@interface TiLdapOptions : NSObject {
}

+(void)processOptions:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;
+(int)set:(TiLdapConnectionProxy*)connection option:(int)option value:(id)optionValue;

@end