struct FBSceneEventQueue {
    BSEventQueueLock *_idleEventLock; // +0x38
};

BSSimpleAssertion *+[FBSceneEventQueue suspendIdleWorkForReason:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "+[FBSceneEventQueue suspendIdleWorkForReason:]");
    }
    BSEventQueue *v1 = FBSceneIdleEventQueue();
    id v2 = [v1 acquireLockForReason:a1];
    return [[BSSimpleAssertion alloc] initWithIdentifier:@"SuspendIdleWork" forReason:a1 queue:dispatch_get_main_queue() invalidationBlock:^void(id arg1) {
        [v2 relinquish];
    }];
}


long -[FBSceneEventQueue _noteQueueDidUnlock](void)
{
    return [self _relinquishIdleLockIfAppropriate];
}


void -[FBSceneEventQueue _relinquishIdleLockIfAppropriate](void)
{
    if (!self) {
        return;
    }
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneEventQueue _relinquishIdleLockIfAppropriate]");
    }
    if (!self->_idleEventLock || ![self isEmpty]) {
        return;
    }
    if (![self executingEvent]) {
        if ([self isLocked]) {
            return;
        }
        BSEventQueueLock *v3 = self->_idleEventLock;
        self->_idleEventLock = nil;
        [v3 relinquish];
    }
}


id -[FBSceneEventQueue _noteWillPendEvents:atPosition:](long a1, long a2)
{
    if (!self->_idleEventLock) {
        BSEventQueue *v1 = FBSceneIdleEventQueue();
        self->_idleEventLock = [v1 acquireLockForReason:@"FBSceneEventQueue"];
        return v1;
    } else {
        return self;
    }
}


long -[FBSceneEventQueue _noteQueueDidDrain](void)
{
    return [self _relinquishIdleLockIfAppropriate];
}


void +[FBSceneEventQueue executeWhenIdle:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "+[FBSceneEventQueue executeWhenIdle:]");
    }
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBSceneEventQueue.m", 34, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    id v1 = [BSEventQueueEvent eventWithName:@"idleEvent" handler:a1];
    BSEventQueue *v2 = FBSceneIdleEventQueue();
    [v2 executeOrInsertEvent:v1 atPosition:1];
}


void -[FBSceneEventQueue executeOrAppend:](long a1)
{
    id v0 = [BSEventQueueEvent eventWithName:@"event" handler:a1];
    [super executeOrInsertEvent:v0 atPosition:1];
}


void -[FBSceneEventQueue .cxx_destruct](void)
{
    self->_idleEventLock = nil;
}


id -[FBSceneEventQueue _noteQueueDidLock](void)
{
    if (!self->_idleEventLock) {
        BSEventQueue *v1 = FBSceneIdleEventQueue();
        self->_idleEventLock = [v1 acquireLockForReason:@"FBSceneEventQueue"];
        return v1;
    } else {
        return self;
    }
}


BOOL +[FBSceneEventQueue isIdleWorkSuspended](void)
{
    BSEventQueue *v0 = FBSceneIdleEventQueue();
    return [v0 isLocked];
}
