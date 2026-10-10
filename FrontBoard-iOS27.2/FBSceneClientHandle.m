struct FBSceneClientHandle {
    FBSSceneClientIdentity *_identity; // +0x8
    FBProcess *_legacyProcess; // +0x10
};

FBSceneClientHandle *+[FBSceneClientHandle handleForScene:clientProcess:](id a1, id a2)
{
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBSceneClientHandle.m", 20, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    RBSProcessHandle *rbsHandle = [a2 rbsHandle];
    long _isLegacy = [a1 _isLegacy];
    if (!_isLegacy || rbsHandle != nil) {
        Class v4 = NSClassFromString(@"RBSProcessHandle");
        if (!rbsHandle) {
            NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v13 = NSStringFromSelector(_cmd);
                NSString *v14 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBSceneClientHandle.m", 21, v12);
            }
            _bs_set_crash_log_message([v12 UTF8String]);
            __break(0);
        }
        if (![rbsHandle isKindOfClass:v4]) {
            NSString *v16 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:RBSProcessHandleClass]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v17 = NSStringFromSelector(_cmd);
                NSString *v18 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBSceneClientHandle.m", 21, v16);
            }
            _bs_set_crash_log_message([v16 UTF8String]);
            __break(0);
        }
    }
    FBSceneClientHandle *v5 = [[FBSceneClientHandle alloc] init];
    if (v5 != nil) {
        id definition = [a1 definition];
        v5->field_8 = [definition clientIdentity];
        objc_storeStrong(v5 + 16, a2);
    }
    return v5;
}


NSString *-[FBSceneClientHandle bundleIdentifier](void)
{
    return [self->_legacyProcess bundleIdentifier];
}


FBProcess *-[FBSceneClientHandle legacyProcess](void)
{
    return self->_legacyProcess;
}


RBSProcessHandle *-[FBSceneClientHandle processHandle](void)
{
    return [self->_legacyProcess rbsHandle];
}


void -[FBSceneClientHandle .cxx_destruct](void)
{
    self->_legacyProcess = nil;
    self->_identity = nil;
}


NSString *-[FBSceneClientHandle description](void)
{
    RBSProcessHandle *processHandle = [self processHandle];
    return [processHandle description];
}


FBSSceneClientIdentity *-[FBSceneClientHandle identity](void)
{
    return self->_identity;
}
