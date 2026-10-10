struct FBWorkspaceConnectionsStateStore {
    NSString *_path1; // +0x8
    NSString *_path2; // +0x10
    NSObject<OS_dispatch_queue> *_queue; // +0x18
    FBWorkspaceConnectionsState *_queue_state; // +0x20
    long _queue_lastBuffer; // +0x28
    long _queue_nextWriteFailure; // +0x30
    bool _queue_writeFailedOnce; // +0x38
    bool _queue_invalidated; // +0x39
};

void -[FBWorkspaceConnectionsStateStore setState:](id a1)
{
    if (self != nil) {
        if (!a1) {
            NSString *v1 = NSStringFromClass([FBWorkspaceConnectionsState class]);
            NSString *v6 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"state", v1];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v7 = NSStringFromSelector(@selector(setState:));
                NSString *v4 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v4, self, @"FBWorkspaceConnectionsStateStore.m", 183, v6);
            }
            _bs_set_crash_log_message([v6 UTF8String]);
            __break(0);
        }
        if (![a1 isKindOfClass:[FBWorkspaceConnectionsState class]]) {
            NSArray *v9 = OUTLINED_FUNCTION_28(a1);
            __builtin_return_address(0);
            Class v10 = [v9 classForCoder];
            if (!v10) {
                v10 = [v9 class];
            }
            NSString *v11 = NSStringFromClass(v10);
            NSString *v12 = NSStringFromClass([FBWorkspaceConnectionsState class]);
            NSString *v13 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"state", v11, v12];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v14 = NSStringFromSelector(@selector(setState:));
                NSString *v15 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceConnectionsStateStore.m", 183, v13);
            }
            _bs_set_crash_log_message([v13 UTF8String]);
            __break(0);
        }
        FBWorkspaceConnectionsState *v16 = [a1 copy];
        dispatch_async(self->_queue, ^void(void) {
            os_log_type_t v34;
            if (self->_queue_invalidated == 1) {
                NSString *v26 = [NSString stringWithFormat:@"attemp to set state after invalidation"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v27 = NSStringFromSelector(@selector(setState:));
                    NSString *v37 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v27, v37, self, @"FBWorkspaceConnectionsStateStore.m", 186, v26);
                }
                _bs_set_crash_log_message([v26 UTF8String]);
                __break(0);
            }
            if ((BSEqualObjects(self->_queue_state, v16) & 1) != 0) {
                return;
            }
            self->_queue_state = v16;
            long v40 = (self->_queue_lastBuffer > 0) ? self->_queue_lastBuffer & 3 : -(-self->_queue_lastBuffer & 3);
            Class v41 = [self class];
            if (![v41 _storeState:v16 toPath:*((((v40 - 1) & 0xfffffffffffffffd) == 0) ? &self->_path2 : &self->_path1) withGeneration:(v40 & 0xfffffffffffffffe) == 2 injectedFailure:&self->_queue_nextWriteFailure]) {
                if (!self->_queue_lastBuffer) {
                    if (self->_path1 != nil || self->_path2 != nil) {
                        if (self->_queue_writeFailedOnce == 0) {
                            self->_queue_writeFailedOnce = YES;
                            v34 = OS_LOG_TYPE_ERROR;
                        } else {
                            v34 = OS_LOG_TYPE_DEBUG;
                        }
                        os_log_t oslog4 = FBLogCommon();
                        if (os_log_type_enabled(oslog4, v34)) {
                            os_log_with_type(oslog4, v34, "failed to write new workspace connections state to shm - are we sandboxed?");
                        }
                    }
                } else {
                    os_log_t oslog = FBLogCommon();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_FAULT)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_FAULT, "workspace connections state desynced with shm");
                    }
                }
            } else {
                os_log_t oslog2 = FBLogCommon();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "stored new workspace connections = %@", v16);
                }
                self->_queue_lastBuffer = v40 + 1;
                if (self->_queue_nextWriteFailure != 1) {
                    if (self->_queue_lastBuffer != 0) {
                        Class v19 = [self class];
                        [v19 _unlinkShmPath:*((((self->_queue_lastBuffer - 2) & 0xfffffffffffffffd) == 0) ? &self->_path2 : &self->_path1) graceful:0];
                    }
                } else {
                    self->_queue_nextWriteFailure = 0;
                    os_log_t oslog3 = FBLogCommon();
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                        long v39 = self->_queue_lastBuffer;
                        id v1 = *((((v39 - 2) & 0xfffffffffffffffd) == 0) ? &self->_path2 : &self->_path1);
                        os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "simulating failure to purge old buffer : %@", v1);
                    }
                }
            }
        });
    }
}


int +[FBWorkspaceConnectionsStateStore _storeState:toPath:withGeneration:injectedFailure:](id a1, id a2, long a3, long *a4)
{
    void *v10;
    int v14;
    int *v24;
    int *v31;
    int *v32;
    os_log_t v33;
    int *v38;
    os_log_t v39;
    int *v40;
    unsigned long serializedDataLength;
    char v12[256];
    uint8_t v16[32];
    if (!a1) {
        NSString *v41 = NSStringFromClass([FBWorkspaceConnectionsState class]);
        NSString *v42 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"state", v41];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v43 = NSStringFromSelector(_cmd);
            NSString *v44 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v43, v44, self, @"FBWorkspaceConnectionsStateStore.m", 356, v42);
        }
        _bs_set_crash_log_message([v42 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:[FBWorkspaceConnectionsState class]]) {
        NSArray *v0 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v46 = [v0 classForCoder];
        if (!v46) {
            v46 = [v0 class];
        }
        NSString *v47 = NSStringFromClass(v46);
        NSString *v48 = NSStringFromClass([FBWorkspaceConnectionsState class]);
        NSString *v49 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"state", v47, v48];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v50 = NSStringFromSelector(_cmd);
            NSString *v51 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v50, v51, self, @"FBWorkspaceConnectionsStateStore.m", 356, v49);
        }
        _bs_set_crash_log_message([v49 UTF8String]);
        __break(0);
    }
    if (!a2) {
        if (!a4) {
            NSString *v53 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"failure"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v54 = NSStringFromSelector(_cmd);
                NSString *v55 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v54, v55, self, @"FBWorkspaceConnectionsStateStore.m", 358, v53);
            }
            _bs_set_crash_log_message([v53 UTF8String]);
            __break(0);
        }
        return 0;
    }
    if (![a2 isKindOfClass:[NSString class]]) {
        NSArray *v57 = OUTLINED_FUNCTION_28(a2);
        __builtin_return_address(0);
        Class v58 = [v57 classForCoder];
        if (!v58) {
            v58 = [v57 class];
        }
        NSString *v59 = NSStringFromClass(v58);
        NSString *v60 = NSStringFromClass([NSString class]);
        NSString *v61 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"shmPath", v59, v60];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v62 = NSStringFromSelector(_cmd);
            NSString *v63 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v62, v63, self, @"FBWorkspaceConnectionsStateStore.m", 357, v61);
        }
        _bs_set_crash_log_message([v61 UTF8String]);
        __break(0);
    }
    if (!a4) {
        NSString *v65 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"failure"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v66 = NSStringFromSelector(_cmd);
            NSString *v67 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v66, v67, self, @"FBWorkspaceConnectionsStateStore.m", 358, v65);
        }
        _bs_set_crash_log_message([v65 UTF8String]);
        __break(0);
    }
    int *v4 = __error();
    *(v4) = 0;
    const char *UTF8String = [a2 UTF8String];
    int v6 = shm_open(UTF8String, 2562, 384);
    if (v6 >= 0) {
        serializedDataLength = [a1 serializedDataLength];
        if (serializedDataLength >= 0x7fffffffffffffff) {
            NSString *v69 = [NSString stringWithFormat:@"shmLength out of range"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v70 = NSStringFromSelector(_cmd);
                NSString *v71 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v70, v71, self, @"FBWorkspaceConnectionsStateStore.m", 368, v69);
            }
            _bs_set_crash_log_message([v69 UTF8String]);
            __break(0);
        }
        if (*(a4) != 2) {
            int *v8 = __error();
            *(v8) = 0;
            if (ftruncate(v6, serializedDataLength + 1)) {
                int *v26 = __error();
                strerror_r(*(v26), v12, 0x100);
                os_log_t oslog5 = FBLogCommon();
                if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                    int *v79 = __error();
                    int v21 = *(v79);
                    os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "failed to set the size of %@ - unlinking : errno=%i (%s)", a2, v21, &v12);
                }
                [FBWorkspaceConnectionsStateStore _unlinkShmPath:a2 graceful:0];
                v14 = 0;
            } else if (*(a4) != 3) {
                int *v9 = __error();
                *(v9) = 0;
                v10 = mmap(NULL, serializedDataLength + 1, 2, 1, v6, 0);
                if (v10 == -1) {
                    int *v11 = __error();
                    strerror_r(*(v11), v12, 0x100);
                    os_log_t oslog = FBLogCommon();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        int *v73 = __error();
                        int v13 = *(v73);
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "failed to mmap %@ - unlinking : errno=%i (%s)", a2, v13, &v12);
                    }
                    [FBWorkspaceConnectionsStateStore _unlinkShmPath:a2 graceful:0];
                    v14 = 0;
                } else {
                    void *v15 = &v16;
                    *(uint64_t *)&v16[0] = 0;
                    *(uint64_t *)&v16[8] = v15;
                    *(uint64_t *)&v16[16] = 0x2020000000;
                    *(uint64_t *)&v16[24] = 0;
                    long v18 = [a1 serializeToWriter:^long(void *arg1, unsigned long arg2) {
                        int *v89;
                        unsigned long v88 = serializedDataLength - arg2;
                        if (serializedDataLength < arg2) {
                            v89 = __error();
                            *(v89) = 14;
                            arg2 = -1;
                        } else {
                            long v90 = v15->field_8->field_24;
                            if (v15->field_8->field_24 <= v88) {
                                memmove(v10 + 1 + v90);
                                void *v91 = v15->field_8;
                                v91->field_24 = v91->field_24 + arg2;
                            } else {
                                v89 = __error();
                                *(v89) = 14;
                                arg2 = -1;
                            }
                        }
                        return arg2;
                    }];
                    if (v18 != serializedDataLength) {
                        os_log_t oslog2 = FBLogCommon();
                        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "data length inconsistent in %@ - unlinking : actual=%zi expected=%zu", a2, v18, serializedDataLength);
                        }
                        [FBWorkspaceConnectionsStateStore _unlinkShmPath:a2 graceful:0];
                    } else {
                        if (*(a4) != 4) {
                            *(uint8_t *)v10 = (a3 != 0) ? 3 : 1;
                            int *v22 = __error();
                            *(v22) = 0;
                            if (__msync(v10, serializedDataLength + 1, 16) != -1) {
                                goto blk_1c4eefadc;
                            }
                            goto blk_1c4eefaac;
                        }
                        *(a4) = 0;
                        os_log_t oslog3 = FBLogCommon();
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "simulating crash after writing data to new buffer : %@", a2);
                        }
                    }
                    v14 = 0;
                    v24 = __error();
                    *(v24) = 0;
                    if (munmap(v10, serializedDataLength + 1) != -1) {
                        _Block_object_dispose(v16, 8);
                        v31 = __error();
                        *(v31) = 0;
                        if (close(v6) != 0) {
                            v32 = __error();
                            strerror_r(*(v32), v12, 0x100);
                            v33 = FBLogCommon();
                            if (os_log_type_enabled(v33, OS_LOG_TYPE_ERROR)) {
                                int *v76 = __error();
                                long (^v17)(void *, unsigned long) = *(v76);
                                os_log_with_type(v33, OS_LOG_TYPE_ERROR, "failed to close write of %@ : errno=%i (%s)", a2, v17, &v12);
                            }
                        }
                        return v14;
                    }
                    v38 = __error();
                    strerror_r(*(v38), v12, 0x100);
                    v39 = FBLogCommon();
                    if (os_log_type_enabled(v39, OS_LOG_TYPE_ERROR)) {
                        v40 = __error();
                        int v19 = *(v40);
                        os_log_with_type(v39, OS_LOG_TYPE_ERROR, "failed to munmap %@ - unlinking : errno=%i (%s)", a2, v19, &v12);
                    }
                    [FBWorkspaceConnectionsStateStore _unlinkShmPath:a2 graceful:0];
                    _Block_object_dispose(v16, 8);
                }
            } else {
                *(a4) = 0;
                os_log_t oslog4 = FBLogCommon();
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "simulating crash after resizing new buffer : %@", a2);
                }
                v14 = 0;
            }
        } else {
            *(a4) = 0;
            os_log_t oslog6 = FBLogCommon();
            if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "simulating crash after opening new buffer : %@", a2);
            }
            v14 = 0;
        }
    } else {
        int *v29 = __error();
        strerror_r(*(v29), v12, 0x100);
        os_log_t oslog7 = FBLogCommon();
        if (os_log_type_enabled(oslog7, OS_LOG_TYPE_ERROR)) {
            int *v82 = __error();
            int v23 = *(v82);
            os_log_with_type(oslog7, OS_LOG_TYPE_ERROR, "failed to create %@ : errno=%i (%s)", a2, v23, &v12);
        }
        return 0;
blk_1c4eefaac:
        int *v34 = __error();
        strerror_r(*(v34), v12, 0x100);
        os_log_t oslog8 = FBLogCommon();
        if (os_log_type_enabled(oslog8, OS_LOG_TYPE_ERROR)) {
            int *v36 = __error();
            int v25 = *(v36);
            os_log_with_type(oslog8, OS_LOG_TYPE_ERROR, "failed to msync %@ : errno=%i (%s)", a2, v25, &v12);
        }
blk_1c4eefadc:
        v14 = 1;
        v24 = __error();
        *(v24) = 0;
        if (munmap(v10, serializedDataLength + 1) != -1) {
            _Block_object_dispose(v16, 8);
            v31 = __error();
            *(v31) = 0;
            if (close(v6) != 0) {
                v32 = __error();
                strerror_r(*(v32), v12, 0x100);
                v33 = FBLogCommon();
                if (os_log_type_enabled(v33, OS_LOG_TYPE_ERROR)) {
                    int *v84 = __error();
                    int v27 = *(v84);
                    os_log_with_type(v33, OS_LOG_TYPE_ERROR, "failed to close write of %@ : errno=%i (%s)", a2, v27, &v12);
                }
            }
            return v14;
        }
        v38 = __error();
        strerror_r(*(v38), v12, 0x100);
        v39 = FBLogCommon();
        if (os_log_type_enabled(v39, OS_LOG_TYPE_ERROR)) {
            v40 = __error();
            int v28 = *(v40);
            os_log_with_type(v39, OS_LOG_TYPE_ERROR, "failed to munmap %@ - unlinking : errno=%i (%s)", a2, v28, &v12);
        }
        [FBWorkspaceConnectionsStateStore _unlinkShmPath:a2 graceful:0];
        _Block_object_dispose(v16, 8);
    }
    v31 = __error();
    *(v31) = 0;
    if (close(v6) != 0) {
        v32 = __error();
        strerror_r(*(v32), v12, 0x100);
        v33 = FBLogCommon();
        if (os_log_type_enabled(v33, OS_LOG_TYPE_ERROR)) {
            int *v86 = __error();
            int v30 = *(v86);
            os_log_with_type(v33, OS_LOG_TYPE_ERROR, "failed to close write of %@ : errno=%i (%s)", a2, v30, &v12);
        }
    }
    return v14;
}


void +[FBWorkspaceConnectionsStateStore _unlinkShmPath:graceful:](id a1, int a2)
{
    char v10[256];
    Class aClass = [NSString class];
    if (!a1) {
        NSString *v5 = NSStringFromClass(aClass);
        NSString *v6 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"shmPath", v5];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v1 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v1, self, @"FBWorkspaceConnectionsStateStore.m", 340, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:aClass]) {
        NSArray *v13 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v14 = [v13 classForCoder];
        if (!v14) {
            v14 = [v13 class];
        }
        NSString *v15 = NSStringFromClass(v14);
        NSString *v16 = NSStringFromClass([NSString class]);
        NSString *v17 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"shmPath", v15, v16];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceConnectionsStateStore.m", 340, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    int *v7 = __error();
    *(v7) = 0;
    int v8 = shm_unlink([a1 UTF8String]);
    if ((a2 & 1) == 0 && v8 != 0) {
        int *v9 = __error();
        strerror_r(*(v9), v10, 0x100);
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            int *v21 = __error();
            int v3 = *(v21);
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "failed to unlink %@ : errno=%i (%s)", a1, v3, &v10);
        }
    }
}


FBWorkspaceConnectionsStateStore *-[FBWorkspaceConnectionsStateStore _initWithIdentifier:](id a1)
{
    long v4;
    long v8;
    FBWorkspaceConnectionsStateStore *self;
    if (self != nil) {
        id v1 = a1;
        if (a1 != nil && ![v1 isKindOfClass:[NSString class]]) {
            NSArray *v9 = OUTLINED_FUNCTION_28(v1);
            __builtin_return_address(0);
            Class v2 = [v9 classForCoder];
            if (!v2) {
                v2 = [v9 class];
            }
            NSString *v3 = NSStringFromClass(v2);
            NSString *v10 = NSStringFromClass([NSString class]);
            NSString *v5 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"identifier", v3, v10];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v6 = NSStringFromSelector(@selector(_initWithIdentifier:));
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspaceConnectionsStateStore.m", 110, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        self = [super init];
        if (self != nil) {
            if (v1) {
                self->_path1 = _pathForIdentifierAndBuffer(v1, 0);
                self->_path2 = _pathForIdentifierAndBuffer(v1, 1);
            }
            id serial = [BSDispatchQueueAttributes serial];
            id v16 = [serial serviceClass:25];
            self->_queue = BSDispatchQueueCreate(@"com.apple.frontboard.workspace.connections.shm", v16);
            self->_queue_nextWriteFailure = 0;
            dispatch_async(self->_queue, ^void(void) {
                uint8_t v27[16];
                long v22;
                long v29 = 0;
                Class v39 = [self class];
                FBWorkspaceConnectionsState *v40 = [v39 _loadStateFromPath:self->_path1 outGeneration:&v4 outExisted:&v29];
                long v41 = 0;
                Class v42 = [self class];
                FBWorkspaceConnectionsState *v43 = [v42 _loadStateFromPath:self->_path2 outGeneration:&v8 outExisted:&v41];
                if (!v40 && !v43) {
                    os_log_t oslog4 = FBLogCommon();
                    if ((v29 & 1) != 0 || (v41 & 1) != 0) {
                        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_FAULT)) {
                            os_log_with_type(oslog4, OS_LOG_TYPE_FAULT, "all previous workspace connections states are bad : %@", v1);
                        }
                    } else if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "no previous workspace connections state - initializing");
                    }
                    self->_queue_state = [FBWorkspaceConnectionsState new];
                    self->_queue_lastBuffer = 0;
                } else {
                    if (v40 != nil && v43 != nil) {
                        long v35 = v4;
                        long v36 = v8;
                        Class v37 = [self class];
                        [v37 _unlinkShmPath:*((v35 == v36) ? &self->_path1 : &self->_path2) graceful:0];
                        os_log_t log = FBLogCommon();
                        if (os_log_type_enabled(log, OS_LOG_TYPE_ERROR)) {
                            *(uint32_t *)&v27[0] = 0x4000100;
                            if (v35 == v36) {
                                *(uint32_t *)&v27[4] = 2;
                                _os_log_error_impl(&_mh_dylib_header, log, OS_LOG_TYPE_ERROR, "previous workspace connections state wasn't clean - resolving latest (%i)", v27, 8);
                            } else {
                                *(uint32_t *)&v27[4] = 1;
                                _os_log_error_impl(&_mh_dylib_header, log, OS_LOG_TYPE_ERROR, "previous workspace connections state wasn't clean - resolving latest (%i)", v27, 8);
                            }
                        }
                        if (v35 == v36) {
blk_1c4efaf4c:
                            os_log_t oslog = FBLogCommon();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                                os_log_with_type(oslog, OS_LOG_TYPE_INFO, "restored previous workspace connections state (2)");
                            }
                            self->_queue_state = v43;
                            v22 = (v8 != 0) ? 4 : 2;
                        } else {
blk_1c4efb0a0:
                            os_log_t oslog2 = FBLogCommon();
                            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                                os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "restored previous workspace connections state (1)");
                            }
                            self->_queue_state = v40;
                            v22 = (v4 != 0) ? 3 : 1;
                        }
                    } else if (!v43) {
                        goto blk_1c4efb0a0;
                    } else {
                        goto blk_1c4efaf4c;
                    }
                    self->_queue_lastBuffer = v22;
                    os_log_t oslog3 = FBLogCommon();
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEBUG)) {
                        FBWorkspaceConnectionsState *v2 = self->_queue_state;
                        os_log_with_type(oslog3, OS_LOG_TYPE_DEBUG, "previous workspace connections = %@", v2);
                    }
                }
            });
        }
    }
    return self;
}


id -[FBWorkspaceConnectionsStateStore state](void)
{
    if (!self) {
        return nil;
    }
    __block id v1 = nil;
    dispatch_async_and_wait(self->_queue, ^void(void) {
        v1 = self->_queue_state;
    });
    return v1;
}


id +[FBWorkspaceConnectionsStateStore identifierForName:](id a1)
{
    objc_opt_self(self);
    id v1 = ([a1 length] < 26) ? a1 : [a1 substringToIndex:25];
    return v1;
}


int +[FBWorkspaceConnectionsStateStore hasSandboxAccessForIdentifier:](id a1)
{
    long v0;
    NSFastEnumerationState v11;
    id v13;
    char v34[256];
    v0.field_0 = &v0;
    id v1 = objc_opt_self(self);
    Class aClass = [NSString class];
    if (a1 != nil) {
        if (![a1 isKindOfClass:aClass]) {
            NSArray *v40 = OUTLINED_FUNCTION_28(a1);
            __builtin_return_address(0);
            Class v2 = [v40 classForCoder];
            if (!v2) {
                v2 = [v40 class];
            }
            NSString *v41 = NSStringFromClass(v2);
            NSString *v4 = NSStringFromClass([NSString class]);
            NSString *v42 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"identifier", v41, v4];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v43 = NSStringFromSelector(@selector(hasSandboxAccessForIdentifier:));
                NSString *v44 = NSStringFromClass([v1 class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v43, v44, v1, @"FBWorkspaceConnectionsStateStore.m", 81, v42);
            }
            _bs_set_crash_log_message([v42 UTF8String]);
            __break(0);
        }
        int v8 = 1;
        NSArray<NSString *> *v10 = @[_pathForIdentifierAndBuffer(a1, 0), _pathForIdentifierAndBuffer(a1, 1)];
        _memset(v11, 0, 64);
        NSUInteger v12 = [@[@"ipc-posix-shm-read-data", @"ipc-posix-shm-write-unlink", @"ipc-posix-shm-write-create"] countByEnumeratingWithState:&v11 objects:&v13 count:16];
        if (!v12) {
            return v8;
        }
        long v14 = *(v11.mutationsPtr);
        int v15 = SANDBOX_CHECK_NO_REPORT;
        long v18 = v14;
        do {
            long v20 = 0;
            do {
                if (*(v11.mutationsPtr) != v18) {
                    objc_enumerationMutation(@[@"ipc-posix-shm-read-data", @"ipc-posix-shm-write-unlink", @"ipc-posix-shm-write-create"]);
                }
                id v21 = v11.itemsPtr[v20];
                NSArray<NSString *> *v23 = v10;
                for (NSString *v28 in v23) {
                    int *v29 = __error();
                    *(v29) = 0;
                    long v30 = __getpid(v29);
                    const char *UTF8String = [v21 UTF8String];
                    [v28 UTF8String];
                    long v32 = sandbox_check(v30, UTF8String, 17 | v15);
                    if (v32 != 0) {
                        if (v32 == 1) {
                            os_log_t oslog2 = FBLogCommon();
                            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "FBWorkspaceConnectionsStateStore: %@ denied for %@", v21, v28);
                            }
                            return 0;
                        }
                        int *v33 = __error();
                        strerror_r(*(v33), v34, 0x100);
                        os_log_t oslog = FBLogCommon();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                            int *v36 = __error();
                            int v5 = *(v36);
                            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "FBWorkspaceConnectionsStateStore: error in sandbox_check %@ for %@ : errno=%i (%s)", v21, v28, v5, &v34);
                        }
                    }
                }
                v20++;
                v18 = v14;
            } while (v20 != v12);
            v12 = [@[@"ipc-posix-shm-read-data", @"ipc-posix-shm-write-unlink", @"ipc-posix-shm-write-create"] countByEnumeratingWithState:&v11 objects:&v13 count:16];
            v18 = v14;
        } while (v12 != 0);
        return v8;
    }
    NSString *v38 = NSStringFromClass(aClass);
    NSString *v39 = [NSString stringWithFormat:@"Value for '%@' was unexpectedly nil. Expected %@.", @"identifier", v38];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v47 = NSStringFromSelector(@selector(hasSandboxAccessForIdentifier:));
        NSString *v48 = NSStringFromClass([v1 class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v47, v48, v1, @"FBWorkspaceConnectionsStateStore.m", 81, v39);
    }
    _bs_set_crash_log_message([v39 UTF8String]);
    __break(0);
}


FBWorkspaceConnectionsState *+[FBWorkspaceConnectionsStateStore _loadStateFromPath:outGeneration:outExisted:](id a1, char *a2, char *a3)
{
    FBWorkspaceConnectionsState *v8;
    struct stat v6;
    char v12[256];
    char v29[256];
    char v26[256];
    if (!a1 || [a1 isKindOfClass:[NSString class]]) {
        if (!a2) {
            NSString *v32 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outGenerationTwiddle"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v33 = NSStringFromSelector(_cmd);
                NSString *v34 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v33, v34, self, @"FBWorkspaceConnectionsStateStore.m", 255, v32);
            }
            _bs_set_crash_log_message([v32 UTF8String]);
            __break(0);
        }
        if (!a3) {
            NSString *v36 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outExisted"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v37 = NSStringFromSelector(_cmd);
                NSString *v38 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v37, v38, self, @"FBWorkspaceConnectionsStateStore.m", 0x100, v36);
            }
            _bs_set_crash_log_message([v36 UTF8String]);
            __break(0);
        }
        if (!a1) {
            goto blk_1c4f388f8;
        }
        int *v2 = __error();
        *(v2) = 0;
        const char *UTF8String = [a1 UTF8String];
        int v4 = shm_open(UTF8String, 0);
        if (v4 >= 0) {
            *(a3) = 1;
            unsigned long minimumSerializedDataLength = [FBWorkspaceConnectionsState minimumSerializedDataLength];
            if (minimumSerializedDataLength >= 0x7fffffffffffffff) {
                NSString *v40 = [NSString stringWithFormat:@"shmLength cannot exceed SSIZE_MAX"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v41 = NSStringFromSelector(_cmd);
                    NSString *v42 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v42, self, @"FBWorkspaceConnectionsStateStore.m", 268, v40);
                }
                _bs_set_crash_log_message([v40 UTF8String]);
                __break(0);
            }
            v6 = (struct stat){0};
            if (fstat(v4, &v6) != 0 || v6.st_size <= minimumSerializedDataLength) {
                os_log_t oslog7 = FBLogCommon();
                if (os_log_type_enabled(oslog7, OS_LOG_TYPE_ERROR)) {
                    off_t v7 = v6.st_size;
                    os_log_with_type(oslog7, OS_LOG_TYPE_ERROR, "invalid size of %@ - unlinking : size=%lli", a1, v7);
                }
                [FBWorkspaceConnectionsStateStore _unlinkShmPath:a1 graceful:0];
blk_1c4f38844:
                v8 = nil;
            } else {
                int *v9 = __error();
                *(v9) = 0;
                void *v10 = mmap(NULL, v6.st_size, 1, 1, v4, 0);
                if (v10 == -1) {
                    int *v11 = __error();
                    strerror_r(*(v11), v12, 0x100);
                    os_log_t oslog = FBLogCommon();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        int *v44 = __error();
                        int v13 = *(v44);
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "failed to mmap %@ - unlinking : errno=%i (%s)", a1, v13, &v12);
                    }
                    [FBWorkspaceConnectionsStateStore _unlinkShmPath:a1 graceful:0];
                    goto blk_1c4f38844;
                }
                int v14 = *(uint8_t *)v10;
                if ((*(uint8_t *)v10 & 1) != 0) {
                    __block long v17 = 0;
                    long v16 = -1;
                    v8 = [FBWorkspaceConnectionsState deserializeLength:&v16 fromReader:^long(void *arg1, unsigned long arg2) {
                        int *v63;
                        off_t v61 = v6.st_size - 1;
                        off_t v62 = v61 - arg2;
                        if ((unsigned long)v61 < arg2) {
                            v63 = __error();
                            *(v63) = 14;
                            arg2 = -1;
                        } else {
                            long v64 = v17;
                            if ((unsigned long)v17 <= (unsigned long)v62) {
                                memmove(arg1, v10 + 1 + v64);
                                v17 += arg2;
                            } else {
                                v63 = __error();
                                *(v63) = 14;
                                arg2 = -1;
                            }
                        }
                        return arg2;
                    }];
                    if (!v8 || v16 < minimumSerializedDataLength || v16 > 0x7ffffffffffffffd) {
                        os_log_t oslog2 = FBLogCommon();
                        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                            off_t v15 = v6.st_size - 1;
                            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "data length inconsistent in %@ - unlinking : min=%zu actual=%zu expected=%llu", a1, minimumSerializedDataLength, v16, v15);
                        }
                        [FBWorkspaceConnectionsStateStore _unlinkShmPath:a1 graceful:0];
                        v8 = nil;
                    } else {
                        *(a2) = (v14 >> 1) & 1;
                    }
                } else {
                    os_log_t oslog3 = FBLogCommon();
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "validity check failed for %@ - unlinking", a1);
                    }
                    [FBWorkspaceConnectionsStateStore _unlinkShmPath:a1 graceful:0];
                    v8 = nil;
                }
                int *v22 = __error();
                *(v22) = 0;
                if (munmap(v10, v6.st_size) == -1) {
                    int *v30 = __error();
                    strerror_r(*(v30), v29, 0x100);
                    os_log_t oslog6 = FBLogCommon();
                    if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                        int *v47 = __error();
                        long (^v18)(void *, unsigned long) = *(v47);
                        os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "failed to munmap %@ - unlinking : errno=%i (%s)", a1, v18, &v29);
                    }
                    [FBWorkspaceConnectionsStateStore _unlinkShmPath:a1 graceful:0];
                }
            }
            int *v23 = __error();
            *(v23) = 0;
            if (close(v4)) {
                int *v24 = __error();
                strerror_r(*(v24), v26, 0x100);
                os_log_t oslog4 = FBLogCommon();
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                    int *v49 = __error();
                    int v19 = *(v49);
                    os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "failed to close read of %@ : errno=%i (%s)", a1, v19, &v26);
                }
            }
        } else if (*(__error()) != 2) {
            int *v27 = __error();
            strerror_r(*(v27), v12, 0x100);
            os_log_t oslog5 = FBLogCommon();
            if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                int *v51 = __error();
                int v21 = *(v51);
                os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "failed to read %@ : errno=%i (%s)", a1, v21, &v12);
            }
blk_1c4f388f8:
            v8 = nil;
            *(a3) = 0;
        } else {
            v8 = nil;
        }
        return v8;
    } else {
        NSArray *v53 = OUTLINED_FUNCTION_28(a1);
        __builtin_return_address(0);
        Class v54 = [v53 classForCoder];
        if (!v54) {
            v54 = [v53 class];
        }
        NSString *v55 = NSStringFromClass(v54);
        NSString *v56 = NSStringFromClass([NSString class]);
        NSString *v57 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"shmPath", v55, v56];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v58 = NSStringFromSelector(_cmd);
            NSString *v59 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v58, v59, self, @"FBWorkspaceConnectionsStateStore.m", 254, v57);
        }
        _bs_set_crash_log_message([v57 UTF8String]);
        __break(0);
    }
}


void -[FBWorkspaceConnectionsStateStore .cxx_destruct](void)
{
    self->_queue_state = nil;
    self->_queue = nil;
    self->_path2 = nil;
    self->_path1 = nil;
}


void -[FBWorkspaceConnectionsStateStore init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBWorkspaceConnectionsStateStore"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceConnectionsStateStore.m", 105, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
