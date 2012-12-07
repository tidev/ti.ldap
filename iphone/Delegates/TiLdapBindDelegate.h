//
//  TiLdapBindDelegate.h
//  ldap
//
//  Created by Jeff English on 12/5/12.
//
//

#import "TiLdapDelegate.h"

@interface TiLdapBindDelegate : TiLdapDelegate {
}

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;

-(void)simpleBind:(NSDictionary*)args;

@end
