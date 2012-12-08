//
//  TiLdapSaslBindDelegate.h
//  ldap
//
//  Created by Jeff English on 12/6/12.
//
//

#import "TiLdapDelegate.h"

@interface TiLdapSaslBindDelegate : TiLdapDelegate {
}

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;

-(void)saslBind:(NSDictionary*)args;

@end
