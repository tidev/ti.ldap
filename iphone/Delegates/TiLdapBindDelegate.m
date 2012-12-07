//
//  TiLdapBindDelegate.m
//  ldap
//
//  Created by Jeff English on 12/5/12.
//
//

#import "TiLdapBindDelegate.h"
#import "TiUtils.h"

@implementation TiLdapBindDelegate

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initWithProxy:connection args:args] autorelease];
}

/* 
    From the UnboundID documentation:
 
    Note, however, that LDAP does place restrictions on asynchronous operation processing.
    In particular, bind operations and StartTLS operations must always be processed in a 
    synchronous manner. If a client is going to process asynchronous operations, then it 
    must take care to ensure that it does not attempt to process bind or StartTLS operations 
    while other operations may be in progress.
*/

-(void)simpleBind:(NSDictionary*)args
{
    NSString *dn = [TiUtils stringValue:@"dn" properties:args def:nil];
    NSString *passwd = [TiUtils stringValue:@"passsword" properties:args def:nil];
    
    NSLog(@"[DEBUG] LDAP simpleBind with dn: %@", dn);
    int result = ldap_simple_bind_s(_connection.ld, [dn UTF8String], [passwd UTF8String]);
    
    if (result == LDAP_SUCCESS) {
        [self handleSuccess:nil];
    } else {
        [self handleError:result
             errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]
                   method:@"simpleBind"];
    }
}

@end
