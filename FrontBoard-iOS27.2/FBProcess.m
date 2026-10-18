struct FBProcess {
    __weak FBProcessManager *_processManager; // +0x8
    int _pid; // +0x10
    long _versionedPID; // +0x18
    RBSProcessIdentity *_identity; // +0x20
    BSProcessHandle *_handle; // +0x28
    RBSProcessHandle *_rbsHandle; // +0x30
    NSString *_bundleIdentifier; // +0x38
    NSString *_executablePath; // +0x40
    BSAuditToken *_auditToken; // +0x48
    FBWorkspace *_workspace; // +0x50
    FBProcessExecutionContext *_executionContext; // +0x58
    NSString *_identityDescription; // +0x60
    NSString *_handleDescription; // +0x68
    struct os_unfair_recursive_lock_s _lock; // +0x70
    struct os_unfair_lock_s _observerLock; // +0x78
    struct os_unfair_lock_s _bootstrapLock; // +0x7c
    struct os_unfair_lock_s _watchdogProviderLock; // +0x80
    NSString *_description; // +0x88
    NSError *_bootstrapError; // +0x90
    NSMutableSet *_observerLock_observers; // +0x98
    RBSAssertion *_lock_gracefulExitAssertion; // +0xa0
    NSMutableArray *_lock_launchCompletionBlocks; // +0xa8
    NSMutableArray *_lock_bootstrapBlocks; // +0xb0
    FBSApplicationInfo *_lock_applicationInfo; // +0xb8
    FBProcessState *_lock_state; // +0xc0
    RBSProcessState *_lock_rbsState; // +0xc8
    unsigned char _lock_sceneState; // +0xd0
    FBProcessCPUStatistics *_lock_watchdogCPUStatistics; // +0xd8
    FBSProcessTerminationRequest *_lock_terminationRequest; // +0xe0
    FBProcessWatchdogEventContext *_lock_terminationWatchdogContext; // +0xe8
    long _terminationReason; // +0xf0
    NSMutableArray *_lock_terminateRequestCompletionBlocks; // +0xf8
    BSAbsoluteMachTimer *_lock_exitTimer; // +0x100
    id<FBProcessWatchdogProviding> _watchdogProvider; // +0x108
    FBProcessWatchdog *_lock_watchdog; // +0x110
    FBSProcessWatchdogPolicy *_sceneCreateWatchdogPolicy; // +0x118
    FBSProcessExecutionProvision *_lock_latestViolatedProvision; // +0x120
    bool _lock_pendingExit; // +0x128
    bool _lock_invalidated; // +0x129
    bool _lock_attemptedBootstrap; // +0x12a
    bool _lock_waitForDebugger; // +0x12b
    bool _lock_updatingState; // +0x12c
    bool _lock_didExit; // +0x12d
    bool _lock_launchFinalized; // +0x12e
    bool _lock_launchSuccess; // +0x12f
    bool _lock_attemptedGracefulTermination; // +0x130
    long _lock_executableLivesOnSystemPartition; // +0x138
    long _lock_platformBinary; // +0x140
    bool _calloutQueue_sentWillExit; // +0x148
    bool _calloutQueue_sentDidExit; // +0x149
    bool _calloutQueue_sentAppWillLaunch; // +0x14a
    bool _calloutQueue_sentAppDidLaunch; // +0x14b
    __weak id<FBProcessDelegate> _lock_delegate; // +0x150
    FBProcessExitContext *_lock_exitContext; // +0x158
    double _execTime; // +0x160
    RBSTarget *_target; // +0x168
};

static long FBAssertionDomain;

long -[FBProcess _finishInit](void)
{
    return self;
}


FBProcess *-[FBProcess _initWithProcessManager:identity:handle:executionContext:](FBProcessManager *a1, RBSProcessIdentity *a2, id a3, id a4)
{
    if (!a2) {
        NSString *v53 = [NSString stringWithFormat:@"must be initialized with an identity : identity=%@ handle=%@", 0, a3];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v54 = NSStringFromSelector(_cmd);
            NSString *v55 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v54, v55, self, @"FBProcess.m", 174, v53);
        }
        _bs_set_crash_log_message([v53 UTF8String]);
        __break(0);
    }
    if (!a3 != (a4 != nil)) {
        NSString *v7 = [NSString stringWithFormat:@"must have either a handle or a context, but not both: %@ // %@", a3, a4];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v57 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v57, self, @"FBProcess.m", 175, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    FBProcess *v9 = [super init];
    if (v9 != nil) {
        v9->_processManager = a1;
        v9->field_112 = 0;
        v9->field_120 = 0;
        v9->_pid = -1;
        v9->_versionedPID = -1;
        v9->_identity = a2;
        v9->_identityDescription = [a2 description];
        v9->_executionContext = [a4 copy];
        v9->_watchdogProvider = [v9->_executionContext watchdogProvider];
        v9->_bundleIdentifier = [a2 embeddedApplicationIdentifier];
        v9->_lock_executableLivesOnSystemPartition = 0x7fffffffffffffff;
        v9->_lock_platformBinary = 0x7fffffffffffffff;
        v9->_observerLock_observers = [[NSMutableSet alloc] init];
        v9->_lock_bootstrapBlocks = [[NSMutableArray alloc] init];
        @autoreleasepool {
            NSRange v24 = [v9->_identityDescription rangeOfString:@"{"];
            NSRange v25 = [v9->_identityDescription rangeOfString:@"}" options:NSBackwardsSearch];
            NSUInteger v26 = v25.length;
            if (v24.location != NSNotFound && v25.location != NSNotFound) {
                NSString *v27 = [v9->_identityDescription substringToIndex:v24.location];
                NSString *aString = [v9->_identityDescription substringFromIndex:v26 + v25.location];
                v9->_identityDescription = [v27 stringByAppendingString:aString];
            }
            NSRange v31 = [v9->_identityDescription rangeOfString:@"("];
            NSRange v32 = [v9->_identityDescription rangeOfString:@")" options:NSBackwardsSearch];
            NSUInteger v33 = v32.length;
            if (v31.location != NSNotFound && v32.location != NSNotFound) {
                NSString *v34 = [v9->_identityDescription substringToIndex:v31.location];
                NSString *aString2 = [v9->_identityDescription substringFromIndex:v33 + v32.location];
                v9->_identityDescription = [v34 stringByAppendingString:aString2];
            }
            NSRange v38 = [v9->_identityDescription rangeOfString:@"["];
            NSRange v39 = [v9->_identityDescription rangeOfString:@"]" options:NSBackwardsSearch];
            NSUInteger v40 = v39.length;
            if (v38.location != NSNotFound && v39.location != NSNotFound) {
                NSString *v41 = [v9->_identityDescription substringToIndex:v38.location];
                NSString *aString3 = [v9->_identityDescription substringFromIndex:v40 + v39.location];
                v9->_identityDescription = [v41 stringByAppendingString:aString3];
            }
        }
        if (a3 != nil) {
            [v9 _configureIntrinsicsFromHandle:a3];
        }
        v9->_lock_state = [[FBProcessState alloc] initWithPid:v9->_pid];
        [v9 _finishInit];
        v9->_workspace = [[FBWorkspace alloc] _initWithDispatcher:[a1 eventDispatcher] process:v9];
        if (!v9->_executionContext) {
            v9->_executionContext = [[FBProcessExecutionContext alloc] initWithIdentity:a2];
        }
    }
    return v9;
}


NSString *-[FBProcess logProem](void)
{
    NSString *self;
    if (self != nil) {
        self = (!self->_handleDescription) ? [NSString stringWithFormat:@"[%@:-1]", self->_identityDescription] : self->_handleDescription;
    }
    return self;
}


FBProcessExecutionContext *-[FBProcess executionContext](void)
{
    return self->_executionContext;
}


id -[FBProcess succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    id v1 = NSStringFromBSVersionedPID(self->_versionedPID);
    NSString *v2 = [NSString stringWithFormat:@"%@:%@", self->_identityDescription, v1];
    [v0 appendString:v2 withName:0];
    return v0;
}


int -[FBProcess bootstrapWithDelegate:](id<FBProcessDelegate> a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"delegate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcess.m", 444, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_unfair_lock_assert_owner(&self->_bootstrapLock);
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool v1 = self->_lock_attemptedBootstrap;
    if (!self->_lock_attemptedBootstrap) {
        self->_lock_attemptedBootstrap = YES;
        self->_lock_delegate = a1;
        os_unfair_recursive_lock_unlock(&self->_lock);
        [self _bootstrapAndExec];
    } else {
        os_unfair_recursive_lock_unlock(&self->_lock);
    }
    return !v1;
}


id -[FBProcess succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


RBSProcessHandle *-[FBProcess rbsHandle](void)
{
    return self->_rbsHandle;
}


int -[FBProcess(FBExtensionProcess) isExtensionProcess](void)
{
    return 0;
}


int -[FBProcess pid](void)
{
    return self->_pid;
}


bool -[FBProcess isCurrentProcess](void)
{
    long v0 = __getpid(self);
    return self->_pid == v0;
}


void -[FBProcess bootstrapLock:](void (^a1)(id<FBProcessBootstrapping>))
{
    os_unfair_lock_assert_not_owner(&self->_lock);
    os_unfair_lock_lock(&self->_bootstrapLock);
    if (a1 != nil) {
        a1(self);
    }
    os_unfair_lock_unlock(&self->_bootstrapLock);
}


void -[FBProcess _bootstrapAndExec](void)
{
    id v15;
    FBWorkspaceEndpointPromise *v16;
    RBSAssertion *v22;
    NSObject<OS_dispatch_queue> *v89;
    NSError *v69;
    os_log_t v92;
    id v30;
    long v25;
    NSError *v32;
    RBSAssertion *v41;
    RBSLaunchRequest *v28;
    int v45;
    struct timespec v6;
    NSError *error;
    uint8_t v1[240];
    uint8_t v103[32];
    double v66;
    os_unfair_lock_assert_owner(&self->_bootstrapLock);
    long launchIntent = [self->_executionContext launchIntent];
    os_log_t log = FBLogProcess();
    bool v5 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (launchIntent) {
        if (v5) {
            id v7 = FBProcessLaunchIntentDescription(launchIntent);
            NSString *v37 = self->_identityDescription;
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Bootstrapping %{public}@ with intent %{public}@", v37, v7);
        }
    } else if (v5) {
        NSString *v4 = self->_identityDescription;
        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Bootstrapping %{public}@", v4);
    }
    self->_execTime = [NSDate timeIntervalSinceReferenceDate];
    self->_lock_waitForDebugger = [self->_executionContext waitForDebugger];
    int *v8 = &FBWorkspaceStateNone;
    long v9 = 0;
    id _domain = [self->_workspace _domain];
    id v11 = [_domain assertionAttributesForLaunchIntent:launchIntent outWorkspaceState:&v8 outProcessVisibility:&v9];
    id _createBootstrapContext = [self _createBootstrapContext];
    [_createBootstrapContext setAttributes:v11];
    RBSProcessHandle *v13 = self->_rbsHandle;
    if (self->_rbsHandle != nil) {
        int pid2 = [v13 pid];
        long v14 = __getpid(pid2);
        if (pid2 == v14) {
            v15 = [RBSProcessHandle currentProcess];
            v16 = [self->_workspace _incomingEndpointPromise];
            if (![v11 count]) {
                v22 = nil;
                if (v15 != nil) {
blk_1c4ed71dc:
                    long count = [v11 count];
                    if (count != 0 && !v22) {
                        os_log_t oslog5 = FBLogProcess();
                        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                            long requiredExistingProcess = [_createBootstrapContext requiredExistingProcess];
                            v6.tv_sec = 0x8420402;
                            v6.field_4 = self->_identityDescription;
                            v6.field_12 = 2114;
                            v6.field_14 = requiredExistingProcess;
                            v6.field_22 = 2114;
                            v6.field_32 = 2114;
                            v6.field_34 = v11;
                            _os_log_error_impl(&_mh_dylib_header, oslog5, OS_LOG_TYPE_ERROR, "failed to acquire launch assertion for %{public}@ : existingProcess=%{public}@ error=%{public}@ attributes=%{public}@", &v6, 42);
                        }
                    }
                    [self _configureIntrinsicsFromHandle:v15];
                    os_log_t oslog6 = FBLogProcess([self _configureBundleInfo]);
                    if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
                        NSString *logProem = [self logProem];
                        os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "%{public}@ Bootstrap success!", logProem);
                    }
                    [self _updateStateWithBlock:^void(FBProcessState *arg1) {
                        [arg1 setPid:self->_pid];
                        [arg1 setTaskState:2];
                        [arg1 setVisibility:v9];
                        id currentState = [self->_rbsHandle currentState];
                        if ([currentState isRunning]) {
                            [self _rebuildState:currentState];
                        }
                    }];
                    FBSMutableSceneSettings *v76 = [[FBSMutableSceneSettings alloc] init];
                    [v76 setForeground:v9 > 1];
                    long v78 = [FBProcessWatchdogEventContext contextForEvent:1 settings:v76 transitionContext:0];
                    long v79 = [self _startWatchdogTimerForContext:v78];
                    if (!v22) {
                        [self _bootstrapDidComplete];
                        v89 = [FBProcess calloutQueue];
                        dispatch_async(v89, ^void(void) {
                            id<FBProcessDelegate> delegate = [self delegate];
                            [delegate noteProcessDidLaunch:self];
                            os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
                            NSMutableArray *v139 = self->_lock_bootstrapBlocks;
                            self->_lock_bootstrapBlocks = nil;
                            os_unfair_recursive_lock_unlock(&self->_lock);
                            [self _executeBlockAsCurrentProcess:^void(void) {
                                for (id v144 in v139) {
                                    v144->field_16(v144, self, 0);
                                }
                                if (![self isApplicationProcess]) {
                                    return;
                                }
                                self->_calloutQueue_sentAppWillLaunch = YES;
                                id _observers = [self _observers];
                                for (id v143 in _observers) {
                                    [v143 applicationProcessWillLaunch:self];
                                }
                            }];
                        });
                        [self->_workspace _noteProcessBootstrapped:self withHandle:v15 assertion:v22 outgoingEndpointPromise:v16];
                        return;
                    }
                    [v22 fb_setWorkspaceState:v8];
                    if ((v79 & 1) != 0) {
                        [self _bootstrapDidComplete];
                        v89 = [FBProcess calloutQueue];
                        dispatch_async(v89, ^void(void) {
                            id<FBProcessDelegate> delegate = [self delegate];
                            [delegate noteProcessDidLaunch:self];
                            os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
                            NSMutableArray *v147 = self->_lock_bootstrapBlocks;
                            self->_lock_bootstrapBlocks = nil;
                            os_unfair_recursive_lock_unlock(&self->_lock);
                            [self _executeBlockAsCurrentProcess:^void(void) {
                                for (id v152 in v147) {
                                    v152->field_16(v152, self, 0);
                                }
                                if (![self isApplicationProcess]) {
                                    return;
                                }
                                self->_calloutQueue_sentAppWillLaunch = YES;
                                id _observers = [self _observers];
                                for (id v151 in _observers) {
                                    [v151 applicationProcessWillLaunch:self];
                                }
                            }];
                        });
                        [self->_workspace _noteProcessBootstrapped:self withHandle:v15 assertion:v22 outgoingEndpointPromise:v16];
                        return;
                    }
                    NSArray *attributes = [v22 attributes];
                    for (id v2 in attributes) {
                        if ([v2 isKindOfClass:[RBSDurationAttribute class]]) {
                            [self _bootstrapDidComplete];
                            v89 = [FBProcess calloutQueue];
                            dispatch_async(v89, ^void(void) {
                                id<FBProcessDelegate> delegate = [self delegate];
                                [delegate noteProcessDidLaunch:self];
                                os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
                                NSMutableArray *v155 = self->_lock_bootstrapBlocks;
                                self->_lock_bootstrapBlocks = nil;
                                os_unfair_recursive_lock_unlock(&self->_lock);
                                [self _executeBlockAsCurrentProcess:^void(void) {
                                    for (id v160 in v155) {
                                        v160->field_16(v160, self, 0);
                                    }
                                    if (![self isApplicationProcess]) {
                                        return;
                                    }
                                    self->_calloutQueue_sentAppWillLaunch = YES;
                                    id _observers = [self _observers];
                                    for (id v159 in _observers) {
                                        [v159 applicationProcessWillLaunch:self];
                                    }
                                }];
                            });
                            [self->_workspace _noteProcessBootstrapped:self withHandle:v15 assertion:v22 outgoingEndpointPromise:v16];
                            return;
                        }
                    }
                    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                    NSObject<OS_dispatch_workloop> *queue = [FBProcess userInitiatedWorkloop];
                    dispatch_after(when, queue, ^void(void) {
                        [v22 invalidate];
                    });
                    os_log_t oslog7 = FBLogProcess();
                    if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
                        NSString *logProem2 = [self logProem];
                        os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "%{public}@ No launch watchdog for this process, dropping initial assertion in %.1fs", logProem2, 2.0);
                    }
                    v22 = nil;
                    [self _bootstrapDidComplete];
                    v89 = [FBProcess calloutQueue];
                    dispatch_async(v89, ^void(void) {
                        id<FBProcessDelegate> delegate = [self delegate];
                        [delegate noteProcessDidLaunch:self];
                        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
                        NSMutableArray *v163 = self->_lock_bootstrapBlocks;
                        self->_lock_bootstrapBlocks = nil;
                        os_unfair_recursive_lock_unlock(&self->_lock);
                        [self _executeBlockAsCurrentProcess:^void(void) {
                            for (id v168 in v163) {
                                v168->field_16(v168, self, 0);
                            }
                            if (![self isApplicationProcess]) {
                                return;
                            }
                            self->_calloutQueue_sentAppWillLaunch = YES;
                            id _observers = [self _observers];
                            for (id v167 in _observers) {
                                [v167 applicationProcessWillLaunch:self];
                            }
                        }];
                    });
                    [self->_workspace _noteProcessBootstrapped:self withHandle:v15 assertion:v22 outgoingEndpointPromise:v16];
                    return;
blk_1c4ed756c:
                    os_log_t oslog11 = FBLogProcess();
                    if (os_log_type_enabled(oslog11, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog11, OS_LOG_TYPE_ERROR, "Failing bootstrap after excessive (%i) backoff retries of %{public}@", v45, v28);
                    }
blk_1c4ed7588:
                    v69 = error;
                    if (v69 != nil) {
                        RBSProcessHandle *v91 = self->_rbsHandle;
                        if (!v91) {
                            v92 = FBLogProcess();
                            if (os_log_type_enabled(v92, OS_LOG_TYPE_ERROR)) {
                                id v124 = [v69 descriptionWithMultilinePrefix:0];
                                os_log_with_type(v92, OS_LOG_TYPE_ERROR, "Bootstrapping failed for %{public}@ with error: %{public}@", self, v124);
                            }
                            [self _notePendingExitForReason:@"Bootstrap failed"];
                            self->_bootstrapError = error;
                            [0 invalidate];
                            v16 = [[FBWorkspaceEndpointPromise alloc] initWithEndpoint:[FBWorkspaceDomain nullEndpoint]];
                            [self->_workspace _noteProcessBootstrapped:self withHandle:0 assertion:0 outgoingEndpointPromise:v16];
                            return;
                        }
                        long v95 = [RBSProcessIdentifier identifierForIdentifier:v91];
                        id v96 = nil;
                        v15 = [RBSProcessHandle forceLookupIdentifer:v95 error:&v96];
                        v30 = v96;
                        if (!v15) {
                            os_log_t oslog8 = FBLogProcess();
                            bool v98 = os_log_type_enabled(oslog8, OS_LOG_TYPE_ERROR);
                            if (v98) {
                                int pid4 = [self->_rbsHandle pid];
                                id v100 = [v30 descriptionWithMultilinePrefix:0];
                                NSString *v39 = self->_identityDescription;
                                os_log_with_type(oslog8, OS_LOG_TYPE_ERROR, "%{public}@ Error looking up handle matching %i : %{public}@", v39, pid4, v100);
                            }
                            v15 = self->_rbsHandle;
                        } else {
                            _memset(&v1[112], 0, 32);
                            if (self->_rbsHandle != nil) {
                                [self->_rbsHandle auditToken:&v6];
                            }
                            *(__uint128_t *)&v1[208] = 0;
                            *(__uint128_t *)&v1[224] = 0;
                            [v15 auditToken:&v103];
                            long identity = [self->_rbsHandle identity];
                            long identity2 = [v15 identity];
                            long v107 = BSEqualObjects(identity, identity2);
                            if (((((((v6.tv_sec == v103) ? v6.tv_nsec == *(uint64_t *)&v103[8] : 0) == 1) ? v6.field_16 == *(uint64_t *)&v103[16] : 0) == 1) ? v6.field_24 == *(uint64_t *)&v103[24] : 0) == 0 || (v107 & 1) == 0) {
                                os_log_t oslog = FBLogProcess();
                                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                                    NSString *v44 = self->_identityDescription;
                                    RBSProcessHandle *v47 = self->_rbsHandle;
                                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ Fallback lookup of processHandle is a mismatch : %{public}@ != %{public}@", v44, v47, v15);
                                }
                                v15 = nil;
                            }
                        }
                        v16 = [[FBWorkspaceEndpointPromise alloc] initWithEndpoint:[FBWorkspaceDomain nullEndpoint]];
                        if (!v15) {
                            v92 = FBLogProcess();
                            if (os_log_type_enabled(v92, OS_LOG_TYPE_ERROR)) {
                                id v126 = [v69 descriptionWithMultilinePrefix:0];
                                os_log_with_type(v92, OS_LOG_TYPE_ERROR, "Bootstrapping failed for %{public}@ with error: %{public}@", self, v126);
                            }
                            [self _notePendingExitForReason:@"Bootstrap failed"];
                            self->_bootstrapError = error;
                            [0 invalidate];
                            v16 = [[FBWorkspaceEndpointPromise alloc] initWithEndpoint:[FBWorkspaceDomain nullEndpoint]];
                            [self->_workspace _noteProcessBootstrapped:self withHandle:0 assertion:0 outgoingEndpointPromise:v16];
                            return;
                        }
                        if (![v11 count]) {
                            v25 = 0;
                            v22 = nil;
                            goto blk_1c4ed71dc;
                        }
                        int pid = [v15 pid];
                        NSNumber *v113 = [NSNumber numberWithInt:pid];
                        v32 = [RBSTarget targetWithProcessIdentifier:v113];
                        v41 = [[RBSAssertion alloc] initWithExplanation:[_createBootstrapContext explanation] target:v32 attributes:v11];
                        id v116 = nil;
                        long v117 = [v41 acquireWithError:&v116];
                        if ((v117 & 1) == 0) {
                            [v41 invalidate];
                            v22 = nil;
                            goto blk_1c4ed71dc;
                        }
                        v22 = v41;
                        goto blk_1c4ed71dc;
                    }
                }
                NSString *v128 = [NSString stringWithFormat:@"must have either a handle or an error, but not both: %@ // %@", 0, 0];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v129 = NSStringFromSelector(_cmd);
                    NSString *v130 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v129, v130, self, @"FBProcess.m", 815, v128);
                }
                _bs_set_crash_log_message([v128 UTF8String]);
                __break(0);
            }
            int pid3 = [v15 pid];
            NSNumber *v18 = [NSNumber numberWithInt:pid3];
            long v19 = [RBSTarget targetWithProcessIdentifier:v18];
            v22 = [[RBSAssertion alloc] initWithExplanation:[_createBootstrapContext explanation] target:v19 attributes:v11];
            id v23 = nil;
            long v24 = [v22 acquireWithError:&v23];
            if ((v24 & 1) == 0) {
                [v22 invalidate];
                v22 = nil;
            }
            if (!v15) {
                NSString *v132 = [NSString stringWithFormat:@"must have either a handle or an error, but not both: %@ // %@", 0, 0];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v133 = NSStringFromSelector(_cmd);
                    NSString *v134 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v133, v134, self, @"FBProcess.m", 815, v132);
                }
                _bs_set_crash_log_message([v132 UTF8String]);
                __break(0);
            }
            goto blk_1c4ed71dc;
        }
        long v27 = [RBSProcessIdentifier identifierForIdentifier:self->_rbsHandle];
        [_createBootstrapContext setRequiredExistingProcess:v27];
    }
    v28 = [[RBSLaunchRequest alloc] initWithContext:_createBootstrapContext];
    NSString *v29 = RBSRequestErrorDomain;
    v30 = [v28 executeRequest];
    v15 = [v30 process];
    long continuationRoute1 = 0;
    if (!v15) {
        v45 = 0;
        NSString *v46 = RBSServiceErrorThrottleTimeKey;
        while (1) {
            id assertion = [v30 assertion];
            [assertion invalidate];
            error = [v30 error];
            NSErrorDomain domain = [error domain];
            if (![domain isEqualToString:v29]) {
                break;
            }
            NSInteger code2 = [error code];
            if (code2 != 6) {
                goto blk_1c4ed7588;
            }
            if ((unsigned int)v45 > 2) {
                goto blk_1c4ed756c;
            }
            NSDictionary<NSErrorUserInfoKey, id> *userInfo = [error userInfo];
            id v60 = [userInfo objectForKey:v46];
            double doubleValue = [v60 doubleValue];
            double v62 = BSAbsoluteMachTimeNow(v60);
            double v63 = fmin(fmax(doubleValue - v62, 0.0), 30.0);
            os_log_t oslog3 = FBLogProcess();
            if (v60 != nil) {
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Backing off for %0.2fs of %{public}@", v63, v28);
                }
            } else if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Backoff triggered without backoff time %{public}@ : %{public}@", v28, error);
            }
            while (v63 > 0.0) {
                *(__uint128_t *)&v1[112] = xmmword_1c4f5d290;
                if (v63 < 9.223372036854776e+18) {
                    double v65 = modf(v63, &v66);
                    v6.tv_sec = (long)v66;
                    v6.tv_nsec = (long)(v65 * 1000000000.0);
                }
                v63 = doubleValue - BSAbsoluteMachTimeNow(nanosleep(&v6, NULL));
            }
            os_log_t oslog4 = FBLogProcess();
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "re-attempting backed off launch request %{public}@", v28);
            }
            v45++;
            v30 = [v28 executeRequest];
            v15 = [v30 process];
            if (v15 != nil) {
                continuationRoute1 = 1;
                break;
            }
            continue;
        }
        if (!continuationRoute1) {
            goto blk_1c4ed7588;
        }
    }
    v32 = [v30 error];
    NSErrorDomain domain2 = [v32 domain];
    if ([domain2 isEqualToString:v29]) {
        NSInteger code = [v32 code];
        if (code == 2) {
            if (![_createBootstrapContext executionOptions]) {
                id arguments = [_createBootstrapContext arguments];
                if (![arguments count]) {
                    id _additionalEnvironment = [_createBootstrapContext _additionalEnvironment];
                    if ([_additionalEnvironment count] == 0) {
                        long v38 = [_createBootstrapContext standardInPath];
                        if (v38 == 0) {
                            v38 = [_createBootstrapContext standardOutputPath];
                            if (!v38) {
                                id standardErrorPath = [_createBootstrapContext standardErrorPath];
                                if (standardErrorPath == nil) {
                                    os_log_t oslog9 = FBLogProcess();
                                    if (os_log_type_enabled(oslog9, OS_LOG_TYPE_DEFAULT)) {
                                        NSString *v48 = self->_identityDescription;
                                        os_log_with_type(oslog9, OS_LOG_TYPE_DEFAULT, "%{public}@ was already running!", v48);
                                        goto blk_1c4ed6e18;
                                    }
                                    goto blk_1c4ed6e18;
                                }
                            }
                        }
                    }
                }
            }
            os_log_t oslog10 = FBLogProcess();
            if (os_log_type_enabled(oslog10, OS_LOG_TYPE_ERROR)) {
                NSString *v49 = self->_identityDescription;
                os_log_with_type(oslog10, OS_LOG_TYPE_ERROR, "%{public}@ was already running! Some execution context (arguments, environment, etc) may have been lost.", v49);
            }
        }
    }
blk_1c4ed6e18:
    NSString *identifier = [FBSWorkspaceServiceSpecification identifier];
    v41 = [BSServiceConnectionEndpoint endpointOfLaunchIdentifier:FBSSceneClientIdentityDirectLaunchIdentifier fromLaunchResponse:v30 withService:identifier instance:0 error:0];
    if (!v41) {
        v16 = [[FBWorkspaceEndpointPromise alloc] initWithEndpoint:[FBWorkspaceDomain nullEndpoint]];
    } else {
        os_log_t oslog2 = FBLogProcess();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            NSString *v50 = self->_identityDescription;
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ has an outgoing endpoint", v50);
        }
        v16 = [[FBWorkspaceEndpointPromise alloc] initWithEndpoint:v41];
    }
    v22 = [v30 assertion];
    v69 = nil;
    v25 = 0;
    goto blk_1c4ed71dc;
}


RBSLaunchContext *-[FBProcess _createBootstrapContext](void)
{
    RBSLaunchContext *v0 = [[RBSLaunchContext alloc] init];
    [v0 setIdentity:self->_identity];
    NSString *v1 = NSStringFromClass([self class]);
    [v0 setExplanation:v1];
    NSString *overrideExecutablePath = [self->_executionContext overrideExecutablePath];
    [v0 _setOverrideExecutablePath:overrideExecutablePath];
    FBSProcessExecutableSlice *overrideExecutableSlice = [self->_executionContext overrideExecutableSlice];
    if (overrideExecutableSlice != nil) {
        int type = [overrideExecutableSlice type];
        NSNumber *v5 = [NSNumber numberWithInt:type];
        NSArray<NSNumber *> *v7 = @[v5];
        [v0 setLsBinpref:v7];
        if ([overrideExecutableSlice subtype] != -1) {
            int subtype = [overrideExecutableSlice subtype];
            NSNumber *v9 = [NSNumber numberWithInt:subtype];
            NSArray<NSNumber *> *v11 = @[v9];
            [v0 setLsBinprefSubtype:v11];
        }
    }
    NSSet *v12 = [NSSet setWithObject:FBSSceneClientIdentityDirectLaunchIdentifier];
    [v0 setManagedEndpointLaunchIdentifiers:v12];
    return v0;
}


void -[FBProcess _updateStateWithBlock:](void (^a1)(FBProcessState *))
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_didExit != 1) {
        if (!self->_lock_updatingState) {
            self->_lock_updatingState = YES;
            id v3 = [self->_lock_state copy];
            if (a1 != nil) {
                a1(self->_lock_state);
            }
            long taskState = [v3 taskState];
            long taskState2 = [self->_lock_state taskState];
            if (taskState != taskState2) {
                os_log_t oslog2 = FBLogProcess();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem = [self logProem];
                    id v1 = NSStringFromFBProcessTaskState([self->_lock_state taskState]);
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ Setting process task state to: %{public}@", logProem, v1);
                }
            }
            long visibility = [v3 visibility];
            long visibility2 = [self->_lock_state visibility];
            if (visibility != visibility2) {
                os_log_t oslog3 = FBLogProcess();
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem2 = [self logProem];
                    id v20 = NSStringFromFBProcessVisibility([self->_lock_state visibility]);
                    os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%{public}@ Setting process visibility to: %{public}@", logProem2, v20);
                }
            }
            bool isDebugging = [v3 isDebugging];
            bool isDebugging2 = [self->_lock_state isDebugging];
            int v12 = isDebugging != isDebugging2;
            if (isDebugging != isDebugging2) {
                os_log_t oslog = FBLogProcess();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem3 = [self logProem];
                    NSString *v23 = ([self->_lock_state isDebugging]) ? @"YES" : @"NO";
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Setting process debug state to: %{public}@", logProem3, v23);
                }
            }
            if (![v3 isEqual:self->_lock_state]) {
                id v14 = [self->_lock_state copy];
                NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
                dispatch_async(queue, ^void(void) {
                    id _observers = [self _observers];
                    for (id v27 in _observers) {
                        [v27 process:self stateDidChangeFromState:v3 toState:v14];
                    }
                    if (v12 != 1) {
                        return;
                    }
                    id _observers2 = [self _observers];
                    for (id v26 in _observers2) {
                        [v26 applicationProcessDebuggingStateDidChange:self];
                    }
                });
            }
            self->_lock_updatingState = NO;
        } else if (a1 != nil) {
            a1(self->_lock_state);
        }
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
}


long -[FBProcess _bootstrapDidComplete](void)
{
    return self;
}


void -[FBProcess _rebuildState:](RBSProcessState *a1)
{
    RBSProcessState *v0 = a1;
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"rbsState != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBProcess.m", 1137, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    self->_lock_rbsState = a1;
    long v1 = [self->_lock_state taskState];
    long taskState = [v0 taskState];
    long v3 = taskState - 2;
    if ((unsigned long)(taskState - 2) <= 2) {
        v1 = (&qword_1c4f5d2a0)[v3 & 255];
    }
    [self _updateStateWithBlock:^void(FBProcessState *arg1) {
        int v9;
        [arg1 setTaskState:v1];
        if ([v0 isDebugging]) {
            v9 = 1;
        } else if (self->_lock_waitForDebugger == 0) {
            v9 = BSPIDIsBeingDebugged(self->_pid);
        } else {
            v9 = 1;
        }
        [arg1 setDebugging:v9];
    }];
    os_unfair_recursive_lock_unlock(&self->_lock);
}


void -[FBProcess _configureBundleInfo](void)
{
    uint8_t v8[32];
    if (!self->_rbsHandle) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_rbsHandle != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBProcess.m", 971, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    id bundle = [self->_rbsHandle bundle];
    if (!self->_bundleIdentifier) {
        id identifier = [bundle identifier];
        self->_bundleIdentifier = (!identifier) ? [self->_auditToken bundleID] : identifier;
    }
    self->_handle = [BSProcessHandle processHandleForAuditToken:self->_auditToken bundleID:self->_bundleIdentifier];
    NSString *executablePath = [bundle executablePath];
    if (!executablePath) {
        if (!self->_auditToken) {
            _memset(v8, 0, 32);
        } else {
            [self->_auditToken realToken:&v8];
        }
        self->_executablePath = BSExecutablePathForAuditToken(&v8);
    } else {
        self->_executablePath = executablePath;
    }
}


void -[FBProcess _configureIntrinsicsFromHandle:](RBSProcessHandle *a1)
{
    uint8_t v4[32];
    if (!a1) {
        NSString *v30 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"handle != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcess.m", 942, v30);
        }
        _bs_set_crash_log_message([v30 UTF8String]);
        __break(0);
    }
    if (self->_rbsHandle == a1) {
        return;
    }
    if (self->_rbsHandle != nil) {
        [a1 auditToken:&v4];
        id v5 = [BSAuditToken tokenFromAuditToken:&v4];
        if (![v5 isEqual:self->_auditToken]) {
            NSString *v21 = [NSString stringWithFormat:@"auditToken mismatch : existing=%@ new=%@", self->_auditToken, v5];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(_cmd);
                NSString *v32 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v32, self, @"FBProcess.m", 947, v21);
            }
            _bs_set_crash_log_message([v21 UTF8String]);
            __break(0);
        }
        id identity5 = [self->_rbsHandle identity];
        id identity6 = [a1 identity];
        if (![identity5 isEqual:identity6]) {
            id identity2 = [self->_rbsHandle identity];
            id identity3 = [a1 identity];
            NSString *v24 = [NSString stringWithFormat:@"identity mismatch : existing=%@ new=%@", identity2, identity3];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v34 = NSStringFromSelector(_cmd);
                NSString *v35 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v34, v35, self, @"FBProcess.m", 948, v24);
            }
            _bs_set_crash_log_message([v24 UTF8String]);
            __break(0);
        }
        return;
    }
    self->_rbsHandle = a1;
    self->_pid = [self->_rbsHandle pid];
    if (!self->_rbsHandle) {
        _memset(v4, 0, 32);
    } else {
        [self->_rbsHandle auditToken:&v4];
    }
    self->_auditToken = [BSAuditToken tokenFromAuditToken:&v4];
    self->_versionedPID = [self->_auditToken versionedPID];
    self->_target = [RBSTarget targetWithPid:self->_pid];
    self->_description = [self succinctDescription];
    self->_handleDescription = [NSString stringWithFormat:@"[%@:%d]", self->_identityDescription, self->_pid];
    int pid = [self->_auditToken pid];
    if (self->_pid == pid) {
        if ([self->_auditToken isInvalid] != 0) {
            NSString *v27 = [NSString stringWithFormat:@"RBSProcessHandle %@ gave us a bogus audit token: %@", self->_rbsHandle, self->_auditToken];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v37 = NSStringFromSelector(_cmd);
                NSString *v38 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBProcess.m", 962, v27);
            }
            _bs_set_crash_log_message([v27 UTF8String]);
            __break(0);
        }
        if (([self->_identity isXPCService] & 1) == 0) {
            id identity = [a1 identity];
            if (![self->_identity isEqual:identity]) {
                id identity4 = [a1 identity];
                NSString *v29 = [NSString stringWithFormat:@"processIdentity %@ is not equal to handleIdentity %@", self->_identity, identity4];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v40 = NSStringFromSelector(_cmd);
                    NSString *v41 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v41, self, @"FBProcess.m", 965, v29);
                }
                _bs_set_crash_log_message([v29 UTF8String]);
                __break(0);
            }
        }
        return;
    }
    int pid2 = [self->_auditToken pid];
    NSString *v26 = [NSString stringWithFormat:@"RBSProcessHandle %@ gave us a pid (%d) and an audit token with pid (%d) that don't match", self->_rbsHandle, self->_pid, pid2];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v43 = NSStringFromSelector(_cmd);
        NSString *v44 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v43, v44, self, @"FBProcess.m", 961, v26);
    }
    _bs_set_crash_log_message([v26 UTF8String]);
    __break(0);
}


void -[FBProcess _executeBlockAsCurrentProcess:](void (^a1)(void))
{
    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    id v3 = [threadDictionary objectForKey:@"FBProcess"];
    [threadDictionary setObject:self forKey:@"FBProcess"];
    a1();
    if (!v3) {
        [threadDictionary removeObjectForKey:@"FBProcess"];
    } else {
        [threadDictionary setObject:v3 forKey:@"FBProcess"];
    }
}


void -[FBProcess noteProcessPublished](void)
{
    [self->_workspace _enableLegacyRequests:self];
}


bool -[FBProcess _setSceneLifecycleState:](unsigned char a1)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    int v0 = self->_lock_sceneState;
    if (self->_lock_sceneState != a1) {
        self->_lock_sceneState = a1;
        [self _updateStateWithBlock:^void(FBProcessState *arg1) {
            long v2 = (a1 == 2) ? 2 : 0;
            if (a1 == 1) {
                v2 = 1;
            }
            [arg1 setVisibility:v2];
        }];
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0 != a1;
}


bool -[FBProcess _startWatchdogTimerForContext:](id a1)
{
    bool v2;
    FBProcessWatchdog *v4;
    long v1 = __getpid();
    if (self->_pid == v1) {
        return false;
    }
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_didExit != 1) {
        FBProcessWatchdog *v3 = [self _newWatchdogForContext:a1 completion:0];
        v2 = v3 != nil;
        if (!v3) {
            v4 = nil;
        } else {
            v4 = self->_lock_watchdog;
            self->_lock_watchdog = v3;
        }
        os_unfair_recursive_lock_unlock(&self->_lock);
        [v4 invalidate];
        [v3 activate];
    } else {
        os_unfair_recursive_lock_unlock(&self->_lock);
        v2 = false;
    }
    return v2;
}


FBProcessWatchdog *-[FBProcess _newWatchdogForContext:completion:](id a1, void (^a2)(long))
{
    FBSProcessWatchdogPolicy *v10;
    FBProcessWatchdog *v13;
    void (^v1)(id) = a2;
    long event = [a1 event];
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    FBSSceneTransitionContext *sceneTransitionContext = [a1 sceneTransitionContext];
    if (event == 2) {
        id watchdogTransitionContext = [sceneTransitionContext watchdogTransitionContext];
        if (![watchdogTransitionContext runIndependently]) {
            v10 = self->_sceneCreateWatchdogPolicy;
            self->_sceneCreateWatchdogPolicy = nil;
            if (!v10) {
                goto blk_1c4ee74c8;
            } else {
                goto blk_1c4ee754c;
            }
        }
    }
    self->_sceneCreateWatchdogPolicy = nil;
blk_1c4ee74c8:
    id watchdogTransitionContext2 = [sceneTransitionContext watchdogTransitionContext];
    id watchdogProvider = [watchdogTransitionContext2 watchdogProvider];
    id v9 = (!watchdogProvider) ? [self _watchdogProvider] : watchdogProvider;
    v10 = [v9 watchdogPolicyForProcess:self eventContext:a1];
    if (v10 != nil) {
blk_1c4ee754c:
        FBProcessWatchdog *v11 = [[FBProcessWatchdog alloc] initWithProcess:self context:a1 policy:v10];
        v13 = v11;
        [v11 setCompletion:^bool(bool arg1, NSError *arg2) {
            os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
            if (arg1) {
                NSDictionary<NSErrorUserInfoKey, id> *userInfo = [arg2 userInfo];
                id v23 = [userInfo objectForKey:FBSProcessWatchdogErrorProvisionKey];
                if (v23 != nil) {
                    os_log_t oslog = FBLogWatchdog();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        NSString *logProem = [self logProem];
                        NSString *name = [v11 name];
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ Provision violated for watchdog %{public}@: %{public}@", logProem, name, v23);
                    }
                    self->_lock_latestViolatedProvision = [v23 copy];
                }
            }
            if (v11 == self->_lock_watchdog) {
                [self->_lock_watchdog invalidate];
                self->_lock_watchdog = nil;
            }
            os_unfair_recursive_lock_unlock(&self->_lock);
            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
            dispatch_async(queue, ^void(void) {
                if (!v1) {
                    return;
                } else {
                    v1(v11);
                    return;
                }
            });
            return false;
        }];
    } else {
        v13 = nil;
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v13;
}


id -[FBProcess _watchdogProvider](void)
{
    os_unfair_lock_lock(&self->_watchdogProviderLock);
    id<FBProcessWatchdogProviding> v0 = self->_watchdogProvider;
    os_unfair_lock_unlock(&self->_watchdogProviderLock);
    return (!v0) ? [self delegate] : v0;
}


FBSApplicationInfo *-[FBProcess applicationInfo](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    FBSApplicationInfo *v1 = self->_lock_applicationInfo;
    if (!self->_lock_applicationInfo) {
        long isApplicationProcess = [self isApplicationProcess];
        os_unfair_recursive_lock_unlock(&self->_lock);
        if (!isApplicationProcess) {
            v1 = nil;
        } else {
            id sharedInstanceIfExists = [FBSystemService sharedInstanceIfExists];
            id _applicationInfoProvider = [sharedInstanceIfExists _applicationInfoProvider];
            if (self->_auditToken != nil && [_applicationInfoProvider respondsToSelector:@selector(applicationInfoForAuditToken:)]) {
                v1 = [_applicationInfoProvider applicationInfoForAuditToken:self->_auditToken];
                os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
            } else if (!self->_bundleIdentifier) {
                v1 = nil;
                os_unfair_recursive_lock_lock_with_options(&self->_lock, 0, self->_bundleIdentifier);
            } else {
                v1 = [_applicationInfoProvider applicationInfoForBundleIdentifier:self->_bundleIdentifier];
                os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
            }
            self->_lock_applicationInfo = v1;
            os_unfair_recursive_lock_unlock(&self->_lock);
        }
    } else {
        os_unfair_recursive_lock_unlock(&self->_lock);
    }
    return v1;
}


long -[FBProcess addObserver:](id a1)
{
    if (a1 != nil) {
        FBProcessObserver *v2 = [[FBProcessObserver alloc] initWithObserver:a1];
        os_unfair_lock_lock(&self->_observerLock);
        if (v2 && ![self->_observerLock_observers containsObject:v2]) {
            [self->_observerLock_observers addObject:v2];
            os_unfair_lock_unlock(&self->_observerLock);
            NSObject<OS_dispatch_queue> *calloutQueue = [FBProcess calloutQueue];
            dispatch_async(calloutQueue, ^void(void) {
                void *v0 = self;
                if (v0->_calloutQueue_sentWillExit == 1) {
                    [v2 processWillExit:v0];
                    v0 = self;
                }
                if (v0->_calloutQueue_sentDidExit == 1) {
                    [v2 processDidExit:v0];
                    v0 = self;
                }
                if (v0->_calloutQueue_sentAppWillLaunch == 1) {
                    [v2 applicationProcessWillLaunch:v0];
                    v0 = self;
                }
                if (v0->_calloutQueue_sentAppDidLaunch != 1) {
                    return;
                }
                [v2 applicationProcessDidLaunch:v0];
            });
            return calloutQueue;
        }
        os_unfair_lock_unlock(&self->_observerLock);
        return [v2 invalidate];
    }
    return self;
}


id<FBProcessDelegate> -[FBProcess delegate](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    id<FBProcessDelegate> v0 = self->_lock_delegate;
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0;
}


long -[FBProcess versionedPID](void)
{
    return self->_versionedPID;
}


bool -[FBProcess isPendingExit](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool v0 = self->_lock_pendingExit;
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0;
}


id -[FBProcess _observers](void)
{
    os_unfair_lock_lock(&self->_observerLock);
    id v0 = [self->_observerLock_observers copy];
    os_unfair_lock_unlock(&self->_observerLock);
    return v0;
}


RBSTarget *-[FBProcess target](void)
{
    return self->_target;
}


void -[FBProcess _noteAssertionStateDidChange](void)
{
    id<FBProcessDelegate> delegate = [self delegate];
    [delegate noteProcessAssertionStateDidChange:self];
}


long -[FBProcess workspaceState](void)
{
    return [self->_workspace state];
}


void -[FBProcess _executeBlockAfterLaunchCompletes:](void (^a1)(bool))
{
    void (^v2)(bool);
    if (a1 != nil) {
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        if (!self->_lock_launchFinalized) {
            if (!self->_lock_launchCompletionBlocks) {
                v2 = [a1 copy];
                self->_lock_launchCompletionBlocks = [NSMutableArray arrayWithObject:v2];
            } else {
                v2 = [a1 copy];
                void *v4 = _Block_copy(v2);
                [self->_lock_launchCompletionBlocks addObject:v4];
            }
            os_unfair_recursive_lock_unlock(&self->_lock);
        } else {
            bool v5 = self->_lock_launchSuccess;
            os_unfair_recursive_lock_unlock(&self->_lock);
            a1(v5);
        }
    }
}


void -[FBProcess _launchDidComplete:finalizeBlock:](bool a1, void (^a2)(void))
{
    uint8_t v16[32];
    void (^v0)(void) = a2;
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_launchFinalized != 1) {
        self->_lock_launchFinalized = YES;
        self->_lock_launchSuccess = a1;
        os_log_t log = FBLogProcess();
        bool v2 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
        if (a1) {
            if (v2) {
                NSString *logProem3 = [self logProem];
                os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "%{public}@ Connection to remote process established!", logProem3);
            }
        } else if (v2) {
            NSString *logProem2 = [self logProem];
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "%{public}@ Connection to remote process was not established.", logProem2);
        }
        NSMutableArray *v3 = self->_lock_launchCompletionBlocks;
        self->_lock_launchCompletionBlocks = nil;
        if ([self->_lock_watchdog event] == 1) {
            [self->_lock_watchdog deactivate];
            if (a1) {
                NSMutableArray *array = [NSMutableArray array];
                id policy = [self->_lock_watchdog policy];
                id provisions = [policy provisions];
                for (id v14 in provisions) {
                    long v15 = 0;
                    v15.field_16 = 0;
                    if ([v14 isResourceProvision] != 0 && [v14 allowanceRemaining:&v15] != 0) {
                        *(__uint128_t *)&v16[0] = v15;
                        *(uint64_t *)&v16[16] = v15.field_16;
                        id v18 = [FBSProcessResourceProvision provisionWithAllowance:&v16];
                        if (v18 != nil) {
                            os_log_t oslog = FBLogWatchdog();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                                NSString *logProem = [self logProem];
                                os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%{public}@ Provision %{public}@ has remainder %{public}@", logProem, v14, v18);
                            }
                            [array addObject:v18];
                        }
                    }
                }
                if ([array count] != 0) {
                    self->_sceneCreateWatchdogPolicy = [FBSProcessWatchdogPolicy policyWithName:@"scene create after launch" forProvisions:array];
                }
                os_log_t oslog2 = FBLogWatchdog();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                    NSString *logProem4 = [self logProem];
                    FBSProcessWatchdogPolicy *v1 = self->_sceneCreateWatchdogPolicy;
                    os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%{public}@ Made scene-create policy: %{public}@", logProem4, v1);
                }
            }
            [self->_lock_watchdog invalidate];
            self->_lock_watchdog = nil;
        }
        if (!a1) {
            [self _notePendingExitForReason:@"launch failed"];
        } else if (self->_lock_waitForDebugger == 1) {
            self->_lock_waitForDebugger = NO;
            [self _rebuildState];
        }
        os_unfair_recursive_lock_unlock(&self->_lock);
        NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
        dispatch_async(queue, ^void(void) {
            for (id v6 in v3) {
                v6->field_16(v6, a1);
            }
            if (a1 == 1 && [self isApplicationProcess] != 0) {
                self->_calloutQueue_sentAppDidLaunch = YES;
                id _observers = [self _observers];
                for (id v36 in _observers) {
                    [v36 applicationProcessDidLaunch:self];
                }
            }
            int64_t v13 = (([self isApplicationProcess] & 1) == 0) ? [self->_identity hasConsistentLaunchdJob] : 0;
            v13 = (((a1 | v13) & 1) != 0) ? 1000000000 : 100000000;
            v13 = dispatch_time(DISPATCH_TIME_NOW, v13);
            NSObject<OS_dispatch_workloop> *queue = [FBProcess userInitiatedWorkloop];
            dispatch_after(v13, queue, ^void(void) {
                os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
                id v39 = self;
                if (!self->_lock_sceneState) {
                    [v39 _updateStateWithBlock:^void(FBProcessState *arg1) {
                        [arg1 setVisibility:0];
                    }];
                    v39 = self;
                }
                os_unfair_recursive_lock_unlock(&v39->_lock);
                if (!v0) {
                    return;
                }
                v0();
            });
        });
    } else {
        os_unfair_recursive_lock_unlock(&self->_lock);
        if (v0 != nil) {
            NSObject<OS_dispatch_workloop> *queue2 = [FBProcess userInitiatedWorkloop];
            dispatch_async(queue2, v0);
        }
    }
}


id -[FBProcess descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBProcess descriptionBuilderWithMultilinePrefix:](long a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    long v1 = NSStringFromFBProcessTaskState([self->_lock_state taskState]);
    [succinctDescriptionBuilder appendObject:v1 withName:@"taskState" skipIfNil:1];
    long v2 = NSStringFromFBProcessVisibility([self->_lock_state visibility]);
    [succinctDescriptionBuilder appendObject:v2 withName:@"visibility" skipIfNil:1];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return succinctDescriptionBuilder;
}


bool -[FBProcess isForeground](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool isForeground = [self->_lock_state isForeground];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return isForeground;
}


FBWorkspace *-[FBProcess workspace](void)
{
    return self->_workspace;
}


void -[FBProcess _noteStateDidUpdate:](id a1)
{
    id state = [a1 state];
    id v2 = [state copy];
    if (![v2 taskState]) {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id process = [a1 process];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "invalid task state received from runningboard for %{public}@", process);
        }
    } else {
        [self _rebuildState:v2];
    }
}


NSString *-[FBProcess description](void)
{
    return (!self->_description) ? [self succinctDescription] : self->_description;
}


NSString *-[FBProcess bundleIdentifier](void)
{
    return self->_bundleIdentifier;
}


RBSProcessIdentity *-[FBProcess identity](void)
{
    return self->_identity;
}


long -[FBProcess debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


double -[FBProcess execTime](void)
{
    return self->_execTime;
}


long -[FBProcess hasEntitlement:](long a1)
{
    return [self->_auditToken hasEntitlement:a1];
}


int -[FBProcess isBeingDebugged](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool isDebugging = [self->_lock_state isDebugging];
    os_unfair_recursive_lock_unlock(&self->_lock);
    if (!isDebugging) {
        return BSPIDIsBeingDebugged(self->_pid);
    } else {
        return 1;
    }
}


bool -[FBProcess isRunning](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool isRunning = [self->_lock_state isRunning];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return isRunning;
}


long +[FBProcess calloutQueue](void)
{
    dispatch_once(&calloutQueue.onceToken, ^void(void) {
        id serial = [BSDispatchQueueAttributes serial];
        id v1 = [serial serviceClass:33];
        calloutQueue.queue = BSDispatchQueueCreate(@"com.apple.frontboard.process.call-out", v1);
    });
    return calloutQueue.queue;
}


BSProcessHandle *-[FBProcess handle](void)
{
    return self->_handle;
}


dispatch_workloop_t +[FBProcess userInitiatedWorkloop](void)
{
    dispatch_once(&userInitiatedWorkloop.onceToken, ^void(void) {
        userInitiatedWorkloop.queue = dispatch_workloop_create_inactive("com.apple.frontboard.process.user-initiated");
        dispatch_set_qos_class_floor(userInitiatedWorkloop.queue, 25, 0);
        dispatch_activate(userInitiatedWorkloop.queue);
    });
    return userInitiatedWorkloop.queue;
}


id -[FBProcess state](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    id v0 = [self->_lock_state copy];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0;
}


id -[FBProcess processPredicate](void)
{
    if (self->_pid < 1) {
        return nil;
    }
    NSNumber *v2 = [NSNumber numberWithInt:self->_pid];
    return [RBSProcessPredicate predicateMatchingIdentifier:v2];
}


bool -[FBProcess finishedLaunching](void)
{
    return [self isFinishedLaunching];
}


bool -[FBProcess isFinishedLaunching](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    bool v0 = self->_lock_launchSuccess;
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0;
}


int -[FBProcess(FBApplicationProcess) isApplicationProcess](void)
{
    return 0;
}


void -[FBProcess _notePendingExitForReason:](id a1)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (!self->_lock_pendingExit) {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [self logProem];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Now flagged as pending exit for reason: %{public}@", logProem, a1);
        }
        self->_lock_pendingExit = YES;
        NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
        dispatch_async(queue, ^void(void) {
            self->_calloutQueue_sentWillExit = YES;
            id _observers = [self _observers];
            for (id v17 in _observers) {
                [v17 processWillExit:self];
            }
        });
        if (self->_rbsHandle != nil && [self isApplicationProcess] != 0) {
            id currentProcess = [RBSProcessHandle currentProcess];
            long fb_canTaskSuspend = [currentProcess fb_canTaskSuspend];
            if ((fb_canTaskSuspend & 1) == 0) {
                NSDate *date = [NSDate date];
                NSString *logProem2 = [self logProem];
                __block long v9 = 0;
                self->_lock_exitTimer = [[BSAbsoluteMachTimer alloc] initWithIdentifier:logProem2];
                NSObject<OS_dispatch_workloop> *userInitiatedWorkloop = [FBProcess userInitiatedWorkloop];
                objc_msgSend$scheduleRepeatingWithFireInterval:repeatInterval:leewayInterval:queue:handler:(self->_lock_exitTimer, userInitiatedWorkloop, ^void(BSAbsoluteMachTimer *arg1) {
                    id v22 = (self->_lock_attemptedGracefulTermination == 0) ? [self->_rbsHandle lastExitContext] : nil;
                    if (![v22 type]) {
                        NSTimeInterval timeIntervalSinceNow = [date timeIntervalSinceNow];
                        v32++;
                        unsigned long v33 = v32 * 0xcccccccccccccccd;
                        v9 = v32;
                        os_log_type_t type = (((v33 >> 1) | (v33 << 63)) < 0x199999999999999a) ? OS_LOG_TYPE_ERROR : OS_LOG_TYPE_DEBUG;
                        os_log_t oslog2 = FBLogProcess();
                        if (os_log_type_enabled(oslog2, type)) {
                            os_log_with_type(oslog2, type, "%{public}@: Still waiting on exit context after %.1f seconds", logProem2, -timeIntervalSinceNow);
                        }
                        if (timeIntervalSinceNow <= -300.0) {
                            os_log_t v34 = FBLogProcess();
                            if (os_log_type_enabled(v34, OS_LOG_TYPE_ERROR)) {
                                os_log_with_type(v34, OS_LOG_TYPE_ERROR, "No exit notification received for %{public}@ after 5 minutes", logProem2);
                            }
                            id v24 = [NSError bs_errorWithDomain:@"FBProcessTermination" code:2 configuration:^void(id<BSErrorConfiguring> arg1) {
                                [arg1 setFailureDescription:@"Timed out waiting for process termination"];
                                [arg1 setFailureReason:@"No exit notification received after 5 minutes"];
                                [arg1 setCodeDescription:@"timed-out"];
                            }];
                            [self _processDidExitWithContext:[[FBProcessExitContext alloc] initWithTerminationError:v24]];
                            RBSTerminateContext *v26 = [RBSTerminateContext alloc];
                            id userInfo = [v24 userInfo];
                            RBSTerminateContext *v29 = [v26 initWithExplanation:[userInfo objectForKey:NSLocalizedFailureReasonErrorKey]];
                            [v29 setReportType:0];
                            [v29 setExceptionDomain:10];
                            [v29 setExceptionCode:0xfa1cdead];
                            [v29 setMaximumTerminationResistance:40];
                            RBSTerminateRequest *v30 = [RBSTerminateRequest alloc];
                            id v18 = [RBSProcessPredicate predicateMatching:self->_rbsHandle];
                            [[v30 initWithPredicate:v18 context:v29] execute:0];
                        }
                    } else {
                        [self _processDidExitWithContext:[[FBProcessExitContext alloc] initWithUnderlyingContext:v22]];
                    }
                }, 10.0, 1.0, 0.1);
            }
        }
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
}


void -[FBProcess _processDidExitWithContext:](id a1)
{
    FBProcessExitContext *v0 = a1;
    [self _launchDidComplete:0 finalizeBlock:0];
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_didExit == 1) {
        os_unfair_recursive_lock_unlock(&self->_lock);
        return;
    }
    [self _notePendingExitForReason:@"process exited"];
    if (!v0 && (!self->_bootstrapError || ![[FBProcessExitContext alloc] initWithLaunchError:self->_bootstrapError])) {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "No exit context obtained for %{public}@", self);
        }
        v0 = [[FBProcessExitContext alloc] initWithUnderlyingContext:[[RBSProcessExitContext alloc] init]];
    }
    [v0 setTerminationRequest:self->_lock_terminationRequest];
    [v0 setWatchdogContext:self->_lock_terminationWatchdogContext];
    [v0 setTerminationReason:self->_terminationReason];
    [v0 setStateBeforeExiting:self->_lock_state];
    self->_lock_exitContext = v0;
    [self->_lock_watchdog invalidate];
    [self->_lock_exitTimer invalidate];
    self->_lock_exitTimer = nil;
    [self->_lock_gracefulExitAssertion invalidate];
    self->_lock_gracefulExitAssertion = nil;
    os_log_t oslog2 = FBLogProcess();
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem = [self logProem];
        FBProcessExitContext *v1 = self->_lock_exitContext;
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ Process exited: %{public}@.", logProem, v1);
    }
    [self _updateStateWithBlock:^void(FBProcessState *arg1) {
        [arg1 setTaskState:1];
        [arg1 setVisibility:0];
    }];
    self->_lock_didExit = YES;
    NSMutableArray *v7 = self->_lock_terminateRequestCompletionBlocks;
    self->_lock_terminateRequestCompletionBlocks = nil;
    NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
    dispatch_async(queue, ^void(void) {
        id<FBProcessDelegate> delegate = [self delegate];
        [delegate noteProcessDidExit:self];
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        NSMutableArray *v15 = self->_lock_bootstrapBlocks;
        self->_lock_bootstrapBlocks = nil;
        os_unfair_recursive_lock_unlock(&self->_lock);
        self->_calloutQueue_sentDidExit = YES;
        [self _executeBlockAsCurrentProcess:^void(void) {
            if ([v15 count] != 0) {
                id createError = [v0 createError];
                for (id v23 in v15) {
                    v23->field_16(v23, self, createError);
                }
            }
            id _observers = [self _observers];
            for (id v22 in _observers) {
                [v22 processDidExit:self];
            }
            for (id v20 in v7) {
                v20->field_16(v20, 1);
            }
        }];
        FBAnalyticsLogHangTracerEvent(self, 3);
    });
    os_unfair_recursive_lock_unlock(&self->_lock);
}


void -[FBProcess invalidate](void)
{
    os_unfair_lock_assert_owner(&self->_bootstrapLock);
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (!self->_lock_didExit) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_lock_didExit"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcess.m", 469, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    if (!self->_lock_attemptedBootstrap) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_lock_attemptedBootstrap"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBProcess.m", 470, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (self->_lock_invalidated == 1) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"!_lock_invalidated"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBProcess.m", 471, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    self->_lock_invalidated = YES;
    self->_lock_delegate = nil;
    os_unfair_recursive_lock_unlock(&self->_lock);
    [self->_workspace _noteProcessDidInvalidate:self];
}


void -[FBProcess .cxx_destruct](void)
{
    self->_target = nil;
    self->_lock_exitContext = nil;
    self->_lock_delegate = nil;
    self->_lock_latestViolatedProvision = nil;
    self->_sceneCreateWatchdogPolicy = nil;
    self->_lock_watchdog = nil;
    self->_watchdogProvider = nil;
    self->_lock_exitTimer = nil;
    self->_lock_terminateRequestCompletionBlocks = nil;
    self->_lock_terminationWatchdogContext = nil;
    self->_lock_terminationRequest = nil;
    self->_lock_watchdogCPUStatistics = nil;
    self->_lock_rbsState = nil;
    self->_lock_state = nil;
    self->_lock_applicationInfo = nil;
    self->_lock_bootstrapBlocks = nil;
    self->_lock_launchCompletionBlocks = nil;
    self->_lock_gracefulExitAssertion = nil;
    self->_observerLock_observers = nil;
    self->_bootstrapError = nil;
    self->_description = nil;
    self->_handleDescription = nil;
    self->_identityDescription = nil;
    self->_executionContext = nil;
    self->_workspace = nil;
    self->_auditToken = nil;
    self->_executablePath = nil;
    self->_bundleIdentifier = nil;
    self->_rbsHandle = nil;
    self->_handle = nil;
    self->_identity = nil;
    self->_processManager = nil;
}


void -[FBProcess dealloc](void)
{
    if (!self->_lock_invalidated) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_lock_invalidated == YES"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBProcess.m", 237, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogProcess();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        Class v1 = [self class];
        id v2 = FBSProcessPrettyDescription(self);
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "<%{public}@:%{public}p %@> Dealloc", v1, self, v2);
    }
    [super dealloc];
}


FBProcessExitContext *-[FBProcess exitContext](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    FBProcessExitContext *v0 = self->_lock_exitContext;
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v0;
}


long -[FBProcess executableLivesOnSystemPartition](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    long v0 = self->_lock_executableLivesOnSystemPartition;
    if (self->_lock_executableLivesOnSystemPartition == 0x7fffffffffffffff) {
        if (!self->_executablePath) {
            v0 = 0x7fffffffffffffff;
        } else {
            v0 = BSSettingFlagForBool(BSPathExistsOnSystemPartition(self->_executablePath));
            self->_lock_executableLivesOnSystemPartition = v0;
        }
    }
    long v2 = BSSettingFlagIsYes(v0);
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v2;
}


id +[FBProcess _currentProcess](void)
{
    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    return [threadDictionary objectForKey:@"FBProcess"];
}


void -[FBProcess setWatchdogProvider:](id<FBProcessWatchdogProviding> a1)
{
    os_unfair_lock_lock(&self->_watchdogProviderLock);
    self->_watchdogProvider = a1;
    os_unfair_lock_unlock(&self->_watchdogProviderLock);
}


void -[FBProcess removeObserver:](id a1)
{
    if (a1 != nil) {
        os_unfair_lock_lock(&self->_observerLock);
        id v2 = [self->_observerLock_observers copy];
        for (id v7 in v2) {
            id observer = [v7 observer];
            if (!observer || observer == a1) {
                [self->_observerLock_observers removeObject:v7];
                [v7 invalidate];
            }
        }
        os_unfair_lock_unlock(&self->_observerLock);
    }
}


NSString *-[FBProcess name](void)
{
    return [self->_handle name];
}


long -[FBProcess add:](long a1)
{
    return [self addObserver:a1];
}


long -[FBProcess remove:](id a1)
{
    return [self removeObserver:a1];
}


long -[FBProcess valueForEntitlement:](long a1)
{
    return [self->_auditToken valueForEntitlement:a1];
}


long -[FBProcess taskState](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    long taskState = [self->_lock_state taskState];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return taskState;
}


long -[FBProcess visibility](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    long visibility = [self->_lock_state visibility];
    os_unfair_recursive_lock_unlock(&self->_lock);
    return visibility;
}


long -[FBProcess isPlatformBinary](void)
{
    long v3;
    uint8_t v2[32];
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_platformBinary == 0x7fffffffffffffff) {
        FBSApplicationInfo *applicationInfo = [self applicationInfo];
        if (!applicationInfo || [applicationInfo type] == 2) {
            if (!self->_rbsHandle) {
                _memset(v2, 0, 32);
            } else {
                [self->_rbsHandle auditToken:&v2];
            }
            v3 = BSSettingFlagForBool(BSAuditTokenRepresentsPlatformBinary(&v2));
        } else {
            v3 = BSSettingFlagForBool(1);
        }
        self->_lock_platformBinary = v3;
    }
    long v4 = BSSettingFlagIsYes(self->_lock_platformBinary);
    os_unfair_recursive_lock_unlock(&self->_lock);
    return v4;
}


void -[FBProcess _executeBlockAfterBootstrap:](void (^a1)(FBProcess *, NSError *))
{
    void (^v0)(FBProcess *, NSError *) = a1;
    if (a1 != nil) {
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        if (!self->_lock_bootstrapBlocks) {
            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
            dispatch_async(queue, ^void(void) {
                [self _executeBlockAsCurrentProcess:^void(void) {
                    if (!self->_rbsHandle) {
                        FBProcessExitContext *exitContext = [self exitContext];
                        NSError *createError = [exitContext createError];
                        v0(self, createError);
                        return;
                    }
                    v0(self, nil);
                }];
            });
        } else {
            void (^aBlock)(FBProcess *, NSError *) = [v0 copy];
            id v5 = _Block_copy(aBlock);
            [self->_lock_bootstrapBlocks addObject:v5];
        }
        os_unfair_recursive_lock_unlock(&self->_lock);
    }
}


long -[FBProcess _rebuildState](void)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (self->_lock_rbsState != nil) {
        [self _rebuildState:self->_lock_rbsState];
    }
    return os_unfair_recursive_lock_unlock(&self->_lock);
}


bool -[FBProcess allowsTerminatingOnWatchdogViolations](void)
{
    id _domain = [self->_workspace _domain];
    return [_domain allowsTerminatingOnWatchdogViolations];
}


bool -[FBProcess _shouldWatchdogWithDeclineReason:](NSString **a1)
{
    bool v3;
    long v0 = __getpid(self);
    if (self->_pid == v0) {
        v3 = false;
        *(a1) = @"current process can't be watchdogged";
        return v3;
    }
    if ([self isBeingDebugged]) {
        v3 = false;
        *(a1) = @"process is being debugged";
        return v3;
    }
    Boolean v1 = CFPreferencesGetAppBooleanValue(@"BKNoWatchdogs", kCFPreferencesCurrentApplication, NULL);
    bool checkForLeaks = [self->_executionContext checkForLeaks];
    if (checkForLeaks || v1) {
        v3 = false;
        *(a1) = @"override default is set";
    } else {
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        id tags = [self->_lock_rbsState tags];
        BOOL v6 = [tags containsObject:@"FBDisableWatchdog"];
        os_unfair_recursive_lock_unlock(&self->_lock);
        if (v6) {
            *(a1) = @"watchdog is disabled via RB assertion";
        }
        v3 = !v6;
    }
    return v3;
}


long -[FBProcess _watchdogReportType](void)
{
    dispatch_once(&_watchdogReportType.onceToken, ^void(void) {
        if (CFPreferencesGetAppBooleanValue(@"BKStackshotAppTimeout", kCFPreferencesCurrentApplication, NULL)) {
            _watchdogReportType.__StackshotOverride = true;
            return;
        }
        _watchdogReportType.__StackshotOverride = false;
    });
    if (!_watchdogReportType.__StackshotOverride) {
        return ([self isPlatformBinary]) ? 2 : 1;
    } else {
        return 2;
    }
}


void -[FBProcess _terminateWithRequest:completion:](id a1, void (^a2)(long))
{
    void (^v4)(long);
    void (^v1)(long) = a2;
    if (!a1) {
        NSString *v19 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"request != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(_cmd);
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBProcess.m", 1425, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    os_log_t oslog3 = FBLogProcess();
    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem = [self logProem];
        os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%{public}@ Received termination request: %{public}@", logProem, a1);
    }
    if ((self->_lock_launchFinalized != 1 || self->_lock_launchSuccess == 1) && self->_lock_didExit != 1) {
        if (!self->_rbsHandle) {
            NSString *v25 = [NSString stringWithFormat:@"cannot terminate a process before it has attempted bootstrapping"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v26 = NSStringFromSelector(_cmd);
                NSString *v27 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v26, v27, self, @"FBProcess.m", 1441, v25);
            }
            _bs_set_crash_log_message([v25 UTF8String]);
            __break(0);
        }
        if (v1 != nil) {
            NSMutableArray *v3 = self->_lock_terminateRequestCompletionBlocks;
            if (!self->_lock_terminateRequestCompletionBlocks) {
                v4 = [v1 copy];
                NSMutableArray<void (^)(long)> *v5 = [NSMutableArray arrayWithObject:v4];
                NSMutableArray *v6 = self->_lock_terminateRequestCompletionBlocks;
                self->_lock_terminateRequestCompletionBlocks = v5;
            } else {
                v4 = [v1 copy];
                void *v32 = _Block_copy(v4);
                [v3 addObject:v32];
            }
        }
        long exceptionCode = [a1 exceptionCode];
        if (self->_lock_terminationRequest != nil && (exceptionCode != 0x8badf00d || [self->_lock_terminationRequest exceptionCode] == 0x8badf00d)) {
            os_unfair_recursive_lock_unlock(&self->_lock);
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                NSString *logProem2 = [self logProem];
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Already terminating; ignoring additional termination request.", logProem2);
            }
            return;
        }
        FBSProcessTerminationRequest *v11 = [a1 copy];
        self->_lock_terminationRequest = v11;
        bool v18 = exceptionCode == 0x8badf00d || ([v11 options] & 1) == 0;
        if (!v18) {
            v18 = [self->_lock_state taskState] != 2;
            if (v18) {
                long options = [v11 options];
                [v11 setOptions:options & 0xfffffffffffffffe];
                [v11 setReportType:0];
            }
        }
        if (v18) {
            [self _lock_consumeLock_executeTerminationRequest];
        } else {
            [self _lock_consumeLock_performGracefulKill];
        }
        return;
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
    os_log_t oslog2 = FBLogProcess();
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem3 = [self logProem];
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%{public}@ Ignoring termination request because the process either failed to launch or already exited.", logProem3);
    }
    NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
    dispatch_async(queue, ^void(void) {
        if (!v1) {
            return;
        } else {
            v1(0);
            return;
        }
    });
}


void -[FBProcess _killForReason:andReport:withDescription:completion:](long a1, int a2, id a3, id a4)
{
    id v1 = a3;
    long v3 = __getpid();
    if (self->_pid == v3) {
        id v4 = FBSApplicationTerminationReasonDescription(a1);
        NSString *v5 = [NSString stringWithFormat:@"The current requested its own termination (for reason \"%@\" with description \"%@\")", v4, v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v12, self, @"FBProcess.m", 1482, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (!v1) {
        v1 = FBSApplicationTerminationReasonDescription(a1);
    }
    os_log_t oslog = FBLogProcess();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem = [self logProem];
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSString *processName = [processInfo processName];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ %{public}@ requested termination (\"%{public}@\")", logProem, processName, v1);
    }
    [self _notePendingExitForReason:@"explicit kill request from client"];
    if ((unsigned long)(a1 - 1) >= 9) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"fbReason != FBProcessKillReasonUnknown"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBProcess.m", 1505, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (!self->_terminationReason) {
        self->_terminationReason = a1;
    }
    id v10 = [FBSProcessTerminationRequest requestForProcess:self withLabel:v1];
    [v10 setReportType:(a2 != 0) ? (&qword_1c4f5d2b8)[a1 - 1] : 0];
    [v10 setExceptionCode:(&qword_1c4f5d300)[a1 - 1]];
    [v10 setExplanation:v1];
    long v11 = FBSApplicationTerminationReasonIsGraceful(a1);
    [v10 setOptions:v11];
    [self _terminateWithRequest:v10 completion:a4];
}


void -[FBProcess _lock_consumeLock_executeTerminationRequest](void)
{
    os_unfair_lock_assert_owner(&self->_lock);
    if (!self->_rbsHandle) {
        NSString *v48 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_rbsHandle != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v49 = NSStringFromSelector(_cmd);
            NSString *v50 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBProcess.m", 1552, v48);
        }
        _bs_set_crash_log_message([v48 UTF8String]);
        __break(0);
    }
    if (!self->_lock_terminationRequest) {
        NSString *v52 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_lock_terminationRequest != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v53 = NSStringFromSelector(_cmd);
            NSString *v54 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v53, v54, self, @"FBProcess.m", 1553, v52);
        }
        _bs_set_crash_log_message([v52 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogProcess([self _notePendingExitForReason:@"terminate with request"]);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem = [self logProem];
        FBSProcessTerminationRequest *v1 = self->_lock_terminationRequest;
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Executing termination request: %{public}@", logProem, v1);
    }
    long exceptionCode = [self->_lock_terminationRequest exceptionCode];
    FBSProcessTerminationRequest *v3 = self->_lock_terminationRequest;
    FBProcessWatchdogEventContext *v4 = self->_lock_terminationWatchdogContext;
    FBProcessCPUStatistics *v5 = self->_lock_watchdogCPUStatistics;
    FBSProcessExecutionProvision *v6 = self->_lock_latestViolatedProvision;
    id v7 = [self->_lock_state copy];
    os_unfair_recursive_lock_unlock(&self->_lock);
    NSMutableArray *array = [NSMutableArray array];
    id v9 = NSStringFromFBProcessVisibility([v7 visibility]);
    NSString *v10 = (!v9) ? nil : [NSString stringWithFormat:@"%@: %@", @"ProcessVisibility", v9];
    [array bs_safeAddObject:v10];
    id v11 = NSStringFromFBProcessTaskState([v7 taskState]);
    NSString *v12 = (!v11) ? nil : [NSString stringWithFormat:@"%@: %@", @"ProcessState", v11];
    [array bs_safeAddObject:v12];
    if (v4 != nil) {
        FBSSceneSettings *sceneSettings = [v4 sceneSettings];
        bool isForeground = [sceneSettings isForeground];
        id v15 = NSStringFromProcessWatchdogEvent([v4 event]);
        NSString *v16 = (!v15) ? nil : [NSString stringWithFormat:@"%@: %@", @"WatchdogEvent", v15];
        [array bs_safeAddObject:v16];
        NSString *v17 = [NSString stringWithFormat:@"%@: %@", @"WatchdogVisibility", (isForeground) ? @"Foreground" : @"Background"];
        [array bs_safeAddObject:v17];
        id descriptionForCrashReport = [v5 descriptionForCrashReport];
        NSString *v19 = (!descriptionForCrashReport) ? nil : [NSString stringWithFormat:@"%@: %@", @"WatchdogCPUStatistics", descriptionForCrashReport];
        [array bs_safeAddObject:v19];
        FBSceneUpdateContext *sceneUpdateContext = [v4 sceneUpdateContext];
        long isClientLifecycleExternallyManaged = [sceneUpdateContext isClientLifecycleExternallyManaged];
        if (isClientLifecycleExternallyManaged != 0) {
            NSString *v22 = [NSString stringWithFormat:@"%@: %@", @"LifecycleExternallyManaged", @"YES"];
            [array bs_safeAddObject:v22];
        }
        FBAnalyticsLogWatchdogEvent(self, v4, v6, v7);
    }
    long v23 = OSThermalNotificationCurrentLevel();
    NSString *v24 = [NSString stringWithFormat:@"Thermal Level:   %d", v23];
    NSArray<NSString *> *v26 = @[v24];
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSProcessInfoThermalState thermalState = [processInfo thermalState];
    if (thermalState <= NSProcessInfoThermalStateCritical) {
        NSString *anObject = [NSString stringWithFormat:@"Thermal State:   %@", (&qword_1e17d6410)[thermalState]];
        NSArray<NSString *> *v30 = [v26 arrayByAddingObject:anObject];
        v26 = v30;
    }
    if (exceptionCode == 0xc00010ff) {
        id v31 = GetThermalState();
        NSString *v32 = [v31 componentsJoinedByString:@" "];
        NSString *v35 = (!v32) ? @"failed to load sensor values" : v32;
        NSString *anObject2 = [NSString stringWithFormat:@"Thermal Sensors: %@", v35];
        NSArray<NSString *> *v37 = [v26 arrayByAddingObject:anObject2];
        v26 = v37;
    }
    NSString *v38 = (!v26) ? nil : [NSString stringWithFormat:@"%@: %@", @"ThermalInfo", v26];
    [array bs_safeAddObject:v38];
    id explanation = [v3 explanation];
    NSMutableString *v40 = [NSMutableString stringWithString:(!explanation) ? @"" : explanation];
    if ([array count] != 0) {
        [v40 appendString:@"\n\n"];
        NSString *aString = [array componentsJoinedByString:@"\n"];
        [v40 appendString:aString];
    }
    RBSTerminateContext *v42 = [[RBSTerminateContext alloc] initWithExplanation:v40];
    long reportType = [v3 reportType];
    [v42 setReportType:reportType];
    [v42 setExceptionDomain:10];
    [v42 setExceptionCode:exceptionCode];
    int v44 = BSPthreadCurrentEffectiveQualityOfService([v42 setMaximumTerminationResistance:40]);
    if ((unsigned int)v44 <= 25) {
        v44 = 25;
    }
    NSObject<OS_dispatch_workloop> *queue = [FBProcess userInitiatedWorkloop];
    dispatch_block_t block = BSDispatchBlockCreateWithQualityOfService(v44, 0, ^void(void) {
        id v58 = [RBSProcessPredicate predicateMatching:self->_rbsHandle];
        RBSTerminateRequest *v62 = [[RBSTerminateRequest alloc] initWithPredicate:v58 context:v42];
        id v63 = nil;
        long v64 = [v62 execute:&v63];
        id v65 = v63;
        if ((v64 & 1) == 0) {
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                NSString *logProem = [self logProem];
                id v60 = [v65 descriptionWithMultilinePrefix:0];
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ Termination failed with error: %{public}@", logProem, v60);
            }
            id v67 = [NSError bs_errorWithDomain:@"FBProcessTermination" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureDescription:@"Termination request failed"];
                [arg1 setFailureReason:@"RunningBoard returned an error"];
                [arg1 setCodeDescription:@"request-failed"];
                [arg1 setUnderlyingError:v65];
            }];
            [self _processDidExitWithContext:[[FBProcessExitContext alloc] initWithTerminationError:v67]];
        }
    });
    dispatch_async(queue, block);
}


void -[FBProcess _lock_consumeLock_performGracefulKill](void)
{
    double v12;
    bool v20;
    long v21;
    os_unfair_lock_assert_owner(&self->_lock);
    self->_lock_attemptedGracefulTermination = YES;
    [self _notePendingExitForReason:@"pending graceful exit"];
    FBSSceneTransitionContext *v0 = [[FBSSceneTransitionContext alloc] init];
    if ([self isApplicationProcess] != 0 && UIKitLibraryCore(0) != 0 && getUIApplicationSceneTransitionContextClass() != 0) {
        long v1 = UIKitLibraryCore(0);
        if (v1 != 0) {
            v1 = getUIApplicationSceneTransitionContextClass();
        }
        id v48 = [[v1 alloc] init];
        if (self->_terminationReason == 9) {
            id _uiApplicationSceneTransitionContextShim = [v48 _uiApplicationSceneTransitionContextShim];
            [_uiApplicationSceneTransitionContextShim setWaitForBackgroundTaskCompletion:1];
        }
        v0 = v48;
    }
    __weak id v3 = self;
    RBSProcessHandle *v4 = self->_rbsHandle;
    FBSProcessTerminationRequest *v5 = self->_lock_terminationRequest;
    FBSMutableSceneSettings *v6 = [[FBSMutableSceneSettings alloc] init];
    bool isForeground = [self isForeground];
    [v6 setForeground:isForeground];
    id v8 = [FBProcessWatchdogEventContext contextForEvent:4 settings:v6 transitionContext:v0];
    id _watchdogProvider = [self _watchdogProvider];
    id v10 = [_watchdogProvider watchdogPolicyForProcess:self eventContext:v8];
    FBProcessCPUStatistics *v11 = [[FBProcessCPUStatistics alloc] initWithProcessHandle:self->_rbsHandle];
    if (!v10) {
        v12 = 0.0;
    } else {
        id provisions = [v10 provisions];
        v12 = 0.0;
        for (id v19 in provisions) {
            if (![v19 isResourceProvision] || [v19 type] != 1) {
                continue;
            }
            if (v19 != nil) {
                [v19 allowance];
                v20 = v21;
            } else {
                v20 = false;
                v21 = 0;
            }
            v12 += FBSProcessResourceTimeIntervalForValue(v20);
        }
    }
    double v23 = (BSFloatIsZero() != 0) ? 5.0 : v12;
    os_log_t oslog = FBLogProcess();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *logProem = [self logProem];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Giving the process %.1fs to exit gracefully...", logProem, v23);
    }
    id v26 = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:@"GracefulTermination"];
    id v28 = objc_msgSend$attributeWithDuration:warningDuration:startPolicy:endPolicy:(RBSDurationAttribute, 1, 2, v23 + 1.0, 1.0);
    NSArray *v29 = @[v26, v28];
    id v30 = FBSApplicationTerminationReasonDescription(self->_terminationReason);
    NSString *v31 = [NSString stringWithFormat:@"FBProcess Graceful Termination: %@", v30];
    RBSAssertion *v32 = self->_lock_gracefulExitAssertion;
    RBSAssertion *v33 = [[RBSAssertion alloc] initWithExplanation:v31 target:self->_target attributes:v29];
    self->_lock_gracefulExitAssertion = v33;
    [v33 setExpirationWarningHandler:^void(RBSAssertion *arg1) {
        [arg1 invalidate];
        if (v3 != nil) {
            id logProem = [v3 logProem];
            NSString *v51 = [NSString stringWithFormat:@"%@ Failed to terminate gracefully after %.1fs", logProem, v23];
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@!", v51);
            }
            id v53 = [FBSProcessTerminationRequest requestForProcess:v3 withLabel:@"graceful termination failed"];
            long _watchdogReportType = [v3 _watchdogReportType];
            [v53 setReportType:_watchdogReportType];
            [v53 setExceptionCode:0x8badf00d];
            [v53 setExplanation:v51];
            os_unfair_recursive_lock_lock_with_options(&v3->_lock, 0);
            v3->_lock_terminationRequest = v53;
            v3->_lock_terminationWatchdogContext = v8;
            v3->_lock_watchdogCPUStatistics = v11;
            v3->_lock_latestViolatedProvision = [FBSProcessResourceProvision provisionWithResourceType:1 timeInterval:v23];
            if (v3->_lock_gracefulExitAssertion == arg1) {
                v3->_lock_gracefulExitAssertion = 0;
            }
            [v3 _lock_consumeLock_executeTerminationRequest];
        }
    }];
    [v33 setInvalidationHandler:^void(RBSAssertion *arg1, NSError *arg2) {
        if (v3 != nil) {
            os_unfair_recursive_lock_lock_with_options(&v3->_lock, 0);
            if (arg1 == v3->_lock_gracefulExitAssertion) {
                v3->_lock_gracefulExitAssertion = 0;
            }
            os_unfair_recursive_lock_unlock(&v3->_lock);
        }
    }];
    os_unfair_recursive_lock_unlock(&self->_lock);
    long exceptionCode = [v5 exceptionCode];
    id v41 = [RBSProcessExitStatus statusWithDomain:10 code:exceptionCode];
    [v4 intendToExitWith:v41];
    [self->_workspace _terminateGracefully:self withTransitionContext:v0];
    id v42 = nil;
    long v43 = [v33 acquireWithError:&v42];
    if ((v43 & 1) == 0) {
        os_log_t oslog2 = FBLogProcess();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
            NSString *logProem2 = [self logProem];
            id v47 = [v42 descriptionWithMultilinePrefix:0];
            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%{public}@ Failed to acquire graceful termination assertion: %{public}@", logProem2, v47);
        }
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        [self _lock_consumeLock_executeTerminationRequest];
    }
    [v32 invalidate];
}


long -[FBProcess taskNameRight](void)
{
    return 0;
}


void -[FBProcess _terminateWithRequest:forWatchdog:](id a1, id a2)
{
    os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
    if (!self->_lock_terminationWatchdogContext && [a2 isKindOfClass:[FBProcessWatchdog class]]) {
        self->_lock_terminationWatchdogContext = [a2 eventContext];
        self->_lock_watchdogCPUStatistics = [a2 cpuStatistics];
    }
    os_unfair_recursive_lock_unlock(&self->_lock);
    [self _terminateWithRequest:a1 completion:0];
    [a2 invalidate];
}


id -[FBProcess _watchdog:terminationRequestForError:](id a1, id a2)
{
    id v3;
    id v4;
    long v5;
    NSString *v11;
    id _watchdogProvider = [self _watchdogProvider];
    if (!_watchdogProvider || ![_watchdogProvider respondsToSelector:@selector(watchdogTerminationRequestForProcess:error:)]) {
        v3 = [FBSProcessTerminationRequest requestForProcess:self withLabel:@"watchdog provision violated"];
        v4 = v3;
        v5 = [self _watchdogReportType];
        [v3 setReportType:v5];
    } else {
        v4 = [_watchdogProvider watchdogTerminationRequestForProcess:self error:a2];
        if (!v4) {
            v3 = [FBSProcessTerminationRequest requestForProcess:self withLabel:@"watchdog provision violated"];
            v4 = v3;
            v5 = [self _watchdogReportType];
            [v3 setReportType:v5];
        }
    }
    NSString *name = [a1 name];
    NSString *localizedFailureReason = [a2 localizedFailureReason];
    if (!localizedFailureReason) {
        NSString *localizedDescription = [a2 localizedDescription];
        v11 = [NSString stringWithFormat:@"%@ watchdog transgression: %@", name, localizedDescription];
    } else {
        v11 = [NSString stringWithFormat:@"%@ watchdog transgression: %@", name, localizedFailureReason];
    }
    id explanation = [v4 explanation];
    NSString *v13 = (!explanation) ? v11 : [NSString stringWithFormat:@"%@; %@", v11, explanation];
    [v4 setExplanation:v13];
    [v4 setExceptionCode:0x8badf00d];
    return v4;
}


long -[FBProcess _watchdog:shouldTerminateWithDeclineReason:](id a1, long *a2)
{
    long v1 = [self _shouldWatchdogWithDeclineReason:a2];
    if ((v1 & 1) == 0) {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *logProem = [self logProem];
            id v4 = [BSDescriptionBuilder succinctDescriptionForObject:a1];
            id v2 = *(a2);
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Ignoring %{public}@ for reason: %{public}@", logProem, v4, v2);
        }
        os_unfair_recursive_lock_lock_with_options(&self->_lock, 0);
        [self->_lock_exitTimer invalidate];
        self->_lock_exitTimer = nil;
        os_unfair_recursive_lock_unlock(&self->_lock);
    }
    return v1;
}


BOOL -[FBProcess matchesProcess:](id a1)
{
    int pid = [a1 pid];
    if ((!self->_pid || self->_pid < 0) && pid < 1) {
        id identity = [a1 identity];
        return [self->_identity isEqual:identity];
    }
    return self->_pid == pid;
}


NSString *-[FBProcess executablePath](void)
{
    return self->_executablePath;
}


BSAuditToken *-[FBProcess auditToken](void)
{
    return self->_auditToken;
}


long -[FBProcess(FBApplicationProcess) isSystemApplicationProcess](void)
{
    return [self isCurrentProcess];
}


void -[FBProcess init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-[FBProcess init] is not supported"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcess.m", 166, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
