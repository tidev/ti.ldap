//
//  LdapOptions.h
//  ldap
//
//  Created by Jeff English on 12/4/12.
//
//

#import <Foundation/Foundation.h>

#define LDAP_DEPRECATED 1
#import "ldap.h"

@interface TiLdapOptions : NSObject {
}

+(void)processOptions:(LDAP*)ld args:(NSDictionary*)args;
+(int)set:(LDAP*)ld option:(int)option value:(id)optionValue;

@end