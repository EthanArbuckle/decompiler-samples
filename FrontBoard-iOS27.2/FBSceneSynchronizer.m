struct FBSceneSynchronizer {
    NSString *_identifier; // +0x8
    BSServiceDispatchQueue *_workspaceQueue; // +0x10
    BSServiceCompoundQueue *_serviceQueue; // +0x18
    FBWorkspaceEventDispatcher *_dispatcher; // +0x20
    RBSProcessHandle *_lock_process; // +0x28
    struct os_unfair_lock_s _lock; // +0x30
    bool _lock_waitingForConnect; // +0x34
};

FBSceneSynchronizer *-[FBSceneSynchronizer _initWithIdentifier:workspaceQueue:dispatcher:](id a1, BSServiceDispatchQueue *a2, FBWorkspaceEventDispatcher *a3)
{
    if (self != nil) {
        Class aClass = [NSString class];
        if (!a1) {
            NSString *v8 = NSStringFromClass(aClass);
            NSString *v9 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"identifier", v8];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(@selector(_initWithIdentifier:workspaceQueue:dispatcher:));
                NSString *v19 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v19, self, @"FBSceneSynchronizer.m", 38, v9);
            }
            _bs_set_crash_log_message([v9 UTF8String]);
            __break(0);
        }
        if (![a1 isKindOfClass:aClass]) {
            NSArray *v21 = OUTLINED_FUNCTION_28(a1);
            __builtin_return_address(0);
            Class v22 = [v21 classForCoder];
            if (!v22) {
                v22 = [v21 class];
            }
            NSString *v23 = NSStringFromClass(v22);
            NSString *v4 = NSStringFromClass([NSString class]);
            NSString *v24 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"identifier", v23, v4];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v25 = NSStringFromSelector(@selector(_initWithIdentifier:workspaceQueue:dispatcher:));
                NSString *v26 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBSceneSynchronizer.m", 38, v24);
            }
            _bs_set_crash_log_message([v24 UTF8String]);
            __break(0);
        }
        if (!a2) {
            NSString *v28 = NSStringFromClass([BSServiceDispatchQueue class]);
            NSString *v29 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"workspaceQueue", v28];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v30 = NSStringFromSelector(@selector(_initWithIdentifier:workspaceQueue:dispatcher:));
                NSString *v31 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v30, v31, self, @"FBSceneSynchronizer.m", 39, v29);
            }
            _bs_set_crash_log_message([v29 UTF8String]);
            __break(0);
        }
        if (![a2 isKindOfClass:[BSServiceDispatchQueue class]]) {
            NSArray *v33 = OUTLINED_FUNCTION_28(a2);
            __builtin_return_address(0);
            Class v34 = [v33 classForCoder];
            if (!v34) {
                v34 = [v33 class];
            }
            NSString *v35 = NSStringFromClass(v34);
            NSString *v36 = NSStringFromClass([BSServiceDispatchQueue class]);
            NSString *v37 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"workspaceQueue", v35, v36];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v38 = NSStringFromSelector(@selector(_initWithIdentifier:workspaceQueue:dispatcher:));
                NSString *v39 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v38, v39, self, @"FBSceneSynchronizer.m", 39, v37);
            }
            _bs_set_crash_log_message([v37 UTF8String]);
            __break(0);
        }
        if (a3 != nil && ![a3 isKindOfClass:[FBWorkspaceEventDispatcher class]]) {
            NSArray *v41 = OUTLINED_FUNCTION_28(a3);
            __builtin_return_address(0);
            Class v42 = [v41 classForCoder];
            if (!v42) {
                v42 = [v41 class];
            }
            NSString *v43 = NSStringFromClass(v42);
            NSString *v44 = NSStringFromClass([FBWorkspaceEventDispatcher class]);
            NSString *v45 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"dispatcher", v43, v44];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v46 = NSStringFromSelector(@selector(_initWithIdentifier:workspaceQueue:dispatcher:));
                NSString *v47 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v46, v47, self, @"FBSceneSynchronizer.m", 40, v45);
            }
            _bs_set_crash_log_message([v45 UTF8String]);
            __break(0);
        }
        self = [super init];
        if (self != nil) {
            self->_identifier = [a1 copy];
            self->_workspaceQueue = a2;
            id callOutQueue = [FBWorkspaceEventDispatcher callOutQueue];
            self->_serviceQueue = [BSServiceCompoundQueue queueWithDispatchQueue:self->_workspaceQueue targetQueue:callOutQueue];
            self->_dispatcher = a3;
            self->_lock_process = nil;
            memset(&self->_lock, 0, 4);
            self->_lock_waitingForConnect = NO;
        }
    }
    return self;
}


FBWorkspaceEventDispatcher *-[FBSceneSynchronizer _dispatcher](void)
{
    FBWorkspaceEventDispatcher *v0 = nil;
    if (self != nil) {
        v0 = self->_dispatcher;
    }
    return v0;
}


void -[FBSceneSynchronizer _setProcessHandle:](RBSProcessHandle *a1)
{
    if (self != nil) {
        if (!a1) {
            NSString *v13 = NSStringFromClass([RBSProcessHandle class]);
            NSString *v2 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"process", v13];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v14 = NSStringFromSelector(@selector(_setProcessHandle:));
                NSString *v15 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBSceneSynchronizer.m", 63, v2);
            }
            _bs_set_crash_log_message([v2 UTF8String]);
            __break(0);
        }
        if (![a1 isKindOfClass:[RBSProcessHandle class]]) {
            NSArray *v0 = OUTLINED_FUNCTION_28(a1);
            __builtin_return_address(0);
            Class v17 = [v0 classForCoder];
            if (!v17) {
                v17 = [v0 class];
            }
            NSString *v18 = NSStringFromClass(v17);
            NSString *v19 = NSStringFromClass([RBSProcessHandle class]);
            NSString *v20 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"process", v18, v19];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v21 = NSStringFromSelector(@selector(_setProcessHandle:));
                NSString *v22 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v21, v22, self, @"FBSceneSynchronizer.m", 63, v20);
            }
            _bs_set_crash_log_message([v20 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        RBSProcessHandle *v4 = self->_lock_process;
        if (self->_lock_process != nil) {
            id identity = [v4 identity];
            id identity2 = [a1 identity];
            if ([identity isEqual:identity2]) {
                int pid2 = [v4 pid];
                int pid3 = [a1 pid];
                if (pid2 == pid3) {
                    goto blk_1c4edc030;
                }
            }
            os_unfair_lock_unlock(&self->_lock);
            NSString *v9 = [NSString stringWithFormat:@"new processHandle=%@ mismatches previous=%@", a1, v4];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v24 = NSStringFromSelector(@selector(_setProcessHandle:));
                NSString *v25 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v24, v25, self, @"FBSceneSynchronizer.m", 74, v9);
            }
            _bs_set_crash_log_message([v9 UTF8String]);
            __break(0);
        }
blk_1c4edc030:
        self->_lock_process = a1;
        if (self->_lock_waitingForConnect == 1) {
            int pid = [a1 pid];
            long v11 = __getpid(pid);
            if (pid == v11) {
                id domain = [self->_dispatcher domain];
                [domain injectEndpointToFBSWorkspace];
            }
        }
        os_unfair_lock_unlock(&self->_lock);
    }
}


BSServiceDispatchQueue *-[FBSceneSynchronizer _workspaceQueue](void)
{
    BSServiceDispatchQueue *v0 = nil;
    if (self != nil) {
        v0 = self->_workspaceQueue;
    }
    return v0;
}


void -[FBSceneSynchronizer _setWaitingForConnect](void)
{
    if (!self) {
        return;
    }
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_waitingForConnect) {
        self->_lock_waitingForConnect = YES;
        if (self->_lock_process != nil) {
            int pid = [self->_lock_process pid];
            long v3 = __getpid(pid);
            if (pid == v3) {
                id domain = [self->_dispatcher domain];
                [domain injectEndpointToFBSWorkspace];
            }
        }
    }
    os_unfair_lock_unlock(&self->_lock);
}


id +[FBSceneSynchronizer synchronizerWithAuditToken:](struct AnonymousStruct_11 *a1)
{
    os_log_t v6;
    id v8;
    struct AnonymousStruct_11 buf = *(struct AnonymousStruct_11 *)a1;
    long v1 = BSVersionedPIDForAuditToken(&buf);
    id v2 = [RBSProcessIdentifier identifierWithPid:v1];
    id v3 = nil;
    id v4 = [RBSProcessHandle forceLookupIdentifer:v2 error:&v3];
    if (!v4) {
        v6 = FBLogProcessWorkspace();
        if (os_log_type_enabled(v6, OS_LOG_TYPE_DEFAULT)) {
            id v7 = NSStringFromBSVersionedPID(v1);
            os_log_with_type(v6, OS_LOG_TYPE_DEFAULT, "failed to lookup synchronizer for vPid=%{public}@ : error=%{public}@", v7, v3);
        }
        v8 = nil;
    } else {
        [v4 auditToken];
        long v9 = BSVersionedPIDForAuditToken(&buf);
        if (v1 != v9) {
            v6 = FBLogProcessWorkspace();
            if (os_log_type_enabled(v6, OS_LOG_TYPE_DEFAULT)) {
                id v10 = NSStringFromBSVersionedPID(v1);
                id v11 = NSStringFromBSVersionedPID(v9);
                os_log_with_type(v6, OS_LOG_TYPE_DEFAULT, "failed to lookup synchronizer for vPid=%{public}@ due to RB mismatch (%{public}@)", v10, v11);
                return nil;
            }
            v8 = nil;
        } else {
            v8 = [FBSceneSynchronizer _synchronizerWithMonitorableHandle:v4];
        }
    }
    return v8;
}


FBSceneSynchronizer *+[FBSceneSynchronizer _synchronizerWithMonitorableHandle:](id a1)
{
    if (!a1) {
        NSString *v1 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v11 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"handle", v1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(@selector(_synchronizerWithMonitorableHandle:));
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSceneSynchronizer.m", 90, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[RBSProcessHandle class]]) {
        NSArray *v15 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v16 = [v15 classForCoder];
        if (!v16) {
            v16 = [v15 class];
        }
        NSString *v17 = NSStringFromClass(v16);
        NSString *v18 = NSStringFromClass([RBSProcessHandle class]);
        NSString *v19 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"handle", v17, v18];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v20 = NSStringFromSelector(@selector(_synchronizerWithMonitorableHandle:));
            NSString *v21 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBSceneSynchronizer.m", 90, v19);
        }
        _bs_set_crash_log_message([v19 UTF8String]);
        __break(0);
    }
    id sharedInstance = [FBProcessManager sharedInstance];
    id v4 = nil;
    id v5 = [sharedInstance _registerProcessForMonitorableProcessHandle:a1 error:&v4];
    if (!v5) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "failed to register synchronizer for validated handle (%{public}@) : error=%{public}@", a1, v4);
        }
    }
    FBWorkspace *workspace = [v5 workspace];
    return [workspace synchronizer];
}


long -[FBSceneSynchronizer callOutQueue](void)
{
    return [FBWorkspaceEventDispatcher callOutQueue];
}


RBSProcessHandle *-[FBSceneSynchronizer processHandle](void)
{
    os_unfair_lock_lock(&self->_lock);
    RBSProcessHandle *v0 = self->_lock_process;
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


NSString *-[FBSceneSynchronizer description](void)
{
    os_unfair_lock_lock(&self->_lock);
    int pid = [self->_lock_process pid];
    os_unfair_lock_unlock(&self->_lock);
    return (pid < 1) ? [NSString stringWithFormat:@"<FBSceneSynchronizer:%p %@>", self, self->_identifier] : [NSString stringWithFormat:@"<FBSceneSynchronizer:%p %@[%i]>", self, self->_identifier, pid];
}


BSServiceDispatchQueue *-[FBSceneSynchronizer machQueue](void)
{
    return self->_workspaceQueue;
}


void -[FBSceneSynchronizer .cxx_destruct](void)
{
    self->_lock_process = nil;
    self->_dispatcher = nil;
    self->_serviceQueue = nil;
    self->_workspaceQueue = nil;
    self->_identifier = nil;
}


id +[FBSceneSynchronizer synchronizerForViewServiceWithProcessIdentifier:](id a1)
{
    id v8;
    if (!a1) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"processIdentifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBSceneSynchronizer.m", 142, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    id v1 = [RBSProcessIdentifier identifierForIdentifier:a1];
    id v2 = nil;
    id v3 = [RBSProcessHandle forceLookupIdentifer:v1 error:&v2];
    if (!v3) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            long rbs_pid = [a1 rbs_pid];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "failed to lookup viewService synchronizer with pid=%i : error=%{public}@", rbs_pid, v2);
        }
        v8 = nil;
    } else {
        v8 = [FBSceneSynchronizer _synchronizerWithMonitorableHandle:v3];
    }
    return v8;
}


void *-[FBSceneSynchronizer performAsyncOnSendingQueue:](long a1)
{
    if (!a1) {
        return self;
    } else {
        return [self->_workspaceQueue performAsync:a1];
    }
}


FBSceneSynchronizer *+[FBSceneSynchronizer detachedSynchronizerWithIdentifier:](id a1)
{
    Class aClass = [NSString class];
    if (!a1) {
        NSString *v4 = NSStringFromClass(aClass);
        NSString *v5 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"identifier", v4];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v10, self, @"FBSceneSynchronizer.m", 156, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:aClass]) {
        NSArray *v12 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v13 = [v12 classForCoder];
        if (!v13) {
            v13 = [v12 class];
        }
        NSString *v14 = NSStringFromClass(v13);
        NSString *v15 = NSStringFromClass([NSString class]);
        NSString *v16 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"identifier", v14, v15];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBSceneSynchronizer.m", 156, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    NSString *v6 = [NSString stringWithFormat:@"com.apple.frontboard.detached-scene-synchronizer<%@>", a1];
    id v7 = [BSServiceQuality serviceWithClass:33];
    id v8 = [BSServiceDispatchQueue queueWithName:v6 serviceQuality:v7];
    return [[FBSceneSynchronizer alloc] _initWithIdentifier:a1 workspaceQueue:v8 dispatcher:0];
}


BSServiceCompoundQueue *-[FBSceneSynchronizer serviceQueue](void)
{
    return self->_serviceQueue;
}
