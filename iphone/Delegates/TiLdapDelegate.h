//
//  TiLdapDelegate.h
//  ldap
//
//  Created by Jeff English on 12/5/12.
//
//

//BUGBUG: Change this to a AsyncRequestProxy that combines the delegate and searchResult, etc. Return this
//proxy for async requests and add the 'abandon' method so that it can be killed if necessary

#import <Foundation/Foundation.h>
#import "TiLdapConnectionProxy.h"

@interface TiLdapDelegate : NSObject {
@protected
    TiLdapConnectionProxy *_connection;
    KrollCallback   *_successCallback;
    KrollCallback   *_errorCallback;
}

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args;

-(id)initWithProxy:(TiProxy*)proxy args:(NSDictionary*)args;
-(void)handleSuccess:(id)result;
-(void)handleError:(int)errorCode errorMessage:(NSString*)errorMessage;
-(void)handleError:(int)errorCode errorMessage:(NSString *)errorMessage method:(NSString*)method;

@end
