struct FBSceneManagerObserver {
    __weak id<FBSceneManagerObserver> _observer; // +0x8
    unsigned long _observerAddress; // +0x10
    Class _observerClass; // +0x18
    bool _isDelegate; // +0x20
    bool _privateDelegate; // +0x21
    bool _didDestroyDEPRECATED; // +0x22
    bool _willUpdateSceneDEPRECATED; // +0x23
    bool _willCommitDEPRECATED; // +0x24
    bool _didCommitDEPRECATED; // +0x25
    bool _didAddLEGACY; // +0x26
    bool _willRemoveLEGACY; // +0x27
    bool _interceptSceneUpdatesLEGACY; // +0x28
    bool _clientDidConnectLEGACY; // +0x29
    bool _didReceiveSceneRequestLEGACY; // +0x2a
    bool _didAdd; // +0x2b
    bool _willRemove; // +0x2c
    bool _clientDidConnect; // +0x2d
    bool _didReceiveSceneRequest; // +0x2e
    bool _didReceiveScene; // +0x2f
    bool _didReceiveActions; // +0x30
};

FBSceneManagerObserver *-[FBSceneManagerObserver _initWithObserver:workspace:](id<FBSceneManagerObserver> a1, id a2)
{
    FBSceneManagerObserver *v3 = [super init];
    if (v3 != nil) {
        Class v4 = [a1 class];
        v3->_observerAddress = a1;
        v3->_observerClass = v4;
        v3->_observer = a1;
        v3->_didAdd = [a1 respondsToSelector:@selector(workspace:didAddScene:)];
        v3->_willRemove = [a1 respondsToSelector:@selector(workspace:willRemoveScene:)];
        id _legacyWorkspace = [a2 _legacyWorkspace];
        if (_legacyWorkspace != nil) {
            v3->_didAddLEGACY = [a1 respondsToSelector:@selector(sceneManager:didAddScene:)];
            v3->_willRemoveLEGACY = [a1 respondsToSelector:@selector(sceneManager:willRemoveScene:)];
            v3->_didDestroyDEPRECATED = [a1 respondsToSelector:@selector(sceneManager:didDestroyScene:)];
            v3->_willUpdateSceneDEPRECATED = [a1 respondsToSelector:@selector(sceneManager:willUpdateScene:withSettings:transitionContext:)];
            v3->_willCommitDEPRECATED = [a1 respondsToSelector:@selector(sceneManager:willCommitUpdateForScene:transactionID:)];
            v3->_didCommitDEPRECATED = [a1 respondsToSelector:@selector(sceneManager:didCommitUpdateForScene:transactionID:)];
        }
    }
    return v3;
}


void -[FBSceneManagerObserver workspace:didAddScene:](id a1, id a2)
{
    id observer = [self observer];
    id _legacyWorkspace = [a1 _legacyWorkspace];
    if (_legacyWorkspace) {
        if (self->_didAddLEGACY == 1) {
            [observer sceneManager:_legacyWorkspace didAddScene:a2];
        }
    } else if (self->_didAdd == 1) {
        [observer workspace:a1 didAddScene:a2];
    }
}


void -[FBSceneManagerObserver workspace:clientDidConnectWithHandshake:](id a1, id a2)
{
    id delegate = [self delegate];
    if (delegate != nil) {
        if (self->_clientDidConnect != 1) {
            if (self->_clientDidConnectLEGACY != 1) {
                NSSet *remnants2 = [a2 remnants];
                for (id v17 in remnants2) {
                    [v17 invalidate];
                }
                return;
            } else {
                id _legacyWorkspace = [a1 _legacyWorkspace];
                [delegate sceneManager:_legacyWorkspace clientDidConnectWithHandshake:a2];
            }
        } else {
            [delegate workspace:a1 clientDidConnectWithHandshake:a2];
        }
        return;
    }
    NSSet *remnants = [a2 remnants];
    for (id v18 in remnants) {
        [v18 invalidate];
    }
}


FBSceneManagerObserver *-[FBSceneManagerObserver initWithObserver:workspace:](long a1, long a2)
{
    return [self _initWithObserver:a1 workspace:a2];
}


bool -[FBSceneManagerObserver isEqual:](id a1)
{
    if (self == a1) {
        return true;
    }
    if ([a1 isKindOfClass:[self class]] && a1->field_16 == self->_observerAddress && a1->field_24 == self->_observerClass) {
        id v2 = objc_loadWeakRetained(a1 + 8);
        id<FBSceneManagerObserver> v3 = self->_observer;
        return v2 == v3;
    }
    return false;
}


void -[FBSceneManagerObserver sceneManager:didCommitUpdateForScene:transactionID:](id a1, id a2, long a3)
{
    id observer = [self observer];
    if (self->_didCommitDEPRECATED == 1) {
        [observer sceneManager:a1 didCommitUpdateForScene:a2 transactionID:a3];
    }
}


void -[FBSceneManagerObserver sceneManager:willCommitUpdateForScene:transactionID:](id a1, id a2, long a3)
{
    id observer = [self observer];
    if (self->_willCommitDEPRECATED == 1) {
        [observer sceneManager:a1 willCommitUpdateForScene:a2 transactionID:a3];
    }
}


bool -[FBSceneManagerObserver delegateHandlesLegacyInterception](void)
{
    return self->_interceptSceneUpdatesLEGACY;
}


void -[FBSceneManagerObserver sceneManager:willUpdateScene:withSettings:transitionContext:](id a1, id a2, id a3, id a4)
{
    id observer = [self observer];
    if (self->_willUpdateSceneDEPRECATED == 1) {
        id updateContext = [a4 updateContext];
        long transactionID = [updateContext transactionID];
        if (transactionID >= 2) {
            [observer sceneManager:a1 willUpdateScene:a2 withSettings:a3 transitionContext:a4];
        }
    }
}


id<FBSceneManagerObserver> -[FBSceneManagerObserver observer](void)
{
    return self->_observer;
}


id<FBSceneManagerObserver> -[FBSceneManagerObserver delegate](void)
{
    if (self->_isDelegate == 1) {
        return self->_observer;
    }
    return nil;
}


void -[FBSceneManagerObserver workspace:didReceiveSceneRequestWithOptions:fromProcess:completion:](id a1, id a2, _FBSceneClientProcess *a3, void (^a4)(FBScene *, NSError *))
{
    NSError *v5;
    id delegate = [self delegate];
    if (!delegate) {
        v5 = FBSWorkspaceErrorCreate(delegate, 2, @"the host has not configured a workspace delegate");
blk_1c4efa2e8:
        a4(nil, v5);
    } else if (self->_didReceiveSceneRequest != 1) {
        if (self->_didReceiveSceneRequestLEGACY != 1) {
            v5 = FBSWorkspaceErrorCreate(0, 2, @"the host has not implemented the workspace delegate callout");
            goto blk_1c4efa2e8;
        }
        id _legacyWorkspace = [a1 _legacyWorkspace];
        [delegate sceneManager:_legacyWorkspace didReceiveSceneRequestWithOptions:a2 fromProcess:a3 completion:a4];
    } else {
        [delegate workspace:a1 didReceiveSceneRequestWithOptions:a2 fromProcess:a3 completion:a4];
    }
}


FBSceneManagerObserver *-[FBSceneManagerObserver initWithDelegate:workspace:](id a1, id a2)
{
    FBSceneManagerObserver *v2 = [self _initWithObserver:a1 workspace:a2];
    if (v2 != nil) {
        v2->_isDelegate = YES;
        v2->_clientDidConnect = [a1 respondsToSelector:@selector(workspace:clientDidConnectWithHandshake:)];
        v2->_didReceiveSceneRequest = [a1 respondsToSelector:@selector(workspace:didReceiveSceneRequestWithOptions:fromProcess:completion:)];
        v2->_didReceiveScene = [a1 respondsToSelector:@selector(workspace:didReceiveScene:withContext:fromProcess:)];
        v2->_didReceiveActions = [a1 respondsToSelector:@selector(workspace:didReceiveActions:)];
        id _legacyWorkspace = [a2 _legacyWorkspace];
        if (_legacyWorkspace != nil) {
            v2->_clientDidConnectLEGACY = [a1 respondsToSelector:@selector(sceneManager:clientDidConnectWithHandshake:)];
            v2->_didReceiveSceneRequestLEGACY = [a1 respondsToSelector:@selector(sceneManager:didReceiveSceneRequestWithOptions:fromProcess:completion:)];
            BOOL v4 = [a1 respondsToSelector:@selector(sceneManager:interceptUpdateForScene:withNewSettings:)];
            v2->_interceptSceneUpdatesLEGACY = v4;
            v2->_privateDelegate = v4;
        }
    }
    return v2;
}


void -[FBSceneManagerObserver workspace:willRemoveScene:](id a1, id a2)
{
    id observer = [self observer];
    if (self->_willRemoveLEGACY != 1) {
        if (self->_willRemove == 1) {
            [observer workspace:a1 willRemoveScene:a2];
        }
    } else {
        id _legacyWorkspace = [a1 _legacyWorkspace];
        [observer sceneManager:_legacyWorkspace willRemoveScene:a2];
    }
}


void -[FBSceneManagerObserver .cxx_destruct](void)
{
    self->_observer = nil;
}


unsigned long -[FBSceneManagerObserver hash](void)
{
    return self->_observerAddress;
}


bool -[FBSceneManagerObserver isDelegate](void)
{
    return self->_isDelegate;
}


bool -[FBSceneManagerObserver delegateReceivesActions](void)
{
    if (self->_isDelegate != 1) {
        return false;
    } else {
        return self->_didReceiveActions;
    }
}


bool -[FBSceneManagerObserver delegateHandlesClientScenes](void)
{
    if (self->_isDelegate != 1) {
        return false;
    } else {
        return self->_didReceiveScene;
    }
}


void -[FBSceneManagerObserver workspace:didReceiveScene:withContext:fromProcess:](id a1, id a2, id a3, id a4)
{
    id delegate = [self delegate];
    if (delegate != nil && self->_didReceiveScene == 1) {
        [delegate workspace:a1 didReceiveScene:a2 withContext:a3 fromProcess:a4];
    }
}


void -[FBSceneManagerObserver workspace:didReceiveActions:](id a1, id a2)
{
    id delegate = [self delegate];
    if (delegate != nil && self->_didReceiveActions == 1) {
        [delegate workspace:a1 didReceiveActions:a2];
    }
}


id -[FBSceneManagerObserver sceneManager:didDestroyScene:](id a1, id a2)
{
    if (self->_didDestroyDEPRECATED != 1) {
        return self;
    }
    id observer = [self observer];
    [observer sceneManager:a1 didDestroyScene:a2];
    return observer;
}


void -[FBSceneManagerObserver sceneManager:interceptUpdateForScene:withNewSettings:](id a1, id a2, id a3)
{
    if (self->_interceptSceneUpdatesLEGACY == 1) {
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            id identifier = [a2 identifier];
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Client intercepting scene update for scene: %{public}@", identifier);
        }
        id _privateDelegate = [self _privateDelegate];
        [_privateDelegate sceneManager:a1 interceptUpdateForScene:a2 withNewSettings:a3];
    }
}


long -[FBSceneManagerObserver description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneManagerObserver succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneManagerObserver succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    id<FBSceneManagerObserver> v1 = self->_observer;
    [v0 appendPointer:v1 withName:@"observer"];
    if (self->_isDelegate == 1) {
        [v0 appendBool:1 withName:@"isDelegate"];
    }
    return v0;
}


id -[FBSceneManagerObserver descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


long -[FBSceneManagerObserver descriptionBuilderWithMultilinePrefix:](long a1)
{
    return [self succinctDescriptionBuilder];
}


id -[FBSceneManagerObserver _privateDelegate](void)
{
    if (self->_privateDelegate == 1) {
        return [self delegate];
    }
    return nil;
}


void -[FBSceneManagerObserver sceneManager:didCreateScene:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"no longer used"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneManagerObserver.m", 232, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneManagerObserver sceneManager:didAddScene:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"no longer used"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneManagerObserver.m", 266, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneManagerObserver sceneManager:willRemoveScene:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"no longer used"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneManagerObserver.m", 270, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSceneManagerObserver sceneManager:clientDidConnectWithHandshake:](long a1, long a2)
{
    NSString *v1 = [NSString stringWithFormat:@"no longer used"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneManagerObserver.m", 274, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
