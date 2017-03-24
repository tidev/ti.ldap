/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapSaslBindRequestProxy.h"
#import "TiUtils.h"

#include <sasl/sasl.h>

@implementation TiLdapSaslBindRequestProxy

+(id)requestWithProxy:(TiLdapConnectionProxy*)connection
{
    return [[[self alloc] initRequest:@"saslBind" connection:connection] autorelease];
}

-(void)_destroy
{
    if (_auth.mech) {
        free(_auth.mech);
    }
    if (_auth.authenticationId) {
        free(_auth.authenticationId);
    }
    if (_auth.authorizationId) {
        free(_auth.authorizationId);
    }
    if (_auth.passwd) {
        free(_auth.passwd);
    }
    if (_auth.realm) {
        free(_auth.realm);
    }
    
    [super _destroy];
}

// Override the handleSuccess method so that we can set the bound state of the connection
-(void)handleSuccess:(id)result
{
    _connection.bound = YES;
    [super handleSuccess:result];
}

int ldap_sasl_interact(LDAP *ld, unsigned flags, void *defaults,
                       void * sin)
{
    MyLDAPAuth      * ldap_inst = defaults;
	sasl_interact_t * interact;
    
    ldap_inst = (MyLDAPAuth *) defaults;
    interact  = (sasl_interact_t *) sin;
    flags     = 0;
    
    if (!(ld))
        return(LDAP_PARAM_ERROR);
    
    for(interact = sin; (interact->id != SASL_CB_LIST_END); interact++)
    {
        interact->result = NULL;
        interact->len    = 0;
        switch( interact->id )
        {
            case SASL_CB_GETREALM:
                interact->result = ldap_inst->realm ? ldap_inst->realm : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_AUTHNAME:
                interact->result = ldap_inst->authenticationId ? ldap_inst->authenticationId : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_PASS:
                interact->result = ldap_inst->passwd ? ldap_inst->passwd : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_USER:
                interact->result = ldap_inst->authorizationId ? ldap_inst->authorizationId : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_NOECHOPROMPT:
                break;
            case SASL_CB_ECHOPROMPT:
                break;
            default:
                break;
        };
    };

    return(LDAP_SUCCESS);
};

-(char*)getAuthValue:(NSString*)key args:(NSDictionary*)args option:(int)option
{
    char* result = NULL;
    
    NSString *argValue = [TiUtils stringValue:key properties:args def:nil];
    if (argValue) {
        result = strdup([argValue UTF8String]);
    } else if (option >= 0) {
        char* optValue;
        ldap_get_option(_connection.ld, option, &optValue);
        if (optValue) {
            result = strdup(optValue);
            ldap_memfree(optValue);
        }
    }
    
    return result;
}

-(int)execute:(NSDictionary*)args async:(BOOL)async
{
    memset(&_auth, 0, sizeof(MyLDAPAuth));
    
    // dn is always ignored on sasl bind
    _auth.passwd = [self getAuthValue:@"password" args:args option:-1];
    _auth.mech = [self getAuthValue:@"mech" args:args option:LDAP_OPT_X_SASL_MECH];
    _auth.realm = [self getAuthValue:@"realm" args:args option:LDAP_OPT_X_SASL_REALM];
    _auth.authorizationId = [self getAuthValue:@"authorizationId" args:args option:LDAP_OPT_X_SASL_AUTHZID];
    _auth.authenticationId = [self getAuthValue:@"authenticationId" args:args option:LDAP_OPT_X_SASL_AUTHCID];
    
    /*
     
     From the UnboundID documentation:
     
     Note, however, that LDAP does place restrictions on asynchronous operation processing.
     In particular, bind operations and StartTLS operations must always be processed in a
     synchronous manner. If a client is going to process asynchronous operations, then it
     must take care to ensure that it does not attempt to process bind or StartTLS operations
     while other operations may be in progress.
     
     */
    
    NSLog(@"[INFO] LDAP SASLBind");
    
    int result = ldap_sasl_interactive_bind_s(_connection.ld, NULL, _auth.mech, NULL, NULL, LDAP_SASL_QUIET, ldap_sasl_interact, &_auth);
    
    // NOTE: Do NOT free the memory allocated by getAuthValue -- it will be freed in the _destroy method when the proxy is destroyed
    
    return result;
}

@end
