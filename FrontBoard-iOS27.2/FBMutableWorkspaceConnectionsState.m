FBWorkspaceConnectionsState *-[FBMutableWorkspaceConnectionsState copyWithZone:](long a1)
{
    return [[FBWorkspaceConnectionsState alloc] _initWithIndexSet:self->_pidSet];
}


bool -[FBMutableWorkspaceConnectionsState addProcessIdentifier:](id a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"processIdentifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBWorkspaceConnectionsState.m", 203, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    NSUInteger rbs_pid = [a1 rbs_pid];
    if ((long)rbs_pid <= 0) {
        NSString *v7 = [NSString stringWithFormat:@"invalid pid"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBWorkspaceConnectionsState.m", 206, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    BOOL v2 = [self->_pidSet containsIndex:rbs_pid];
    if (!v2) {
        [self->_pidSet addIndex:rbs_pid];
    }
    return !v2;
}
