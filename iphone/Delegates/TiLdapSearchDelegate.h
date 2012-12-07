//
//  TiLdapSearchDelegate.h
//  ldap
//
//  Created by Jeff English on 12/6/12.
//
//

#import "TiLdapDelegate.h"
#import "TiLdapConnectionProxy.h"

@interface TiLdapSearchDelegate : TiLdapDelegate {
    int _messageId;
}

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;

-(void)search:(NSDictionary*)args;

@end
