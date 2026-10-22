struct FBSystemShell {
    FBSystemShellInitializationContext *_initializationContext; // +0x8
    unsigned long _state; // +0x10
    RBSAssertion *_runningAssertion; // +0x18
    BKSSystemShellService *_systemShellService; // +0x20
    struct os_unfair_lock_s _lock; // +0x28
    RBSAssertion *_lock_preventSleepAssertion; // +0x30
    NSMutableSet *_lock_preventIdleSleepReasons; // +0x38
    NSMutableArray *_lock_blocksToRunWhenReady; // +0x40
    BSCompoundAssertion *_lock_temporaryWatchdogAssertion; // +0x48
};

static FBSystemShell *__instance;
static long FBAssertionDomain;

FBSystemShell *+[FBSystemShell sharedInstance](void)
{
    return __instance;
}


void -[FBSystemShell _setSystemIdleSleepDisabled:forReason:](int a1, id a2)
{
    uint8_t v5;
    Class v2 = NSClassFromString(@"NSString");
    if (!a2) {
        NSString *v21 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSStringFromSelector(_cmd);
            NSString *v23 = NSStringFromClass([self class]);
            void *dso = OUTLINED_FUNCTION_2(v23, 6.8450148e-316);
            _os_log_error_impl(dso, dso.word1, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", &v5, 58);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v2]) {
        NSString *v25 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSStringFromSelector(_cmd);
            NSString *v27 = NSStringFromClass([self class]);
            void *v24 = OUTLINED_FUNCTION_2(v27, 6.8450148e-316);
            _os_log_error_impl(v24, v24.word1, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", &v5, 58);
        }
        _bs_set_crash_log_message([v25 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    BOOL v3 = [self->_lock_preventIdleSleepReasons containsObject:a2];
    if (a1) {
        if (!v3) {
            os_log_t oslog4 = FBLogCommon();
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_INFO, "Preventing system idle sleep for reason: %{public}@", a2);
            }
            [self->_lock_preventIdleSleepReasons addObject:a2];
        }
    } else if (v3) {
        os_log_t oslog3 = FBLogCommon();
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "Allowing system idle sleep for reason: %{public}@", a2);
        }
        [self->_lock_preventIdleSleepReasons removeObject:a2];
    }
    os_log_t oslog5 = FBLogCommon();
    if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
        id v8 = (![self->_lock_preventIdleSleepReasons count]) ? @"(none)" : self->_lock_preventIdleSleepReasons;
        os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "Prevent idle sleep reasons: %{public}@", v8);
    }
    if ([self->_lock_preventIdleSleepReasons count]) {
        if (!self->_lock_preventSleepAssertion) {
            os_log_t oslog2 = FBLogCommon();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Now preventing system idle sleep.");
            }
            RBSAssertion *v14 = [RBSAssertion alloc];
            id currentProcess = [RBSTarget currentProcess];
            id v16 = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:@"SystemShell-PreventIdleSleep"];
            NSArray *v18 = @[v16];
            self->_lock_preventSleepAssertion = [v14 initWithExplanation:@"FBSystemApp-PreventIdleSleep" target:currentProcess attributes:v18];
            [self->_lock_preventSleepAssertion acquireWithError:0];
        }
    } else if (self->_lock_preventSleepAssertion != nil) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Now allowing system idle sleep.");
        }
        [self->_lock_preventSleepAssertion invalidate];
        self->_lock_preventSleepAssertion = nil;
    }
    os_unfair_lock_unlock(&self->_lock);
}


FBSystemShell *-[FBSystemShell _initWithOptions:](id a1)
{
    id v0 = a1;
    FBSystemShell *v2 = [super init];
    if (v2 != nil) {
        v2->_lock._os_unfair_lock_opaque = 0;
        v2->_lock_preventIdleSleepReasons = [NSMutableSet set];
        v2->_lock_blocksToRunWhenReady = [[NSMutableArray alloc] init];
        v2->_initializationContext = [[FBSystemShellInitializationContext alloc] _initWithOptions:[v0 copy]];
        [v2 _setSystemIdleSleepDisabled:1 forReason:@"FBSystemShellStartup"];
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Taking out the system app's process assertion.");
        }
        kdebug_trace(0x2b850050, 0, 0, 0, 0);
        RBSAssertion *v13 = [RBSAssertion alloc];
        id currentProcess = [RBSTarget currentProcess];
        id v15 = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:@"SystemShell"];
        NSArray *v17 = @[v15];
        v2->_runningAssertion = [v13 initWithExplanation:@"FBSystemShell" target:currentProcess attributes:v17];
        [v2->_runningAssertion acquireWithError:0];
        kdebug_trace(0x2b850054, 0, 0, 0, 0);
        kdebug_trace(0x2b850048, 0, 0, 0, 0);
        v2->_systemShellService = [[BKSSystemShellService alloc] initWithConfigurator:^void(id<BKSSystemShellServiceConfiguration> arg1) {
            bool shouldWaitForMigrator = [v0 shouldWaitForMigrator];
            [arg1 setWaitForDataMigration:shouldWaitForMigrator];
            double systemSleepInterval = [v0 systemSleepInterval];
            [arg1 setIdleSleepInterval:systemSleepInterval];
            NSString *independentWatchdogPortName = [v0 independentWatchdogPortName];
            if (independentWatchdogPortName != nil) {
                [arg1 setCollectiveWatchdogPingBlock:0];
            }
        }];
        kdebug_trace(0x2b85004c, 0, 0, 0, 0);
        __block FBSystemShell *v25 = v2;
        [v2 _addBlockToExecuteWhenReady:^void(void) {
            NSString *independentWatchdogPortName = [v0 independentWatchdogPortName];
            if (independentWatchdogPortName != nil) {
                wd_endpoint_register([independentWatchdogPortName UTF8String]);
                wd_endpoint_add_queue(dispatch_get_main_queue());
                id sharedInstanceIfExists = [FBSystemService sharedInstanceIfExists];
                id _applicationInfoProvider = [sharedInstanceIfExists _applicationInfoProvider];
                if ([_applicationInfoProvider isKindOfClass:[FBSApplicationLibrary class]]) {
                    id _synchronizationQueue = [_applicationInfoProvider _synchronizationQueue];
                    if (_synchronizationQueue != 0) {
                        wd_endpoint_add_queue(_synchronizationQueue);
                    }
                }
                wd_endpoint_activate();
            }
            [v25 _setSystemIdleSleepDisabled:0 forReason:@"FBSystemShellStartup"];
        }];
    }
    return v2;
}


FBSystemShell *+[FBSystemShell _createSingletonWithOptions:](id a1)
{
    if (__instance != nil) {
        NSString *v5 = [NSString stringWithFormat:@"Cannot create multiple FBSystemShell instances."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSystemShell.m", 130, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    dispatch_once(&_createSingletonWithOptions:.onceToken, ^void(void) {
        __instance = [[FBSystemShell alloc] _initWithOptions:a1];
    });
    return __instance;
}


long -[FBSystemShell readyForInteraction](void)
{
    return [self _setState:2];
}


void -[FBSystemShell sendActionsToBackBoard:](id a1)
{
    for (id v8 in a1) {
        if ([v8 isKindOfClass:[BKSRestartAction class]]) {
            BKSRestartAction *v6 = v8;
            long options = [v6 options];
            [self->_systemShellService restartWithOptions:options];
        }
    }
}


id -[FBSystemShell assertWatchdogEnabledForLimitedDurationForReason:](id a1)
{
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_temporaryWatchdogAssertion) {
        __weak FBSystemShell *v1 = self;
        self->_lock_temporaryWatchdogAssertion = [BSCompoundAssertion assertionWithIdentifier:@"FBSystemShell temporary watchdog" stateDidChangeHandler:^void(id<BSCompoundAssertionState> arg1) {
            if (v1 != nil) {
                BOOL isActive = [arg1 isActive];
                [v1->_systemShellService setIndependentWatchdogEnabled:isActive];
            }
        }];
    }
    os_unfair_lock_unlock(&self->_lock);
    return [self->_lock_temporaryWatchdogAssertion acquireForReason:a1];
}


long -[FBSystemShell _initializationComplete](void)
{
    return [self _setState:1];
}


void -[FBSystemShell _addBlockToExecuteWhenReady:](void (^a1)(void))
{
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_blocksToRunWhenReady) {
        os_unfair_lock_unlock(&self->_lock);
        a1();
    } else {
        void (^v2)(void) = _Block_copy(a1);
        [self->_lock_blocksToRunWhenReady addObject:v2];
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBSystemShell _startSystemShellService](void)
{
    [self->_systemShellService start];
}


long -[FBSystemShell _informSystemShellServiceDidFinishLaunching](void)
{
    return [self->_systemShellService didFinishLaunching];
}


long -[FBSystemShell description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSystemShell succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSystemShell succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    long v1 = NSStringFromFBSystemShellState(self->_state);
    [v0 appendObject:v1 withName:@"state"];
    return v0;
}


id -[FBSystemShell descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBSystemShell descriptionBuilderWithMultilinePrefix:](long a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendObject:self->_initializationContext withName:@"initializationContext" skipIfNil:1];
    return succinctDescriptionBuilder;
}


id -[FBSystemShell _setState:](long a1)
{
    unsigned long v1 = self->_state;
    if (self->_state != a1) {
        if (a1 != 1) {
            if (a1 != 2) {
                NSString *v10 = [NSString stringWithFormat:@"Cannot set to state: uninitialized."];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v0 = NSStringFromSelector(_cmd);
                    NSString *v11 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v11, self, @"FBSystemShell.m", 289, v10);
                }
                _bs_set_crash_log_message([v10 UTF8String]);
                __break(0);
            }
            if (v1 != 1) {
                NSString *v13 = [NSString stringWithFormat:@"Cannot move FBSystemShell to `Ready` unless we're `Initialized`."];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v14 = NSStringFromSelector(_cmd);
                    NSString *v15 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBSystemShell.m", 298, v13);
                }
                _bs_set_crash_log_message([v13 UTF8String]);
                __break(0);
            }
            self->_state = 2;
            os_unfair_lock_lock(&self->_lock);
            id v2 = [self->_lock_blocksToRunWhenReady copy];
            self->_lock_blocksToRunWhenReady = nil;
            os_unfair_lock_unlock(&self->_lock);
            for (id v9 in v2) {
                v9->field_16(v9);
            }
            return nil;
        }
        if (v1 != 0) {
            NSString *v16 = [NSString stringWithFormat:@"Cannot move FBSystemShell to `Initialized` unless we're `Uninitialized`."];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v17 = NSStringFromSelector(_cmd);
                NSString *v18 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBSystemShell.m", 293, v16);
            }
            _bs_set_crash_log_message([v16 UTF8String]);
            __break(0);
        }
        self->_state = 1;
    }
    return self;
}


FBSystemShellInitializationContext *-[FBSystemShell initializationContext](void)
{
    return self->_initializationContext;
}


unsigned long -[FBSystemShell _state](void)
{
    return self->_state;
}


void -[FBSystemShell .cxx_destruct](void)
{
    self->_lock_temporaryWatchdogAssertion = nil;
    self->_lock_blocksToRunWhenReady = nil;
    self->_lock_preventIdleSleepReasons = nil;
    self->_lock_preventSleepAssertion = nil;
    self->_systemShellService = nil;
    self->_runningAssertion = nil;
    self->_initializationContext = nil;
}
