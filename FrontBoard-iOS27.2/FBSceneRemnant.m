struct FBSceneRemnant {
    __weak FBWorkspace *_workspace; // +0x8
    FBSSceneDefinition *_definition; // +0x10
    FBSSceneParameters *_parameters; // +0x18
    NSObject<OS_dispatch_queue> *_assertionQueue; // +0x20
    BSSimpleAssertion *_assertion; // +0x28
    BSAtomicSignal *_invalidated; // +0x30
};

void -[FBSceneRemnant dealloc](void)
{
    if (([self->_invalidated hasBeenSignalled] & 1) == 0) {
        NSString *v1 = [NSString stringWithFormat:@"FBSceneRemnant must be invalidated before dealloc"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneRemnant.m", 28, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


FBSSceneSettings *-[FBSceneRemnant lastSettings](void)
{
    return [self->_parameters settings];
}


void -[FBSceneRemnant invalidate](void)
{
    if (![self->_invalidated signal]) {
        return;
    }
    if (!self->_assertionQueue) {
        [self->_assertion invalidate];
        return;
    }
    dispatch_async_and_wait(self->_assertionQueue, ^void(void) {
        [self->_assertion invalidate];
    });
}


FBSceneRemnant *-[FBSceneRemnant _initWithIdentity:client:workspace:parameters:assertionQueue:assertion:](RBSProcessIdentity *a1, id a2, FBWorkspace *a3, id a4, NSObject<OS_dispatch_queue> *a5, BSSimpleAssertion *a6)
{
    Class v2 = NSClassFromString(@"FBSSceneIdentity");
    if (!a1) {
        NSString *v18 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBSceneRemnant.m", 66, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v2]) {
        NSString *v22 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v23 = NSStringFromSelector(_cmd);
            NSString *v24 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBSceneRemnant.m", 66, v22);
        }
        _bs_set_crash_log_message([v22 UTF8String]);
        __break(0);
    }
    Class v4 = NSClassFromString(@"FBSSceneClientIdentity");
    if (!a2) {
        NSString *v26 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v27 = NSStringFromSelector(_cmd);
            NSString *v28 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v27, v28, self, @"FBSceneRemnant.m", 67, v26);
        }
        _bs_set_crash_log_message([v26 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v4]) {
        NSString *v30 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneClientIdentityClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v31 = NSStringFromSelector(_cmd);
            NSString *v32 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v31, v32, self, @"FBSceneRemnant.m", 67, v30);
        }
        _bs_set_crash_log_message([v30 UTF8String]);
        __break(0);
    }
    if (!a3) {
        NSString *v34 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"workspace"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v35 = NSStringFromSelector(_cmd);
            NSString *v36 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v35, v36, self, @"FBSceneRemnant.m", 68, v34);
        }
        _bs_set_crash_log_message([v34 UTF8String]);
        __break(0);
    }
    Class v6 = NSClassFromString(@"FBSSceneParameters");
    if (!a4) {
        NSString *v38 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v39 = NSStringFromSelector(_cmd);
            NSString *v40 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v39, v40, self, @"FBSceneRemnant.m", 69, v38);
        }
        _bs_set_crash_log_message([v38 UTF8String]);
        __break(0);
    }
    if (![a4 isKindOfClass:v6]) {
        NSString *v42 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneParametersClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v43 = NSStringFromSelector(_cmd);
            NSString *v44 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v43, v44, self, @"FBSceneRemnant.m", 69, v42);
        }
        _bs_set_crash_log_message([v42 UTF8String]);
        __break(0);
    }
    if (a6 != nil && ![a6 isKindOfClass:NSClassFromString(@"BSSimpleAssertion")]) {
        NSString *v46 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:BSSimpleAssertionClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v47 = NSStringFromSelector(_cmd);
            NSString *v48 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v47, v48, self, @"FBSceneRemnant.m", 70, v46);
        }
        _bs_set_crash_log_message([v46 UTF8String]);
        __break(0);
    }
    FBSceneRemnant *v9 = [super init];
    if (v9 != nil) {
        FBSMutableSceneDefinition *v10 = [[FBSMutableSceneDefinition alloc] init];
        [v10 setIdentity:a1];
        FBSSceneSpecification *specification = [a4 specification];
        [v10 setSpecification:specification];
        [v10 setClientIdentity:a2];
        v9->_definition = [v10 copy];
        v9->_workspace = a3;
        v9->_parameters = [a4 copy];
        v9->_assertionQueue = a5;
        v9->_assertion = a6;
        v9->_invalidated = [BSAtomicSignal new];
    }
    return v9;
}


long -[FBSceneRemnant _hasBeenInvalidated](void)
{
    return [self->_invalidated hasBeenSignalled];
}


FBSSceneClientSettings *-[FBSceneRemnant _clientSettings](void)
{
    return [self->_parameters clientSettings];
}


NSString *-[FBSceneRemnant description](void)
{
    Class v0 = [self class];
    id identity = [self->_definition identity];
    id clientIdentity = [self->_definition clientIdentity];
    id v3 = NSStringFromBOOL([self->_assertion isValid]);
    return [NSString stringWithFormat:@"<%@:%p %@ -> %@ valid=%@>", v0, self, identity, clientIdentity, v3];
}


FBSSceneDefinition *-[FBSceneRemnant definition](void)
{
    return self->_definition;
}


FBWorkspace *-[FBSceneRemnant _workspace](void)
{
    return self->_workspace;
}


BSSimpleAssertion *-[FBSceneRemnant _assertion](void)
{
    return self->_assertion;
}


void -[FBSceneRemnant .cxx_destruct](void)
{
    self->_invalidated = nil;
    self->_assertion = nil;
    self->_assertionQueue = nil;
    self->_parameters = nil;
    self->_definition = nil;
    self->_workspace = nil;
}


void -[FBSceneRemnant init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed on FBSceneRemnant"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneRemnant.m", 34, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
