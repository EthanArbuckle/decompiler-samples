struct FBServiceFacilityServer {
    struct os_unfair_lock_s _lock; // +0x8
    BSServiceDomainSpecification *_domain; // +0x10
    BSServiceConnectionListener *_serviceListener; // +0x18
    NSMutableDictionary *_lock_facilitiesByIdentifier; // +0x20
    NSMutableSet *_lock_completedMilestones; // +0x28
    NSMutableDictionary *_lock_suspendedFacilitiesByIdentifier; // +0x30
    NSMutableSet *_lock_pendingConnects; // +0x38
};

id +[FBServiceFacilityServer sharedInstanceDomain](void)
{
    dispatch_once(&sharedInstanceDomain.onceToken, ^void(void) {
        id bootstrapConfiguration = [BSServicesConfiguration bootstrapConfiguration];
        id identifier = [FBSSystemServiceSpecification identifier];
        id v2 = [bootstrapConfiguration domainsContainingServiceIdentifier:identifier];
        if ([v2 count] != 0) {
            if ([v2 count] != 1) {
                id identifier3 = [FBSSystemServiceSpecification identifier];
                NSString *v8 = [NSString stringWithFormat:@"must have one and only one domain specify %@ : domains=%@", identifier3, v2];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v9 = NSStringFromSelector(_cmd);
                    NSString *v10 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBServiceFacilityServer.m", 104, v8);
                }
                _bs_set_crash_log_message([v8 UTF8String]);
                __break(0);
            }
            sharedInstanceDomain.__domain = [v2 anyObject];
        }
        id environmentAliases = [BSMachServiceAliases environmentAliases];
        id defaultShellMachName = [BSServiceConnectionEndpoint defaultShellMachName];
        id v5 = [environmentAliases resolveMachService:defaultShellMachName];
        id v6 = [bootstrapConfiguration domainForMachName:v5];
        if (v6 != 0 && v6 != sharedInstanceDomain.__domain) {
            id identifier2 = [FBSSystemServiceSpecification identifier];
            NSString *v13 = [NSString stringWithFormat:@"if we own the defaultShellMachName then %@ must be registered there", identifier2];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v14 = NSStringFromSelector(_cmd);
                NSString *v15 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBServiceFacilityServer.m", 109, v13);
            }
            _bs_set_crash_log_message([v13 UTF8String]);
            __break(0);
        }
    });
    return sharedInstanceDomain.__domain;
}


void -[FBServiceFacilityServer listener:didReceiveConnection:withContext:](long a1, id a2, id a3)
{
    uint8_t v4[32];
    id v7;
    id v0 = a2;
    id sharedInstance = [FBProcessManager sharedInstance];
    id remoteToken = [v0 remoteToken];
    if (!remoteToken) {
        _memset(v4, 0, 32);
    } else {
        [remoteToken realToken:&v4];
    }
    [sharedInstance registerProcessForAuditToken:&v4];
    os_unfair_lock_lock(&self->_lock);
    id v5 = [a3 decodeStringForKey:FBSServiceFacilityMessageKeyFacilityID];
    if (!v5 || !(v7 = [self->_lock_facilitiesByIdentifier objectForKey:v5])) {
        [v0 invalidate];
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    FBServiceFacilityServerClientHandle *v10 = [[FBServiceFacilityServerClientHandle alloc] initWithFacilityID:[v7 identifier] connection:v0];
    [v0 _configureConnection:^void(id<BSServiceConnectionInternalConfiguring> arg1) {
        [arg1 setMessageHandler:^void(id<BSInvalidatable> arg1, id<BSXPCServiceConnectionMessage> arg2) {
            [self _facilityQueue_facility:v7 handleMessage:arg2 client:v10];
        }];
        [arg1 setErrorHandler:^void(id<BSInvalidatable> arg1, NSError *arg2) {
            [v7 queue_clientDidDisconnect:v10];
            [arg1 invalidate];
        }];
        BSServiceDispatchQueue *queue = [v7 queue];
        [arg1 setQueue:queue];
    }];
    if (![self _lock_areFacilityPrerequisitesSatisfied:v7]) {
        id v14 = [_FBServiceFacilityServerPendingConnection pendingConnectionToFacility:v7 completion:^void(void) {
            [v0 activate];
        }];
        [self->_lock_pendingConnects addObject:v14];
    } else {
        [v0 activate];
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBServiceFacilityServer _facilityQueue_facility:handleMessage:client:](id a1, id a2, id a3)
{
    int64_t v3 = [a2 decodeInt64ForKey:FBSServiceFacilityMessageKeyMessageType];
    if (v3 != 0x636f6e6e656374) {
        id v4 = [FBSXPCMessage messageWithBSXPCMessage:a2 ownReply:1];
        [a1 queue_handleMessage:v4 withType:v3 fromClient:a3];
    } else {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *v6 = NSStringFromClass([self class]);
            id prettyProcessDescription = [a3 prettyProcessDescription];
            NSString *facilityID = [a3 facilityID];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Client %{public}@ connected to service %{public}@", v6, prettyProcessDescription, facilityID);
        }
        id createReply = [a2 createReply];
        id v11 = [FBSXPCMessage messageWithBSXPCMessage:a2 ownReply:0];
        BOOL v12 = [a1 queue_clientDidConnect:a3 withMessage:v11];
        [createReply encodeBool:v12 forKey:FBSServiceFacilityMessageKeyServiceAccepted];
        [createReply encodeObject:(v12) ? nil : @"Connection rejected by service facility" forKey:FBSServiceFacilityMessageKeyErrorDescription];
        [createReply send];
        if (!v12) {
            [a3 invalidate];
        }
    }
}


BOOL -[FBServiceFacilityServer _lock_areFacilityPrerequisitesSatisfied:](id a1)
{
    BOOL v2;
    os_unfair_lock_assert_owner(&self->_lock);
    id _prerequisiteMilestones = [a1 _prerequisiteMilestones];
    if (!_prerequisiteMilestones) {
        return YES;
    }
    if ([_prerequisiteMilestones count]) {
        v2 = [_prerequisiteMilestones isSubsetOfSet:self->_lock_completedMilestones];
    } else {
        v2 = YES;
    }
    return v2;
}


id +[FBServiceFacilityServer sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        id sharedInstanceDomain = [FBServiceFacilityServer sharedInstanceDomain];
        if (!sharedInstanceDomain) {
            id identifier = [FBSSystemServiceSpecification identifier];
            id bootstrapConfiguration = [BSServicesConfiguration bootstrapConfiguration];
            NSString *v3 = [NSString stringWithFormat:@"must have a valid domain for %@ : bootstrapConfiguration = %@", identifier, bootstrapConfiguration];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v4 = NSStringFromSelector(_cmd);
                NSString *v5 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v4, v5, self, @"FBServiceFacilityServer.m", 91, v3);
            }
            _bs_set_crash_log_message([v3 UTF8String]);
            __break(0);
        }
        sharedInstance.__instance = [[FBServiceFacilityServer alloc] _initWithDomain:sharedInstanceDomain];
    });
    return sharedInstance.__instance;
}


FBServiceFacilityServer *-[FBServiceFacilityServer _initWithDomain:](BSServiceDomainSpecification *a1)
{
    if (!a1) {
        NSString *v14 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"domain"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v15 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBServiceFacilityServer.m", 121, v14);
        }
        _bs_set_crash_log_message([v14 UTF8String]);
        __break(0);
    }
    FBServiceFacilityServer *v1 = [super init];
    if (v1 != nil) {
        v1->_lock._os_unfair_lock_opaque = 0;
        v1->_domain = a1;
        v1->_lock_pendingConnects = [[NSMutableSet alloc] init];
        v1->_lock_completedMilestones = [[NSMutableSet alloc] init];
        v1->_lock_facilitiesByIdentifier = [[NSMutableDictionary alloc] init];
        v1->_lock_suspendedFacilitiesByIdentifier = [[NSMutableDictionary alloc] init];
        v1->_serviceListener = [BSServiceConnectionListener listenerWithConfigurator:^void(id<BSServiceConnectionListenerConfiguring> arg1) {
            id identifier = [v1->_domain identifier];
            [arg1 setDomain:identifier];
            id identifier2 = [FBSSystemServiceSpecification identifier];
            [arg1 setService:identifier2];
            [arg1 setDelegate:v1];
        }];
        FBSSetServiceFacilityManager(v1);
    }
    return v1;
}


void -[FBServiceFacilityServer run](void)
{
    [self->_serviceListener activate];
}


void -[FBServiceFacilityServer addFacility:](id a1)
{
    id<NSCopying> identifier = [a1 identifier];
    if (!identifier) {
        NSString *v8 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"identifier != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBServiceFacilityServer.m", 189, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    if (![a1 queue]) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[facility queue] != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBServiceFacilityServer.m", 190, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    id v3 = [self->_lock_facilitiesByIdentifier objectForKey:identifier];
    if (v3 != nil) {
        NSString *v16 = [NSString stringWithFormat:@"duplicate facility with identifier %@", identifier];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBServiceFacilityServer.m", 193, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *v5 = NSStringFromClass([self class]);
        id succinctDescription = [a1 succinctDescription];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Adding facility: %{public}@", v5, succinctDescription);
    }
    [self->_lock_facilitiesByIdentifier setObject:a1 forKey:identifier];
    [self->_lock_suspendedFacilitiesByIdentifier setObject:a1 forKey:identifier];
    [self _lock_evaluateSuspendedFacility:a1];
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBServiceFacilityServer removeFacility:](id a1)
{
    id identifier = [a1 identifier];
    if (identifier != nil) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *v3 = NSStringFromClass([self class]);
            id succinctDescription = [a1 succinctDescription];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Removing facility: %{public}@", v3, succinctDescription);
        }
        os_unfair_lock_lock(&self->_lock);
        [self->_lock_facilitiesByIdentifier removeObjectForKey:identifier];
        [self->_lock_suspendedFacilitiesByIdentifier removeObjectForKey:identifier];
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBServiceFacilityServer noteMilestoneReached:](id a1)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *v2 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Milestone reached: %{public}@", v2, a1);
    }
    os_unfair_lock_lock(&self->_lock);
    [self->_lock_completedMilestones addObject:a1];
    NSArray *allValues = [self->_lock_suspendedFacilitiesByIdentifier allValues];
    for (id v10 in allValues) {
        [self _lock_evaluateSuspendedFacility:v10];
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBServiceFacilityServer _lock_evaluateSuspendedFacility:](id a1)
{
    os_unfair_lock_assert_owner(&self->_lock);
    if ([self _lock_areFacilityPrerequisitesSatisfied:a1] != 0) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *v2 = NSStringFromClass([self class]);
            id identifier2 = [a1 identifier];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Starting facility: %{public}@", v2, identifier2);
        }
        NSArray *allObjects = [self->_lock_pendingConnects allObjects];
        for (id v11 in allObjects) {
            FBSServiceFacility *facility = [v11 facility];
            if (a1 == facility) {
                void (^completion)(void) = [v11 completion];
                completion();
                [self->_lock_pendingConnects removeObject:v11];
            }
        }
        id identifier = [a1 identifier];
        [self->_lock_suspendedFacilitiesByIdentifier removeObjectForKey:identifier];
    }
}


BSServiceDomainSpecification *-[FBServiceFacilityServer domain](void)
{
    return self->_domain;
}


void -[FBServiceFacilityServer .cxx_destruct](void)
{
    self->_lock_pendingConnects = nil;
    self->_lock_suspendedFacilitiesByIdentifier = nil;
    self->_lock_completedMilestones = nil;
    self->_lock_facilitiesByIdentifier = nil;
    self->_serviceListener = nil;
    self->_domain = nil;
}


void -[FBServiceFacilityServer init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBServiceFacilityServer"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBServiceFacilityServer.m", 116, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBServiceFacilityServer dealloc](void)
{
    NSString *v1 = [NSString stringWithFormat:@"this is a singleton, yo"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = [NSString stringWithUTF8String:"-[FBServiceFacilityServer dealloc]"];
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v2, @"FBServiceFacilityServer.m", 142, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
