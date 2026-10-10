struct FBApplicationProcessLaunchTransaction {
    FBProcessManager *_processManager; // +0x98
    RBSProcessIdentity *_identity; // +0xa0
    FBProcess *_process; // +0xa8
    id _executionContextProvider; // +0xb0
    FBWaitForProcessDeathTransaction *_deathTransaction; // +0xb8
    FBProcessExecutionContext *_executionContext; // +0xc0
    BSAtomicSignal *_interruptedOrComplete; // +0xc8
};

struct objc_super {
    id receiver; // +0x0
    Class super_class; // +0x8
};

void -[FBApplicationProcessLaunchTransaction .cxx_destruct](void)
{
    self->_interruptedOrComplete = nil;
    self->_executionContext = nil;
    self->_deathTransaction = nil;
    self->_executionContextProvider = nil;
    self->_process = nil;
    self->_identity = nil;
    self->_processManager = nil;
}


FBApplicationProcessLaunchTransaction *-[FBApplicationProcessLaunchTransaction initWithProcessIdentity:executionContextProvider:](id a1, id a2)
{
    if (!a1) {
        NSString *v16 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"identity"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v17, self, @"FBApplicationProcessLaunchTransaction.m", 62, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    FBApplicationProcessLaunchTransaction *v3 = [super init];
    if (v3 != nil) {
        v3->_processManager = [FBProcessManager sharedInstance];
        v3->_identity = [a1 copy];
        v3->_executionContextProvider = [a2 copy];
        v3->_interruptedOrComplete = [BSAtomicSignal new];
    }
    return v3;
}


void -[FBApplicationProcessLaunchTransaction _begin](void)
{
    id v0 = [self->_processManager processForIdentity:self->_identity];
    [self addMilestone:@"processWillBeginLaunching"];
    if (![v0 isPendingExit]) {
        [self _queue_launchProcess:v0];
    } else {
        if ([self isAuditHistoryEnabled] != 0) {
            [self _addAuditHistoryItem:@"Process is pending exit. Waiting for it to die..."];
        }
        id v2 = self->_executionContextProvider;
        if (self->_executionContextProvider != nil) {
            self->_executionContext = v2->field_16(v2);
            self->_executionContextProvider = nil;
        }
        self->_deathTransaction = [[FBWaitForProcessDeathTransaction alloc] initWithProcess:v0];
        [self addChildTransaction:self->_deathTransaction];
    }
    [super _begin];
}


void -[FBApplicationProcessLaunchTransaction _queue_processWillLaunch:](FBProcess *a1)
{
    if (self->_process != nil) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_process == ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBApplicationProcessLaunchTransaction.m", 242, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (!a1) {
        [self _failWithReason:@"process launch failed" description:@"Unable to create process."];
    } else {
        self->_process = a1;
        [self addMilestone:@"processDidFinishLaunching"];
        [a1 _executeBlockAsCurrentProcess:^void(void) {
            [self _enumerateObserversWithBlock:^void(id<BSTransactionObserver> arg1) {
                if ([arg1 respondsToSelector:@selector(transaction:willLaunchProcess:)]) {
                    void *v8 = self;
                    [arg1 transaction:v8 willLaunchProcess:self->_process];
                }
            }];
        }];
        [self satisfyMilestone:@"processWillBeginLaunching"];
    }
}


void -[FBApplicationProcessLaunchTransaction _queue_finishProcessLaunch:](long a1)
{
    if ([self->_interruptedOrComplete hasBeenSignalled] != 0) {
        if (![self isAuditHistoryEnabled]) {
            return;
        }
        [self _addAuditHistoryItem:@"Ignoring launched process since we were already interrupted or completed."];
        return;
    }
    if (a1 != 0) {
        [self _enumerateObserversWithBlock:^void(id<BSTransactionObserver> arg1) {
            if ([arg1 respondsToSelector:@selector(transaction:didLaunchProcess:)]) {
                void *v4 = self;
                [arg1 transaction:v4 didLaunchProcess:self->_process];
            }
        }];
        [self satisfyMilestone:@"processDidFinishLaunching"];
        return;
    }
    FBProcessExitContext *exitContext = [self->_process exitContext];
    id createError = [exitContext createError];
    [self _failWithReason:@"process launch failed" description:@"Process failed to launch." precipitatingError:createError];
}


long -[FBApplicationProcessLaunchTransaction _didComplete](void)
{
    [self->_interruptedOrComplete signal];
    self->_executionContextProvider = nil;
    return [super _didComplete];
}


FBProcess *-[FBApplicationProcessLaunchTransaction process](void)
{
    return self->_process;
}


void -[FBApplicationProcessLaunchTransaction _queue_launchProcess:](id a1)
{
    long *v15;
    if (self->_process != nil) {
        NSString *v17 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_process == ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v18, self, @"FBApplicationProcessLaunchTransaction.m", 191, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    if (a1 != nil) {
        [self _queue_processWillLaunch:a1];
        if (![a1 finishedLaunching]) {
            [a1 _executeBlockAfterLaunchCompletes:^void(bool arg1) {
                BSServiceDispatchQueue *queue = [self queue];
                dispatch_async(queue, ^void(void) {
                    [self _queue_finishProcessLaunch:arg1];
                });
            }];
            self->_executionContext = nil;
        } else {
            [self _queue_finishProcessLaunch:1];
            self->_executionContext = nil;
        }
        v15 = &self->_executionContextProvider;
        *(v15) = 0;
        return;
    }
    FBProcessExecutionContext *v6 = self->_executionContext;
    if (!self->_executionContext) {
        id v7 = self->_executionContextProvider;
        if (!self->_executionContextProvider) {
            v6 = [[FBProcessExecutionContext alloc] init];
        } else {
            id v8 = v7->field_16(v7);
            v6 = [v8 copy];
            if (!v6) {
                v6 = [[FBProcessExecutionContext alloc] init];
            }
        }
    }
    [v6 setIdentity:self->_identity];
    void (^completion)(FBProcess *, NSError *) = [v6 completion];
    [v6 setCompletion:^void(FBProcess *arg1, NSError *arg2) {
        FBProcess *v24 = arg1;
        if (([self->_interruptedOrComplete hasBeenSignalled] & 1) == 0) {
            BSServiceDispatchQueue *queue = [self queue];
            dispatch_async(queue, ^void(void) {
                [self _queue_processWillLaunch:v24];
            });
            [v24 _executeBlockAfterLaunchCompletes:^void(bool arg1) {
                BSServiceDispatchQueue *queue = [self queue];
                dispatch_async(queue, ^void(void) {
                    [self _queue_finishProcessLaunch:arg1];
                });
            }];
        }
        if (completion != nil) {
            completion(v24, arg2);
        }
    }];
    if (![self->_processManager _createProcessFutureWithExecutionContext:v6 error:0]) {
        NSString *v19 = [NSString stringWithFormat:@"legacy transaction does not support launching process identity: %@", self->_identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(_cmd);
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBApplicationProcessLaunchTransaction.m", 234, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    self->_executionContext = nil;
    v15 = &self->_executionContextProvider;
    *(v15) = 0;
}


long -[FBApplicationProcessLaunchTransaction _willComplete](void)
{
    [super _willComplete];
    return [self->_interruptedOrComplete signal];
}


FBApplicationProcessLaunchTransaction *-[FBApplicationProcessLaunchTransaction initWithApplicationProcess:](id a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"process"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBApplicationProcessLaunchTransaction.m", 52, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return [self initWithProcessIdentity:[a1 identity] executionContextProvider:0];
}


FBApplicationProcessLaunchTransaction *-[FBApplicationProcessLaunchTransaction initWithApplicationBundleID:executionContextProvider:](id a1, id a2)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"bundleID"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBApplicationProcessLaunchTransaction.m", 57, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return [self initWithProcessIdentity:[RBSProcessIdentity identityForEmbeddedApplicationIdentifier:a1] executionContextProvider:a2];
}


long -[FBApplicationProcessLaunchTransaction addObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBApplicationProcessLaunchTransaction removeObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


long -[FBApplicationProcessLaunchTransaction add:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBApplicationProcessLaunchTransaction remove:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


bool -[FBApplicationProcessLaunchTransaction failedLaunch](void)
{
    return [self->_process pid] < 1;
}


int -[FBApplicationProcessLaunchTransaction exited](void)
{
    return ![self->_process isRunning];
}


int -[FBApplicationProcessLaunchTransaction _canBeInterrupted](void)
{
    return 1;
}


long -[FBApplicationProcessLaunchTransaction _willInterruptWithReason:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    objc_msgSendSuper2(&v0, @selector(_willInterruptWithReason:));
    return [self->_interruptedOrComplete signal];
}


long -[FBApplicationProcessLaunchTransaction _willFailWithReason:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationProcessLaunchTransaction;
    objc_msgSendSuper2(&v0, @selector(_willFailWithReason:));
    return [self->_interruptedOrComplete signal];
}


void -[FBApplicationProcessLaunchTransaction _childTransactionDidComplete:](id a1)
{
    if (a1 == self->_deathTransaction) {
        if (([a1 isFailed] & 1) == 0 && ([a1 isInterrupted] & 1) == 0) {
            if ([self isAuditHistoryEnabled] != 0) {
                [self _addAuditHistoryItem:@"Process officially exited. Attempting relaunch..."];
            }
            [self _queue_launchProcess:0];
        }
        self->_deathTransaction = nil;
    }
    [super _childTransactionDidComplete:a1];
}


bool -[FBApplicationProcessLaunchTransaction _shouldFailForChildTransaction:](long a1)
{
    return a1 == self->_deathTransaction;
}


NSMutableDictionary *-[FBApplicationProcessLaunchTransaction _customizedDescriptionProperties](void)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    FBProcess *v1 = self->_process;
    if (!self->_process) {
        v1 = @"(none)";
    }
    [dictionary setObject:v1 forKey:@"Process"];
    return dictionary;
}


long -[FBApplicationProcessLaunchTransaction _queue_noteExited](void)
{
    long isComplete = [self isComplete];
    if ((isComplete & 1) == 0) {
        return [self _failWithReason:@"process launch failed" description:@"Process exited"];
    } else {
        return isComplete;
    }
}


void -[FBApplicationProcessLaunchTransaction init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed on FBApplicationProcessLaunchTransaction"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBApplicationProcessLaunchTransaction.m", 47, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
