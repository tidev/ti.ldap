/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2012 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiLdapConnectionProxy.h"
#import "TiLdapSearchResultProxy.h"

#import "TiUtils.h"

#include <sasl/sasl.h>

@implementation TiLdapConnectionProxy

MAKE_SYSTEM_PROP(SUCCESS, LDAP_SUCCESS);

MAKE_SYSTEM_PROP(OPT_PROTOCOL_VERSION, LDAP_OPT_PROTOCOL_VERSION);
MAKE_SYSTEM_PROP(OPT_X_TLS_CACERTFILE, LDAP_OPT_X_TLS_CACERTFILE);

MAKE_SYSTEM_PROP(VERSION1, LDAP_VERSION1);
MAKE_SYSTEM_PROP(VERSION2, LDAP_VERSION2);
MAKE_SYSTEM_PROP(VERSION3, LDAP_VERSION3);

MAKE_SYSTEM_PROP(SCOPE_BASE, LDAP_SCOPE_BASE);
MAKE_SYSTEM_PROP(SCOPE_ONELEVEL, LDAP_SCOPE_ONELEVEL);
MAKE_SYSTEM_PROP(SCOPE_SUBTREE, LDAP_SCOPE_SUBTREE);
MAKE_SYSTEM_PROP(SCOPE_CHILDREN, LDAP_SCOPE_CHILDREN);
MAKE_SYSTEM_PROP(SCOPE_DEFAULT, LDAP_SCOPE_DEFAULT);

MAKE_SYSTEM_STR(ALL_USER_ATTRIBUTES, LDAP_ALL_USER_ATTRIBUTES);
MAKE_SYSTEM_STR(ALL_OPERATIONAL_ATTRIBUTES, LDAP_ALL_OPERATIONAL_ATTRIBUTES);
MAKE_SYSTEM_STR(NO_ATTRS, LDAP_NO_ATTRS);

-(id)init
{
    if (self = [super init]) {
        ld = NULL;
    }
    
    return self;
}

-(void)_destroy
{
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(errorCallback);
    
    if (ld) {
        ldap_unbind(ld);
        ld = NULL;
    }
    
    [super _destroy];
}

-(void)_initWithProperties:(NSDictionary*)properties
{
	[super _initWithProperties:properties];
    
    successCallback = [[properties objectForKey:@"success"] retain];
    errorCallback = [[properties objectForKey:@"error"] retain];
}

-(NSNumber*)initialize:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);

    NSString *uri = [TiUtils stringValue:@"uri" properties:args def:@"ldap://127.0.0.1"];
    
    //BUGBUG -- if no scheme specified, use 'ldap'

    NSLog(@"[DEBUG] LDAP initialize with uri: %@", uri);
    int result = ldap_initialize(&ld, [uri UTF8String]);
    if (result != LDAP_SUCCESS) {
        NSLog(@"[ERROR] Error occurred during LDAP initialization: (%d) %s", result, ldap_err2string(result));
    }
    
    return NUMINT(result);
}

-(LDAP*)ld
{
    return ld;
}

//NOTE: The switch statement should be moved to a module method that accepts an ld so that the module can use the same
// method to set global options
-(NSNumber*)setOption:(id)args
{
    enum args {
        kArgOption = 0,
        kArgValue,
        kArgCount
    };
    
    // Validate correct number of arguments
    ENSURE_ARG_COUNT(args, kArgCount);
    
    int option = [TiUtils intValue:[args objectAtIndex:kArgOption]];
    id inValue = [args objectAtIndex:kArgValue];
    int result;
    
    switch (option) {
        case LDAP_OPT_PROTOCOL_VERSION: {
            int value = [TiUtils intValue:inValue];
            NSLog(@"[DEBUG] Setting LDAP_OPT_PROTOCOL_VERSION to %d", value);
            result = ldap_set_option(ld, option, &value);
            NSLog(@"[DEBUG] Result: %d", result);
            break;
        }
        case LDAP_OPT_X_TLS_CACERTFILE: {
            if ([inValue isKindOfClass:[TiFile class]]) {
                TiFile *file = (TiFile*)inValue;
                NSString *path = [file path];
                NSLog(@"[DEBUG] Setting LDAP_OPT_X_TLS_CACERTFILE to file: %@", path);
                result = ldap_set_option(ld, LDAP_OPT_X_TLS_CACERTFILE, [path UTF8String]);
                NSLog(@"[DEBUG] Result: %d", result);
            }
            break;
        }
    }
    
    return NUMINT(result);
}

-(id)getOption:(id)arg
{
    ENSURE_ARG_COUNT(arg, 1);
    
    int option = [TiUtils intValue:[arg objectAtIndex:0]];
    int result;
    id outValue;
    
    switch (option) {
        case LDAP_OPT_PROTOCOL_VERSION: {
            int value;
            result = ldap_get_option(ld, option, &value);
            if (result == LDAP_SUCCESS) {
                outValue = NUMINT(value);
            }
            break;
        }
    }
    
    if (result != LDAP_SUCCESS) {
        NSLog(@"[ERROR] Error occurred getting LDAP option %d: (%d) %s", option, result, ldap_err2string(result));
        return nil;
    }
    
    return outValue;;
}

-(NSNumber*)simpleBind:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *dn = [TiUtils stringValue:@"dn" properties:args];
    NSString *passwd = [TiUtils stringValue:@"passsword" properties:args];

    NSLog(@"[DEBUG] LDAP simpleBind with dn: %@", dn);
    int result = ldap_simple_bind_s(ld, [dn UTF8String], [passwd UTF8String]);
    if (result != LDAP_SUCCESS) {
        NSLog(@"[ERROR] Error occurred in simple bind: (%d) %s", result, ldap_err2string(result));
    }
    
    return NUMINT(result);
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

-(NSNumber*)unBind:(id)args
{
    int result = LDAP_SUCCESS;
    if (ld) {
        result = ldap_unbind_ext(ld, NULL, NULL);
        ld = NULL;
    }
    
    return NUMINT(result);
}

-(id)search:(id)args
{
    //BUGBUG: This needs to be completely refactored to support both sync and async requests. A factory
    // needs to be defined for creating sync and async requests for several of the ldap APIs
    // See the Ti.Network.HTTPClient code for one possible framework
    
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSString *dn = [TiUtils stringValue:@"dn" properties:args];
    int scope = [TiUtils intValue:@"scope" properties:args def:LDAP_SCOPE_DEFAULT];
    NSString *filter = [TiUtils stringValue:@"filter" properties:args def:nil];
    
    NSArray *inAttrs = [args objectForKey:@"attrs"];
    int count = [inAttrs count];
    const char** attrs = NULL;
    if (count > 0) {
        attrs = malloc(sizeof(const char*) * (count+1));
        if (attrs) {
            for (int i=0; i<count; i++) {
                attrs[i] = [[inAttrs objectAtIndex:i] UTF8String];
            }
            // Null terminate the array
            attrs[count] = NULL;
        }
    }
    
    BOOL attrsOnly = [TiUtils boolValue:@"attrsOnly" properties:args def:0];
    KrollCallback *callback = [args objectForKey:@"callback"];

    LDAPMessage *search_result;
    int result = ldap_search_ext_s(ld,
                                   [dn UTF8String],
                                   scope,
                                   [filter UTF8String],
                                   (char**)attrs,
                                   attrsOnly,
                                   NULL,
                                   NULL,
                                   NULL,
                                   0,
                                   &search_result);
    
    if (attrs) {
        free(attrs);
    }
    
    if (result != LDAP_SUCCESS) {
        NSLog(@"[ERROR] Error occurred in search: (%d) %s", result, ldap_err2string(result));
        return nil;
    }

    TiLdapSearchResultProxy *searchResult = [[[TiLdapSearchResultProxy alloc] initWithLDAPMessage:search_result callback:callback connection:self pageContext:[self pageContext]] autorelease];
    
    return searchResult;
}

@end
