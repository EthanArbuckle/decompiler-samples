struct FBUpdateSceneTransaction {
    FBSceneManager *_sceneManager; // +0x98
    NSString *_sceneID; // +0xa0
    FBSSceneDefinition *_definition; // +0xa8
    FBSSceneParameters *_parameters; // +0xb0
    FBSSceneTransitionContext *_transitionContext; // +0xb8
    FBWaitForSceneDestructionTransaction *_destructionTransaction; // +0xc0
    __weak id<FBSynchronizedTransactionDelegate> _synchronizationDelegate; // +0xc8
    unsigned long _transactionID; // +0xd0
    bool _waitsForSceneCommit; // +0xd8
    bool _readyToCommit; // +0xd9
    bool _didCommit; // +0xda
    bool _destroyed; // +0xdb
};

struct objc_super {
    id receiver; // +0x0
    Class super_class; // +0x8
};

static long FBTMilestoneSynchronizedCommit;

FBUpdateSceneTransaction *-[FBUpdateSceneTransaction _initWithSceneDefinition:parameters:transitionContext:](id a1, id a2, id a3)
{
    Class v1 = NSClassFromString(@"FBSSceneDefinition");
    if (!a1) {
        NSString *v24 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v25 = NSStringFromSelector(_cmd);
            NSString *v26 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBUpdateSceneTransaction.m", 57, v24);
        }
        _bs_set_crash_log_message([v24 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v28 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneDefinitionClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v29 = NSStringFromSelector(_cmd);
            NSString *v30 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v29, v30, self, @"FBUpdateSceneTransaction.m", 57, v28);
        }
        _bs_set_crash_log_message([v28 UTF8String]);
        __break(0);
    }
    Class v3 = NSClassFromString(@"FBSSceneParameters");
    if (!a2) {
        NSString *v32 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v33 = NSStringFromSelector(_cmd);
            NSString *v34 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v33, v34, self, @"FBUpdateSceneTransaction.m", 58, v32);
        }
        _bs_set_crash_log_message([v32 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v3]) {
        NSString *v36 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneParametersClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v37 = NSStringFromSelector(_cmd);
            NSString *v38 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBUpdateSceneTransaction.m", 58, v36);
        }
        _bs_set_crash_log_message([v36 UTF8String]);
        __break(0);
    }
    if (![a1 isValid]) {
        NSString *v40 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[definition isValid]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v41 = NSStringFromSelector(_cmd);
            NSString *v42 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v42, self, @"FBUpdateSceneTransaction.m", 59, v40);
        }
        _bs_set_crash_log_message([v40 UTF8String]);
        __break(0);
    }
    if (a3 != nil && ![a3 isKindOfClass:NSClassFromString(@"FBSSceneTransitionContext")]) {
        NSString *v44 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneTransitionContextClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v45 = NSStringFromSelector(_cmd);
            NSString *v46 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v45, v46, self, @"FBUpdateSceneTransaction.m", 61, v44);
        }
        _bs_set_crash_log_message([v44 UTF8String]);
        __break(0);
    }
    FBUpdateSceneTransaction *v6 = [super init];
    if (v6 != nil) {
        v6->_sceneManager = [FBSceneManager sharedInstance];
        id identity = [a1 identity];
        id identifier = [identity identifier];
        v6->_sceneID = [identifier copy];
        v6->_definition = [a1 copy];
        v6->_parameters = [a2 copy];
        v6->_transitionContext = [a3 copy];
        v6->_waitsForSceneCommit = YES;
    }
    return v6;
}


FBUpdateSceneTransaction *-[FBUpdateSceneTransaction initWithSceneDefinition:parameters:transitionContext:](long a1, long a2, long a3)
{
    return [self _initWithSceneDefinition:a1 parameters:a2 transitionContext:a3];
}


FBUpdateSceneTransaction *-[FBUpdateSceneTransaction initWithSceneIdentifier:process:parameters:transitionContext:](id a1, id a2, id a3, id a4)
{
    id definition = [FBSMutableSceneDefinition definition];
    RBSProcessIdentity *v5 = [FBSSceneIdentity identityForIdentifier:a1];
    [definition setIdentity:v5];
    id identity = [a2 identity];
    id v7 = [FBSSceneClientIdentity identityForProcessIdentity:identity];
    [definition setClientIdentity:v7];
    FBSSceneSpecification *specification = [a3 specification];
    [definition setSpecification:specification];
    return [self _initWithSceneDefinition:definition parameters:a3 transitionContext:a4];
}


FBUpdateSceneTransaction *-[FBUpdateSceneTransaction initWithSceneToUpdate:newSettings:transitionContext:](id a1, id a2, id a3)
{
    if (!a1) {
        NSString *v8 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"sceneID"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBUpdateSceneTransaction.m", 95, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"newSettings"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBUpdateSceneTransaction.m", 96, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    id sharedInstance = [FBSceneManager sharedInstance];
    id v4 = [sharedInstance sceneWithIdentifier:a1];
    if (([v4 _isLegacy] & 1) == 0) {
        NSString *v16 = [NSString stringWithFormat:@"this transaction only supports legacy scenes"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBUpdateSceneTransaction.m", 99, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    id parameters = [v4 parameters];
    [parameters setSettings:a2];
    return [self _initWithSceneDefinition:[v4 definition] parameters:parameters transitionContext:a3];
}


void -[FBUpdateSceneTransaction dealloc](void)
{
    NSString *v0 = self->_sceneID;
    FBSceneManager *v1 = self->_sceneManager;
    BSDispatchMain(^void(void) {
        id v3 = [v1 sceneWithIdentifier:v0];
        [v3 removeObserver:self];
    });
    [super dealloc];
}


id -[FBUpdateSceneTransaction scene](void)
{
    dispatch_queue_t queue = [self queue];
    dispatch_assert_queue(queue);
    id v1 = [self->_sceneManager sceneWithIdentifier:self->_sceneID];
    if (v1 != nil && ([v1 _isLegacy] & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"this transaction only supports legacy scenes"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBUpdateSceneTransaction.m", 132, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return v1;
}


FBSSceneSettings *-[FBUpdateSceneTransaction settings](void)
{
    return [self->_parameters settings];
}


FBSSceneSettings *-[FBUpdateSceneTransaction newSettings](void)
{
    return [self settings];
}


FBSSceneSpecification *-[FBUpdateSceneTransaction specification](void)
{
    return [self->_parameters specification];
}


dispatch_queue_t -[FBUpdateSceneTransaction setWaitsForSceneCommit:](bool a1)
{
    dispatch_queue_t v0 = [self queue];
    dispatch_assert_queue(v0);
    if (self->_waitsForSceneCommit == a1) {
        return v0;
    }
    self->_waitsForSceneCommit = a1;
    v0 = [self isWaitingForMilestone:@"sceneUpdateDidCommit"];
    if (!self->_waitsForSceneCommit && v0 != nil) {
        return [self removeMilestone:@"sceneUpdateDidCommit"];
    }
    if (((!self->_waitsForSceneCommit | v0) & 1) != 0) {
        return v0;
    }
    v0 = [self isComplete];
    if ((v0 & 1) != 0) {
        return v0;
    }
    return [self addMilestone:@"sceneUpdateDidCommit"];
}


long -[FBUpdateSceneTransaction addObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBUpdateSceneTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBUpdateSceneTransaction removeObserver:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBUpdateSceneTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


long -[FBUpdateSceneTransaction add:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBUpdateSceneTransaction;
    return objc_msgSendSuper2(&v0, @selector(addObserver:));
}


long -[FBUpdateSceneTransaction remove:](long a1)
{
    struct objc_super v0;
    v0.receiver = self;
    v0.super_class = FBUpdateSceneTransaction;
    return objc_msgSendSuper2(&v0, @selector(removeObserver:));
}


void -[FBUpdateSceneTransaction _commitSceneUpdate:](void (^a1)(void))
{
    long v8 = 0;
    if (self->_waitsForSceneCommit == 1) {
        [self addMilestone:@"sceneUpdateDidCommit"];
    }
    FBSSceneSettings *settings = [self settings];
    if ([settings isForeground]) {
        if (![self->_transitionContext _uikitShimming_isUISubclass]) {
            v8 = 1;
        }
        if (!v8 && self->_waitsForSceneCommit == 1) {
            id watchdogTransitionContext = [self->_transitionContext watchdogTransitionContext];
            long watchdogBehavior = [watchdogTransitionContext watchdogBehavior];
            long v4 = ((unsigned long)watchdogBehavior > 1) ? watchdogBehavior : 1;
            [watchdogTransitionContext setWatchdogBehavior:v4];
            if ([self isAuditHistoryEnabled] != 0) {
                id v5 = NSStringFromFBWatchdogBehavior(v4);
                [self _addAuditHistoryItem:@"Updating scene with watchdog policy: %@", v5];
            }
        }
    }
    a1();
    FBScene *scene = [self scene];
    [scene addObserver:self];
    id animationFence = [self->_transitionContext animationFence];
    [animationFence invalidate];
}


void -[FBUpdateSceneTransaction _createScene](void)
{
    FBWorkspace *v3;
    id clientIdentity = [self->_definition clientIdentity];
    long continuationRoute1 = 0;
    if (([clientIdentity isLocal] & 1) == 0) {
        id identityOfCurrentProcess = [RBSProcessIdentity identityOfCurrentProcess];
        if (![identityOfCurrentProcess isEqual:clientIdentity]) {
            id sharedInstance = [FBProcessManager sharedInstance];
            id clientIdentity2 = [self->_definition clientIdentity];
            RBSProcessIdentity *processIdentity = [clientIdentity2 processIdentity];
            id v12 = [sharedInstance processForIdentity:processIdentity];
            v3 = [v12 workspace];
            if (v3 != nil) {
                continuationRoute1 = 2;
            } else {
                continuationRoute1 = 1;
            }
        }
    }
    if (!continuationRoute1) {
        v3 = [FBLocalSynchronousSceneClientProvider sharedInstance];
        if (v3) {
            continuationRoute1 = 2;
        } else {
            continuationRoute1 = 1;
        }
    }
    if (continuationRoute1 == 1) {
        id clientIdentity3 = [self->_definition clientIdentity];
        NSString *v5 = [NSString stringWithFormat:@"no client provider for client with identity %@", clientIdentity3];
        [self _failWithReason:@"scene update failed" description:v5];
    } else {
        [self _commitSceneUpdate:^void(void) {
            FBSSceneSettings *settings = [self->_parameters settings];
            FBSSceneClientSettings *clientSettings = [self->_parameters clientSettings];
            void (^v15)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                [self _noteDidCommit:arg1];
            };
            [self->_sceneManager _createSceneWithDefinition:self->_definition settings:settings initialClientSettings:clientSettings transitionContext:self->_transitionContext fromRemnant:0 usingClientProvider:v3 completion:v15];
            [self _noteDidCreate];
            [self _noteWillCommit];
        }];
    }
}


void -[FBUpdateSceneTransaction _updateScene](void)
{
    FBScene *scene = [self scene];
    if (!scene) {
        NSString *v6 = [NSString stringWithFormat:@"Scene expected to update."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBUpdateSceneTransaction.m", 236, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    bool v5 = self->_transitionContext != nil;
    if (!v5) {
        FBSSceneSettings *settings = [scene settings];
        FBSSceneSettings *settings2 = [self settings];
        BOOL v4 = [settings isEqual:settings2];
        v5 = !v4;
    }
    if (v5) {
        [self _commitSceneUpdate:^void(void) {
            [self _noteWillUpdate];
            FBScene *scene = [self scene];
            FBSSceneSettings *settings = [self settings];
            [scene updateSettings:settings withTransitionContext:self->_transitionContext completion:^void(bool arg1) {
                [self _noteDidCommit:arg1];
            }];
            [self _noteWillCommit];
        }];
    } else if ([self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Updated scene settings are identical to existing settings with no transition context. Ignoring update."];
    }
}


void -[FBUpdateSceneTransaction _commitSceneOrWait](void)
{
    self->_readyToCommit = YES;
    [self addMilestone:FBTMilestoneSynchronizedCommit];
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    if (!synchronizationDelegate) {
        [self performSynchronizedCommit];
    } else {
        [synchronizationDelegate synchronizedTransactionReadyToCommit:self];
    }
}


long -[FBUpdateSceneTransaction _performCommit](void)
{
    if (![self scene]) {
        return [self _createScene];
    } else {
        return [self _updateScene];
    }
}


void -[FBUpdateSceneTransaction _begin](void)
{
    FBScene *scene = [self scene];
    FBProcess *clientProcess = [scene clientProcess];
    if (!scene) {
        [self _commitSceneOrWait];
    } else if (![clientProcess isPendingExit]) {
        [self _commitSceneOrWait];
    } else {
        if ([self isAuditHistoryEnabled] != 0) {
            [self _addAuditHistoryItem:@"Scene exists but is invalidated. Waiting for it to be destroyed..."];
        }
        self->_destructionTransaction = [[FBWaitForSceneDestructionTransaction alloc] initWithScene:scene];
        [self addChildTransaction:self->_destructionTransaction];
    }
    [super _begin];
}


long -[FBUpdateSceneTransaction _didComplete](void)
{
    FBScene *scene = [self scene];
    [scene removeObserver:self];
    return [super _didComplete];
}


void -[FBUpdateSceneTransaction _childTransactionDidComplete:](id a1)
{
    if (a1 == self->_destructionTransaction) {
        if (([a1 isFailed] & 1) == 0 && ([a1 isInterrupted] & 1) == 0) {
            if ([self isAuditHistoryEnabled] != 0) {
                [self _addAuditHistoryItem:@"Invalidated scene was destroyed."];
            }
            [self _commitSceneOrWait];
        }
        self->_destructionTransaction = nil;
    }
    [super _childTransactionDidComplete:a1];
}


int -[FBUpdateSceneTransaction _canBeInterrupted](void)
{
    return 1;
}


NSMutableDictionary *-[FBUpdateSceneTransaction _customizedDescriptionProperties](void)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *v1 = self->_sceneID;
    if (!self->_sceneID) {
        v1 = @"(none)";
    }
    [dictionary setObject:v1 forKey:@"SceneID"];
    FBSSceneSettings *settings = [self settings];
    if (settings != nil) {
        FBSSceneSettings *settings2 = [self settings];
        NSString *v4 = ([settings2 isForeground]) ? @"Foreground" : @"Background";
        [dictionary setObject:v4 forKey:@"Scene Visibility"];
    }
    id v5 = NSStringFromBOOL(self->_waitsForSceneCommit);
    [dictionary setObject:v5 forKey:@"Wait for Commit"];
    return dictionary;
}


long -[FBUpdateSceneTransaction _noteDidCreate](void)
{
    return [self _enumerateObserversWithBlock:^void(id<FBUpdateSceneTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(updateSceneTransactionDidCreateScene:)]) {
            [arg1 updateSceneTransactionDidCreateScene:self];
        }
    }];
}


long -[FBUpdateSceneTransaction _noteWillUpdate](void)
{
    return [self _enumerateObserversWithBlock:^void(id<FBUpdateSceneTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(updateSceneTransactionWillUpdateScene:)]) {
            [arg1 updateSceneTransactionWillUpdateScene:self];
        }
    }];
}


long -[FBUpdateSceneTransaction _noteWillCommit](void)
{
    return [self _enumerateObserversWithBlock:^void(id<FBUpdateSceneTransactionObserver> arg1) {
        if ([arg1 respondsToSelector:@selector(updateSceneTransactionWillCommitUpdate:)]) {
            [arg1 updateSceneTransactionWillCommitUpdate:self];
        }
    }];
}


NSString *-[FBUpdateSceneTransaction _noteDidCommit:](int a1)
{
    if (!a1) {
        NSString *v0 = [NSString stringWithFormat:@"Scene update failed"];
        [self _failWithReason:@"scene update failed" description:v0];
        return v0;
    }
    long isFailed = [self isFailed];
    if ((isFailed & 1) == 0) {
        [self _enumerateObserversWithBlock:^void(id<FBUpdateSceneTransactionObserver> arg1) {
            if ([arg1 respondsToSelector:@selector(updateSceneTransactionDidCommitUpdate:)]) {
                [arg1 updateSceneTransactionDidCommitUpdate:self];
            }
        }];
        return [self satisfyMilestone:@"sceneUpdateDidCommit"];
    }
    return isFailed;
}


void -[FBUpdateSceneTransaction sceneDidInvalidate:](id a1)
{
    [a1 removeObserver:self];
    self->_destroyed = YES;
    NSString *v1 = [NSString stringWithFormat:@"Scene destroyed: %@", a1];
    [self _failWithReason:@"scene update failed" description:v1];
}


id<FBSynchronizedTransactionDelegate> -[FBUpdateSceneTransaction synchronizationDelegate](void)
{
    return self->_synchronizationDelegate;
}


bool -[FBUpdateSceneTransaction isReadyForSynchronizedCommit](void)
{
    return ((!self->_didCommit) ? self->_readyToCommit : 0) & 1;
}


void -[FBUpdateSceneTransaction performSynchronizedCommit](void)
{
    if (![self isReadyForSynchronizedCommit]) {
        return;
    }
    self->_didCommit = YES;
    if ([self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Performing synchronized commit."];
    }
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    [synchronizationDelegate synchronizedTransaction:self willCommitSynchronizedTransactions:0];
    [self _performCommit];
    [synchronizationDelegate synchronizedTransaction:self didCommitSynchronizedTransactions:0];
    [self satisfyMilestone:FBTMilestoneSynchronizedCommit];
}


NSString *-[FBUpdateSceneTransaction sceneIdentifier](void)
{
    return self->_sceneID;
}


FBSSceneTransitionContext *-[FBUpdateSceneTransaction transitionContext](void)
{
    return self->_transitionContext;
}


bool -[FBUpdateSceneTransaction destroyed](void)
{
    return self->_destroyed;
}


bool -[FBUpdateSceneTransaction waitsForSceneCommit](void)
{
    return self->_waitsForSceneCommit;
}


id -[FBUpdateSceneTransaction setSynchronizationDelegate:](id a1)
{
    return objc_storeWeak(&self->_synchronizationDelegate, a1);
}


void -[FBUpdateSceneTransaction .cxx_destruct](void)
{
    self->_synchronizationDelegate = nil;
    self->_destructionTransaction = nil;
    self->_transitionContext = nil;
    self->_parameters = nil;
    self->_definition = nil;
    self->_sceneID = nil;
    self->_sceneManager = nil;
}
