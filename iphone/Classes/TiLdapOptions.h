//
//  LdapOptions.h
//  ldap
//
//  Created by Jeff English on 12/4/12.
//
//

#import <Foundation/Foundation.h>
#import "TiLdapConnectionProxy.h"

#define LDAP_DEPRECATED 1
#import "ldap.h"

@interface TiLdapOptions : NSObject {
}

+(void)processOptions:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;
+(int)set:(TiLdapConnectionProxy*)connection option:(int)option value:(id)optionValue;

@end