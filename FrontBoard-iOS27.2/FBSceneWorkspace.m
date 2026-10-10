struct FBSceneWorkspace {
    FBProcessManager *_processManager; // +0x8
    id<BSInvalidatable> _eventDispatcherTargetRegistration; // +0x10
    id<BSInvalidatable> _stateCaptureAssertion; // +0x18
    FBSceneManagerObserver *_delegate; // +0x20
    NSMutableOrderedSet *_lock_observers; // +0x28
    NSMutableDictionary *_allScenesByID; // +0x30
    unsigned long _synchronizationBlockDepth; // +0x38
    FBSMutableSceneDefinition *_buildingDefinition; // +0x40
    FBSMutableSceneParameters *_buildingParameters; // +0x48
    struct os_unfair_lock_s _lock; // +0x50
    bool _invalidated; // +0x54
    bool _suppressConnectionHandshakes; // +0x55
    NSString *_identifier; // +0x58
};

static NSMutableDictionary *__Workspaces;
static long FBLegacySceneWorkspaceIdentifier;
static long _OBJC_PROTOCOL_REFERENCE_$_FBSceneClientProvider;
static long __WorkspacesLock;

NSArray *-[FBSceneWorkspace allScenes](void)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace allScenes]");
    }
    return [self->_allScenesByID allValues];
}


id -[FBSceneWorkspace sceneIdentityTokenForIdentifier:](id a1)
{
    Class v1 = NSClassFromString(@"NSString");
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBSceneWorkspace.m", 207, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v8 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBSceneWorkspace.m", 207, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    id incomingWorkspaceEndpoint = [self->_processManager incomingWorkspaceEndpoint];
    return [FBSSceneIdentityToken tokenWithHostEndpoint:incomingWorkspaceEndpoint workspace:self->_identifier identifier:a1];
}


id -[FBSceneWorkspace _legacyWorkspace](void)
{
    id self;
    if (self != nil) {
        id v0 = [self->_processManager legacySceneManagerCreatingIfNecessary:0];
        self = (![v0 _isSameAsWorkspace:self]) ? nil : v0;
    }
    return self;
}


int -[FBSceneWorkspace scene:willUpdateSettings:](id a1, id a2)
{
    int v3;
    id _legacyWorkspace = [self _legacyWorkspace];
    if (!_legacyWorkspace) {
        return 0;
    }
    if (![self->_delegate delegateHandlesLegacyInterception]) {
        v3 = 0;
    } else {
        id mutableSettings = [a2 mutableSettings];
        [self->_delegate sceneManager:_legacyWorkspace interceptUpdateForScene:a1 withNewSettings:mutableSettings];
        v3 = 1;
    }
    return v3;
}


id -[FBSceneWorkspace sceneWithIdentifier:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(1, "-[FBSceneWorkspace sceneWithIdentifier:]");
    }
    id v1 = (!a1) ? nil : [self->_allScenesByID objectForKey:a1];
    return v1;
}


void -[FBSceneWorkspace scene:didPrepareUpdate:](id a1, id a2)
{
    id v1 = a1;
    id _legacyWorkspace = [self _legacyWorkspace];
    if (_legacyWorkspace != nil) {
        FBSSceneTransitionContext *transitionContext = [a2 transitionContext];
        id updateContext = [transitionContext updateContext];
        [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
            FBSSceneSettings *v33 = [updateContext settings];
            FBSSceneTransitionContext *v34 = [updateContext transitionContext];
            [arg1 sceneManager:_legacyWorkspace willUpdateScene:v1 withSettings:v33 transitionContext:v34];
        }];
    }
    FBSSceneSettingsDiff *settingsDiff = [a2 settingsDiff];
    long v8 = [settingsDiff containsProperty:@selector(interruptionPolicy)];
    if (v8 != 0) {
        FBSSceneSettings *settings = [a2 settings];
        long interruptionPolicy = [settings interruptionPolicy];
        if (interruptionPolicy == 2) {
            id definition = [v1 definition];
            FBSSceneClientIdentity *clientIdentity = [definition clientIdentity];
            long targetsClientEndpoint = [clientIdentity targetsClientEndpoint];
            if (targetsClientEndpoint != 0) {
                NSString *v14 = [NSString stringWithFormat:@"reconnect not supported for direct connections"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v15 = NSStringFromSelector(_cmd);
                    NSString *v16 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBSceneWorkspace.m", 486, v14);
                }
                _bs_set_crash_log_message([v14 UTF8String]);
                __break(0);
            }
            id eventDispatcher = [self->_processManager eventDispatcher];
            id domain = [eventDispatcher domain];
            id reconnectableWorkspaces = [domain reconnectableWorkspaces];
            if (![reconnectableWorkspaces containsObject:self->_identifier]) {
                id loggingIdentifier = [v1 loggingIdentifier];
                NSString *v23 = [NSString stringWithFormat:@"workspace (%@) of scene (%@) does not support reconnect", self->_identifier, loggingIdentifier];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v24 = NSStringFromSelector(_cmd);
                    NSString *v25 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v24, v25, self, @"FBSceneWorkspace.m", 487, v23);
                }
                _bs_set_crash_log_message([v23 UTF8String]);
                __break(0);
            }
            NSString *workspaceIdentifier = [v1 workspaceIdentifier];
            if (workspaceIdentifier != nil) {
                NSString *workspaceIdentifier2 = [v1 workspaceIdentifier];
                if (![self->_identifier isEqualToString:workspaceIdentifier2]) {
                    id loggingIdentifier2 = [v1 loggingIdentifier];
                    NSString *v30 = [NSString stringWithFormat:@"reconnect not supported for (legacy) scenes with conflicting workspace identifiers : workspace (%@) != scene (%@)", self->_identifier, loggingIdentifier2];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v31 = NSStringFromSelector(_cmd);
                        NSString *v32 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBSceneWorkspace.m", 489, v30);
                    }
                    _bs_set_crash_log_message([v30 UTF8String]);
                    __break(0);
                }
            }
        }
    }
}


void -[FBSceneWorkspace _iterateObservers:](void (^a1)(FBSceneManagerObserver *))
{
    if (self != 0) {
        FBSceneManagerObserver *v1 = self->_delegate;
        if (self->_delegate != nil) {
            a1(v1);
        }
        os_unfair_lock_lock(&self->_lock);
        NSArray *array = [self->_lock_observers array];
        id v3 = [array copy];
        os_unfair_lock_unlock(&self->_lock);
        for (FBSceneManagerObserver *v9 in v3) {
            if (v9 != v1) {
                a1(v9);
            }
        }
    }
}


void -[FBSceneWorkspace scene:didApplyUpdate:](id a1, id a2)
{
    id v0 = a1;
    id _legacyWorkspace = [self _legacyWorkspace];
    if (_legacyWorkspace != nil) {
        FBSSceneTransitionContext *transitionContext = [a2 transitionContext];
        id updateContext = [transitionContext updateContext];
        [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
            long transactionID = [updateContext transactionID];
            [arg1 sceneManager:_legacyWorkspace willCommitUpdateForScene:v0 transactionID:transactionID];
        }];
    }
}


id -[FBSceneWorkspace createScene:](void (^a1)(id<FBSceneCreating_Internal>))
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace createScene:]");
    }
    if (self->_buildingDefinition != nil) {
        NSString *v9 = NSStringFromSelector(_cmd);
        NSString *v10 = [NSString stringWithFormat:@"%@ was called reentrantly", v9];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBSceneWorkspace.m", 219, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    FBSMutableSceneDefinition *definition = [FBSMutableSceneDefinition definition];
    self->_buildingDefinition = definition;
    a1(self);
    FBSSceneSettings *settings = [self->_buildingParameters settings];
    FBSSceneClientSettings *clientSettings = [self->_buildingParameters clientSettings];
    self->_buildingDefinition = nil;
    self->_buildingParameters = nil;
    return [self _createSceneWithDefinition:definition settings:settings initialClientSettings:clientSettings transitionContext:0 fromRemnant:0 usingClientProvider:0 completion:0];
}


void -[FBSceneWorkspace setIdentity:](RBSProcessIdentity *a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace setIdentity:]");
    }
    if (!self->_buildingDefinition) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_buildingDefinition != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBSceneWorkspace.m", 425, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    Class v1 = NSClassFromString(@"FBSSceneIdentity");
    if (!a1) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBSceneWorkspace.m", 426, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSceneWorkspace.m", 426, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    if (![self _legacyWorkspace]) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[self _legacyWorkspace]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBSceneWorkspace.m", 427, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    [self->_buildingDefinition setIdentity:a1];
}


void -[FBSceneWorkspace configureParameters:](void (^a1)(FBSMutableSceneParameters *))
{
    if (!self->_buildingDefinition) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_buildingDefinition != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBSceneWorkspace.m", 448, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    FBSSceneSpecification *specification = [self->_buildingDefinition specification];
    if (!specification) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"specification != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBSceneWorkspace.m", 450, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    FBSMutableSceneParameters *v2 = self->_buildingParameters;
    if (!self->_buildingParameters) {
        self->_buildingParameters = [FBSMutableSceneParameters parametersForSpecification:specification];
        v2 = self->_buildingParameters;
    }
    a1(v2);
}


FBScene *-[FBSceneWorkspace _createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:](id a1, id a2, id a3, id a4, id a5, id a6, long a7)
{
    RBSProcessIdentity *v36;
    id v37;
    id v1 = _cmd;
    FBSSceneSettings *v2 = a1;
    FBSSceneSettings *v3 = a2;
    if (!self) {
        return nil;
    }
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace _createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:]");
    }
    if (self->_invalidated == 1) {
        NSString *v43 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"!_invalidated"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v44 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v45 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v44, v45, self, @"FBSceneWorkspace.m", 278, v43);
        }
        _bs_set_crash_log_message([v43 UTF8String]);
        __break(0);
    }
    if (![v1 isValid]) {
        NSString *v47 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[definition isValid]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v48 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v49 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v48, v49, self, @"FBSceneWorkspace.m", 279, v47);
        }
        _bs_set_crash_log_message([v47 UTF8String]);
        __break(0);
    }
    id identity = [v1 identity];
    id<NSCopying> identifier = [identity identifier];
    Class v14 = NSClassFromString(@"NSString");
    if (!identifier) {
        NSString *v51 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v52 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v53 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v52, v53, self, @"FBSceneWorkspace.m", 281, v51);
        }
        _bs_set_crash_log_message([v51 UTF8String]);
        __break(0);
    }
    if (![identifier isKindOfClass:v14]) {
        NSString *v55 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v56 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v57 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v56, v57, self, @"FBSceneWorkspace.m", 281, v55);
        }
        _bs_set_crash_log_message([v55 UTF8String]);
        __break(0);
    }
    FBSSceneSpecification *specification = [v1 specification];
    Class v16 = NSClassFromString(@"FBSSceneSpecification");
    if (!specification) {
        NSString *v59 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v60 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v61 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v60, v61, self, @"FBSceneWorkspace.m", 283, v59);
        }
        _bs_set_crash_log_message([v59 UTF8String]);
        __break(0);
    }
    if (![specification isKindOfClass:v16]) {
        NSString *v63 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSpecificationClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v64 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v65 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v64, v65, self, @"FBSceneWorkspace.m", 283, v63);
        }
        _bs_set_crash_log_message([v63 UTF8String]);
        __break(0);
    }
    long v17 = a5;
    if (a4 != nil) {
        if (![a4 isKindOfClass:NSClassFromString(@"FBSceneRemnant")]) {
            NSString *v67 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneRemnantClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v68 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v69 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v68, v69, self, @"FBSceneWorkspace.m", 285, v67);
            }
            _bs_set_crash_log_message([v67 UTF8String]);
            __break(0);
        }
        FBSSceneDefinition *definition = [a4 definition];
        id identity2 = [definition identity];
        id internalWorkspaceIdentifier = [identity2 internalWorkspaceIdentifier];
        long v22 = BSEqualObjects(internalWorkspaceIdentifier, self->_identifier);
        if ((v22 & 1) == 0) {
            NSString *v71 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"BSEqualObjects([[[remnant definition] identity] internalWorkspaceIdentifier], _identifier)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v72 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v73 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v72, v73, self, @"FBSceneWorkspace.m", 286, v71);
            }
            _bs_set_crash_log_message([v71 UTF8String]);
            __break(0);
        }
        bool _hasBeenInvalidated = [a4 _hasBeenInvalidated];
        v17 = a5;
        if (_hasBeenInvalidated) {
            NSString *v75 = [NSString stringWithFormat:@"cannot create a scene from an invalidated remnant"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v76 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v77 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v76, v77, self, @"FBSceneWorkspace.m", 287, v75);
            }
            _bs_set_crash_log_message([v75 UTF8String]);
            __break(0);
        }
    }
    if (a3 != nil && ![a3 isKindOfClass:NSClassFromString(@"FBSSceneTransitionContext")]) {
        NSString *v79 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneTransitionContextClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v80 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v81 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v80, v81, self, @"FBSceneWorkspace.m", 289, v79);
        }
        _bs_set_crash_log_message([v79 UTF8String]);
        __break(0);
    }
    id v25 = v17;
    if (v17 != 0 && ![v25 conformsToProtocol:_OBJC_PROTOCOL_REFERENCE_$_FBSceneClientProvider]) {
        NSString *v83 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object conformsToProtocol:@protocol(FBSceneClientProvider)]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v84 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v85 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v84, v85, self, @"FBSceneWorkspace.m", 290, v83);
        }
        _bs_set_crash_log_message([v83 UTF8String]);
        __break(0);
    }
    id _legacyWorkspace = [self _legacyWorkspace];
    if (!v25) {
        if (a3 && a4 == nil) {
            NSString *v87 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"remnant != nil || transitionContext == nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v88 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v89 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v88, v89, self, @"FBSceneWorkspace.m", 299, v87);
            }
            _bs_set_crash_log_message([v87 UTF8String]);
            __break(0);
        }
        if (a6 != nil) {
            NSString *v91 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"completion == nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v92 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v93 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v92, v93, self, @"FBSceneWorkspace.m", 300, v91);
            }
            _bs_set_crash_log_message([v91 UTF8String]);
            __break(0);
        }
        if (!v2) {
            id settingsClass = [specification settingsClass];
            v2 = [settingsClass settings];
        }
        if (!v3) {
            id clientSettingsClass = [specification clientSettingsClass];
            v3 = [clientSettingsClass settings];
        }
    } else {
        if (!_legacyWorkspace) {
            NSString *v95 = [NSString stringWithFormat:@"legacy scenes can only be created on a legacy workspace"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v96 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v97 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v96, v97, self, @"FBSceneWorkspace.m", 296, v95);
            }
            _bs_set_crash_log_message([v95 UTF8String]);
            __break(0);
        }
        id displayConfiguration = [v2 displayConfiguration];
        Class v30 = NSClassFromString(@"FBSDisplayConfiguration");
        if (!displayConfiguration) {
            NSString *v99 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v100 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v101 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v100, v101, self, @"FBSceneWorkspace.m", 297, v99);
            }
            _bs_set_crash_log_message([v99 UTF8String]);
            __break(0);
        } else if (![displayConfiguration isKindOfClass:v30]) {
            NSString *v103 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSDisplayConfigurationClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v104 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v105 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v104, v105, self, @"FBSceneWorkspace.m", 297, v103);
            }
            _bs_set_crash_log_message([v103 UTF8String]);
            __break(0);
        }
    }
    Class v31 = NSClassFromString(@"FBSSceneSettings");
    if (!v2) {
        NSString *v107 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v108 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v109 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v108, v109, self, @"FBSceneWorkspace.m", 309, v107);
        }
        _bs_set_crash_log_message([v107 UTF8String]);
        __break(0);
    }
    if (![v2 isKindOfClass:v31]) {
        NSString *v111 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v112 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v113 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v112, v113, self, @"FBSceneWorkspace.m", 309, v111);
        }
        _bs_set_crash_log_message([v111 UTF8String]);
        __break(0);
    }
    Class v32 = NSClassFromString(@"FBSSceneClientSettings");
    if (!v3) {
        NSString *v115 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v116 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v117 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v116, v117, self, @"FBSceneWorkspace.m", 310, v115);
        }
        _bs_set_crash_log_message([v115 UTF8String]);
        __break(0);
    }
    if (![v3 isKindOfClass:v32]) {
        NSString *v119 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneClientSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v120 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v121 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v120, v121, self, @"FBSceneWorkspace.m", 310, v119);
        }
        _bs_set_crash_log_message([v119 UTF8String]);
        __break(0);
    }
    id identity3 = [v1 identity];
    NSString *workspaceIdentifier = [identity3 workspaceIdentifier];
    if (_legacyWorkspace) {
        NSString *v41 = FBLegacySceneWorkspaceIdentifier;
        if (workspaceIdentifier != nil && ![workspaceIdentifier isEqualToString:v41]) {
            os_unfair_lock_lock(&__WorkspacesLock);
            id v42 = [__Workspaces objectForKey:workspaceIdentifier];
            os_unfair_lock_unlock(&__WorkspacesLock);
            if (v42 != nil) {
                NSString *v137 = [NSString stringWithFormat:@"modern workspace \"%@\" already exists", workspaceIdentifier];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v138 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                    NSString *v139 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v138, v139, self, @"FBSceneWorkspace.m", 323, v137);
                }
                _bs_set_crash_log_message([v137 UTF8String]);
                __break(0);
            }
        }
        v36 = [identity3 mutableCopy];
        [v36 setInternalWorkspaceIdentifier:v41];
        v37 = [v1 mutableCopy];
        [v37 setIdentity:v36];
    } else if ((BSEqualStrings(workspaceIdentifier, self->_identifier) & 1) == 0) {
        if (workspaceIdentifier != nil) {
            NSString *v35 = [NSString stringWithFormat:@"provided workspaceID \"%@\" does not match actual workspaceID \"%@\"", workspaceIdentifier, self->_identifier];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                NSString *v123 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v123, self, @"FBSceneWorkspace.m", 338, v35);
            }
            _bs_set_crash_log_message([v35 UTF8String]);
            __break(0);
        }
        v36 = [identity3 mutableCopy];
        [v36 setWorkspaceIdentifier:self->_identifier];
        [v36 setInternalWorkspaceIdentifier:0];
        v37 = [v1 mutableCopy];
        [v37 setIdentity:v36];
    } else {
        v37 = nil;
    }
    if (v37 != nil) {
        id v38 = [v37 copy];
        v1 = v38;
    }
    FBScene *v8 = [[FBScene alloc] initWithDefiniton:v1 remnant:a4 settings:v2 initialClientSettings:v3 clientProvider:v25 workspace:self];
    if (!v8) {
        NSString *v125 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v126 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v127 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v126, v127, self, @"FBSceneWorkspace.m", 355, v125);
        }
        _bs_set_crash_log_message([v125 UTF8String]);
        __break(0);
    }
    id v39 = [self->_allScenesByID objectForKey:identifier];
    if (v39 != nil) {
        NSString *v129 = [NSString stringWithFormat:@"scene \"%@\" already exists in workspace \"%@\"", identifier, self->_identifier];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v130 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
            NSString *v131 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v130, v131, self, @"FBSceneWorkspace.m", 356, v129);
        }
        _bs_set_crash_log_message([v129 UTF8String]);
        __break(0);
    }
    [self->_allScenesByID setObject:v8 forKey:identifier];
    if (!a4 && !v25) {
        [self didAddScene:v8];
    } else {
        [v8 activateWithTransitionContext:a3 completion:a6];
        if (v25 != nil && ![v8 isActive]) {
            [v8 invalidate];
            id v40 = [self->_allScenesByID objectForKey:identifier];
            if (v40 != nil) {
                NSString *v133 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_allScenesByID objectForKey:identifier] == nil"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v134 = NSStringFromSelector(@selector(_createSceneWithDefinition:settings:initialClientSettings:transitionContext:fromRemnant:usingClientProvider:completion:));
                    NSString *v135 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v134, v135, self, @"FBSceneWorkspace.m", 366, v133);
                }
                _bs_set_crash_log_message([v133 UTF8String]);
                __break(0);
            }
        }
    }
    return v8;
}


void -[FBSceneWorkspace didAddScene:](id a1)
{
    [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
        [arg1 workspace:self didAddScene:a1];
    }];
}


void -[FBSceneWorkspace addObserver:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace addObserver:]");
    }
    if (a1 != nil) {
        FBSceneManagerObserver *v1 = [[FBSceneManagerObserver alloc] initWithObserver:a1 workspace:self];
        os_unfair_lock_lock(&self->_lock);
        if (![self->_lock_observers containsObject:v1]) {
            [self->_lock_observers addObject:v1];
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBSceneWorkspace scene:didCompleteUpdate:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    id _legacyWorkspace = [self _legacyWorkspace];
    if (_legacyWorkspace != nil) {
        [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
            long transactionID = [v1 transactionID];
            [arg1 sceneManager:_legacyWorkspace didCommitUpdateForScene:v0 transactionID:transactionID];
        }];
    }
}


bool -[FBSceneWorkspace _suppressConnectionHandshakes](void)
{
    if (!self) {
        return false;
    } else {
        return self->_suppressConnectionHandshakes;
    }
}


NSString *-[FBSceneWorkspace identifier](void)
{
    return self->_identifier;
}


void -[FBSceneWorkspace didReceiveHandshake:](id a1)
{
    if (!self->_suppressConnectionHandshakes) {
        FBSceneManagerObserver *v8 = self->_delegate;
        if (self->_delegate) {
            [v8 workspace:self clientDidConnectWithHandshake:a1];
            return;
        }
    }
    NSSet *remnants = [a1 remnants];
    for (id v7 in remnants) {
        [v7 invalidate];
    }
}


NSString *-[FBSceneWorkspace workspaceIdentifier](void)
{
    return self->_identifier;
}


void -[FBSceneWorkspace didReceiveSceneRequest:fromHandle:](id a1, id a2)
{
    long v24;
    id v0 = a1;
    id options = [v0 options];
    _FBSceneClientProcess *v4 = [[_FBSceneClientProcess alloc] _initWithHandle:a2];
    if (![options isClientFuture]) {
        if ([v0 actions]) {
            if (![self->_delegate delegateReceivesActions]) {
                v24 = FBSWorkspaceErrorCreate(0, 2, @"Workspace \"%@\" does not handle client actions", self->_identifier);
                [v0 invalidateWithError:v24];
                return;
            }
            id actions = [v0 actions];
            [self->_delegate workspace:self didReceiveActions:actions];
            [v0 respondWithScene:0];
        } else if (self->_delegate != nil) {
            id v29 = v0;
            id v30 = [BSBlockSentinel sentinelWithCompletion:^void(id<BSBlockSentinelSignalContext> arg1) {
                id v48;
                id v51;
                id context = [arg1 context];
                Class v47 = [FBScene class];
                if (!v47) {
                    v48 = nil;
                } else {
                    v48 = ([context isKindOfClass:v47]) ? context : nil;
                }
                if (!v48) {
                    Class v49 = [NSError class];
                    if (!v49) {
                        v51 = nil;
                    } else {
                        v51 = ([context isKindOfClass:v49]) ? context : nil;
                    }
                    id v52 = v51;
                    NSString *v53 = self->_identifier;
                    id v54 = (!v52) ? FBSWorkspaceErrorCreate(0, 2, @"the delegate of workspace \"%@\" ignored the request", v53) : FBSWorkspaceErrorCreate(v52, 2, @"the delegate of workspace \"%@\" declined to create a scene", v53);
                    [v0 invalidateWithError:v54];
                } else {
                    [v0 respondWithScene:v48];
                }
            }];
            FBSSceneClientIdentity *clientIdentity2 = [v29 clientIdentity];
            if (!clientIdentity2) {
                NSString *v1 = [NSString stringWithFormat:@"we should never get a scene request without a clientIdentity specified by the time it gets through the dispatcher : %@", v29];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v2 = NSStringFromSelector(_cmd);
                    NSString *v34 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v34, self, @"FBSceneWorkspace.m", 624, v1);
                }
                _bs_set_crash_log_message([v1 UTF8String]);
                __break(0);
            }
            [options setClientIdentity:clientIdentity2];
            [self->_delegate workspace:self didReceiveSceneRequestWithOptions:options fromProcess:v4 completion:^void(FBScene *arg1, NSError *arg2) {
                if (!arg1) {
                    [v30 signalWithContext:arg2];
                    return;
                } else {
                    [v30 signalWithContext:arg1];
                    return;
                }
            }];
        } else {
            v24 = FBSWorkspaceErrorCreate(0, 2, @"the host has not configured a delegate for workspace \"%@\"", self->_identifier);
            [v0 invalidateWithError:v24];
        }
        return;
    }
    id eventDispatcher = [self->_processManager eventDispatcher];
    id domain = [eventDispatcher domain];
    id preregisteredWorkspaces = [domain preregisteredWorkspaces];
    NSString *identifier2 = [self identifier];
    id v9 = [preregisteredWorkspaces objectForKey:identifier2];
    if (([v9 acceptsClientScenes] & 1) != 0 || [self->_delegate delegateHandlesClientScenes] != 0) {
        id identifier = [options identifier];
        id v13 = [self sceneWithIdentifier:identifier];
        if (!v13) {
            FBSSceneClientIdentity *clientIdentity = [v0 clientIdentity];
            if (!clientIdentity) {
                NSString *v36 = [NSString stringWithFormat:@"we should never get a scene request without a clientIdentity specified by the time it gets through the dispatcher : %@", v0];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v37 = NSStringFromSelector(_cmd);
                    NSString *v38 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBSceneWorkspace.m", 560, v36);
                }
                _bs_set_crash_log_message([v36 UTF8String]);
                __break(0);
            }
            v13 = [self createScene:^void(id<FBSceneCreating_Internal> arg1) {
                NSString *v46 = [options identifier];
                if (!v46) {
                    NSUUID *UUID = [NSUUID UUID];
                    NSString *UUIDString = [UUID UUIDString];
                    [arg1 setIdentifier:UUIDString];
                } else {
                    [arg1 setIdentifier:v46];
                }
                [arg1 setClientIdentity:clientIdentity];
                FBSSceneSpecification *specification = [options specification];
                if (!specification) {
                    FBSSceneSpecification *specification2 = [FBSSceneSpecification specification];
                    [arg1 setSpecification:specification2];
                } else {
                    [arg1 setSpecification:specification];
                }
                [arg1 configureParameters:^void(FBSMutableSceneParameters *arg1) {
                    id initialSettings = [options initialSettings];
                    [arg1 setSettings:initialSettings];
                    [arg1 updateSettingsWithBlock:^void(FBSMutableSceneSettings *arg1) {
                        [arg1 setClientFuture:1];
                        [arg1 setClientProcess:v4];
                    }];
                    FBSSceneClientSettings *initialClientSettings = [options initialClientSettings];
                    [arg1 setClientSettings:initialClientSettings];
                }];
            }];
            if ([v13 isActive]) {
                NSString *v40 = [NSString stringWithFormat:@"it's not valid to activate this kind of scene from workspace:didAddScene:"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v41 = NSStringFromSelector(_cmd);
                    NSString *v42 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v42, self, @"FBSceneWorkspace.m", 574, v40);
                }
                _bs_set_crash_log_message([v40 UTF8String]);
                __break(0);
            }
        }
        if (![v13 isActive]) {
            FBSSceneSettings *settings = [v13 settings];
            if ([settings isClientFuture]) {
                [v0 observeScene:v13];
                if (![v13 isValid]) {
                    return;
                }
                if (![self->_delegate delegateHandlesClientScenes]) {
                    [v13 activate:nil];
                    return;
                }
                FBSSceneTransitionContext *transitionContext = [options transitionContext];
                [self->_delegate workspace:self didReceiveScene:v13 withContext:transitionContext fromProcess:v4];
                return;
            }
        }
        id v18 = FBSWorkspaceErrorCreate(0, 2, @"Workspace \"%@\" already has a scene with identifier \"%@\"", self->_identifier, identifier);
        [v0 invalidateWithError:v18];
        return;
    }
    id _legacyWorkspace = [self _legacyWorkspace];
    id v45 = FBSWorkspaceErrorCreate(0, 2, (!_legacyWorkspace) ? @"Workspace \"%@\" does not support client-specified scenes" : @"Legacy FBSceneManager does not support client scene futures");
    [v0 invalidateWithError:v45];
}


void -[FBSceneWorkspace setClientIdentity:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace setClientIdentity:]");
    }
    if (!self->_buildingDefinition) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_buildingDefinition != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v3, self, @"FBSceneWorkspace.m", 440, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    if (!a1) {
        NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"clientID != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSceneWorkspace.m", 441, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    id fbs_sceneClientIdentity = [a1 fbs_sceneClientIdentity];
    if (!fbs_sceneClientIdentity) {
        NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"realID != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBSceneWorkspace.m", 443, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    [self->_buildingDefinition setClientIdentity:fbs_sceneClientIdentity];
}


void -[FBSceneWorkspace setSpecification:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace setSpecification:]");
    }
    if (!self->_buildingDefinition) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_buildingDefinition != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneWorkspace.m", 433, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    Class v1 = NSClassFromString(@"FBSSceneSpecification");
    if (!a1) {
        NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSceneWorkspace.m", 434, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSpecificationClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBSceneWorkspace.m", 434, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    [self->_buildingDefinition setSpecification:a1];
}


void -[FBSceneWorkspace setIdentifier:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace setIdentifier:]");
    }
    if (!self->_buildingDefinition) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_buildingDefinition != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBSceneWorkspace.m", 418, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    Class v1 = NSClassFromString(@"NSString");
    if (!a1) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBSceneWorkspace.m", 419, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSceneWorkspace.m", 419, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    RBSProcessIdentity *v2 = [FBSSceneIdentity identityForIdentifier:a1 workspaceIdentifier:self->_identifier];
    [self->_buildingDefinition setIdentity:v2];
}


void -[FBSceneWorkspace sceneDidInvalidate:](id a1)
{
    id v3 = a1;
    [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
        [arg1 workspace:self willRemoveScene:a1];
    }];
    id identifier = [v3 identifier];
    [self->_allScenesByID removeObjectForKey:identifier];
    id _legacyWorkspace = [self _legacyWorkspace];
    if (_legacyWorkspace != nil) {
        [self _iterateObservers:^void(FBSceneManagerObserver *arg1) {
            [arg1 sceneManager:_legacyWorkspace didDestroyScene:v3];
        }];
    }
}


FBSceneWorkspace *-[FBSceneWorkspace initWithIdentifier:](NSString *a1)
{
    id v1 = FBLegacySceneWorkspaceIdentifier;
    if ([FBLegacySceneWorkspaceIdentifier isEqualToString:a1]) {
        NSString *v5 = [NSString stringWithFormat:@"%@ is reserved", v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBSceneWorkspace.m", 122, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    } else {
        return [self _initWithProcessManager:[FBProcessManager sharedInstance] identifier:a1];
    }
}


FBSceneWorkspace *-[FBSceneWorkspace _initWithProcessManager:identifier:](FBProcessManager *a1, id a2)
{
    id v2 = a2;
    if (!self) {
        return self;
    }
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace _initWithProcessManager:identifier:]");
    }
    if (!a1) {
        NSString *v32 = NSStringFromClass([FBProcessManager class]);
        NSString *v33 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"processManager", v32];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v3 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v34 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v34, self, @"FBSceneWorkspace.m", 74, v33);
        }
        _bs_set_crash_log_message([v33 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[FBProcessManager class]]) {
        Class v36 = [a1 classForCoder];
        if (!v36) {
            v36 = [a1 class];
        }
        NSString *v37 = NSStringFromClass(v36);
        NSString *v38 = NSStringFromClass([FBProcessManager class]);
        NSString *v39 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"processManager", v37, v38];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v40 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v41 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v41, self, @"FBSceneWorkspace.m", 74, v39);
        }
        _bs_set_crash_log_message([v39 UTF8String]);
        __break(0);
    }
    Class aClass = [NSString class];
    if (!v2) {
        NSString *v6 = NSStringFromClass(aClass);
        NSString *v7 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"identifier", v6];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v43 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v43, self, @"FBSceneWorkspace.m", 75, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![v2 isKindOfClass:aClass]) {
        Class v45 = [v2 classForCoder];
        if (!v45) {
            v45 = [v2 class];
        }
        NSString *v46 = NSStringFromClass(v45);
        NSString *v47 = NSStringFromClass([NSString class]);
        NSString *v48 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"identifier", v46, v47];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v49 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v50 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBSceneWorkspace.m", 75, v48);
        }
        _bs_set_crash_log_message([v48 UTF8String]);
        __break(0);
    }
    dispatch_once(&_initWithProcessManager:identifier:.onceToken, ^void(void) {
        _class_setCustomDeallocInitiation([FBSceneWorkspace class]);
    });
    os_unfair_lock_lock(&__WorkspacesLock);
    if (!__Workspaces) {
        __Workspaces = [[NSMutableDictionary alloc] init];
    }
    if (![v2 isKindOfClass:NSClassFromString(@"NSString")]) {
        NSString *v52 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v53 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v54 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v53, v54, self, @"FBSceneWorkspace.m", 87, v52);
        }
        _bs_set_crash_log_message([v52 UTF8String]);
        __break(0);
    }
    id v8 = [__Workspaces objectForKey:v2];
    if (v8 != nil) {
        NSString *v56 = [NSString stringWithFormat:@"workspace already exists with identifier \"%@\"", v2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v57 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v58 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v57, v58, self, @"FBSceneWorkspace.m", 88, v56);
        }
        _bs_set_crash_log_message([v56 UTF8String]);
        __break(0);
    }
    id v9 = [self->_processManager legacySceneManagerCreatingIfNecessary:0];
    id v12 = [v9 scenesPassingTest:^bool(FBScene *arg1, bool *arg2) {
        NSString *workspaceIdentifier = [arg1 workspaceIdentifier];
        long v65 = BSEqualStrings(workspaceIdentifier, v2);
        return v65;
    }];
    if ([v12 count] != 0) {
        NSString *v60 = [NSString stringWithFormat:@"legacy scene manager contains scene with workspaceID \"%@\"", v2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v61 = NSStringFromSelector(@selector(_initWithProcessManager:identifier:));
            NSString *v62 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v61, v62, self, @"FBSceneWorkspace.m", 93, v60);
        }
        _bs_set_crash_log_message([v60 UTF8String]);
        __break(0);
    }
    FBSceneWorkspace *v16 = [super init];
    if (v16 != nil) {
        v16->_processManager = a1;
        v16->_lock._os_unfair_lock_opaque = 0;
        v16->_identifier = [v2 copy];
        v16->_allScenesByID = [[NSMutableDictionary alloc] init];
        v16->_lock_observers = [[NSMutableOrderedSet alloc] init];
        id eventDispatcher = [v16->_processManager eventDispatcher];
        v16->_eventDispatcherTargetRegistration = [eventDispatcher registerTarget:v16];
        id domain = [eventDispatcher domain];
        [domain injectEndpointToFBSWorkspace];
        NSString *v27 = [NSString stringWithFormat:@"FBSceneWorkspace minus scenes - %@", v16->_identifier];
        __weak FBSceneWorkspace *v14 = v16;
        v16->_stateCaptureAssertion = BSLogAddStateCaptureBlockForUserRequestsOnlyWithTitle(dispatch_get_main_queue(), v27, ^id(void) {
            id succinctDescription = [v14 succinctDescription];
            return succinctDescription;
        });
        [__Workspaces setObject:v16 forKey:v16->_identifier];
    }
    os_unfair_lock_unlock(&__WorkspacesLock);
    self = v16;
    return self;
}


void -[FBSceneWorkspace setDelegate:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace setDelegate:]");
    }
    self->_delegate = [[FBSceneManagerObserver alloc] initWithDelegate:a1 workspace:self];
}


id -[FBSceneWorkspace sceneWithIdentityToken:](id a1)
{
    id v3;
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace sceneWithIdentityToken:]");
    }
    if (!a1) {
        NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"token"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSceneWorkspace.m", 196, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    id identifier = [a1 identifier];
    id v2 = [self sceneWithIdentifier:identifier];
    if (!v2) {
        return nil;
    }
    FBSSceneIdentityToken *identityToken = [v2 identityToken];
    if ([identityToken isEqual:a1]) {
        v3 = v2;
    } else {
        v3 = nil;
    }
    return v3;
}


void -[FBSceneWorkspace removeObserver:](long a1)
{
    os_unfair_lock_lock(&self->_lock);
    id v1 = [self->_lock_observers copy];
    for (id v6 in v1) {
        id observer = [v6 observer];
        if (!observer || observer == a1) {
            [self->_lock_observers removeObject:v6];
        }
    }
    os_unfair_lock_unlock(&self->_lock);
}


long -[FBSceneWorkspace description](void)
{
    return [self succinctDescription];
}


id -[FBSceneWorkspace succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneWorkspace succinctDescriptionBuilder](void)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace succinctDescriptionBuilder]");
    }
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_identifier withName:0];
    NSUInteger count = [self->_allScenesByID count];
    [v0 appendUnsignedInteger:count withName:@"scenes"];
    return v0;
}


FBSceneWorkspace *-[FBSceneWorkspace init](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    NSUUID *UUID = [NSUUID UUID];
    return [self _initWithProcessManager:sharedInstance identifier:[UUID UUIDString]];
}


FBSceneWorkspace *+[FBSceneWorkspace workspaceWithIdentifier:](NSString *a1)
{
    id v1 = FBLegacySceneWorkspaceIdentifier;
    if ([FBLegacySceneWorkspaceIdentifier isEqualToString:a1]) {
        NSString *v5 = [NSString stringWithFormat:@"%@ is reserved", v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBSceneWorkspace.m", 127, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return [[FBSceneWorkspace alloc] _initWithProcessManager:[FBProcessManager sharedInstance] identifier:a1];
}


void -[FBSceneWorkspace _objc_initiateDealloc](void)
{
    if (pthread_main_np() != 0) {
        _objc_deallocOnMainThreadHelper(self);
        return;
    }
    dispatch_async_f(dispatch_get_main_queue(), self, &_objc_deallocOnMainThreadHelper);
}


void -[FBSceneWorkspace dealloc](void)
{
    if (!self->_invalidated) {
        NSString *v1 = [NSString stringWithFormat:@"this object must be invalidated before it is released"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneWorkspace.m", 140, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


id -[FBSceneWorkspace delegate](void)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace delegate]");
    }
    return [self->_delegate delegate];
}


id +[FBSceneWorkspace sceneIdentityTokenForIdentifier:workspaceIdentifier:](id a1, id a2)
{
    Class v1 = NSClassFromString(@"NSString");
    if (!a1) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBSceneWorkspace.m", 212, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSceneWorkspace.m", 212, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    Class v3 = NSClassFromString(@"NSString");
    if (!a2) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBSceneWorkspace.m", 213, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v3]) {
        NSString *v19 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(_cmd);
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBSceneWorkspace.m", 213, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    id sharedInstance = [FBProcessManager sharedInstance];
    id incomingWorkspaceEndpoint = [sharedInstance incomingWorkspaceEndpoint];
    return [FBSSceneIdentityToken tokenWithHostEndpoint:incomingWorkspaceEndpoint workspace:a2 identifier:a1];
}


long -[FBSceneWorkspace createSceneWithDefinition:](long a1)
{
    return [self _createSceneWithDefinition:a1 settings:0 initialClientSettings:0 transitionContext:0 fromRemnant:0 usingClientProvider:0 completion:0];
}


id -[FBSceneWorkspace createSceneFromRemnant:withSettings:transitionContext:](id a1, id a2, id a3)
{
    id definition = [a1 definition];
    FBSSceneClientSettings *_clientSettings = [a1 _clientSettings];
    return [self _createSceneWithDefinition:definition settings:a2 initialClientSettings:_clientSettings transitionContext:a3 fromRemnant:a1 usingClientProvider:0 completion:0];
}


BOOL -[FBSceneWorkspace invalidate](void)
{
    BOOL isMainThread = [NSThread isMainThread];
    if (!isMainThread) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneWorkspace invalidate]");
    }
    if (self->_invalidated) {
        return isMainThread;
    }
    if ([self->_allScenesByID count] != 0) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_allScenesByID count] == 0"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBSceneWorkspace.m", 244, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    self->_invalidated = YES;
    [self->_eventDispatcherTargetRegistration invalidate];
    self->_eventDispatcherTargetRegistration = nil;
    [self->_stateCaptureAssertion invalidate];
    self->_stateCaptureAssertion = nil;
    self->_delegate = nil;
    os_unfair_lock_lock(&self->_lock);
    self->_lock_observers = nil;
    os_unfair_lock_unlock(&self->_lock);
    os_unfair_lock_lock(&__WorkspacesLock);
    [__Workspaces removeObjectForKey:self->_identifier];
    return os_unfair_lock_unlock(&__WorkspacesLock);
}


long -[FBSceneWorkspace debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id +[FBSceneWorkspace debugDescription](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:0];
    [v0 modifyProem:^void(void) {
        [v0 appendString:@"All Workspaces" withName:0];
    }];
    os_unfair_lock_lock(&__WorkspacesLock);
    [v0 appendDictionarySection:__Workspaces withName:0 skipIfEmpty:0];
    os_unfair_lock_unlock(&__WorkspacesLock);
    return [v0 build];
}


id -[FBSceneWorkspace descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBSceneWorkspace descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    if ([self->_allScenesByID count] != 0) {
        [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
            NSArray *allValues = [self->_allScenesByID allValues];
            [succinctDescriptionBuilder appendArraySection:allValues withName:@"scenes" skipIfEmpty:1];
        }];
    }
    return succinctDescriptionBuilder;
}


void -[FBSceneWorkspace .cxx_destruct](void)
{
    self->_identifier = nil;
    self->_buildingParameters = nil;
    self->_buildingDefinition = nil;
    self->_allScenesByID = nil;
    self->_lock_observers = nil;
    self->_delegate = nil;
    self->_stateCaptureAssertion = nil;
    self->_eventDispatcherTargetRegistration = nil;
    self->_processManager = nil;
}


void -[FBSceneWorkspace _setSuppressConnectionHandshakes:](bool a1)
{
    if (self != 0) {
        self->_suppressConnectionHandshakes = a1;
    }
}
