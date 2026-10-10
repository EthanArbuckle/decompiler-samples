struct FBWorkspaceSceneRequest {
    id _lock_completion; // +0x8
    struct os_unfair_lock_s _lock; // +0x10
    bool _lock_responded; // +0x14
    FBSSceneClientIdentity *_clientIdentity; // +0x18
    NSString *_targetIdentifier; // +0x20
    FBSWorkspaceSceneRequestOptions *_options; // +0x28
    NSSet *_actions; // +0x30
};

NSString *-[FBWorkspaceSceneRequest targetIdentifier](void)
{
    return self->_targetIdentifier;
}


FBWorkspaceSceneRequest *-[FBWorkspaceSceneRequest initWithClientIdentity:targetIdentifier:options:completion:](id a1, id a2, FBSWorkspaceSceneRequestOptions *a3, id a4)
{
    if (!a1) {
        NSString *v9 = NSStringFromClass([FBSSceneClientIdentity class]);
        NSString *v10 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"clientIdentity", v9];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBWorkspaceSceneRequest.m", 45, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[FBSSceneClientIdentity class]]) {
        Class v14 = [a1 classForCoder];
        if (!v14) {
            v14 = [a1 class];
        }
        NSString *v15 = NSStringFromClass(v14);
        NSString *v16 = NSStringFromClass([FBSSceneClientIdentity class]);
        NSString *v17 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"clientIdentity", v15, v16];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceSceneRequest.m", 45, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    if (a2 != nil && ![a2 isKindOfClass:[NSString class]]) {
        Class v21 = [a2 classForCoder];
        if (!v21) {
            v21 = [a2 class];
        }
        NSString *v22 = NSStringFromClass(v21);
        NSString *v23 = NSStringFromClass([NSString class]);
        NSString *v24 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"targetIdentifier", v22, v23];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v25 = NSStringFromSelector(_cmd);
            NSString *v26 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBWorkspaceSceneRequest.m", 46, v24);
        }
        _bs_set_crash_log_message([v24 UTF8String]);
        __break(0);
    }
    if (a3 != nil && ![a3 isKindOfClass:[FBSWorkspaceSceneRequestOptions class]]) {
        Class v28 = [a3 classForCoder];
        if (!v28) {
            v28 = [a3 class];
        }
        NSString *v29 = NSStringFromClass(v28);
        NSString *v30 = NSStringFromClass([FBSWorkspaceSceneRequestOptions class]);
        NSString *v31 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"options", v29, v30];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v32 = NSStringFromSelector(_cmd);
            NSString *v33 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v32, v33, self, @"FBWorkspaceSceneRequest.m", 47, v31);
        }
        _bs_set_crash_log_message([v31 UTF8String]);
        __break(0);
    }
    if (!a4) {
        NSString *v35 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"completion"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v36 = NSStringFromSelector(_cmd);
            NSString *v37 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v36, v37, self, @"FBWorkspaceSceneRequest.m", 48, v35);
        }
        _bs_set_crash_log_message([v35 UTF8String]);
        __break(0);
    }
    FBWorkspaceSceneRequest *v4 = [self initWithTargetIdentifier:a2];
    if (v4 != nil) {
        v4->_clientIdentity = [a1 copy];
        v4->_options = a3;
        v4->_lock_completion = [a4 copy];
    }
    return v4;
}


void -[FBWorkspaceSceneRequest respondWithScene:](id a1)
{
    if (a1 != nil || !self->_actions) {
        Class v1 = NSClassFromString(@"FBScene");
        if (!a1) {
            NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(_cmd);
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceSceneRequest.m", 104, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        if (![a1 isKindOfClass:v1]) {
            NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v7 = NSStringFromSelector(_cmd);
                NSString *v8 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBWorkspaceSceneRequest.m", 104, v6);
            }
            _bs_set_crash_log_message([v6 UTF8String]);
            __break(0);
        }
    }
    [self _respondWithScene:a1 error:0];
}


void -[FBWorkspaceSceneRequest _respondWithScene:error:](id a1, id a2)
{
    os_unfair_lock_lock(&self->_lock);
    bool v3 = self->_lock_responded;
    id v4 = _Block_copy(self->_lock_completion);
    self->_lock_completion = nil;
    self->_lock_responded = YES;
    os_unfair_lock_unlock(&self->_lock);
    if (v3 == 1) {
        NSString *v6 = [NSString stringWithFormat:@"attempt to respond to previously invalidated request with scene=%@ error=%@", a1, a2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v8, self, @"FBWorkspaceSceneRequest.m", 121, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    if (a2 != nil) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id v10 = [a2 descriptionWithMultilinePrefix:0];
            NSString *v7 = self->_targetIdentifier;
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Request for workspace \"%{public}@\" failed: %{public}@", v7, v10);
        }
    }
    if (v4 != nil) {
        v4->field_16(v4, a1, a2);
    }
}


void -[FBWorkspaceSceneRequest dealloc](void)
{
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_completion != nil) {
        NSString *v1 = [NSString stringWithFormat:@"FBWorkspaceSceneRequest deallocated without firing its completion"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceSceneRequest.m", 69, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    os_unfair_lock_unlock(&self->_lock);
    [super dealloc];
}


void -[FBWorkspaceSceneRequest .cxx_destruct](void)
{
    self->_actions = nil;
    self->_options = nil;
    self->_targetIdentifier = nil;
    self->_clientIdentity = nil;
    self->_lock_completion = nil;
}


NSSet *-[FBWorkspaceSceneRequest actions](void)
{
    return self->_actions;
}


FBWorkspaceSceneRequest *-[FBWorkspaceSceneRequest init](void)
{
    return [self initWithTargetIdentifier:0];
}


FBWorkspaceSceneRequest *-[FBWorkspaceSceneRequest initWithTargetIdentifier:](id a1)
{
    if (a1 != nil && ![a1 isKindOfClass:NSClassFromString(@"NSString")]) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v6 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v6, self, @"FBWorkspaceSceneRequest.m", 33, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    FBWorkspaceSceneRequest *v2 = [super init];
    if (v2 != nil) {
        v2->_targetIdentifier = [a1 copy];
        v2->_lock._os_unfair_lock_opaque = 0;
    }
    return v2;
}


FBWorkspaceSceneRequest *-[FBWorkspaceSceneRequest initWithTargetIdentifier:actions:completion:](long a1, id a2, id a3)
{
    FBWorkspaceSceneRequest *v2 = [self initWithTargetIdentifier:a1];
    if (v2 != nil) {
        v2->_actions = [a2 copy];
        v2->_lock_completion = [a3 copy];
    }
    return v2;
}


bool -[FBWorkspaceSceneRequest requiresModernDispatcher](void)
{
    if (([self->_options isClientFuture] & 1) == 0) {
        return self->_actions != nil;
    } else {
        return true;
    }
}


int -[FBWorkspaceSceneRequest requiresTargetPreregistration](void)
{
    return [self requiresModernDispatcher] ^ 1;
}


void -[FBWorkspaceSceneRequest observeScene:](id a1)
{
    if (![a1 isValid] || [a1 isActive]) {
        if (![a1 isActive]) {
            NSError *v2 = FBSceneErrorCreate(2, @"scene already invalidated", 0);
            [self invalidateWithError:v2];
        } else {
            [self respondWithScene:a1];
        }
    } else {
        [a1 addObserver:self];
        objc_setAssociatedObject(a1, [FBWorkspaceSceneRequest class], self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}


void -[FBWorkspaceSceneRequest invalidateWithError:](id a1)
{
    Class v1 = NSClassFromString(@"NSError");
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceSceneRequest.m", 109, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSErrorClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBWorkspaceSceneRequest.m", 109, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    [self _respondWithScene:0 error:a1];
}


void -[FBWorkspaceSceneRequest sceneDidActivate:](id a1)
{
    [self respondWithScene:a1];
    [a1 removeObserver:self];
    objc_setAssociatedObject(a1, [FBWorkspaceSceneRequest class], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


void -[FBWorkspaceSceneRequest sceneDidInvalidate:](id a1)
{
    NSError *v1 = FBSceneErrorCreate(2, @"scene explicitly invalidated", 0);
    [self invalidateWithError:v1];
    [a1 removeObserver:self];
    objc_setAssociatedObject(a1, [FBWorkspaceSceneRequest class], nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


FBSSceneClientIdentity *-[FBWorkspaceSceneRequest clientIdentity](void)
{
    return self->_clientIdentity;
}


FBSWorkspaceSceneRequestOptions *-[FBWorkspaceSceneRequest options](void)
{
    return self->_options;
}
