struct FBWorkspaceEventDispatcherSource {
    RBSProcessHandle *_processHandle; // +0x8
    id _lock_invalidationBlock; // +0x10
    NSSet *_lock_remnants; // +0x18
    NSMutableDictionary *_lock_requestsByTargetIdentifier; // +0x20
    struct os_unfair_lock_s _lock; // +0x28
    struct os_unfair_lock_s _invalidationLock; // +0x2c
};

int -[FBWorkspaceEventDispatcherSource noteHandshakeWithRemnants:](id a1)
{
    int v11;
    if (!a1) {
        NSString *v1 = NSStringFromClass([NSSet class]);
        NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"remnants", v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v3 = NSStringFromSelector(_cmd);
            NSString *v4 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v4, self, @"FBWorkspaceEventDispatcherSource.m", 53, v2);
        }
        _bs_set_crash_log_message([v2 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[NSSet class]]) {
        Class v13 = [a1 classForCoder];
        if (!v13) {
            v13 = [a1 class];
        }
        NSString *v14 = NSStringFromClass(v13);
        NSString *v15 = NSStringFromClass([NSSet class]);
        NSString *v16 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"remnants", v14, v15];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBWorkspaceEventDispatcherSource.m", 53, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    for (id v6 in a1) {
        if (!v6) {
            NSString *v20 = NSStringFromClass([FBSceneRemnant class]);
            NSString *v21 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"remnant", v20];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v22 = NSStringFromSelector(_cmd);
                NSString *v23 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBWorkspaceEventDispatcherSource.m", 55, v21);
            }
            _bs_set_crash_log_message([v21 UTF8String]);
            __break(0);
        }
        if (![v6 isKindOfClass:[FBSceneRemnant class]]) {
            Class v25 = [v6 classForCoder];
            if (!v25) {
                v25 = [v6 class];
            }
            NSString *v26 = NSStringFromClass(v25);
            NSString *v27 = NSStringFromClass([FBSceneRemnant class]);
            NSString *v28 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"remnant", v26, v27];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v29 = NSStringFromSelector(_cmd);
                NSString *v30 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v29, v30, self, @"FBWorkspaceEventDispatcherSource.m", 55, v28);
            }
            _bs_set_crash_log_message([v28 UTF8String]);
            __break(0);
        }
    }
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_invalidationBlock) {
        NSString *v32 = [NSString stringWithFormat:@"attempt to handshake after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v33 = NSStringFromSelector(_cmd);
            NSString *v34 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v33, v34, self, @"FBWorkspaceEventDispatcherSource.m", 59, v32);
        }
        _bs_set_crash_log_message([v32 UTF8String]);
        __break(0);
    }
    int pid = [self->_processHandle pid];
    long v8 = __getpid(pid);
    if (pid == v8) {
        if ([a1 count] != 0) {
            NSString *v36 = [NSString stringWithFormat:@"the currentProcess may never have remnants"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v37 = NSStringFromSelector(_cmd);
                NSString *v38 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBWorkspaceEventDispatcherSource.m", 62, v36);
            }
            _bs_set_crash_log_message([v36 UTF8String]);
            __break(0);
        }
        if (!self->_lock_remnants) {
            self->_lock_remnants = [NSSet set];
            v11 = 1;
            os_unfair_lock_unlock(&self->_lock);
            return v11;
        }
        v11 = 0;
        os_unfair_lock_unlock(&self->_lock);
        return v11;
    }
    if (self->_lock_remnants != nil) {
        NSString *v40 = [NSString stringWithFormat:@"double handshake detected"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v41 = NSStringFromSelector(_cmd);
            NSString *v42 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v42, self, @"FBWorkspaceEventDispatcherSource.m", 69, v40);
        }
        _bs_set_crash_log_message([v40 UTF8String]);
        __break(0);
    }
    self->_lock_remnants = [a1 copy];
    v11 = 1;
    os_unfair_lock_unlock(&self->_lock);
    return v11;
}


id -[FBWorkspaceEventDispatcherSource consumeRemnantsPassingTest:](id a1)
{
    id v2;
    id v12;
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"test"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v3, self, @"FBWorkspaceEventDispatcherSource.m", 78, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_remnants) {
        v2 = nil;
    } else {
        NSMutableSet *v7 = nil;
        NSMutableSet *v8 = nil;
        for (id v11 in self->_lock_remnants) {
            long continuationRoute1 = 0;
            if (a1->field_16(a1, v11) != 0) {
                if (!v7) {
                    continuationRoute1 = 2;
                }
                if (!continuationRoute1) {
                    v12 = v7;
                    continuationRoute1 = 1;
                }
            }
            if (!continuationRoute1) {
                if (v8 != nil) {
                    v12 = v8;
                    continuationRoute1 = 1;
                } else {
                    v8 = [NSMutableSet setWithObject:v11];
                }
            }
            if (continuationRoute1 == 1) {
                [v12 addObject:v11];
                continue;
            } else if (continuationRoute1 == 2) {
                v7 = [NSMutableSet setWithObject:v11];
            }
        }
        NSUInteger count = [self->_lock_remnants count];
        NSUInteger count2 = [v8 count];
        if (count != count2) {
            id v15 = [v8 copy];
            self->_lock_remnants = (!v15) ? [NSSet set] : v15;
        }
        v2 = (!v7) ? [NSSet set] : v7;
    }
    os_unfair_lock_unlock(&self->_lock);
    return v2;
}


RBSProcessHandle *-[FBWorkspaceEventDispatcherSource processHandle](void)
{
    return self->_processHandle;
}


FBWorkspaceEventDispatcherSource *-[FBWorkspaceEventDispatcherSource _initWithProcessHandle:invalidationBlock:](RBSProcessHandle *a1, id a2)
{
    if (!a1) {
        NSString *v6 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"processHandle", v6];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBWorkspaceEventDispatcherSource.m", 38, v2);
        }
        _bs_set_crash_log_message([v2 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[RBSProcessHandle class]]) {
        Class v10 = [a1 classForCoder];
        if (!v10) {
            v10 = [a1 class];
        }
        NSString *v11 = NSStringFromClass(v10);
        NSString *v12 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v13 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"processHandle", v11, v12];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v14 = NSStringFromSelector(_cmd);
            NSString *v15 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceEventDispatcherSource.m", 38, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    if ([a1 rbs_pid] <= 0) {
        NSString *v17 = [NSString stringWithFormat:@"invalid pid on handle=%@", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceEventDispatcherSource.m", 39, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v21 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"invalidationBlock"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v22 = NSStringFromSelector(_cmd);
            NSString *v23 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBWorkspaceEventDispatcherSource.m", 40, v21);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
    FBWorkspaceEventDispatcherSource *v3 = [super init];
    if (v3 != nil) {
        v3->_processHandle = a1;
        v3->_lock_invalidationBlock = [a2 copy];
        v3->field_40 = 0;
    }
    return v3;
}


void -[FBWorkspaceEventDispatcherSource invalidate](void)
{
    os_unfair_lock_lock(&self->_invalidationLock);
    os_unfair_lock_lock(&self->_lock);
    id v1 = _Block_copy(self->_lock_invalidationBlock);
    os_unfair_lock_unlock(&self->_lock);
    if (v1 != nil) {
        v1->field_16(v1, self);
    }
    os_unfair_lock_lock(&self->_lock);
    NSSet *v2 = self->_lock_remnants;
    NSMutableDictionary *v3 = self->_lock_requestsByTargetIdentifier;
    self->_lock_remnants = nil;
    self->_lock_requestsByTargetIdentifier = nil;
    self->_lock_invalidationBlock = nil;
    os_unfair_lock_unlock(&self->_lock);
    for (id v26 in v2) {
        [v26 invalidate];
    }
    NSEnumerator *objectEnumerator = [v3 objectEnumerator];
    for (id v20 in objectEnumerator) {
        for (id v17 in v20) {
            id v25 = FBSWorkspaceErrorCreate(0, 2, @"dispatcher registration has invalidated");
            [v17 invalidateWithError:v25];
        }
    }
    os_unfair_lock_unlock(&self->_invalidationLock);
}


void -[FBWorkspaceEventDispatcherSource dealloc](void)
{
    if (self->_lock_invalidationBlock != nil) {
        NSString *v1 = [NSString stringWithFormat:@"must invalidate before dealloc"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceEventDispatcherSource.m", 30, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


void -[FBWorkspaceEventDispatcherSource .cxx_destruct](void)
{
    self->_lock_requestsByTargetIdentifier = nil;
    self->_lock_remnants = nil;
    self->_lock_invalidationBlock = nil;
    self->_processHandle = nil;
}


void -[FBWorkspaceEventDispatcherSource enqueueSceneRequest:](id a1)
{
    if (!a1) {
        NSString *v6 = NSStringFromClass([FBWorkspaceSceneRequest class]);
        NSString *v7 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"request", v6];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v3 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v8, self, @"FBWorkspaceEventDispatcherSource.m", 110, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[FBWorkspaceSceneRequest class]]) {
        Class v10 = [a1 classForCoder];
        if (!v10) {
            v10 = [a1 class];
        }
        NSString *v11 = NSStringFromClass(v10);
        NSString *v12 = NSStringFromClass([FBWorkspaceSceneRequest class]);
        NSString *v13 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"request", v11, v12];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v14 = NSStringFromSelector(_cmd);
            NSString *v15 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceEventDispatcherSource.m", 110, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    NSString *targetIdentifier = [a1 targetIdentifier];
    if (!targetIdentifier) {
        NSString *v17 = [NSString stringWithFormat:@"missing targetIdentifier in request : %@", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceEventDispatcherSource.m", 112, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_remnants) {
        NSString *v21 = [NSString stringWithFormat:@"attempt to enqueue scene request before handshake"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v22 = NSStringFromSelector(_cmd);
            NSString *v23 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBWorkspaceEventDispatcherSource.m", 115, v21);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
    if (!self->_lock_invalidationBlock) {
        NSString *v25 = [NSString stringWithFormat:@"attempt to enqueue scene request after invalidation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v26 = NSStringFromSelector(_cmd);
            NSString *v27 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v26, v27, self, @"FBWorkspaceEventDispatcherSource.m", 116, v25);
        }
        _bs_set_crash_log_message([v25 UTF8String]);
        __break(0);
    }
    id v2 = [self->_lock_requestsByTargetIdentifier objectForKey:targetIdentifier];
    if (!v2) {
        NSMutableArray<FBWorkspaceSceneRequest *> *v28 = [NSMutableArray arrayWithObject:a1];
        if (!self->_lock_requestsByTargetIdentifier) {
            self->_lock_requestsByTargetIdentifier = [NSMutableDictionary dictionaryWithObject:v28 forKey:targetIdentifier];
        } else {
            [self->_lock_requestsByTargetIdentifier setObject:v28 forKey:targetIdentifier];
        }
    } else {
        [v2 addObject:a1];
    }
    os_unfair_lock_unlock(&self->_lock);
}


id -[FBWorkspaceEventDispatcherSource dequeueSceneRequestsForTargetIdentifier:](id a1)
{
    Class aClass = [NSString class];
    if (!a1) {
        NSString *v4 = NSStringFromClass(aClass);
        NSString *v5 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"targetIdentifier", v4];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v10, self, @"FBWorkspaceEventDispatcherSource.m", 132, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:aClass]) {
        Class v12 = [a1 classForCoder];
        if (!v12) {
            v12 = [a1 class];
        }
        NSString *v13 = NSStringFromClass(v12);
        NSString *v14 = NSStringFromClass([NSString class]);
        NSString *v15 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"targetIdentifier", v13, v14];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v6 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v6, self, @"FBWorkspaceEventDispatcherSource.m", 132, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&self->_lock);
    id v7 = [self->_lock_requestsByTargetIdentifier objectForKey:a1];
    if (v7 != nil) {
        NSUInteger count = [self->_lock_requestsByTargetIdentifier count];
        NSMutableDictionary *v9 = self->_lock_requestsByTargetIdentifier;
        if (count != 1) {
            [v9 removeObjectForKey:a1];
        } else {
            self->_lock_requestsByTargetIdentifier = nil;
        }
    }
    os_unfair_lock_unlock(&self->_lock);
    return v7;
}


void -[FBWorkspaceEventDispatcherSource init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBWorkspaceEventDispatcherSource"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceEventDispatcherSource.m", 151, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
