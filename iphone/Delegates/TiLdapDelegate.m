//
//  TiLdapDelegate.m
//  ldap
//
//  Created by Jeff English on 12/5/12.
//
//

#import "TiLdapDelegate.h"

@implementation TiLdapDelegate

-(id)initWithProxy:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    if (self = [super init]) {
        _connection = [connection retain];
        _successCallback = [[args objectForKey:@"success"] retain];
        _errorCallback = [[args objectForKey:@"error"] retain];
    }
    
    return self;
}

+(id)delegateWithProxyAndArgs:(TiProxy*)proxy args:(NSDictionary*)args
{
    return [[[self alloc] initWithProxy:proxy args:args] autorelease];
}

-(void)dealloc
{
    RELEASE_TO_NIL(_successCallback);
    RELEASE_TO_NIL(_errorCallback);
    RELEASE_TO_NIL(_connection);
    
    [super dealloc];
}

-(void)handleSuccess:(id)result
{
    if (_successCallback != nil) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               result, @"result",
                               nil];
        [_connection _fireEventToListener:@"success" withObject:event listener:_successCallback thisObject:nil];
    }
}

-(void)handleError:(int)errorCode errorMessage:(NSString *)errorMessage
{
    if (_errorCallback != nil) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               NUMINT(errorCode), @"error",
                               errorMessage, @"message",
                               nil ];
        [_connection _fireEventToListener:@"error" withObject:event listener:_errorCallback thisObject:nil];
    }
}

-(void)handleError:(int)errorCode errorMessage:(NSString *)errorMessage method:(NSString*)method
{
    if (_errorCallback != nil) {
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               method, @"method",
                               NUMINT(errorCode), @"error",
                               errorMessage, @"message",
                               nil ];
        [_connection _fireEventToListener:@"error" withObject:event listener:_errorCallback thisObject:nil];
    }
}

@end
