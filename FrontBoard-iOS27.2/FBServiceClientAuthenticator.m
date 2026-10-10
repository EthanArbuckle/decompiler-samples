struct FBServiceClientAuthenticator {
    NSString *_entitlement; // +0x8
    unsigned long _credentials; // +0x10
};

long -[FBServiceClientAuthenticator authenticateAuditToken:error:](long a1, long a2)
{
    return [self authenticateAuditToken:a1 forEntitlement:self->_entitlement error:a2];
}


long -[FBServiceClientAuthenticator authenticateClient:](long a1)
{
    return [self authenticateClient:a1 error:0];
}


long -[FBServiceClientAuthenticator authenticateClient:error:](id a1, long a2)
{
    id processHandle = [a1 processHandle];
    BSAuditToken *auditToken = [processHandle auditToken];
    Class v2 = [self class];
    return [v2 _authenticateAuditToken:auditToken entitlement:self->_entitlement credentials:self->_credentials error:a2];
}


bool +[FBServiceClientAuthenticator _authenticateAuditToken:entitlement:credentials:error:](id a1, id a2, int a3, long *a4)
{
    int v5;
    uint8_t v3[32];
    id sharedInstance = [FBProcessManager sharedInstance];
    if (!a1) {
        _memset(v3, 0, 32);
    } else {
        [a1 realToken:&v3];
    }
    id v4 = [sharedInstance registerProcessForAuditToken:&v3];
    if (![v4 isRunning]) {
        v5 = 3;
    } else {
        bool v8 = false;
        if ((a3 & 1) != 0) {
            int pid = [a1 pid];
            long v7 = __getpid(pid);
            v8 = pid == v7;
        }
        if (a2 != nil && !v8) {
            v8 = [a1 hasEntitlement:a2];
        }
        if ((a3 & 4) != 0 && !v8) {
            v8 = [v4 isApplicationProcess];
        }
        if ((a3 & 8) != 0 && !v8 && [v4 isApplicationProcess]) {
            v8 = [v4 isForeground];
        }
        if ((a3 & 2) != 0 && !v8) {
            if (![v4 isApplicationProcess]) {
                v8 = [v4 executableLivesOnSystemPartition];
            } else {
                FBSApplicationInfo *applicationInfo = [v4 applicationInfo];
                v8 = [applicationInfo type] != 2;
            }
        }
        v5 = (v8) ? 0 : 13;
    }
    if (a4 != 0 && v5 != 0) {
        *(a4) = [FBServiceClientAuthenticator _errorForCode:v5 process:v4 failedEntitlement:a2];
    }
    return !v5;
}


long +[FBServiceClientAuthenticator authenticateAuditToken:forEntitlement:error:](struct AnonymousStruct_11 *a1, id a2, long a3)
{
    if (!a2) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"entitlement"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBServiceClientAuthenticator.m", 103, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    BSAuditToken *v1 = [BSAuditToken alloc];
    struct AnonymousStruct_11 v2 = *(struct AnonymousStruct_11 *)a1;
    return [FBServiceClientAuthenticator _authenticateAuditToken:[v1 initWithAuditToken:&v2] entitlement:a2 credentials:0 error:a3];
}


FBServiceClientAuthenticator *+[FBServiceClientAuthenticator sharedSystemClientAuthenticator](void)
{
    dispatch_once(&sharedSystemClientAuthenticator.onceToken, ^void(void) {
        sharedSystemClientAuthenticator.__authenticator = [[FBServiceClientAuthenticator alloc] initWithCredentials:3];
    });
    return sharedSystemClientAuthenticator.__authenticator;
}


long -[FBServiceClientAuthenticator authenticateAuditToken:forEntitlement:error:](id a1, id a2, long a3)
{
    Class v2 = [self class];
    return [v2 _authenticateAuditToken:a1 entitlement:a2 credentials:self->_credentials error:a3];
}


FBServiceClientAuthenticator *+[FBServiceClientAuthenticator sharedUIAppClientAuthenticator](void)
{
    dispatch_once(&sharedUIAppClientAuthenticator.onceToken, ^void(void) {
        sharedUIAppClientAuthenticator.__authenticator = [[FBServiceClientAuthenticator alloc] initWithCredentials:5];
    });
    return sharedUIAppClientAuthenticator.__authenticator;
}


FBServiceClientAuthenticator *+[FBServiceClientAuthenticator sharedForegroundUIAppClientAuthenticator](void)
{
    dispatch_once(&sharedForegroundUIAppClientAuthenticator.onceToken, ^void(void) {
        sharedForegroundUIAppClientAuthenticator.__authenticator = [[FBServiceClientAuthenticator alloc] initWithCredentials:9];
    });
    return sharedForegroundUIAppClientAuthenticator.__authenticator;
}


FBServiceClientAuthenticator *-[FBServiceClientAuthenticator init](void)
{
    FBServiceClientAuthenticator *v1 = [super init];
    if (v1 != nil) {
        v1->_credentials = 1;
    }
    return v1;
}


FBServiceClientAuthenticator *-[FBServiceClientAuthenticator initWithCredentials:](unsigned long a1)
{
    FBServiceClientAuthenticator *v0 = [self init];
    if (v0 != nil) {
        v0->_credentials = a1;
    }
    return v0;
}


FBServiceClientAuthenticator *-[FBServiceClientAuthenticator initWithEntitlement:](long a1)
{
    return [self initWithEntitlement:a1 additionalCredentials:1];
}


FBServiceClientAuthenticator *-[FBServiceClientAuthenticator initWithEntitlement:additionalCredentials:](id a1, unsigned long a2)
{
    FBServiceClientAuthenticator *v1 = [self init];
    if (v1 != nil) {
        v1->_entitlement = [a1 copy];
        v1->_credentials = a2;
    }
    return v1;
}


long -[FBServiceClientAuthenticator authenticateAuditToken:](long a1)
{
    return [self authenticateAuditToken:a1 error:0];
}


NSError *+[FBServiceClientAuthenticator _errorForCode:process:failedEntitlement:](NSInteger a1, id a2, id a3)
{
    NSString *v2;
    if (a1 == 3) {
        v2 = @"No such process.";
    } else {
        v2 = (a1 != 13 || !a3) ? @"Process lacks credentials to access this resource." : [NSString stringWithFormat:@"Entitlement \"%@\" is required to access this resource.", a3];
    }
    NSString *v3 = [NSString stringWithFormat:@"Authentication failed: %@", v2];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:v3 forKey:NSLocalizedDescriptionKey];
    [dictionary setObject:v2 forKey:NSLocalizedFailureReasonErrorKey];
    if (a3 != nil) {
        [dictionary setObject:a3 forKey:@"Entitlement"];
    }
    if (a2 != nil) {
        id v5 = FBSProcessPrettyDescription(a2);
        [dictionary setObject:v5 forKey:@"FBProcess"];
    }
    return [NSError errorWithDomain:@"FBServiceClientAuthenticatorErrorDomain" code:(int32_t)a1 userInfo:dictionary];
}


id -[FBServiceClientAuthenticator succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBServiceClientAuthenticator succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    NSString *entitlement = [self entitlement];
    [v0 appendObject:entitlement withName:@"entitlement" skipIfNil:1];
    [v0 appendUnsignedInteger:self->_credentials withName:@"credentials"];
    return v0;
}


id -[FBServiceClientAuthenticator descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


long -[FBServiceClientAuthenticator descriptionBuilderWithMultilinePrefix:](long a1)
{
    return [self succinctDescriptionBuilder];
}


NSString *-[FBServiceClientAuthenticator entitlement](void)
{
    return self->_entitlement;
}


unsigned long -[FBServiceClientAuthenticator credentials](void)
{
    return self->_credentials;
}


void -[FBServiceClientAuthenticator .cxx_destruct](void)
{
    self->_entitlement = nil;
}
