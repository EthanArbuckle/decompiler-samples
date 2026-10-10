id -[FBWorkspaceIncomingConnection initWithWorkspace:](long a1)
{
    if (!self) {
        return self;
    } else {
        return [self _initWithWorkspace:a1];
    }
}


void -[FBWorkspaceIncomingConnection workspaceLock_consumeConnection:](id a1)
{
    os_log_t v5;
    id v0 = a1;
    if (self != nil) {
        if (!v0) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"incomingConnection"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v22 = NSStringFromSelector(@selector(workspaceLock_consumeConnection:));
                NSString *v23 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBWorkspaceConnection.m", 192, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        [self->_workspace _assertLocked];
        FBProcess *process = [self->_workspace process];
        id _workspaceLock_connection2 = [self _workspaceLock_connection];
        long continuationRoute1 = 0;
        if (_workspaceLock_connection2 != nil) {
            BOOL isValid = [_workspaceLock_connection2 isValid];
            v5 = FBLogProcessWorkspace();
            bool v19 = os_log_type_enabled(v5, OS_LOG_TYPE_ERROR);
            if (!isValid) {
                if (v19) {
                    NSString *logProem2 = [process logProem];
                    os_log_with_type(v5, OS_LOG_TYPE_ERROR, "%{public}@ Enqueueing a cancel for a new connection (%p) to a workspace server that is in the process of exiting.", logProem2, v0);
                }
                id queue2 = [self queue];
                void (^v21)(void) = ^void(void) {
                    [v0 cancel];
                };
                [queue2 performAfter:0.1 withBlock:v21];
                continuationRoute1 = 1;
            }
            if (!continuationRoute1) {
                if (v19) {
                    NSString *logProem3 = [process logProem];
                    os_log_with_type(v5, OS_LOG_TYPE_ERROR, "%{public}@ Unexpectedly attempted to assign a new connection (%p) to a workspace server with an existing connection.", logProem3, v0);
                }
                continuationRoute1 = 2;
            }
        }
        if (!continuationRoute1) {
            long isMultiplexed = [v0 isMultiplexed];
            v5 = FBLogProcessWorkspace();
            if ((isMultiplexed & 1) != 0) {
                if (os_log_type_enabled(v5, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem5 = [process logProem];
                    os_log_with_type(v5, OS_LOG_TYPE_DEFAULT, "%{public}@ Connection established.", logProem5);
                }
                void (^v8)(id<BSServiceListenerConnectionConfiguring>) = ^void(id<BSServiceListenerConnectionConfiguring> arg1) {
                    id interface = [FBSWorkspaceServiceSpecification interface];
                    [arg1 setInterface:interface];
                    [arg1 setInvalidationHandler:^void(BSServiceListenerConnection<BSServiceConnectionContext> *arg1) {
                        os_log_t v31 = FBLogProcessWorkspace();
                        if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
                            NSString *v30 = [process logProem];
                            os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "%{public}@ Workspace connection invalidated.", v30);
                        }
                        [process _notePendingExitForReason:@"workspace client connection invalidated"];
                    }];
                };
                [v0 configure:v8];
                [self _workspaceLock_consumeConnection:v0];
                id _workspaceLock_connection = [self _workspaceLock_connection];
                id remoteTarget = [_workspaceLock_connection remoteTarget];
                os_log_t oslog = FBLogProcessWorkspace();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    NSString *logProem = [process logProem];
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ created proxy of %{public}@", logProem, remoteTarget);
                }
                id queue = [self queue];
                [queue performAsync:^void(void) {
                    [self _flushConnectBlocksWithProxy:remoteTarget];
                }];
                continuationRoute1 = 1;
            } else {
                if (os_log_type_enabled(v5, OS_LOG_TYPE_ERROR)) {
                    NSString *logProem4 = [process logProem];
                    os_log_with_type(v5, OS_LOG_TYPE_ERROR, "%{public}@ Received new connection (%p) to a workspace server that doesn't use multiplexing.", logProem4, v0);
                }
                continuationRoute1 = 2;
            }
        }
        if (continuationRoute1 != 1) {
            [v0 invalidate];
        }
    }
}
