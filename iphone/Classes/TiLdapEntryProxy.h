/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiLdapConnectionProxy.h"

@interface TiLdapEntryProxy : TiProxy {
@private
    TiLdapConnectionProxy *connection;
    LDAPMessage *entry;
    BerElement *ber;
}

-(id)initWithLDAPMessage:(LDAPMessage*)entry_ connection:(TiLdapConnectionProxy*)connection_ pageContext:(id<TiEvaluator>)context;

-(LDAPMessage*)entry;

@end
