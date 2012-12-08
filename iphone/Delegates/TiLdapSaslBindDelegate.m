//
//  TiLdapSaslBindDelegate.m
//  ldap
//
//  Created by Jeff English on 12/6/12.
//
//

#import "TiLdapSaslBindDelegate.h"
#import "TiUtils.h"

#include <sasl/sasl.h>

@implementation TiLdapSaslBindDelegate

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initWithProxy:connection args:args] autorelease];
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


/*
 From the UnboundID documentation:
 
 Note, however, that LDAP does place restrictions on asynchronous operation processing.
 In particular, bind operations and StartTLS operations must always be processed in a
 synchronous manner. If a client is going to process asynchronous operations, then it
 must take care to ensure that it does not attempt to process bind or StartTLS operations
 while other operations may be in progress.
 */

-(void)saslBind:(NSDictionary*)args
{
    // dn is always ignored on sasl bind
    NSString *mech = [TiUtils stringValue:@"mech" properties:args def:nil];
    NSString *user = [TiUtils stringValue:@"user" properties:args def:nil];
    NSString *realm = [TiUtils stringValue:@"realm" properties:args def:nil];
    NSString *passwd = [TiUtils stringValue:@"password" properties:args def:nil];
    
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
    
    MyLDAPAuth auth;
    memset(&auth, 0, sizeof(MyLDAPAuth));
    
    if (mech) {
        auth.mech = strdup([mech UTF8String]);
    } else {
        ldap_get_option(_connection.ld, LDAP_OPT_X_SASL_MECH, &auth.mech);
    }
    
    if (user) {
        auth.authuser = strdup([user UTF8String]);
    } else {
        ldap_get_option(_connection.ld, LDAP_OPT_X_SASL_AUTHCID, &auth.authuser);
    }
    
    if (realm) {
        auth.realm = strdup([realm UTF8String]);
    } else {
        ldap_get_option(_connection.ld, LDAP_OPT_X_SASL_REALM, &auth.realm);
    }
    
    if (passwd) {
        auth.passwd = strdup([passwd UTF8String]);
    } else {
        auth.passwd = NULL;
    }
    
    //BUGBUG Need to ldap_memfree IF option retrieved from ldap
    
    NSLog(@"[DEBUG] LDAP saslBind with:");
    NSLog(@"[DEBUG]      Mech:      %s", auth.mech     ? auth.mech     : "(NULL)");
    NSLog(@"[DEBUG]      User:      %s", auth.user     ? auth.user     : "(NULL)");
    NSLog(@"[DEBUG]      Auth User: %s", auth.authuser ? auth.authuser : "(NULL)");
    NSLog(@"[DEBUG]      Realm:     %s", auth.realm    ? auth.realm    : "(NULL)");
    NSLog(@"[DEBUG]      Passwd:    %s", auth.passwd   ? auth.passwd   : "(NULL)");
    
    int result = ldap_sasl_interactive_bind_s(_connection.ld, NULL, auth.mech, NULL, NULL, LDAP_SASL_QUIET, ldap_sasl_interact, &auth);
    
    if (mech) {
        free(auth.mech);
    } else {
        ldap_memfree(auth.mech);
    }
    
    if (user) {
        free(auth.user);
    } else {
        ldap_memfree(auth.user);
    }
    
    if (realm) {
        free(auth.realm);
    } else {
        ldap_memfree(auth.realm);
    }
    
    if (passwd) {
        free(auth.passwd);
    } else {
        ldap_memfree(auth.passwd);
    }
    
    if (result == LDAP_SUCCESS) {
        _connection.bound = YES;
        [self handleSuccess:nil];
    } else {
        [self handleError:result
             errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]
                   method:@"saslBind"];
    }
}
@end
