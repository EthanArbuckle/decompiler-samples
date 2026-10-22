struct FBWorkspaceEndpointPromise {
    BSServiceConnectionEndpoint *_lock_endpoint; // +0x8
    __weak FBWorkspaceDomain *_lock_domain; // +0x10
    NSString *_domainIdentifier; // +0x18
    struct os_unfair_lock_s _lock; // +0x20
};

BSServiceConnectionEndpoint *-[FBWorkspaceEndpointPromise endpoint](void)
{
    if (!self) {
        return nil;
    }
    os_unfair_lock_lock(&self->_lock);
    BSServiceConnectionEndpoint *v1 = self->_lock_endpoint;
    if (!self->_lock_endpoint) {
        FBWorkspaceDomain *v2 = self->_lock_domain;
        if (!v2) {
            self->_lock_endpoint = [FBWorkspaceDomain nullEndpoint];
        } else {
            BSServiceConnectionEndpoint *_listenerEndpoint = [v2 _listenerEndpoint];
            self->_lock_endpoint = (!_listenerEndpoint) ? [FBWorkspaceDomain nullEndpoint] : _listenerEndpoint;
        }
        v1 = self->_lock_endpoint;
    }
    os_unfair_lock_unlock(&self->_lock);
    return v1;
}


id -[FBWorkspaceEndpointPromise initWithEndpoint:](long a1)
{
    if (!self) {
        return self;
    } else {
        return [self _initWithDomain:0 identifier:0 endpoint:a1];
    }
}


FBWorkspaceEndpointPromise *-[FBWorkspaceEndpointPromise _initWithDomain:identifier:endpoint:](FBWorkspaceDomain *a1, id a2, BSServiceConnectionEndpoint *a3)
{
    if (self != nil) {
        self = [super init];
        if (self != nil) {
            memset(&self->_lock, 0, 4);
            self->_lock_domain = a1;
            self->_domainIdentifier = [a2 copy];
            self->_lock_endpoint = a3;
        }
    }
    return self;
}


NSString *-[FBWorkspaceEndpointPromise _domainIdentifier](void)
{
    NSString *v4 = nil;
    if (self != nil) {
        if (!self->_domainIdentifier) {
            NSString *v1 = [NSString stringWithFormat:@"never nil if created by FBWorkspaceDomain"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_domainIdentifier));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceDomain.m", 692, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        v4 = self->_domainIdentifier;
    }
    return v4;
}


void -[FBWorkspaceEndpointPromise .cxx_destruct](void)
{
    self->_domainIdentifier = nil;
    self->_lock_domain = nil;
    self->_lock_endpoint = nil;
}


NSString *-[FBWorkspaceEndpointPromise description](void)
{
    NSString *v1;
    NSString *v7;
    os_unfair_lock_lock(&self->_lock);
    if (!self->_domainIdentifier) {
        v1 = @"";
    } else {
        v1 = self->_domainIdentifier;
        if (!self->_lock_endpoint && !self->_lock_domain) {
            self->_lock_endpoint = [FBWorkspaceDomain nullEndpoint];
        }
    }
    BSServiceConnectionEndpoint *v5 = self->_lock_endpoint;
    os_unfair_lock_unlock(&self->_lock);
    if (!v5) {
        v7 = [NSString stringWithFormat:@"<FBWorkspaceEndpointPromise:%@>", v1];
    } else if (![v5 isNullEndpoint]) {
        NSString *description = [v5 description];
        v7 = [NSString stringWithFormat:@"<FBWorkspaceEndpointPromise:%@ (%@)>", v1, description];
    } else {
        v7 = [NSString stringWithFormat:@"<FBWorkspaceEndpointPromise:%@ (null)>", v1];
    }
    return v7;
}


void *-[FBWorkspaceEndpointPromise isResolvedNullEndpoint](void)
{
    if (!self) {
        return self;
    }
    os_unfair_lock_lock(&self->_lock);
    BSServiceConnectionEndpoint *v1 = self->_lock_endpoint;
    if (!self->_lock_endpoint) {
        if (!self->_lock_domain) {
            self->_lock_endpoint = [FBWorkspaceDomain nullEndpoint];
        }
        v1 = self->_lock_endpoint;
    }
    os_unfair_lock_unlock(&self->_lock);
    return [v1 isNullEndpoint];
}
