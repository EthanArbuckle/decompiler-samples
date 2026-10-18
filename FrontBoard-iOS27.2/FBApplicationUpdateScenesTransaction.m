struct FBApplicationUpdateScenesTransaction {
    FBSSceneClientIdentity *_clientIdentity; // +0xc0
    FBApplicationProcessLaunchTransaction *_processLaunchTransaction; // +0xc8
    bool _hasScheduledProcessLaunch; // +0xd0
    bool _processLaunched; // +0xd1
    bool _waitsForSceneCommits; // +0xd2
    NSMutableArray *_updateSceneTransactions; // +0xd8
    NSMutableArray *_pendingUpdateTransactions; // +0xe0
};

struct objc_super {
    id receiver; // +0x0
    Class super_class; // +0x8
};

FBApplicationUpdateScenesTransaction *-[FBApplicationUpdateScenesTransaction initWithApplicationBundleID:executionContextProvider:](id a1, id a2)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"bundleID"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBApplicationUpdateScenesTransaction.m", 55, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return [self initWithProcessIdentity:[RBSProcessIdentity identityForEmbeddedApplicationIdentifier:a1] executionContextProvider:a2];
}


FBApplicationUpdateScenesTransaction *-[FBApplicationUpdateScenesTransaction initWithClientIdentity:executionContextProvider:](id a1, id a2, long a3)
{
    id v1 = a2;
    if (!a1) {
        NSString *v24 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"clientIdentity"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v25 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v25, self, @"FBApplicationUpdateScenesTransaction.m", 61, v24);
        }
        _bs_set_crash_log_message([v24 UTF8String]);
        __break(0);
    }
    FBApplicationUpdateScenesTransaction *v3 = [super init];
    if (!v3) {
        return v3;
    }
    v3->_clientIdentity = [a1 copy];
    v3->_waitsForSceneCommits = YES;
    v3->_updateSceneTransactions = [[NSMutableArray alloc] init];
    v3->_pendingUpdateTransactions = [[NSMutableArray alloc] init];
    RBSProcessIdentity *processIdentity = [a1 processIdentity];
    if (!processIdentity) {
        NSString *v27 = [NSString stringWithFormat:@"must be a process identity based client identity"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v28 = NSStringFromSelector(_cmd);
            NSString *v29 = NSStringFromClass([v3 class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v28, v29, v3, @"FBApplicationUpdateScenesTransaction.m", 69, v27);
        }
        _bs_set_crash_log_message([v27 UTF8String]);
        __break(0);
    }
    __weak FBApplicationUpdateScenesTransaction *v15 = v3;
    v3->_processLaunchTransaction = [[FBApplicationProcessLaunchTransaction alloc] initWithProcessIdentity:processIdentity executionContextProvider:^FBProcessExecutionContext *(void) {
        FBMutableProcessExecutionContext *v34;
        NSMutableArray *v32 = (!v15) ? nil : v15->_pendingUpdateTransactions;
        if (!v1) {
            v34 = [[FBMutableProcessExecutionContext alloc] initWithIdentity:processIdentity];
        } else {
            v34 = v1->field_16(v1);
            if (!v34) {
                v34 = [[FBMutableProcessExecutionContext alloc] initWithIdentity:processIdentity];
            }
        }
        id firstObject = [v32 firstObject];
        FBSSceneSettings *settings = [firstObject settings];
        return [v34 copyOrUpdateForSceneActivationWithSettings:settings];
    }];
    return v3;
}


FBApplicationUpdateScenesTransaction *-[FBApplicationUpdateScenesTransaction initWithProcessIdentity:executionContextProvider:](long a1, id a2)
{
    return [self initWithClientIdentity:[FBSSceneClientIdentity identityForProcessIdentity:a1] executionContextProvider:a2];
}


id -[FBApplicationUpdateScenesTransaction bundleID](void)
{
    id processIdentity = [self->_clientIdentity processIdentity];
    return [processIdentity embeddedApplicationIdentifier];
}


void -[FBApplicationUpdateScenesTransaction setWaitsForSceneCommits:](bool a1)
{
    self->_waitsForSceneCommits = a1;
    for (FBUpdateSceneTransaction *v2 in self->_updateSceneTransactions) {
        [v2 setWaitsForSceneCommit:self->_waitsForSceneCommits];
    }
}


FBProcess *-[FBApplicationUpdateScenesTransaction process](void)
{
    dispatch_queue_t queue = [self queue];
    dispatch_assert_queue(queue);
    return [self->_processLaunchTransaction process];
}


void -[FBApplicationUpdateScenesTransaction updateSceneWithIdentifier:parameters:transitionContext:](long a1, id a2, id a3)
{
    id v2 = [FBSSceneIdentity identityForIdentifier:a1];
    [self _updateSceneWithIdentity:v2 parameters:a2 transitionContext:a3];
}


long -[FBApplicationUpdateScenesTransaction updateSceneWithIdentity:parameters:transitionContext:](long a1, long a2, long a3)
{
    return [self _updateSceneWithIdentity:a1 parameters:a2 transitionContext:a3];
}


void -[FBApplicationUpdateScenesTransaction _updateSceneWithIdentity:parameters:transitionContext:](RBSProcessIdentity *a1, id a2, id a3)
{
    Class v3 = NSClassFromString(@"FBSSceneParameters");
    if (!a2) {
        NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBApplicationUpdateScenesTransaction.m", 127, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v3]) {
        NSString *v14 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneParametersClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v15 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBApplicationUpdateScenesTransaction.m", 127, v14);
        }
        _bs_set_crash_log_message([v14 UTF8String]);
        __break(0);
    }
    FBSSceneSpecification *specification = [a2 specification];
    Class v5 = NSClassFromString(@"FBSSceneSpecification");
    if (!specification) {
        NSString *v18 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBApplicationUpdateScenesTransaction.m", 128, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    if (![specification isKindOfClass:v5]) {
        NSString *v22 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSpecificationClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v23 = NSStringFromSelector(_cmd);
            NSString *v24 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBApplicationUpdateScenesTransaction.m", 128, v22);
        }
        _bs_set_crash_log_message([v22 UTF8String]);
        __break(0);
    }
    if (![self isRunning] && ([self isComplete] & 1) == 0) {
        dispatch_queue_t queue = [self queue];
        dispatch_assert_queue(queue);
        id definition = [FBSMutableSceneDefinition definition];
        [definition setIdentity:a1];
        [definition setClientIdentity:self->_clientIdentity];
        FBSSceneSpecification *specification2 = [a2 specification];
        [definition setSpecification:specification2];
        FBUpdateSceneTransaction *v9 = [[FBUpdateSceneTransaction alloc] initWithSceneDefinition:definition parameters:a2 transitionContext:a3];
        [self->_pendingUpdateTransactions addObject:v9];
        [self _executeSceneUpdatesIfAppropriate];
    }
}


long -[FBApplicationUpdateScenesTransaction addObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBApplicationUpdateScenesTransaction removeObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


long -[FBApplicationUpdateScenesTransaction add:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBApplicationUpdateScenesTransaction remove:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


long -[FBApplicationUpdateScenesTransaction _willBegin](void)
{
    [super _willBegin];
    return [self _executeProcessLaunchIfAppropriate];
}


void -[FBApplicationUpdateScenesTransaction _willAddChildTransaction:](id a1)
{
    [super _willAddChildTransaction:a1];
    if ([a1 isKindOfClass:[FBUpdateSceneTransaction class]]) {
        [self->_updateSceneTransactions addObject:a1];
    }
}


void -[FBApplicationUpdateScenesTransaction _didRemoveChildTransaction:](id a1)
{
    [super _didRemoveChildTransaction:a1];
    if ([a1 isKindOfClass:[FBUpdateSceneTransaction class]]) {
        [a1 removeObserver:self];
        [self->_updateSceneTransactions removeObject:a1];
    }
}


BOOL -[FBApplicationUpdateScenesTransaction _shouldFailForChildTransaction:](id a1)
{
    if (a1 == self->_processLaunchTransaction) {
        return YES;
    }
    return [a1 isKindOfClass:[FBUpdateSceneTransaction class]];
}


int -[FBApplicationUpdateScenesTransaction _canBeInterrupted](void)
{
    return 1;
}


void -[FBApplicationUpdateScenesTransaction _willInterruptWithReason:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    objc_msgSendSuper2(&v0, @selector(_willInterruptWithReason:));
    for (FBUpdateSceneTransaction *v2 in self->_updateSceneTransactions) {
        [v2 setWaitsForSceneCommit:NO];
    }
}


void -[FBApplicationUpdateScenesTransaction _willFailWithReason:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    objc_msgSendSuper2(&v0, @selector(_willFailWithReason:));
    for (FBUpdateSceneTransaction *v2 in self->_updateSceneTransactions) {
        [v2 setWaitsForSceneCommit:NO];
    }
}


long -[FBApplicationUpdateScenesTransaction _didComplete](void)
{
    [self->_processLaunchTransaction removeObserver:self];
    [self->_pendingUpdateTransactions removeAllObjects];
    for (NSNotificationCenter *v1 in self->_updateSceneTransactions) {
        [v1 removeObserver:self];
    }
    return [super _didComplete];
}


NSMutableDictionary *-[FBApplicationUpdateScenesTransaction _customizedDescriptionProperties](void)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self->_clientIdentity forKey:@"ClientIdentity"];
    id v1 = NSStringFromBOOL(self->_waitsForSceneCommits);
    [dictionary setObject:v1 forKey:@"Waits for scene commits"];
    return dictionary;
}


long -[FBApplicationUpdateScenesTransaction _childTransactionDidComplete:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    objc_msgSendSuper2(&v0, @selector(_childTransactionDidComplete:));
    return [self _executeProcessLaunchIfAppropriate];
}


long -[FBApplicationUpdateScenesTransaction _childTransactionDidFinishWork:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    objc_msgSendSuper2(&v0, @selector(_childTransactionDidFinishWork:));
    return [self _executeProcessLaunchIfAppropriate];
}


long -[FBApplicationUpdateScenesTransaction _didSatisfyMilestone:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBApplicationUpdateScenesTransaction;
    objc_msgSendSuper2(&v0, @selector(_didSatisfyMilestone:));
    return [self _executeProcessLaunchIfAppropriate];
}


long -[FBApplicationUpdateScenesTransaction _noteWillCommitUpdateForScene:](long a1)
{
    return self;
}


long -[FBApplicationUpdateScenesTransaction _noteDidCommitUpdateForScene:](long a1)
{
    return self;
}


int -[FBApplicationUpdateScenesTransaction _isReadyToLaunch](void)
{
    return 1;
}


FBApplicationUpdateScenesTransaction *-[FBApplicationUpdateScenesTransaction _executeProcessLaunchIfAppropriate](void)
{
    if (self->_hasScheduledProcessLaunch) {
        return self;
    }
    FBApplicationUpdateScenesTransaction *_isReadyToLaunch = [self _isReadyToLaunch];
    self = _isReadyToLaunch;
    if (!_isReadyToLaunch) {
        return self;
    }
    self->_hasScheduledProcessLaunch = YES;
    [self->_processLaunchTransaction addObserver:self];
    return [self addChildTransaction:self->_processLaunchTransaction];
}


void -[FBApplicationUpdateScenesTransaction _executeSceneUpdatesIfAppropriate](void)
{
    FBProcess *v0;
    if (self->_processLaunched != 1 || !(v0 = [self->_processLaunchTransaction process])) {
        return;
    }
    if (![self->_pendingUpdateTransactions count]) {
        return;
    }
    if ([self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Beginning scene updates."];
    }
    id v3 = [self->_pendingUpdateTransactions copy];
    [self->_pendingUpdateTransactions removeAllObjects];
    for (FBUpdateSceneTransaction *v9 in v3) {
        [v9 addObserver:self];
        [v9 setWaitsForSceneCommit:self->_waitsForSceneCommits];
        [self addSynchronizedTransaction:v9];
    }
}


void -[FBApplicationUpdateScenesTransaction transaction:willLaunchProcess:](long a1, id a2)
{
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:willLaunchProcess:)]) {
            [arg1 transaction:self willLaunchProcess:a2];
        }
    }];
    self->_processLaunched = YES;
    [self _executeSceneUpdatesIfAppropriate];
}


void -[FBApplicationUpdateScenesTransaction transaction:didLaunchProcess:](long a1, id a2)
{
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:didLaunchProcess:)]) {
            [arg1 transaction:self didLaunchProcess:a2];
        }
    }];
}


void -[FBApplicationUpdateScenesTransaction updateSceneTransactionDidCreateScene:](id a1)
{
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:didCreateScene:)]) {
            id scene = [a1 scene];
            [arg1 transaction:self didCreateScene:scene];
        }
    }];
}


void -[FBApplicationUpdateScenesTransaction updateSceneTransactionWillUpdateScene:](id a1)
{
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:willUpdateScene:)]) {
            id scene = [a1 scene];
            [arg1 transaction:self willUpdateScene:scene];
        }
    }];
}


void -[FBApplicationUpdateScenesTransaction updateSceneTransactionWillCommitUpdate:](id a1)
{
    id scene = [a1 scene];
    [self _noteWillCommitUpdateForScene:scene];
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:willCommitSceneUpdate:)]) {
            id scene = [a1 scene];
            [arg1 transaction:self willCommitSceneUpdate:scene];
        }
    }];
}


void -[FBApplicationUpdateScenesTransaction updateSceneTransactionDidCommitUpdate:](id a1)
{
    id scene = [a1 scene];
    [self _noteDidCommitUpdateForScene:scene];
    [self _enumerateObserversWithBlock:^void(id<FBApplicationUpdateScenesTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(transaction:didCommitSceneUpdate:)]) {
            id scene = [a1 scene];
            [arg1 transaction:self didCommitSceneUpdate:scene];
        }
    }];
}


bool -[FBApplicationUpdateScenesTransaction waitsForSceneCommits](void)
{
    return self->_waitsForSceneCommits;
}


void -[FBApplicationUpdateScenesTransaction .cxx_destruct](void)
{
    self->_pendingUpdateTransactions = nil;
    self->_updateSceneTransactions = nil;
    self->_processLaunchTransaction = nil;
    self->_clientIdentity = nil;
}


void -[FBApplicationUpdateScenesTransaction init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed on FBApplicationProcessLaunchTransaction"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBApplicationUpdateScenesTransaction.m", 50, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
