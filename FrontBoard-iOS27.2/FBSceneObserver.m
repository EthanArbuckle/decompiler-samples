struct FBSceneObserver {
    __weak id<FBSceneObserver> _observer; // +0x8
    unsigned long _observerAddress; // +0x10
    Class _observerClass; // +0x18
    bool _isDelegate; // +0x20
    struct { bool contentStateDidChange; bool didUpdateSettings; bool updatePreparedLEGACY; bool updateAppliedLEGACY; bool updateCompletedLEGACY; bool didUpdateClientSettings; bool clientSettingsUpdatedLEGACY; bool willActivate; bool didActivate; bool willDeactivateWithError; bool willDeactivateWithContext; bool didInvalidate; bool didInvalidateWithContext; bool clientDidConnect; bool handleActions; bool wantsInactiveUpdates; } _observerFlags; // +0x21
    struct { bool willUpdateSettingsLEGACY; bool willUpdateSettings; bool didReceiveActions; bool didDeactivateWithError; bool didDeactivateWithContext; } _delegateFlags; // +0x31
    struct { bool willUpdateSettingsLEGACY; bool willUpdateSettings; bool handlePrivateActions; bool willInvalidate; bool invalidate; } _componentFlags; // +0x36
    id<FBSceneComponent> _component; // +0x40
    Class _extension; // +0x48
};

bool -[FBSceneObserver receiverImplementsWillUpdate](void)
{
    if (!self) {
        return false;
    } else if ((self->_delegateFlags.willUpdateSettings & 1) != 0 || (self->_componentFlags.willUpdateSettings & 1) != 0) {
        return true;
    }
    if ((self->_delegateFlags.willUpdateSettingsLEGACY & 1) == 0) {
        return self->_componentFlags.willUpdateSettingsLEGACY & 1;
    } else {
        return true;
    }
}


void -[FBSceneObserver scene:willUpdateSettings:](id a1, id a2)
{
    if (self->_delegateFlags.willUpdateSettings == 1) {
        id delegate = [self delegate];
        [delegate scene:a1 willUpdateSettings:a2];
    } else if (self->_componentFlags.willUpdateSettings != 1) {
        id mutableSettings = [a2 mutableSettings];
        FBSSceneTransitionContext *transitionContext = [a2 transitionContext];
        [self scene:a1 willUpdateSettings:mutableSettings withTransitionContext:transitionContext];
    } else {
        [self->_component scene:a1 willUpdateSettings:a2];
    }
}


id<FBSceneObserver> -[FBSceneObserver delegate](void)
{
    id<FBSceneObserver> self;
    if (self != nil) {
        if (self->_isDelegate != 1) {
            return nil;
        }
        self = self->_observer;
    }
    return self;
}


void -[FBSceneObserver scene:willUpdateSettings:withTransitionContext:](id a1, id a2, id a3)
{
    if (self->_delegateFlags.willUpdateSettingsLEGACY == 1) {
        id delegate = [self delegate];
        [delegate scene:a1 willUpdateSettings:a2 withTransitionContext:a3];
    } else if (self->_componentFlags.willUpdateSettingsLEGACY == 1) {
        [self->_component scene:a1 willUpdateSettings:a2 withTransitionContext:a3];
    }
}


FBSceneObserver *-[FBSceneObserver initWithComponent:extension:](id<FBSceneComponent> a1, Class a2)
{
    FBSceneObserver *self;
    if (self != nil) {
        self = [self _initWithObserver:a1];
        if (self != nil) {
            self->_extension = a2;
            self->_component = a1;
            self->_componentFlags.willUpdateSettingsLEGACY = [a1 respondsToSelector:@selector(scene:willUpdateSettings:withTransitionContext:)];
            self->_componentFlags.willUpdateSettings = [a1 respondsToSelector:@selector(scene:willUpdateSettings:)];
            self->_componentFlags.handlePrivateActions = [a1 respondsToSelector:@selector(handlePrivateActions:)];
            self->_componentFlags.willInvalidate = [a1 respondsToSelector:@selector(componentWillInvalidate:)];
            self->_componentFlags.invalidate = [a1 respondsToSelector:@selector(invalidate)];
        }
    }
    return self;
}


id<FBSceneComponent> -[FBSceneObserver component](void)
{
    id<FBSceneComponent> self;
    if (self != nil) {
        self = self->_component;
    }
    return self;
}


bool -[FBSceneObserver receiverWantsInactiveUpdates](void)
{
    void *self;
    if (self != 0) {
        id<FBSceneObserver> v0 = self->_observer;
        self = (!v0) ? 0 : self->_observerFlags.wantsInactiveUpdates;
    }
    return self & 1;
}


id -[FBSceneObserver initWithObserver:](long a1)
{
    if (!self) {
        return self;
    } else {
        return [self _initWithObserver:a1];
    }
}


FBSceneObserver *-[FBSceneObserver initWithDelegate:](id a1)
{
    FBSceneObserver *self;
    if (self != nil) {
        self = [self _initWithObserver:a1];
        if (self != nil) {
            self->_isDelegate = YES;
            self->_delegateFlags.willUpdateSettingsLEGACY = [a1 respondsToSelector:@selector(scene:willUpdateSettings:withTransitionContext:)];
            self->_delegateFlags.willUpdateSettings = [a1 respondsToSelector:@selector(scene:willUpdateSettings:)];
            self->_delegateFlags.didReceiveActions = [a1 respondsToSelector:@selector(scene:didReceiveActions:)];
            self->_delegateFlags.didDeactivateWithError = [a1 respondsToSelector:@selector(sceneDidDeactivate:withError:)];
            self->_delegateFlags.didDeactivateWithContext = [a1 respondsToSelector:@selector(sceneDidDeactivate:withContext:)];
        }
    }
    return self;
}


void -[FBSceneObserver scene:didUpdateClientSettings:](id a1, id a2)
{
    if (self->_observerFlags.didUpdateClientSettings != 1) {
        FBSSceneSettingsDiff *settingsDiff = [a2 settingsDiff];
        id previousSettings = [a2 previousSettings];
        FBSSceneTransitionContext *transitionContext = [a2 transitionContext];
        [self scene:a1 didUpdateClientSettingsWithDiff:settingsDiff oldClientSettings:previousSettings transitionContext:transitionContext];
    } else {
        id<FBSceneObserver> v6 = self->_observer;
        [v6 scene:a1 didUpdateClientSettings:a2];
    }
}


void *-[FBSceneObserver scene:didPrepareUpdateWithContext:](id a1, id a2)
{
    if (self->_observerFlags.updatePreparedLEGACY != 1) {
        return self;
    }
    id<FBSceneObserver> v3 = self->_observer;
    [v3 scene:a1 didPrepareUpdateWithContext:a2];
    return v3;
}


void *-[FBSceneObserver sceneWillActivate:](id a1)
{
    if (self->_observerFlags.willActivate != 1) {
        return self;
    }
    id<FBSceneObserver> v2 = self->_observer;
    [v2 sceneWillActivate:a1];
    return v2;
}


bool -[FBSceneObserver isEqual:](id a1)
{
    if (self == a1) {
        return true;
    }
    if ([a1 isKindOfClass:[self class]] && a1->field_16 == self->_observerAddress && a1->field_24 == self->_observerClass) {
        id v2 = objc_loadWeakRetained(a1 + 8);
        id<FBSceneObserver> v3 = self->_observer;
        return v2 == v3;
    }
    return false;
}


unsigned long -[FBSceneObserver hash](void)
{
    return self->_observerAddress;
}


FBSceneObserver *-[FBSceneObserver _initWithObserver:](id<FBSceneObserver> a1)
{
    FBSceneObserver *v2 = [super init];
    if (v2 != nil) {
        v2->_observerAddress = a1;
        v2->_observerClass = [a1 class];
        v2->_observer = a1;
        v2->_observerFlags.contentStateDidChange = [a1 respondsToSelector:@selector(sceneContentStateDidChange:)];
        v2->_observerFlags.didUpdateSettings = [a1 respondsToSelector:@selector(scene:didUpdateSettings:)];
        v2->_observerFlags.updatePreparedLEGACY = [a1 respondsToSelector:@selector(scene:didPrepareUpdateWithContext:)];
        v2->_observerFlags.updateAppliedLEGACY = [a1 respondsToSelector:@selector(scene:didApplyUpdateWithContext:)];
        v2->_observerFlags.updateCompletedLEGACY = [a1 respondsToSelector:@selector(scene:didCompleteUpdateWithContext:error:)];
        v2->_observerFlags.didUpdateClientSettings = [a1 respondsToSelector:@selector(scene:didUpdateClientSettings:)];
        v2->_observerFlags.clientSettingsUpdatedLEGACY = [a1 respondsToSelector:@selector(scene:didUpdateClientSettingsWithDiff:oldClientSettings:transitionContext:)];
        v2->_observerFlags.willActivate = [a1 respondsToSelector:@selector(sceneWillActivate:)];
        v2->_observerFlags.didActivate = [a1 respondsToSelector:@selector(sceneDidActivate:)];
        v2->_observerFlags.willDeactivateWithError = [a1 respondsToSelector:@selector(sceneWillDeactivate:withError:)];
        v2->_observerFlags.willDeactivateWithContext = [a1 respondsToSelector:@selector(sceneWillDeactivate:withContext:)];
        v2->_observerFlags.didInvalidate = [a1 respondsToSelector:@selector(sceneDidInvalidate:)];
        v2->_observerFlags.didInvalidateWithContext = [a1 respondsToSelector:@selector(sceneDidInvalidate:withContext:)];
        v2->_observerFlags.clientDidConnect = [a1 respondsToSelector:@selector(scene:clientDidConnect:)];
        v2->_observerFlags.handleActions = [a1 respondsToSelector:@selector(scene:handleActions:)];
        if ([a1 respondsToSelector:@selector(sceneObserverWantsUpdatesFromInactiveScenes)]) {
            v2->_observerFlags.wantsInactiveUpdates = [a1 sceneObserverWantsUpdatesFromInactiveScenes];
        }
    }
    return v2;
}


void -[FBSceneObserver scene:didUpdateSettings:](id a1, id a2)
{
    id<FBSceneObserver> v2 = self->_observer;
    if (self->_observerFlags.didUpdateSettings != 1) {
        if (self->_observerFlags.updateAppliedLEGACY == 1) {
            FBSSceneTransitionContext *transitionContext = [a2 transitionContext];
            id updateContext = [transitionContext updateContext];
            [v2 scene:a1 didApplyUpdateWithContext:updateContext];
        }
    } else {
        [v2 scene:a1 didUpdateSettings:a2];
    }
}


void *-[FBSceneObserver sceneDidActivate:](id a1)
{
    if (self->_observerFlags.didActivate != 1) {
        return self;
    }
    id<FBSceneObserver> v2 = self->_observer;
    [v2 sceneDidActivate:a1];
    return v2;
}


void *-[FBSceneObserver sceneContentStateDidChange:](id a1)
{
    if (self->_observerFlags.contentStateDidChange != 1) {
        return self;
    }
    id<FBSceneObserver> v2 = self->_observer;
    [v2 sceneContentStateDidChange:a1];
    return v2;
}


id<FBSceneObserver> -[FBSceneObserver observer](void)
{
    id<FBSceneObserver> self;
    if (self != nil) {
        self = self->_observer;
    }
    return self;
}


void *-[FBSceneObserver scene:didUpdateClientSettingsWithDiff:oldClientSettings:transitionContext:](id a1, id a2, id a3, id a4)
{
    if (self->_observerFlags.clientSettingsUpdatedLEGACY != 1) {
        return self;
    }
    id<FBSceneObserver> v5 = self->_observer;
    [v5 scene:a1 didUpdateClientSettingsWithDiff:a2 oldClientSettings:a3 transitionContext:a4];
    return v5;
}


void *-[FBSceneObserver scene:clientDidConnect:](id a1, id a2)
{
    if (self->_observerFlags.clientDidConnect != 1) {
        return self;
    }
    id<FBSceneObserver> v3 = self->_observer;
    [v3 scene:a1 clientDidConnect:a2];
    return v3;
}


void -[FBSceneObserver .cxx_destruct](void)
{
    self->_extension = 0;
    self->_component = nil;
    self->_observer = nil;
}


void *-[FBSceneObserver scene:didCompleteUpdateWithContext:error:](id a1, id a2, id a3)
{
    if (self->_observerFlags.updateCompletedLEGACY != 1) {
        return self;
    }
    id<FBSceneObserver> v4 = self->_observer;
    [v4 scene:a1 didCompleteUpdateWithContext:a2 error:a3];
    return v4;
}


bool -[FBSceneObserver delegateReceivesActions](void)
{
    if (!self) {
        return self & 1;
    }
    if (self->_isDelegate != 1) {
        return false;
    }
    id<FBSceneObserver> v0 = self->_observer;
    self = (!v0) ? 0 : self->_delegateFlags.didReceiveActions;
    return self & 1;
}


bool -[FBSceneObserver observerHandlesActions](void)
{
    void *self;
    if (self != 0) {
        id<FBSceneObserver> v0 = self->_observer;
        self = (!v0) ? 0 : self->_observerFlags.handleActions;
    }
    return self & 1;
}


id -[FBSceneObserver scene:handleActions:](id a1, id a2)
{
    id v2;
    if (self->_observerFlags.handleActions != 1) {
        return nil;
    }
    if (![a2 count]) {
        v2 = nil;
    } else {
        id<FBSceneObserver> v3 = self->_observer;
        v2 = [v3 scene:a1 handleActions:a2];
    }
    return v2;
}


void -[FBSceneObserver sceneDidDeactivate:withContext:](id a1, id a2)
{
    id delegate = [self delegate];
    if (delegate != nil) {
        if (self->_delegateFlags.didDeactivateWithContext != 1) {
            if (self->_delegateFlags.didDeactivateWithError == 1) {
                NSError *error = [a2 error];
                [delegate sceneDidDeactivate:a1 withError:error];
            }
        } else {
            [delegate sceneDidDeactivate:a1 withContext:a2];
        }
    }
}


id -[FBSceneObserver invalidate](void)
{
    memset(&self->_delegateFlags, 0, 5);
    memset(&self->_observerFlags, 0, 16);
    memset(&self->_componentFlags, 0, 5);
    self->_component = nil;
    return objc_storeWeak(&self->_observer, nil);
}


void -[FBSceneObserver sceneWillDeactivate:withContext:](id a1, id a2)
{
    id<FBSceneObserver> v2 = self->_observer;
    if (v2 != nil) {
        if (self->_observerFlags.willDeactivateWithContext != 1) {
            if (self->_observerFlags.willDeactivateWithError == 1) {
                NSError *error = [a2 error];
                [v2 sceneWillDeactivate:a1 withError:error];
            }
        } else {
            [v2 sceneWillDeactivate:a1 withContext:a2];
        }
    }
}


void -[FBSceneObserver sceneDidInvalidate:withContext:](id a1, id a2)
{
    id<FBSceneComponent> v2 = self->_component;
    if (self->_component != nil && self->_componentFlags.willInvalidate == 1) {
        FBSSceneSettings *settings = [a1 settings];
        id v4 = [settings mutableCopy];
        [v2 componentWillInvalidate:v4];
    }
    id<FBSceneObserver> v5 = self->_observer;
    if (v5 != nil) {
        if (self->_observerFlags.didInvalidateWithContext != 1) {
            if (self->_observerFlags.didInvalidate == 1) {
                [v5 sceneDidInvalidate:a1];
            }
        } else {
            [v5 sceneDidInvalidate:a1 withContext:a2];
        }
    }
    if (v2 != nil && self->_componentFlags.invalidate == 1) {
        [v2 invalidate];
    }
    [self invalidate];
}


id -[FBSceneObserver scene:didReceiveActions:](id a1, id a2)
{
    if (self->_delegateFlags.didReceiveActions == 1) {
        id delegate = [self delegate];
        [delegate scene:a1 didReceiveActions:a2];
        return delegate;
    } else {
        return self;
    }
}


id -[FBSceneObserver scene:handlePrivateActions:](id a1, id a2)
{
    return (!self->_component || self->_componentFlags.handlePrivateActions != 1) ? [self scene:a1 handleActions:a2] : [self->_component handlePrivateActions:a2];
}


long -[FBSceneObserver description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneObserver succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneObserver succinctDescriptionBuilder](void)
{
    NSString *v0;
    if (self->_isDelegate) {
        v0 = @"delegate";
    } else {
        v0 = (!self->_component) ? @"observer" : @"component";
    }
    id v1 = [BSDescriptionBuilder builderWithObject:self];
    id<FBSceneObserver> v2 = self->_observer;
    [v1 appendObject:v2 withName:v0];
    return v1;
}


id -[FBSceneObserver descriptionWithMultilinePrefix:](id a1)
{
    id v1 = [self descriptionBuilderWithMultilinePrefix:a1];
    if (self->_isDelegate == 1) {
        [v1 appendBodySectionWithName:@"delegate" multilinePrefix:a1 block:^void(void) {
            [v1 appendBool:self->_delegateFlags.willUpdateSettingsLEGACY withName:@"RespondsToWillUpdateSettingsWithTransitionContext" ifEqualTo:1];
            [v1 appendBool:self->_delegateFlags.willUpdateSettings withName:@"RespondsToWillUpdateSettings" ifEqualTo:1];
            [v1 appendBool:self->_delegateFlags.didReceiveActions withName:@"RespondsToDidReceiveActions" ifEqualTo:1];
            [v1 appendBool:self->_delegateFlags.didDeactivateWithError withName:@"RespondsToDidDeactivateWithError" ifEqualTo:1];
        }];
    }
    if (self->_component != nil) {
        [v1 appendBodySectionWithName:@"component" multilinePrefix:a1 block:^void(void) {
            [v1 appendBool:self->_componentFlags.willUpdateSettingsLEGACY withName:@"RespondsToWillUpdateSettingsWithTransitionContext" ifEqualTo:1];
            [v1 appendBool:self->_componentFlags.willUpdateSettings withName:@"RespondsToWillUpdateSettings" ifEqualTo:1];
        }];
    }
    [v1 appendBool:self->_observerFlags.didUpdateSettings withName:@"RespondsToDidUpdateSettings" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.didUpdateClientSettings withName:@"RespondsToDidUpdateClientSettings" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.updatePreparedLEGACY withName:@"RespondsToPrepared" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.updateAppliedLEGACY withName:@"RespondsToApplied" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.updateCompletedLEGACY withName:@"RespondsToCompleted" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.didInvalidate withName:@"RespondsToInvalidated" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.clientSettingsUpdatedLEGACY withName:@"RespondsToClientSettingsUpdated" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.didActivate withName:@"RespondsToDidActivate" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.willDeactivateWithError withName:@"RespondsToWillDeactivate" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.clientDidConnect withName:@"RespondsToClientDidConnect" ifEqualTo:1];
    [v1 appendBool:self->_observerFlags.handleActions withName:@"RespondsToHandleActions" ifEqualTo:1];
    return [v1 build];
}


long -[FBSceneObserver descriptionBuilderWithMultilinePrefix:](long a1)
{
    return [self succinctDescriptionBuilder];
}


void -[FBSceneObserver sceneDidDeactivate:withError:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"call sceneDidDeactivate:withContext:"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 233, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneObserver scene:didApplyUpdateWithContext:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"call scene:didUpdateSettings: instead"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 265, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneObserver sceneWillDeactivate:withError:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"call sceneWillDeactivate:withContext:"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 290, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneObserver sceneDidInvalidate:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"call sceneDidInvalidate:withContext:"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 307, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


long -[FBSceneObserver sceneObserverWantsUpdatesFromInactiveScenes](void)
{
    return [self receiverWantsInactiveUpdates];
}


void -[FBSceneObserver initWithScene:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"called before this object is created"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 388, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneObserver configureInitialSettings:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"called before this object is created"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 399, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneObserver componentWillInvalidate:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"not handled by this object"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneObserver.m", 403, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
