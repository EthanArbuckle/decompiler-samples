struct FBWorkspaceEventDispatcher {
    FBWorkspaceDomain *_domain; // +0x8
    FBWorkspaceConnectionsStateStore *_store; // +0x10
    NSDictionary *_preregisteredWorkspaces; // +0x18
    NSMutableDictionary *_lock_sourcesByPidNumber; // +0x20
    NSMapTable *_lock_targetsByIdentifier; // +0x28
    NSCountedSet *_main_incompleteTargetRegistrations; // +0x30
    NSMutableDictionary *_lock_restartAssertionsByPidNumber; // +0x38
    FBMutableWorkspaceConnectionsState *_lock_mutableState; // +0x40
    struct os_unfair_lock_s _lock; // +0x48
};

static long FBAssertionDomain;

long +[FBWorkspaceEventDispatcher callOutQueue](void)
{
    objc_opt_self(self);
    return [BSServiceDispatchQueue mainQueue];
}


id -[FBWorkspaceEventDispatcher registerSourceWithProcessHandle:](id a1)
{
    bool v14;
    id v16;
    uint8_t v20[32];
    if (!self) {
        return nil;
    }
    if (!a1) {
        NSString *v34 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v35 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"processHandle", v34];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v3 = NSStringFromSelector(@selector(registerSourceWithProcessHandle:));
            NSString *v36 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v36, self, @"FBWorkspaceEventDispatcher.m", 232, v35);
        }
        _bs_set_crash_log_message([v35 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[RBSProcessHandle class]]) {
        NSArray *v0 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v38 = [v0 classForCoder];
        if (!v38) {
            v38 = [v0 class];
        }
        NSString *v39 = NSStringFromClass(v38);
        NSString *v40 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v41 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"processHandle", v39, v40];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v42 = NSStringFromSelector(@selector(registerSourceWithProcessHandle:));
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v42, v7, self, @"FBWorkspaceEventDispatcher.m", 232, v41);
        }
        _bs_set_crash_log_message([v41 UTF8String]);
        __break(0);
    }
    int pid = [a1 pid];
    if (pid <= 0) {
        NSString *v44 = [NSString stringWithFormat:@"invalid pid for %@", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v45 = NSStringFromSelector(@selector(registerSourceWithProcessHandle:));
            NSString *v46 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v45, v46, self, @"FBWorkspaceEventDispatcher.m", 234, v44);
        }
        _bs_set_crash_log_message([v44 UTF8String]);
        __break(0);
    }
    NSNumber *v6 = [NSNumber numberWithInt:pid];
    os_unfair_lock_lock(&self->_lock);
    id v2 = [self->_lock_sourcesByPidNumber objectForKey:v6];
    if (!v2) {
        __weak FBWorkspaceEventDispatcher *v8 = self;
        v2 = [[FBWorkspaceEventDispatcherSource alloc] _initWithProcessHandle:a1 invalidationBlock:^void(FBWorkspaceEventDispatcherSource *arg1) {
            [v8 _noteSourceDidInvalidate:arg1 withPIDNumber:v6];
        }];
        v14 = !self->_lock_sourcesByPidNumber;
        if (!self->_lock_sourcesByPidNumber) {
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Immediately invalidating new source %{public}@ due to previous dispatcher invalidation : %{public}@", v6, v2);
            }
            v16 = nil;
        } else {
            v16 = [self->_lock_restartAssertionsByPidNumber objectForKey:v6];
            if (v16 != nil) {
                [self->_lock_restartAssertionsByPidNumber removeObjectForKey:v6];
                if (![self->_lock_restartAssertionsByPidNumber count]) {
                    self->_lock_restartAssertionsByPidNumber = nil;
                }
            }
            [self->_lock_sourcesByPidNumber setObject:v2 forKey:v6];
            os_log_t oslog2 = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Registering Source for %{public}@ : %{public}@", v6, v2);
            }
            long rbs_pid = [v6 rbs_pid];
            long v22 = __getpid(rbs_pid);
            if (rbs_pid != v22 && [self->_lock_mutableState addProcessIdentifier:v6] != 0) {
                [self->_store setState:self->_lock_mutableState];
            }
        }
    } else {
        long v23 = __getpid(v2);
        if (pid != v23) {
            id identity = [a1 identity];
            NSString *description = [identity description];
            [a1 auditToken:&v20];
            id v26 = NSStringFromBSVersionedPID(BSVersionedPIDForAuditToken(&v20));
            RBSProcessHandle *processHandle = [v2 processHandle];
            id identity2 = [processHandle identity];
            NSString *description2 = [identity2 description];
            RBSProcessHandle *processHandle2 = [v2 processHandle];
            if (processHandle2 != nil) {
                [processHandle2 auditToken:&v20];
            } else {
                _memset(v20, 0, 32);
            }
            id v32 = NSStringFromBSVersionedPID(BSVersionedPIDForAuditToken(&v20));
            NSString *v33 = [NSString stringWithFormat:@"already have a source registered for pid=%i: new=%@:%@ existing=%@:%@", pid, description, v26, description2, v32];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v49 = NSStringFromSelector(@selector(registerSourceWithProcessHandle:));
                NSString *v50 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBWorkspaceEventDispatcher.m", 245, v33);
            }
            _bs_set_crash_log_message([v33 UTF8String]);
            __break(0);
        }
        v16 = nil;
        v14 = false;
    }
    os_unfair_lock_unlock(&self->_lock);
    [v16 invalidate];
    if (v14) {
        [v2 invalidate];
    }
    return v2;
}


id -[FBWorkspaceEventDispatcher _callOutQueue_noteHandshakeFromSource:withRemnants:](id a1, id a2)
{
    os_log_t v10;
    long v7;
    if (self != nil) {
        os_unfair_lock_lock(&self->_lock);
        id processHandle2 = [a1 processHandle];
        int rbs_pid2 = [processHandle2 rbs_pid];
        NSNumber *v5 = [NSNumber numberWithInt:rbs_pid2];
        id v6 = [self->_lock_sourcesByPidNumber objectForKey:v5];
        if (v6 != a1) {
            os_unfair_lock_unlock(&self->_lock);
            v10 = FBLogProcessWorkspace();
            if (os_log_type_enabled(v10, OS_LOG_TYPE_DEFAULT)) {
                id processHandle = [a1 processHandle];
                long rbs_pid = [processHandle rbs_pid];
                os_log_with_type(v10, OS_LOG_TYPE_DEFAULT, "Ignoring invalid source handshake for %{public}i", rbs_pid);
            }
        }
        if (v6 == a1) {
            v7 = [a1 noteHandshakeWithRemnants:a2];
            NSArray *v8 = NSAllMapTableValues(self->_lock_targetsByIdentifier);
            id v9 = [v8 copy];
            os_unfair_lock_unlock(&self->_lock);
            if (!v7) {
                v10 = FBLogProcessWorkspace();
                if (os_log_type_enabled(v10, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(v10, OS_LOG_TYPE_DEFAULT, "Ignoring double local source handshake");
                }
            } else {
                for (id v21 in v9) {
                    NSString *workspaceIdentifier = [v21 workspaceIdentifier];
                    if (![self->_main_incompleteTargetRegistrations containsObject:workspaceIdentifier]) {
                        [self _callOutQueue_dispatchHandshakeFromSource:a1 toTarget:v21];
                    }
                }
            }
        }
        if (v6 != a1 || (v6 == a1 && !v7)) {
            for (id v26 in a2) {
                [v26 invalidate];
            }
        }
    }
    return a2;
}


void -[FBWorkspaceEventDispatcher _callOutQueue_dispatchHandshakeFromSource:toTarget:](id a1, id a2)
{
    id v1 = a2;
    if (self != nil) {
        objc_opt_self(FBWorkspaceEventDispatcher);
        id mainQueue = [BSServiceDispatchQueue mainQueue];
        [mainQueue assertBarrierOnQueue];
        id v4 = v1;
        id v5 = [a1 consumeRemnantsPassingTest:^bool(FBSceneRemnant *arg1) {
            FBSSceneDefinition *definition = [arg1 definition];
            id identity = [definition identity];
            id internalWorkspaceIdentifier = [identity internalWorkspaceIdentifier];
            NSString *workspaceIdentifier = [v1 workspaceIdentifier];
            return [internalWorkspaceIdentifier isEqualToString:workspaceIdentifier];
        }];
        if (v5 != nil) {
            FBSceneClientHandshake *v6 = [FBSceneClientHandshake alloc];
            id processHandle = [a1 processHandle];
            [v4 didReceiveHandshake:[v6 _initWithHandle:processHandle remnants:v5]];
        }
    }
}


void -[FBWorkspaceEventDispatcher noteHandshakeFromSource:withRemnants:](id a1, id a2)
{
    if (self != nil) {
        id v3 = a1;
        if (!a1) {
            NSString *v12 = NSStringFromClass([FBWorkspaceEventDispatcherSource class]);
            NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"source", v12];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v13 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                NSString *v14 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBWorkspaceEventDispatcher.m", 285, v2);
            }
            _bs_set_crash_log_message([v2 UTF8String]);
            __break(0);
        }
        if (![v3 isKindOfClass:[FBWorkspaceEventDispatcherSource class]]) {
            NSArray *v15 = OUTLINED_FUNCTION_28(v3);
            __builtin_return_address(0);
            Class v16 = [v15 classForCoder];
            if (!v16) {
                v16 = [v15 class];
            }
            NSString *v17 = NSStringFromClass(v16);
            NSString *v18 = NSStringFromClass([FBWorkspaceEventDispatcherSource class]);
            NSString *v19 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"source", v17, v18];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspaceEventDispatcher.m", 285, v19);
            }
            _bs_set_crash_log_message([v19 UTF8String]);
            __break(0);
        }
        id v4 = a2;
        if (!a2) {
            NSString *v21 = NSStringFromClass([NSSet class]);
            NSString *v22 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"remnants", v21];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v23 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                NSString *v24 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBWorkspaceEventDispatcher.m", 286, v22);
            }
            _bs_set_crash_log_message([v22 UTF8String]);
            __break(0);
        }
        if (![v4 isKindOfClass:[NSSet class]]) {
            NSArray *v26 = OUTLINED_FUNCTION_28(v4);
            __builtin_return_address(0);
            Class v27 = [v26 classForCoder];
            if (!v27) {
                v27 = [v26 class];
            }
            NSString *v28 = NSStringFromClass(v27);
            NSString *v29 = NSStringFromClass([NSSet class]);
            NSString *v30 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"remnants", v28, v29];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v31 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                NSString *v32 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBWorkspaceEventDispatcher.m", 286, v30);
            }
            _bs_set_crash_log_message([v30 UTF8String]);
            __break(0);
        }
        for (id v11 in v4) {
            if (!v11) {
                NSString *v34 = NSStringFromClass([FBSceneRemnant class]);
                NSString *v35 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"remnant", v34];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v36 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                    NSString *v37 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v36, v37, self, @"FBWorkspaceEventDispatcher.m", 288, v35);
                }
                _bs_set_crash_log_message([v35 UTF8String]);
                __break(0);
            }
            if (![v11 isKindOfClass:[FBSceneRemnant class]]) {
                NSArray *v39 = OUTLINED_FUNCTION_28(v11);
                __builtin_return_address(0);
                Class v40 = [v39 classForCoder];
                if (!v40) {
                    v40 = [v39 class];
                }
                NSString *v41 = NSStringFromClass(v40);
                NSString *v42 = NSStringFromClass([FBSceneRemnant class]);
                NSString *v43 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"remnant", v41, v42];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v44 = NSStringFromSelector(@selector(noteHandshakeFromSource:withRemnants:));
                    NSString *v45 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v44, v45, self, @"FBWorkspaceEventDispatcher.m", 288, v43);
                }
                _bs_set_crash_log_message([v43 UTF8String]);
                __break(0);
            }
        }
        objc_opt_self(FBWorkspaceEventDispatcher);
        id mainQueue = [BSServiceDispatchQueue mainQueue];
        [mainQueue performAsync:^void(void) {
            [self _callOutQueue_noteHandshakeFromSource:v3 withRemnants:v4];
        }];
    }
}


void -[FBWorkspaceEventDispatcher _callOutQueue_dispatchSceneRequestsFromSource:toTarget:](id a1, id a2)
{
    if (self != nil) {
        objc_opt_self(FBWorkspaceEventDispatcher);
        id mainQueue = [BSServiceDispatchQueue mainQueue];
        [mainQueue assertBarrierOnQueue];
        NSString *workspaceIdentifier = [a2 workspaceIdentifier];
        id v5 = [a1 dequeueSceneRequestsForTargetIdentifier:workspaceIdentifier];
        for (id v11 in v5) {
            id processHandle = [a1 processHandle];
            [a2 didReceiveSceneRequest:v11 fromHandle:processHandle];
        }
    }
}


void -[FBWorkspaceEventDispatcher _callOutQueue_handleSceneRequest:fromSource:](id a1, id a2)
{
    long v11;
    if (self != nil) {
        NSString *targetIdentifier = [a1 targetIdentifier];
        id v3 = [self->_preregisteredWorkspaces objectForKey:targetIdentifier];
        os_unfair_lock_lock(&self->_lock);
        id processHandle2 = [a2 processHandle];
        int rbs_pid2 = [processHandle2 rbs_pid];
        NSNumber *v6 = [NSNumber numberWithInt:rbs_pid2];
        id v7 = [self->_lock_sourcesByPidNumber objectForKey:v6];
        if (v7 == a2) {
            id v8 = [self->_lock_targetsByIdentifier objectForKey:targetIdentifier];
            if (!v8 && !v3) {
                os_unfair_lock_unlock(&self->_lock);
                os_log_t oslog2 = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Denying scene request because target workspace \"%{public}@\" does not exist", targetIdentifier);
                }
                v11 = FBSWorkspaceErrorCreate(0, 2, @"target workspace \"%@\" does not exist", targetIdentifier);
            } else {
                [a2 enqueueSceneRequest:a1];
                os_unfair_lock_unlock(&self->_lock);
                if (v8) {
                    NSString *workspaceIdentifier = [v8 workspaceIdentifier];
                    if (![self->_main_incompleteTargetRegistrations containsObject:workspaceIdentifier]) {
                        [self _callOutQueue_dispatchSceneRequestsFromSource:a2 toTarget:v8];
                    }
                }
                return;
            }
        } else {
            os_unfair_lock_unlock(&self->_lock);
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id processHandle = [a2 processHandle];
                long rbs_pid = [processHandle rbs_pid];
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Ignoring scene request from invalid source registration for %{public}i", rbs_pid);
            }
            v11 = FBSWorkspaceErrorCreate(0, 2, @"invalid source registration");
        }
        [a1 invalidateWithError:v11];
    }
}


int -[FBWorkspaceEventDispatcher handleSceneRequest:fromSource:](id a1, id a2)
{
    int v33 = 0;
    if (self) {
        id v3 = a1;
        if (!a1) {
            NSString *v9 = NSStringFromClass([FBWorkspaceSceneRequest class]);
            NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"request", v9];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v10 = NSStringFromSelector(@selector(handleSceneRequest:fromSource:));
                NSString *v11 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBWorkspaceEventDispatcher.m", 298, v2);
            }
            _bs_set_crash_log_message([v2 UTF8String]);
            __break(0);
        }
        if (![v3 isKindOfClass:[FBWorkspaceSceneRequest class]]) {
            NSArray *v13 = OUTLINED_FUNCTION_28(v3);
            __builtin_return_address(0);
            Class v14 = [v13 classForCoder];
            if (!v14) {
                v14 = [v13 class];
            }
            NSString *v15 = NSStringFromClass(v14);
            NSString *v16 = NSStringFromClass([FBWorkspaceSceneRequest class]);
            NSString *v17 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"request", v15, v16];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v18 = NSStringFromSelector(@selector(handleSceneRequest:fromSource:));
                NSString *v19 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceEventDispatcher.m", 298, v17);
            }
            _bs_set_crash_log_message([v17 UTF8String]);
            __break(0);
        }
        id v4 = a2;
        if (!a2) {
            NSString *v21 = NSStringFromClass([FBWorkspaceEventDispatcherSource class]);
            NSString *v22 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"source", v21];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v23 = NSStringFromSelector(@selector(handleSceneRequest:fromSource:));
                NSString *v24 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBWorkspaceEventDispatcher.m", 299, v22);
            }
            _bs_set_crash_log_message([v22 UTF8String]);
            __break(0);
        }
        if (![v4 isKindOfClass:[FBWorkspaceEventDispatcherSource class]]) {
            NSArray *v26 = OUTLINED_FUNCTION_28(v4);
            __builtin_return_address(0);
            Class v27 = [v26 classForCoder];
            if (!v27) {
                v27 = [v26 class];
            }
            NSString *v28 = NSStringFromClass(v27);
            NSString *v29 = NSStringFromClass([FBWorkspaceEventDispatcherSource class]);
            NSString *v30 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"source", v28, v29];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v31 = NSStringFromSelector(@selector(handleSceneRequest:fromSource:));
                NSString *v32 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBWorkspaceEventDispatcher.m", 299, v30);
            }
            _bs_set_crash_log_message([v30 UTF8String]);
            __break(0);
        }
        NSString *targetIdentifier = [v3 targetIdentifier];
        id v6 = [self->_preregisteredWorkspaces objectForKey:targetIdentifier];
        if (!targetIdentifier) {
            v33 = 0;
        } else if (v6 != nil || ([v3 requiresTargetPreregistration] & 1) == 0) {
            objc_opt_self(FBWorkspaceEventDispatcher);
            id mainQueue = [BSServiceDispatchQueue mainQueue];
            [mainQueue performAsync:^void(void) {
                [self _callOutQueue_handleSceneRequest:v3 fromSource:v4];
            }];
            v33 = 1;
        } else {
            v33 = 0;
        }
    }
    return v33;
}


FBWorkspaceEventDispatcher *-[FBWorkspaceEventDispatcher _initWithDomain:](id a1)
{
    FBWorkspaceEventDispatcher *v1 = nil;
    if (self != nil) {
        v1 = [self _initWithDomain:a1 connectionStore:[[FBWorkspaceConnectionsStateStore alloc] _initWithIdentifier:[a1 reconnectShmemIdentifier]] preregisteredWorkspaces:[a1 preregisteredWorkspaces]];
    }
    return v1;
}


FBWorkspaceEventDispatcher *-[FBWorkspaceEventDispatcher _initWithDomain:connectionStore:preregisteredWorkspaces:](FBWorkspaceDomain *a1, FBWorkspaceConnectionsStateStore *a2, id a3)
{
    if (!self) {
        return nil;
    }
    if (!a1) {
        NSString *v47 = NSStringFromClass([FBWorkspaceDomain class]);
        NSString *v48 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"domain", v47];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v49 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v50 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBWorkspaceEventDispatcher.m", 79, v48);
        }
        _bs_set_crash_log_message([v48 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[FBWorkspaceDomain class]]) {
        NSArray *v0 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v51 = [v0 classForCoder];
        if (!v51) {
            v51 = [v0 class];
        }
        NSString *v52 = NSStringFromClass(v51);
        NSString *v53 = NSStringFromClass([FBWorkspaceDomain class]);
        NSString *v54 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"domain", v52, v53];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v55 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v55, self, @"FBWorkspaceEventDispatcher.m", 79, v54);
        }
        _bs_set_crash_log_message([v54 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v57 = NSStringFromClass([FBWorkspaceConnectionsStateStore class]);
        NSString *v58 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"store", v57];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v59 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v60 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v59, v60, self, @"FBWorkspaceEventDispatcher.m", 80, v58);
        }
        _bs_set_crash_log_message([v58 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:[FBWorkspaceConnectionsStateStore class]]) {
        NSArray *v62 = OUTLINED_FUNCTION_28(a2);
        __builtin_return_address(0);
        Class v63 = [v62 classForCoder];
        if (!v63) {
            v63 = [v62 class];
        }
        NSString *v64 = NSStringFromClass(v63);
        NSString *v65 = NSStringFromClass([FBWorkspaceConnectionsStateStore class]);
        NSString *v66 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"store", v64, v65];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v67 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v68 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v67, v68, self, @"FBWorkspaceEventDispatcher.m", 80, v66);
        }
        _bs_set_crash_log_message([v66 UTF8String]);
        __break(0);
    }
    if (!a3) {
        NSString *v70 = NSStringFromClass([NSDictionary class]);
        NSString *v71 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"preregisteredWorkspaces", v70];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v72 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v73 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v72, v73, self, @"FBWorkspaceEventDispatcher.m", 81, v71);
        }
        _bs_set_crash_log_message([v71 UTF8String]);
        __break(0);
    }
    if (![a3 isKindOfClass:[NSDictionary class]]) {
        NSArray *v75 = OUTLINED_FUNCTION_28(a3);
        __builtin_return_address(0);
        Class v76 = [v75 classForCoder];
        if (!v76) {
            v76 = [v75 class];
        }
        NSString *v77 = NSStringFromClass(v76);
        NSString *v78 = NSStringFromClass([NSDictionary class]);
        NSString *v79 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"preregisteredWorkspaces", v77, v78];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v80 = NSStringFromSelector(@selector(_initWithDomain:connectionStore:preregisteredWorkspaces:));
            NSString *v81 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v80, v81, self, @"FBWorkspaceEventDispatcher.m", 81, v79);
        }
        _bs_set_crash_log_message([v79 UTF8String]);
        __break(0);
    }
    FBWorkspaceEventDispatcher *v4 = [super init];
    if (v4 != nil) {
        v4->_domain = a1;
        v4->_store = a2;
        v4->_preregisteredWorkspaces = [a3 copy];
        id state = [v4->_store state];
        NSSet *processIdentifiers = [state processIdentifiers];
        v4->_lock_targetsByIdentifier = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsZeroingWeakMemory | NSPointerFunctionsMachVirtualMemory | NSPointerFunctionsObjectPointerPersonality];
        v4->_main_incompleteTargetRegistrations = [NSCountedSet set];
        v4->_lock._os_unfair_lock_opaque = 0;
        os_unfair_lock_t lock = &v4->_lock;
        v4->_lock_sourcesByPidNumber = [NSMutableDictionary dictionary];
        v4->_lock_mutableState = [FBMutableWorkspaceConnectionsState new];
        NSUInteger count = [processIdentifiers count];
        if (count != 0) {
            __weak FBWorkspaceEventDispatcher *v21 = v4;
            void (^v24)(RBSAssertion *, NSError *) = [^void(RBSAssertion *arg1, NSError *arg2) {
                [v21 _noteReceivedInvalidationHandlerForAssertion:arg1];
            } copy];
            os_unfair_lock_lock(lock);
            long v30 = FBAssertionDomain;
            for (id<NSCopying> v33 in processIdentifiers) {
                RBSAssertion *v34 = [RBSAssertion alloc];
                long rbs_pid = [v33 rbs_pid];
                id v36 = [RBSTarget targetWithPid:rbs_pid];
                id v37 = [RBSDomainAttribute attributeWithDomain:v30 name:@"WorkspaceReconnect"];
                NSArray *v39 = @[v37];
                RBSAssertion *v40 = [v34 initWithExplanation:@"com.apple.frontboard.workspace.reconnect" target:v36 attributes:v39];
                [v40 setInvalidationHandler:v24];
                id v41 = nil;
                if (![v40 acquireWithError:&v41]) {
                    os_log_t oslog = FBLogProcessWorkspace();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "failed to acquire restart assertion on %@ : %@", v33, v41);
                    }
                    [v40 invalidate];
                } else {
                    NSMutableDictionary *v44 = v4->_lock_restartAssertionsByPidNumber;
                    if (!v4->_lock_restartAssertionsByPidNumber) {
                        v4->_lock_restartAssertionsByPidNumber = [NSMutableDictionary dictionaryWithCapacity:count];
                        v44 = v4->_lock_restartAssertionsByPidNumber;
                    }
                    [v44 setObject:v40 forKey:v33];
                    [v4->_lock_mutableState addProcessIdentifier:v33];
                }
            }
            [v4->_store setState:v4->_lock_mutableState];
            os_unfair_lock_unlock(lock);
        }
        id currentProcess = [RBSProcessHandle currentProcess];
        [v4 registerSourceWithProcessHandle:currentProcess];
        return v4;
    }
    return v4;
}


void -[FBWorkspaceEventDispatcher _noteSourceDidInvalidate:withPIDNumber:](id a1, id a2, long a3, long a4, long a5, long a6, long a7, long a8)
{
    uint8_t v0[64];
    v0[0].state = a8;
    v0[0].itemsPtr = a7;
    v0[0].mutationsPtr = a6;
    v0[0].extra[0] = a5;
    v0[0].extra[1] = a4;
    v0[0].extra[2] = a3;
    v0[0].extra[3] = &v0[48];
    v0[0].extra[4] = __builtin_return_address(0);
    if (self != nil) {
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_sourcesByPidNumber != nil) {
            id v3 = [self->_lock_sourcesByPidNumber objectForKey:a2];
            if (v3 != a1) {
                id v23 = [self->_lock_sourcesByPidNumber objectForKey:a2];
                NSString *v24 = [NSString stringWithFormat:@"source mismatch for %@ : actual=%p expected=%p", a2, v23, a1];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v25 = NSStringFromSelector(@selector(_noteSourceDidInvalidate:withPIDNumber:));
                    NSString *v26 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBWorkspaceEventDispatcher.m", 384, v24);
                }
                _bs_set_crash_log_message([v24 UTF8String]);
                __break(0);
            }
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id processHandle = [a1 processHandle];
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Removing source registration for processHandle: %{public}@", processHandle);
            }
            [self->_lock_sourcesByPidNumber removeObjectForKey:a2];
            self->_lock_mutableState = [FBMutableWorkspaceConnectionsState new];
            for (id v15 in self->_lock_sourcesByPidNumber) {
                long rbs_pid = [v15 rbs_pid];
                long v17 = __getpid(rbs_pid);
                if (rbs_pid != v17) {
                    [self->_lock_mutableState addProcessIdentifier:v15];
                }
            }
            for (id v10 in self->_lock_restartAssertionsByPidNumber) {
                [self->_lock_mutableState addProcessIdentifier:v10];
            }
            [self->_store setState:self->_lock_mutableState];
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


BSSimpleAssertion *-[FBWorkspaceEventDispatcher registerTarget:](id a1)
{
    BSSimpleAssertion *v10 = nil;
    if (self != nil) {
        objc_opt_self(FBWorkspaceEventDispatcher);
        id mainQueue2 = [BSServiceDispatchQueue mainQueue];
        [mainQueue2 assertBarrierOnQueue];
        if (!a1) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"target"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v21 = NSStringFromSelector(@selector(registerTarget:));
                NSString *v22 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v21, v22, self, @"FBWorkspaceEventDispatcher.m", 172, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        NSString *workspaceIdentifier = [a1 workspaceIdentifier];
        __weak id v4 = a1;
        BSSimpleAssertion *v5 = [BSSimpleAssertion alloc];
        NSString *v9 = workspaceIdentifier;
        v10 = [v5 initWithIdentifier:@"com.apple.frontboard.workspace-events.registration.target" forReason:v9 invalidationBlock:^void(BSSimpleAssertion *arg1) {
            os_unfair_lock_lock(&self->_lock);
            if (!v4) {
                NSString *v25 = [NSString stringWithFormat:@"target for %@ dealloced before invalidation", workspaceIdentifier];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v26 = NSStringFromSelector(@selector(registerTarget:));
                    NSString *v27 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v26, v27, self, @"FBWorkspaceEventDispatcher.m", 184, v25);
                }
                _bs_set_crash_log_message([v25 UTF8String]);
                __break(0);
            }
            id v32 = [self->_lock_targetsByIdentifier objectForKey:workspaceIdentifier];
            if (v32 != v4) {
                id v33 = [self->_lock_targetsByIdentifier objectForKey:workspaceIdentifier];
                NSString *v34 = [NSString stringWithFormat:@"target mismatch for %@ : actual=%p expected=%p", workspaceIdentifier, v33, v4];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v24 = NSStringFromSelector(@selector(registerTarget:));
                    NSString *v29 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v24, v29, self, @"FBWorkspaceEventDispatcher.m", 185, v34);
                }
                _bs_set_crash_log_message([v34 UTF8String]);
                __break(0);
            }
            os_log_t v35 = FBLogProcessWorkspace();
            if (os_log_type_enabled(v35, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(v35, OS_LOG_TYPE_DEFAULT, "Removing target registration for workspaceIdentifier: %{public}@", workspaceIdentifier);
            }
            [self->_lock_targetsByIdentifier removeObjectForKey:workspaceIdentifier];
            os_unfair_lock_unlock(&self->_lock);
        }];
        os_unfair_lock_lock(&self->_lock);
        id v11 = [self->_lock_targetsByIdentifier objectForKey:v9];
        if (!v11) {
            [self->_lock_targetsByIdentifier setObject:a1 forKey:v9];
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Registering Target for %{public}@: %{public}@", v9, a1);
            }
            os_unfair_lock_unlock(&self->_lock);
            [self->_main_incompleteTargetRegistrations addObject:v9];
            objc_opt_self(FBWorkspaceEventDispatcher);
            id mainQueue = [BSServiceDispatchQueue mainQueue];
            [mainQueue performAsync:^void(void) {
                id v37;
                os_unfair_lock_lock(&self->_lock);
                if (!v4) {
                    v37 = nil;
                } else {
                    id v40 = [self->_lock_targetsByIdentifier objectForKey:v9];
                    if (v40 == v4) {
                        NSArray *allValues = [self->_lock_sourcesByPidNumber allValues];
                        v37 = [allValues copy];
                    } else {
                        v37 = nil;
                    }
                }
                os_unfair_lock_unlock(&self->_lock);
                [self->_main_incompleteTargetRegistrations removeObject:v9];
                for (id v38 in v37) {
                    [self _callOutQueue_dispatchHandshakeFromSource:v38 toTarget:v4];
                }
                for (id v39 in v37) {
                    [self _callOutQueue_dispatchSceneRequestsFromSource:v39 toTarget:v4];
                }
            }];
        } else {
            NSString *v18 = [NSString stringWithFormat:@"already have a target registered for %@: %@", v9, v11];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v19 = NSStringFromSelector(@selector(registerTarget:));
                NSString *v20 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBWorkspaceEventDispatcher.m", 196, v18);
            }
            _bs_set_crash_log_message([v18 UTF8String]);
            __break(0);
        }
    }
    return v10;
}


void -[FBWorkspaceEventDispatcher dealloc](void)
{
    if (self->_lock_sourcesByPidNumber != nil) {
        NSString *v5 = [NSString stringWithFormat:@"must call _invalidateWithCompletion: before dealloc"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceEventDispatcher.m", 127, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "FBWorkspaceEventDispatcher:%p deallocing.", self);
    }
    [super dealloc];
}


void -[FBWorkspaceEventDispatcher .cxx_destruct](void)
{
    self->_lock_mutableState = nil;
    self->_lock_restartAssertionsByPidNumber = nil;
    self->_main_incompleteTargetRegistrations = nil;
    self->_lock_targetsByIdentifier = nil;
    self->_lock_sourcesByPidNumber = nil;
    self->_preregisteredWorkspaces = nil;
    self->_store = nil;
    self->_domain = nil;
}


void -[FBWorkspaceEventDispatcher init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed on FBWorkspaceEventDispatcher"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceEventDispatcher.m", 65, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBWorkspaceEventDispatcher _noteReceivedInvalidationHandlerForAssertion:](id a1)
{
    id v0 = a1;
    if (self != nil) {
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_sourcesByPidNumber != nil) {
            NSSet<NSNumber *> *v2 = [self->_lock_restartAssertionsByPidNumber keysOfEntriesPassingTest:^bool(NSNumber *arg1, RBSAssertion *arg2, bool *arg3) {
                return v0 == arg2;
            }];
            if ([v2 count] != 0) {
                for (NSNumber *v12 in v2) {
                    [self->_lock_restartAssertionsByPidNumber removeObjectForKey:v12];
                }
                self->_lock_mutableState = [FBMutableWorkspaceConnectionsState new];
                for (id v17 in self->_lock_sourcesByPidNumber) {
                    long rbs_pid = [v17 rbs_pid];
                    long v19 = __getpid(rbs_pid);
                    if (rbs_pid != v19) {
                        [self->_lock_mutableState addProcessIdentifier:v17];
                    }
                }
                for (id v21 in self->_lock_restartAssertionsByPidNumber) {
                    [self->_lock_mutableState addProcessIdentifier:v21];
                }
                [self->_store setState:self->_lock_mutableState];
            }
            if (![self->_lock_restartAssertionsByPidNumber count]) {
                self->_lock_restartAssertionsByPidNumber = nil;
            }
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


bool -[FBWorkspaceEventDispatcher canCreateLocalSceneWithIdentity:](id a1)
{
    bool v6;
    if (!self) {
        return false;
    }
    objc_opt_self(FBWorkspaceEventDispatcher);
    id mainQueue = [BSServiceDispatchQueue mainQueue];
    [mainQueue assertBarrierOnQueue];
    NSString *workspaceIdentifier = [a1 workspaceIdentifier];
    id v3 = [self->_preregisteredWorkspaces objectForKey:workspaceIdentifier];
    os_unfair_lock_lock(&self->_lock);
    NSNumber *v4 = [NSNumber numberWithInt:__getpid()];
    if (![self->_lock_sourcesByPidNumber objectForKey:v4]) {
        v6 = false;
    } else {
        id v7 = [self->_lock_targetsByIdentifier objectForKey:workspaceIdentifier];
        v6 = (v3 | v7) != 0;
    }
    os_unfair_lock_unlock(&self->_lock);
    return v6;
}


void -[FBWorkspaceEventDispatcher handleLocalSceneRequest:](id a1)
{
    if (self != nil) {
        objc_opt_self(FBWorkspaceEventDispatcher);
        id mainQueue = [BSServiceDispatchQueue mainQueue];
        [mainQueue assertBarrierOnQueue];
        os_unfair_lock_lock(&self->_lock);
        NSNumber *v2 = [NSNumber numberWithInt:__getpid()];
        id v3 = [self->_lock_sourcesByPidNumber objectForKey:v2];
        os_unfair_lock_unlock(&self->_lock);
        if (v3 != nil) {
            NSSet *set = [NSSet set];
            [self _callOutQueue_noteHandshakeFromSource:v3 withRemnants:set];
            [self _callOutQueue_handleSceneRequest:a1 fromSource:v3];
        } else {
            os_log_t oslog = FBLogProcessWorkspace();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Ignoring scene request from local source as we've already been invalidated");
            }
            id v7 = FBSWorkspaceErrorCreate(0, 3, @"already invalidated");
            [a1 invalidateWithError:v7];
        }
    }
}
