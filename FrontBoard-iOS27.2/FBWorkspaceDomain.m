struct FBWorkspaceDomain {
    FBSWorkspaceCoupler *_coupler; // +0x8
    BSServiceDomainSpecification *_specification; // +0x10
    FBWorkspaceEndpointPromise *_endpointPromise; // +0x18
    id<BSInvalidatable> _lock_registration; // +0x20
    BSServiceConnectionListener *_lock_listener; // +0x28
    id<BSInvalidatable> _lock_activation; // +0x30
    id<FBWorkspaceDomainConnectionDelegate> _icdLock_indirectConnectionDelegate; // +0x38
    NSMutableSet *_icdLock_pendingIndirectConnectionBlocks; // +0x40
    NSDictionary *_preregisteredWorkspaces; // +0x48
    NSString *_defaultWorkspace; // +0x50
    struct os_unfair_lock_s _lock; // +0x58
    struct os_unfair_lock_s _icdLock; // +0x5c
    unsigned int _selfAssertRuntime; // +0x60
    bool _usesDefaultShellEndpoint; // +0x61
    bool _allowsTerminatingOnWatchdogViolations; // +0x62
    bool _injectorEnabled; // +0x63
    bool _assertsVisibility; // +0x64
    bool _monitorAllSuspendableProcesses; // +0x65
    bool _allowsDirectConnections; // +0x66
    bool _defaultWorkspaceDisabled; // +0x67
    bool _lock_injectEndpointToFBSWorkspace; // +0x68
    bool _lock_invalidated; // +0x69
    NSString *_reconnectShmemIdentifier; // +0x70
    NSSet *_reconnectableWorkspaces; // +0x78
};

FBSWorkspaceCoupler *-[FBWorkspaceDomain coupler](void)
{
    FBSWorkspaceCoupler *self;
    if (self != nil) {
        self = self->_coupler;
    }
    return self;
}


FBWorkspaceEndpointPromise *-[FBWorkspaceDomain endpointPromise](void)
{
    FBWorkspaceEndpointPromise *self;
    if (self != nil) {
        self = self->_endpointPromise;
    }
    return self;
}


id -[FBWorkspaceDomain assertionAttributesForLaunchIntent:outWorkspaceState:outProcessVisibility:](long a1, long a2, long a3)
{
    if (!self) {
        return nil;
    }
    id sharedAttributes = [FBWorkspaceAssertionAttributes sharedAttributes];
    return [sharedAttributes assertionAttributesForLaunchIntent:a1 assertsVisibility:self->_assertsVisibility outWorkspaceState:a2 outProcessVisibility:a3];
}


long +[FBWorkspaceDomain nullEndpoint](void)
{
    objc_opt_self(self);
    dispatch_once(&nullEndpoint.onceToken, ^void(void) {
        NSString *identifier = [FBSWorkspaceServiceSpecification identifier];
        nullEndpoint.nullEndpoint = [BSServiceConnectionEndpoint nullEndpointForService:identifier instance:0];
    });
    return nullEndpoint.nullEndpoint;
}


RBSAssertion *-[FBWorkspaceDomain endpointInjectorTargetingProcess:](id a1)
{
    RBSAssertion *v1;
    if (!self) {
        return nil;
    }
    int pid = [a1 pid];
    if (pid < 1) {
        v1 = nil;
    } else {
        id _listenerEndpoint = [self _listenerEndpoint];
        if (!self->_injectorEnabled) {
            v1 = nil;
        } else if (!_listenerEndpoint) {
            os_log_t oslog2 = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: can not inject workspace endpoint to %{public}@", a1);
            }
            v1 = nil;
        } else if (![self->_coupler _isSharedInstance]) {
            v1 = [BSServiceConnectionEndpointInjector injectorWithConfigurator:^void(id<BSServiceConnectionEndpointInjectorConfiguring> arg1) {
                id v19 = [RBSTarget targetWithPid:pid];
                [arg1 setTarget:v19];
                [arg1 addEndpoint:_listenerEndpoint];
            }];
        } else {
            dispatch_once(&endpointInjectorTargetingProcess:.onceToken, ^void(void) {
                os_log_t v16 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v16, OS_LOG_TYPE_DEFAULT)) {
                    id targetDescription = [_listenerEndpoint targetDescription];
                    os_log_with_type(v16, OS_LOG_TYPE_DEFAULT, "FBWorkspaceDomain: registering saved endowment %{public}@", targetDescription);
                }
                NSString *identifier = [FBSWorkspaceServiceSpecification identifier];
                [_listenerEndpoint saveAsInjectorEndowmentForKey:identifier];
            });
            RBSAssertion *v9 = [RBSAssertion alloc];
            id v10 = [RBSTarget targetWithPid:pid];
            id sharedAttributes = [FBWorkspaceAssertionAttributes sharedAttributes];
            v1 = [v9 initWithExplanation:@"FBWorkspaceDomain: injecting saved endowment" target:v10 attributes:(!sharedAttributes) ? 0 : sharedAttributes->field_208];
            id v14 = nil;
            long v15 = [v1 acquireWithError:&v14];
            if (!v15 || v14 != nil) {
                os_log_t oslog = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: error injecting workspace endpoint to %{public}@ : %{public}@", a1, v14);
                }
            }
        }
    }
    return v1;
}


NSXPCListenerEndpoint *-[FBWorkspaceDomain _listenerEndpoint](void)
{
    NSXPCListenerEndpoint *v1;
    if (self != nil) {
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_invalidated) {
            v1 = nil;
blk_1c4ee0b54:
            os_unfair_lock_unlock(&self->_lock);
            os_unfair_lock_assert_not_owner(&self->_lock);
            return v1;
        }
        os_unfair_lock_lock(&self->_icdLock);
        id<FBWorkspaceDomainConnectionDelegate> v2 = self->_icdLock_indirectConnectionDelegate;
        os_unfair_lock_unlock(&self->_icdLock);
        if (!v2) {
            os_unfair_lock_unlock(&self->_lock);
            NSString *v4 = [NSString stringWithFormat:@"asked for the listenerEndpoint before the processConnectionDelegate is registered"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(@selector(_listenerEndpoint));
                NSString *v5 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v5, self, @"FBWorkspaceDomain.m", 574, v4);
            }
            _bs_set_crash_log_message([v4 UTF8String]);
            __break(0);
        }
        id _lock_listener = [self _lock_listener];
        v1 = [_lock_listener endpoint];
        goto blk_1c4ee0b54;
    }
    return nil;
}


bool -[FBWorkspaceDomain monitorAllSuspendableProcesses](void)
{
    if (!self) {
        return false;
    } else {
        return self->_monitorAllSuspendableProcesses;
    }
}


void *-[FBWorkspaceDomain selfAssertRuntime](void)
{
    void *self;
    if (self != 0) {
        self = self->_selfAssertRuntime & 3;
    }
    return self;
}


BSServiceConnectionListener *-[FBWorkspaceDomain _lock_listener](void)
{
    BSServiceConnectionListener *self;
    if (self != nil) {
        os_unfair_lock_assert_owner(&self->_lock);
        if (!self->_lock_invalidated && !self->_lock_listener) {
            id _domainIdentifier = [self->_endpointPromise _domainIdentifier];
            NSString *identifier = [FBSWorkspaceServiceSpecification identifier];
            if (!self->_specification) {
                NSDictionary<NSString *, NSDictionary *> *v7 = @{identifier: @{}};
                NSDictionary<NSString *, id> *v8 = @{@"Start": @"ManualSession", @"Services": v7};
                NSDictionary<id, NSDictionary<NSString *, id> *> *v10 = @{_domainIdentifier: v8};
                self->_lock_registration = [BSServicesConfiguration registerDynamicDomainsFromPlist:v10];
            }
            id v13 = [BSServiceConnectionListenerConfiguration configurationWithDomain:_domainIdentifier service:identifier];
            self->_lock_listener = [BSServiceConnectionListener listenerWithConfiguration:v13 handler:^void(BSServiceListenerConnection *arg1) {
                [self _didReceiveConnection:arg1];
            }];
            [self->_lock_listener activate];
            if (!self->_specification) {
                self->_lock_activation = [BSServicesConfiguration activateManualDomain:_domainIdentifier];
            }
        }
        self = self->_lock_listener;
    }
    return self;
}


NSSet *-[FBWorkspaceDomain reconnectableWorkspaces](void)
{
    NSSet *self;
    if (self != nil) {
        self = self->_reconnectableWorkspaces;
    }
    return self;
}


NSArray *-[FBWorkspaceDomain selfAssertionAttributesForWorkspaceState:](int *a1)
{
    NSArray *self;
    if (self != nil) {
        if (!a1) {
            NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"inoutState != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v7 = NSStringFromSelector(@selector(selfAssertionAttributesForWorkspaceState:));
                NSString *v8 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBWorkspaceDomain.m", 507, v6);
            }
            _bs_set_crash_log_message([v6 UTF8String]);
            __break(0);
        }
        if ((FBWorkspaceStateEqual(*(a1), &FBWorkspaceStateNone) & 1) == 0) {
            int v1 = self->_selfAssertRuntime & 3;
            if ((self->_selfAssertRuntime & 3) == 2) {
                bool v2 = FBWorkspaceStateGetActivity(*(a1)) > 1;
                int *v3 = &FBWorkspaceStateNone;
                id sharedAttributes = [FBWorkspaceAssertionAttributes sharedAttributes];
                self = [sharedAttributes selfAssertionAttributesWithForeground:v2 outWorkspaceState:&v3];
                *(a1) = v3;
            } else if (v1 != 0) {
                *(a1) = FBWorkspaceStateCreate(1, 1, 40);
                id v5 = [RBSDomainAttribute attributeWithDomain:@"com.apple.common" name:@"FinishTaskInterruptable"];
                self = @[v5];
            } else {
                self = nil;
                *(a1) = &FBWorkspaceStateNone;
            }
        } else {
            self = nil;
        }
    }
    return self;
}


void -[FBWorkspaceDomain _didReceiveConnection:](id a1)
{
    os_log_t v12;
    os_log_t v2;
    id v0 = a1;
    if (self != 0) {
        do {
            id remoteToken = [v0 remoteToken];
            if (remoteToken && ![remoteToken isInvalid]) {
                id initiatingContext = [v0 initiatingContext];
                if (![initiatingContext decodeBoolForKey:@"targetsClientEndpoint"]) {
                    os_unfair_lock_lock(&self->_icdLock);
                    if (!self->_icdLock_pendingIndirectConnectionBlocks) {
                        id<FBWorkspaceDomainConnectionDelegate> v6 = self->_icdLock_indirectConnectionDelegate;
                        os_unfair_lock_unlock(&self->_icdLock);
                        if (!v6) {
                            os_log_t oslog = FBLogCommon();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                                os_log_with_type(oslog, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Invalidating defunct indirect connection %p with remoteToken=%{public}@", v0, remoteToken);
                            }
                            [v0 invalidate];
                        } else {
                            [v6 domain:self didReceiveConnection:v0];
                        }
                    } else {
                        void (^v9)(id<FBWorkspaceDomainConnectionDelegate>) = ^void(id<FBWorkspaceDomainConnectionDelegate> arg1) {
                            if (arg1 != nil) {
                                [arg1 domain:self didReceiveConnection:v0];
                                return;
                            }
                            os_log_t v16 = FBLogCommon();
                            if (os_log_type_enabled(v16, OS_LOG_TYPE_INFO)) {
                                os_log_with_type(v16, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Invalidating pended indirect connection %p with remoteToken=%{public}@", v0, remoteToken);
                            }
                            [v0 invalidate];
                        };
                        void (^aBlock)(id<FBWorkspaceDomainConnectionDelegate>) = [v9 copy];
                        id v11 = _Block_copy(aBlock);
                        [self->_icdLock_pendingIndirectConnectionBlocks addObject:v11];
                        os_unfair_lock_unlock(&self->_icdLock);
                    }
                    os_unfair_lock_assert_not_owner(&self->_icdLock);
                    return;
                }
                if (self->_allowsDirectConnections) {
                    v12 = FBLogCommon();
                    if (os_log_type_enabled(v12, OS_LOG_TYPE_INFO)) {
                        os_log_with_type(v12, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Enqueuing new direct workspace connection %p with remoteToken=%{public}@", v0, remoteToken);
                    }
                    [self->_coupler _enqueueClientConnectionBlock:^void(FBSWorkspace *arg1) {
                        if (arg1 != nil) {
                            [arg1 _registerSourcePeer:v0];
                            return;
                        }
                        os_log_t v17 = FBLogCommon();
                        if (os_log_type_enabled(v17, OS_LOG_TYPE_INFO)) {
                            os_log_with_type(v17, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Invalidating enqueued direct connection %p with remoteToken=%{public}@", v0, remoteToken);
                        }
                    }];
                    return;
                }
                int pid = [remoteToken pid];
                long v15 = __getpid(pid);
                if (pid == v15) {
                    v12 = FBLogCommon();
                    if (os_log_type_enabled(v12, OS_LOG_TYPE_INFO)) {
                        os_log_with_type(v12, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Enqueuing new direct workspace connection %p with remoteToken=%{public}@", v0, remoteToken);
                    }
                    [self->_coupler _enqueueClientConnectionBlock:^void(FBSWorkspace *arg1) {
                        if (arg1 != nil) {
                            [arg1 _registerSourcePeer:v0];
                            return;
                        }
                        os_log_t v18 = FBLogCommon();
                        if (os_log_type_enabled(v18, OS_LOG_TYPE_INFO)) {
                            os_log_with_type(v18, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Invalidating enqueued direct connection %p with remoteToken=%{public}@", v0, remoteToken);
                        }
                    }];
                    return;
                }
                v2 = FBLogCommon();
                if (os_log_type_enabled(v2, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v2, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: Unable to register new direct connection with remoteToken=%{public}@ because the service doesn't declare support for direct connections", remoteToken);
                    break;
                }
                break;
            }
            v2 = FBLogCommon();
            if (os_log_type_enabled(v2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(v2, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: Unable to validate new incoming connection because the remote was unknown : connection=%@", v0);
            }
        } while (0);
        [v0 invalidate];
    }
}


id -[FBWorkspaceDomain assertionAttributesForWorkspaceState:](long a1)
{
    if (!self) {
        return nil;
    }
    id sharedAttributes = [FBWorkspaceAssertionAttributes sharedAttributes];
    return [sharedAttributes assertionAttributesForWorkspaceState:a1 assertsVisibility:self->_assertsVisibility isBootstrapping:0];
}


FBSSceneSpecification *+[FBWorkspaceDomain(FBSWorkspace) startWorkspaceDomainListener](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    id eventDispatcher = [sharedInstance eventDispatcher];
    id domain = [eventDispatcher domain];
    return [domain specification];
}


FBWorkspaceDomain *-[FBWorkspaceDomain _initWithCoupler:specification:](FBSWorkspaceCoupler *a1, BSServiceDomainSpecification *a2)
{
    id v4;
    BOOL v15;
    NSString *v100;
    int v27;
    bool v34;
    NSUInteger v39;
    id v38;
    id v61;
    int v75;
    id machName;
    NSMutableDictionary *dictionary;
    NSFastEnumerationState v37;
    long v40;
    FBWorkspaceDomain *self;
    if (self != nil) {
        self = [super init];
        if (self != nil) {
            self->_coupler = a1;
            self->_lock = 0;
            self->_icdLock_pendingIndirectConnectionBlocks = [NSMutableSet set];
            if (a2 != nil) {
                NSString *identifier2 = [FBSWorkspaceServiceSpecification identifier];
                v4 = [a2 serviceForIdentifier:identifier2];
                if (!v4) {
                    NSString *v94 = [NSString stringWithFormat:@"missing workspace service"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v95 = NSStringFromSelector(@selector(_initWithCoupler:specification:));
                        NSString *v96 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v95, v96, self, @"FBWorkspaceDomain.m", 135, v94);
                    }
                    _bs_set_crash_log_message([v94 UTF8String]);
                    __break(0);
                }
                machName = [a2 machName];
                id environmentAliases = [BSMachServiceAliases environmentAliases];
                id defaultShellMachName = [BSServiceConnectionEndpoint defaultShellMachName];
                NSString *v8 = [environmentAliases resolveMachService:defaultShellMachName];
                self->_specification = a2;
                self->_usesDefaultShellEndpoint = [machName isEqualToString:v8];
                FBWorkspaceEndpointPromise *v9 = [FBWorkspaceEndpointPromise alloc];
                id identifier = [a2 identifier];
                self->_endpointPromise = (!v9) ? nil : [v9 _initWithDomain:self identifier:identifier endpoint:0];
                id v13 = [v4 optionForKey:@"AllowTerminatingOnWatchdogViolations"];
                if (![v13 respondsToSelector:@selector(boolValue)]) {
                    v15 = YES;
                    goto blk_1c4ef5ffc;
                }
                v15 = [v13 boolValue];
                goto blk_1c4ef5ffc;
            }
            NSBundle *mainBundle = [NSBundle mainBundle];
            NSString *bundleIdentifier = [mainBundle bundleIdentifier];
            if (bundleIdentifier != nil) {
                v100 = [NSString stringWithFormat:@"FBWorkspace-%@", bundleIdentifier];
                goto blk_1c4ef6520;
blk_1c4ef5ffc:
                self->_allowsTerminatingOnWatchdogViolations = v15;
                id v20 = [v4 optionForKey:@"InjectEndpoint"];
                self->_injectorEnabled = (![v20 respondsToSelector:@selector(boolValue)]) ? YES : [v20 boolValue];
                id v22 = [v4 optionForKey:@"AssertVisibility"];
                if (![v22 respondsToSelector:@selector(boolValue)]) {
                    id tokenForCurrentProcess = [BSAuditToken tokenForCurrentProcess];
                    self->_assertsVisibility = [tokenForCurrentProcess hasEntitlement:@"com.apple.runningboard.primitiveattribute"];
                } else {
                    self->_assertsVisibility = [v22 boolValue];
                }
                self->_selfAssertRuntime = self->_selfAssertRuntime & 252;
                id v24 = [v4 optionForKey:@"SelfAssertRuntime"];
                if (![v24 respondsToSelector:@selector(boolValue)]) {
                    id currentProcess = [RBSProcessHandle currentProcess];
                    if (![currentProcess fb_canTaskSuspend]) {
                        goto blk_1c4ef611c;
                    }
                    v27 = 1;
                } else {
                    if (![v24 boolValue]) {
                        goto blk_1c4ef611c;
                    }
                    v27 = 2;
                }
                self->_selfAssertRuntime = (self->_selfAssertRuntime & 252) | v27;
blk_1c4ef611c:
                self->_monitorAllSuspendableProcesses = self->_usesDefaultShellEndpoint;
                id launchIdentifiers = [a2 launchIdentifiers];
                self->_allowsDirectConnections = [launchIdentifiers containsObject:FBSSceneClientIdentityDirectLaunchIdentifier];
                id v30 = [v4 optionForKey:@"DefaultWorkspace"];
                if ([v30 isKindOfClass:[NSString class]]) {
                    NSString *v32 = @"FBSceneManager";
                    if (![v30 isEqualToString:@"FBSceneManager"]) {
                        v32 = [v30 copy];
                    }
                    self->_defaultWorkspace = v32;
blk_1c4ef61f4:
                    v34 = false;
                } else {
                    self->_defaultWorkspace = nil;
                    if (![v30 isKindOfClass:[NSNumber class]]) {
                        goto blk_1c4ef61f4;
                    }
                    if (![v30 boolValue]) {
                        v34 = true;
                    } else {
                        goto blk_1c4ef61f4;
                    }
                }
                self->_defaultWorkspaceDisabled = v34;
                id v35 = [v4 optionForKey:@"RegisterWorkspaces"];
                long continuationRoute19 = 0;
                if (!v35) {
                    v35 = [v4 optionForKey:@"ReconnectWorkspaces"];
                    if (!v35) {
                        if (self->_usesDefaultShellEndpoint != 1) {
                            NSDictionary *dictionary2 = [NSDictionary dictionary];
                            NSDictionary *v97 = self->_preregisteredWorkspaces;
                            self->_preregisteredWorkspaces = dictionary2;
                            goto blk_1c4ef6460;
                        }
                        id v83 = [FBWorkspaceRegistration registrationWithIdentifier:@"FBSceneManager" options:0];
                        self->_preregisteredWorkspaces = [NSDictionary dictionaryWithObject:v83 forKey:@"FBSceneManager"];
                        goto blk_1c4ef6460;
                    }
                    goto blk_1c4ef6230;
blk_1c4ef6298:
                    long v44 = *(v37.mutationsPtr);
                    do {
                        long v45 = 0;
                        do {
                            if (*(v37.mutationsPtr) != v44) {
                                objc_enumerationMutation(v38);
                            }
                            id v47 = [FBWorkspaceRegistration registrationWithIdentifier:v37.itemsPtr[v45] options:0];
                            if (v47 != nil) {
                                [dictionary setObject:v47 forKey:v47->field_16];
                            }
                            v45++;
                            v39--;
                        } while (v39 != 0);
                        v39 = [v38 countByEnumeratingWithState:&v37 objects:&v40 count:16];
                    } while (v39 != 0);
                    continuationRoute19 = 2;
                } else {
blk_1c4ef6230:
                    dictionary = [NSMutableDictionary dictionary];
                    if ([v35 isKindOfClass:[NSArray class]]) {
                        _memset(v37, 0, 64);
                        v38 = v35;
                        v39 = [v35 countByEnumeratingWithState:&v37 objects:&v40 count:16];
                        if (!v39) {
                            continuationRoute19 = 2;
                        }
                        if (!continuationRoute19) {
                            goto blk_1c4ef6298;
                        }
                    }
                    if (!continuationRoute19 && [v35 isKindOfClass:[NSDictionary class]]) {
                        continuationRoute19 = 1;
                    }
                }
                if (continuationRoute19 == 1) {
                    id v49 = v35;
                    for (id v54 in v49) {
                        id v55 = [v49 objectForKey:v54];
                        id v57 = [FBWorkspaceRegistration registrationWithIdentifier:v54 options:v55];
                        if (v57 != nil) {
                            [dictionary setObject:v57 forKey:v57->field_16];
                        }
                    }
                }
                if (self->_defaultWorkspace && ![dictionary objectForKey:self->_defaultWorkspace]) {
                    id v0 = [FBWorkspaceRegistration registrationWithIdentifier:self->_defaultWorkspace options:0];
                    if (!v0) {
                        [dictionary setObject:v0 forKey:nil];
                    } else {
                        [dictionary setObject:v0 forKey:v0->field_16];
                    }
                }
                self->_preregisteredWorkspaces = [dictionary copy];
blk_1c4ef6460:
                if (!machName) {
blk_1c4ef64d0:
                    v61 = self->_reconnectShmemIdentifier;
                    self->_reconnectShmemIdentifier = nil;
                    goto blk_1c4ef6820;
                }
                id currentProcess2 = [RBSProcessHandle currentProcess];
                if (![currentProcess2 hasConsistentLaunchdJob]) {
                    goto blk_1c4ef64d0;
                }
                id v64 = [v4 optionForKey:@"ReconnectShmemIdentifier"];
                if (!v64) {
                    id v65 = [FBWorkspaceConnectionsStateStore identifierForName:machName];
                    if (![FBWorkspaceConnectionsStateStore hasSandboxAccessForIdentifier:v65]) {
                        os_log_t oslog = FBLogCommon();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBWorkspaceDomain:%p no access to defaultShmemIdentifier \"%@\" - disabling reconnection support", self, v65);
                        }
                        v61 = nil;
                    } else {
                        v61 = v65;
                    }
                } else if ([v64 isKindOfClass:[NSString class]]) {
                    v61 = v64;
                } else if (![v64 respondsToSelector:@selector(boolValue)]) {
                    os_log_t oslog2 = FBLogCommon();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "FBWorkspaceDomain:%p unrecognized ReconnectShmemIdentifier \"%@\" - disabling reconnection support", self, v64);
                    }
blk_1c4ef6804:
                    v61 = nil;
                } else {
                    if (![v64 boolValue]) {
                        goto blk_1c4ef6804;
                    }
                    v61 = [FBWorkspaceConnectionsStateStore identifierForName:machName];
                }
            } else {
                NSProcessInfo *processInfo = [NSProcessInfo processInfo];
                NSString *processName = [processInfo processName];
                v100 = [NSString stringWithFormat:@"FBWorkspace-%@", processName];
blk_1c4ef6520:
                self->_specification = nil;
                self->_usesDefaultShellEndpoint = NO;
                FBWorkspaceEndpointPromise *v70 = [FBWorkspaceEndpointPromise alloc];
                if (v70 != nil) {
                    v70 = [v70 _initWithDomain:self identifier:v100 endpoint:0];
                }
                self->_endpointPromise = v70;
                self->_allowsTerminatingOnWatchdogViolations = YES;
                self->_injectorEnabled = YES;
                self->_assertsVisibility = NO;
                self->_selfAssertRuntime = self->_selfAssertRuntime & 252;
                NSDictionary<NSString *, id> *infoDictionary = [mainBundle infoDictionary];
                id v101 = [infoDictionary objectForKey:@"FBWorkspaceDynamicDomainOption_SelfAssertRuntime"];
                if (![v101 respondsToSelector:@selector(boolValue)]) {
                    id currentProcess3 = [RBSProcessHandle currentProcess];
                    if (![currentProcess3 fb_canTaskSuspend]) {
                        goto blk_1c4ef6600;
                    }
                    v75 = 1;
                } else {
                    if (![v101 boolValue]) {
                        goto blk_1c4ef6600;
                    }
                    v75 = 2;
                }
                self->_selfAssertRuntime = (self->_selfAssertRuntime & 252) | v75;
blk_1c4ef6600:
                self->_monitorAllSuspendableProcesses = NO;
                self->_allowsDirectConnections = NO;
                self->_defaultWorkspace = nil;
                self->_defaultWorkspaceDisabled = YES;
                self->_preregisteredWorkspaces = [NSDictionary dictionary];
                self->_reconnectShmemIdentifier = nil;
                self->_reconnectableWorkspaces = [NSSet set];
                return self;
            }
            self->_reconnectShmemIdentifier = [v61 copy];
blk_1c4ef6820:
            if (!self->_reconnectShmemIdentifier) {
                self->_reconnectableWorkspaces = [NSSet set];
            } else {
                NSArray *allKeys = [self->_preregisteredWorkspaces allKeys];
                self->_reconnectableWorkspaces = [NSSet setWithArray:allKeys];
            }
        }
    }
    return self;
}


void *-[FBWorkspaceDomain defaultSceneInterruptionPolicy](void)
{
    void *self;
    if (self != 0) {
        self = (self->_usesDefaultShellEndpoint) ? 3 : 1;
    }
    return self;
}


NSString *-[FBWorkspaceDomain reconnectShmemIdentifier](void)
{
    NSString *self;
    if (self != nil) {
        self = self->_reconnectShmemIdentifier;
    }
    return self;
}


NSDictionary *-[FBWorkspaceDomain preregisteredWorkspaces](void)
{
    NSDictionary *self;
    if (self != nil) {
        self = self->_preregisteredWorkspaces;
    }
    return self;
}


void -[FBWorkspaceDomain setIndirectConnectionDelegate:](id<FBWorkspaceDomainConnectionDelegate> a1)
{
    if (!self) {
        return;
    }
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_invalidated == 1) {
        os_unfair_lock_unlock(&self->_lock);
        NSString *v4 = [NSString stringWithFormat:@"attempt to set an indirectConnectionDelegate after invalidation : new=%@", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(@selector(setIndirectConnectionDelegate:));
            NSString *v1 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v1, self, @"FBWorkspaceDomain.m", 343, v4);
        }
        _bs_set_crash_log_message([v4 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_icdLock);
    id<FBWorkspaceDomainConnectionDelegate> v5 = self->_icdLock_indirectConnectionDelegate;
    if (self->_icdLock_indirectConnectionDelegate != nil) {
        os_unfair_lock_unlock(&self->_icdLock);
        os_unfair_lock_unlock(&self->_lock);
        NSString *v6 = [NSString stringWithFormat:@"already have an indirectConnectionDelegate : existing=%@ new=%@", v5, a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(@selector(setIndirectConnectionDelegate:));
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBWorkspaceDomain.m", 350, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    self->_icdLock_indirectConnectionDelegate = a1;
    id machName = [self->_specification machName];
    if (machName != nil) {
        os_unfair_lock_unlock(&self->_icdLock);
        [self _lock_listener];
        os_unfair_lock_lock(&self->_icdLock);
    }
    NSMutableSet *v8 = self->_icdLock_pendingIndirectConnectionBlocks;
    self->_icdLock_pendingIndirectConnectionBlocks = nil;
    os_unfair_lock_unlock(&self->_icdLock);
    os_unfair_lock_unlock(&self->_lock);
    for (id v15 in v8) {
        v15->field_16(v15, a1);
    }
    os_unfair_lock_assert_not_owner(&self->_icdLock);
    os_unfair_lock_assert_not_owner(&self->_lock);
}


BSServiceDomainSpecification *-[FBWorkspaceDomain specification](void)
{
    BSServiceDomainSpecification *self;
    if (self != nil) {
        self = self->_specification;
    }
    return self;
}


void -[FBWorkspaceDomain injectEndpointToFBSWorkspace](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_injectEndpointToFBSWorkspace == 1) {
        os_unfair_lock_unlock(&self->_lock);
        os_unfair_lock_assert_not_owner(&self->_lock);
        return;
    }
    self->_lock_injectEndpointToFBSWorkspace = YES;
    os_unfair_lock_lock(&self->_icdLock);
    id<FBWorkspaceDomainConnectionDelegate> v2 = self->_icdLock_indirectConnectionDelegate;
    os_unfair_lock_unlock(&self->_icdLock);
    if (v2 != nil) {
        id _lock_listener = [self _lock_listener];
        NSXPCListenerEndpoint *endpoint = [_lock_listener endpoint];
        os_unfair_lock_unlock(&self->_lock);
        os_unfair_lock_assert_not_owner(&self->_lock);
        if (endpoint) {
            [self->_coupler _enqueueClientConnectionBlock:^void(FBSWorkspace *arg1) {
                [arg1 _registerSourceEndpoint:endpoint];
            }];
        }
        return;
    }
    os_unfair_lock_unlock(&self->_lock);
    NSString *v4 = [NSString stringWithFormat:@"asked for the listenerEndpoint before the processConnectionDelegate is registered"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v5 = NSStringFromSelector(@selector(injectEndpointToFBSWorkspace));
        NSString *v6 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v6, self, @"FBWorkspaceDomain.m", 444, v4);
    }
    _bs_set_crash_log_message([v4 UTF8String]);
    __break(0);
}


void -[FBWorkspaceDomain dealloc](void)
{
    if (!self->_lock_invalidated) {
        NSString *v5 = [NSString stringWithFormat:@"invalidate must be called before deallocing"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceDomain.m", 307, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBWorkspaceDomain:%p deallocing.", self);
    }
    [super dealloc];
}


id +[FBWorkspaceDomain backgroundUserInitiatedBootstrapAttributes](void)
{
    int *v0 = &FBWorkspaceStateNone;
    long v1 = 0;
    id sharedAttributes = [FBWorkspaceAssertionAttributes sharedAttributes];
    return [sharedAttributes assertionAttributesForLaunchIntent:5 assertsVisibility:0 outWorkspaceState:&v0 outProcessVisibility:&v1];
}


id -[FBWorkspaceDomain description](void)
{
    os_unfair_lock_lock(&self->_lock);
    BSServiceConnectionListener *v0 = self->_lock_listener;
    os_unfair_lock_unlock(&self->_lock);
    id v1 = [BSDescriptionBuilder builderWithObject:self];
    id _domainIdentifier = [self->_endpointPromise _domainIdentifier];
    [v1 appendString:_domainIdentifier withName:@"identifier"];
    id machName = [self->_specification machName];
    [v1 appendString:machName withName:@"machName" skipIfEmpty:1];
    [v1 appendBodySectionWithName:0 multilinePrefix:0 block:^void(void) {
        long v9;
        NSString *v6;
        if (!self) {
            v9 = 0;
        } else {
            v9 = (self->_usesDefaultShellEndpoint) ? 3 : 1;
        }
        id v10 = NSStringFromFBSSceneInterruptionPolicy(v9);
        [v1 appendString:v10 withName:@"defaultSceneInterruptionPolicy"];
        [v1 appendBool:self->_injectorEnabled withName:@"injectorEnabled"];
        [v1 appendBool:self->_assertsVisibility withName:@"assertsVisibility"];
        id v11 = NSStringFromFBWorkspaceDomainSelfAssertRuntime(self->_selfAssertRuntime & 3);
        [v1 appendString:v11 withName:@"selfAssertRuntime"];
        if (self->_defaultWorkspaceDisabled == 0) {
            v6 = (!self->_defaultWorkspace) ? @"<deprecated>" : self->_defaultWorkspace;
        } else {
            v6 = @"<disabled>";
        }
        [v1 appendString:v6 withName:@"defaultWorkspace"];
        NSArray *allValues = [self->_preregisteredWorkspaces allValues];
        [v1 appendArraySection:allValues withName:@"preregisteredWorkspaces" skipIfEmpty:1];
        [v1 appendString:self->_reconnectShmemIdentifier withName:@"reconnectShmem" skipIfEmpty:1];
        [v1 appendPointer:v0 withName:@"listener"];
    }];
    return [v1 build];
}


void -[FBWorkspaceDomain .cxx_destruct](void)
{
    self->_reconnectableWorkspaces = nil;
    self->_reconnectShmemIdentifier = nil;
    self->_defaultWorkspace = nil;
    self->_preregisteredWorkspaces = nil;
    self->_icdLock_pendingIndirectConnectionBlocks = nil;
    self->_icdLock_indirectConnectionDelegate = nil;
    self->_lock_activation = nil;
    self->_lock_listener = nil;
    self->_lock_registration = nil;
    self->_endpointPromise = nil;
    self->_specification = nil;
    self->_coupler = nil;
}


NSString *+[FBWorkspaceDomain(Debugging) debugDescription](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    id eventDispatcher = [sharedInstance eventDispatcher];
    id domain = [eventDispatcher domain];
    return [domain debugDescription];
}


void -[FBWorkspaceDomain init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBWorkspaceDomain"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceDomain.m", 123, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


bool -[FBWorkspaceDomain allowsTerminatingOnWatchdogViolations](void)
{
    if (!self) {
        return false;
    } else {
        return self->_allowsTerminatingOnWatchdogViolations;
    }
}


NSString *-[FBWorkspaceDomain defaultWorkspace](void)
{
    NSString *self;
    if (self != nil) {
        self = self->_defaultWorkspace;
    }
    return self;
}


bool -[FBWorkspaceDomain isDefaultWorkspaceDisabled](void)
{
    if (!self) {
        return false;
    } else {
        return self->_defaultWorkspaceDisabled;
    }
}
