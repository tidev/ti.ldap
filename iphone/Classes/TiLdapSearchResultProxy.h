/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiLdapConnectionProxy.h"

@interface TiLdapSearchResultProxy : TiProxy {
    KrollCallback *callback;
    TiLdapConnectionProxy *connection;
    LDAPMessage *searchResult;
    int msgId;
}

-(id)initWithLDAPMessage:(LDAPMessage*)result_ callback:(KrollCallback*)callback_ connection:(TiLdapConnectionProxy*)connection_ pageContext:(id<TiEvaluator>)context;
-(id)initWithMsgId:(int)msgId_ callback:(KrollCallback*)callback_ connection:(TiLdapConnectionProxy*)connection_ pageContext:(id<TiEvaluator>)context;

@end
