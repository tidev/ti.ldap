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

+(id)requestWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initRequest:@"saslBind" connection:connection args:args] autorelease];
}

-(void)_destroy
{
    if (_auth.mech) {
        free(_auth.mech);
    }
    if (_auth.authuser) {
        free(_auth.authuser);
    }
    if (_auth.passwd) {
        free(_auth.passwd);
    }
    if (_auth.realm) {
        free(_auth.realm);
    }
    if (_auth.user) {
        free(_auth.user);
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
    
    NSLog(@"      entering my_ldap_sasl_interact_proc()");
    for(interact = sin; (interact->id != SASL_CB_LIST_END); interact++)
    {
        interact->result = NULL;
        interact->len    = 0;
        switch( interact->id )
        {
            case SASL_CB_GETREALM:
                NSLog(@"         processing SASL_CB_GETREALM (%s)", ldap_inst->realm ? ldap_inst->realm : "");
                interact->result = ldap_inst->realm ? ldap_inst->realm : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_AUTHNAME:
                NSLog(@"         processing SASL_CB_AUTHNAME (%s)", ldap_inst->authuser ? ldap_inst->authuser : "");
                interact->result = ldap_inst->authuser ? ldap_inst->authuser : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_PASS:
                NSLog(@"         processing SASL_CB_PASS (%s)", ldap_inst->passwd ? ldap_inst->passwd : "");
                interact->result = ldap_inst->passwd ? ldap_inst->passwd : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_USER:
                NSLog(@"         processing SASL_CB_USER (%s)", ldap_inst->user ? ldap_inst->user : "");
                interact->result = ldap_inst->user ? ldap_inst->user : "";
                interact->len    = strlen( interact->result );
                break;
            case SASL_CB_NOECHOPROMPT:
                NSLog(@"         processing SASL_CB_NOECHOPROMPT");
                break;
            case SASL_CB_ECHOPROMPT:
                NSLog(@"         processing SASL_CB_ECHOPROMPT");
                break;
            default:
                NSLog(@"         I don't know how to process this.");
                break;
        };
    };
    NSLog(@"      exiting my_ldap_sasl_interact_proc()");
    
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
    //BUGBUG -- this needs to occur in a thread
    if (_connection.useTLS) {
        NSLog(@"[INFO] Starting TLS");
        int result = ldap_start_tls_s(_connection.ld, NULL, NULL);
        if (result != LDAP_SUCCESS) {
            char *msg;
            ldap_get_option(_connection.ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
            NSLog(@"[ERROR] Error occurred in starting TLS: %s (%s)", ldap_err2string(result), msg);
            ldap_memfree(msg);
        } else {
            NSLog(@"[INFO] TLS established");
        }
    }
    
    memset(&_auth, 0, sizeof(MyLDAPAuth));
    
    // dn is always ignored on sasl bind
    _auth.mech = [self getAuthValue:@"mech" args:args option:LDAP_OPT_X_SASL_MECH];
    _auth.authuser = [self getAuthValue:@"user" args:args option:LDAP_OPT_X_SASL_AUTHCID];
    _auth.realm = [self getAuthValue:@"realm" args:args option:LDAP_OPT_X_SASL_REALM];
    _auth.passwd = [self getAuthValue:@"password" args:args option:-1];
    
    NSLog(@"[DEBUG] LDAP saslBind with:");
    NSLog(@"[DEBUG]      Mech:      %s", _auth.mech     ? _auth.mech     : "(NULL)");
    NSLog(@"[DEBUG]      User:      %s", _auth.user     ? _auth.user     : "(NULL)");
    NSLog(@"[DEBUG]      Auth User: %s", _auth.authuser ? _auth.authuser : "(NULL)");
    NSLog(@"[DEBUG]      Realm:     %s", _auth.realm    ? _auth.realm    : "(NULL)");
    NSLog(@"[DEBUG]      Passwd:    %s", _auth.passwd   ? _auth.passwd   : "(NULL)");
    
    int result;
    
    if (async) {
        const char *rmech = NULL;
        result = ldap_sasl_interactive_bind(_connection.ld, NULL, _auth.mech, NULL, NULL, LDAP_SASL_QUIET, ldap_sasl_interact, &_auth, NULL, &rmech, &_messageId);
    } else {
        result = ldap_sasl_interactive_bind_s(_connection.ld, NULL, _auth.mech, NULL, NULL, LDAP_SASL_QUIET, ldap_sasl_interact, &_auth);
    }
    
    // NOTE: Do NOT free the memory allocated by getAuthValue -- it will be freed in the _destroy method when the proxy is destroyed
    
    return result;
}

@end
