struct FBWorkspaceConnection {
    FBWorkspace *_workspace; // +0x8
    BSServiceConnection *_workspaceLock_connection; // +0x10
    NSMutableArray *_workspaceLock_waitForConnectBlocks; // +0x18
    bool _workspaceLock_valid; // +0x20
};

static NSMapTable *qword_1e70eb5c0;
static long _MergedGlobals;

FBWorkspaceConnection *-[FBWorkspaceConnection _initWithWorkspace:](FBWorkspace *a1)
{
    FBWorkspaceConnection *self;
    if (self != nil) {
        self = [super init];
        if (self != nil) {
            self->_workspace = a1;
            self->_workspaceLock_waitForConnectBlocks = [NSMutableArray new];
            self->_workspaceLock_valid = YES;
        }
    }
    return self;
}


void -[FBWorkspaceConnection workspaceLock_enqueueConnectBlock:](void (^a1)(long))
{
    void (^v0)(id) = a1;
    if (self != nil) {
        if (!v0) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(workspaceLock_enqueueConnectBlock:));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspaceConnection.m", 149, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        [self->_workspace _assertLocked];
        if (!self->_workspaceLock_waitForConnectBlocks) {
            id v9 = (self->_workspaceLock_valid != 1) ? nil : [self->_workspaceLock_connection remoteTarget];
            id queue = [self queue];
            [queue performAsync:^void(void) {
                v0(v9);
            }];
        } else {
            id aBlock = [v0 copy];
            void *v4 = _Block_copy(aBlock);
            [self->_workspaceLock_waitForConnectBlocks addObject:v4];
            id _synchronizer = [self->_workspace _synchronizer];
            [_synchronizer _setWaitingForConnect];
        }
    }
}


void -[FBWorkspaceConnection _workspaceScene:enqueueConnectBlock:](long a1, void (^a2)(long))
{
    void (^v1)(long) = a2;
    if (self != nil) {
        if (!v1) {
            NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_workspaceScene:enqueueConnectBlock:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceConnection.m", 99, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        id queue = [self queue];
        [queue assertBarrierOnQueue];
        [self->_workspace _lock];
        if (!self->_workspaceLock_waitForConnectBlocks) {
            id v7 = (self->_workspaceLock_valid != 1) ? nil : [self->_workspaceLock_connection remoteTarget];
            [self->_workspace _unlock];
            v1(v7);
        } else {
            id aBlock = [v1 copy];
            id v8 = _Block_copy(aBlock);
            [self->_workspaceLock_waitForConnectBlocks addObject:v8];
            id _synchronizer = [self->_workspace _synchronizer];
            [_synchronizer _setWaitingForConnect];
            [self->_workspace _unlock];
        }
    }
}


id -[FBWorkspaceConnection queue](void)
{
    if (!self) {
        return nil;
    }
    id _synchronizer = [self->_workspace _synchronizer];
    return [_synchronizer _workspaceQueue];
}


bool -[FBWorkspaceConnection workspaceLock_isValid](void)
{
    if (!self) {
        return false;
    }
    [self->_workspace _assertLocked];
    return self->_workspaceLock_valid;
}


id -[FBWorkspaceConnection isOutgoing](void)
{
    if (self != nil) {
        Class v1 = [self class];
        Class v2 = [FBWorkspaceOutgoingConnection class];
        return v1 == v2;
    }
    return self;
}


id +[FBWorkspaceConnection currentWorkspaceConnection](void)
{
    id currentContext = [BSServiceConnection currentContext];
    if (!currentContext) {
        NSString *v5 = [NSString stringWithFormat:@"if we're asking for the currentContext and we don't have it then something must have gone seriously wrong"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(@selector(currentWorkspaceConnection));
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspaceConnection.m", 123, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_unfair_lock_lock(&_MergedGlobals);
    id v2 = [qword_1e70eb5c0 objectForKey:currentContext];
    os_unfair_lock_unlock(&_MergedGlobals);
    if (!v2) {
        os_log_t oslog = FBLogProcessWorkspace();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Could not find workspaceConnection for currentConnection=%{public}@", currentContext);
        }
    }
    return v2;
}


BSServiceConnection *-[FBWorkspaceConnection _workspaceLock_connection](void)
{
    BSServiceConnection *self;
    if (self != nil) {
        [self->_workspace _assertLocked];
        self = self->_workspaceLock_connection;
    }
    return self;
}


void -[FBWorkspaceConnection _workspaceLock_consumeConnection:](BSServiceConnection *a1)
{
    if (self != nil) {
        [self->_workspace _assertLocked];
        if (!self->_workspaceLock_waitForConnectBlocks) {
            NSString *v1 = [NSString stringWithFormat:@"cannot set connection if we've already been invalidated : conn=%@", a1];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v5 = NSStringFromSelector(@selector(_workspaceLock_consumeConnection:));
                NSString *v6 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v6, self, @"FBWorkspaceConnection.m", 56, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        self->_workspaceLock_connection = a1;
        os_unfair_lock_lock(&_MergedGlobals);
        id v2 = *(uint64_t *)&__MergedGlobals[8];
        if (!*(uint64_t *)&__MergedGlobals[8]) {
            qword_1e70eb5c0 = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsObjectPointerPersonality valueOptions:NSPointerFunctionsObjectPointerPersonality];
            v2 = FBWorkspaceEventDispatcherSource->field_1472;
        }
        id v3 = [v2 objectForKey:a1];
        if (v3 != nil) {
            NSString *v8 = [NSString stringWithFormat:@"should not be possible to have an existing mapping for connection=%p : existing=%@", a1, qword_1e70eb5c0];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v9 = NSStringFromSelector(@selector(_workspaceLock_consumeConnection:));
                NSString *v10 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBWorkspaceConnection.m", 64, v8);
            }
            _bs_set_crash_log_message([v8 UTF8String]);
            __break(0);
        }
        [qword_1e70eb5c0 setObject:self forKey:a1];
        os_unfair_lock_unlock(&_MergedGlobals);
        [a1 configure:^void(id<BSServiceConnectionCommonConfiguring> arg1) {
            id _synchronizer = [self->_workspace _synchronizer];
            id _workspaceQueue = [_synchronizer _workspaceQueue];
            [arg1 setQueue:_workspaceQueue];
            [arg1 setLocalTarget:self->_workspace];
        }];
        [self->_workspaceLock_connection activate];
    }
}


void -[FBWorkspaceConnection _flushConnectBlocksWithProxy:](id a1)
{
    if (self != 0) {
        [self->_workspace _lock];
        NSMutableArray *v1 = self->_workspaceLock_waitForConnectBlocks;
        self->_workspaceLock_waitForConnectBlocks = nil;
        [self->_workspace _unlock];
        for (id v8 in v1) {
            v8->field_16(v8, a1);
        }
    }
}


id -[FBWorkspaceConnection _acquireAssertionForWorkspaceScene:withState:](id a1, long a2)
{
    if (!self) {
        return nil;
    }
    id identity = [a1 identity];
    NSString *description = [identity description];
    return [self->_workspace _acquireAssertionForReason:description withState:a2];
}


NSMutableArray *-[FBWorkspaceConnection workspaceLock_invalidate](void)
{
    NSMutableArray *self;
    if (self != nil) {
        [self->_workspace _assertLocked];
        NSMutableArray *v1 = self->_workspaceLock_waitForConnectBlocks;
        self->_workspaceLock_waitForConnectBlocks = nil;
        os_unfair_lock_lock(&_MergedGlobals);
        id v3 = [qword_1e70eb5c0 objectForKey:self->_workspaceLock_connection];
        if (v3 != nil && v3 != self) {
            NSString *v6 = [NSString stringWithFormat:@"should not be possible to map to something other than connection=%p for connection=%@ : existing=%@", self, self->_workspaceLock_connection, v3];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v0 = NSStringFromSelector(@selector(workspaceLock_invalidate));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v7, self, @"FBWorkspaceConnection.m", 171, v6);
            }
            _bs_set_crash_log_message([v6 UTF8String]);
            __break(0);
        }
        [qword_1e70eb5c0 removeObjectForKey:self->_workspaceLock_connection];
        os_unfair_lock_unlock(&_MergedGlobals);
        [self->_workspaceLock_connection invalidate];
        self->_workspaceLock_valid = NO;
        self = (![v1 count]) ? nil : v1;
    }
    return self;
}


void -[FBWorkspaceConnection .cxx_destruct](void)
{
    self->_workspaceLock_waitForConnectBlocks = nil;
    self->_workspaceLock_connection = nil;
    self->_workspace = nil;
}


FBWorkspace *-[FBWorkspaceConnection _workspace](void)
{
    FBWorkspace *self;
    if (self != nil) {
        self = self->_workspace;
    }
    return self;
}


FBProcess *-[FBWorkspaceConnection remoteProcess](void)
{
    FBProcess *self;
    if (self != nil) {
        self = [self->_workspace process];
    }
    return self;
}
