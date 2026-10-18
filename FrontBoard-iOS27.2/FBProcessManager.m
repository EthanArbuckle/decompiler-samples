struct FBProcessManager {
    FBWorkspaceEventDispatcher *_eventDispatcher; // +0x8
    FBSceneManager *_lock_legacySceneManager; // +0x10
    FBProcess *_currentProcess; // +0x18
    FBLocalSynchronousSceneClientProvider *_lock_syncLocalSceneClientProvider; // +0x20
    NSObject<OS_dispatch_queue> *_bootstrapQueue; // +0x28
    NSObject<OS_dispatch_queue> *_callOutQueue; // +0x30
    RBSProcessMonitor *_processMonitor; // +0x38
    id<BSInvalidatable> _stateCaptureAssertion; // +0x40
    struct os_unfair_lock_s _bootstrapLock; // +0x48
    struct os_unfair_lock_s _bootstrapPredicatesLock; // +0x4c
    NSMutableSet *_bootstrap_pendingProcesses; // +0x50
    NSMutableSet *_bootstrap_bootstrappingProcesses; // +0x58
    NSMutableSet *_bootstrap_processPredicates; // +0x60
    id<FBProcessWatchdogProviding> _noDirectAccess_defaultWatchdogPolicy; // +0x68
    struct os_unfair_lock_s _lock; // +0x70
    NSMutableDictionary *_lock_processesByPID; // +0x78
    NSMutableDictionary *_lock_processesByVersionedPID; // +0x80
    NSMutableDictionary *_lock_processesByIdentity; // +0x88
    NSHashTable *_lock_observers; // +0x90
    RBSAssertion *_lock_assertion; // +0x98
    bool _lock_initializationComplete; // +0xa0
    bool _lock_invalidated; // +0xa1
    bool _bootstrapLock_invalidated; // +0xa2
};

id -[FBProcessManager _bootstrapProcessWithExecutionContext:synchronously:error:](id a1, long a2, id *a3)
{
    id v7;
    id v8;
    os_log_t v27;
    if (!a1) {
        NSString *v30 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"executionContext != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v31 = NSStringFromSelector(_cmd);
            NSString *v32 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBProcessManager.m", 670, v30);
        }
        _bs_set_crash_log_message([v30 UTF8String]);
        __break(0);
    }
    id v3 = [a1 copy];
    void (^completion)(FBProcess *, id) = [v3 completion];
    [v3 setCompletion:nil];
    id identity2 = [v3 identity];
    if (!identity2 || ![identity2 supportsLaunchingDirectly]) {
        v7 = [NSError bs_errorWithDomain:@"FBProcessManager" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
            [arg1 setFailureDescription:@"Ignoring execution context."];
            [arg1 setFailureReason:@"RunningBoard does not support directly launching %@", identity2];
            [arg1 setCodeDescription:@"not-supported"];
        }];
        v8 = nil;
    } else {
        os_unfair_lock_lock(&self->_bootstrapLock);
        os_log_t oslog2 = FBLogProcess();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Asked to bootstrap a new process with identity: %{public}@", identity2);
        }
        v8 = [self processForIdentity:identity2];
        if (!v8) {
            for (id v19 in self->_bootstrap_pendingProcesses) {
                id identity = [v19 identity];
                if ([identity isEqual:identity2]) {
                    v8 = v19;
                    if (!v8) {
                        goto blk_1c4ed3dc4;
                    }
                    v7 = [NSError bs_errorWithDomain:@"FBProcessManager" code:2 configuration:^void(id<BSErrorConfiguring> arg1) {
                        [arg1 setFailureDescription:@"Ignoring execution context."];
                        [arg1 setFailureReason:@"A pending process for %@ already exists.", identity2];
                        [arg1 setCodeDescription:@"already-exists"];
                    }];
                    goto blk_1c4ed3e9c;
                }
            }
blk_1c4ed3dc4:
            if (self->_bootstrapLock_invalidated) {
                v7 = [NSError bs_errorWithDomain:@"FBProcessManager" code:3 configuration:^void(id<BSErrorConfiguring> arg1) {
                    [arg1 setFailureDescription:@"Ignoring execution context."];
                    [arg1 setFailureReason:@"ProcessManager has been invalidated."];
                    [arg1 setCodeDescription:@"invalidated"];
                }];
                goto blk_1c4ed3eb0;
            }
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Creating process (sync=%{bool}u) with identity: %{public}@", a2, identity2);
            }
            Class fb_processClass = [identity2 fb_processClass];
            v8 = [[fb_processClass alloc] _initWithProcessManager:self identity:identity2 handle:0 executionContext:v3];
            [self->_bootstrap_pendingProcesses addObject:v8];
            v7 = nil;
            if (!v8) {
blk_1c4ed3eb0:
                os_unfair_lock_unlock(&self->_bootstrapLock);
                v8 = nil;
            } else {
blk_1c4ed3e9c:
                [self _bootstrap_consumeLock_addProcess:v8 synchronously:a2];
            }
        } else {
            v7 = [NSError bs_errorWithDomain:@"FBProcessManager" code:2 configuration:^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureDescription:@"Ignoring execution context."];
                [arg1 setFailureReason:@"A process for %@ already exists.", identity2];
                [arg1 setCodeDescription:@"already-exists"];
            }];
            os_unfair_lock_unlock(&self->_bootstrapLock);
        }
    }
    if (completion != nil && v8 != nil) {
        [v8 _executeBlockAfterBootstrap:^void(FBProcess *arg1, NSError *arg2) {
            id v39 = v7;
            if (!v39) {
                v39 = arg2;
            }
            completion(arg1, v39);
        }];
    }
    if (completion != nil && !v8) {
        NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
        dispatch_async(queue, ^void(void) {
            completion(nil, v7);
        });
        if (!v7) {
            goto blk_1c4ed3c04;
        }
        goto blk_1c4ed3be8;
    }
    if (v7 != nil) {
        if (v8 != nil) {
            v27 = FBLogProcess();
            if (os_log_type_enabled(v27, OS_LOG_TYPE_DEFAULT)) {
                NSString *localizedFailureReason2 = [v7 localizedFailureReason];
                os_log_with_type(v27, OS_LOG_TYPE_DEFAULT, "Did not create a new process: %{public}@", localizedFailureReason2);
                goto blk_1c4ed3c04;
            }
        }
blk_1c4ed3be8:
        v27 = FBLogProcess();
        if (os_log_type_enabled(v27, OS_LOG_TYPE_ERROR)) {
            NSString *localizedFailureReason = [v7 localizedFailureReason];
            os_log_with_type(v27, OS_LOG_TYPE_ERROR, "Failed to create a new process: %{public}@", localizedFailureReason);
        }
    }
blk_1c4ed3c04:
    if (a3 != 0) {
        *(a3) = v7;
    }
    os_unfair_lock_assert_not_owner(&self->_bootstrapLock);
    return v8;
}


NSXPCListenerEndpoint *-[FBProcessManager incomingWorkspaceEndpoint](void)
{
    id domain = [self->_eventDispatcher domain];
    id endpointPromise = [domain endpointPromise];
    return [endpointPromise endpoint];
}


long +[FBProcessManager sharedInstance](void)
{
    return [FBProcessManager _sharedInstanceCreateIfNeeded:1];
}


void -[FBProcessManager noteProcessAssertionStateDidChange:](long a1)
{
    RBSAssertion *v25;
    id domain = [self->_eventDispatcher domain];
    long selfAssertRuntime = [domain selfAssertRuntime];
    if (selfAssertRuntime != 0) {
        int v2 = &FBWorkspaceStateNone;
        id allProcesses = [self allProcesses];
        for (FBProcess *v11 in allProcesses) {
            struct /* anonymous */ workspaceState2 = [v11 workspaceState];
            v2 = FBWorkspaceStateCombine(v2, workspaceState2);
        }
        os_unfair_lock_lock(&self->_bootstrapLock);
        for (FBProcess *v20 in self->_bootstrap_pendingProcesses) {
            struct /* anonymous */ workspaceState = [v20 workspaceState];
            v2 = FBWorkspaceStateCombine(v2, workspaceState);
        }
        os_unfair_lock_unlock(&self->_bootstrapLock);
        int v17 = v2;
        id domain2 = [self->_eventDispatcher domain];
        id v19 = [domain2 selfAssertionAttributesForWorkspaceState:&v17];
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_invalidated != 1) {
            int fb_workspaceState = [self->_lock_assertion fb_workspaceState];
            if ((FBWorkspaceStateEqual(v17, fb_workspaceState) & 1) == 0) {
                os_log_t oslog = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    NSString *v23 = NSStringFromFBWorkspaceState(v17);
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Updating self-assertion for unified workspace priority: %{public}@", v23);
                }
                v25 = self->_lock_assertion;
                self->_lock_assertion = nil;
                if (!v19) {
blk_1c4ee1250:
                    os_unfair_lock_unlock(&self->_lock);
                } else {
                    RBSAssertion *v27 = [[RBSAssertion alloc] initWithExplanation:@"FBWorkspace Self-Assert" target:[RBSTarget currentProcess] attributes:v19];
                    self->_lock_assertion = v27;
                    [self->_lock_assertion fb_setWorkspaceState:v17];
                    [self->_lock_assertion setInvalidationHandler:^void(RBSAssertion *arg1, NSError *arg2) {
                        os_log_t oslog = FBLogProcessWorkspace();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                            id v10 = [arg2 descriptionWithMultilinePrefix:0];
                            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Self-assertion invalidated: %{public}@", v10);
                        }
                        os_unfair_lock_lock(&self->_lock);
                        if (arg1 == self->_lock_assertion) {
                            [self->_lock_assertion invalidate];
                            self->_lock_assertion = nil;
                            os_unfair_lock_unlock(&self->_lock);
                            dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
                            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
                            dispatch_after(when, queue, ^void(void) {
                                [self noteProcessAssertionStateDidChange:0];
                            });
                        } else {
                            os_unfair_lock_unlock(&self->_lock);
                        }
                    }];
                    os_unfair_lock_unlock(&self->_lock);
                    if (v27 != nil) {
                        id v33 = nil;
                        long v34 = [v27 acquireWithError:&v33];
                        if ((v34 & 1) == 0) {
                            os_log_t oslog2 = FBLogProcessWorkspace();
                            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                                id v37 = [v33 descriptionWithMultilinePrefix:0];
                                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Self-assertion acquisition failed: %{public}@", v37);
                            }
                        }
                    }
                }
                if (v25 != nil) {
                    [v25 invalidate];
                }
                return;
            }
        } else if (self->_lock_assertion != nil) {
            NSString *v39 = [NSString stringWithFormat:@"must not have an assertion if we're invalidated"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v40 = NSStringFromSelector(_cmd);
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v3, self, @"FBProcessManager.m", 580, v39);
            }
            _bs_set_crash_log_message([v39 UTF8String]);
            __break(0);
        }
        v25 = nil;
        goto blk_1c4ee1250;
    }
}


FBSceneManager *-[FBProcessManager legacySceneManagerCreatingIfNecessary:](int a1)
{
    os_unfair_lock_lock(&self->_lock);
    FBSceneManager *v0 = self->_lock_legacySceneManager;
    os_unfair_lock_unlock(&self->_lock);
    if (a1 != 0 && !v0) {
        BSDispatchQueueAssertMain();
        os_unfair_lock_lock(&self->_lock);
        if (!self->_lock_legacySceneManager) {
            FBSceneManager *v2 = [[FBSceneManager alloc] _initWithProcessManager:self];
            self->_lock_legacySceneManager = v2;
            v0 = v2;
            if (self->_lock_invalidated == 1) {
                [v0 _invalidate];
            }
        } else {
            v0 = self->_lock_legacySceneManager;
        }
        os_unfair_lock_unlock(&self->_lock);
    }
    return v0;
}


id -[FBProcessManager _bootstrapProcessWithHandle:synchronously:error:](id a1, long a2, NSError **a3)
{
    id v5;
    NSError *v10;
    long v23;
    long v1;
    id v0 = a1;
    if (!a1) {
        NSString *v39 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"processHandle != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v40 = NSStringFromSelector(_cmd);
            NSString *v41 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v41, self, @"FBProcessManager.m", 769, v39);
        }
        _bs_set_crash_log_message([v39 UTF8String]);
        __break(0);
    }
    [v0 auditToken:&v1];
    long v2 = BSVersionedPIDForAuditToken(&v1);
    if (v2 != -1) {
        os_unfair_lock_lock(&self->_bootstrapLock);
        os_log_t oslog3 = FBLogProcess();
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Asked to bootstrap a new process for handle: %{public}@", v0);
        }
        v5 = [self processForVersionedPID:v2];
        if (!v5) {
            id identity = [v0 identity];
            if (!identity) {
                NSString *v42 = [NSString stringWithFormat:@"RunningBoard returned no identity for a processHandle : %@", v0];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v43 = NSStringFromSelector(_cmd);
                    NSString *v44 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v43, v44, self, @"FBProcessManager.m", 788, v42);
                }
                _bs_set_crash_log_message([v42 UTF8String]);
                __break(0);
            }
            v5 = nil;
            for (FBProcess *v26 in self->_bootstrap_pendingProcesses) {
                long versionedPID = [v26 versionedPID];
                if (v2 == versionedPID) {
                    v5 = v26;
                    break;
                }
                if (versionedPID == -1) {
                    RBSProcessIdentity *identity2 = [v26 identity];
                    if ([identity isEqual:identity2]) {
                        v5 = v26;
                        break;
                    }
                }
            }
            if (!v5) {
                if (!self->_bootstrapLock_invalidated) {
                    os_log_t oslog2 = FBLogProcess();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Creating process (sync=%{bool}u) for handle: %{public}@", a2, v0);
                    }
                    Class fb_processClass = [identity fb_processClass];
                    v5 = [[fb_processClass alloc] _initWithProcessManager:self identity:identity handle:v0 executionContext:0];
                    [self->_bootstrap_pendingProcesses addObject:v5];
                    v10 = nil;
                    v23 = 0;
                    if (v5 != nil) {
                        goto blk_1c4ee9224;
                    }
                } else {
                    v23 = [NSError bs_errorWithDomain:@"FBProcessManager" code:3 configuration:^void(id<BSErrorConfiguring> arg1) {
                        [arg1 setFailureDescription:@"Ignoring execution context."];
                        [arg1 setFailureReason:@"ProcessManager has been invalidated."];
                        [arg1 setCodeDescription:@"invalidated"];
                    }];
                }
                os_unfair_lock_unlock(&self->_bootstrapLock);
                v5 = nil;
                v10 = v23;
            } else {
                os_log_t oslog4 = FBLogProcess();
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "A pending process already exists for this handle: %{public}@", v5);
                }
                NSDictionary *v33 = @{NSLocalizedFailureReasonErrorKey: @"A pending process already exists for this handle."};
                v10 = [NSError errorWithDomain:@"FBProcessManager" code:2 userInfo:v33];
blk_1c4ee9224:
                [self _bootstrap_consumeLock_addProcess:v5 synchronously:a2];
                if (a2 != 0) {
                    long versionedPID2 = [v5 versionedPID];
                    if (v2 != versionedPID2) {
                        os_log_t oslog5 = FBLogProcess();
                        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
                            id v36 = NSStringFromBSVersionedPID(v2);
                            os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "resolved process does not match handle %{public}@: %{public}@", v36, v5);
                        }
                        id v37 = nil;
                        v0 = [self _bootstrapProcessWithHandle:v0 synchronously:1 error:&v37];
                        long v38 = v37;
                        v10 = v38;
                        v5 = v0;
                    }
                }
            }
            if (a3 != 0) {
                goto blk_1c4ee8e98;
            } else {
                goto blk_1c4ee8ea4;
            }
        }
        os_log_t oslog6 = FBLogProcess();
        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "A process already exists for this handle: %{public}@", v5);
        }
        NSDictionary *v9 = @{NSLocalizedFailureReasonErrorKey: @"A process already exists for this handle."};
        v10 = [NSError errorWithDomain:@"FBProcessManager" code:2 userInfo:v9];
        os_unfair_lock_unlock(&self->_bootstrapLock);
        if (a3 != 0) {
blk_1c4ee8e98:
            *(a3) = v10;
        }
blk_1c4ee8ea4:
        os_unfair_lock_assert_not_owner(&self->_bootstrapLock);
    } else {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Not registering process %{public}@ with an invalid audit token.", v0);
        }
        if (!a3) {
            v5 = nil;
        } else {
            NSDictionary *v14 = @{NSLocalizedFailureReasonErrorKey: @"Specified process is not valid."};
            NSError *v15 = [NSError errorWithDomain:@"FBProcessManager" code:1 userInfo:v14];
            v5 = nil;
            *(a3) = v15;
        }
    }
    return v5;
}


void -[FBProcessManager domain:didReceiveConnection:](long a1, id a2)
{
    uint8_t v2[32];
    id remoteToken = [a2 remoteToken];
    if (!remoteToken) {
        _memset(v2, 0, 32);
    } else {
        [remoteToken realToken:&v2];
    }
    id v3 = [self registerProcessForAuditToken:&v2];
    if (!v3) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: Unable to assign new incoming connection to a process because a process was unable to be found or created for connection=%@ with remoteToken=%@", a2, remoteToken);
        }
        [a2 invalidate];
    } else {
        FBWorkspace *workspace = [v3 workspace];
        os_log_t oslog2 = FBLogProcessWorkspace();
        if (!workspace) {
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "FBWorkspaceDomain: Unable to assign new incoming connection to a process because its server was unable to be found for process=%@", v3);
            }
            [a2 invalidate];
        } else {
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                FBWorkspace *workspace2 = [v3 workspace];
                os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "FBWorkspaceDomain: Assigning new workspace connection to workspace (%p) owned by process: %{public}@", workspace2, v3);
            }
            [workspace _consumeIncomingConnection:a2];
        }
    }
}


void -[FBProcessManager _notifyObserversUsingBlock:completion:](void (^a1)(id<FBProcessManagerObserver>), void (^a2)(void))
{
    dispatch_async(self->_callOutQueue, ^void(void) {
        os_unfair_lock_lock(&self->_lock);
        id v0 = [self->_lock_observers copy];
        os_unfair_lock_unlock(&self->_lock);
        for (id<FBProcessManagerObserver> v8 in v0) {
            a1(v8);
        }
        if (a2 != nil) {
            a2();
        }
    });
}


void -[FBProcessManager launchProcessWithContext:](id a1)
{
    if (![a1 identity]) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[context identity] != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBProcessManager.m", 467, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    id v2 = [a1 copy];
    dispatch_block_t block = BSDispatchBlockCreateWithCurrentQualityOfService(0, ^void(void) {
        [self _createProcessWithExecutionContext:v2 error:0];
    });
    dispatch_async(self->_bootstrapQueue, block);
}


void -[FBProcessManager _bootstrap_consumeLock_addProcess:](id a1)
{
    id v0 = a1;
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcessManager.m", 874, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_unfair_lock_assert_owner(&self->_bootstrapLock);
    if (![self->_bootstrap_bootstrappingProcesses containsObject:v0]) {
        [v0 bootstrapLock:^void(id<FBProcessBootstrapping> arg1) {
            NSArray *v19;
            [self->_bootstrap_bootstrappingProcesses addObject:v0];
            os_unfair_lock_unlock(&self->_bootstrapLock);
            long v54 = [arg1 bootstrapWithDelegate:self];
            os_unfair_lock_lock(&self->_bootstrapLock);
            [self->_bootstrap_pendingProcesses removeObject:v0];
            [self->_bootstrap_bootstrappingProcesses removeObject:v0];
            if (!v54) {
                os_unfair_lock_unlock(&self->_bootstrapLock);
                return;
            }
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Adding: %{public}@", v0);
            }
            os_unfair_lock_lock(&self->_lock);
            id<NSCopying> identity5 = [v0 identity];
            id v7 = [self->_lock_processesByIdentity objectForKey:identity5];
            if (!v7) {
                NSMutableArray<id> *v8 = [NSMutableArray arrayWithObject:v0];
                [self->_lock_processesByIdentity setObject:v8 forKey:identity5];
            } else {
                [v7 addObject:v0];
            }
            int pid = [v0 pid];
            if (pid < 1) {
                goto blk_1c4ed65a0;
            }
            NSNumber *v47 = [NSNumber numberWithInt:pid];
            id v10 = [self->_lock_processesByPID objectForKey:v47];
            if (!v10) {
                [self->_lock_processesByPID setObject:v0 forKey:v47];
blk_1c4ed65a0:
                long versionedPID = [v0 versionedPID];
                if (versionedPID != -1) {
                    NSNumber *v12 = [NSNumber numberWithLongLong:versionedPID];
                    id v14 = [self->_lock_processesByVersionedPID objectForKey:v12];
                    if (v14 != nil) {
                        id identity3 = [v0 identity];
                        NSString *description3 = [identity3 description];
                        id v42 = NSStringFromBSVersionedPID([v0 versionedPID]);
                        id identity4 = [v14 identity];
                        NSString *description4 = [identity4 description];
                        id v45 = NSStringFromBSVersionedPID([v14 versionedPID]);
                        NSString *v46 = [NSString stringWithFormat:@"attempting to add a process with a vpid that is already tracked : new=<%p %@:%@> existing=<%p %@:%@>", v0, description3, v42, v14, description4, v45];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v52 = NSStringFromSelector(_cmd);
                            NSString *v53 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v52, v53, self, @"FBProcessManager.m", 930, v46);
                        }
                        _bs_set_crash_log_message([v46 UTF8String]);
                        __break(0);
                    }
                    [self->_lock_processesByVersionedPID setObject:v0 forKey:v12];
                }
                if (self->_bootstrapLock_invalidated == 0) {
                    id v16 = [self->_eventDispatcher domain];
                    if (([v16 monitorAllSuspendableProcesses] & 1) == 0) {
                        RBSProcessHandle *rbsHandle = [v0 rbsHandle];
                        long fb_canTaskSuspend = [rbsHandle fb_canTaskSuspend];
                        if (!fb_canTaskSuspend) {
                            goto blk_1c4ed65fc;
                        }
                        v16 = [v0 processPredicate];
                        if (!v16 || [self->_bootstrap_processPredicates containsObject:v16]) {
                            goto blk_1c4ed661c;
                        }
                        NSMutableSet *v27 = self->_bootstrap_processPredicates;
                        if (!self->_bootstrap_processPredicates) {
                            self->_bootstrap_processPredicates = [NSMutableSet setWithObject:v16];
                        } else {
                            [v27 addObject:v16];
                        }
                        v19 = [self->_bootstrap_processPredicates allObjects];
                    } else {
blk_1c4ed661c:
                        v19 = nil;
                    }
                } else {
blk_1c4ed65fc:
                    v19 = nil;
                }
                [self _notifyObserversUsingBlock:^void(id<FBProcessManagerObserver> arg1) {
                    [arg1 processManager:self didAddProcess:v0];
                } completion:^void(void) {
                    os_unfair_lock_lock(&self->_lock);
                    os_unfair_lock_unlock(&self->_lock);
                    if (self->_lock_initializationComplete != 1) {
                        return;
                    }
                    [v0 noteProcessPublished];
                }];
                os_unfair_lock_unlock(&self->_lock);
                if (!v19) {
                    os_unfair_lock_unlock(&self->_bootstrapLock);
                } else {
                    os_unfair_lock_lock(&self->_bootstrapPredicatesLock);
                    os_unfair_lock_unlock(&self->_bootstrapLock);
                    [self->_processMonitor updateConfiguration:^void(id<RBSProcessMonitorConfiguring> arg1) {
                        [arg1 setPredicates:v19];
                    }];
                    os_unfair_lock_unlock(&self->_bootstrapPredicatesLock);
                }
                return;
            }
            id identity = [v0 identity];
            NSString *description = [identity description];
            id v34 = NSStringFromBSVersionedPID([v0 versionedPID]);
            id identity2 = [v10 identity];
            NSString *description2 = [identity2 description];
            id v37 = NSStringFromBSVersionedPID([v10 versionedPID]);
            NSString *v38 = [NSString stringWithFormat:@"attempting to add a process with a pid that is already tracked : new=<%p %@:%@> existing=<%p %@:%@>", v0, description, v34, v10, description2, v37];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v49 = NSStringFromSelector(_cmd);
                NSString *v50 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBProcessManager.m", 920, v38);
            }
            _bs_set_crash_log_message([v38 UTF8String]);
            __break(0);
        }];
        os_unfair_lock_assert_not_owner(&self->_bootstrapLock);
    } else {
        os_unfair_lock_unlock(&self->_bootstrapLock);
        [v0 bootstrapLock:nil];
    }
}


long -[FBProcessManager _createProcessWithExecutionContext:error:](long a1, long a2)
{
    return [self _bootstrapProcessWithExecutionContext:a1 synchronously:1 error:a2];
}


FBWorkspaceEventDispatcher *-[FBProcessManager eventDispatcher](void)
{
    return self->_eventDispatcher;
}


void -[FBProcessManager noteProcessDidLaunch:](id a1)
{
    [a1 bootstrapLock:nil];
}


id -[FBProcessManager processForVersionedPID:](long a1)
{
    if (a1 == -1) {
        return nil;
    }
    os_unfair_lock_lock(&self->_lock);
    NSNumber *v1 = [NSNumber numberWithLongLong:a1];
    id v0 = [self->_lock_processesByVersionedPID objectForKey:v1];
    if (!v0) {
        NSNumber *v2 = [NSNumber numberWithInt:a1];
        v0 = [self->_lock_processesByPID objectForKey:v2];
        if (v0 != nil) {
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                id v4 = NSStringFromBSVersionedPID(a1);
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Returning %{public}@, even though it does not match provided vpid %{public}@", v0, v4);
            }
        }
    }
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


long -[FBProcessManager _createProcessFutureForProcessHandle:error:](long a1, long a2)
{
    return [self _bootstrapProcessWithHandle:a1 synchronously:0 error:a2];
}


id +[FBProcessManager _sharedInstanceCreateIfNeeded:](int a1)
{
    if (a1 != 0) {
        dispatch_once(&_sharedInstanceCreateIfNeeded:.onceToken, ^void(void) {
            FBWorkspaceDomain *v9 = [FBWorkspaceDomain alloc];
            id _sharedInstance = [FBSWorkspaceCoupler _sharedInstance];
            FBWorkspaceDomain *v3 = [v9 _initWithCoupler:_sharedInstance specification:[FBSWorkspace _findDomainSpecification]];
            int selfAssertRuntime = [v3 selfAssertRuntime];
            if (selfAssertRuntime != 0) {
                os_log_t oslog = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    id v6 = NSStringFromFBWorkspaceDomainSelfAssertRuntime(selfAssertRuntime);
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "This process will acquire %{public}@ workspace self-assertions.", v6);
                }
            }
            __atomic_store_n(&(_sharedInstanceCreateIfNeeded:.__SharedManager), [[self alloc] _initWithWorkspaceDomain:v3], __ATOMIC_RELEASE);
        });
    }
    return __atomic_load_n(&_sharedInstanceCreateIfNeeded:.__SharedManager, __ATOMIC_ACQUIRE);
}


id -[FBProcessManager _reallyRegisterProcessForHandle:](id a1)
{
    if (!a1) {
        return nil;
    }
    if (![a1 isKindOfClass:NSClassFromString(@"RBSProcessHandle")]) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:RBSProcessHandleClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v10, self, @"FBProcessManager.m", 655, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    id identity = [a1 identity];
    id hostIdentifier = [identity hostIdentifier];
    if (hostIdentifier != nil) {
        int pid = [hostIdentifier pid];
        if (![self processForPID:pid]) {
            id v8 = [RBSProcessHandle forceLookupIdentifer:hostIdentifier error:0];
            [self _reallyRegisterProcessForHandle:v8];
        }
    }
    return [self _bootstrapProcessWithHandle:a1 synchronously:1 error:0];
}


void -[FBProcessManager _bootstrap_consumeLock_addProcess:synchronously:](id a1, int a2)
{
    id v0 = a1;
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBProcessManager.m", 857, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_unfair_lock_assert_owner(&self->_bootstrapLock);
    if (!a2) {
        dispatch_block_t block = BSDispatchBlockCreateWithCurrentQualityOfService(0, ^void(void) {
            os_unfair_lock_lock(&self->_bootstrapLock);
            [self _bootstrap_consumeLock_addProcess:v0 synchronously:1];
        });
        dispatch_async(self->_bootstrapQueue, block);
        os_unfair_lock_unlock(&self->_bootstrapLock);
    } else {
        [self _bootstrap_consumeLock_addProcess:v0];
    }
    os_unfair_lock_assert_not_owner(&self->_bootstrapLock);
}


id -[FBProcessManager processForIdentity:](id a1)
{
    os_unfair_lock_lock(&self->_lock);
    id v1 = [self->_lock_processesByIdentity objectForKey:a1];
    id lastObject = [v1 lastObject];
    os_unfair_lock_unlock(&self->_lock);
    return lastObject;
}


id -[FBProcessManager registerProcessForAuditToken:](struct AnonymousStruct_11 *a1)
{
    os_log_t v14;
    struct AnonymousStruct_11 v1 = *(struct AnonymousStruct_11 *)a1;
    long v2 = BSVersionedPIDForAuditToken(&v1);
    if (v2 == -1) {
        return nil;
    }
    id v4 = [self processForVersionedPID:v2];
    if (v4 != nil) {
        return v4;
    }
    id v5 = nil;
    v1 = *(struct AnonymousStruct_11 *)a1;
    id v6 = [RBSProcessHandle handleForAuditToken:&v1 error:&v5];
    if (!v6) {
        v14 = FBLogProcess();
        if (os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
            id v0 = NSStringFromBSVersionedPID(v2);
            id succinctDescription = [v5 succinctDescription];
            os_log_with_type(v14, OS_LOG_TYPE_ERROR, "Unable to resolve vpid %{public}@: %{public}@", v0, succinctDescription);
            return nil;
        } else {
            return nil;
        }
    }
    [v6 auditToken];
    long v8 = BSVersionedPIDForAuditToken(&v1);
    if (v2 != v8) {
        id v15 = NSStringFromBSVersionedPID(v2);
        id v16 = NSStringFromBSVersionedPID(v8);
        NSString *v17 = [NSString stringWithFormat:@"handleForAudiToken: returned a mismatched vpid : requested=%@ actual=%@ handle=%@", v15, v16, v6];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(_cmd);
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBProcessManager.m", 447, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    v4 = [self _reallyRegisterProcessForHandle:v6];
    if (!v4) {
        v14 = FBLogProcess();
        if (os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
            id v23 = NSStringFromBSVersionedPID(v2);
            os_log_with_type(v14, OS_LOG_TYPE_ERROR, "Failed to begin tracking vpid %{public}@ as %{public}@", v23, v6);
        }
    } else {
        long versionedPID = [v4 versionedPID];
        if (v2 == versionedPID) {
            return v4;
        }
        id v11 = NSStringFromBSVersionedPID(v2);
        id v12 = NSStringFromBSVersionedPID(versionedPID);
        NSString *v13 = [NSString stringWithFormat:@"_reallyRegisterProcessForHandle: returned a mismatched vpid : requested=%@ actual=%@ handle=%@", v11, v12, v4];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v25 = NSStringFromSelector(_cmd);
            NSString *v26 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBProcessManager.m", 451, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    return nil;
}


long -[FBProcessManager _createProcessFutureWithExecutionContext:error:](long a1, long a2)
{
    return [self _bootstrapProcessWithExecutionContext:a1 synchronously:0 error:a2];
}


id -[FBProcessManager processForPID:](int a1)
{
    if (a1 < 1) {
        return nil;
    }
    os_unfair_lock_lock(&self->_lock);
    NSNumber *v1 = [NSNumber numberWithInt:a1];
    id v0 = [self->_lock_processesByPID objectForKey:v1];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


id -[FBProcessManager registerProcessForHandle:](id a1)
{
    uint8_t v1[32];
    BSAuditToken *auditToken = [a1 auditToken];
    if (!auditToken) {
        _memset(v1, 0, 32);
    } else {
        [auditToken realToken:&v1];
    }
    return [self registerProcessForAuditToken:&v1];
}


id -[FBProcessManager allProcesses](void)
{
    os_unfair_lock_lock(&self->_lock);
    NSArray *allValues = [self->_lock_processesByPID allValues];
    id v1 = [allValues copy];
    os_unfair_lock_unlock(&self->_lock);
    id v2 = @[];
    if (v1 != nil) {
        v2 = v1;
    }
    return v2;
}


long -[FBProcessManager defaultWatchdogPolicy](void)
{
    return objc_getProperty(self, _cmd, 104, 1);
}


id -[FBProcessManager watchdogPolicyForProcess:eventContext:](id a1, id a2)
{
    id<FBProcessWatchdogProviding> defaultWatchdogPolicy = [self defaultWatchdogPolicy];
    return [defaultWatchdogPolicy watchdogPolicyForProcess:a1 eventContext:a2];
}


void *-[FBProcessManager _initWithWorkspaceDomain:](id a1, long a2)
{
    id v0 = a1;
    if (!self) {
        return self;
    }
    if (!v0) {
        NSString *v1 = NSStringFromClass([FBWorkspaceDomain class]);
        NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"workspaceDomain", v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v55 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v56 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v55, v56, self, @"FBProcessManager.m", 116, v2);
        }
        _bs_set_crash_log_message([v2 UTF8String]);
        __break(0);
    }
    if (![v0 isKindOfClass:[FBWorkspaceDomain class]]) {
        Class v58 = [v0 classForCoder];
        if (!v58) {
            v58 = [v0 class];
        }
        NSString *v59 = NSStringFromClass(v58);
        NSString *v60 = NSStringFromClass([FBWorkspaceDomain class]);
        NSString *v61 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"workspaceDomain", v59, v60];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v62 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v63 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v62, v63, self, @"FBProcessManager.m", 116, v61);
        }
        _bs_set_crash_log_message([v61 UTF8String]);
        __break(0);
    }
    self = [super init];
    if (!self) {
        return self;
    }
    FBWorkspaceEventDispatcher *v3 = [[FBWorkspaceEventDispatcher alloc] _initWithDomain:v0];
    self->_eventDispatcher = v3;
    id concurrent = [BSDispatchQueueAttributes concurrent];
    self->_bootstrapQueue = BSDispatchQueueCreate(@"com.apple.frontboard.process-manager.bootstrap", concurrent);
    id serial = [BSDispatchQueueAttributes serial];
    id v9 = [serial serviceClass:33];
    self->_callOutQueue = BSDispatchQueueCreate(@"com.apple.frontboard.process-manager.call-out", v9);
    memset(&self->_lock, 0, 4);
    self->_lock_processesByPID = [NSMutableDictionary dictionary];
    self->_lock_processesByVersionedPID = [NSMutableDictionary dictionary];
    self->_lock_processesByIdentity = [NSMutableDictionary dictionary];
    self->_lock_observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsZeroingWeakMemory | NSPointerFunctionsMachVirtualMemory | NSPointerFunctionsObjectPointerPersonality capacity:1];
    memset(&self->_bootstrapLock, 0, 4);
    self->_bootstrap_pendingProcesses = [NSMutableSet set];
    self->_bootstrap_bootstrappingProcesses = [NSMutableSet set];
    self->_noDirectAccess_defaultWatchdogPolicy = [FBApplicationProcessWatchdogPolicy defaultPolicy];
    id currentProcess = [RBSProcessHandle currentProcess];
    if (!currentProcess) {
        NSString *v65 = [NSString stringWithFormat:@"Unable to communicate with RunningBoard"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v66 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v67 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v66, v67, self, @"FBProcessManager.m", 136, v65);
        }
        _bs_set_crash_log_message([v65 UTF8String]);
        __break(0);
    }
    id identity = [currentProcess identity];
    if (!identity) {
        NSString *v69 = [NSString stringWithFormat:@"RunningBoard returned a currentProcess with no identity : %@", currentProcess];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v70 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v71 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v70, v71, self, @"FBProcessManager.m", 138, v69);
        }
        _bs_set_crash_log_message([v69 UTF8String]);
        __break(0);
    }
    Class v28 = [FBApplicationProcess class];
    if (!v28) {
        NSString *v73 = [NSString stringWithFormat:@"unknown processClass for currentProcessHandle : %@", currentProcess];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v74 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v75 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v74, v75, self, @"FBProcessManager.m", 147, v73);
        }
        _bs_set_crash_log_message([v73 UTF8String]);
        __break(0);
    }
    self->_currentProcess = [[v28 alloc] _initWithProcessManager:self identity:identity handle:currentProcess executionContext:0];
    FBProcess *v31 = self->_currentProcess;
    if (!self->_currentProcess) {
        NSString *v77 = [NSString stringWithFormat:@"Must have a current process."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v78 = NSStringFromSelector(@selector(_initWithWorkspaceDomain:));
            NSString *v79 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v78, v79, self, @"FBProcessManager.m", 152, v77);
        }
        _bs_set_crash_log_message([v77 UTF8String]);
        __break(0);
    }
    struct FBProcessManager *v36 = self;
    [v31 bootstrapLock:^void(id<FBProcessBootstrapping> arg1) {
        [arg1 bootstrapWithDelegate:self];
    }];
    long v37 = __getpid();
    NSNumber *v54 = [NSNumber numberWithInt:v37];
    [self->_lock_processesByPID setObject:self->_currentProcess forKey:v54];
    long versionedPID = [self->_currentProcess versionedPID];
    NSNumber *v40 = [NSNumber numberWithLongLong:versionedPID];
    [self->_lock_processesByVersionedPID setObject:self->_currentProcess forKey:v40];
    NSMutableArray<FBProcess *> *v41 = [NSMutableArray arrayWithObject:self->_currentProcess];
    RBSProcessIdentity *identity2 = [self->_currentProcess identity];
    [self->_lock_processesByIdentity setObject:v41 forKey:identity2];
    __weak id v33 = v36;
    self->_processMonitor = [RBSProcessMonitor monitorWithConfiguration:^void(id<RBSProcessMonitorConfiguring> arg1) {
        RBSProcessStateDescriptor *v82 = [[RBSProcessStateDescriptor alloc] init];
        [v82 setValues:3];
        [arg1 setServiceClass:25];
        [arg1 setStateDescriptor:v82];
        if ([v0 monitorAllSuspendableProcesses] != 0) {
            id predicateMatchingSuspendableProcesses = [RBSProcessPredicate predicateMatchingSuspendableProcesses];
            NSArray *v84 = @[predicateMatchingSuspendableProcesses];
            [arg1 setPredicates:v84];
        }
        void (^v85)(RBSProcessMonitor *, RBSProcessHandle *, RBSProcessStateUpdate *) = ^void(RBSProcessMonitor *arg1, RBSProcessHandle *arg2, RBSProcessStateUpdate *arg3) {
            if (!arg2) {
                _memset(v3, 0, 32);
            } else {
                [arg2 auditToken:&v3];
            }
            id v86 = [v33 processForVersionedPID:BSVersionedPIDForAuditToken(&v3)];
            if (v86 != nil) {
                [v86 _noteStateDidUpdate:arg3];
            }
        };
        [arg1 setUpdateHandler:v85];
    }];
    id domain = [self->_eventDispatcher domain];
    id domain2 = [domain domain];
    long _isSharedInstance = [domain2 _isSharedInstance];
    NSString *v50 = ((_isSharedInstance & 1) == 0) ? [NSString stringWithFormat:@"FBProcessManager-%p", v36] : @"FBProcessManager-sharedInstance";
    self = v36;
    self->_stateCaptureAssertion = BSLogAddStateCaptureBlockForUserRequestsOnlyWithTitle(0, v50, ^id(void) {
        return [self description];
    });
    [v0 setIndirectConnectionDelegate:self];
    return self;
}


void -[FBProcessManager _removeProcess:](id a1)
{
    NSArray *v9;
    id v0 = a1;
    if (!a1) {
        NSString *v20 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v21 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v21, v3, self, @"FBProcessManager.m", 981, v20);
        }
        _bs_set_crash_log_message([v20 UTF8String]);
        __break(0);
    }
    [v0 bootstrapLock:^void(id<FBProcessBootstrapping> arg1) {
        [arg1 invalidate];
    }];
    os_log_t oslog = FBLogProcess();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Removing: %{public}@", v0);
    }
    os_unfair_lock_lock(&self->_bootstrapLock);
    os_unfair_lock_lock(&self->_lock);
    id identity = [v0 identity];
    if (identity != nil) {
        id identity2 = [v0 identity];
        id v6 = [self->_lock_processesByIdentity objectForKey:identity2];
        if ([v6 containsObject:v0]) {
            if ([v6 count] != 1) {
                [v6 removeObject:v0];
            } else {
                [self->_lock_processesByIdentity removeObjectForKey:identity];
            }
        }
    }
    int pid = [v0 pid];
    if (pid >= 1) {
        NSNumber *v8 = [NSNumber numberWithInt:pid];
        [self->_lock_processesByPID removeObjectForKey:v8];
    }
    if (!self->_bootstrapLock_invalidated) {
        id domain = [self->_eventDispatcher domain];
        long monitorAllSuspendableProcesses = [domain monitorAllSuspendableProcesses];
        if ((monitorAllSuspendableProcesses & 1) == 0) {
            id processPredicate = [v0 processPredicate];
            if (!processPredicate) {
                v9 = nil;
            } else if (![self->_bootstrap_processPredicates containsObject:processPredicate]) {
                v9 = nil;
            } else {
                [self->_bootstrap_processPredicates removeObject:processPredicate];
                v9 = [self->_bootstrap_processPredicates allObjects];
            }
        } else {
            v9 = nil;
        }
    } else {
        v9 = nil;
    }
    long versionedPID = [v0 versionedPID];
    if (versionedPID != -1) {
        NSNumber *v15 = [NSNumber numberWithLongLong:versionedPID];
        [self->_lock_processesByVersionedPID removeObjectForKey:v15];
    }
    os_unfair_lock_unlock(&self->_lock);
    if (!v9) {
        os_unfair_lock_unlock(&self->_bootstrapLock);
    } else {
        os_unfair_lock_lock(&self->_bootstrapPredicatesLock);
        os_unfair_lock_unlock(&self->_bootstrapLock);
        [self->_processMonitor updateConfiguration:^void(long arg1) {
            [arg1 setPredicates:v9];
        }];
        os_unfair_lock_unlock(&self->_bootstrapPredicatesLock);
    }
    [self _notifyObserversUsingBlock:^void(long arg1) {
        [arg1 processManager:self didRemoveProcess:v0];
    } completion:0];
}


long -[FBProcessManager _registerProcessForMonitorableProcessHandle:error:](long a1, long a2)
{
    return [self _bootstrapProcessWithHandle:a1 synchronously:1 error:a2];
}


FBProcess *-[FBProcessManager systemApplicationProcess](void)
{
    return (![self->_currentProcess isApplicationProcess]) ? nil : self->_currentProcess;
}


NSMutableArray *-[FBProcessManager processesForBundleIdentifier:](NSString *a1)
{
    NSMutableArray *array = [NSMutableArray array];
    id allProcesses = [self allProcesses];
    for (id v8 in allProcesses) {
        NSString *bundleIdentifier = [v8 bundleIdentifier];
        if ([bundleIdentifier isEqualToString:a1]) {
            [array addObject:v8];
        }
    }
    return array;
}


long +[FBProcessManager sharedInstanceIfExists](void)
{
    return [FBProcessManager _sharedInstanceCreateIfNeeded:0];
}


long -[FBProcessManager noteProcessDidExit:](long a1)
{
    return [self _removeProcess:a1];
}


void -[FBProcessManager dealloc](void)
{
    if (!self->_bootstrapLock_invalidated) {
        NSString *v5 = [NSString stringWithFormat:@"must call _invalidateWithCompletion: before dealloc"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcessManager.m", 195, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBProcessManager:%p deallocing.", self);
    }
    [super dealloc];
}


FBProcess *-[FBProcessManager currentProcess](void)
{
    return self->_currentProcess;
}


void -[FBProcessManager addObserver:](id a1)
{
    os_unfair_lock_lock(&self->_lock);
    if (![self->_lock_observers containsObject:a1]) {
        [self->_lock_observers addObject:a1];
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBProcessManager removeObserver:](id a1)
{
    os_unfair_lock_lock(&self->_lock);
    if ([self->_lock_observers containsObject:a1]) {
        [self->_lock_observers removeObject:a1];
    }
    os_unfair_lock_unlock(&self->_lock);
}


long -[FBProcessManager add:](long a1)
{
    return [self addObserver:a1];
}


long -[FBProcessManager remove:](id a1)
{
    return [self removeObserver:a1];
}


id -[FBProcessManager description](void)
{
    id allProcesses = [self allProcesses];
    NSArray *v1 = [allProcesses sortedArrayUsingComparator:^long(id arg1, id arg2) {
        int pid = [arg1 pid];
        int pid2 = [arg2 pid];
        if (pid >= pid2) {
            return 1;
        } else {
            return -1;
        }
    }];
    id v2 = [BSDescriptionBuilder builderWithObject:self];
    [v2 appendArraySection:v1 withName:@"processes" skipIfEmpty:0];
    return [v2 build];
}


NSMutableArray *-[FBProcessManager allApplicationProcesses](void)
{
    os_unfair_lock_lock(&self->_lock);
    NSMutableArray *array = [NSMutableArray array];
    NSEnumerator *objectEnumerator = [self->_lock_processesByPID objectEnumerator];
    for (id v7 in objectEnumerator) {
        if ([v7 isApplicationProcess] != 0) {
            [array addObject:v7];
        }
    }
    os_unfair_lock_unlock(&self->_lock);
    return array;
}


id -[FBProcessManager applicationProcessForPID:](long a1)
{
    id v0 = [self processForPID:a1];
    return (![v0 isApplicationProcess]) ? nil : v0;
}


NSMutableArray *-[FBProcessManager applicationProcessesForBundleIdentifier:](NSString *a1)
{
    NSMutableArray *array = [NSMutableArray array];
    id allProcesses = [self allProcesses];
    for (id v8 in allProcesses) {
        if (![v8 isApplicationProcess]) {
            continue;
        }
        NSString *bundleIdentifier = [v8 bundleIdentifier];
        if (![bundleIdentifier isEqualToString:a1]) {
            continue;
        }
        [array addObject:v8];
    }
    return array;
}


id -[FBProcessManager _bestProcessForOpenApplicationIdentifier:](NSString *a1)
{
    BOOL v6;
    os_unfair_lock_lock(&self->_bootstrapLock);
    id v1 = [FBProcess _currentProcess];
    if (v1 != nil) {
        NSString *bundleIdentifier2 = [v1 bundleIdentifier];
        v6 = [bundleIdentifier2 isEqualToString:a1];
    }
    if (v1 == nil || !v6) {
        id v2 = [self processesForBundleIdentifier:a1];
        v1 = [v2 firstObject];
        if (!v1) {
            long v3 = 0;
            for (id v12 in self->_bootstrap_pendingProcesses) {
                NSString *bundleIdentifier = [v12 bundleIdentifier];
                if ([bundleIdentifier isEqualToString:a1]) {
                    v1 = v12;
                    v3 = 1;
                }
                if (v3) {
                    break;
                }
            }
            if (!v3) {
                v1 = nil;
            }
        }
    }
    os_unfair_lock_unlock(&self->_bootstrapLock);
    return v1;
}


FBLocalSynchronousSceneClientProvider *-[FBProcessManager syncLocalSceneClientProvider](void)
{
    os_unfair_lock_lock(&self->_lock);
    FBLocalSynchronousSceneClientProvider *v0 = self->_lock_syncLocalSceneClientProvider;
    if (!self->_lock_syncLocalSceneClientProvider) {
        self->_lock_syncLocalSceneClientProvider = [[FBLocalSynchronousSceneClientProvider alloc] _initWithWorkspaceCoupler:[[self->_eventDispatcher domain] domain] currentProcess:self->_currentProcess eventDispatcher:self->_eventDispatcher];
        v0 = self->_lock_syncLocalSceneClientProvider;
        if (self->_lock_invalidated == 1) {
            [v0 _invalidate];
            v0 = self->_lock_syncLocalSceneClientProvider;
        }
    }
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


void -[FBProcessManager _noteShellInitializationComplete](void)
{
    dispatch_async(self->_callOutQueue, ^void(void) {
        os_unfair_lock_lock(&self->_lock);
        self->_lock_initializationComplete = YES;
        NSArray *allValues = [self->_lock_processesByPID allValues];
        id v1 = [allValues copy];
        os_unfair_lock_unlock(&self->_lock);
        for (id v7 in v1) {
            [v7 noteProcessPublished];
        }
    });
}


long -[FBProcessManager setDefaultWatchdogPolicy:](long a1)
{
    return objc_setProperty_atomic(self, _cmd, a1, 104);
}


void -[FBProcessManager .cxx_destruct](void)
{
    self->_lock_assertion = nil;
    self->_lock_observers = nil;
    self->_lock_processesByIdentity = nil;
    self->_lock_processesByVersionedPID = nil;
    self->_lock_processesByPID = nil;
    self->_noDirectAccess_defaultWatchdogPolicy = nil;
    self->_bootstrap_processPredicates = nil;
    self->_bootstrap_bootstrappingProcesses = nil;
    self->_bootstrap_pendingProcesses = nil;
    self->_stateCaptureAssertion = nil;
    self->_processMonitor = nil;
    self->_callOutQueue = nil;
    self->_bootstrapQueue = nil;
    self->_lock_syncLocalSceneClientProvider = nil;
    self->_currentProcess = nil;
    self->_lock_legacySceneManager = nil;
    self->_eventDispatcher = nil;
}


void -[FBProcessManager init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBProcessManager"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcessManager.m", 111, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
