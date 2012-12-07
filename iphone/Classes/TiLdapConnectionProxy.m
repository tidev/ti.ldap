/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapConnectionProxy.h"
#import "TiLdapSearchResultProxy.h"
#import "TiLdapDelegate.h"
#import "TiLdapBindDelegate.h"
#import "TiLdapSearchDelegate.h"
#import "TiLdapOptions.h"

#import "TiUtils.h"

#include <sasl/sasl.h>

@implementation TiLdapConnectionProxy

-(id)init
{
    if (self = [super init]) {
        ld = NULL;
    }
    
    return self;
}

-(void)_destroy
{
    if (ld) {
        ldap_unbind(ld);
    }
    
    [super _destroy];
}

-(LDAP*)ld
{
    return ld;
}

-(void)connect:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the delegate for the callbacks eventhough this method
    // is synchronous. This allows us to centrally handle the callbacks
    TiLdapDelegate *delegate = [TiLdapDelegate delegateWithProxyAndArgs:self args:args];
    
    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1:389"];
  
    NSLog(@"[DEBUG] LDAP initialize with url: %@", uri);

    int result = ldap_initialize(&ld, [uri UTF8String]);
    if (result == LDAP_SUCCESS) {
        [TiLdapOptions processOptions:ld args:[self allProperties]];
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               uri, @"uri",
                               nil ];
        [delegate handleSuccess:event];
    } else {
        [delegate handleError:result
                 errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]
                       method:@"connect"];
    }
    
    return NUMINT(result);
}

-(void)simpleBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary)
    
    // Create the delegate that implements the bind and handles the callbacks
    TiLdapBindDelegate *delegate = [TiLdapBindDelegate delegateWithProxyAndArgs:self args:args];
    [delegate simpleBind:args];
}

-(NSNumber*)unBind:(id)args
{
    int result = LDAP_SUCCESS;
    if (ld) {
        result = ldap_unbind_ext(ld, NULL, NULL);
        ld = NULL;
    }
    
    return NUMINT(result);
}

-(void)search:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // Create the delegate that implements the search and handles the callbacks
    TiLdapSearchDelegate *delegate = [TiLdapSearchDelegate delegateWithProxyAndArgs:self args:args];
    [delegate search:args];
}


typedef struct my_ldap_auth MyLDAPAuth;
struct my_ldap_auth
{
    char * mech;
    char * authuser;
    char * user;
    char * realm;
    char * passwd;
};

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


-(NSNumber*)saslBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    // dn is always ignored on sasl bind
//    NSString *dn = [TiUtils stringValue:@"dn" properties:args def:nil];
    NSString *mech = [TiUtils stringValue:@"mech" properties:args def:nil];
    NSString *user = [TiUtils stringValue:@"user" properties:args def:nil];
    NSString *realm = [TiUtils stringValue:@"realm" properties:args def:nil];
    NSString *passwd = [TiUtils stringValue:@"passwd" properties:args def:nil];
    BOOL cert = [TiUtils boolValue:@"cert" properties:args def:NO];
    
    if (cert) {
        int result = ldap_start_tls_s(ld, NULL, NULL);
        if (result != LDAP_SUCCESS) {
            char *msg;
            ldap_get_option(ld, LDAP_OPT_DIAGNOSTIC_MESSAGE, (void*)&msg);
            NSLog(@"[ERROR] Error occurred in starting TLS: %s", msg);
            ldap_memfree(msg);
        } else {
            NSLog(@"[INFO] TLS established");
        }
    }
    
    MyLDAPAuth auth;
    memset(&auth, 0, sizeof(MyLDAPAuth));
    auth.mech = mech ? strdup([mech UTF8String]) : NULL;
    auth.authuser = user ? strdup([user UTF8String]) : NULL;
    auth.realm = realm ? strdup([realm UTF8String]) : NULL;
    auth.passwd = passwd ? strdup([passwd UTF8String]) : NULL;
    
    if (!auth.mech) {
        ldap_get_option(ld, LDAP_OPT_X_SASL_MECH, &auth.mech);
    }
    if (!auth.authuser) {
        ldap_get_option(ld, LDAP_OPT_X_SASL_AUTHCID, &auth.authuser);
    }
    if (!auth.realm) {
        ldap_get_option(ld, LDAP_OPT_X_SASL_REALM, &auth.realm);
    }
    ldap_get_option(ld, LDAP_OPT_X_SASL_AUTHZID, &auth.user);
    
    NSLog(@"[DEBUG] LDAP saslBind with:");
    NSLog(@"[DEBUG]      Mech:      %s", auth.mech     ? auth.mech     : "(NULL)");
    NSLog(@"[DEBUG]      User:      %s", auth.user     ? auth.user     : "(NULL)");
    NSLog(@"[DEBUG]      Auth User: %s", auth.authuser ? auth.authuser : "(NULL)");
    NSLog(@"[DEBUG]      Realm:     %s", auth.realm    ? auth.realm    : "(NULL)");
    NSLog(@"[DEBUG]      Passwd:    %s", auth.passwd   ? auth.passwd   : "(NULL)");
    
    // dn is always ignored on sasl bind
    int result = ldap_sasl_interactive_bind_s(ld, NULL, auth.mech, NULL, NULL, LDAP_SASL_QUIET, ldap_sasl_interact, &auth);
    if (result != LDAP_SUCCESS) {
        NSLog(@"[ERROR] Error occurred in sasl bind: (%d) %s", result, ldap_err2string(result));
    }
    return NUMINT(result);
}


@end
