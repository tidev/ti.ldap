/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapRequestProxy.h"

typedef struct my_ldap_auth MyLDAPAuth;
struct my_ldap_auth
{
    char * mech;
    char * authuser;
    char * user;
    char * realm;
    char * passwd;
};

@interface TiLdapSaslBindRequestProxy : TiLdapRequestProxy {
@private
    MyLDAPAuth _auth;
}

+(id)requestWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;

-(int)execute:(NSDictionary*)args async:(BOOL)async;
-(void)handleSuccess:(id)result;

@end
