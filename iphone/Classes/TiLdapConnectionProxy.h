/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"

#define LDAP_DEPRECATED 1
#import "ldap.h"

@interface TiLdapConnectionProxy : TiProxy {
@private
    LDAP        *_ld;
    BOOL        _bound;
}

-(LDAP*)ld;
-(BOOL)isBound;
-(void)setBound:(BOOL)bound;

@property(nonatomic,readwrite) BOOL useTLS;
@property(nonatomic,readwrite,retain) id certFile;

@end
