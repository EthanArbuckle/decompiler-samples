struct FBWorkspaceScene {
    FBWorkspaceConnection *_lock_connection; // +0x8
    __weak id<FBSceneHost> _host; // +0x10
    FBSSceneDefinition *_definition; // +0x18
    FBSSceneIdentity *_identity; // +0x20
    NSString *_logProem; // +0x28
    id<FBSSceneHostAgent> _hostAgent; // +0x30
    NSMutableArray *_agentSessions; // +0x38
    FBSSceneSettings *_lock_settings; // +0x40
    FBSSceneClientSettings *_lock_clientSettings; // +0x48
    NSMutableArray *_lock_sceneCreatedBlocks; // +0x50
    id<BSInvalidatable> _queue_workspaceAssertion; // +0x58
    NSMutableSet *_queue_allWatchdogs; // +0x60
    NSMutableArray *_queue_watchdogStack; // +0x68
    BSAtomicSignal *_queue_eventsCompleteSignal; // +0x70
    unsigned long _queue_inFlightUpdateEvents; // +0x78
    unsigned long _queue_inFlightDeactivationEvents; // +0x80
    unsigned long _queue_inFlightUpdateAllowsThrottling; // +0x88
    unsigned long _queue_inFlightUpdateDisallowsThrottling; // +0x90
    unsigned long _queue_inFlightExternallyManagedEvents; // +0x98
    struct os_unfair_lock_s _lock; // +0xa0
    struct { unsigned int rawValue; } _queue_workspaceState; // +0xa4
    unsigned char _lock_lifecycleState; // +0xa8
    bool _reconnect; // +0xa9
    bool _lock_invalidated; // +0xaa
    bool _usesOutgoingConnection; // +0xab
    bool _isUISubclass; // +0xac
    BSServiceDispatchQueue *_workspaceQueue; // +0xb0
};

void -[FBWorkspaceScene _workspaceQueue_sendMessageToClient:](void (^a1)(id<FBSWorkspaceServiceServerInterface>))
{
    void (^v0)(id<FBSWorkspaceServiceServerInterface>) = a1;
    os_unfair_lock_lock(&self->_lock);
    FBWorkspaceConnection *v1 = self->_lock_connection;
    os_unfair_lock_unlock(&self->_lock);
    if (!v1) {
        v0(nil);
    } else {
        [v1 _workspaceScene:self enqueueConnectBlock:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
            os_unfair_lock_lock(&self->_lock);
            bool v5 = self->_lock_invalidated;
            os_unfair_lock_unlock(&self->_lock);
            v0((v5) ? nil : arg1);
        }];
    }
}


void -[FBWorkspaceScene _workspaceQueue_updateAssertion](void)
{
    int v17;
    unsigned int v19;
    int v16;
    long v22;
    long v23;
    unsigned int v26;
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_invalidated != 1) {
        FBSSceneSettings *v0 = self->_lock_settings;
        FBWorkspaceConnection *v1 = self->_lock_connection;
        os_unfair_lock_unlock(&self->_lock);
        long activityMode = [v0 activityMode];
        int v8 = (activityMode > 0) ? 10 : (!activityMode) ? 0 : (activityMode > -11) ? 246 : (activityMode > -21) ? 236 : (activityMode < -50) ? -128 : -50;
        long jetsamPriority = [v0 jetsamPriority];
        long v10 = FBSSceneJetsamPriorityGetJetsamMode(jetsamPriority);
        int v14 = (v10 > 0) ? 10 : (!v10) ? 0 : (v10 > -11) ? 246 : (v10 < -20) ? -128 : -20;
        long v15 = FBSSceneJetsamPriorityGetResourceElevation(jetsamPriority);
        if ((v8 & 255) == 128) {
            v17 = 0;
            v19 = 0;
        } else if (![v0 isForeground]) {
            v16 = (self->_queue_inFlightDeactivationEvents != 0) ? 2 : 1;
            v17 = (!self->_queue_inFlightDeactivationEvents) ? 0 : 2;
            v8 = 206;
blk_1c4edfb78:
            if (!self->_queue_inFlightUpdateEvents) {
                v19 = 0;
                int v20 = v8 & 255;
                if ((v8 & 255) > 235) {
                    v16 = v17;
                    if (v20 == 246) {
blk_1c4edfc34:
                        int v21 = v16 - 1;
                        if ((unsigned int)((v16 - 1) & 255) >= 3) {
blk_1c4edfc58:
                            v19 = 0;
                        } else {
                            v22 = (v21 & 31) * 8;
                            v23 = 262915;
blk_1c4edfc50:
                            v19 = v23 >> v22;
                        }
                        v17 = v16;
                    } else if (v20 == 236) {
blk_1c4edfbf0:
                        if ((unsigned int)((v16 - 1) & 255) >= 3) {
                            goto blk_1c4edfc58;
                        }
                        v22 = ((v16 - 1) & 31) * 8;
                        v23 = 131585;
                        goto blk_1c4edfc50;
                    }
                } else if (!v20 || v20 == 10) {
                    v19 = 0x5040300 >> v17 * 8;
                }
            } else {
                if (self->_queue_inFlightUpdateEvents != self->_queue_inFlightExternallyManagedEvents) {
                    if (!self->_queue_inFlightUpdateAllowsThrottling || self->_queue_inFlightUpdateDisallowsThrottling != 0) {
                        goto blk_1c4edfc34;
                    } else {
                        goto blk_1c4edfbf0;
                    }
                }
                v19 = 0;
            }
        } else {
            if ((v8 & 255) != 0) {
                v16 = 3;
                goto blk_1c4edfb74;
            }
            if (([v0 prefersProcessTaskSuspensionWhileSceneForeground] & 1) != 0) {
                v16 = 3;
                v8 = 206;
blk_1c4edfb74:
                v17 = 3;
                goto blk_1c4edfb78;
            }
            if (![v0 isOccluded] || ([v0 isIgnoringOcclusions] & 1) != 0) {
                v19 = 5;
            } else {
                v19 = 4;
            }
            v17 = 3;
        }
        int v25 = v14 & 255;
        if ((v14 & 255) <= 235) {
            int v35 = (v17 & 255) * 8;
            v26 = (!v25) ? 0x645a2800 >> v35 : (v25 == 10) ? 0x655a2800 >> v35 : 0;
        } else if (v25 == 246) {
            v26 = 0x5a501e00 >> (v17 & 255) * 8;
        } else if (v25 == 236) {
            int v27 = v17 & 255;
            v26 = (v27 == 3) ? (v15 < 3) ? 30 : (v15 == 3) ? 33 : (v15 != 4) ? 35 : 34 : (v27 == 2) ? (v15 < 3) ? 30 : 33 : (v27 != 1) ? 0 : (v15 < 3) ? 20 : 30;
        } else {
            v26 = 0;
        }
        struct { unsigned int rawValue; } v37 = FBWorkspaceStateCreate(v17 & 255, v19 & 255, v26 & 255);
        if ((FBWorkspaceStateEqual(self->_queue_workspaceState.rawValue, v37) & 1) == 0) {
            os_log_t oslog = FBLogProcessScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                NSString *v40 = NSStringFromFBWorkspaceState(v37);
                NSString *v3 = self->_logProem;
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Scene state did change: %{public}@.", v3, v40);
            }
            self->_queue_workspaceState.rawValue = v37;
            id<BSInvalidatable> v42 = self->_queue_workspaceAssertion;
            self->_queue_workspaceAssertion = [v1 _acquireAssertionForWorkspaceScene:self withState:v37];
            [v42 invalidate];
        }
        return;
    }
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBWorkspaceScene workspace:sendUpdatedSettings:withDiff:transitionContext:completion:](id a1, id a2, id a3, id a4, void (^a5)(bool, NSError *))
{
    id v23;
    void (^v32)(bool, NSError *);
    void (^v37)(bool, NSError *);
    unsigned long v38;
    id v1 = a2;
    id v2 = a3;
    id v3 = a4;
    void (^v4)(bool, NSError *) = a5;
    if (!self) {
        return;
    }
    [self->_workspaceQueue assertBarrierOnQueue];
    id process = [a1 process];
    uint32_t v6 = arc4random();
    unsigned int v7 = FBSceneLifecycleStateForSettings(v1);
    os_unfair_lock_lock(&self->_lock);
    self->_lock_settings = [v1 copy];
    int v10 = [FBWorkspaceScene _sceneActionForLifecycleFromState:self->_lock_lifecycleState toState:v7];
    if (v10 == 1) {
        if (([v2 _isSignifcant] & 1) == 0) {
            FBSSceneSpecification *specification = [self->_definition specification];
            if ([specification _isSignificantTransitionContext:v3]) {
                v10 = 1;
            } else {
                v10 = 0;
            }
        } else {
            v10 = 1;
        }
    }
    long allowCPUThrottling = [v3 allowCPUThrottling];
    id updateContext = [v3 updateContext];
    long isClientLifecycleExternallyManaged = [updateContext isClientLifecycleExternallyManaged];
    if ((unsigned int)v10 <= 5 && ((1 << v10) & 52) != 0) {
        id _uiApplicationSceneTransitionContextShim = [v3 _uiApplicationSceneTransitionContextShim];
        double execTime = [process execTime];
        [_uiApplicationSceneTransitionContextShim setExecTime:execTime];
    }
    int v18 = self->_lock_lifecycleState;
    if (self->_lock_lifecycleState != v7) {
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id v20 = FBSceneLifecycleStateDescription(v7);
            NSString *v19 = self->_logProem;
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Scene lifecycle state did change: %{public}@", v19, v20);
        }
        self->_lock_lifecycleState = v7;
    }
    if ((v10 & 254) == 4) {
        FBSSceneSpecification *specification2 = [self->_definition specification];
        v23 = [FBSMutableSceneParameters parametersForSpecification:specification2];
        [v23 setSettings:self->_lock_settings];
        [v23 setClientSettings:self->_lock_clientSettings];
    } else {
        v23 = nil;
    }
    os_unfair_lock_unlock(&self->_lock);
    __block void *v25 = 0;
    if (!self->_hostAgent) {
        [self _workspaceQueue_incrementInFlightUpdatesForAction:v10 allowThrottling:allowCPUThrottling externallyManaged:isClientLifecycleExternallyManaged];
        if (v18 != v7) {
            [a1 _workspaceSceneLifecycleStateChanged:self];
        }
        v32 = (!v23) ? nil : FBAnalyticsLogHangTracerEvent(process, 2);
        v37 = ^void(bool arg1, NSError *arg2) {
            [self _workspaceQueue_decrementInFlightUpdatesForAction:v10 allowThrottling:allowCPUThrottling externallyManaged:isClientLifecycleExternallyManaged];
            if (v4 != nil) {
                v4(arg1, arg2);
            }
            if (v25 != 0) {
                if (!arg1) {
                    id v48 = [NSError sceneMessageErrorWithCode:2];
                    v25->field_16(v25, 0, v48);
                } else {
                    v25->field_16(v25, 0, 0);
                }
            }
            if (v32 != nil) {
                v32(arg1, arg2);
            }
        };
        if (!v10) {
            v37(YES, nil);
        } else {
            v38 = v6 * 0x80008001 >> 47;
            [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                uint8_t v52[48];
                if (!arg1) {
                    FBProcessExitContext *exitContext = [process exitContext];
                    id createError = [exitContext createError];
                    NSError *v57 = FBWorkspaceSceneErrorCreate(1, @"Scene update failed.", @"Client process exited.", createError);
                    v37(NO, v57);
                } else {
                    id v58 = [self _workspaceQueue_createWatchdogForProcess:process sceneAction:v10 settings:v1 transitionContext:v3];
                    os_log_type_t type = ((v10 == 1) ? !v58 : 0) == 1;
                    os_log_t v62 = FBLogProcessScene();
                    if (os_log_type_enabled(v62, type)) {
                        id v61 = _FBSceneActionToString(v10);
                        id _policyDesc = [v58 _policyDesc];
                        *(uint32_t *)&v52[0] = 0x8420502;
                        *(uint16_t *)&v52[12] = 2114;
                        *(uint64_t *)&v52[14] = v61;
                        *(uint16_t *)&v52[22] = 0x400;
                        *(uint32_t *)&v52[24] = v6 + (v38 - (v38 << 16));
                        *(uint16_t *)&v52[28] = 0x800;
                        *(uint64_t *)&v52[30] = process;
                        *(uint16_t *)&v52[38] = 2114;
                        *(uint64_t *)&v52[40] = (!_policyDesc) ? @"none" : _policyDesc;
                        _os_log_impl(&_mh_dylib_header, v62, type, "[%{public}@] Sending scene action [%{public}@][%#04x] to process %p (watchdog: %{public}@)", v52, 48);
                    }
                    void (^v54)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                        os_log_t oslog = FBLogProcessScene();
                        if (os_log_type_enabled(oslog, type)) {
                            id v65 = _FBSceneActionToString(v10);
                            NSString *v1 = self->_logProem;
                            os_log_with_type(oslog, type, "[%{public}@] Scene action [%{public}@][%#04x] completed with success: %d", v1, v65, v6 + (v38 - (v38 << 16)), arg1);
                        }
                        [self _workspaceQueue_cancelWatchdogTimer:v58];
                        if (v37 != nil) {
                            v37(arg1, arg2);
                        }
                    };
                    if (!v23) {
                        [self _workspaceQueue_sendSceneUpdateToClient:arg1 settingsDiff:v2 transitionContext:v3 completion:v54];
                    } else {
                        [self _workspaceQueue_sendSceneCreateToClient:arg1 parameters:v23 transitionContext:v3 completion:v54];
                    }
                }
            }];
        }
        return;
    }
    FBSSceneEvent *v26 = [[FBSSceneEvent alloc] init];
    [v26 setSettingsDiff:v2];
    [v26 setTransitionContext:v3];
    [v26 setSource:1];
    __block bool v27 = false;
    if (!v23) {
        [self->_hostAgent scene:self reviewEvent:v26 withCompletion:^void(void (^arg1)(FBSSceneMessage *, NSError *)) {
            v27 = true;
            void *v68 = _Block_copy(arg1);
            v25 = v68;
        }];
    } else {
        [self->_hostAgent scene:self didInitializeWithEvent:v26 completion:^void(void) {
            v27 = true;
        }];
    }
    if (v27) {
        [self _workspaceQueue_incrementInFlightUpdatesForAction:v10 allowThrottling:allowCPUThrottling externallyManaged:isClientLifecycleExternallyManaged];
        if (v18 != v7) {
            [a1 _workspaceSceneLifecycleStateChanged:self];
        }
        v32 = (!v23) ? nil : FBAnalyticsLogHangTracerEvent(process, 2);
        v37 = ^void(bool arg1, NSError *arg2) {
            [self _workspaceQueue_decrementInFlightUpdatesForAction:v10 allowThrottling:allowCPUThrottling externallyManaged:isClientLifecycleExternallyManaged];
            if (v4 != nil) {
                v4(arg1, arg2);
            }
            if (v25 != 0) {
                if (!arg1) {
                    id v74 = [NSError sceneMessageErrorWithCode:2];
                    v25->field_16(v25, 0, v74);
                } else {
                    v25->field_16(v25, 0, 0);
                }
            }
            if (v32 != nil) {
                v32(arg1, arg2);
            }
        };
        if (!v10) {
            v37(YES, nil);
        } else {
            v38 = v6 * 0x80008001 >> 47;
            [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                uint8_t v78[48];
                if (!arg1) {
                    FBProcessExitContext *exitContext = [process exitContext];
                    id createError = [exitContext createError];
                    NSError *v83 = FBWorkspaceSceneErrorCreate(1, @"Scene update failed.", @"Client process exited.", createError);
                    v37(NO, v83);
                } else {
                    id v84 = [self _workspaceQueue_createWatchdogForProcess:process sceneAction:v10 settings:v1 transitionContext:v3];
                    os_log_type_t type = ((v10 == 1) ? !v84 : 0) == 1;
                    os_log_t v88 = FBLogProcessScene();
                    if (os_log_type_enabled(v88, type)) {
                        id v87 = _FBSceneActionToString(v10);
                        id _policyDesc = [v84 _policyDesc];
                        *(uint32_t *)&v78[0] = 0x8420502;
                        *(uint16_t *)&v78[12] = 2114;
                        *(uint64_t *)&v78[14] = v87;
                        *(uint16_t *)&v78[22] = 0x400;
                        *(uint32_t *)&v78[24] = v6 + (v38 - (v38 << 16));
                        *(uint16_t *)&v78[28] = 0x800;
                        *(uint64_t *)&v78[30] = process;
                        *(uint16_t *)&v78[38] = 2114;
                        *(uint64_t *)&v78[40] = (!_policyDesc) ? @"none" : _policyDesc;
                        _os_log_impl(&_mh_dylib_header, v88, type, "[%{public}@] Sending scene action [%{public}@][%#04x] to process %p (watchdog: %{public}@)", v78, 48);
                    }
                    void (^v80)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                        os_log_t oslog = FBLogProcessScene();
                        if (os_log_type_enabled(oslog, type)) {
                            id v91 = _FBSceneActionToString(v10);
                            NSString *v1 = self->_logProem;
                            os_log_with_type(oslog, type, "[%{public}@] Scene action [%{public}@][%#04x] completed with success: %d", v1, v91, v6 + (v38 - (v38 << 16)), arg1);
                        }
                        [self _workspaceQueue_cancelWatchdogTimer:v84];
                        if (v37 != nil) {
                            v37(arg1, arg2);
                        }
                    };
                    if (!v23) {
                        [self _workspaceQueue_sendSceneUpdateToClient:arg1 settingsDiff:v2 transitionContext:v3 completion:v80];
                    } else {
                        [self _workspaceQueue_sendSceneCreateToClient:arg1 parameters:v23 transitionContext:v3 completion:v80];
                    }
                }
            }];
        }
        return;
    }
    NSString *v44 = [NSString stringWithFormat:@"agent callout's completion was not called in scope : event=%@ agent=%@", v26, self->_hostAgent];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v40 = NSStringFromSelector(@selector(workspace:sendUpdatedSettings:withDiff:transitionContext:completion:));
        NSString *v41 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v40, v41, self, @"FBWorkspaceScene.m", 871, v44);
    }
    _bs_set_crash_log_message([v44 UTF8String]);
    __break(0);
}


FBWorkspaceScene *-[FBWorkspaceScene initWithConnection:host:settings:clientSettings:fromRemnant:](FBWorkspaceConnection *a1, id<FBSceneHost> a2, id a3, id a4, int a5)
{
    if (!a1) {
        NSString *v29 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"connection"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v30 = NSStringFromSelector(_cmd);
            NSString *v31 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v30, v31, self, @"FBWorkspaceScene.m", 103, v29);
        }
        _bs_set_crash_log_message([v29 UTF8String]);
        __break(0);
    }
    id definition = [a2 definition];
    if (![definition isValid]) {
        NSString *v33 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[definition isValid]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v34 = NSStringFromSelector(_cmd);
            NSString *v35 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v34, v35, self, @"FBWorkspaceScene.m", 105, v33);
        }
        _bs_set_crash_log_message([v33 UTF8String]);
        __break(0);
    }
    FBWorkspaceScene *v5 = [self init];
    if (v5 != nil) {
        v5->_host = a2;
        v5->_lock._os_unfair_lock_opaque = 0;
        v5->_lock_connection = a1;
        v5->_usesOutgoingConnection = [a1 isOutgoing];
        v5->_workspaceQueue = [a1 queue];
        v5->_definition = [definition copy];
        v5->_identity = [definition identity];
        v5->_lock_sceneCreatedBlocks = [[NSMutableArray alloc] init];
        v5->_reconnect = ((a5 & 1) == 0) ? [a3 isClientFuture] : YES;
        v5->_lock_settings = [a3 copy];
        v5->_lock_clientSettings = [a4 copy];
        v5->_logProem = [NSString stringWithFormat:@"%p:%@", v5, v5->_identity];
        v5->_isUISubclass = [a3 _uikitShimming_isUISubclass];
        FBSSceneSpecification *specification = [definition specification];
        Class hostAgentClass = [specification hostAgentClass];
        if (hostAgentClass != 0) {
            v5->_hostAgent = [[hostAgentClass alloc] init];
            v5->_agentSessions = [[NSMutableArray alloc] init];
            if ([v5->_hostAgent isKindOfClass:[FBSBasicSceneAgent class]]) {
                [v5->_hostAgent _configureWithScene:v5];
            }
        }
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *v14 = v5->_logProem;
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Initialized with connection: %p.", v14, a1);
        }
    }
    return v5;
}


void -[FBWorkspaceScene workspace:handleUpdatedClientSettings:transitionContext:fromConnection:](long a1, id a2, id a3, id a4)
{
    if (!self) {
        return;
    }
    [self->_workspaceQueue assertBarrierOnQueue];
    os_unfair_lock_lock(&self->_lock);
    FBWorkspaceConnection *v4 = self->_lock_connection;
    if (self->_lock_connection != a4) {
        os_unfair_lock_unlock(&self->_lock);
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            FBSSceneIdentity *v5 = self->_identity;
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Client settings update aborted due to connection mismatch : diff=%@ connection=%@ expected=%@", v5, a2, a4, v4);
        }
        return;
    }
    FBSSceneClientSettings *v18 = self->_lock_clientSettings;
    if (a2 != nil) {
        os_log_t oslog2 = FBLogProcessScene();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            FBSSceneIdentity *v7 = self->_identity;
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "[%{public}@] Client settings updated with diff: %@", v7, a2);
        }
        id v8 = [a2 settingsByApplyingToMutableCopyOfSettings:v18];
        FBSSceneClientSettings *v9 = [v8 copy];
        self->_lock_clientSettings = v9;
        v18 = v9;
    }
    os_unfair_lock_unlock(&self->_lock);
    if (!self->_hostAgent) {
        id<FBSceneHost> v19 = self->_host;
        [v19 clientToken:self didUpdateClientSettings:v18 withDiff:a2 transitionContext:a3];
        return;
    }
    FBSSceneEvent *v10 = [[FBSSceneEvent alloc] init];
    [v10 setClientSettingsDiff:a2];
    [v10 setTransitionContext:a3];
    [v10 setSource:2];
    __block bool v11 = false;
    [self->_hostAgent scene:self reviewEvent:v10 withCompletion:^void(void (^arg1)(FBSSceneMessage *, NSError *)) {
        void (^v0)(FBSSceneMessage *, NSError *) = arg1;
        v11 = true;
        if (v0 != nil) {
            [self->_workspaceQueue performAsync:^void(void) {
                v0(nil, nil);
            }];
        }
    }];
    if (v11) {
        id<FBSceneHost> v20 = self->_host;
        [v20 clientToken:self didUpdateClientSettings:v18 withDiff:a2 transitionContext:a3];
        return;
    }
    NSString *v17 = [NSString stringWithFormat:@"agent callout's completion was not called in scope : event=%@ agent=%@", v10, self->_hostAgent];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v14 = NSStringFromSelector(@selector(workspace:handleUpdatedClientSettings:transitionContext:fromConnection:));
        NSString *v15 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceScene.m", 1082, v17);
    }
    _bs_set_crash_log_message([v17 UTF8String]);
    __break(0);
}


void -[FBWorkspaceScene _workspaceQueue_sendSceneCreateToClient:parameters:transitionContext:completion:](id a1, id a2, id a3, id a4)
{
    long v1 = a2;
    if (!a1) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"client != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBWorkspaceScene.m", 239, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    void (^v5)(NSError *) = ^void(NSError *arg1) {
        id v20;
        NSString *v21;
        id v19 = arg1;
        if (!arg1) {
            v20 = nil;
        } else {
            if (![v19 isBSServiceConnectionError]) {
                v21 = nil;
            } else {
                v21 = ([v19 code] == 4) ? @"Client was unable to decode scene parameters" : nil;
            }
            v20 = FBWorkspaceSceneErrorCreate(2, (self->_reconnect) ? @"Scene reconnect failed" : @"Scene create failed", v21, v19);
            os_log_t oslog = FBLogProcessScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                id succinctDescription = [v20 succinctDescription];
                NSString *v1 = self->_logProem;
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Scene creation failed: %{public}@", v1, succinctDescription);
            }
        }
        os_unfair_lock_lock(&self->_lock);
        self->_lock_sceneCreatedBlocks = nil;
        os_unfair_lock_unlock(&self->_lock);
        NSMutableArray *v25 = self->_lock_sceneCreatedBlocks;
        for (id v15 in v25) {
            v15->field_16(v15, !v19, v20);
        }
        v19 = !v19;
        a4->field_16(a4, v19, v20);
    };
    os_log_t log = FBLogProcessScene();
    bool v7 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (self->_reconnect != 1) {
        if (v7) {
            NSString *v3 = self->_logProem;
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending scene create.", v3);
        }
        [a1 createSceneWithIdentity:self->_identity parameters:v1 transitionContext:a3 completion:v5];
    } else {
        if (v7) {
            NSString *v6 = self->_logProem;
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending scene reconnect.", v6);
        }
        [a1 reconnectSceneWithIdentity:self->_identity parameters:v1 transitionContext:a3 completion:v5];
    }
}


void -[FBWorkspaceScene _workspaceQueue_sendSceneUpdateToClient:settingsDiff:transitionContext:completion:](id a1, id a2, id a3, void (^a4)(bool, NSError *))
{
    void (^v3)(bool, NSError *) = a4;
    if (!a1) {
        NSString *v8 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"client != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v9 = NSStringFromSelector(_cmd);
            NSString *v10 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBWorkspaceScene.m", 273, v8);
        }
        _bs_set_crash_log_message([v8 UTF8String]);
        __break(0);
    }
    bool v7 = ([a2 _isSignifcant] & 1) != 0;
    if (!v7) {
        FBSSceneSpecification *specification = [self->_definition specification];
        long v6 = [specification _isSignificantTransitionContext:a3];
        v7 = v6 != 0;
    }
    if (v7) {
        [a1 sceneID:self->_identity updateWithSettingsDiff:a2 transitionContext:a3 completion:^void(NSError *arg1) {
            if (!arg1) {
                v3(YES, arg1);
                return;
            } else {
                v3(NO, arg1);
                return;
            }
        }];
    } else {
        v3(YES, nil);
    }
}


long -[FBWorkspaceScene _workspaceQueue_incrementInFlightUpdatesForAction:allowThrottling:externallyManaged:](int a1, int a2, int a3)
{
    if (!a1) {
        return [self _workspaceQueue_updateAssertion];
    }
    self->_queue_inFlightUpdateEvents = self->_queue_inFlightUpdateEvents + 1;
    long *v0 = (a2 != 0) ? &self->_queue_inFlightUpdateAllowsThrottling : &self->_queue_inFlightUpdateDisallowsThrottling;
    *(v0) = *(v0) + 1;
    if (a1 == 3) {
        self->_queue_inFlightDeactivationEvents = self->_queue_inFlightDeactivationEvents + 1;
    }
    if (a3 != 0) {
        self->_queue_inFlightExternallyManagedEvents = self->_queue_inFlightExternallyManagedEvents + 1;
    }
    return [self _workspaceQueue_updateAssertion];
}


int +[FBWorkspaceScene _sceneActionForLifecycleFromState:toState:](int a1, long a2)
{
    unsigned int v0 = 66307 >> (a2 & 31) * 8;
    if ((unsigned long)a2 >= 3) {
        v0 = 1;
    }
    unsigned int v1 = 131329 >> (a2 & 31) * 8;
    if ((unsigned long)a2 >= 3) {
        v1 = 1;
    }
    int v2 = (a2 != 2) ? 5 : 4;
    if (a1 != 0) {
        v2 = 1;
    }
    if (a1 != 1) {
        v1 = v2;
    }
    if (a1 != 2) {
        return v1 & 255;
    }
    return v0 & 255;
}


FBSSceneSettings *-[FBWorkspaceScene settings](void)
{
    os_unfair_lock_lock(&self->_lock);
    FBSSceneSettings *v0 = self->_lock_settings;
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


FBSSceneIdentity *-[FBWorkspaceScene identity](void)
{
    return self->_identity;
}


void -[FBWorkspaceScene _enqueueSceneCreateCompletionBlock:](void (^a1)(long, long))
{
    void (^v0)(long, long) = a1;
    if (self != nil) {
        if (!v0) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_enqueueSceneCreateCompletionBlock:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceScene.m", 224, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_sceneCreatedBlocks != nil) {
            id aBlock = [v0 copy];
            id v6 = _Block_copy(aBlock);
            [self->_lock_sceneCreatedBlocks addObject:v6];
            os_unfair_lock_unlock(&self->_lock);
        } else {
            bool v7 = self->_lock_invalidated;
            os_unfair_lock_unlock(&self->_lock);
            if (v7) {
                id v5 = FBWorkspaceSceneErrorCreate(2, @"Scene creation failed", @"scene was invalidated", 0);
                v0(!v7, v5);
            } else {
                v7 = !v7;
                v0(v7, nil);
            }
        }
    }
}


struct FBWorkspaceScene *-[FBWorkspaceScene _workspaceQueue_decrementInFlightUpdatesForAction:allowThrottling:externallyManaged:](int a1, int a2, int a3)
{
    if (!a1) {
        return self;
    }
    unsigned long v0 = self->_queue_inFlightUpdateEvents;
    if (!self->_queue_inFlightUpdateEvents) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_queue_inFlightUpdateEvents > 0"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBWorkspaceScene.m", 341, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    v0--;
    self->_queue_inFlightUpdateEvents = v0;
    if (a2 != 0) {
        if (!self->_queue_inFlightUpdateAllowsThrottling) {
            NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_queue_inFlightUpdateAllowsThrottling > 0"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v10 = NSStringFromSelector(_cmd);
                NSString *v11 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBWorkspaceScene.m", 344, v9);
            }
            _bs_set_crash_log_message([v9 UTF8String]);
            __break(0);
        }
        self->_queue_inFlightUpdateAllowsThrottling = self->_queue_inFlightUpdateAllowsThrottling - 1;
    } else {
        if (!self->_queue_inFlightUpdateDisallowsThrottling) {
            NSString *v13 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_queue_inFlightUpdateDisallowsThrottling > 0"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v14 = NSStringFromSelector(_cmd);
                NSString *v15 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceScene.m", 347, v13);
            }
            _bs_set_crash_log_message([v13 UTF8String]);
            __break(0);
        }
        self->_queue_inFlightUpdateDisallowsThrottling = self->_queue_inFlightUpdateDisallowsThrottling - 1;
    }
    if (a1 == 3) {
        self->_queue_inFlightDeactivationEvents = self->_queue_inFlightDeactivationEvents - 1;
    }
    if (a3 != 0) {
        if (!self->_queue_inFlightExternallyManagedEvents) {
            NSString *v17 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_queue_inFlightExternallyManagedEvents > 0"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v18 = NSStringFromSelector(_cmd);
                NSString *v19 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBWorkspaceScene.m", 354, v17);
            }
            _bs_set_crash_log_message([v17 UTF8String]);
            __break(0);
        }
        self->_queue_inFlightExternallyManagedEvents = self->_queue_inFlightExternallyManagedEvents - 1;
    }
    if (v0 != 0) {
        return self;
    }
    if (self->_queue_eventsCompleteSignal != nil) {
        [self->_queue_eventsCompleteSignal signal];
        self->_queue_eventsCompleteSignal = nil;
    }
    BSAtomicSignal *v3 = [BSAtomicSignal new];
    self->_queue_eventsCompleteSignal = v3;
    self = [self->_workspaceQueue performAfter:0.1 withBlock:^void(void) {
        if (self->_queue_inFlightUpdateEvents != 0) {
            return;
        }
        void *signal = [v3 signal];
        if (!signal) {
            return;
        }
        [signal->field_32 _workspaceQueue_updateAssertion];
    }];
    return self;
}


id -[FBWorkspaceScene succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_identity withName:0];
    os_unfair_lock_lock(&self->_lock);
    [v0 appendBool:self->_lock_invalidated withName:@"invalidated" ifEqualTo:1];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


void -[FBWorkspaceScene workspace:handleActions:forExtension:fromConnection:](long a1, NSDictionary *a2, long a3, id a4)
{
    id<FBSceneHost> v19;
    if (!self) {
        return;
    }
    [self->_workspaceQueue assertBarrierOnQueue];
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_connection != a4) {
        FBWorkspaceConnection *v4 = self->_lock_connection;
        os_unfair_lock_unlock(&self->_lock);
        os_log_t oslog = FBLogProcessScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            NSUInteger count = [a2 count];
            FBSSceneIdentity *v3 = self->_identity;
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Aborted %u action(s) due to connection mismatch : connection=%@ expected=%@", v3, count, a4, v4);
        }
        return;
    }
    os_unfair_lock_unlock(&self->_lock);
    os_log_t oslog2 = FBLogProcessScene();
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
        NSUInteger count2 = [a2 count];
        FBSSceneIdentity *v5 = self->_identity;
        os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "[%{public}@] Received %u action(s)", v5, count2);
    }
    if (a3 != 0 || !self->_hostAgent) {
        if ([a2 count] != 0) {
            v19 = self->_host;
            [v19 clientToken:self didReceiveActions:a2 forExtension:a3];
        }
        return;
    }
    FBSSceneSpecification *specification = [self->_definition specification];
    id transitionContextClass = [specification transitionContextClass];
    FBSSceneTransitionContext *transitionContext = [transitionContextClass transitionContext];
    [transitionContext setActions:a2];
    FBSSceneEvent *v13 = [[FBSSceneEvent alloc] init];
    [v13 setTransitionContext:transitionContext];
    [v13 setSource:2];
    __block bool v14 = false;
    [self->_hostAgent scene:self reviewEvent:v13 withCompletion:^void(void (^arg1)(FBSSceneMessage *, NSError *)) {
        void (^v0)(FBSSceneMessage *, NSError *) = arg1;
        v14 = true;
        if (v0 != nil) {
            [self->_workspaceQueue performAsync:^void(void) {
                v0(nil, nil);
            }];
        }
    }];
    if (v14) {
        id actions = [transitionContext actions];
        if ([actions count] != 0) {
            v19 = self->_host;
            [v19 clientToken:self didReceiveActions:actions forExtension:a3];
        }
        return;
    }
    NSString *v24 = [NSString stringWithFormat:@"agent callout's completion was not called in scope : event=%@ agent=%@", v13, self->_hostAgent];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v20 = NSStringFromSelector(@selector(workspace:handleActions:forExtension:fromConnection:));
        NSString *v21 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBWorkspaceScene.m", 1120, v24);
    }
    _bs_set_crash_log_message([v24 UTF8String]);
    __break(0);
}


id<FBSceneHost> -[FBWorkspaceScene host](void)
{
    return self->_host;
}


id -[FBWorkspaceScene succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


void -[FBWorkspaceScene dealloc](void)
{
    if (!self->_lock_invalidated) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_lock_invalidated == YES"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceScene.m", 137, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


void -[FBWorkspaceScene .cxx_destruct](void)
{
    self->_workspaceQueue = nil;
    self->_queue_eventsCompleteSignal = nil;
    self->_queue_watchdogStack = nil;
    self->_queue_allWatchdogs = nil;
    self->_queue_workspaceAssertion = nil;
    self->_lock_sceneCreatedBlocks = nil;
    self->_lock_clientSettings = nil;
    self->_lock_settings = nil;
    self->_agentSessions = nil;
    self->_hostAgent = nil;
    self->_logProem = nil;
    self->_identity = nil;
    self->_definition = nil;
    self->_host = nil;
    self->_lock_connection = nil;
}


void -[FBWorkspaceScene workspace:sendInvalidationWithTransitionContext:completion:](id a1, id a2, void (^a3)(bool, NSError *))
{
    id v0 = a2;
    void (^v1)(bool, NSError *) = a3;
    if (self != nil) {
        [self->_workspaceQueue assertBarrierOnQueue];
        long allowCPUThrottling = [v0 allowCPUThrottling];
        [self _workspaceQueue_incrementInFlightUpdatesForAction:3 allowThrottling:allowCPUThrottling externallyManaged:0];
        void (^v6)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
            [self _workspaceQueue_decrementInFlightUpdatesForAction:3 allowThrottling:allowCPUThrottling externallyManaged:0];
            if (v1 != nil) {
                v1(arg1, arg2);
            }
        };
        id process = [a1 process];
        [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
            if (!arg1) {
                FBProcessExitContext *exitContext = [process exitContext];
                id createError = [exitContext createError];
                NSError *v15 = FBWorkspaceSceneErrorCreate(1, @"Scene invalidation failed.", @"Client process exited.", createError);
                v6(NO, v15);
            } else {
                os_log_t oslog = FBLogProcessScene();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    NSString *v19 = self->_logProem;
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending scene destroy.", v19);
                }
                if (self->_hostAgent != nil) {
                    FBSSceneEvent *v18 = [[FBSSceneEvent alloc] init];
                    [v18 setTransitionContext:v0];
                    [v18 setSource:1];
                    [self _workspaceQueue_invalidateSceneAgentWithEvent:v18];
                }
                [arg1 sceneID:self->_identity destroyWithTransitionContext:v0 completion:^void(NSError *arg1) {
                    if (!arg1) {
                        v6(YES, arg1);
                        return;
                    } else {
                        v6(NO, arg1);
                        return;
                    }
                }];
            }
        }];
    }
}


void -[FBWorkspaceScene workspace:sendActions:toExtension:](long a1, NSDictionary *a2, Class a3)
{
    if (!self) {
        return;
    }
    [self->_workspaceQueue assertBarrierOnQueue];
    NSDictionary *v2 = a2;
    if (a3 != 0 || !self->_hostAgent) {
        if ([v2 count] != 0) {
            [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                if (arg1 != nil) {
                    [self _workspaceQueue_incrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                    BSAtomicSignal *v1 = [BSAtomicSignal new];
                    void (^v19)(void) = [^void(void) {
                        if (![v1 signal]) {
                            return;
                        }
                        [self _workspaceQueue_decrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                    } copy];
                    NSString *v20 = (!a3) ? nil : NSStringFromClass(a3);
                    [arg1 sceneID:self->_identity sendActions:v2 toExtension:v20 completion:^void(NSError *arg1) {
                        v19();
                    }];
                    id v21 = self;
                    [self->_workspaceQueue performAfter:5.0 withBlock:^void(void) {
                        if (([v1 hasBeenSignalled] & 1) == 0) {
                            os_log_t oslog = FBLogProcessScene();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                                id v2 = v21->_logProem;
                                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Send action timed out.", v2);
                            }
                        }
                        v19();
                    }];
                }
            }];
        }
        return;
    }
    FBSSceneSpecification *specification = [self->_definition specification];
    id transitionContextClass = [specification transitionContextClass];
    FBSSceneTransitionContext *transitionContext = [transitionContextClass transitionContext];
    [transitionContext setActions:v2];
    FBSSceneEvent *v6 = [[FBSSceneEvent alloc] init];
    [v6 setTransitionContext:transitionContext];
    [v6 setSource:1];
    __block bool v7 = false;
    [self->_hostAgent scene:self reviewEvent:v6 withCompletion:^void(void (^arg1)(FBSSceneMessage *, NSError *)) {
        void (^v0)(FBSSceneMessage *, NSError *) = arg1;
        v7 = true;
        if (v0 != nil) {
            [self->_workspaceQueue performAsync:^void(void) {
                NSError *v26 = [NSError sceneMessageErrorWithCode:1];
                v0(nil, v26);
            }];
        }
    }];
    if (v7) {
        id actions = [transitionContext actions];
        if ([actions count] != 0) {
            [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
                if (arg1 != nil) {
                    [self _workspaceQueue_incrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                    BSAtomicSignal *v1 = [BSAtomicSignal new];
                    void (^v27)(void) = [^void(void) {
                        if (![v1 signal]) {
                            return;
                        }
                        [self _workspaceQueue_decrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                    } copy];
                    NSString *v28 = (!a3) ? nil : NSStringFromClass(a3);
                    [arg1 sceneID:self->_identity sendActions:actions toExtension:v28 completion:^void(NSError *arg1) {
                        v27();
                    }];
                    id v29 = self;
                    [self->_workspaceQueue performAfter:5.0 withBlock:^void(void) {
                        if (([v1 hasBeenSignalled] & 1) == 0) {
                            os_log_t oslog = FBLogProcessScene();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                                id v2 = v29->_logProem;
                                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Send action timed out.", v2);
                            }
                        }
                        v27();
                    }];
                }
            }];
        }
        return;
    }
    NSString *v18 = [NSString stringWithFormat:@"agent callout's completion was not called in scope : event=%@ agent=%@", v6, self->_hostAgent];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v13 = NSStringFromSelector(@selector(workspace:sendActions:toExtension:));
        NSString *v14 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBWorkspaceScene.m", 990, v18);
    }
    _bs_set_crash_log_message([v18 UTF8String]);
    __break(0);
}


void -[FBWorkspaceScene invalidate](void)
{
    os_unfair_lock_lock(&self->_lock);
    if (self->_lock_invalidated) {
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    os_log_t oslog = FBLogProcessScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *v1 = self->_logProem;
        FBWorkspaceConnection *v2 = self->_lock_connection;
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Invalidated for connection: %p.", v1, v2);
    }
    self->_lock_connection = nil;
    self->_lock_invalidated = YES;
    NSMutableArray *v6 = self->_lock_sceneCreatedBlocks;
    self->_lock_sceneCreatedBlocks = nil;
    os_unfair_lock_unlock(&self->_lock);
    for (id v14 in v6) {
        id v15 = FBWorkspaceSceneErrorCreate(2, @"Scene creation failed", @"scene was invalidated", 0);
        v14->field_16(v14, 0, v15);
    }
    [self->_workspaceQueue performAsync:^void(void) {
        [self _workspaceQueue_invalidate];
    }];
}


long -[FBWorkspaceScene _workspaceQueue_invalidate](void)
{
    [self->_workspaceQueue assertBarrierOnQueue];
    for (id v1 in self->_queue_allWatchdogs) {
        [v1 invalidate];
    }
    self->_queue_allWatchdogs = nil;
    self->_queue_watchdogStack = nil;
    [self->_queue_workspaceAssertion invalidate];
    return [self _workspaceQueue_invalidateSceneAgentWithEvent:0];
}


void -[FBWorkspaceScene _workspaceQueue_invalidateSceneAgentWithEvent:](id a1)
{
    if (self->_hostAgent != nil) {
        if (!a1) {
            FBSSceneEvent *v2 = [[FBSSceneEvent alloc] init];
            [self->_hostAgent scene:self willInvalidateWithEvent:v2 completion:^void(void) {
            }];
        } else {
            [self->_hostAgent scene:self willInvalidateWithEvent:a1 completion:^void(void) {
            }];
        }
        for (id v1 in self->_agentSessions) {
            [v1 invalidate];
        }
        self->_hostAgent = nil;
        self->_agentSessions = nil;
    }
}


long -[FBWorkspaceScene description](void)
{
    return [self succinctDescription];
}


id -[FBWorkspaceScene _workspaceQueue_createWatchdogForProcess:sceneAction:settings:transitionContext:](id a1, int a2, id a3, id a4)
{
    long v8;
    [self->_workspaceQueue assertBarrierOnQueue];
    id watchdogTransitionContext = [a4 watchdogTransitionContext];
    if (!a1) {
        goto blk_1c4f243bc;
    }
    int pid = [a1 pid];
    long v7 = __getpid(pid);
    if (pid == v7 || ![a1 allowsTerminatingOnWatchdogViolations] || (v8 = [watchdogTransitionContext watchdogBehavior]) == 2) {
        goto blk_1c4f243bc;
    }
    if (v8 == 1) {
        goto blk_1c4f24318;
    }
    if (!v8) {
        long defaultWatchdogBehavior = [a3 defaultWatchdogBehavior];
        if (defaultWatchdogBehavior == 2) {
blk_1c4f243bc:
            return nil;
        }
        if (defaultWatchdogBehavior != 1) {
            if (defaultWatchdogBehavior != 0) {
                id v25 = NSStringFromFBSDefaultWatchdogBehavior(defaultWatchdogBehavior);
                id v26 = _FBSceneActionToString(a2);
                NSString *v27 = [NSString stringWithFormat:@"unknown sceneBehavior (%@) for action=%@ on %@", v25, v26, a1];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v0 = [NSString stringWithUTF8String:"BOOL _shouldRunWatchdog(FBProcess *__strong, _FBSceneAction, FBSSceneSettings *__strong, BOOL, FBWatchdogTransitionContext *__strong)"];
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v0, @"FBWorkspaceScene.m", 582, v27);
                }
                _bs_set_crash_log_message([v27 UTF8String]);
                __break(0);
            }
            if (!self->_isUISubclass) {
                goto blk_1c4f243bc;
            }
            if ((unsigned int)a2 <= 1 && [a3 isForeground]) {
                return nil;
            }
        }
blk_1c4f24318:
        id v11 = [FBProcessWatchdogEventContext contextForEvent:((a2 & 254) != 4) ? 3 : 2 settings:a3 transitionContext:a4];
        id v13 = [a1 _newWatchdogForContext:v11 completion:^void(FBProcessWatchdog *arg1) {
            void *v31 = self;
            [self->_workspaceQueue performAsync:^void(void) {
                [v31 _workspaceQueue_cancelWatchdogTimer:arg1];
            }];
        }];
        if (!v13) {
            return v13;
        }
        NSMutableSet *v14 = self->_queue_allWatchdogs;
        if (!self->_queue_allWatchdogs) {
            self->_queue_allWatchdogs = [NSMutableSet setWithObject:v13];
        } else {
            [v14 addObject:v13];
        }
        if ([watchdogTransitionContext runIndependently]) {
blk_1c4f2447c:
            [v13 activate];
            return v13;
        }
        if (!self->_queue_watchdogStack) {
            self->_queue_watchdogStack = [NSMutableArray arrayWithObject:v13];
        } else {
            [self->_queue_watchdogStack addObject:v13];
        }
        if ([self->_queue_watchdogStack count] == 1) {
            goto blk_1c4f2447c;
        } else {
            return v13;
        }
    }
    id v22 = NSStringFromFBWatchdogBehavior(v8);
    id v23 = _FBSceneActionToString(a2);
    NSString *v24 = [NSString stringWithFormat:@"unknown transitionBehavior (%@) for action=%@ on %@", v22, v23, a1];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v29 = [NSString stringWithUTF8String:"BOOL _shouldRunWatchdog(FBProcess *__strong, _FBSceneAction, FBSSceneSettings *__strong, BOOL, FBWatchdogTransitionContext *__strong)"];
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v29, @"FBWorkspaceScene.m", 590, v24);
    }
    _bs_set_crash_log_message([v24 UTF8String]);
    __break(0);
}


void -[FBWorkspaceScene _workspaceQueue_cancelWatchdogTimer:](id a1)
{
    [self->_workspaceQueue assertBarrierOnQueue];
    if (a1 != nil) {
        if ([self->_queue_allWatchdogs containsObject:a1]) {
            NSUInteger v1 = [self->_queue_watchdogStack indexOfObjectIdenticalTo:a1];
            if (v1 != NSNotFound) {
                [self->_queue_watchdogStack removeObjectAtIndex:v1];
                if (![self->_queue_watchdogStack count]) {
                    self->_queue_watchdogStack = nil;
                } else if (!v1) {
                    id firstObject = [self->_queue_watchdogStack firstObject];
                    [firstObject activate];
                }
            }
            [self->_queue_allWatchdogs removeObject:a1];
            if (![self->_queue_allWatchdogs count]) {
                self->_queue_allWatchdogs = nil;
                self->_queue_watchdogStack = nil;
            }
        }
        [a1 invalidate];
    }
}


id -[FBWorkspaceScene descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBWorkspaceScene descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
        id<FBSSceneHostAgent> v5 = self->_hostAgent;
        if (!self->_hostAgent) {
            [succinctDescriptionBuilder appendObject:@"(none)" withName:@"agent"];
        } else {
            id v6 = [BSDescriptionBuilder succinctDescriptionForObject:v5];
            [succinctDescriptionBuilder appendObject:v6 withName:@"agent"];
        }
        FBProcess *clientProcess = [self clientProcess];
        id v4 = [BSDescriptionBuilder succinctDescriptionForObject:clientProcess];
        [succinctDescriptionBuilder appendObject:v4 withName:@"clientProcess"];
        [succinctDescriptionBuilder appendArraySection:self->_agentSessions withName:@"agentSessions" skipIfEmpty:1];
    }];
    return succinctDescriptionBuilder;
}


long -[FBWorkspaceScene debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBWorkspaceScene identifier](void)
{
    return [self->_identity identifier];
}


FBSSceneDefinition *-[FBWorkspaceScene definition](void)
{
    return self->_definition;
}


FBSMutableSceneParameters *-[FBWorkspaceScene parameters](void)
{
    FBSMutableSceneParameters *v2 = [[FBSMutableSceneParameters alloc] initWithSpecification:[self->_definition specification]];
    os_unfair_lock_lock(&self->_lock);
    [v2 setSettings:self->_lock_settings];
    [v2 setClientSettings:self->_lock_clientSettings];
    os_unfair_lock_unlock(&self->_lock);
    return v2;
}


FBSSceneSpecification *-[FBWorkspaceScene specification](void)
{
    return [self->_definition specification];
}


BSServiceDispatchQueue *-[FBWorkspaceScene callOutQueue](void)
{
    return self->_workspaceQueue;
}


long -[FBWorkspaceScene counterpartAgent](void)
{
    return 0;
}


id -[FBWorkspaceScene hostProcess](void)
{
    id<FBSceneHost> v0 = self->_host;
    return [v0 hostProcess];
}


id -[FBWorkspaceScene clientProcess](void)
{
    os_unfair_lock_lock(&self->_lock);
    FBWorkspaceConnection *v0 = self->_lock_connection;
    os_unfair_lock_unlock(&self->_lock);
    return [v0 remoteProcess];
}


FBSSceneActivitySession *-[FBWorkspaceScene openSessionWithName:executionPolicy:](id a1, id a2)
{
    [self->_workspaceQueue assertBarrierOnQueue];
    FBSSceneActivitySession *v2 = [[FBSSceneActivitySession alloc] initWithName:a1 scene:self executionPolicy:a2];
    if (v2 != nil) {
        [self->_agentSessions addObject:v2];
    }
    [v2 open];
    return v2;
}


void -[FBWorkspaceScene closeSession:](id a1)
{
    [self->_workspaceQueue assertBarrierOnQueue];
    if (a1 != nil && [self->_agentSessions containsObject:a1]) {
        [a1 close];
        [a1 invalidate];
        [self->_agentSessions removeObject:a1];
    }
}


void -[FBWorkspaceScene agent:registerMessageHandler:](long a1, long a2)
{
    os_log_t oslog = FBLogProcessScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = self->_logProem;
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Agent message handlers are no longer supported.", v2);
    }
}


void -[FBWorkspaceScene agent:sendMessage:withResponse:](long a1, long a2, void (^a3)(long, long))
{
    os_log_t oslog = FBLogProcessScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v1 = self->_logProem;
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Agent messages are no longer supported.", v1);
    }
    if (a3 != nil) {
        id v2 = [NSError sceneMessageErrorWithCode:2];
        a3(0, v2);
    }
}


bool -[FBWorkspaceScene usesOutgoingConnection](void)
{
    return self->_usesOutgoingConnection;
}


void -[FBWorkspaceScene workspace:sendInvocation:withReply:](id a1, void (^a2)(FBSInvocationReply *, NSError *), long a3)
{
    id v0 = a1;
    void (^v1)(FBSInvocationReply *, NSError *) = a2;
    if (self != nil) {
        [self _workspaceQueue_sendMessageToClient:^void(id<FBSWorkspaceServiceServerInterface> arg1) {
            if (!arg1) {
                NSError *v13 = [NSError sceneMessageErrorWithCode:2];
                v1(nil, v13);
            } else {
                [self _workspaceQueue_incrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                BSAtomicSignal *v3 = [BSAtomicSignal new];
                BSAtomicSignal *v6 = v3;
                void (^v7)(void) = [^void(void) {
                    if (![v3 signal]) {
                        return;
                    }
                    [self _workspaceQueue_decrementInFlightUpdatesForAction:1 allowThrottling:0 externallyManaged:0];
                } copy];
                void (^v9)(void) = v7;
                [arg1 sceneID:self->_identity handleInvocation:v0 completion:^void(FBSInvocationReply *arg1, NSError *arg2) {
                    v7();
                    v1(arg1, arg2);
                }];
                id v10 = self;
                [self->_workspaceQueue performAfter:5.0 withBlock:^void(void) {
                    if (([v6 hasBeenSignalled] & 1) == 0) {
                        os_log_t oslog = FBLogProcessScene();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                            id v1 = v10->_logProem;
                            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Send invocations timed out.", v1);
                        }
                    }
                    v9();
                }];
            }
        }];
    }
}


void -[FBWorkspaceScene workspace:handleInvocation:fromConnection:withReply:](long a1, id a2, id a3, id a4)
{
    if (self != 0) {
        [self->_workspaceQueue assertBarrierOnQueue];
        os_unfair_lock_lock(&self->_lock);
        if (self->_lock_connection == a3) {
            os_unfair_lock_unlock(&self->_lock);
            id<FBSceneHost> v4 = self->_host;
            [v4 clientToken:self handleInvocation:a2 withReply:a4];
        } else {
            FBWorkspaceConnection *v5 = self->_lock_connection;
            os_unfair_lock_unlock(&self->_lock);
            os_log_t oslog = FBLogProcessScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                FBSSceneIdentity *v3 = self->_identity;
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Aborted invocation due to connection mismatch : connection=%@ expected=%@", v3, a3, v5);
            }
        }
    }
}
