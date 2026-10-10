struct FBSceneClientHandshake {
    _FBSceneClientProcess *_process; // +0x8
    NSSet *_remnants; // +0x10
};

void -[FBSceneClientHandshake .cxx_destruct](void)
{
    self->_remnants = nil;
    self->_process = nil;
}


FBSceneClientHandshake *-[FBSceneClientHandshake _initWithHandle:remnants:](id a1, id a2)
{
    Class v1 = NSClassFromString(@"RBSProcessHandle");
    if (!a1) {
        NSString *v18 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBSceneClientHandshake.m", 40, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v21 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:RBSProcessHandleClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v22 = NSStringFromSelector(_cmd);
            NSString *v23 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBSceneClientHandshake.m", 40, v21);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
    Class v3 = NSClassFromString(@"NSSet");
    if (!a2) {
        NSString *v25 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v26 = NSStringFromSelector(_cmd);
            NSString *v27 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v26, v27, self, @"FBSceneClientHandshake.m", 41, v25);
        }
        _bs_set_crash_log_message([v25 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v3]) {
        NSString *v29 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSSetClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v30 = NSStringFromSelector(_cmd);
            NSString *v31 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v30, v31, self, @"FBSceneClientHandshake.m", 41, v29);
        }
        _bs_set_crash_log_message([v29 UTF8String]);
        __break(0);
    }
    for (id v10 in a2) {
        Class v11 = NSClassFromString(@"FBSceneRemnant");
        if (!v10) {
            NSString *v33 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v34 = NSStringFromSelector(_cmd);
                NSString *v35 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v34, v35, self, @"FBSceneClientHandshake.m", 43, v33);
            }
            _bs_set_crash_log_message([v33 UTF8String]);
            __break(0);
        }
        if (![v10 isKindOfClass:v11]) {
            NSString *v37 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneRemnantClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v38 = NSStringFromSelector(_cmd);
                NSString *v39 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v38, v39, self, @"FBSceneClientHandshake.m", 43, v37);
            }
            _bs_set_crash_log_message([v37 UTF8String]);
            __break(0);
        }
    }
    FBSceneClientHandshake *v13 = [super init];
    if (v13 != nil) {
        v13->_process = [[_FBSceneClientProcess alloc] _initWithHandle:a1];
        v13->_remnants = [a2 copy];
    }
    return v13;
}


NSSet *-[FBSceneClientHandshake remnants](void)
{
    return self->_remnants;
}


NSString *-[FBSceneClientHandshake description](void)
{
    Class v0 = [self class];
    RBSProcessHandle *handle = [self->_process handle];
    NSUInteger count = [self->_remnants count];
    return [NSString stringWithFormat:@"<%@:%p; %@ remnants=%i>", v0, self, handle, count];
}


RBSProcessHandle *-[FBSceneClientHandshake handle](void)
{
    return [self->_process handle];
}


_FBSceneClientProcess *-[FBSceneClientHandshake process](void)
{
    return self->_process;
}


void -[FBSceneClientHandshake init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed on FBSceneClientHandshake"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneClientHandshake.m", 25, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
