struct FBProcessObserver {
    __weak id<FBProcessObserver> _observer; // +0x8
    unsigned long _observerAddress; // +0x10
    Class _observerClass; // +0x18
    bool _supportsWillExit; // +0x20
    bool _supportsDidExit; // +0x21
    bool _supportsStateDidChange; // +0x22
    bool _supportsApplicationDidExit; // +0x23
    bool _supportsApplicationWillLaunch; // +0x24
    bool _supportsApplicationDidLaunch; // +0x25
    bool _supportsApplicationDebugState; // +0x26
    int _invalidated; // +0x28
    int _calledWillExit; // +0x2c
    int _calledDidExit; // +0x30
    int _calledWillLaunch; // +0x34
    int _calledDidLaunch; // +0x38
};

void -[FBProcessObserver applicationProcessWillLaunch:](id a1)
{
    if ((BSAtomicGetFlag(&self->_invalidated) & 1) == 0 && BSAtomicSetFlag(1, &self->_calledWillLaunch) != 0) {
        id<FBProcessObserver> v1 = self->_observer;
        if (self->_supportsApplicationWillLaunch == 1) {
            long v2 = BSAtomicGetFlag(&self->_calledDidExit);
            if ((v2 & 1) == 0 && v1 != nil && [a1 isApplicationProcess] != 0) {
                [v1 applicationProcessWillLaunch:a1];
            }
        }
    }
}


void -[FBProcessObserver applicationProcessDidLaunch:](id a1)
{
    if ((BSAtomicGetFlag(&self->_invalidated) & 1) == 0 && BSAtomicSetFlag(1, &self->_calledDidLaunch) != 0) {
        id<FBProcessObserver> v1 = self->_observer;
        if (self->_observer != nil) {
            [self applicationProcessWillLaunch:a1];
            if (self->_supportsApplicationDidLaunch == 1 && (BSAtomicGetFlag(&self->_calledDidExit) & 1) == 0 && [a1 isApplicationProcess] != 0) {
                [v1 applicationProcessDidLaunch:a1];
            }
        }
    }
}


unsigned long -[FBProcessObserver hash](void)
{
    return self->_observerAddress;
}


void -[FBProcessObserver process:stateDidChangeFromState:toState:](id a1, id a2, id a3)
{
    id<FBProcessObserver> v3 = self->_observer;
    if (self->_supportsStateDidChange == 1) {
        long v4 = BSAtomicGetFlag(&self->_calledDidExit);
        if ((v4 & 1) == 0 && v3 != nil) {
            [v3 process:a1 stateDidChangeFromState:a2 toState:a3];
        }
    }
}


FBProcessObserver *-[FBProcessObserver initWithObserver:](id<FBProcessObserver> a1)
{
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"observer != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v3, self, @"FBProcessObserver.m", 34, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    FBProcessObserver *v2 = [super init];
    if (v2 != nil) {
        v2->_observer = a1;
        v2->_observerAddress = a1;
        v2->_observerClass = [a1 class];
        v2->_supportsWillExit = [a1 respondsToSelector:@selector(processWillExit:)];
        v2->_supportsDidExit = [a1 respondsToSelector:@selector(processDidExit:)];
        v2->_supportsStateDidChange = [a1 respondsToSelector:@selector(process:stateDidChangeFromState:toState:)];
        v2->_supportsApplicationDidExit = [a1 respondsToSelector:@selector(applicationProcessDidExit:withContext:)];
        v2->_supportsApplicationWillLaunch = [a1 respondsToSelector:@selector(applicationProcessWillLaunch:)];
        v2->_supportsApplicationDidLaunch = [a1 respondsToSelector:@selector(applicationProcessDidLaunch:)];
        v2->_supportsApplicationDebugState = [a1 respondsToSelector:@selector(applicationProcessDebuggingStateDidChange:)];
    }
    return v2;
}


void -[FBProcessObserver .cxx_destruct](void)
{
    self->_observer = nil;
}


void -[FBProcessObserver processWillExit:](id a1)
{
    if ((BSAtomicGetFlag(&self->_invalidated) & 1) == 0 && BSAtomicSetFlag(1, &self->_calledWillExit) != 0) {
        id<FBProcessObserver> v1 = self->_observer;
        if (v1 != nil && self->_supportsWillExit == 1) {
            [v1 processWillExit:a1];
        }
    }
}


void -[FBProcessObserver processDidExit:](id a1)
{
    if ((BSAtomicGetFlag(&self->_invalidated) & 1) == 0 && BSAtomicSetFlag(1, &self->_calledDidExit) != 0) {
        id<FBProcessObserver> v1 = self->_observer;
        if (self->_observer != nil) {
            if (self->_supportsApplicationDidExit == 1 && [a1 isApplicationProcess] != 0) {
                FBProcessExitContext *exitContext = [a1 exitContext];
                [v1 applicationProcessDidExit:a1 withContext:exitContext];
            }
            if (self->_supportsDidExit == 1) {
                [v1 processDidExit:a1];
            }
        }
    }
}


id<FBProcessObserver> -[FBProcessObserver observer](void)
{
    return self->_observer;
}


long -[FBProcessObserver invalidate](void)
{
    return BSAtomicSetFlag(1, &self->_invalidated);
}


bool -[FBProcessObserver isEqual:](id a1)
{
    if (self == a1) {
        return true;
    }
    if ([a1 isKindOfClass:[self class]] && a1->field_16 == self->_observerAddress && a1->field_24 == self->_observerClass) {
        id v2 = objc_loadWeakRetained(a1 + 8);
        id<FBProcessObserver> v3 = self->_observer;
        return v2 == v3;
    }
    return false;
}


long -[FBProcessObserver applicationProcessDidExit:withContext:](long a1, long a2)
{
    return self;
}


void -[FBProcessObserver applicationProcessDebuggingStateDidChange:](id a1)
{
    if (self->_supportsApplicationDebugState == 1 && [a1 isApplicationProcess] != 0) {
        id<FBProcessObserver> v1 = self->_observer;
        [v1 applicationProcessDebuggingStateDidChange:a1];
    }
}
