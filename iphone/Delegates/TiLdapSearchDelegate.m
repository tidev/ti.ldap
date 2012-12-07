//
//  TiLdapSearchDelegate.m
//  ldap
//
//  Created by Jeff English on 12/6/12.
//
//

#import "TiLdapSearchDelegate.h"
#import "TiLdapSearchResultProxy.h"
#import "TiUtils.h"

@implementation TiLdapSearchDelegate

+(id)delegateWithProxyAndArgs:(TiLdapConnectionProxy*)connection args:(NSDictionary*)args
{
    return [[[self alloc] initWithProxy:connection args:args] autorelease];
}

-(void)startPollingForResult
{
    [self retain];
    [NSThread detachNewThreadSelector:@selector(pollForResult) toTarget:self withObject:nil];
}

-(void)pollForResult
{
    LDAPMessage *message = NULL;
    int err = -1;
    
    int result = ldap_result(_connection.ld, _messageId, LDAP_MSG_ALL, NULL, &message);
    switch (result) {
        case LDAP_RES_SEARCH_ENTRY:
        case LDAP_RES_SEARCH_RESULT: {
            //NOTE: DO NOT FREE THE MESSAGE
            int rc = ldap_parse_result(_connection.ld, message, &err, NULL, NULL, NULL, NULL, 0 );
            if ((rc == LDAP_SUCCESS) && (err == LDAP_SUCCESS)) {
                TiLdapSearchResultProxy *searchResult = [TiLdapSearchResultProxy resultWithLDAPMessage:message connection:_connection];
                [self handleSuccess:searchResult];
                // Set message to NULL so it does NOT get freed below
                message = NULL;
            }
            break;
        }
        case 0:
        case -1: {
            // An error occurred for the asynchronous operation. Get the actual error code.
            ldap_get_option(_connection.ld, LDAP_OPT_RESULT_CODE, &err);
            [self handleError:err
                 errorMessage:[NSString stringWithUTF8String:ldap_err2string(err)]
                       method:@"search"];
            break;
        }
        default: {
            NSLog(@"[ERROR] Unexpected response from ldap_result");
            [self handleError:result
                 errorMessage:@"Unexpected response from ldap_result"
                       method:@"search"];
            break;
        }
    }

    if (message != NULL) {
        ldap_msgfree(message);
    }
    
    [self release];
}

-(void)search:(NSDictionary*)args
{
    BOOL async = [TiUtils boolValue:@"async" properties:args def:NO];
    NSString *base = [TiUtils stringValue:@"base" properties:args];
    int scope = [TiUtils intValue:@"scope" properties:args def:LDAP_SCOPE_DEFAULT];
    NSString *filter = [TiUtils stringValue:@"filter" properties:args def:nil];
    
    // Attributes are passed as an array of strings. Convert to an array of UTF8 strings.
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
    id timeout = [args objectForKey:@"timeout"];
    struct timeval *timeVal = NULL;
    if (timeout) {
        timeVal = (struct timeval *)malloc(sizeof(struct timeval));
        timeVal->tv_sec = [TiUtils intValue:@"sec" properties:timeout def:1];
        timeVal->tv_usec = [TiUtils intValue:@"usec" properties:timeout def:0];
    }
    
    int sizeLimit = [TiUtils intValue:@"sizeLimit" properties:args def:0];
    
    int result;
    LDAPMessage *search_result;
    _messageId = -1;
    
    if (async) {
        result = ldap_search_ext(_connection.ld,
                                 [base UTF8String],
                                 scope,
                                 [filter UTF8String],
                                 (char**)attrs,
                                 attrsOnly,
                                 NULL,
                                 NULL,
                                 timeVal,
                                 sizeLimit,
                                 &_messageId);
        // Get the last result code
        ldap_get_option(_connection.ld, LDAP_OPT_RESULT_CODE, &result);
    } else {
        result = ldap_search_ext_s(_connection.ld,
                                   [base UTF8String],
                                   scope,
                                   [filter UTF8String],
                                   (char**)attrs,
                                   attrsOnly,
                                   NULL,
                                   NULL,
                                   timeVal,
                                   sizeLimit,
                                   &search_result);
    }
    
    if (attrs) {
        free(attrs);
    }
    if (timeVal) {
        free(timeVal);
    }
    
    // If we have a messageId then this is a valid asynchronouse request and we need to start
    // polling for the result. Otherwise, if it was successful then we need to return the
    // result proxy. Otherwise, an error occurred and we need to report that and clean up.
    
    if (_messageId >= 0) {
        [self startPollingForResult];
    } else if (result == LDAP_SUCCESS) {
        TiLdapSearchResultProxy *searchResult = [[[TiLdapSearchResultProxy alloc] initWithLDAPMessage:search_result connection:_connection] autorelease];
        [self handleSuccess:searchResult];
    } else {
        [self handleError:result
             errorMessage:[NSString stringWithUTF8String:ldap_err2string(result)]
                   method:@"search"];
        if (search_result) {
            ldap_msgfree(search_result);
        }
    }
}

@end
