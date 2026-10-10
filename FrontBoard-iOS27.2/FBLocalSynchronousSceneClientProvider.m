struct FBLocalSynchronousSceneClientProvider {
    NSMutableArray *_pendingSceneCreatesBeforeFBSWorkspaceInitialization; // +0x8
    NSMutableDictionary *_localSceneInfoByIdentity; // +0x10
    NSMutableDictionary *_hostsByIdentity; // +0x18
    NSMutableSet *_pendingScenes; // +0x20
    id<FBSProcess> _currentProcess; // +0x28
    FBSWorkspaceCoupler *_coupler; // +0x30
    FBSWorkspace *_callOutQueue_workspace; // +0x38
    FBWorkspaceEventDispatcher *_eventDispatcher; // +0x40
    NSMutableSet *_clientFutureHostsBeingSynchronized; // +0x48
    NSMutableSet *_clientFutureScenesBeingSynchronized; // +0x50
    bool _invalidated; // +0x58
};

void -[FBLocalSynchronousSceneClientProvider _sendToHost:updatedClientSettings:withDiff:transitionContext:](id a1, id a2, id a3, id a4)
{
    if (self != nil) {
        id callOutQueue = [self callOutQueue];
        [callOutQueue assertBarrierOnQueue];
        if (self->_invalidated == 1) {
            NSString *v5 = [NSString stringWithFormat:@"illegal operation after invalidation"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(_sendToHost:updatedClientSettings:withDiff:transitionContext:));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBLocalSynchronousSceneClientProvider.m", 526, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        [a1 clientToken:self didUpdateClientSettings:a2 withDiff:a3 transitionContext:a4];
    }
}


long -[FBLocalSynchronousSceneClientProvider callOutQueue](void)
{
    return [FBWorkspaceEventDispatcher callOutQueue];
}


void -[FBLocalSynchronousSceneClientProvider scene:didUpdateClientSettings:withDiff:transitionContext:](id a1, id a2, id a3, id a4)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v1 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBLocalSynchronousSceneClientProvider.m", 346, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    id identity = [a1 identity];
    if ([self->_clientFutureScenesBeingSynchronized containsObject:a1]) {
        NSString *v8 = [NSString stringWithFormat:@"cannot currently support updates from a local scene during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBLocalSynchronousSceneClientProvider.m", 348, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    id v6 = [self->_hostsByIdentity objectForKey:identity];
    [self _sendToHost:v6 updatedClientSettings:a2 withDiff:a3 transitionContext:a4];
}


void -[FBLocalSynchronousSceneClientProvider host:didUpdateSettings:withDiff:transitionContext:completion:](id a1, FBSSceneSettings *a2, id a3, id a4, id a5)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v9 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBLocalSynchronousSceneClientProvider.m", 267, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    id definition = [a1 definition];
    id identity = [definition identity];
    _FBLocalSceneInfo *v8 = [self->_localSceneInfoByIdentity objectForKey:identity];
    if (v8 != nil && v8->field_16 != 0) {
        if ([self->_pendingScenes containsObject:v8->field_16]) {
            NSString *v13 = [NSString stringWithFormat:@"cannot update from a local host while the scene is still pending : %@", identity];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v14 = NSStringFromSelector(_cmd);
                NSString *v15 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBLocalSynchronousSceneClientProvider.m", 273, v13);
            }
            _bs_set_crash_log_message([v13 UTF8String]);
            __break(0);
        }
        if ([self->_clientFutureHostsBeingSynchronized containsObject:a1]) {
            NSString *v17 = [NSString stringWithFormat:@"cannot currently support updating from a local host during the sync phase of connection : %@", identity];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v18 = NSStringFromSelector(_cmd);
                NSString *v19 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBLocalSynchronousSceneClientProvider.m", 274, v17);
            }
            _bs_set_crash_log_message([v17 UTF8String]);
            __break(0);
        }
        [self _sendToSceneWithInfo:v8 updatedSettings:a2 withDiff:a3 transitionContext:a4 completion:a5];
        return;
    }
    NSString *v21 = [NSString stringWithFormat:@"Scene info for %@ was expected, but not found.", identity];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v22 = NSStringFromSelector(_cmd);
        NSString *v23 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBLocalSynchronousSceneClientProvider.m", 272, v21);
    }
    _bs_set_crash_log_message([v21 UTF8String]);
    __break(0);
}


void -[FBLocalSynchronousSceneClientProvider _sendToSceneWithInfo:updatedSettings:withDiff:transitionContext:completion:](_FBLocalSceneInfo *a1, FBSSceneSettings *a2, id a3, id a4, void (^a5)(int, long))
{
    id v7;
    _FBLocalSceneInfo *v0 = a1;
    FBSSceneSettings *v1 = a2;
    id v3 = a4;
    void (^v4)(int, long) = a5;
    if (!self) {
        return;
    }
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v19 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(@selector(_sendToSceneWithInfo:updatedSettings:withDiff:transitionContext:completion:));
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBLocalSynchronousSceneClientProvider.m", 533, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    if (v0 != nil) {
        v7 = v0->field_16;
        if ((v0->field_8 & 1) != 0) {
            [v7 updater:self didUpdateSettings:v1 withDiff:a3 transitionContext:v3 completion:^void(FBSWorkspaceSceneUpdateResponse *arg1) {
                if (!v4) {
                    return;
                } else {
                    v4(1, 0);
                    return;
                }
            }];
            return;
        }
        v0->field_8 = 1;
    } else {
        v7 = nil;
    }
    if (a3 != nil) {
        [v7 _configureParameters:^void(FBSMutableSceneParameters *arg1) {
            [arg1 setSettings:v1];
        }];
    }
    __block bool v10 = false;
    [v7 _callOutQueue_didCreateWithTransitionContext:v3 alternativeCreationCallout:^void(void) {
        v10 = true;
        [v0 setPendingTransitionContext:v3];
        id v24 = self;
        if (self->_callOutQueue_workspace != nil) {
            [v24 _sendSceneCreateFBSWorkspaceDelegateForSceneInfo:v0];
            return;
        }
        if ([self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization containsObject:v0] == 0) {
            [self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization addObject:v0];
            return;
        }
    } completion:0];
    if (v10) {
        if (v4 != nil) {
            v4(1, 0);
        }
        return;
    }
    NSString *v15 = [NSString stringWithFormat:@"creation callback was not made in scene's didCreate"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v16 = NSStringFromSelector(@selector(_sendToSceneWithInfo:updatedSettings:withDiff:transitionContext:completion:));
        NSString *v17 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBLocalSynchronousSceneClientProvider.m", 562, v15);
    }
    _bs_set_crash_log_message([v15 UTF8String]);
    __break(0);
}


void -[FBLocalSynchronousSceneClientProvider registerHost:settings:initialClientSettings:fromRemnant:error:](SEL a1, id a2, FBSSceneSettings *a3, FBSSceneClientSettings *a4, id a5)
{
    NSString *v1 = a2;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (a5 != nil) {
        NSString *v46 = [NSString stringWithFormat:@"synchronous-local scenes cannot have remnants"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v47 = NSStringFromSelector(a1);
            NSString *v48 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v47, v48, self, @"FBLocalSynchronousSceneClientProvider.m", 163, v46);
        }
        _bs_set_crash_log_message([v46 UTF8String]);
        __break(0);
    }
    FBSSceneIdentityToken *identityToken = [v1 identityToken];
    Class v4 = NSClassFromString(@"FBSSceneIdentityToken");
    if (!identityToken) {
        NSString *v50 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v51 = NSStringFromSelector(a1);
            NSString *v52 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v51, v52, self, @"FBLocalSynchronousSceneClientProvider.m", 165, v50);
        }
        _bs_set_crash_log_message([v50 UTF8String]);
        __break(0);
    }
    if (![identityToken isKindOfClass:v4]) {
        NSString *v54 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityTokenClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v55 = NSStringFromSelector(a1);
            NSString *v56 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v55, v56, self, @"FBLocalSynchronousSceneClientProvider.m", 165, v54);
        }
        _bs_set_crash_log_message([v54 UTF8String]);
        __break(0);
    }
    id definition = [v1 definition];
    id<NSCopying> identity = [definition identity];
    Class v7 = NSClassFromString(@"FBSSceneIdentity");
    if (!identity) {
        NSString *v58 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v59 = NSStringFromSelector(a1);
            NSString *v60 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v59, v60, self, @"FBLocalSynchronousSceneClientProvider.m", 167, v58);
        }
        _bs_set_crash_log_message([v58 UTF8String]);
        __break(0);
    }
    if (![identity isKindOfClass:v7]) {
        NSString *v62 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v63 = NSStringFromSelector(a1);
            NSString *v64 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v63, v64, self, @"FBLocalSynchronousSceneClientProvider.m", 167, v62);
        }
        _bs_set_crash_log_message([v62 UTF8String]);
        __break(0);
    }
    FBSSceneSpecification *specification = [v1 specification];
    Class v9 = NSClassFromString(@"FBSSceneSpecification");
    if (!specification) {
        NSString *v66 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v67 = NSStringFromSelector(a1);
            NSString *v68 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v67, v68, self, @"FBLocalSynchronousSceneClientProvider.m", 169, v66);
        }
        _bs_set_crash_log_message([v66 UTF8String]);
        __break(0);
    }
    if (![specification isKindOfClass:v9]) {
        NSString *v70 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSpecificationClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v71 = NSStringFromSelector(a1);
            NSString *v72 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v71, v72, self, @"FBLocalSynchronousSceneClientProvider.m", 169, v70);
        }
        _bs_set_crash_log_message([v70 UTF8String]);
        __break(0);
    }
    Class v11 = NSClassFromString(@"FBSSceneSettings");
    if (!a3) {
        NSString *v74 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v75 = NSStringFromSelector(a1);
            NSString *v76 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v75, v76, self, @"FBLocalSynchronousSceneClientProvider.m", 170, v74);
        }
        _bs_set_crash_log_message([v74 UTF8String]);
        __break(0);
    }
    if (![a3 isKindOfClass:v11]) {
        NSString *v78 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v79 = NSStringFromSelector(a1);
            NSString *v80 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v79, v80, self, @"FBLocalSynchronousSceneClientProvider.m", 170, v78);
        }
        _bs_set_crash_log_message([v78 UTF8String]);
        __break(0);
    }
    Class settingsClass = [specification settingsClass];
    if (![a3 isKindOfClass:settingsClass]) {
        NSString *v82 = [NSString stringWithFormat:@"settings of an unexpected class"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v83 = NSStringFromSelector(a1);
            NSString *v84 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v83, v84, self, @"FBLocalSynchronousSceneClientProvider.m", 171, v82);
        }
        _bs_set_crash_log_message([v82 UTF8String]);
        __break(0);
    }
    Class v14 = NSClassFromString(@"FBSSceneClientSettings");
    if (!a4) {
        NSString *v86 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v87 = NSStringFromSelector(a1);
            NSString *v88 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v87, v88, self, @"FBLocalSynchronousSceneClientProvider.m", 172, v86);
        }
        _bs_set_crash_log_message([v86 UTF8String]);
        __break(0);
    }
    if (![a4 isKindOfClass:v14]) {
        NSString *v90 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneClientSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v91 = NSStringFromSelector(a1);
            NSString *v92 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v91, v92, self, @"FBLocalSynchronousSceneClientProvider.m", 172, v90);
        }
        _bs_set_crash_log_message([v90 UTF8String]);
        __break(0);
    }
    Class clientSettingsClass = [specification clientSettingsClass];
    if (![a4 isKindOfClass:clientSettingsClass]) {
        NSString *v94 = [NSString stringWithFormat:@"initialClientSettings of an unexpected class"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v95 = NSStringFromSelector(a1);
            NSString *v96 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v95, v96, self, @"FBLocalSynchronousSceneClientProvider.m", 173, v94);
        }
        _bs_set_crash_log_message([v94 UTF8String]);
        __break(0);
    }
    if (self->_invalidated == 1) {
        NSString *v98 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v99 = NSStringFromSelector(a1);
            NSString *v100 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v99, v100, self, @"FBLocalSynchronousSceneClientProvider.m", 174, v98);
        }
        _bs_set_crash_log_message([v98 UTF8String]);
        __break(0);
    }
    if (![self->_hostsByIdentity objectForKey:identity]) {
        _FBLocalSceneInfo *v18 = [self->_localSceneInfoByIdentity objectForKey:identity];
        if (!v18) {
            id v20 = [FBSMutableSceneParameters parametersForSpecification:specification];
            [v20 setSettings:a3];
            [v20 setClientSettings:a4];
            FBSScene *v19 = [[FBSScene alloc] _initWithUpdater:self identityToken:identityToken identity:identity parameters:v20 hostHandle:[FBSSceneHostHandle localHandle]];
            _FBLocalSceneInfo *v124 = [[_FBLocalSceneInfo alloc] initWithScene:v19];
            [self->_localSceneInfoByIdentity setObject:v124 forKey:identity];
            [self->_hostsByIdentity setObject:v1 forKey:identity];
        } else {
            id v125 = v18->field_16;
            if (![self->_pendingScenes containsObject:v18->field_16]) {
                NSString *v43 = [NSString stringWithFormat:@"already registered scene for %@ is not in the pending set: %@", identity, v125];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v0 = NSStringFromSelector(a1);
                    NSString *v102 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v102, self, @"FBLocalSynchronousSceneClientProvider.m", 195, v43);
                }
                _bs_set_crash_log_message([v43 UTF8String]);
                __break(0);
            }
            [self->_pendingScenes removeObject:v125];
            if ((v18->field_9 & 1) == 0) {
                NSString *v104 = [NSString stringWithFormat:@"must have already sent the scene create: %@", v125];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v105 = NSStringFromSelector(a1);
                    NSString *v106 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v105, v106, self, @"FBLocalSynchronousSceneClientProvider.m", 197, v104);
                }
                _bs_set_crash_log_message([v104 UTF8String]);
                __break(0);
            }
            [self->_hostsByIdentity setObject:v1 forKey:identity];
            if (!self->_clientFutureHostsBeingSynchronized) {
                self->_clientFutureHostsBeingSynchronized = [NSMutableSet setWithObject:v1];
            } else {
                if ([self->_clientFutureHostsBeingSynchronized containsObject:v1]) {
                    v1 = [NSString stringWithFormat:@"somehow already initializing this host? host=%@ : beingInitialized=%@", v1, self->_clientFutureHostsBeingSynchronized];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v108 = NSStringFromSelector(a1);
                        NSString *v109 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v108, v109, self, @"FBLocalSynchronousSceneClientProvider.m", 201, v1);
                    }
                    _bs_set_crash_log_message([v1 UTF8String]);
                    __break(0);
                }
                [self->_clientFutureHostsBeingSynchronized addObject:v1];
            }
            if (self->_clientFutureScenesBeingSynchronized != nil) {
                if ([self->_clientFutureScenesBeingSynchronized containsObject:v125]) {
                    NSString *v126 = [NSString stringWithFormat:@"somehow already initializing this scene? scene=%@ : beingInitialized=%@", v125, self->_clientFutureScenesBeingSynchronized];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v111 = NSStringFromSelector(a1);
                        NSString *v112 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v111, v112, self, @"FBLocalSynchronousSceneClientProvider.m", 207, v126);
                    }
                    _bs_set_crash_log_message([v126 UTF8String]);
                    __break(0);
                }
                [self->_clientFutureScenesBeingSynchronized addObject:v125];
            } else {
                self->_clientFutureScenesBeingSynchronized = [NSMutableSet setWithObject:v125];
            }
            FBSSceneClientSettings *clientSettings = [v125 clientSettings];
            if ((BSEqualObjects(a4, clientSettings) & 1) == 0) {
                id v30 = [FBSSceneClientSettingsDiff diffFromSettings:a4 toSettings:clientSettings];
                if (v30 != nil) {
                    os_log_t oslog = FBLogCommon();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Local scene future %{public}@ has out-of-date clientSettings : %@", identity, v30);
                    }
                    [self _sendToHost:v1 updatedClientSettings:clientSettings withDiff:v30 transitionContext:0];
                }
            }
            FBSSceneSettings *settings = [v125 settings];
            if ((BSEqualObjects(settings, a3) & 1) == 0) {
                id v35 = [FBSSceneSettingsDiff diffFromSettings:settings toSettings:a3];
                if (v35 != nil) {
                    os_log_t oslog2 = FBLogCommon();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Local scene future %{public}@ was activated with modified settings : %@", identity, v35);
                    }
                    [self _sendToSceneWithInfo:v18 updatedSettings:a3 withDiff:v35 transitionContext:nil completion:nil];
                }
            }
            if (![self->_clientFutureHostsBeingSynchronized containsObject:v1]) {
                NSString *v44 = [NSString stringWithFormat:@"something bad happened that removed the host prematurely from the initializing set : host=%@ beingInitialized=%@", v1, self->_clientFutureHostsBeingSynchronized];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v116 = NSStringFromSelector(a1);
                    NSString *v117 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v116, v117, self, @"FBLocalSynchronousSceneClientProvider.m", 233, v44);
                }
                _bs_set_crash_log_message([v44 UTF8String]);
                __break(0);
            }
            NSUInteger count = [self->_clientFutureHostsBeingSynchronized count];
            NSMutableSet *v38 = self->_clientFutureHostsBeingSynchronized;
            if (count != 1) {
                [v38 removeObject:v1];
            } else {
                self->_clientFutureHostsBeingSynchronized = nil;
            }
            if (![self->_clientFutureScenesBeingSynchronized containsObject:v125]) {
                NSString *v45 = [NSString stringWithFormat:@"something bad happened that removed the scene prematurely from the initializing set : scene=%@ beingInitialized=%@", v125, self->_clientFutureScenesBeingSynchronized];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v119 = NSStringFromSelector(a1);
                    NSString *v120 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v119, v120, self, @"FBLocalSynchronousSceneClientProvider.m", 239, v45);
                }
                _bs_set_crash_log_message([v45 UTF8String]);
                __break(0);
            }
            NSUInteger count2 = [self->_clientFutureScenesBeingSynchronized count];
            NSMutableSet *v40 = self->_clientFutureScenesBeingSynchronized;
            if (count2 != 1) {
                [v40 removeObject:v125];
            } else {
                self->_clientFutureScenesBeingSynchronized = nil;
            }
        }
        return;
    }
    id v41 = [self->_hostsByIdentity objectForKey:identity];
    NSString *v42 = [NSString stringWithFormat:@"trying to register a local host for an already known identifier : %@ -> previous=%@", identity, v41];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v122 = NSStringFromSelector(a1);
        NSString *v123 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v122, v123, self, @"FBLocalSynchronousSceneClientProvider.m", 175, v42);
    }
    _bs_set_crash_log_message([v42 UTF8String]);
    __break(0);
}


void -[FBLocalSynchronousSceneClientProvider _sendSceneCreateFBSWorkspaceDelegateForSceneInfo:](id a1)
{
    id v2;
    id v0 = a1;
    if (self != nil) {
        id callOutQueue = [self callOutQueue];
        [callOutQueue assertBarrierOnQueue];
        if (!v0) {
            v2 = nil;
        } else {
            if ((v0->field_9 & 1) != 0) {
                return;
            }
            v0->field_9 = 1;
            v2 = v0->field_16;
        }
        id v3 = v2;
        if (!self->_callOutQueue_workspace) {
            FBSSceneIdentityToken *identityToken = [v3 identityToken];
            NSString *v7 = [NSString stringWithFormat:@"cannot note creation of %@ without a reference to the workspace", identityToken];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v8 = NSStringFromSelector(@selector(_sendSceneCreateFBSWorkspaceDelegateForSceneInfo:));
                NSString *v4 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v4, self, @"FBLocalSynchronousSceneClientProvider.m", 585, v7);
            }
            _bs_set_crash_log_message([v7 UTF8String]);
            __break(0);
        }
        [self->_callOutQueue_workspace _calloutQueue_executeCalloutFromSource:self withBlock:^void(void) {
            id delegate = [self->_callOutQueue_workspace delegate];
            BOOL v11 = [delegate respondsToSelector:@selector(workspace:didCreateScene:withTransitionContext:completion:)];
            if (v11) {
                id delegate2 = [self->_callOutQueue_workspace delegate];
                id v13 = v0;
                if (v0 != nil) {
                    v13 = v13->field_16;
                }
                [delegate2 workspace:self->_callOutQueue_workspace didCreateScene:v13 withTransitionContext:(!v0) ? 0 : v0->field_24 completion:^void(FBSWorkspaceCreateSceneResponse *arg1) {
                }];
                return;
            }
        }];
        [v0 setPendingTransitionContext:0];
    }
}


FBLocalSynchronousSceneClientProvider *-[FBLocalSynchronousSceneClientProvider _initWithWorkspaceCoupler:currentProcess:eventDispatcher:](FBSWorkspaceCoupler *a1, id<FBSProcess> a2, FBWorkspaceEventDispatcher *a3)
{
    FBLocalSynchronousSceneClientProvider *self;
    if (self != nil) {
        if (!a1) {
            NSString *v17 = NSStringFromClass([FBSWorkspaceCoupler class]);
            NSString *v18 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"workspaceCoupler", v17];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v3 = NSStringFromSelector(@selector(_initWithWorkspaceCoupler:currentProcess:eventDispatcher:));
                NSString *v19 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v19, self, @"FBLocalSynchronousSceneClientProvider.m", 81, v18);
            }
            _bs_set_crash_log_message([v18 UTF8String]);
            __break(0);
        }
        if (![a1 isKindOfClass:[FBSWorkspaceCoupler class]]) {
            Class v21 = [a1 classForCoder];
            if (!v21) {
                v21 = [a1 class];
            }
            NSString *v22 = NSStringFromClass(v21);
            NSString *v23 = NSStringFromClass([FBSWorkspaceCoupler class]);
            NSString *v24 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"workspaceCoupler", v22, v23];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v25 = NSStringFromSelector(@selector(_initWithWorkspaceCoupler:currentProcess:eventDispatcher:));
                NSString *v6 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v6, self, @"FBLocalSynchronousSceneClientProvider.m", 81, v24);
            }
            _bs_set_crash_log_message([v24 UTF8String]);
            __break(0);
        }
        if (!a2) {
            NSString *v27 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"currentProcess"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v28 = NSStringFromSelector(@selector(_initWithWorkspaceCoupler:currentProcess:eventDispatcher:));
                NSString *v29 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v28, v29, self, @"FBLocalSynchronousSceneClientProvider.m", 82, v27);
            }
            _bs_set_crash_log_message([v27 UTF8String]);
            __break(0);
        }
        if (!a3) {
            NSString *v31 = NSStringFromClass([FBWorkspaceEventDispatcher class]);
            NSString *v32 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"eventDispatcher", v31];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v33 = NSStringFromSelector(@selector(_initWithWorkspaceCoupler:currentProcess:eventDispatcher:));
                NSString *v34 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v33, v34, self, @"FBLocalSynchronousSceneClientProvider.m", 83, v32);
            }
            _bs_set_crash_log_message([v32 UTF8String]);
            __break(0);
        }
        if (![a3 isKindOfClass:[FBWorkspaceEventDispatcher class]]) {
            Class v36 = [a3 classForCoder];
            if (!v36) {
                v36 = [a3 class];
            }
            NSString *v37 = NSStringFromClass(v36);
            NSString *v38 = NSStringFromClass([FBWorkspaceEventDispatcher class]);
            NSString *v39 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"eventDispatcher", v37, v38];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v40 = NSStringFromSelector(@selector(_initWithWorkspaceCoupler:currentProcess:eventDispatcher:));
                NSString *v41 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v41, self, @"FBLocalSynchronousSceneClientProvider.m", 83, v39);
            }
            _bs_set_crash_log_message([v39 UTF8String]);
            __break(0);
        }
        self = [super init];
        if (self != nil) {
            self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization = [[NSMutableArray alloc] init];
            self->_localSceneInfoByIdentity = [NSMutableDictionary dictionary];
            self->_hostsByIdentity = [NSMutableDictionary dictionary];
            self->_pendingScenes = [NSMutableSet set];
            self->_currentProcess = a2;
            self->_coupler = a1;
            self->_callOutQueue_workspace = nil;
            self->_eventDispatcher = a3;
            [self->_coupler _enqueueClientConnectionBlock:^void(FBSWorkspace *arg1) {
                BSDispatchMain(^void(void) {
                    uint8_t buf;
                    BSServiceQueue *callOutQueue = [self callOutQueue];
                    [callOutQueue assertBarrierOnQueue];
                    bool v50 = self->_invalidated;
                    if (!arg1) {
                        if (v50) {
                            return;
                        }
                        os_log_t oslog3 = FBLogCommon();
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "LocalSynchronousSceneClientProvider failed to receive workspace creation.");
                        }
                        return;
                    } else if (v50) {
                        return;
                    }
                    os_log_t oslog2 = FBLogCommon();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "LocalSynchronousSceneClientProvider received workspace creation.");
                    }
                    self->_callOutQueue_workspace = arg1;
                    void *v53 = self;
                    [self->_callOutQueue_workspace _registerSource:v53];
                    id v54 = [self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization copy];
                    for (id v13 in v54) {
                        os_log_t oslog = FBLogCommon();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                            id v48 = (!v44) ? nil : v44->field_16;
                            id succinctDescription = [v48 succinctDescription];
                            buf = 0x8420102;
                            *(&buf | 4) = succinctDescription;
                            _os_log_impl(&_mh_dylib_header, oslog, OS_LOG_TYPE_DEFAULT, "LocalSynchronousSceneClientProvider sending scene create for: %{public}@", &buf, 12);
                        }
                        [self _sendSceneCreateFBSWorkspaceDelegateForSceneInfo:v44];
                    }
                    [self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization removeAllObjects];
                    self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization = nil;
                });
            }];
        }
    }
    return self;
}


void -[FBLocalSynchronousSceneClientProvider dealloc](void)
{
    if (!self->_invalidated) {
        NSString *v5 = [NSString stringWithFormat:@"must invalidate before dealloc"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBLocalSynchronousSceneClientProvider.m", 120, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBLocalSynchronousSceneClientProvider:%p deallocing.", self);
    }
    [super dealloc];
}


void -[FBLocalSynchronousSceneClientProvider _invalidate](void)
{
    if (!self) {
        return;
    }
    if ([self->_coupler _isSharedInstance] != 0) {
        NSString *v5 = [NSString stringWithFormat:@"this instance may not invalidate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(@selector(_invalidate));
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBLocalSynchronousSceneClientProvider.m", 125, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBLocalSynchronousSceneClientProvider:%p invalidating.", self);
    }
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated) {
        return;
    }
    self->_invalidated = YES;
    if ([self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization count] != 0) {
        NSString *v9 = [NSString stringWithFormat:@"all scenes must be invalidated before the syncLocal provider can invalidate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(@selector(_invalidate));
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBLocalSynchronousSceneClientProvider.m", 131, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    if ([self->_localSceneInfoByIdentity count] != 0) {
        NSString *v13 = [NSString stringWithFormat:@"all scenes must be invalidated before the syncLocal provider can invalidate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v14 = NSStringFromSelector(@selector(_invalidate));
            NSString *v15 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBLocalSynchronousSceneClientProvider.m", 132, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    if ([self->_hostsByIdentity count] != 0) {
        NSString *v17 = [NSString stringWithFormat:@"all scenes must be invalidated before the syncLocal provider can invalidate"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(@selector(_invalidate));
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBLocalSynchronousSceneClientProvider.m", 133, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    self->_callOutQueue_workspace = nil;
}


id -[FBLocalSynchronousSceneClientProvider fbsSceneForScene:](id a1)
{
    id identity = [a1 identity];
    return [self sceneWithIdentity:identity];
}


id -[FBLocalSynchronousSceneClientProvider fbsSceneWithIdentifier:](NSString *a1)
{
    NSArray *allKeys = [self->_localSceneInfoByIdentity allKeys];
    for (id v8 in allKeys) {
        id identifier = [v8 identifier];
        if ([identifier isEqualToString:a1]) {
            v8 = [self->_localSceneInfoByIdentity objectForKey:v8];
            id v5 = (!v8) ? nil : v8->field_16;
            return v5;
        }
    }
    return nil;
}


void -[FBLocalSynchronousSceneClientProvider unregisterHost:](id a1)
{
    id definition = [a1 definition];
    id identity = [definition identity];
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v6 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBLocalSynchronousSceneClientProvider.m", 254, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    if (![self->_localSceneInfoByIdentity objectForKey:identity]) {
        NSString *v10 = [NSString stringWithFormat:@"trying to unregister a local scene for an unknown identifier : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBLocalSynchronousSceneClientProvider.m", 255, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    id v5 = [self->_hostsByIdentity objectForKey:identity];
    if (v5 != a1) {
        NSString *v14 = [NSString stringWithFormat:@"trying to unregister a local host for a mismatched identifier : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v15 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBLocalSynchronousSceneClientProvider.m", 0x100, v14);
        }
        _bs_set_crash_log_message([v14 UTF8String]);
        __break(0);
    }
    if ([self->_clientFutureHostsBeingSynchronized containsObject:a1]) {
        NSString *v18 = [NSString stringWithFormat:@"trying to unregister a local host during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBLocalSynchronousSceneClientProvider.m", 257, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    [self->_localSceneInfoByIdentity removeObjectForKey:identity];
    [self->_hostsByIdentity removeObjectForKey:identity];
}


void -[FBLocalSynchronousSceneClientProvider host:didInvalidateWithTransitionContext:completion:](id a1, id a2, void (^a3)(int, long))
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v1 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBLocalSynchronousSceneClientProvider.m", 281, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    id definition = [a1 definition];
    id identity = [definition identity];
    id v6 = [self->_localSceneInfoByIdentity objectForKey:identity];
    if (!v6) {
        NSString *v10 = [NSString stringWithFormat:@"Must have a scene for it to be invalidated."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBLocalSynchronousSceneClientProvider.m", 284, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    if ([self->_clientFutureHostsBeingSynchronized containsObject:a1]) {
        NSString *v14 = [NSString stringWithFormat:@"cannot currently support invalidating from a local host during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v15 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBLocalSynchronousSceneClientProvider.m", 285, v14);
        }
        _bs_set_crash_log_message([v14 UTF8String]);
        __break(0);
    }
    [self _invalidateSceneInfo:v6 transitionContext:a2];
    if (a3 != nil) {
        a3(1, 0);
    }
}


void -[FBLocalSynchronousSceneClientProvider host:didReceiveActions:forExtension:](id a1, id a2, long a3)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v7 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBLocalSynchronousSceneClientProvider.m", 297, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    id definition = [a1 definition];
    id identity = [definition identity];
    if ([self->_clientFutureHostsBeingSynchronized containsObject:a1]) {
        NSString *v11 = [NSString stringWithFormat:@"cannot currently support actions from a local host during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBLocalSynchronousSceneClientProvider.m", 299, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    id v5 = [self->_localSceneInfoByIdentity objectForKey:identity];
    id v6 = (!v5) ? nil : v5->field_16;
    if (v6 != nil) {
        [v6 updater:self didReceiveActions:a2 forExtension:a3];
    }
}


void -[FBLocalSynchronousSceneClientProvider host:sendInvocation:withReply:](id a1, id a2, id a3)
{
    void (^v2)(long, long) = a3;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v9 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBLocalSynchronousSceneClientProvider.m", 309, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    id definition = [a1 definition];
    id identity = [definition identity];
    if ([self->_clientFutureHostsBeingSynchronized containsObject:a1]) {
        NSString *v13 = [NSString stringWithFormat:@"cannot currently support actions from a local host during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v14 = NSStringFromSelector(_cmd);
            NSString *v15 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBLocalSynchronousSceneClientProvider.m", 311, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    id v6 = [self->_localSceneInfoByIdentity objectForKey:identity];
    id v7 = (!v6) ? nil : v6->field_16;
    if (v7) {
        [a2 invokeWithReceiver:v7 replyHandler:v2];
    } else if (v2 != 0) {
        id v8 = [NSError bs_errorWithDomain:@"FBLocalSynchronousSceneClientProvider" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
            [arg1 setFailureDescription:@"No client scene exists"];
        }];
        v2(0, v8);
    }
}


id<FBSProcess> -[FBLocalSynchronousSceneClientProvider hostProcess](void)
{
    return self->_currentProcess;
}


int -[FBLocalSynchronousSceneClientProvider canHaveAgent](void)
{
    return 0;
}


long -[FBLocalSynchronousSceneClientProvider sendBatchedMessages](void)
{
    return self;
}


void -[FBLocalSynchronousSceneClientProvider scene:didReceiveActions:forExtension:](id a1, id a2, long a3)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v1 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v6 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v6, self, @"FBLocalSynchronousSceneClientProvider.m", 355, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    id identity = [a1 identity];
    if ([self->_clientFutureScenesBeingSynchronized containsObject:a1]) {
        NSString *v8 = [NSString stringWithFormat:@"cannot currently support actions from a local scene during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBLocalSynchronousSceneClientProvider.m", 357, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    id v4 = [self->_hostsByIdentity objectForKey:identity];
    [v4 clientToken:self didReceiveActions:a2 forExtension:a3];
}


void -[FBLocalSynchronousSceneClientProvider scene:sendMessage:withResponse:](id a1, id a2, void (^a3)(long, long))
{
    id identity = [a1 identity];
    if ([self->_clientFutureScenesBeingSynchronized containsObject:a1]) {
        NSString *v5 = [NSString stringWithFormat:@"cannot currently support messages from a local scene during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBLocalSynchronousSceneClientProvider.m", 363, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (a3 != nil) {
        a3(0, 0);
    }
}


void -[FBLocalSynchronousSceneClientProvider scene:invalidateWithTransitionContext:](id a1, id a2)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v1 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v6 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v6, self, @"FBLocalSynchronousSceneClientProvider.m", 371, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    id identity = [a1 identity];
    if ([self->_clientFutureScenesBeingSynchronized containsObject:a1]) {
        NSString *v7 = [NSString stringWithFormat:@"cannot currently support invalidations from a local scene during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBLocalSynchronousSceneClientProvider.m", 373, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    id v11 = [self->_localSceneInfoByIdentity objectForKey:identity];
    [self _invalidateSceneInfo:v11 transitionContext:a2];
    id v12 = [self->_hostsByIdentity objectForKey:identity];
    [v12 clientToken:self deactivateWithContext:a2];
}


void -[FBLocalSynchronousSceneClientProvider scene:sendInvocation:](id a1, id a2)
{
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v6 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBLocalSynchronousSceneClientProvider.m", 382, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    id identity = [a1 identity];
    if ([self->_clientFutureScenesBeingSynchronized containsObject:a1]) {
        NSString *v10 = [NSString stringWithFormat:@"cannot currently support invocations from a local scene during the sync phase of connection : %@", identity];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBLocalSynchronousSceneClientProvider.m", 384, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    id v4 = [self->_hostsByIdentity objectForKey:identity];
    id resolve = [a2 resolve];
    [v4 clientToken:self handleInvocation:a2 withReply:resolve];
}


NSString *-[FBLocalSynchronousSceneClientProvider identifier](void)
{
    return @"LocalSynchronousWorkspace";
}


NSMutableSet *-[FBLocalSynchronousSceneClientProvider scenes](void)
{
    NSMutableSet *set = [NSMutableSet set];
    [self->_localSceneInfoByIdentity enumerateKeysAndObjectsUsingBlock:^void(FBSSceneIdentity *arg1, _FBLocalSceneInfo *arg2, bool *arg3) {
        if (arg2 != 0) {
            arg2 = arg2->field_16;
        }
        [set addObject:arg2];
    }];
    return set;
}


void -[FBLocalSynchronousSceneClientProvider sendActions:toWorkspaceID:completion:](id a1, id a2, id a3)
{
    long v5;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v9 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v10, self, @"FBLocalSynchronousSceneClientProvider.m", 411, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    if (!a2) {
        id domain = [self->_eventDispatcher domain];
        v5 = [domain defaultWorkspace];
    } else {
        v5 = a2;
    }
    FBWorkspaceSceneRequest *v8 = [[FBWorkspaceSceneRequest alloc] initWithTargetIdentifier:v5 actions:a1 completion:^void(FBScene *arg1, NSError *arg2) {
        if (!a3) {
            return;
        } else if (!arg2) {
            a3->field_16(a3, 1, arg2);
            return;
        } else {
            a3->field_16(a3, 0, arg2);
            return;
        }
    }];
    [self->_eventDispatcher handleLocalSceneRequest:v8];
}


FBSScene *-[FBLocalSynchronousSceneClientProvider createSceneFutureWithDefinition:](id a1)
{
    FBSScene *v11;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v22 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v23 = NSStringFromSelector(_cmd);
            NSString *v24 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBLocalSynchronousSceneClientProvider.m", 423, v22);
        }
        _bs_set_crash_log_message([v22 UTF8String]);
        __break(0);
    }
    id v2 = [a1 identity];
    if (![v2 workspaceIdentifier]) {
        id domain2 = [self->_eventDispatcher domain];
        id defaultWorkspace = [domain2 defaultWorkspace];
        if (defaultWorkspace != nil) {
            id identifier2 = [v2 identifier];
            id<NSCopying> v7 = [FBSSceneIdentity identityForIdentifier:identifier2 workspaceIdentifier:defaultWorkspace];
            v2 = v7;
        }
    }
    if (![v2 workspaceIdentifier]) {
        NSString *v26 = [NSString stringWithFormat:@"Cannot create a local scene future with identity=%@ as no default workspace is defined.", v2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v27 = NSStringFromSelector(_cmd);
            NSString *v28 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v27, v28, self, @"FBLocalSynchronousSceneClientProvider.m", 431, v26);
        }
        _bs_set_crash_log_message([v26 UTF8String]);
        __break(0);
    }
    id v9 = [self->_localSceneInfoByIdentity objectForKey:v2];
    if (v9 != nil) {
        NSString *v30 = [NSString stringWithFormat:@"already tracking a scene with identity %@", v2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v31 = NSStringFromSelector(_cmd);
            NSString *v32 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBLocalSynchronousSceneClientProvider.m", 432, v30);
        }
        _bs_set_crash_log_message([v30 UTF8String]);
        __break(0);
    }
    if (![self->_eventDispatcher canCreateLocalSceneWithIdentity:v2]) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            NSString *workspaceIdentifier2 = [v2 workspaceIdentifier];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Cannot create a local scene future for workspace \"%@\".", workspaceIdentifier2);
        }
        v11 = nil;
    } else {
        id parameters = [a1 parameters];
        [parameters updateSettingsWithBlock:^void(FBSMutableSceneSettings *arg1) {
            [arg1 setClientFuture:1];
        }];
        id domain = [self->_eventDispatcher domain];
        id endpointPromise = [domain endpointPromise];
        NSXPCListenerEndpoint *endpoint = [endpointPromise endpoint];
        NSString *workspaceIdentifier = [v2 workspaceIdentifier];
        id identifier = [v2 identifier];
        id v18 = [FBSSceneIdentityToken tokenWithHostEndpoint:endpoint workspace:workspaceIdentifier identifier:identifier];
        v11 = [[FBSScene alloc] _initWithUpdater:self identityToken:v18 identity:v2 parameters:parameters hostHandle:[FBSSceneHostHandle localHandle]];
        _FBLocalSceneInfo *v21 = [[_FBLocalSceneInfo alloc] initWithScene:v11];
        [self->_localSceneInfoByIdentity setObject:v21 forKey:v2];
        [self->_pendingScenes addObject:v11];
    }
    return v11;
}


void -[FBLocalSynchronousSceneClientProvider activateSceneFuture:completion:](id a1, void (^a2)(long, NSError *))
{
    id v0 = a1;
    void (^v1)(long, NSError *) = a2;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v16 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBLocalSynchronousSceneClientProvider.m", 458, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    id identity = [v0 identity];
    _FBLocalSceneInfo *v4 = [self->_localSceneInfoByIdentity objectForKey:identity];
    if (!v4) {
        NSString *v20 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"info != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v21 = NSStringFromSelector(_cmd);
            NSString *v22 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v21, v22, self, @"FBLocalSynchronousSceneClientProvider.m", 461, v20);
        }
        _bs_set_crash_log_message([v20 UTF8String]);
        __break(0);
    }
    if (![self->_pendingScenes containsObject:v0]) {
        NSString *v24 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_pendingScenes containsObject:scene]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v25 = NSStringFromSelector(_cmd);
            NSString *v26 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBLocalSynchronousSceneClientProvider.m", 462, v24);
        }
        _bs_set_crash_log_message([v24 UTF8String]);
        __break(0);
    }
    FBSWorkspaceSceneRequestOptions *v5 = [FBSWorkspaceSceneRequestOptions new];
    NSString *identifier = [v0 identifier];
    [v5 setIdentifier:identifier];
    id identity2 = [v0 identity];
    NSString *workspaceIdentifier = [identity2 workspaceIdentifier];
    [v5 setWorkspaceIdentifier:workspaceIdentifier];
    FBSSceneSpecification *specification = [v0 specification];
    [v5 setSpecification:specification];
    FBSSceneSettings *settings = [v0 settings];
    [v5 setInitialSettings:settings];
    FBSSceneClientSettings *clientSettings = [v0 clientSettings];
    [v5 setInitialClientSettings:clientSettings];
    FBSSceneSettings *settings2 = [v0 settings];
    long isClientFuture = [settings2 isClientFuture];
    [v5 setClientFuture:isClientFuture];
    FBSSceneSettings *settings3 = [v0 settings];
    [self _sendToSceneWithInfo:v4 updatedSettings:settings3 withDiff:nil transitionContext:nil completion:nil];
    [self requestSceneWithOptions:v5 completion:^void(FBSScene *arg1, NSError *arg2) {
        if (arg2 != nil) {
            [self _invalidateSceneInfo:v4 transitionContext:0];
            id identity = [v0 identity];
            [self->_localSceneInfoByIdentity removeObjectForKey:identity];
            [self->_pendingScenes removeObject:v0];
        }
        if (v1 != nil) {
            v1(!arg2, arg2);
        }
    }];
}


void -[FBLocalSynchronousSceneClientProvider requestSceneWithOptions:completion:](id a1, void (^a2)(long, long))
{
    void (^v1)(long, long) = a2;
    id callOutQueue = [self callOutQueue];
    [callOutQueue assertBarrierOnQueue];
    if (self->_invalidated == 1) {
        NSString *v11 = [NSString stringWithFormat:@"illegal operation after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBLocalSynchronousSceneClientProvider.m", 490, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    if (![a1 workspaceIdentifier]) {
        id domain = [self->_eventDispatcher domain];
        id defaultWorkspace = [domain defaultWorkspace];
        if (defaultWorkspace != nil) {
            [a1 setWorkspaceIdentifier:defaultWorkspace];
        }
    }
    NSString *workspaceIdentifier = [a1 workspaceIdentifier];
    if (!workspaceIdentifier) {
        id identifier = [a1 identifier];
        NSString *v16 = [NSString stringWithFormat:@"Cannot request a local scene with identifier=%@ as no default workspace is defined.", identifier];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBLocalSynchronousSceneClientProvider.m", 498, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    id localIdentity = [FBSSceneClientIdentity localIdentity];
    FBWorkspaceSceneRequest *v10 = [[FBWorkspaceSceneRequest alloc] initWithClientIdentity:localIdentity targetIdentifier:workspaceIdentifier options:a1 completion:^void(FBScene *arg1, NSError *arg2) {
        BSDispatchMain(^void(void) {
            long v26;
            if (arg1) {
                v26 = [self fbsSceneForScene:arg1];
                if (!v26) {
                    NSString *v23 = [NSString stringWithFormat:@"no FBSScene for active FBScene"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v24 = NSStringFromSelector(_cmd);
                        NSString *v25 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v24, v25, self, @"FBLocalSynchronousSceneClientProvider.m", 507, v23);
                    }
                    _bs_set_crash_log_message([v23 UTF8String]);
                    __break(0);
                }
                if (v1) {
                    v1(v26, 0);
                }
            } else {
                if (!v1) {
                    return;
                }
                v26 = FBSWorkspaceErrorCreate(arg2, 2, @"Scene was not created.");
                v1(0, v26);
            }
        });
    }];
    [self->_eventDispatcher handleLocalSceneRequest:v10];
}


void -[FBLocalSynchronousSceneClientProvider .cxx_destruct](void)
{
    self->_clientFutureScenesBeingSynchronized = nil;
    self->_clientFutureHostsBeingSynchronized = nil;
    self->_eventDispatcher = nil;
    self->_callOutQueue_workspace = nil;
    self->_coupler = nil;
    self->_currentProcess = nil;
    self->_pendingScenes = nil;
    self->_hostsByIdentity = nil;
    self->_localSceneInfoByIdentity = nil;
    self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization = nil;
}


id +[FBLocalSynchronousSceneClientProvider(SharedInstance) sharedInstance](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    return [sharedInstance syncLocalSceneClientProvider];
}


void -[FBLocalSynchronousSceneClientProvider init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-[FBLocalSynchronousSceneClientProvider init] is unavailable."];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBLocalSynchronousSceneClientProvider.m", 74, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBLocalSynchronousSceneClientProvider _invalidateSceneInfo:transitionContext:](id a1, id a2)
{
    id v1 = a2;
    if (self != nil) {
        id callOutQueue = [self callOutQueue];
        [callOutQueue assertBarrierOnQueue];
        id v3 = (!a1) ? nil : a1->field_16;
        if (!self->_callOutQueue_workspace) {
            [self->_pendingSceneCreatesBeforeFBSWorkspaceInitialization removeObject:a1];
            [v3 _callOutQueue_willDestroyWithTransitionContext:v1 completion:0];
        } else {
            [self->_callOutQueue_workspace _calloutQueue_executeCalloutFromSource:self withBlock:^void(void) {
                if (([v3 _callOutQueue_willDestroyWithTransitionContext:v1 completion:0] & 1) != 0) {
                    return;
                }
                id delegate = [self->_callOutQueue_workspace delegate];
                BOOL v6 = [delegate respondsToSelector:@selector(workspace:willDestroyScene:withTransitionContext:completion:)];
                if (v6 == 0) {
                    return;
                }
                id delegate2 = [self->_callOutQueue_workspace delegate];
                [delegate2 workspace:self->_callOutQueue_workspace willDestroyScene:v3 withTransitionContext:v1 completion:^void(FBSWorkspaceDestroySceneResponse *arg1) {
                }];
            }];
        }
        [v3 _callOutQueue_invalidate];
    }
}


id -[FBLocalSynchronousSceneClientProvider sceneWithIdentity:](id a1)
{
    id v0 = [self->_localSceneInfoByIdentity objectForKey:a1];
    if (!v0) {
        return nil;
    }
    return v0->field_16;
}
