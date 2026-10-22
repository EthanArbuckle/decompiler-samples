struct FBWorkspace {
    __weak id<FBWorkspaceDelegate> _weak_delegate; // +0x8
    __weak FBProcess *_weak_process; // +0x10
    FBSceneSynchronizer *_synchronizer; // +0x18
    FBWorkspaceIncomingConnection *_lock_incomingConnection; // +0x20
    FBWorkspaceEventDispatcherSource *_lock_eventDispatcherSource; // +0x28
    NSMutableDictionary *_lock_identityToRemnantsMap; // +0x30
    NSMutableArray *_lock_pendedRequests; // +0x38
    id<BSInvalidatable> _workspaceServiceInjector; // +0x40
    FBWorkspaceEndpointPromise *_lock_outgoingEndpointPromise; // +0x48
    FBWorkspaceOutgoingConnection *_lock_outgoingConnection; // +0x50
    NSMutableDictionary *_lock_identityToSceneMap; // +0x58
    BSCompoundAssertion *_compoundAssertion; // +0x60
    RBSAssertion *_lock_lifeAssertion; // +0x68
    RBSAssertion *_lock_connectAssertion; // +0x70
    RBSAssertion *_lock_afterlifeAssertion; // +0x78
    long _lock_activeInterruptionPolicy; // +0x80
    struct os_unfair_lock_s _lock; // +0x88
    bool _shouldInjectEndpoint; // +0x8c
    bool _lock_didReceiveHandshake; // +0x8d
    bool _invalidated; // +0x8e
    bool _test_rejectAllSceneClients; // +0x8f
};

static long FBAssertionDomain;

FBWorkspace *-[FBWorkspace _initWithDispatcher:process:](id a1, FBProcess *a2)
{
    NSString *v9;
    if (self != nil) {
        if (!a1) {
            NSString *v34 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"dispatcher"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_initWithDispatcher:process:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspace.m", 92, v34);
            }
            _bs_set_crash_log_message([v34 UTF8String]);
            __break(0);
        }
        if (!a2) {
            NSString *v36 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v37 = NSStringFromSelector(@selector(_initWithDispatcher:process:));
                NSString *v38 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBWorkspace.m", 93, v36);
            }
            _bs_set_crash_log_message([v36 UTF8String]);
            __break(0);
        }
        self = [super init];
        if (self != nil) {
            memset(&self->_lock, 0, 4);
            int pid = [a2 pid];
            NSString *logProem2 = [a2 logProem];
            if (pid < 1) {
                NSUUID *UUID = [NSUUID UUID];
                NSString *UUIDString = [UUID UUIDString];
                v9 = [NSString stringWithFormat:@"FBProcess:%@-%@", logProem2, UUIDString];
            } else {
                v9 = [NSString stringWithFormat:@"FBProcess:%@", logProem2];
            }
            id v10 = [BSServiceQuality serviceWithClass:33];
            id v11 = [BSServiceDispatchQueue queueWithName:v9 serviceQuality:v10];
            self->_synchronizer = [[FBSceneSynchronizer alloc] _initWithIdentifier:v9 workspaceQueue:v11 dispatcher:a1];
            self->_weak_process = a2;
            RBSProcessHandle *rbsHandle = [a2 rbsHandle];
            if (rbsHandle != nil) {
                [self->_synchronizer _setProcessHandle:rbsHandle];
                os_log_t oslog = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem = [a2 logProem];
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Registering event dispatcher at init", logProem);
                }
                id _dispatcher = [self->_synchronizer _dispatcher];
                self->_lock_eventDispatcherSource = [_dispatcher registerSourceWithProcessHandle:rbsHandle];
            }
            self->_lock_pendedRequests = [[NSMutableArray alloc] init];
            self->_compoundAssertion = [BSCompoundAssertion assertionWithIdentifier:v9 stateDidChangeHandler:^void(id<BSCompoundAssertionState> arg1) {
                [self _updateProcessAssertionState];
            }];
            self->_shouldInjectEndpoint = YES;
            if ([a2 isExtensionProcess] != 0) {
                FBSExtensionInfo *extensionInfo = [a2 extensionInfo];
                if (![extensionInfo extensionIdentifier]) {
                    id sharedInstance = [FBPreferences sharedInstance];
                    if (![sharedInstance disableXPCServicesEndpointHack]) {
                        self->_shouldInjectEndpoint = NO;
                    }
                }
            }
            self->_lock_incomingConnection = [[FBWorkspaceIncomingConnection alloc] initWithWorkspace:self];
            os_log_t oslog2 = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Created %{public}@", self);
            }
        }
    }
    return self;
}


id -[FBWorkspace _domain](void)
{
    if (!self) {
        return nil;
    }
    id _dispatcher = [self->_synchronizer _dispatcher];
    return [_dispatcher domain];
}


void -[FBWorkspace _noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:](id a1, id a2, RBSAssertion *a3, FBWorkspaceEndpointPromise *a4)
{
    id v1 = a1;
    id v2 = a2;
    RBSAssertion *v3 = a3;
    if (self != nil) {
        FBProcess *v6 = self->_weak_process;
        if (v1 != v6) {
            NSString *v46 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process == _weak_process"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v47 = NSStringFromSelector(@selector(_noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:));
                NSString *v48 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v47, v48, self, @"FBWorkspace.m", 543, v46);
            }
            _bs_set_crash_log_message([v46 UTF8String]);
            __break(0);
        }
        if (!a4) {
            NSString *v50 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"endpointPromise"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v51 = NSStringFromSelector(@selector(_noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:));
                NSString *v52 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v51, v52, self, @"FBWorkspace.m", 544, v50);
            }
            _bs_set_crash_log_message([v50 UTF8String]);
            __break(0);
        }
        if (v2) {
            [self->_synchronizer _setProcessHandle:v2];
        } else if (([a4 isResolvedNullEndpoint] & 1) == 0) {
            NSString *v7 = [NSString stringWithFormat:@"workspace's process bootstrapped without a handle but still had a valid outgoing endpoint promise : process=%@ endpointPromise=%@", v1, a4];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(@selector(_noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:));
                NSString *v54 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v54, self, @"FBWorkspace.m", 549, v7);
            }
            _bs_set_crash_log_message([v7 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_outgoingEndpointPromise != nil) {
            NSString *v9 = [NSString stringWithFormat:@"already noted bootstrap of process : previousEndpoint=%@ newEndpoint=%@ newHandle=%@", self->_lock_outgoingEndpointPromise, a4, v2];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v56 = NSStringFromSelector(@selector(_noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:));
                NSString *v57 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v56, v57, self, @"FBWorkspace.m", 552, v9);
            }
            _bs_set_crash_log_message([v9 UTF8String]);
            __break(0);
        }
        self->_lock_outgoingEndpointPromise = a4;
        if (v2 != nil) {
            os_unfair_lock_assert_owner(&self->_lock);
            if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
                if (!self->_lock_eventDispatcherSource) {
                    os_log_t oslog = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                        id logProem = [v1 logProem];
                        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Registering event dispatcher after bootstrap", logProem);
                    }
                    id _dispatcher = [self->_synchronizer _dispatcher];
                    self->_lock_eventDispatcherSource = [_dispatcher registerSourceWithProcessHandle:v2];
                }
                if (v3) {
                    int fb_workspaceState = [v3 fb_workspaceState];
                    if (FBWorkspaceStateEqual(fb_workspaceState, &FBWorkspaceStateNone) != 0) {
                        NSString *v59 = [NSString stringWithFormat:@"workspace assertion but no workspace state"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v60 = NSStringFromSelector(@selector(_noteProcessBootstrapped:withHandle:assertion:outgoingEndpointPromise:));
                            NSString *v61 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v60, v61, self, @"FBWorkspace.m", 562, v59);
                        }
                        _bs_set_crash_log_message([v59 UTF8String]);
                        __break(0);
                    }
                    os_log_t oslog2 = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                        id logProem3 = [v1 logProem];
                        NSString *v43 = NSStringFromFBWorkspaceState(fb_workspaceState);
                        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ Initial launch state: %{public}@.", logProem3, v43);
                    }
                    self->_lock_connectAssertion = a3;
                    [self->_lock_connectAssertion addObserver:self];
                }
                void (^v16)(bool) = FBAnalyticsLogHangTracerEvent(v1, 1);
                id v20 = v1;
                void (^v21)(bool) = ^void(bool arg1) {
                    if (v16 != nil) {
                        v16(arg1);
                    }
                    [v1 _launchDidComplete:arg1 finalizeBlock:^void(void) {
                        if (!v3) {
                            return;
                        } else {
                            [self _dropLaunchAssertion];
                            return;
                        }
                    }];
                };
                int pid = [v20 pid];
                long v23 = __getpid(pid);
                if (pid == v23) {
                    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
                    void (^v25)(void) = ^void(void) {
                        v21(YES);
                    };
                    [_workspaceQueue performAsync:v25];
                } else {
                    void (^v27)(id<FBSWorkspaceServiceServerInterface>) = ^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                        if (arg1 != 0) {
                            v21(YES);
                            return;
                        } else {
                            v21(NO);
                            return;
                        }
                    };
                    [self->_lock_incomingConnection workspaceLock_enqueueConnectBlock:v27];
                }
                if (self->_lock_outgoingConnection != nil) {
                    NSXPCListenerEndpoint *endpoint = [self->_lock_outgoingEndpointPromise endpoint];
                    [self->_lock_outgoingConnection workspaceLock_setEndpoint:endpoint];
                }
                os_unfair_lock_unlock(&self->_lock);
                if (pid == v23 || !self->_shouldInjectEndpoint) {
                    os_log_t oslog3 = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                        id logProem2 = [v20 logProem];
                        os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%{public}@ Skipping workspace endpoint injector.", logProem2);
                    }
                } else {
                    id _dispatcher2 = [self->_synchronizer _dispatcher];
                    id domain = [_dispatcher2 domain];
                    self->_workspaceServiceInjector = [domain endpointInjectorTargetingProcess:v2];
                }
                [self _updateProcessAssertionState];
                [self _resolveSceneLifecycleStateAndInterruptionPolicy];
                if (v3 != nil) {
                    [v20 _noteAssertionStateDidChange];
                }
                void (^v37)(void) = ^void(void) {
                    __weak id v66 = v20;
                    void (^v67)(RBSProcessHandle *, RBSProcessExitContext *) = ^void(RBSProcessHandle *arg1, RBSProcessExitContext *arg2) {
                        if (v66 != nil) {
                            [v66 _processDidExitWithContext:[[FBProcessExitContext alloc] initWithUnderlyingContext:arg2]];
                        }
                    };
                    [v2 monitorForDeath:v67];
                };
                if (qos_class_self() <= 24) {
                    long v38 = BSDispatchBlockCreateWithQualityOfService(25, 0, v37);
                    v37 = v38;
                }
                v37();
                return;
            }
        }
        os_unfair_lock_unlock(&self->_lock);
        [v1 _launchDidComplete:0 finalizeBlock:^void(void) {
            [v1 _processDidExitWithContext:0];
        }];
        [v3 invalidate];
    }
}


void -[FBWorkspace _assertLocked](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_assert_owner(&self->_lock);
}


void -[FBWorkspace host:didUpdateSettings:withDiff:transitionContext:completion:](id a1, id a2, id a3, id a4, void (^a5)(bool, NSError *))
{
    void (^v6)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
        if (!a5) {
            return;
        } else {
            a5(arg1, arg2);
            return;
        }
    };
    id v7 = [self _sceneForHost:a1];
    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
    [_workspaceQueue performAsync:^void(void) {
        if (!v7) {
            NSDictionary *v5 = @{NSLocalizedFailureReasonErrorKey: @"Scene client is invalid."};
            NSError *v10 = [NSError errorWithDomain:@"FBWorkspace" code:1 userInfo:v5];
            v6(NO, v10);
            return;
        }
        [v7 workspace:self sendUpdatedSettings:a2 withDiff:a3 transitionContext:a4 completion:v6];
    }];
}


void -[FBWorkspace _lock](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_lock(&self->_lock);
}


void -[FBWorkspace _unlock](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBWorkspace _updateProcessAssertionState](void)
{
    int v26;
    RBSAssertion *v14;
    int v16;
    RBSAssertion *v21;
    NSString *v30;
    os_log_t v31;
    os_unfair_lock_lock(&self->_lock);
    os_unfair_lock_assert_owner(&self->_lock);
    if (__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    FBProcess *v3 = self->_weak_process;
    int v4 = &FBWorkspaceStateNone;
    id context = [self->_compoundAssertion context];
    int v8 = &FBWorkspaceStateNone;
    for (NSNumber *v11 in context) {
        unsigned int v12 = v4;
        if (v11 != nil) {
            v12 = [v11 unsignedIntValue];
        }
        v8 = FBWorkspaceStateCombine(v8, v12);
    }
    int fb_workspaceState = [self->_lock_lifeAssertion fb_workspaceState];
    if ((FBWorkspaceStateEqual(v8, fb_workspaceState) & 1) != 0) {
        v26 = 0;
        v14 = nil;
        goto blk_1c4ee180c;
    }
    v14 = self->_lock_lifeAssertion;
    self->_lock_lifeAssertion = nil;
    if (!self->_lock_connectAssertion) {
        v16 = v8;
    } else {
        v4 = FBWorkspaceStateCombine(v8, fb_workspaceState);
        v16 = fb_workspaceState;
    }
    if ((FBWorkspaceStateEqual(v16, v4) & 1) == 0) {
        RBSTarget *target = [v3 target];
        id _dispatcher = [self->_synchronizer _dispatcher];
        id domain = [_dispatcher domain];
        id v20 = [domain assertionAttributesForWorkspaceState:v8];
        if (!target) {
            v21 = nil;
        } else if (![v20 count]) {
            v21 = nil;
        } else {
            NSString *v22 = NSStringFromFBWorkspaceState(v8);
            NSString *v23 = [NSString stringWithFormat:@"FBWorkspace (%@)", v22];
            RBSAssertion *v24 = [[RBSAssertion alloc] initWithExplanation:v23 target:target attributes:v20];
            v21 = v24;
            self->_lock_lifeAssertion = v24;
            [self->_lock_lifeAssertion fb_setWorkspaceState:v8];
            [self->_lock_lifeAssertion addObserver:self];
        }
        v26 = 1;
    } else {
        v26 = 0;
blk_1c4ee180c:
        v21 = nil;
    }
    os_unfair_lock_unlock(&self->_lock);
    id v27 = nil;
    long v28 = [v21 acquireWithError:&v27];
    [v14 invalidate];
    if ((FBWorkspaceStateEqual(v8, fb_workspaceState) & 1) == 0) {
        if (v21) {
            v30 = (v28 != 0) ? @"assertion acquired" : @"assertion acquisition failed!";
        } else if (v26) {
            v30 = @"awaiting concrete target";
        } else {
            v30 = (!v14) ? @"assertion superseded" : @"assertion dropped";
        }
        v31 = FBLogProcessWorkspace();
        if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem2 = [v3 logProem];
            NSString *v33 = NSStringFromFBWorkspaceState(fb_workspaceState);
            NSString *v34 = NSStringFromFBWorkspaceState(v8);
            os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace state did change: %{public}@ --> %{public}@ (%@).", logProem2, v33, v34, v30);
        }
    } else if (v28 != 0) {
        v31 = FBLogProcessWorkspace();
        if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem3 = [v3 logProem];
            NSString *v37 = NSStringFromFBWorkspaceState(v8);
            os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace assertion acquired: %{public}@", logProem3, v37);
        }
    }
    if (v27 != nil) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            NSString *logProem = [v3 logProem];
            id v1 = [v27 descriptionWithMultilinePrefix:0];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ Workspace assertion failed: %{public}@", logProem, v1);
        }
    }
    if ((FBWorkspaceStateEqual(v8, fb_workspaceState) & 1) == 0) {
        [v3 _noteAssertionStateDidChange];
    }
}


void -[FBWorkspace _enableLegacyRequests:](id a1)
{
    if (self != nil) {
        FBProcess *v1 = self->_weak_process;
        if (a1 != v1) {
            NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process == _weak_process"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(_enableLegacyRequests:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBWorkspace.m", 639, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        os_unfair_lock_unlock(&self->_lock);
        if (self->_lock_pendedRequests) {
            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
            dispatch_async(queue, ^void(void) {
                os_unfair_lock_lock(&self->_lock);
                self->_lock_pendedRequests = nil;
                os_unfair_lock_unlock(&self->_lock);
                NSMutableArray *v11 = self->_lock_pendedRequests;
                for (id v8 in v11) {
                    [self _processCallOutQueue_requestScene:v8];
                }
            });
        }
    }
}


FBWorkspaceScene *-[FBWorkspace registerHost:settings:initialClientSettings:fromRemnant:error:](id a1, id a2, id a3, id a4, NSError **a5)
{
    id v43;
    id v44;
    NSError *v45;
    id v54;
    NSDictionary *v57;
    int v46;
    FBWorkspaceScene *v48;
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"host"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v68 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v68, v3, self, @"FBWorkspace.m", 854, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    id definition2 = [a1 definition];
    id<NSCopying> identity = [definition2 identity];
    FBSSceneClientIdentity *clientIdentity = [definition2 clientIdentity];
    long targetsClientEndpoint = [clientIdentity targetsClientEndpoint];
    FBSSceneSpecification *specification = [definition2 specification];
    Class v12 = NSClassFromString(@"FBSSceneIdentity");
    if (!identity) {
        NSString *v69 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v70 = NSStringFromSelector(_cmd);
            NSString *v71 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v70, v71, self, @"FBWorkspace.m", 859, v69);
        }
        _bs_set_crash_log_message([v69 UTF8String]);
        __break(0);
    }
    if (![identity isKindOfClass:v12]) {
        NSString *v73 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v74 = NSStringFromSelector(_cmd);
            NSString *v75 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v74, v75, self, @"FBWorkspace.m", 859, v73);
        }
        _bs_set_crash_log_message([v73 UTF8String]);
        __break(0);
    }
    Class v14 = NSClassFromString(@"FBSSceneSpecification");
    if (!specification) {
        NSString *v77 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v78 = NSStringFromSelector(_cmd);
            NSString *v79 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v78, v79, self, @"FBWorkspace.m", 860, v77);
        }
        _bs_set_crash_log_message([v77 UTF8String]);
        __break(0);
    }
    if (![specification isKindOfClass:v14]) {
        NSString *v81 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSpecificationClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v82 = NSStringFromSelector(_cmd);
            NSString *v83 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v82, v83, self, @"FBWorkspace.m", 860, v81);
        }
        _bs_set_crash_log_message([v81 UTF8String]);
        __break(0);
    }
    Class v16 = NSClassFromString(@"FBSSceneSettings");
    if (!a2) {
        NSString *v85 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v86 = NSStringFromSelector(_cmd);
            NSString *v87 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v86, v87, self, @"FBWorkspace.m", 861, v85);
        }
        _bs_set_crash_log_message([v85 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v16]) {
        NSString *v89 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v90 = NSStringFromSelector(_cmd);
            NSString *v91 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v90, v91, self, @"FBWorkspace.m", 861, v89);
        }
        _bs_set_crash_log_message([v89 UTF8String]);
        __break(0);
    }
    Class settingsClass = [specification settingsClass];
    if (![a2 isKindOfClass:settingsClass]) {
        id settingsClass2 = [specification settingsClass];
        NSString *v19 = [NSString stringWithFormat:@"settings of an unexpected class: expected %@, got %@", settingsClass2, [a2 class]];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v93 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v93, self, @"FBWorkspace.m", 862, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    Class v21 = NSClassFromString(@"FBSSceneClientSettings");
    if (!a3) {
        NSString *v95 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v96 = NSStringFromSelector(_cmd);
            NSString *v97 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v96, v97, self, @"FBWorkspace.m", 863, v95);
        }
        _bs_set_crash_log_message([v95 UTF8String]);
        __break(0);
    }
    if (![a3 isKindOfClass:v21]) {
        NSString *v99 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneClientSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v100 = NSStringFromSelector(_cmd);
            NSString *v101 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v100, v101, self, @"FBWorkspace.m", 863, v99);
        }
        _bs_set_crash_log_message([v99 UTF8String]);
        __break(0);
    }
    Class clientSettingsClass = [specification clientSettingsClass];
    if (![a3 isKindOfClass:clientSettingsClass]) {
        id clientSettingsClass2 = [specification clientSettingsClass];
        NSString *v24 = [NSString stringWithFormat:@"initialClientSettings of an unexpected class: expected %@, got %@", clientSettingsClass2, [a3 class]];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v103 = NSStringFromSelector(_cmd);
            NSString *v104 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v103, v104, self, @"FBWorkspace.m", 864, v24);
        }
        _bs_set_crash_log_message([v24 UTF8String]);
        __break(0);
    }
    long v25 = a2;
    if (a4 != nil) {
        if (![a4 isKindOfClass:NSClassFromString(@"FBSceneRemnant")]) {
            NSString *v106 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneRemnantClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v107 = NSStringFromSelector(_cmd);
                NSString *v108 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v107, v108, self, @"FBWorkspace.m", 866, v106);
            }
            _bs_set_crash_log_message([v106 UTF8String]);
            __break(0);
        }
        if ([a4 _hasBeenInvalidated]) {
            NSString *v110 = [NSString stringWithFormat:@"cannot create a scene from an invalidated remnant"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v111 = NSStringFromSelector(_cmd);
                NSString *v112 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v111, v112, self, @"FBWorkspace.m", 867, v110);
            }
            _bs_set_crash_log_message([v110 UTF8String]);
            __break(0);
        }
        FBWorkspace *_workspace = [a4 _workspace];
        if (_workspace != self) {
            NSString *v114 = [NSString stringWithFormat:@"remnant doesn't match this workspace"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v115 = NSStringFromSelector(_cmd);
                NSString *v116 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v115, v116, self, @"FBWorkspace.m", 868, v114);
            }
            _bs_set_crash_log_message([v114 UTF8String]);
            __break(0);
        }
        FBSSceneDefinition *definition = [a4 definition];
        FBSSceneSpecification *specification2 = [definition specification];
        Class v30 = [specification2 class];
        Class v31 = [specification class];
        v25 = a2;
        if (v30 != v31) {
            NSString *v118 = [NSString stringWithFormat:@"specification must match the remnant"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v119 = NSStringFromSelector(_cmd);
                NSString *v120 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v119, v120, self, @"FBWorkspace.m", 869, v118);
            }
            _bs_set_crash_log_message([v118 UTF8String]);
            __break(0);
        }
    }
    os_unfair_lock_lock(&self->_lock);
    NSMutableDictionary *v32 = self->_lock_identityToSceneMap;
    if (!self->_lock_identityToSceneMap) {
        self->_lock_identityToSceneMap = [NSMutableDictionary new];
        v32 = self->_lock_identityToSceneMap;
    }
    id v35 = [v32 objectForKey:identity];
    if (v35 != nil) {
        id v36 = [self->_lock_identityToSceneMap objectForKey:identity];
        NSString *debugDescription = [a1 debugDescription];
        NSString *v38 = [NSString stringWithFormat:@"cannot register a host that is already registered : existing=%@ : host=%@", v36, debugDescription];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v122 = NSStringFromSelector(_cmd);
            NSString *v123 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v122, v123, self, @"FBWorkspace.m", 878, v38);
        }
        _bs_set_crash_log_message([v38 UTF8String]);
        __break(0);
    }
    if (self->_lock_didReceiveHandshake != 1) {
        if (a4 != nil) {
            NSString *v125 = [NSString stringWithFormat:@"how could you call createWithRemnant: if we haven't made any remnants"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v126 = NSStringFromSelector(_cmd);
                NSString *v127 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v126, v127, self, @"FBWorkspace.m", 885, v125);
            }
            _bs_set_crash_log_message([v125 UTF8String]);
            __break(0);
        }
        NSMutableDictionary *v39 = self->_lock_identityToRemnantsMap;
        if (!self->_lock_identityToRemnantsMap) {
            self->_lock_identityToRemnantsMap = [NSMutableDictionary new];
            v39 = self->_lock_identityToRemnantsMap;
        }
        NSNull *null = [NSNull null];
        [v39 setObject:null forKey:identity];
        v43 = nil;
    } else {
        v43 = [self->_lock_identityToRemnantsMap objectForKey:identity];
    }
    os_unfair_lock_assert_owner(&self->_lock);
    if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
        if (self->_test_rejectAllSceneClients != 1) {
            if ((uint32_t)targetsClientEndpoint == 0) {
                if (!a4) {
                    v44 = self->_lock_incomingConnection;
                    v45 = a4;
                    goto blk_1c4ee6514;
                }
                if (a4 != v43) {
                    os_log_t oslog2 = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "invalid remnant specified: remnant=%{public}@ connection=%{public}@", a4, 0);
                    }
                    v54 = NSError;
                    v57 = @{NSLocalizedFailureReasonErrorKey: @"Invalid scene remnant provided."};
                    goto blk_1c4ee6240;
                }
                [self->_lock_identityToRemnantsMap removeObjectForKey:identity];
                v44 = self->_lock_incomingConnection;
                v45 = nil;
                v46 = 1;
                if (v44 != nil) {
blk_1c4ee651c:
                    long workspaceLock_isValid = [v44 workspaceLock_isValid];
                    if ((workspaceLock_isValid & 1) == 0) {
                        NSString *v130 = [NSString stringWithFormat:@"internal state error : connection is invalidated"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v131 = NSStringFromSelector(_cmd);
                            NSString *v132 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v131, v132, self, @"FBWorkspace.m", 932, v130);
                        }
                        _bs_set_crash_log_message([v130 UTF8String]);
                        __break(0);
                    }
                    v48 = [[FBWorkspaceScene alloc] initWithConnection:v44 host:a1 settings:v25 clientSettings:a3 fromRemnant:v46];
                    [self->_lock_identityToSceneMap setObject:v48 forKey:identity];
                    FBProcess *v49 = self->_weak_process;
                    os_log_t oslog = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                        NSString *logProem = [v49 logProem];
                        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Registered new scene: %{public}@ (fromRemnant = %d)", logProem, v48, (uint32_t)v46);
                    }
                } else {
blk_1c4ee64c8:
                    v48 = nil;
                }
blk_1c4ee627c:
                os_unfair_lock_unlock(&self->_lock);
                BSSimpleAssertion *_assertion = [v43 _assertion];
                [_assertion invalidate];
                id _workspaceQueue = [self->_synchronizer _workspaceQueue];
                [_workspaceQueue performAsync:^void(void) {
                    [self _resolveSceneLifecycleStateAndInterruptionPolicy];
                }];
                if (a5 != 0) {
                    *(a5) = v45;
                }
                return v48;
            }
            NSXPCListenerEndpoint *endpoint = [self->_lock_outgoingEndpointPromise endpoint];
            if (![endpoint isNullEndpoint]) {
                if (!self->_lock_outgoingConnection) {
                    FBWorkspaceOutgoingConnection *v63 = [[FBWorkspaceOutgoingConnection alloc] initWithWorkspace:self];
                    self->_lock_outgoingConnection = v63;
                    v44 = v63;
                    if (endpoint != nil) {
                        [self->_lock_outgoingConnection workspaceLock_setEndpoint:endpoint];
                    }
                } else {
                    v44 = self->_lock_outgoingConnection;
                }
                v45 = nil;
            } else {
                NSDictionary *v67 = @{NSLocalizedFailureReasonErrorKey: @"Workspace cannot establish a connection to a null endpoint."};
                v45 = [NSError errorWithDomain:@"FBWorkspace" code:1 userInfo:v67];
                v44 = nil;
                v25 = a2;
            }
blk_1c4ee6514:
            v46 = 0;
            if (!v44) {
                goto blk_1c4ee64c8;
            } else {
                goto blk_1c4ee651c;
            }
        }
        v54 = NSError;
        v57 = @{NSLocalizedFailureReasonErrorKey: @"Workspace is rejecting all clients for unit tests."};
    } else {
        v54 = NSError;
        v57 = @{NSLocalizedFailureReasonErrorKey: @"Workspace has been invalidated (process has exited)."};
    }
blk_1c4ee6240:
    v45 = [v54 errorWithDomain:@"FBWorkspace" code:1 userInfo:v57];
    v44 = nil;
    v48 = nil;
    goto blk_1c4ee627c;
}


void -[FBWorkspace _resolveSceneLifecycleStateAndInterruptionPolicy](void)
{
    RBSAssertion *v16;
    RBSAssertion *v17;
    NSString *v23;
    NSArray *v24;
    long v26;
    long v28;
    FBProcess *v0 = self->_weak_process;
    RBSTarget *target = [v0 target];
    os_unfair_lock_lock(&self->_lock);
    os_unfair_lock_assert_owner(&self->_lock);
    if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
        NSEnumerator *objectEnumerator = [self->_lock_identityToSceneMap objectEnumerator];
        long v6 = 0;
        int v7 = 0;
        for (id v22 in objectEnumerator) {
            FBSSceneSettings *settings = [v22 settings];
            int v11 = FBSceneLifecycleStateForSettings(settings);
            v7 = ((unsigned int)v11 > (uint8_t)v7) ? v11 : v7 & 255;
            long v13 = [settings interruptionPolicy];
            if (!v13) {
                id _dispatcher = [self->_synchronizer _dispatcher];
                id domain = [_dispatcher domain];
                v13 = [domain defaultSceneInterruptionPolicy];
            }
            if (v13 > v6) {
                v6 = v13;
            }
        }
        if (!target) {
            v16 = nil;
            v17 = nil;
        } else if (self->_lock_activeInterruptionPolicy != v6) {
            self->_lock_activeInterruptionPolicy = v6;
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                NSString *logProem = [v0 logProem];
                id v20 = NSStringFromFBSSceneInterruptionPolicy(v6);
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace interruption policy did change: %{public}@", logProem, v20);
            }
            if (!self->_lock_activeInterruptionPolicy) {
                v23 = nil;
                v24 = nil;
            } else {
                long *v30 = (self->_lock_activeInterruptionPolicy == 3) ? &v26 : &v28;
                v23 = (self->_lock_activeInterruptionPolicy == 3) ? @"com.apple.frontboard.after-life.subordinate" : @"com.apple.frontboard.after-life.interrupted";
                *(v30) = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:(self->_lock_activeInterruptionPolicy == 3) ? @"AfterLife-Subordinate" : @"AfterLife-Interrupted"];
                v24 = [NSArray arrayWithObjects:v30 count:1];
            }
            v17 = self->_lock_afterlifeAssertion;
            self->_lock_afterlifeAssertion = nil;
            if (![v24 count]) {
                v16 = nil;
            } else {
                RBSAssertion *v33 = [[RBSAssertion alloc] initWithExplanation:v23 target:target attributes:v24];
                v16 = v33;
                self->_lock_afterlifeAssertion = v33;
            }
        } else {
            v16 = nil;
            v17 = nil;
        }
        os_unfair_lock_unlock(&self->_lock);
        [v17 invalidate];
        if (v16) {
            id v36 = nil;
            long v37 = [v16 acquireWithError:&v36];
            if ((v37 & 1) == 0) {
                os_log_t oslog2 = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                    NSString *logProem2 = [v0 logProem];
                    os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%{public}@ Workspace afterlife assertion failed: %{public}@", logProem2, v36);
                }
            }
        }
        if ([v0 _setSceneLifecycleState:v7] != 0) {
            [self _updateProcessAssertionState];
        }
    } else {
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBWorkspace sceneID:didUpdateClientSettingsWithDiff:transitionContext:completion:](id a1, id a2, id a3, void (^a4)(long))
{
    id v4 = [self _sceneForIdentity:a1];
    if (!v4) {
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] No scene exists for this identity (didUpdateClientSettingsWithDiff)", a1);
        }
    } else {
        id currentWorkspaceConnection = [FBWorkspaceConnection currentWorkspaceConnection];
        [v4 workspace:self handleUpdatedClientSettings:a2 transitionContext:a3 fromConnection:currentWorkspaceConnection];
    }
    if (a4 != nil) {
        a4(0);
    }
}


void -[FBWorkspace state](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_lock(&self->_lock);
    int v0 = &FBWorkspaceStateNone;
    if (self->_lock_lifeAssertion != nil) {
        int fb_workspaceState = [self->_lock_lifeAssertion fb_workspaceState];
        v0 = FBWorkspaceStateCombine(v0, fb_workspaceState);
    }
    if (self->_lock_connectAssertion != nil) {
        int fb_workspaceState2 = [self->_lock_connectAssertion fb_workspaceState];
        FBWorkspaceStateCombine(v0, fb_workspaceState2);
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBWorkspace _consumeIncomingConnection:](id a1)
{
    id v0 = a1;
    if (self != nil) {
        os_unfair_lock_lock(&self->_lock);
        FBProcess *v1 = self->_weak_process;
        os_unfair_lock_assert_owner(&self->_lock);
        if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
            [self->_lock_incomingConnection workspaceLock_consumeConnection:v0];
        } else {
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                NSString *logProem = [v1 logProem];
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ attempted to assign a new connection to an invalidated workspace server.", logProem);
            }
            BSServiceQueue *serviceQueue = [self->_synchronizer serviceQueue];
            [serviceQueue performAfter:0.1 withBlock:^void(void) {
                [v0 cancel];
            }];
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBWorkspace _workspaceSceneLifecycleStateChanged:](id a1)
{
    if (self != nil && a1 != nil) {
        id identity = [a1 identity];
        id v2 = [self _sceneForIdentity:identity];
        if (v2 == a1) {
            [self _resolveSceneLifecycleStateAndInterruptionPolicy];
        }
    }
}


void -[FBWorkspace handshakeWithRemnants:](id a1)
{
    os_log_t v4;
    NSString *v10;
    id v11;
    id v12;
    NSString *v13;
    NSString *v14;
    os_log_t v15;
    long v16;
    os_log_t v18;
    FBWorkspace *v20;
    BOOL v41;
    BSSimpleAssertion *v44;
    id v66;
    NSMutableSet *set;
    NSFastEnumerationState v55;
    id v58;
    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
    [_workspaceQueue assertBarrierOnQueue];
    FBProcess *process = [self process];
    id currentWorkspaceConnection = [FBWorkspaceConnection currentWorkspaceConnection];
    if (!currentWorkspaceConnection) {
        v4 = FBLogProcessWorkspace();
        if (os_log_type_enabled(v4, OS_LOG_TYPE_ERROR)) {
            NSString *debugDescription3 = [process debugDescription];
            id currentContext2 = [BSServiceConnection currentContext];
            id remoteToken2 = [currentContext2 remoteToken];
            long count3 = [a1 count];
            os_log_with_type(v4, OS_LOG_TYPE_ERROR, "ignoring handshake for unknown connection : process=%@ remote=%@ remnants=%u", debugDescription3, remoteToken2, count3);
        }
    } else {
        Class v7 = [currentWorkspaceConnection class];
        Class v8 = [FBWorkspaceOutgoingConnection class];
        if (v7 == v8) {
            if (![currentWorkspaceConnection queue_isVerified]) {
                v10 = [process description];
                v11 = [BSServiceConnection currentContext];
                v12 = [v11 remoteToken];
                v13 = [a1 description];
                v14 = [NSString stringWithFormat:@"outgoing connection handshake wasn't verified or included remnants: process=%@ remote=%@ remnants=%@", v10, v12, v13];
                [self _terminateWithReason:v14];
                v15 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v15, OS_LOG_TYPE_FAULT)) {
                    v16 = [a1 count];
                    os_log_with_type(v15, OS_LOG_TYPE_FAULT, "outgoing connection handshake included remnants : process=%@ remote=%@ remnants=%u", v10, v12, v16);
                }
                return;
            }
            if (![a1 count]) {
                v4 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v4, OS_LOG_TYPE_DEFAULT)) {
                    NSString *debugDescription2 = [process debugDescription];
                    os_log_with_type(v4, OS_LOG_TYPE_DEFAULT, "received outgoing handshake : process=%@", debugDescription2);
                }
            } else {
                v10 = [process description];
                v11 = [BSServiceConnection currentContext];
                v12 = [v11 remoteToken];
                v13 = [a1 description];
                v14 = [NSString stringWithFormat:@"outgoing connection handshake wasn't verified or included remnants: process=%@ remote=%@ remnants=%@", v10, v12, v13];
                [self _terminateWithReason:v14];
                v15 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v15, OS_LOG_TYPE_FAULT)) {
                    v16 = [a1 count];
                    os_log_with_type(v15, OS_LOG_TYPE_FAULT, "outgoing connection handshake included remnants : process=%@ remote=%@ remnants=%u", v10, v12, v16);
                }
            }
            return;
        }
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_didReceiveHandshake != 1) {
            self->_lock_didReceiveHandshake = YES;
            os_unfair_lock_assert_owner(&self->_lock);
            if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
                v18 = FBLogProcessWorkspace();
                if (self->_lock_eventDispatcherSource != nil) {
                    bool v19 = os_log_type_enabled(v18, OS_LOG_TYPE_DEFAULT);
                    v20 = self;
                    if (v19) {
                        NSString *debugDescription = [process debugDescription];
                        id currentContext = [BSServiceConnection currentContext];
                        id remoteToken = [currentContext remoteToken];
                        long count = [a1 count];
                        os_log_with_type(v18, OS_LOG_TYPE_DEFAULT, "received incoming handshake : process=%@ remote=%@ remnants=%u", debugDescription, remoteToken, count);
                        v20 = self;
                    }
                    set = [NSMutableSet set];
                    for (id v32 in a1) {
                        id identity = [v32 identity];
                        if (identity != nil) {
                            id internalWorkspaceIdentifier = [identity internalWorkspaceIdentifier];
                            RBSProcessIdentity *identity2 = [process identity];
                            id parameters = [v32 parameters];
                            if (internalWorkspaceIdentifier) {
                                id _dispatcher = [v20->_synchronizer _dispatcher];
                                id domain = [_dispatcher domain];
                                id reconnectableWorkspaces = [domain reconnectableWorkspaces];
                                v41 = [reconnectableWorkspaces containsObject:internalWorkspaceIdentifier];
                                v20 = self;
                                if (v41 && identity2 && parameters) {
                                    id v45 = [self->_lock_identityToRemnantsMap objectForKey:identity];
                                    if (v45 != nil) {
                                        v44 = nil;
                                    } else {
                                        v44 = [[BSSimpleAssertion alloc] initWithIdentifier:@"com.apple.frontboard.workspace.remnant" forReason:[identity description] invalidationBlock:^void(BSSimpleAssertion *arg1) {
                                            if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
                                                os_unfair_lock_lock(&self->_lock);
                                                os_unfair_lock_assert_owner(&self->_lock);
                                                if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
                                                    id v80 = [self->_lock_identityToRemnantsMap objectForKey:identity];
                                                    BSSimpleAssertion *v81 = [v80 _assertion];
                                                    if (v81 == arg1) {
                                                        [self->_lock_identityToRemnantsMap removeObjectForKey:identity];
                                                        if (![self->_lock_identityToRemnantsMap count]) {
                                                            self->_lock_identityToRemnantsMap = nil;
                                                        }
                                                        [self->_lock_incomingConnection workspaceLock_enqueueConnectBlock:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                                                            [arg1 sceneID:identity destroyWithTransitionContext:0 completion:^void(NSError *arg1) {
                                                            }];
                                                        }];
                                                    }
                                                }
                                                os_unfair_lock_unlock(&self->_lock);
                                            }
                                        }];
                                    }
                                    id v49 = [FBSSceneClientIdentity identityForProcessIdentity:identity2];
                                    [set addObject:[[FBSceneRemnant alloc] _initWithIdentity:identity client:v49 workspace:self parameters:parameters assertionQueue:0 assertion:v44]];
                                    v20 = self;
                                }
                            }
                            if (!internalWorkspaceIdentifier || !v41 || !identity2 || !parameters) {
                                id v42 = [v20->_lock_identityToRemnantsMap objectForKey:identity];
                                if (v42 == nil) {
                                    void (^v43)(id<FBSWorkspaceServiceServerInterface>) = ^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                                        [arg1 sceneID:identity destroyWithTransitionContext:0 completion:^void(NSError *arg1) {
                                        }];
                                    };
                                    [v20->_lock_incomingConnection workspaceLock_enqueueConnectBlock:v43];
                                }
                            }
                        }
                    }
                    goto blk_1c4eec8e0;
                } else if (os_log_type_enabled(v18, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v18, OS_LOG_TYPE_ERROR, "ignoring handshake because we have no dispatcher registration");
                }
            } else {
                v18 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v18, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v18, OS_LOG_TYPE_ERROR, "ignoring handshake because we're already invalidating");
                }
            }
            os_unfair_lock_unlock(&self->_lock);
            return;
        }
        os_unfair_lock_unlock(&self->_lock);
        v4 = FBLogProcessWorkspace([self _terminateWithReason:@"double handshake"]);
        if (os_log_type_enabled(v4, OS_LOG_TYPE_FAULT)) {
            NSString *debugDescription4 = [process debugDescription];
            id currentContext3 = [BSServiceConnection currentContext];
            id remoteToken3 = [currentContext3 remoteToken];
            long count4 = [a1 count];
            os_log_with_type(v4, OS_LOG_TYPE_FAULT, "double handshake detected : process=%@ remote=%@ remnants=%u", debugDescription4, remoteToken3, count4);
            return;
        }
        return;
blk_1c4eec8e0:
        NSUInteger count2 = [set count];
        NSMutableDictionary *v52 = v20->_lock_identityToRemnantsMap;
        if (!count2) {
            v20->_lock_identityToRemnantsMap = nil;
            FBWorkspace *v78 = v20;
            v66 = [v78->_synchronizer _dispatcher];
            [v66 noteHandshakeFromSource:v78->_lock_eventDispatcherSource withRemnants:set];
            os_unfair_lock_unlock(&v78->_lock);
            return;
        }
        if (!v52) {
            v20->_lock_identityToRemnantsMap = [NSMutableDictionary new];
        } else {
            [v52 removeAllObjects];
        }
        _memset(v55, 0, 64);
        NSUInteger v57 = [set countByEnumeratingWithState:&v55 objects:&v58 count:16];
        if (!v57) {
            if (![self->_lock_identityToRemnantsMap count]) {
                self->_lock_identityToRemnantsMap = nil;
            }
            v66 = [self->_synchronizer _dispatcher];
            [v66 noteHandshakeFromSource:self->_lock_eventDispatcherSource withRemnants:set];
            os_unfair_lock_unlock(&self->_lock);
            return;
        }
        long v60 = *(v55.mutationsPtr);
        do {
            long v61 = 0;
            do {
                if (*(v55.mutationsPtr) != v60) {
                    objc_enumerationMutation(set);
                }
                id v62 = v55.itemsPtr[v61];
                BSSimpleAssertion *_assertion = [v62 _assertion];
                if (_assertion != nil) {
                    id definition = [v62 definition];
                    id<NSCopying> identity3 = [definition identity];
                    [self->_lock_identityToRemnantsMap setObject:v62 forKey:identity3];
                }
                v61++;
                v57--;
            } while (v57 != 0);
            v57 = [set countByEnumeratingWithState:&v55 objects:&v58 count:16];
        } while (v57 != 0);
        if (![self->_lock_identityToRemnantsMap count]) {
            self->_lock_identityToRemnantsMap = nil;
            v66 = [self->_synchronizer _dispatcher];
            [v66 noteHandshakeFromSource:self->_lock_eventDispatcherSource withRemnants:set];
            os_unfair_lock_unlock(&self->_lock);
            return;
        }
        v66 = [self->_synchronizer _dispatcher];
        [v66 noteHandshakeFromSource:self->_lock_eventDispatcherSource withRemnants:set];
        os_unfair_lock_unlock(&self->_lock);
    }
}


id -[FBWorkspace _acquireAssertionForReason:withState:](id a1, long a2)
{
    if (!self) {
        return nil;
    }
    NSNumber *v2 = [NSNumber numberWithUnsignedInt:a2];
    return [self->_compoundAssertion acquireForReason:a1 withContext:v2];
}


id -[FBWorkspace description](void)
{
    FBProcess *v0 = self->_weak_process;
    id v1 = [BSDescriptionBuilder builderWithObject:self];
    id succinctDescription = [v0 succinctDescription];
    [v1 appendObject:succinctDescription withName:0];
    return [v1 build];
}


void -[FBWorkspace _dropLaunchAssertion](void)
{
    os_unfair_lock_lock(&self->_lock);
    RBSAssertion *v0 = self->_lock_connectAssertion;
    self->_lock_connectAssertion = nil;
    os_unfair_lock_unlock(&self->_lock);
    [self _updateProcessAssertionState];
    if ([v0 isValid]) {
        FBProcess *v2 = self->_weak_process;
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [v2 logProem];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Dropping launch assertion.", logProem);
        }
        [v0 invalidate];
        [v2 _noteAssertionStateDidChange];
    }
}


FBProcess *-[FBWorkspace process](void)
{
    return self->_weak_process;
}


id -[FBWorkspace _sceneForHost:](id a1)
{
    id definition = [a1 definition];
    id identity = [definition identity];
    id v3 = [self _sceneForIdentity:identity];
    id host = [v3 host];
    if (host == a1) {
        return v3;
    }
    return nil;
}


id -[FBWorkspace _sceneForIdentity:](id a1)
{
    Class v1 = NSClassFromString(@"FBSSceneIdentity");
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBWorkspace.m", 253, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBWorkspace.m", 253, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    id v2 = [self->_lock_identityToSceneMap objectForKey:a1];
    os_unfair_lock_unlock(&self->_lock);
    return v2;
}


void -[FBWorkspace _handleSceneRequest:](id a1)
{
    long v2;
    NSString *v9;
    long v11;
    id v0 = a1;
    os_unfair_lock_lock(&self->_lock);
    os_unfair_lock_assert_owner(&self->_lock);
    if (__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
        os_log_t oslog3 = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
            id currentContext = [BSServiceConnection currentContext];
            id remoteProcess = [currentContext remoteProcess];
            os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "ignoring scene request because we're already invalidating : from=%@", remoteProcess);
        }
        v2 = FBSWorkspaceErrorCreate(0, 2, @"FBWorkspace is already invalidating");
        [v0 invalidateWithError:v2];
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    if (!self->_lock_eventDispatcherSource) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id currentContext2 = [BSServiceConnection currentContext];
            id remoteProcess2 = [currentContext2 remoteProcess];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "ignoring scene request because we have no dispatcher registration : from=%@", remoteProcess2);
        }
        v2 = FBSWorkspaceErrorCreate(0, 2, @"FBWorkspace has no dispatcher registration");
        [v0 invalidateWithError:v2];
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    if (!self->_lock_didReceiveHandshake) {
        os_log_t oslog2 = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
            id currentContext3 = [BSServiceConnection currentContext];
            id remoteProcess3 = [currentContext3 remoteProcess];
            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "ignoring request before handshake : from=%@", remoteProcess3);
        }
        os_unfair_lock_unlock(&self->_lock);
        [self _terminateWithReason:@"scene request before handshake"];
        id v5 = FBSWorkspaceErrorCreate(0, 2, @"FBWorkspace hasn't yet received a handshake");
        [v0 invalidateWithError:v5];
        return;
    }
    id _dispatcher2 = [self->_synchronizer _dispatcher];
    long v7 = [_dispatcher2 handleSceneRequest:v0 fromSource:self->_lock_eventDispatcherSource];
    if ((v7 & 1) != 0) {
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    if (([v0 requiresModernDispatcher] & 1) != 0) {
        v9 = [v0 targetIdentifier];
        v11 = FBSWorkspaceErrorCreate(0, 3, @"no workspace \"%@\" is defined to handle this request", v9);
        [v0 invalidateWithError:v11];
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    id _dispatcher = [self->_synchronizer _dispatcher];
    id domain = [_dispatcher domain];
    long isDefaultWorkspaceDisabled = [domain isDefaultWorkspaceDisabled];
    if (isDefaultWorkspaceDisabled != 0) {
        v9 = [v0 targetIdentifier];
        v11 = FBSWorkspaceErrorCreate(0, 3, @"no workspace \"%@\" is defined to handle this request", v9);
        [v0 invalidateWithError:v11];
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    NSMutableArray *v15 = self->_lock_pendedRequests;
    if (!self->_lock_pendedRequests) {
        NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
        dispatch_async(queue, ^void(void) {
            os_unfair_lock_lock(&self->_lock);
            if (!self) {
                os_unfair_lock_unlock(136);
            } else {
                os_unfair_lock_assert_owner(&self->_lock);
                long v27 = ({ int __expected = 1; __atomic_compare_exchange_n(&(self->_invalidated), &__expected, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED); __expected; });
                os_unfair_lock_unlock(&self->_lock);
                if (v27 == 1) {
                    id v28 = FBSWorkspaceErrorCreate(0, 2, @"the process invalidated before the callout could be made");
                    [v0 invalidateWithError:v28];
                    return;
                }
            }
            [self _processCallOutQueue_requestScene:v0];
        });
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    [v15 addObject:v0];
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBWorkspace requestSceneWithOptions:completion:](id a1, void (^a2)(FBSSceneIdentity *, NSError *))
{
    NSError *v3;
    Class v5;
    Class v6;
    id v11;
    void (^v1)(FBSSceneIdentity *, NSError *) = a2;
    id currentWorkspaceConnection = [FBWorkspaceConnection currentWorkspaceConnection];
    if (currentWorkspaceConnection) {
        v5 = [currentWorkspaceConnection class];
        v6 = [FBWorkspaceOutgoingConnection class];
        if (v5 == v6) {
            if (v1 != nil) {
                v3 = FBSWorkspaceErrorCreate(0, 2, @"requestScene is not yet supported on directEndpoint connections");
            }
        } else if (v1 != nil) {
            NSString *workspaceIdentifier = [a1 workspaceIdentifier];
            if (!workspaceIdentifier) {
                id _dispatcher = [self->_synchronizer _dispatcher];
                id domain = [_dispatcher domain];
                v11 = [domain defaultWorkspace];
            } else {
                v11 = workspaceIdentifier;
            }
            RBSProcessHandle *processHandle = [self->_synchronizer processHandle];
            id identity = [processHandle identity];
            id v14 = [FBSSceneClientIdentity identityForInjectedEndpointToProcessIdentity:identity];
            [self _handleSceneRequest:[[FBWorkspaceSceneRequest alloc] initWithClientIdentity:v14 targetIdentifier:v11 options:a1 completion:^void(FBScene *arg1, NSError *arg2) {
                NSError *v24;
                if (!arg1) {
                    if (v1 != nil) {
                        v1(nil, arg2);
                        return;
                    }
                    return;
                }
                FBSSceneIdentity *identity = [arg1 identity];
                id v23 = [self _sceneForIdentity:identity];
                if (v23 != nil) {
                    id host = [v23 host];
                    if (host == arg1) {
                        [v23 _enqueueSceneCreateCompletionBlock:^void(bool arg1, NSError *arg2) {
                            NSError *v28;
                            if (!arg1) {
                                v28 = FBSWorkspaceErrorCreate(arg2, 1, @"scene invalidated before create completion");
                                v1(nil, v28);
                            } else {
                                id v4 = [self _sceneForIdentity:identity];
                                if (v4 == v23) {
                                    v1(identity, nil);
                                } else {
                                    v28 = FBSWorkspaceErrorCreate(arg2, 1, @"scene invalidated before create completion");
                                    v1(nil, v28);
                                }
                            }
                        }];
                        return;
                    }
                }
                if (![arg1 isValid]) {
                    v24 = FBSWorkspaceErrorCreate(0, 1, @"the host returned a scene, but it was either inactive or invalid");
                } else if (![arg1 isActive]) {
                    v24 = FBSWorkspaceErrorCreate(0, 1, @"the host returned a scene, but it was either inactive or invalid");
                } else {
                    v24 = FBSWorkspaceErrorCreate(0, 1, @"the host returned a scene, but it could not be found within this workspace");
                }
                v1(nil, v24);
            }]];
        }
    } else if (v1 != nil) {
        v3 = FBSWorkspaceErrorCreate(0, 2, @"failed to identify the connection");
    }
    if ((!currentWorkspaceConnection && v1 != nil) || (currentWorkspaceConnection && v5 == v6 && v1 != nil)) {
        v1(nil, v3);
    }
}


void -[FBWorkspace sendActions:](id a1)
{
    if ([a1 count] != 0) {
        Class v1 = [BSAction class];
        id v3 = a1;
        for (id v8 in v3) {
            if (![v8 isKindOfClass:v1]) {
                NSString *v17 = [NSString stringWithFormat:@"only actions of type BSAction can be sent : tried to send %@", v8];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v2 = NSStringFromSelector(_cmd);
                    NSString *v18 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v18, self, @"FBWorkspace.m", 180, v17);
                }
                _bs_set_crash_log_message([v17 UTF8String]);
                __break(0);
            }
        }
        os_unfair_lock_lock(&self->_lock);
        os_unfair_lock_assert_owner(&self->_lock);
        if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
            FBProcess *v9 = self->_weak_process;
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                NSString *logProem = [v9 logProem];
                id fbs_singleLineDescriptionOfBSActions = [v3 fbs_singleLineDescriptionOfBSActions];
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Sending action(s): %{public}@", logProem, fbs_singleLineDescriptionOfBSActions);
            }
            [self->_lock_incomingConnection workspaceLock_enqueueConnectBlock:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                FBProcess *v20 = self->_weak_process;
                RBSTarget *target = [v20 target];
                if (!arg1 || !target) {
                    for (id v23 in v3) {
                        [v23 invalidate];
                    }
                } else {
                    int v29 = FBWorkspaceStateCreate(1, 3, 40);
                    id v21 = [self _acquireAssertionForReason:@"Send Actions" withState:v29];
                    BSAtomicSignal *v22 = [BSAtomicSignal new];
                    void (^v24)(void) = ^void(void) {
                        if (![v22 signal]) {
                            return;
                        }
                        [v21 invalidate];
                    };
                    [arg1 sendActions:v3 completion:^void(NSError *arg1) {
                        v24();
                    }];
                    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
                    [_workspaceQueue performAfter:5.0 withBlock:v24];
                }
            }];
        } else {
            id _workspaceQueue = [self->_synchronizer _workspaceQueue];
            void (^v16)(void) = ^void(void) {
                for (id v31 in v3) {
                    [v31 invalidate];
                }
            };
            [_workspaceQueue performAsync:v16];
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBWorkspace sceneID:didReceiveActions:forExtension:](id a1, id a2, NSString *a3)
{
    os_log_t v4;
    long v6;
    id v3 = [self _sceneForIdentity:a1];
    if (!v3) {
        v4 = FBLogProcessScene();
        if (os_log_type_enabled(v4, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v4, OS_LOG_TYPE_ERROR, "[%{public}@] Unable to deliver actions because no scene exists with this identity.", a1);
        }
        return;
    }
    if (!a3) {
        v6 = [FBWorkspaceConnection currentWorkspaceConnection];
        [v3 workspace:self handleActions:a2 forExtension:0 fromConnection:v6];
        return;
    }
    Class v5 = NSClassFromString(a3);
    if (v5 != 0) {
        v6 = [FBWorkspaceConnection currentWorkspaceConnection];
        [v3 workspace:self handleActions:a2 forExtension:v5 fromConnection:v6];
        return;
    }
    v4 = FBLogProcessScene();
    if (os_log_type_enabled(v4, OS_LOG_TYPE_ERROR)) {
        os_log_with_type(v4, OS_LOG_TYPE_ERROR, "[%{public}@] Unable to deliver actions to extension \"%{public}@\" because that class does not exist.", a1, a3);
        return;
    }
}


id -[FBWorkspace _incomingEndpointPromise](void)
{
    if (!self) {
        return nil;
    }
    id _dispatcher = [self->_synchronizer _dispatcher];
    id domain = [_dispatcher domain];
    return [domain endpointPromise];
}


void -[FBWorkspace host:didReceiveActions:forExtension:](long a1, id a2, long a3)
{
    id v1 = [self _sceneForHost:a1];
    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
    [_workspaceQueue performAsync:^void(void) {
        [v1 workspace:self sendActions:a2 toExtension:a3];
    }];
}


void -[FBWorkspace host:didInvalidateWithTransitionContext:completion:](id a1, id a2, void (^a3)(bool, NSError *))
{
    void (^v4)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
        if (!a3) {
            return;
        } else {
            a3(arg1, arg2);
            return;
        }
    };
    id v5 = [self _unregisterSceneForHost:a1];
    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
    [_workspaceQueue performAsync:^void(void) {
        if (!v5) {
            NSDictionary *v10 = @{NSLocalizedFailureReasonErrorKey: @"Scene client is invalid."};
            NSError *v12 = [NSError errorWithDomain:@"FBWorkspace" code:1 userInfo:v10];
            v4(NO, v12);
        } else {
            void (^v8)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                v4();
                [v5 invalidate];
            };
            [v5 workspace:self sendInvalidationWithTransitionContext:a2 completion:v8];
            [self _resolveSceneLifecycleStateAndInterruptionPolicy];
        }
    }];
}


id -[FBWorkspace _unregisterSceneForHost:](id a1)
{
    id definition = [a1 definition];
    id identity = [definition identity];
    Class v3 = NSClassFromString(@"FBSSceneIdentity");
    if (!identity) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBWorkspace.m", 266, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    if (![identity isKindOfClass:v3]) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBWorkspace.m", 266, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    id v4 = [self->_lock_identityToSceneMap objectForKey:identity];
    bool v10 = !v4;
    if (!v10) {
        id host = [v4 host];
        v10 = host != a1;
    }
    if (v10) {
        v4 = nil;
    } else {
        FBProcess *v6 = self->_weak_process;
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [v6 logProem];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Unregistering scene: %{public}@", logProem, v4);
        }
        [self->_lock_identityToSceneMap removeObjectForKey:identity];
    }
    os_unfair_lock_unlock(&self->_lock);
    return v4;
}


void -[FBWorkspace sceneID:invalidateWithContext:clientError:](id a1, id a2, id a3)
{
    id v3 = [self _sceneForIdentity:a1];
    if (!v3) {
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Unable to invalidate because no scene exists with this identity.", a1);
        }
    } else {
        [a2 setError:a3];
        id host = [v3 host];
        [host clientToken:v3 deactivateWithContext:a2];
    }
}


void -[FBWorkspace _noteProcessDidInvalidate:](id a1)
{
    id v0 = a1;
    if (self != nil) {
        FBProcess *v1 = self->_weak_process;
        if (v0 != v1) {
            NSString *v35 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process == _weak_process"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v36 = NSStringFromSelector(@selector(_noteProcessDidInvalidate:));
                NSString *v37 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v36, v37, self, @"FBWorkspace.m", 677, v35);
            }
            _bs_set_crash_log_message([v35 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){0}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
            os_unfair_lock_unlock(&self->_lock);
            return;
        }
        for (id v5 in self->_lock_pendedRequests) {
            id v11 = FBSWorkspaceErrorCreate(0, 2, @"the process has invalidated");
            [v5 invalidateWithError:v11];
        }
        self->_lock_pendedRequests = nil;
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id logProem = [v0 logProem];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Invalidating workspace.", logProem);
        }
        NSArray *allValues = [self->_lock_identityToSceneMap allValues];
        [self->_lock_identityToSceneMap removeAllObjects];
        [self->_lock_identityToRemnantsMap enumerateKeysAndObjectsUsingBlock:^void(FBSSceneIdentity *arg1, id arg2, bool *arg3) {
            if ([arg2 isKindOfClass:[FBSceneRemnant class]]) {
                BSSimpleAssertion *_assertion = [arg2 _assertion];
                [_assertion invalidate];
            }
        }];
        [self->_lock_identityToRemnantsMap removeAllObjects];
        [self->_lock_eventDispatcherSource invalidate];
        self->_lock_eventDispatcherSource = nil;
        id v17 = [self->_lock_incomingConnection workspaceLock_invalidate];
        FBWorkspaceOutgoingConnection *v18 = self->_lock_outgoingConnection;
        if (self->_lock_outgoingConnection != nil) {
            NSArray *workspaceLock_invalidate = [v18 workspaceLock_invalidate];
            if (workspaceLock_invalidate) {
                if (!v17) {
                    v17 = workspaceLock_invalidate;
                } else {
                    [v17 addObjectsFromArray:workspaceLock_invalidate];
                }
            }
        }
        self->_lock_incomingConnection = nil;
        self->_lock_outgoingConnection = nil;
        [self->_workspaceServiceInjector invalidate];
        self->_workspaceServiceInjector = nil;
        [self->_lock_connectAssertion invalidate];
        self->_lock_connectAssertion = nil;
        [self->_lock_lifeAssertion invalidate];
        self->_lock_lifeAssertion = nil;
        [self->_lock_afterlifeAssertion invalidate];
        self->_lock_afterlifeAssertion = nil;
        if ([allValues count] != 0) {
            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
            dispatch_async(queue, ^void(void) {
                for (id v7 in allValues) {
                    id host = [v7 host];
                    FBProcessExitContext *exitContext = [v0 exitContext];
                    id createError = [exitContext createError];
                    NSError *v40 = FBSceneErrorCreate(4, @"Client process exited.", createError);
                    [host clientToken:v7 didInvalidateWithError:v40];
                }
            });
        }
        os_unfair_lock_unlock(&self->_lock);
        [self->_compoundAssertion invalidate];
        for (id v9 in allValues) {
            [v9 invalidate];
        }
        if ([v17 count] != 0) {
            id _workspaceQueue = [self->_synchronizer _workspaceQueue];
            [_workspaceQueue performAsync:^void(void) {
                for (id v6 in v17) {
                    v6->field_16(v6, 0);
                }
            }];
        }
    }
}


void -[FBWorkspace dealloc](void)
{
    if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"isInvalidated == YES"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspace.m", 135, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


void -[FBWorkspace .cxx_destruct](void)
{
    self->_lock_afterlifeAssertion = nil;
    self->_lock_connectAssertion = nil;
    self->_lock_lifeAssertion = nil;
    self->_compoundAssertion = nil;
    self->_lock_identityToSceneMap = nil;
    self->_lock_outgoingConnection = nil;
    self->_lock_outgoingEndpointPromise = nil;
    self->_workspaceServiceInjector = nil;
    self->_lock_pendedRequests = nil;
    self->_lock_identityToRemnantsMap = nil;
    self->_lock_eventDispatcherSource = nil;
    self->_lock_incomingConnection = nil;
    self->_synchronizer = nil;
    self->_weak_process = nil;
    self->_weak_delegate = nil;
}


FBSceneSynchronizer *-[FBWorkspace synchronizer](void)
{
    return self->_synchronizer;
}


long -[FBWorkspace unregisterHost:](id a1)
{
    return [self host:a1 didInvalidateWithTransitionContext:nil completion:nil];
}


void -[FBWorkspace setDelegate:](id<FBWorkspaceDelegate> a1)
{
    os_unfair_lock_lock(&self->_lock);
    self->_weak_delegate = a1;
    os_unfair_lock_unlock(&self->_lock);
}


id<FBWorkspaceDelegate> -[FBWorkspace delegate](void)
{
    os_unfair_lock_lock(&self->_lock);
    id<FBWorkspaceDelegate> v0 = self->_weak_delegate;
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


BSAuditToken *-[FBWorkspace auditToken](void)
{
    FBProcess *v0 = self->_weak_process;
    return [v0 auditToken];
}


void -[FBWorkspace _terminateWithReason:](id a1)
{
    os_unfair_lock_assert_not_owner(&self->_lock);
    FBProcess *v1 = self->_weak_process;
    if (v1 != nil) {
        id v2 = [FBSProcessTerminationRequest requestForProcess:v1 withLabel:@"FBWorkspace misbehaving process"];
        [v2 setReportType:1];
        [v2 setExceptionCode:0x4badca11];
        [v2 setExplanation:a1];
        [v2 execute];
    }
}


void -[FBWorkspace _processCallOutQueue_requestScene:](id a1)
{
    id v0 = a1;
    id<FBWorkspaceDelegate> delegate = [self delegate];
    if (!delegate) {
        id v2 = FBSWorkspaceErrorCreate(delegate, 2, @"the host has not configured a workspace delegate for this process");
        [v0 invalidateWithError:v2];
    } else {
        id options = [v0 options];
        [delegate workspace:self didReceiveSceneRequestWithOptions:options completion:^void(FBScene *arg1, NSError *arg2) {
            if (arg1 != 0) {
                [v0 respondWithScene:arg1];
                return;
            }
            id v5 = FBSWorkspaceErrorCreate(arg2, 2, @"the host declined to create a scene");
            [v0 invalidateWithError:v5];
        }];
    }
}


void -[FBWorkspace _terminateGracefully:withTransitionContext:](id a1, id a2)
{
    id v1 = a2;
    if (self != nil) {
        FBProcess *v2 = self->_weak_process;
        if (a1 != v2) {
            NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process == _weak_process"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(_terminateGracefully:withTransitionContext:));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspace.m", 764, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        os_unfair_lock_assert_owner(&self->_lock);
        if (!__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
            [self->_lock_incomingConnection workspaceLock_enqueueConnectBlock:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                [arg1 willTerminateWithTransitionContext:v1];
            }];
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBWorkspace _queue_unverifiedOutgoingConnection:didError:](id a1, id a2, long a3, long a4, long a5, long a6, long a7, long a8, long a9, long a10, long a11, long a12)
{
    uint8_t v0[32];
    uint8_t v1[32];
    *(uint64_t *)&v0[0] = a12;
    *(uint64_t *)&v0[8] = a11;
    *(uint64_t *)&v0[16] = a10;
    (*(uint64_t *)&v0[24])[0] = a9;
    (*(uint64_t *)&v0[24])[1] = a8;
    (*(uint64_t *)&v0[24])[2] = a7;
    (*(uint64_t *)&v0[24])[3] = a6;
    (*(uint64_t *)&v0[24])[4] = a5;
    *(uint64_t *)&v1[0] = a4;
    *(uint64_t *)&v1[8] = a3;
    *(uint64_t *)&v1[16] = &*(uint64_t *)&v1[16];
    (*(uint64_t *)&v1[24])[0] = __builtin_return_address(0);
    id v3 = a2;
    if (self != nil) {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *array2 = [NSMutableArray array];
        os_unfair_lock_lock(&self->_lock);
        os_unfair_lock_assert_owner(&self->_lock);
        if (__atomic_compare_exchange_n(&(self->_invalidated), &(int){1}, 1, false, __ATOMIC_RELAXED, __ATOMIC_RELAXED)) {
            os_unfair_lock_unlock(&self->_lock);
        } else {
            if (self->_lock_outgoingConnection != a1) {
                NSString *v24 = [NSString stringWithFormat:@"unverified outgoingConnection is unknown : expected=%@ actual=%@", self->_lock_outgoingConnection, a1];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v25 = NSStringFromSelector(@selector(_queue_unverifiedOutgoingConnection:didError:));
                    NSString *v26 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBWorkspace.m", 814, v24);
                }
                _bs_set_crash_log_message([v24 UTF8String]);
                __break(0);
            }
            NSMutableArray *v10 = array2;
            [self->_lock_identityToSceneMap enumerateKeysAndObjectsUsingBlock:^void(FBSSceneIdentity *arg1, FBWorkspaceScene *arg2, bool *arg3) {
                if ([arg2 usesOutgoingConnection]) {
                    [array addObject:arg1];
                    [array2 addObject:arg2];
                }
            }];
            [self->_lock_identityToSceneMap removeObjectsForKeys:array];
            id workspaceLock_invalidate = [a1 workspaceLock_invalidate];
            self->_lock_outgoingConnection = nil;
            if ([v10 count] != 0) {
                NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
                dispatch_async(queue, ^void(void) {
                    for (id v30 in v10) {
                        id host = [v30 host];
                        [host clientToken:v30 didInvalidateWithError:v3];
                    }
                });
            }
            os_unfair_lock_unlock(&self->_lock);
            for (id v6 in v10) {
                [v6 invalidate];
            }
            for (id v23 in workspaceLock_invalidate) {
                v23->field_16(v23, 0);
            }
        }
    }
}


void -[FBWorkspace host:sendInvocation:withReply:](long a1, id a2, void (^a3)(long, NSError *))
{
    id v2 = [self _sceneForHost:a1];
    id _workspaceQueue = [self->_synchronizer _workspaceQueue];
    [_workspaceQueue performAsync:^void(void) {
        if (!v2) {
            NSDictionary *v5 = @{NSLocalizedFailureReasonErrorKey: @"Scene client is invalid."};
            NSError *v6 = [NSError errorWithDomain:@"FBWorkspace" code:1 userInfo:v5];
            a3(0, v6);
            return;
        }
        [v2 workspace:self sendInvocation:a2 withReply:a3];
    }];
}


void -[FBWorkspace workspaceID:sendActions:completion:](id a1, id a2, void (^a3)(NSError *))
{
    id v11;
    void (^v2)(NSError *) = a3;
    if ([a2 count]) {
        FBProcess *v3 = self->_weak_process;
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [v3 logProem];
            id fbs_singleLineDescriptionOfBSActions = [a2 fbs_singleLineDescriptionOfBSActions];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Received action(s) for workspace %{public}@: %{public}@", logProem, (!a1) ? @"(default)" : a1, fbs_singleLineDescriptionOfBSActions);
        }
        if (!a1) {
            id _dispatcher = [self->_synchronizer _dispatcher];
            id domain = [_dispatcher domain];
            v11 = [domain defaultWorkspace];
        } else {
            v11 = a1;
        }
        [self _handleSceneRequest:[[FBWorkspaceSceneRequest alloc] initWithTargetIdentifier:v11 actions:a2 completion:^void(FBScene *arg1, NSError *arg2) {
            if (!v2) {
                return;
            } else {
                v2(arg2);
                return;
            }
        }]];
    } else if (v2 != nil) {
        v2(nil);
    }
}


void -[FBWorkspace createSceneWithOptions:completion:](id a1, void (^a2)(NSError *))
{
    NSError *v3;
    Class v5;
    Class v6;
    id v11;
    void (^v1)(NSError *) = a2;
    id currentWorkspaceConnection = [FBWorkspaceConnection currentWorkspaceConnection];
    if (currentWorkspaceConnection) {
        v5 = [currentWorkspaceConnection class];
        v6 = [FBWorkspaceOutgoingConnection class];
        if (v5 == v6) {
            if (v1 != nil) {
                v3 = FBSWorkspaceErrorCreate(0, 2, @"createScene is not yet supported on directEndpoint connections");
            }
        } else {
            NSString *workspaceIdentifier = [a1 workspaceIdentifier];
            if (!workspaceIdentifier) {
                id _dispatcher = [self->_synchronizer _dispatcher];
                id domain = [_dispatcher domain];
                v11 = [domain defaultWorkspace];
            } else {
                v11 = workspaceIdentifier;
            }
            RBSProcessHandle *processHandle = [self->_synchronizer processHandle];
            id identity = [processHandle identity];
            id v14 = [FBSSceneClientIdentity identityForInjectedEndpointToProcessIdentity:identity];
            [self _handleSceneRequest:[[FBWorkspaceSceneRequest alloc] initWithClientIdentity:v14 targetIdentifier:v11 options:a1 completion:^void(FBScene *arg1, NSError *arg2) {
                if (!v1) {
                    return;
                } else {
                    v1(arg2);
                    return;
                }
            }]];
        }
    } else if (v1 != nil) {
        v3 = FBSWorkspaceErrorCreate(0, 2, @"failed to identify the connection");
    }
    if ((!currentWorkspaceConnection && v1 != nil) || (currentWorkspaceConnection && v5 == v6 && v1 != nil)) {
        v1(v3);
    }
}


void -[FBWorkspace sceneID:handleInvocation:completion:](id a1, id a2, id a3)
{
    id v3 = [self _sceneForIdentity:a1];
    if (!v3) {
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Unable to deliver invocation because no scene exists with this identity.", a1);
        }
    } else {
        id currentWorkspaceConnection = [FBWorkspaceConnection currentWorkspaceConnection];
        [v3 workspace:self handleInvocation:a2 fromConnection:currentWorkspaceConnection withReply:a3];
    }
}


void -[FBWorkspace sceneID:sendMessage:withResponse:](id a1, long a2, void (^a3)(long, long))
{
    os_log_t oslog = FBLogProcessScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Ignoring scene message since this functionality is no longer supported.", a1);
    }
    if (a3 != nil) {
        a3(0, 0);
    }
}


void -[FBWorkspace assertion:didInvalidateWithError:](id a1, id a2)
{
    os_unfair_lock_lock(&self->_lock);
    FBProcess *v2 = self->_weak_process;
    RBSAssertion *v3 = self->_lock_lifeAssertion;
    RBSAssertion *v4 = self->_lock_connectAssertion;
    os_unfair_lock_unlock(&self->_lock);
    if (a1 == v4) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem2 = [v2 logProem];
            id succinctDescription2 = [a2 succinctDescription];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Launch assertion invalidated: %{public}@", logProem2, succinctDescription2);
        }
        [self _dropLaunchAssertion];
    } else if (a1 == v3) {
        os_log_t oslog2 = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [v2 logProem];
            id succinctDescription = [a2 succinctDescription];
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace assertion invalidated: %{public}@", logProem, succinctDescription);
        }
    }
}


void -[FBWorkspace assertionWillInvalidate:](id a1)
{
    os_log_t v5;
    id logProem;
    os_unfair_lock_lock(&self->_lock);
    FBProcess *v1 = self->_weak_process;
    RBSAssertion *v2 = self->_lock_lifeAssertion;
    RBSAssertion *v3 = self->_lock_connectAssertion;
    os_unfair_lock_unlock(&self->_lock);
    long continuationRoute1 = 0;
    if (a1 == v3) {
        v5 = FBLogProcessWorkspace();
        if (!os_log_type_enabled(v5, OS_LOG_TYPE_DEFAULT)) {
            return;
        }
        continuationRoute1 = 1;
    } else if (a1 != v2) {
        return;
    }
    if (!continuationRoute1) {
        v5 = FBLogProcessWorkspace();
        if (os_log_type_enabled(v5, OS_LOG_TYPE_DEFAULT)) {
            logProem = [v1 logProem];
            os_log_with_type(v5, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace assertion will expire.", logProem);
            continuationRoute1 = 2;
        }
    }
    if (continuationRoute1 == 1) {
        logProem = [v1 logProem];
        os_log_with_type(v5, OS_LOG_TYPE_DEFAULT, "%{public}@ Launch assertion will expire.", logProem);
    }
}


void -[FBWorkspace setSynchronizer:](FBSceneSynchronizer *a1)
{
    self->_synchronizer = a1;
}


void -[FBWorkspace init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBWorkspace"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspace.m", 87, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
