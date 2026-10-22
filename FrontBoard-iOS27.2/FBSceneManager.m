struct FBSceneManager {
    FBSceneWorkspace *_workspace; // +0x8
    bool _invalidated; // +0x10
};

static NSMapTable *__availabilityObserverMap;
static id __fbKeyboardScene;
static long FBLegacySceneWorkspaceIdentifier;
static long _OBJC_PROTOCOL_REFERENCE_$_FBSceneClientProvider;

id -[FBSceneManager newSceneIdentityTokenForIdentity:](id a1)
{
    id identifier = [a1 identifier];
    return [self->_workspace sceneIdentityTokenForIdentifier:identifier];
}


id +[FBSceneManager sharedInstance](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    return [sharedInstance legacySceneManagerCreatingIfNecessary:1];
}


long -[FBSceneManager sceneWithIdentifier:](long a1)
{
    return [self->_workspace sceneWithIdentifier:a1];
}


long -[FBSceneManager addObserver:](long a1)
{
    return [self->_workspace addObserver:a1];
}


bool -[FBSceneManager _isSameAsWorkspace:](long a1)
{
    return self->_workspace == a1;
}


id -[FBSceneManager createScene:](void (^a1)(id<FBSceneCreating_Internal>))
{
    return [self->_workspace createScene:a1];
}


id +[FBSceneManager(Keyboard) keyboardScene](void)
{
    BSDispatchQueueAssertMain();
    return __fbKeyboardScene;
}


void -[FBSceneManager enumerateScenesWithBlock:](void (^a1)(FBScene *, bool *))
{
    id allScenes = [self->_workspace allScenes];
    for (FBScene *v8 in allScenes) {
        bool v7 = false;
        a1(v8, &v7);
        if (v7) {
            return;
        }
    }
}


long -[FBSceneManager sceneFromIdentityToken:](long a1)
{
    return [self->_workspace sceneWithIdentityToken:a1];
}


id -[FBSceneManager sceneFromIdentityTokenStringRepresentation:](NSString *a1)
{
    if (!a1) {
        NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"tokenString"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSceneManager.m", 112, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    __block id v3 = nil;
    [self enumerateScenesWithBlock:^void(FBScene *arg1, bool *arg2) {
        FBSSceneIdentityToken *identityToken = [arg1 identityToken];
        NSString *stringRepresentation = [identityToken stringRepresentation];
        BOOL v11 = [stringRepresentation isEqualToString:a1];
        if (v11) {
            v3 = arg1;
            *(arg2) = 1;
        }
    }];
    return v3;
}


FBSceneManager *-[FBSceneManager _initWithProcessManager:](id a1)
{
    FBSceneManager *v2 = [super init];
    if (v2 != nil) {
        v2->_workspace = [[FBSceneWorkspace alloc] _initWithProcessManager:a1 identifier:FBLegacySceneWorkspaceIdentifier];
    }
    return v2;
}


NSMutableSet *-[FBSceneManager scenesPassingTest:](id a1)
{
    id v0 = a1;
    NSMutableSet *set = [NSMutableSet set];
    if (v0 != nil) {
        [self enumerateScenesWithBlock:^void(FBScene *arg1, bool *arg2) {
            if (v0->field_16(v0, arg1, arg2) != 0) {
                [set addObject:arg1];
            }
        }];
    }
    return set;
}


void +[FBSceneManager(Keyboard) _clearKeyboardScene](void)
{
    __fbKeyboardScene = nil;
}


void +[FBSceneManager(Keyboard) setKeyboardScene:](id a1)
{
    if (__fbKeyboardScene != nil) {
        NSString *v10 = [NSString stringWithFormat:@"Cannot set a keyboard scene twice."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v11, self, @"FBKeyboardScene.m", 34, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    if (!a1) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"keyboardScene"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBKeyboardScene.m", 35, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    BSDispatchQueueAssertMain();
    if (!__fbKeyboardScene) {
        __fbKeyboardScene = a1;
        id v1 = [__availabilityObserverMap copy];
        [__availabilityObserverMap removeAllObjects];
        __availabilityObserverMap = nil;
        NSEnumerator *keyEnumerator = [v1 keyEnumerator];
        for (id v9 in keyEnumerator) {
            id v8 = [v1 objectForKey:v9];
            v8->field_16(v8, __fbKeyboardScene);
        }
    }
}


BSSimpleAssertion *+[FBSceneManager(Keyboard) observeKeyboardSceneAvailability:](void (^a1)(id))
{
    BSSimpleAssertion *v2;
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBKeyboardScene.m", 50, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    BSDispatchQueueAssertMain();
    id v1 = __fbKeyboardScene;
    if (!__fbKeyboardScene) {
        if (!__availabilityObserverMap) {
            __availabilityObserverMap = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsStrongMemory capacity:1];
        }
        v2 = [[BSSimpleAssertion alloc] initWithIdentifier:@"keyboardAvailableObserverToken" forReason:@"observation" queue:dispatch_get_main_queue() invalidationBlock:^void(BSSimpleAssertion *arg1) {
            [__availabilityObserverMap removeObjectForKey:arg1];
        }];
        void (^v3)(id) = _Block_copy(a1);
        [__availabilityObserverMap setObject:v3 forKey:v2];
    } else {
        a1(v1);
        v2 = nil;
    }
    return v2;
}


id -[FBSceneManager init](void)
{
    return [FBSceneManager sharedInstance];
}


void -[FBSceneManager dealloc](void)
{
    if (!self->_invalidated) {
        NSString *v1 = [NSString stringWithFormat:@"FBSceneManager should not deallocate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneManager.m", 47, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


long -[FBSceneManager _invalidate](void)
{
    long invalidate = [self->_workspace invalidate];
    self->_invalidated = YES;
    return invalidate;
}


id<FBSceneWorkspaceDelegate> -[FBSceneManager delegate](void)
{
    return [self->_workspace delegate];
}


void -[FBSceneManager setDelegate:](id<FBSceneWorkspaceDelegate> a1)
{
    [self->_workspace setDelegate:a1];
}


long -[FBSceneManager removeObserver:](id a1)
{
    return [self->_workspace removeObserver:a1];
}


long -[FBSceneManager add:](long a1)
{
    return [self->_workspace addObserver:a1];
}


long -[FBSceneManager remove:](id a1)
{
    return [self->_workspace removeObserver:a1];
}


long +[FBSceneManager synchronizeChanges:](void *a1)
{
    return a1->field_16(a1);
}


long -[FBSceneManager createSceneWithDefinition:](long a1)
{
    return [self->_workspace _createSceneWithDefinition:a1 settings:0 initialClientSettings:0 transitionContext:0 fromRemnant:0 usingClientProvider:0 completion:0];
}


id -[FBSceneManager createSceneWithDefinition:initialParameters:](id a1, id a2)
{
    FBWorkspace *v5;
    id v3;
    id v12;
    FBSSceneClientIdentity *clientIdentity = [a1 clientIdentity];
    if (([clientIdentity isLocal] & 1) == 0) {
        id identityOfCurrentProcess = [RBSProcessIdentity identityOfCurrentProcess];
        if (![identityOfCurrentProcess isEqual:clientIdentity]) {
            id domain = [self->_workspace domain];
            RBSProcessIdentity *processIdentity2 = [clientIdentity processIdentity];
            id v10 = [domain processForIdentity:processIdentity2];
            v5 = [v10 workspace];
        } else {
            v3 = [self->_workspace domain];
            v5 = [v3 syncLocalSceneClientProvider];
        }
    } else {
        v3 = [self->_workspace domain];
        v5 = [v3 syncLocalSceneClientProvider];
    }
    if (!v5) {
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id identity = [a1 identity];
            RBSProcessIdentity *processIdentity = [clientIdentity processIdentity];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "scene %{public}@ cannot be created because there is no running process for %{public}@", identity, processIdentity);
        }
        v12 = nil;
    } else {
        FBSSceneSettings *settings = [a2 settings];
        FBSSceneClientSettings *clientSettings = [a2 clientSettings];
        v12 = [self _createSceneWithDefinition:a1 settings:settings initialClientSettings:clientSettings transitionContext:0 fromRemnant:0 usingClientProvider:v5 completion:0];
    }
    return v12;
}


id -[FBSceneManager createSceneWithIdentifier:parameters:clientProvider:transitionContext:](id a1, id a2, id a3, id a4)
{
    long v6;
    if (!a3) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v16, self, @"FBSceneManager.m", 173, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    if (![a3 conformsToProtocol:_OBJC_PROTOCOL_REFERENCE_$_FBSceneClientProvider]) {
        NSString *v18 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object conformsToProtocol:@protocol(FBSceneClientProvider)]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBSceneManager.m", 173, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    if (![a3 isKindOfClass:[FBWorkspace class]]) {
        v6 = [FBSSceneClientIdentity localIdentity];
    } else {
        FBProcess *process = [a3 process];
        RBSProcessIdentity *identity = [process identity];
        v6 = [FBSSceneClientIdentity identityForProcessIdentity:identity];
    }
    id definition = [FBSMutableSceneDefinition definition];
    RBSProcessIdentity *v10 = [FBSSceneIdentity identityForIdentifier:a1];
    [definition setIdentity:v10];
    [definition setClientIdentity:v6];
    FBSSceneSpecification *specification = [a2 specification];
    [definition setSpecification:specification];
    FBSSceneSettings *settings = [a2 settings];
    FBSSceneClientSettings *clientSettings = [a2 clientSettings];
    return [self _createSceneWithDefinition:definition settings:settings initialClientSettings:clientSettings transitionContext:a4 fromRemnant:0 usingClientProvider:a3 completion:0];
}


long -[FBSceneManager createSceneFromRemnant:withSettings:transitionContext:](long a1, long a2, long a3)
{
    return [self->_workspace createSceneFromRemnant:a1 withSettings:a2 transitionContext:a3];
}


id -[FBSceneManager createLegacySceneFromRemnant:withSettings:transitionContext:](id a1, id a2, id a3)
{
    Class v3 = NSClassFromString(@"FBSceneRemnant");
    if (!a1) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSceneManager.m", 207, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v3]) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneRemnantClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBSceneManager.m", 207, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    if ([a1 _hasBeenInvalidated]) {
        NSString *v19 = [NSString stringWithFormat:@"cannot create a scene from an invalidated remnant"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(_cmd);
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBSceneManager.m", 208, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    FBWorkspace *_workspace = [a1 _workspace];
    if (!_workspace) {
        return nil;
    }
    BSSimpleAssertion *_assertion = [a1 _assertion];
    if ([_assertion isValid]) {
        FBSSceneDefinition *definition = [a1 definition];
        FBSSceneClientSettings *_clientSettings = [a1 _clientSettings];
        id v5 = [self _createSceneWithDefinition:definition settings:a2 initialClientSettings:_clientSettings transitionContext:a3 fromRemnant:a1 usingClientProvider:_workspace completion:0];
        if ([v5 isValid]) {
            return v5;
        }
    }
    return nil;
}


void -[FBSceneManager destroyScene:withTransitionContext:](id a1, id a2)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneManager destroyScene:withTransitionContext:]");
    }
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"sceneIdentifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBSceneManager.m", 229, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    id v2 = [self sceneWithIdentifier:a1];
    if (v2 != nil) {
        if (([v2 _isLegacy] & 1) == 0) {
            NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[scene _isLegacy]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v8 = NSStringFromSelector(_cmd);
                NSString *v9 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBSceneManager.m", 234, v7);
            }
            _bs_set_crash_log_message([v7 UTF8String]);
            __break(0);
        }
        [v2 deactivateWithTransitionContext:a2];
    }
}


long -[FBSceneManager _suppressConnectionHandshakes](void)
{
    return [self->_workspace _suppressConnectionHandshakes];
}


void -[FBSceneManager _setSuppressConnectionHandshakes:](long a1)
{
    [self->_workspace _setSuppressConnectionHandshakes:a1];
}


long -[FBSceneManager _createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:](long a1, long a2, long a3, long a4, long a5, long a6, long a7)
{
    return [self->_workspace _createSceneWithDefinition:a1 settings:a2 initialClientSettings:a3 transitionContext:a4 fromRemnant:a5 usingClientProvider:a6 completion:a7];
}


NSString *-[FBSceneManager description](void)
{
    return [self->_workspace description];
}


long -[FBSceneManager debugDescription](void)
{
    return [self->_workspace descriptionWithMultilinePrefix:0];
}


void -[FBSceneManager .cxx_destruct](void)
{
    self->_workspace = nil;
}
