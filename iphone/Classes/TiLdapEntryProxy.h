/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiLdapConnectionProxy.h"

@interface TiLdapEntryProxy : TiProxy {
@private
    TiLdapConnectionProxy *_connection;
    LDAPMessage *_entry;
    BerElement *_ber;
}

+(TiLdapEntryProxy*)entryWithLDAPMessage:(LDAPMessage*)entry connection:(TiLdapConnectionProxy*)connection;

-(id)initWithLDAPMessage:(LDAPMessage*)entry connection:(TiLdapConnectionProxy*)connection;

-(LDAPMessage*)entry;

@end
