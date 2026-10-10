struct FBWorkspaceOutgoingConnection {
    bool _queue_verified; // +0x21
    BSServiceConnectionEndpoint *_queue_endpoint; // +0x28
};

static long FBWorkspaceConnectionTargetsClientEndpoint;

void -[FBWorkspaceOutgoingConnection .cxx_destruct](void)
{
    self->_queue_endpoint = nil;
}


void -[FBWorkspaceOutgoingConnection workspaceLock_setEndpoint:](id a1)
{
    if (self != nil) {
        if (!a1) {
            NSString *v19 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"endpoint"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(workspaceLock_setEndpoint:));
                NSString *v20 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v20, self, @"FBWorkspaceConnection.m", 252, v19);
            }
            _bs_set_crash_log_message([v19 UTF8String]);
            __break(0);
        }
        id service = [a1 service];
        NSString *identifier = [FBSWorkspaceServiceSpecification identifier];
        if (![service isEqualToString:identifier]) {
            NSString *v22 = [NSString stringWithFormat:@"outgoing endpoint is for the wrong service : %@", a1];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v23 = NSStringFromSelector(@selector(workspaceLock_setEndpoint:));
                NSString *v24 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v23, v24, self, @"FBWorkspaceConnection.m", 253, v22);
            }
            _bs_set_crash_log_message([v22 UTF8String]);
            __break(0);
        }
        [self->_workspace _assertLocked];
        FBProcess *process = [self->_workspace process];
        id _workspaceLock_connection = [self _workspaceLock_connection];
        os_log_t log = FBLogProcessWorkspace();
        bool v10 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
        if (_workspaceLock_connection != nil) {
            if (v10) {
                NSString *logProem = [process logProem];
                BSServiceConnectionEndpoint *v6 = self->_queue_endpoint;
                os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "%{public}@ ignoring outgoing endpoint due to already established connection : endpoint=%{public}@ existing=%{public}@", logProem, a1, v6);
            }
            if (([a1 isEqualToServiceEndpoint:self->_queue_endpoint] & 1) == 0) {
                NSString *logProem2 = [process logProem];
                NSString *v14 = [NSString stringWithFormat:@"%@ already have an outgoing connection but the endpoint doesn't match existing : new=%@ existing=%@", logProem2, a1, self->_queue_endpoint];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v0 = NSStringFromSelector(@selector(workspaceLock_setEndpoint:));
                    NSString *v26 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v26, self, @"FBWorkspaceConnection.m", 261, v14);
                }
                _bs_set_crash_log_message([v14 UTF8String]);
                __break(0);
            }
        } else {
            if (v10) {
                NSString *logProem3 = [process logProem];
                os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "%{public}@ Creating outgoing connection to %{public}@.", logProem3, a1);
            }
            BSServiceInitiatingConnection *v16 = [[BSServiceInitiatingConnection alloc] initWithEndpoint:a1 options:^void(id<BSServiceConnectionInitiatingOptions> arg1) {
                id userInteractiveMultiplexer = [BSServiceInitiatingConnectionMultiplexer userInteractiveMultiplexer];
                [arg1 setMultiplexer:userInteractiveMultiplexer];
                [arg1 encodeContext:^void(id<BSXPCEncoding> arg1) {
                    [arg1 encodeBool:YES forKey:FBWorkspaceConnectionTargetsClientEndpoint];
                }];
            }];
            [v16 configure:^void(id<BSServiceInitiatingConnectionConfiguring> arg1) {
                id invertedInterface = [FBSWorkspaceServiceSpecification invertedInterface];
                [arg1 setInterface:invertedInterface];
                [arg1 setActivationHandler:^void(BSServiceInitiatingConnection<BSServiceConnectionContext> *arg1) {
                    id remoteToken = [arg1 remoteToken];
                    long versionedPID = [remoteToken versionedPID];
                    if (versionedPID == -1 || versionedPID != [process versionedPID]) {
                        os_log_t oslog = FBLogProcessWorkspace();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                            NSString *v37 = [process logProem];
                            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%{public}@ Outgoing workspace connection does not match expected process. remoteToken=%{public}@ process=%{public}@", v37, remoteToken, process);
                        }
                        FBWorkspace *_workspace = [self _workspace];
                        NSError *v36 = FBSceneErrorCreate(3, @"FBWorkspaceOutgoingConnection failed process verification.", 0);
                        [_workspace _queue_unverifiedOutgoingConnection:self didError:v36];
                    } else {
                        self->_queue_verified = YES;
                        id remoteTarget = [arg1 remoteTarget];
                        [self _flushConnectBlocksWithProxy:remoteTarget];
                    }
                }];
                [arg1 setInvalidationHandler:^void(BSServiceInitiatingConnection<BSServiceConnectionContext> *arg1) {
                    os_log_t v46 = FBLogProcessWorkspace();
                    bool v41 = os_log_type_enabled(v46, OS_LOG_TYPE_DEFAULT);
                    if (self->_queue_verified != 1) {
                        if (v41) {
                            NSString *v47 = [process logProem];
                            os_log_with_type(v46, OS_LOG_TYPE_DEFAULT, "%{public}@ Unverified outgoing workspace connection invalidated.", v47);
                        }
                        FBWorkspace *_workspace = [self _workspace];
                        NSError *v45 = FBSceneErrorCreate(4, @"FBWorkspaceOutgoingConnection invalidated before process verification.", 0);
                        [_workspace _queue_unverifiedOutgoingConnection:self didError:v45];
                    } else {
                        if (v41) {
                            NSString *v48 = [process logProem];
                            os_log_with_type(v46, OS_LOG_TYPE_DEFAULT, "%{public}@ Verified outgoing workspace connection invalidated.", v48);
                        }
                        [process _notePendingExitForReason:@"verified outgoing workspace client connection invalidated"];
                    }
                }];
            }];
            [self _workspaceLock_consumeConnection:v16];
        }
    }
}


bool -[FBWorkspaceOutgoingConnection queue_isVerified](void)
{
    if (!self) {
        return false;
    }
    id queue = [self queue];
    [queue assertBarrierOnQueue];
    return self->_queue_verified;
}


FBWorkspaceOutgoingConnection *-[FBWorkspaceOutgoingConnection initWithWorkspace:](long a1)
{
    if (!self) {
        return self;
    }
    self = [self _initWithWorkspace:a1];
    if (self != nil) {
        self->_queue_verified = NO;
    }
    return self;
}
