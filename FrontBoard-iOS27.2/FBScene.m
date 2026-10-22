struct FBScene {
    struct os_unfair_lock_s _lock; // +0x8
    FBSceneLayerManager *_layerManager; // +0x10
    FBSceneObserver *_delegateProxy; // +0x18
    NSMutableOrderedSet *_lock_observerProxies; // +0x20
    id<BSInvalidatable> _stateCaptureAssertion; // +0x28
    FBSceneEventQueue *_eventQueue; // +0x30
    id<NSObject> _clientToken; // +0x38
    id<FBSceneClient> _client; // +0x40
    FBProcess *_clientProcess; // +0x48
    NSString *_identifier; // +0x50
    NSString *_workspaceIdentifier; // +0x58
    FBSSceneIdentityToken *_identityToken; // +0x60
    FBSSceneSettings *_settings; // +0x68
    FBSSceneClientSettings *_clientSettings; // +0x70
    FBSSceneDefinition *_definition; // +0x78
    FBSceneRemnant *_remnant; // +0x80
    FBSSceneSettings *_settingsAtDeactivation; // +0x88
    NSMapTable *_components; // +0x90
    NSMutableArray *_orderedComponents; // +0x98
    __weak FBSScene *_parentScene; // +0xa0
    FBSSceneUpdate *_settingsUpdate; // +0xa8
    id _updateCompletion; // +0xb0
    id<BSInvalidatable> _updateSuspendIdleWork; // +0xb8
    unsigned long _activationID; // +0xc0
    unsigned long _transactionID; // +0xc8
    unsigned long _lastForegroundingTransitionID; // +0xd0
    unsigned char _updateDepth; // +0xd8
    bool _contentStateIsChanging; // +0xd9
    bool _legacy; // +0xda
    bool _active; // +0xdb
    bool _deactivating; // +0xdc
    bool _invalidated; // +0xdd
    bool _legacyActivated; // +0xde
    bool _midUpdate; // +0xdf
    bool _finishedInit; // +0xe0
    bool _newlyReparented; // +0xe1
    bool _updateShouldActivate; // +0xe2
    bool _componentInit; // +0xe3
    bool _configuringParameters; // +0xe4
    bool _updatePendingFinalize; // +0xe5
    bool _inTransaction; // +0xe6
    FBSceneClientHandle *_clientHandle; // +0xe8
    long _contentState; // +0xf0
    FBSceneWorkspace *_workspace; // +0xf8
};

static long FBSceneErrorDomain;

FBSSceneSettings *-[FBScene settings](void)
{
    FBSSceneSettings *v1 = [self->_settingsUpdate settings];
    if (!v1) {
        v1 = self->_settings;
    }
    return v1;
}


int -[FBScene isValid](void)
{
    return 1 & ~self->_invalidated;
}


void -[FBScene(UIApp) updateUISettingsWithTransitionBlock:](id a1)
{
    long v2;
    id v0 = a1;
    if (a1 != nil) {
        [self updateSettingsWithTransitionBlock:^FBSSceneTransitionContext *(FBSMutableSceneSettings *arg1) {
            if (([arg1 _uikitShimming_isUISubclass] & 1) == 0) {
                NSString *v5 = [NSString stringWithFormat:@"settings is of an unexpected class : %@", arg1];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v6 = NSStringFromSelector(v2);
                    NSString *v3 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v3, self, @"FBScene+UIApp.m", 45, v5);
                }
                _bs_set_crash_log_message([v5 UTF8String]);
                __break(0);
            }
            FBSSceneTransitionContext *v9 = v0->field_16(v0, arg1);
            return v9;
        }];
    }
}


FBSSceneSettings *-[FBScene(UIApp) uiSettings](void)
{
    FBSSceneSettings *settings = [self settings];
    if (([settings _uikitShimming_isUISubclass] & 1) == 0) {
        NSString *v1 = [NSString stringWithFormat:@"settings is of an unexpected class : %@", settings];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene+UIApp.m", 23, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    return settings;
}


void -[FBScene updateSettingsWithTransitionBlock:](FBSSceneTransitionContext *(^a1)(FBSMutableSceneSettings *))
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"settingsUpdateBlock"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBScene.m", 516, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    FBSSceneSettings *settings = [self settings];
    FBSMutableSceneSettings *v2 = [settings mutableCopy];
    FBSSceneTransitionContext *v3 = a1(v2);
    [self updateSettings:v2 withTransitionContext:v3 completion:0];
}


NSString *-[FBScene identifier](void)
{
    return self->_identifier;
}


void -[FBScene updateSettings:withTransitionContext:completion:](long a1, id a2, void (^a3)(bool))
{
    void (^v3)(bool, NSError *);
    void (^v1)(bool) = a3;
    id v2 = [self _verifyIntegrityOfExtensionsInSettings:a1];
    if (v1) {
        v3 = ^void(bool arg1, NSError *arg2) {
            v1(arg1);
        };
    } else {
        v3 = 0;
    }
    v3 = _Block_copy(v3);
    if (!a2 || [a2 _indirect_isEmpty] != 0) {
        FBSSceneSettings *settings = [self settings];
        id v7 = [FBSSettingsDiff diffFromSettings:settings toSettings:v2];
        [self _joinUpdate:0 block:^void(FBSMutableSceneSettings *arg1, FBSSceneTransitionContext *arg2) {
            [v7 applyToMutableSettings:arg1];
        } completion:v3];
    } else {
        FBSSceneUpdate *_beginUpdate = [self _beginUpdate];
        _beginUpdate->_settings = v2;
        _beginUpdate->_context = a2;
        [self _joinUpdate:0 block:nil completion:v3];
    }
}


id -[FBScene _verifyIntegrityOfExtensionsInSettings:](id a1)
{
    if (!self) {
        return nil;
    }
    id _progenitor = [a1 _progenitor];
    if (_progenitor != self->_settings) {
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id loggingIdentifier2 = [self loggingIdentifier];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] updated settings were not derived from the scene's previous settings", loggingIdentifier2);
        }
    }
    id v1 = a1;
    FBSSceneSettings *settings = [self settings];
    id _allSceneExtensions = [settings _allSceneExtensions];
    id _allSceneExtensions2 = [v1 _allSceneExtensions];
    if ((BSEqualObjects(_allSceneExtensions, _allSceneExtensions2) & 1) == 0) {
        os_log_t oslog2 = FBLogScene();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
            id loggingIdentifier = [self loggingIdentifier];
            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "[%{public}@] Extension mismatch in new scene settings", loggingIdentifier);
        }
        long v12 = [v1 copy:^void(FBSSettings<FBSMutableSettings> *arg1) {
            [arg1 _removeAllSceneExtensions];
            for (id v14 in _allSceneExtensions) {
                [arg1 _addSceneExtension:v14 applyingSettings:settings];
            }
        }];
        v1 = v12;
    }
    return v1;
}


void -[FBScene _joinUpdate:block:completion:](int a1, void (^a2)(FBSMutableSceneSettings *, FBSSceneTransitionContext *), void (^a3)(bool, NSError *))
{
    void (^v1)(bool, NSError *) = a3;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _joinUpdate:block:completion:]");
        }
        bool v3 = (!self->_active) ? self->_updateShouldActivate : true;
        if (self->_updateDepth >= 16) {
            NSString *v51 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_updateDepth < 16"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_joinUpdate:block:completion:));
                NSString *v52 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v52, self, @"FBScene.m", 933, v51);
            }
            _bs_set_crash_log_message([v51 UTF8String]);
            __break(0);
        }
        if (((v3 | ~a1) & 1) == 0) {
            if (!self->_finishedInit) {
                NSString *v54 = [NSString stringWithFormat:@"cannot activate a scene during init"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v55 = NSStringFromSelector(@selector(_joinUpdate:block:completion:));
                    NSString *v56 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v55, v56, self, @"FBScene.m", 934, v54);
                }
                _bs_set_crash_log_message([v54 UTF8String]);
                __break(0);
            }
            if (self->_componentInit == 1) {
                NSString *v58 = [NSString stringWithFormat:@"cannot activate a scene during component init"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v59 = NSStringFromSelector(@selector(_joinUpdate:block:completion:));
                    NSString *v60 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v59, v60, self, @"FBScene.m", 935, v58);
                }
                _bs_set_crash_log_message([v58 UTF8String]);
                __break(0);
            }
        }
        if (self->_configuringParameters == 1) {
            NSString *v62 = [NSString stringWithFormat:@"re-entrant mutation during configureParameters is not supported"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v63 = NSStringFromSelector(@selector(_joinUpdate:block:completion:));
                NSString *v64 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v63, v64, self, @"FBScene.m", 936, v62);
            }
            _bs_set_crash_log_message([v62 UTF8String]);
            __break(0);
        }
        FBSSceneUpdate *v4 = self->_settingsUpdate;
        if (!self->_settingsUpdate) {
            v4 = [self _beginUpdate];
        }
        v3 |= a1;
        if (v3 && !self->_settingsUpdate->_context) {
            id _createTransitionContext = [self _createTransitionContext];
            long *v7 = &v4->_context;
            *(v7) = _createTransitionContext;
        }
        if (v1 != nil) {
            if (!self->_updateCompletion) {
                self->_updateCompletion = [v1 copy];
            } else {
                void (^v12)(bool, NSError *) = _Block_copy(self->_updateCompletion);
                self->_updateCompletion = ^void(bool arg1, NSError *arg2) {
                    v1(arg1, arg2);
                    v12(arg1, arg2);
                };
            }
        }
        int v16 = self->_updateDepth;
        self->_updateDepth = v16 + 1;
        if (a2 != nil) {
            FBSMutableSceneSettings *v18 = v4->_mutableSettings;
            if (!v18) {
                v18 = [v4->_settings mutableCopy];
                v4->_mutableSettings = v18;
            }
            a2(v18, v4->_context);
            if (![v4->_settings isEqual:v18]) {
                id v21 = [v18 copy];
                long *v22 = &v4->_settings;
                *(v22) = v21;
                NSOrderedSet *_allSceneExtensions = [v4->_settings _allSceneExtensions];
                NSOrderedSet *_allSceneExtensions2 = [v18 _allSceneExtensions];
                if (![_allSceneExtensions2 isEqualToOrderedSet:_allSceneExtensions]) {
                    id v26 = [_allSceneExtensions2 mutableCopy];
                    [v26 minusOrderedSet:_allSceneExtensions];
                    id v27 = [_allSceneExtensions mutableCopy];
                    [v27 minusOrderedSet:_allSceneExtensions2];
                    [self _addExtensions:v26 removeExtensions:v27 settings:v18];
                    if (![v4->_settings isEqual:v18]) {
                        id v28 = [v18 copy];
                        long *v29 = &v4->_settings;
                        *(v29) = v28;
                    }
                    v3 = (uint32_t)v3;
                }
                FBSScene *v31 = self->_parentScene;
                if (v31) {
                    id propagatedSettings = [v4->_settings propagatedSettings];
                    NSSet *propagatedSettings2 = [v18 propagatedSettings];
                    if (![propagatedSettings isEqualToSet:propagatedSettings2]) {
                        FBSSceneSettings *settings = [v31 settings];
                        FBSSceneSettings *settings2 = [v4 settings];
                        id _propagatedSettings = [settings2 _propagatedSettings];
                        id v38 = [_propagatedSettings mutableCopy];
                        id previousSettings = [v4 previousSettings];
                        NSSet *_propagatedSettings2 = [previousSettings _propagatedSettings];
                        [v38 minusSet:_propagatedSettings2];
                        id v41 = [FBSSettingsDiff diffFromSettings:0 toSettings:settings];
                        NSSet *_changedSettings = [v41 _changedSettings];
                        [v38 intersectSet:_changedSettings];
                        if ([v38 count]) {
                            [self _propagateSettings:v38 fromSettings:settings toSettings:v18];
                            if (![v4->_settings isEqual:v18]) {
                                os_log_t oslog = FBLogScene();
                                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
                                    id loggingIdentifier = [self loggingIdentifier];
                                    id v45 = [FBSSettingsDiff diffFromSettings:v4->_settings toSettings:v18];
                                    os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "[%@] propagation mutated settings: %@", loggingIdentifier, v45);
                                }
                                id v47 = [v18 copy];
                                long *v48 = &v4->_settings;
                                *(v48) = v47;
                            }
                        }
                    }
                }
            }
            v16 = self->_updateDepth - 1;
        }
        self->_updateDepth = v16;
        v3 = (!v3) ? self->_updateShouldActivate : true;
        self->_updateShouldActivate = v3;
        if ((v16 & 255) == 0 && !self->_updatePendingFinalize) {
            self->_updatePendingFinalize = YES;
            if (self->_inTransaction != 1) {
                [self _finalizeSettingsUpdate];
            } else {
                [self->_eventQueue executeOrAppend:^void(void) {
                    [self _finalizeSettingsUpdate];
                }];
            }
        }
    }
}


FBSSceneUpdate *-[FBScene _beginUpdate](void)
{
    FBSSceneUpdate *v18 = nil;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _beginUpdate]");
        }
        if (self->_midUpdate == 1) {
            NSString *v5 = [NSString stringWithFormat:@"cannot re-entrantly begin a new scene update"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_beginUpdate));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene.m", 915, v5);
            }
            _bs_set_crash_log_message([v5 UTF8String]);
            __break(0);
        }
        if (self->_deactivating == 1) {
            NSString *v6 = [NSString stringWithFormat:@"cannot update a scene while it is deactivating"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v7 = NSStringFromSelector(@selector(_beginUpdate));
                NSString *v8 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBScene.m", 916, v6);
            }
            _bs_set_crash_log_message([v6 UTF8String]);
            __break(0);
        }
        if (self->_settingsUpdate != nil) {
            NSString *v10 = [NSString stringWithFormat:@"cannot begin a new update while one is ongoing"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v11 = NSStringFromSelector(@selector(_beginUpdate));
                NSString *v12 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBScene.m", 917, v10);
            }
            _bs_set_crash_log_message([v10 UTF8String]);
            __break(0);
        }
        self->_midUpdate = YES;
        self->_updateSuspendIdleWork = [FBSceneEventQueue suspendIdleWorkForReason:@"sceneUpdate"];
        FBSSceneUpdate *v15 = [FBSSceneUpdate new];
        FBSSceneUpdate *v1 = v15;
        self->_settingsUpdate = v15;
        v15->_settings = self->_settings;
        id v17 = *((!self->_transactionID) ? &self->_settingsAtDeactivation : &v15->_settings);
        v15 = &v15->_previousSettings;
        v15->_previousSettings = v17;
        v18 = v1;
    }
    return v18;
}


void -[FBScene _finalizeSettingsUpdate](void)
{
    if (!self) {
        return;
    }
    if (self->_updateShouldActivate != 1 || self->_active || self->_legacy || self->_invalidated == 1) {
        [self _applySettingsUpdateWithCompletion:self->_updateCompletion];
        return;
    }
    id v3 = self->_settingsUpdate->_context;
    id v4 = _Block_copy(self->_updateCompletion);
    long *v5 = &self->_settingsUpdate->_context;
    *(v5) = 0;
    [self _applySettingsUpdateWithCompletion:0];
    [self activateWithTransitionContext:v3 completion:v4];
}


void -[FBScene _applySettingsUpdateWithCompletion:](void (^a1)(bool, NSError *))
{
    id v4;
    FBSSceneSettings *v15;
    void (^v0)(bool, NSError *) = a1;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _applySettingsUpdateWithCompletion:]");
        }
        if (self->_inTransaction == 1) {
            id loggingIdentifier = [self loggingIdentifier];
            NSString *v2 = [NSString stringWithFormat:@"re-entrant scene mutation is not supported (%@)", loggingIdentifier];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v3 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                NSString *v125 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v125, self, @"FBScene.m", 1302, v2);
            }
            _bs_set_crash_log_message([v2 UTF8String]);
            __break(0);
        }
        if (!self->_midUpdate) {
            NSString *v126 = [NSString stringWithFormat:@"cannot finish an update when we are not in an update"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v127 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                NSString *v128 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v127, v128, self, @"FBScene.m", 1303, v126);
            }
            _bs_set_crash_log_message([v126 UTF8String]);
            __break(0);
        }
        if (!self->_settingsUpdate) {
            NSString *v130 = [NSString stringWithFormat:@"no active settings update"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v131 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                NSString *v132 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v131, v132, self, @"FBScene.m", 1304, v130);
            }
            _bs_set_crash_log_message([v130 UTF8String]);
            __break(0);
        }
        if (self->_configuringParameters == 1) {
            NSString *v134 = [NSString stringWithFormat:@"re-entrant mutation during configureParameters is not supported"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v135 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                NSString *v136 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v135, v136, self, @"FBScene.m", 1305, v134);
            }
            _bs_set_crash_log_message([v134 UTF8String]);
            __break(0);
        }
        if (!self->_updatePendingFinalize) {
            NSString *v138 = [NSString stringWithFormat:@"cannot apply another update while the previous one is pending"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v139 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                NSString *v140 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v139, v140, self, @"FBScene.m", 1306, v138);
            }
            _bs_set_crash_log_message([v138 UTF8String]);
            __break(0);
        }
        if (self->_invalidated != 1) {
            v4 = self->_settingsUpdate;
            id parentUpdate = [v4->_context parentUpdate];
            long *v7 = &v4->_instigatingUpdate;
            *(v7) = parentUpdate;
            if (self->_active != 1) {
                if (self->_finishedInit == 1 && self->_legacy == 1) {
                    NSString *v142 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"!_legacy"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v143 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                        NSString *v144 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v143, v144, self, @"FBScene.m", 1542, v142);
                    }
                    _bs_set_crash_log_message([v142 UTF8String]);
                    __break(0);
                }
                FBSSceneSpecification *specification = [self->_definition specification];
                FBSSceneTransitionContext *transitionContext = [v4 transitionContext];
                long v11 = [specification _isSignificantTransitionContext:transitionContext];
                if (v11 != 0) {
                    NSString *v146 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"![[_definition specification] _isSignificantTransitionContext:[update transitionContext]]"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v147 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                        NSString *v148 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v147, v148, self, @"FBScene.m", 1544, v146);
                    }
                    _bs_set_crash_log_message([v146 UTF8String]);
                    __break(0);
                }
                if (v0 != nil) {
                    NSString *v150 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"completion == nil"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v151 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                        NSString *v152 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v151, v152, self, @"FBScene.m", 1545, v150);
                    }
                    _bs_set_crash_log_message([v150 UTF8String]);
                    __break(0);
                }
                FBSSceneSettings *settings2 = [v4 settings];
                v15 = [settings2 _copyClearingProgenitor:0];
                long *v16 = &v4->_mutableSettings;
                *(v16) = 0;
                v4->_previousSettings = self->_settings;
                id v18 = [FBSSettingsDiff diffFromSettings:self->_settings toSettings:v15];
                long *v20 = &v4->_diff;
                *(v20) = v18;
                self->_settings = v15;
                v4->_settings = v15;
                long *v22 = &v4->_context;
                *(v22) = 0;
                [self _resetUpdateState];
                if (v4->_diff != 0) {
                    [self _iterateObservers:^void(FBSceneObserver *arg1) {
                        if ([arg1 receiverWantsInactiveUpdates] != 0) {
                            [arg1 scene:self didUpdateSettings:v4];
                        }
                    }];
                }
            } else {
                if (!self->_workspace) {
                    NSString *v154 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_workspace != nil"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v155 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                        NSString *v156 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v155, v156, self, @"FBScene.m", 1326, v154);
                    }
                    _bs_set_crash_log_message([v154 UTF8String]);
                    __break(0);
                }
                if (v4->_mutableSettings != 0) {
                    if (![v4->_mutableSettings isEqual:v4->_settings]) {
                        NSString *v158 = [NSString stringWithFormat:@"mutable and non-mutable settings must be equal"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v159 = NSStringFromSelector(@selector(_applySettingsUpdateWithCompletion:));
                            NSString *v160 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v159, v160, self, @"FBScene.m", 1331, v158);
                        }
                        _bs_set_crash_log_message([v158 UTF8String]);
                        __break(0);
                    }
                } else {
                    id v12 = v4->_settings;
                    id v162 = [v12 mutableCopy];
                    long *v163 = &v4->_mutableSettings;
                    *(v163) = v162;
                }
                id v29 = [FBSSettingsDiff diffFromSettings:v4->_previousSettings toSettings:v4->_settings];
                long *v30 = &v4->_diff;
                *(v30) = v29;
                id _allComponentProxies = [self _allComponentProxies];
                for (id v40 in _allComponentProxies) {
                    if ([v40 receiverImplementsWillUpdate] != 0) {
                        FBSSceneSettings *settings3 = [v4 settings];
                        [v40 scene:self willUpdateSettings:v4];
                        if (![settings3 isEqual:v4->_mutableSettings]) {
                            os_log_t oslog4 = FBLogScene();
                            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEBUG)) {
                                id loggingIdentifier4 = [self loggingIdentifier];
                                id component = [v40 component];
                                id v52 = [BSDescriptionBuilder succinctDescriptionForObject:component];
                                id v53 = [FBSSettingsDiff diffFromSettings:settings3 toSettings:v4->_mutableSettings];
                                os_log_with_type(oslog4, OS_LOG_TYPE_DEBUG, "[%@] component %@ mutated settings: %@", loggingIdentifier4, v52, v53);
                            }
                            id v43 = [v4->_mutableSettings copy];
                            long *v44 = &v4->_settings;
                            *(v44) = v43;
                            id v46 = [FBSSettingsDiff diffFromSettings:v4->_previousSettings toSettings:v4->_settings];
                            long *v47 = &v4->_diff;
                            *(v47) = v46;
                        }
                    }
                }
                self->_settingsUpdate = nil;
                id loggingIdentifier2 = [self loggingIdentifier];
                unsigned long _beginTransaction = [self _beginTransaction];
                bool v59 = _beginTransaction == 1;
                id v62 = [v4->_context copy];
                if (!v62) {
                    v62 = [self _createTransitionContext];
                }
                v4->_context = v62;
                v15 = v4->_context;
                FBSSceneSettings *settings4 = [v4 settings];
                id mutableSettings = [v4 mutableSettings];
                if ([self->_workspace scene:self willUpdateSettings:v4] != 0 && ![v4->_settings isEqual:mutableSettings]) {
                    id<FBSceneWorkspaceDelegate> delegate = [self->_workspace delegate];
                    os_log_t oslog5 = FBLogScene();
                    if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEBUG)) {
                        id v67 = [BSDescriptionBuilder succinctDescriptionForObject:delegate];
                        id v68 = [FBSSettingsDiff diffFromSettings:v4->_settings toSettings:mutableSettings];
                        os_log_with_type(oslog5, OS_LOG_TYPE_DEBUG, "[%@] workspace delegate %@ mutated settings: %@", loggingIdentifier2, v67, v68);
                    }
                    long v70 = [mutableSettings _copyClearingProgenitor:0];
                    long *v72 = &v4->_settings;
                    *(v72) = v70;
                    id v74 = [FBSSettingsDiff diffFromSettings:v4->_previousSettings toSettings:v4->_settings];
                    long *v75 = &v4->_diff;
                    *(v75) = v74;
                }
                id _synchronizer = [self _synchronizer];
                if ([_synchronizer receiverImplementsWillUpdate] != 0) {
                    [_synchronizer scene:self willUpdateSettings:v4];
                    if (![v4->_settings isEqual:mutableSettings]) {
                        id delegate2 = [_synchronizer delegate];
                        os_log_t oslog6 = FBLogScene();
                        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEBUG)) {
                            id v80 = [BSDescriptionBuilder succinctDescriptionForObject:delegate2];
                            id v81 = [FBSSettingsDiff diffFromSettings:v4->_settings toSettings:mutableSettings];
                            os_log_with_type(oslog6, OS_LOG_TYPE_DEBUG, "[%@] delegate %@ mutated settings: %@", loggingIdentifier2, v80, v81);
                        }
                        long v83 = [mutableSettings _copyClearingProgenitor:0];
                        long *v85 = &v4->_settings;
                        *(v85) = v83;
                        id v87 = [FBSSettingsDiff diffFromSettings:v4->_previousSettings toSettings:v4->_settings];
                        long *v88 = &v4->_diff;
                        *(v88) = v87;
                    }
                }
                bool isForeground = [settings4 isForeground];
                bool isForeground2 = [mutableSettings isForeground];
                if (isForeground != isForeground2) {
                    os_log_t oslog7 = FBLogScene();
                    if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
                        bool isForeground3 = [settings4 isForeground];
                        bool isForeground4 = [mutableSettings isForeground];
                        os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "[%{public}@] isForeground changed from %{bool}u to %{bool}u after interception", loggingIdentifier2, isForeground3, isForeground4);
                    }
                }
                if ((uint32_t)self->_legacy != 0 && _beginTransaction == 1) {
                    FBSSceneSettings *settings5 = [v4 settings];
                    self->_settings = [settings5 _copyClearingProgenitor:0];
                }
                long *v99 = &v4->_mutableSettings;
                *(v99) = 0;
                FBSSceneSettingsDiff *settingsDiff = [v4 settingsDiff];
                if (_beginTransaction == 1 || settingsDiff != nil || ![v15 _indirect_isEmpty]) {
                    FBSSceneSettings *settings = [v4 settings];
                    FBSSceneSettings *v104 = [settings _copyClearingProgenitor:0];
                    v4->_settings = v104;
                    id v105 = [FBSceneEventQueue suspendIdleWorkForReason:@"finishUpdate"];
                    id v106 = [FBSceneUpdateContext contextWithSceneID:self->_identifier transactionID:_beginTransaction settings:v104 settingsDiff:settingsDiff transitionContext:v15];
                    [v15 setUpdateContext:v106];
                    id v109 = v106;
                    [self _iterateObservers:^void(FBSceneObserver *arg1) {
                        [arg1 scene:self didPrepareUpdateWithContext:v106];
                    }];
                    [self->_workspace scene:self didPrepareUpdate:v4];
                    id actions = [v15 actions];
                    id fbs_singleLineDescriptionOfBSActions = [actions fbs_singleLineDescriptionOfBSActions];
                    if ([fbs_singleLineDescriptionOfBSActions length] != 0) {
                        os_log_t oslog = FBLogScene();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending action(s) in update: %{public}@", loggingIdentifier2, fbs_singleLineDescriptionOfBSActions);
                        }
                    }
                    id animationFence = [v15 animationFence];
                    if (animationFence != nil) {
                        id v116 = FBGetFencingProvider();
                        [v116 synchronizeDrawingWithFence:animationFence];
                    }
                    self->_settings = v104;
                    self->_settingsAtDeactivation = nil;
                    [self _resetUpdateState];
                    [self->_eventQueue executeOrAppend:^void(void) {
                        id v179;
                        long v169 = self->_contentState;
                        if (![self->_settings isForeground]) {
                            v169 = 0;
                            self->_lastForegroundingTransitionID = 0;
                        } else if (!v169) {
                            v169 = 1;
                            self->_lastForegroundingTransitionID = _beginTransaction;
                        }
                        if (!self) {
                            v179 = nil;
                        } else {
                            [self _setContentState:v169 notifyObservers:1];
                            v179 = self;
                        }
                        [v179 _iterateObservers:^void(FBSceneObserver *arg1) {
                            [arg1 scene:v179 didUpdateSettings:v4];
                        }];
                        [self->_workspace scene:self didApplyUpdate:v4];
                        id takeUpdateCompletions = [v4 takeUpdateCompletions];
                        void (^v170)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                            NSError *v183 = arg2;
                            if (arg1 == 0) {
                                os_log_t v187 = FBLogScene();
                                if (os_log_type_enabled(v187, OS_LOG_TYPE_ERROR)) {
                                    id v186 = [v183 descriptionWithMultilinePrefix:0];
                                    os_log_with_type(v187, OS_LOG_TYPE_ERROR, "[%{public}@] Update failed: %{public}@", loggingIdentifier2, v186);
                                }
                            }
                            if (v0 != nil) {
                                v0(arg1, v183);
                            }
                            if ([self isActive]) {
                                [self _iterateObservers:^void(FBSceneObserver *arg1) {
                                    [arg1 scene:self didCompleteUpdateWithContext:v109 error:v183];
                                }];
                                [self->_workspace scene:self didCompleteUpdate:v109];
                            }
                            for (id v185 in takeUpdateCompletions) {
                                v185->field_16(v185);
                            }
                        };
                        if (!self->_clientToken) {
                            void (^v172)(void) = ^void(void) {
                                NSError *v187 = FBSceneErrorCreate(1, @"No scene client exists", 0);
                                v170(NO, v187);
                            };
                            [self _dispatchClientMessageWithBlock:v172];
                        } else {
                            void (^v174)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                                [self _dispatchClientMessageWithBlock:^void(void) {
                                    NSError *v192;
                                    if (arg1 == 1) {
                                        if (self->_active == 1 && self->_lastForegroundingTransitionID == _beginTransaction && [self->_settings isForeground] && self != nil) {
                                            [self _setContentState:2 notifyObservers:1];
                                        }
                                        v192 = nil;
                                    } else {
                                        v192 = FBSceneErrorCreate(1, @"Scene update failed.", arg2);
                                    }
                                    v170(arg1, v192);
                                }];
                            };
                            [self->_client host:self didUpdateSettings:self->_settings withDiff:settingsDiff transitionContext:v15 completion:v174];
                        }
                        [self _endTransaction:_beginTransaction];
                        if ((uint32_t)v59 == 1) {
                            [self _iterateObservers:^void(FBSceneObserver *arg1) {
                                [arg1 sceneDidActivate:self];
                            }];
                        }
                        long *v176 = &*(v4);
                        *(v176) = 0;
                        long *v19 = &*(v4);
                        *(v19) = 0;
                    }];
                    [v105 invalidate];
                } else {
                    os_log_t oslog2 = FBLogScene();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "[%{public}@] Update was a no-op.", loggingIdentifier2);
                    }
                    [self _endTransaction:_beginTransaction];
                    [self _resetUpdateState];
                    if (v0 != nil) {
                        [self _dispatchClientMessageWithBlock:^void(void) {
                            v0(YES, nil);
                        }];
                    }
                }
            }
        } else {
            os_log_t oslog3 = FBLogScene();
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                id loggingIdentifier3 = [self loggingIdentifier];
                os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Ignoring update for invalidated scene: %{public}@", loggingIdentifier3);
            }
            [self _resetUpdateState];
            NSError *v123 = FBSceneErrorCreate(2, @"Cannot update an invalidated scene.", 0);
            v4 = v123;
            void (^v124)(void) = ^void(void) {
                if (!v0) {
                    return;
                } else {
                    v0(NO, v123);
                    return;
                }
            };
            [self _dispatchClientMessageWithBlock:v124];
        }
    }
}


id -[FBScene _allComponentProxies](void)
{
    id v1 = nil;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _allComponentProxies]");
        }
        id v0 = [self->_orderedComponents copy];
        v1 = (!v0) ? @[] : v0;
    }
    return v1;
}


bool -[FBScene isActive](void)
{
    if (!self->_active) {
        return self->_updateShouldActivate;
    } else {
        return true;
    }
}


unsigned long -[FBScene _beginTransaction](void)
{
    if (!self) {
        return 0;
    }
    if (!self->_active) {
        id loggingIdentifier = [self loggingIdentifier];
        NSString *v2 = [NSString stringWithFormat:@"scene is not actually active: %@", loggingIdentifier];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v3 = NSStringFromSelector(@selector(_beginTransaction));
            NSString *v4 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v3, v4, self, @"FBScene.m", 842, v2);
        }
        _bs_set_crash_log_message([v2 UTF8String]);
        __break(0);
    }
    if (self->_inTransaction) {
        id loggingIdentifier2 = [self loggingIdentifier];
        NSString *v7 = [NSString stringWithFormat:@"cannot begin a transition while we're already in one (%@)", loggingIdentifier2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v8 = NSStringFromSelector(@selector(_beginTransaction));
            NSString *v9 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBScene.m", 843, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    self->_inTransaction = YES;
    unsigned long v0 = self->_transactionID + 1;
    self->_transactionID = self->_transactionID + 1;
    return v0;
}


void -[FBScene _dispatchClientMessageWithBlock:](id a1)
{
    id v0 = a1;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            id callOutQueue = [FBWorkspaceEventDispatcher callOutQueue];
            [callOutQueue performAsync:^void(void) {
                [FBSceneEventQueue executeWhenIdle:v0];
            }];
        } else {
            @autoreleasepool {
                [FBSceneEventQueue executeWhenIdle:v0];
            }
        }
    }
}


FBSceneObserver *-[FBScene delegateProxy](void)
{
    FBSceneObserver *v0 = nil;
    if (self != nil) {
        v0 = self->_delegateProxy;
    }
    return v0;
}


void (^-[FBScene _iterateObservers:](void (^a1)(FBSceneObserver *)))(FBSceneObserver *)
{
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _iterateObservers:]");
        }
        if (self->_delegateProxy != nil) {
            a1(self->_delegateProxy);
        }
        id v4 = [self->_orderedComponents copy];
        for (FBSceneObserver *v2 in v4) {
            a1(v2);
        }
        id observerProxies = [self observerProxies];
        for (FBSceneObserver *v14 in observerProxies) {
            if (v14 != self->_delegateProxy) {
                a1(v14);
            }
        }
    }
    return a1;
}


id -[FBScene observerProxies](void)
{
    if (!self) {
        return nil;
    }
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene observerProxies]");
    }
    os_unfair_lock_lock(&self->_lock);
    NSArray *array = [self->_lock_observerProxies array];
    id v0 = [array copy];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


void -[FBScene _resetUpdateState](void)
{
    if (!self) {
        return;
    }
    self->_midUpdate = NO;
    self->_updateCompletion = nil;
    self->_updatePendingFinalize = NO;
    self->_updateShouldActivate = NO;
    self->_settingsUpdate = nil;
    [self->_updateSuspendIdleWork invalidate];
    self->_updateSuspendIdleWork = nil;
}


void -[FBScene _endTransaction:](long a1)
{
    if (!self) {
        return;
    }
    if (self->_inTransaction != 1 || self->_transactionID != a1) {
        NSString *v2 = [NSString stringWithFormat:@"ending transactionID %llu does not match active transactionID %llu", a1, self->_transactionID];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(@selector(_endTransaction:));
            NSString *v1 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v1, self, @"FBScene.m", 855, v2);
        }
        _bs_set_crash_log_message([v2 UTF8String]);
        __break(0);
    }
    self->_inTransaction = NO;
}


void -[FBScene _setContentState:notifyObservers:](long a1, int a2)
{
    if (!self || self->_contentState == a1) {
        return;
    }
    if (!self->_workspace) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_workspace != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(@selector(_setContentState:notifyObservers:));
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v11, self, @"FBScene.m", 869, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    if (self->_contentStateIsChanging == 1) {
        id v3 = NSStringFromFBSceneContentState(self->_contentState);
        id v4 = NSStringFromFBSceneContentState(a1);
        NSString *v5 = [NSString stringWithFormat:@"cannot re-entrantly mutate contentState (%@ --> %@)", v3, v4];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(@selector(_setContentState:notifyObservers:));
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v13, self, @"FBScene.m", 870, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    os_log_t oslog = FBLogScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id loggingIdentifier = [self loggingIdentifier];
        id v8 = NSStringFromFBSceneContentState(a1);
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] scene content state changed: %{public}@", loggingIdentifier, v8);
    }
    self->_contentState = a1;
    self->_contentStateIsChanging = YES;
    if (a2 != 0) {
        [self _iterateObservers:^void(FBSceneObserver *arg1) {
            [arg1 sceneContentStateDidChange:self];
        }];
    }
    self->_contentStateIsChanging = NO;
}


void -[FBScene performUpdate:withCompletion:](void (^a1)(FBSMutableSceneSettings *, FBSSceneTransitionContext *), id a2)
{
    [self _joinUpdate:1 block:a1 completion:a2];
}


void -[FBScene clientToken:didUpdateClientSettings:withDiff:transitionContext:](id a1, id a2, id a3, id a4)
{
    [self _dispatchClientMessageWithBlock:^void(void) {
        if (a1 == self->_clientToken) {
            FBSSceneUpdate *v0 = [FBSSceneUpdate new];
            v0->_previousSettings = self->_clientSettings;
            FBSSceneClientSettings *v1 = [a2 copy];
            self->_clientSettings = v1;
            v0->_settings = v1;
            v0->_diff = a3;
            v0->_context = a4;
            if ([a3 containsProperty:@selector(layers)] != 0) {
                id layers = [self->_clientSettings layers];
                [self->_layerManager _setLayers:layers];
            }
            os_log_t v6 = v0;
            [self _iterateObservers:^void(FBSceneObserver *arg1) {
                [arg1 scene:self didUpdateClientSettings:v0];
            }];
            id takeUpdateCompletions = [v6 takeUpdateCompletions];
            for (id v13 in takeUpdateCompletions) {
                v13->field_16(v13);
            }
        } else {
            os_log_t oslog = FBLogScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id loggingIdentifier = [self loggingIdentifier];
                id<NSObject> v2 = self->_clientToken;
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Ignoring scene client update due to token mismatch (probably due to prior deactivation). expected=%p received=%p", loggingIdentifier, v2, a1);
            }
        }
    }];
}


void -[FBScene _addExtensions:removeExtensions:settings:](id a1, id a2, id a3)
{
    id v24;
    if (self != nil) {
        if (self->_componentInit == 1) {
            NSString *v79 = [NSString stringWithFormat:@"components cannot mutate extensions during init"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v80 = NSStringFromSelector(@selector(_addExtensions:removeExtensions:settings:));
                NSString *v81 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v80, v81, self, @"FBScene.m", 1203, v79);
            }
            _bs_set_crash_log_message([v79 UTF8String]);
            __break(0);
        }
        self->_componentInit = YES;
        for (Class v11 in a1) {
            os_log_t oslog = FBLogScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
                id identity2 = [self->_definition identity];
                os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "[%@] Adding extension: \"%@\"", identity2, v11);
            }
            FBSComponentScene *v13 = [[FBSComponentScene alloc] initWithScene:self extension:v11];
            NSMutableArray *array = [NSMutableArray array];
            id hostComponents = [v11 hostComponents];
            FBSComponentScene *v20 = v13;
            for (Class v3 in hostComponents) {
                id v23 = [v3 alloc];
                if ([v23 respondsToSelector:@selector(initWithScene:)]) {
                    v24 = [v23 initWithScene:v20];
                } else {
                    v24 = [v23 init];
                }
                if (v24 != nil) {
                    os_log_t oslog2 = FBLogScene();
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG)) {
                        id identity = [self->_definition identity];
                        id v28 = [BSDescriptionBuilder succinctDescriptionForObject:v24];
                        os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "[%@] Instantiated component: \"%@\"", identity, v28);
                        v20 = v13;
                    }
                    [array addObject:[[FBSceneObserver alloc] initWithComponent:v24 extension:v11]];
                }
                v13 = v20;
            }
            if (!self->_components) {
                self->_components = [NSMapTable strongToStrongObjectsMapTable];
                self->_orderedComponents = [NSMutableArray array];
            }
            id v35 = [self->_components objectForKey:v11];
            if (v35 != nil) {
                NSString *v82 = NSStringFromClass(v11);
                NSString *v83 = [NSString stringWithFormat:@"shouldn't have existing components for new extension %@", v82];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v84 = NSStringFromSelector(@selector(_addExtensions:removeExtensions:settings:));
                    NSString *v85 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v84, v85, self, @"FBScene.m", 1232, v83);
                }
                _bs_set_crash_log_message([v83 UTF8String]);
                __break(0);
            }
            [self->_components setObject:array forKey:v11];
            [self->_orderedComponents addObjectsFromArray:array];
            for (id v9 in array) {
                id component = [v9 component];
                if ([component respondsToSelector:@selector(setScene:)]) {
                    [component setScene:v13];
                }
                if ([component respondsToSelector:@selector(configureInitialSettings:)]) {
                    [component configureInitialSettings:a3];
                }
            }
        }
        self->_componentInit = NO;
        for (Class v57 in a2) {
            os_log_t oslog3 = FBLogScene();
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEBUG)) {
                id loggingIdentifier2 = [self loggingIdentifier];
                NSString *v77 = NSStringFromClass(v57);
                os_log_with_type(oslog3, OS_LOG_TYPE_DEBUG, "[%@] Removing extension: \"%@\"", loggingIdentifier2, v77);
            }
            id v60 = [self->_components objectForKey:v57];
            for (id v67 in v60) {
                id component2 = [v67 component];
                if ([component2 respondsToSelector:@selector(componentWillInvalidate:)]) {
                    [component2 componentWillInvalidate:a3];
                }
                if ([component2 respondsToSelector:@selector(invalidate)]) {
                    [component2 invalidate];
                }
                [self->_orderedComponents removeObjectIdenticalTo:v67];
                [v67 invalidate];
                os_log_t oslog4 = FBLogScene();
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEBUG)) {
                    id loggingIdentifier = [self loggingIdentifier];
                    id v72 = [BSDescriptionBuilder succinctDescriptionForObject:component2];
                    os_log_with_type(oslog4, OS_LOG_TYPE_DEBUG, "[%@] Invalidated component: \"%@\"", loggingIdentifier, v72);
                }
            }
            [self->_components removeObjectForKey:v57];
            if (![self->_components count]) {
                self->_components = nil;
                self->_orderedComponents = nil;
            }
        }
    }
}


void -[FBScene updateSettings:](void (^a1)(FBSMutableSceneSettings *))
{
    [self _joinUpdate:0 block:a1 completion:nil];
}


FBScene *-[FBScene initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:](id a1, FBSceneRemnant *a2, id a3, id a4, id<FBSceneClient> a5, FBSceneWorkspace *a6)
{
    FBSSceneSettings *v42;
    FBSSceneSettings *v45;
    if (!self) {
        return nil;
    }
    if (!a6) {
        NSString *v64 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"workspace != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v65 = NSStringFromSelector(@selector(initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:));
            NSString *v66 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v65, v66, self, @"FBScene.m", 141, v64);
        }
        _bs_set_crash_log_message([v64 UTF8String]);
        __break(0);
    }
    if (![a1 isValid]) {
        NSString *v68 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[definition isValid]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v69 = NSStringFromSelector(@selector(initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:));
            NSString *v70 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v69, v70, self, @"FBScene.m", 142, v68);
        }
        _bs_set_crash_log_message([v68 UTF8String]);
        __break(0);
    }
    if (a2 != nil && ![a2 isKindOfClass:NSClassFromString(@"FBSceneRemnant")]) {
        NSString *v72 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSceneRemnantClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v73 = NSStringFromSelector(@selector(initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:));
            NSString *v74 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v73, v74, self, @"FBScene.m", 143, v72);
        }
        _bs_set_crash_log_message([v72 UTF8String]);
        __break(0);
    }
    if (a3 != nil && ![a3 isKindOfClass:NSClassFromString(@"FBSSceneSettings")]) {
        NSString *v76 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v77 = NSStringFromSelector(@selector(initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:));
            NSString *v78 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v77, v78, self, @"FBScene.m", 144, v76);
        }
        _bs_set_crash_log_message([v76 UTF8String]);
        __break(0);
    }
    if (a4 != nil && ![a4 isKindOfClass:NSClassFromString(@"FBSSceneClientSettings")]) {
        NSString *v80 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:FBSSceneClientSettingsClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v81 = NSStringFromSelector(@selector(initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:));
            NSString *v82 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v81, v82, self, @"FBScene.m", 145, v80);
        }
        _bs_set_crash_log_message([v80 UTF8String]);
        __break(0);
    }
    dispatch_once(&initWithDefiniton:remnant:settings:initialClientSettings:clientProvider:workspace:.onceToken, ^void(void) {
        _class_setCustomDeallocInitiation([FBScene class]);
    });
    FBScene *v6 = [super init];
    if (!v6) {
        return v6;
    }
    v6->_lock._os_unfair_lock_opaque = 0;
    v6->_definition = [a1 copy];
    v6->_transactionID = 0;
    v6->_workspace = a6;
    id identity = [a1 identity];
    FBSSceneClientIdentity *clientIdentity = [a1 clientIdentity];
    FBSSceneSpecification *specification = [a1 specification];
    id identifier = [identity identifier];
    v6->_identifier = [identifier copy];
    NSString *workspaceIdentifier = [identity workspaceIdentifier];
    v6->_workspaceIdentifier = [workspaceIdentifier copy];
    v6->_eventQueue = [[FBSceneEventQueue alloc] initWithName:[identity description] onQueue:dispatch_get_main_queue()];
    long targetsClientEndpoint = [clientIdentity targetsClientEndpoint];
    if (!targetsClientEndpoint) {
        id domain = [a6 domain];
        id incomingWorkspaceEndpoint = [domain incomingWorkspaceEndpoint];
        id internalWorkspaceIdentifier = [identity internalWorkspaceIdentifier];
        v6->_identityToken = [FBSSceneIdentityToken tokenWithHostEndpoint:incomingWorkspaceEndpoint workspace:internalWorkspaceIdentifier identifier:v6->_identifier];
    } else {
        long v37 = BSGetVersionedPID(targetsClientEndpoint);
        RBSProcessIdentity *processIdentity = [clientIdentity processIdentity];
        id internalWorkspaceIdentifier2 = [identity internalWorkspaceIdentifier];
        v6->_identityToken = [FBSSceneIdentityToken tokenWithHostVPID:v37 directEndpointTarget:processIdentity workspace:internalWorkspaceIdentifier2 identifier:v6->_identifier];
    }
    if (!a3) {
        id settingsClass = [specification settingsClass];
        v42 = [settingsClass settings];
    } else {
        v42 = [a3 _copyClearingProgenitor:0];
    }
    v6->_settings = v42;
    if (!a4) {
        id clientSettingsClass = [specification clientSettingsClass];
        v45 = [clientSettingsClass settings];
    } else {
        v45 = [a4 copy];
    }
    v6->_clientSettings = v45;
    v6->_layerManager = [[FBSceneLayerManager alloc] _initWithScene:v6];
    v6->_lock_observerProxies = [[NSMutableOrderedSet alloc] init];
    v6->_legacy = a5 != nil;
    v6->_client = a5;
    v6->_remnant = a2;
    if ([v6->_settings _hasAnySceneExtension] != 0) {
        v6->_settings = [v6->_settings _copyClearingProgenitor:^void(FBSSettings<FBSMutableSettings> *arg1) {
            [arg1 _removeAllSceneExtensions];
        }];
    }
    if ([v6->_clientSettings _hasAnySceneExtension] != 0) {
        v6->_clientSettings = [v6->_clientSettings copy:^void(FBSSettings<FBSMutableSettings> *arg1) {
            [arg1 _removeAllSceneExtensions];
        }];
    }
    id v56 = FBSGetDefaultExtensions(specification);
    [v6 addExtensions:v56];
    __weak FBScene *v57 = v6;
    id loggingIdentifier = [v6 loggingIdentifier];
    NSString *v59 = [NSString stringWithFormat:@"FBScene - %@", loggingIdentifier];
    v6->_stateCaptureAssertion = BSLogAddStateCaptureBlockForUserRequestsOnlyWithTitle(dispatch_get_main_queue(), v59, ^id(void) {
        return [v57 debugDescription];
    });
    v6->_finishedInit = YES;
    return v6;
}


long -[FBScene updateSettingsWithBlock:](long a1)
{
    return [self updateSettings:a1];
}


long -[FBScene(FBSceneManager) isLegacy](void)
{
    return [self _isLegacy];
}


void -[FBScene addObserver:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene addObserver:]");
    }
    if (a1 != nil) {
        FBSceneObserver *v1 = [[FBSceneObserver alloc] initWithObserver:a1];
        os_unfair_lock_lock(&self->_lock);
        [self->_lock_observerProxies addObject:v1];
        os_unfair_lock_unlock(&self->_lock);
    }
}


void -[FBScene setDelegate:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene setDelegate:]");
    }
    if (self->_delegateProxy != nil) {
        self->_delegateProxy = nil;
    }
    if (a1 != nil) {
        self->_delegateProxy = [[FBSceneObserver alloc] initWithDelegate:a1];
    }
}


bool -[FBScene _isLegacy](void)
{
    if (!self) {
        return false;
    } else {
        return self->_legacy;
    }
}


id -[FBScene componentForExtension:ofClass:](id a1, Class a2)
{
    id v9;
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene componentForExtension:ofClass:]");
    }
    id v1 = [self->_components objectForKey:a1];
    for (id v7 in v1) {
        id component = [v7 component];
        if (a2 != 0) {
            v9 = ([component isKindOfClass:a2]) ? component : nil;
        } else {
            v9 = nil;
        }
        id v4 = v9;
        if (v4 != nil) {
            return v4;
        }
    }
    return nil;
}


FBSSceneDefinition *-[FBScene definition](void)
{
    return self->_definition;
}


void -[FBScene activateWithTransitionContext:completion:](id a1, void (^a2)(bool, NSError *))
{
    NSString *v8;
    id v0 = a1;
    if (!self->_finishedInit) {
        NSString *v1 = [NSString stringWithFormat:@"cannot activate a scene during init"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBScene.m", 330, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    if (self->_midUpdate == 1) {
        NSString *v21 = [NSString stringWithFormat:@"cannot activate a scene mid update"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v22 = NSStringFromSelector(_cmd);
            NSString *v23 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v23, self, @"FBScene.m", 331, v21);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
    if (self->_deactivating == 1) {
        NSString *v25 = [NSString stringWithFormat:@"cannot activate a scene mid deactivation"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v26 = NSStringFromSelector(_cmd);
            NSString *v27 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v26, v27, self, @"FBScene.m", 332, v25);
        }
        _bs_set_crash_log_message([v25 UTF8String]);
        __break(0);
    }
    if (self->_legacy == 1) {
        if (self->_legacyActivated == 1) {
            NSString *v29 = [NSString stringWithFormat:@"legacy scenes can only ever be activated once"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v30 = NSStringFromSelector(_cmd);
                NSString *v31 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v30, v31, self, @"FBScene.m", 334, v29);
            }
            _bs_set_crash_log_message([v29 UTF8String]);
            __break(0);
        }
        self->_legacyActivated = YES;
    }
    id v2 = [FBSceneEventQueue suspendIdleWorkForReason:@"activation"];
    id v3 = nil;
    long v4 = [self _activateWithTransitionContext:v0 error:&v3];
    id v5 = v3;
    FBProcessExecutionContext *executionContext = [v0 executionContext];
    void (^completion)(id, NSError *) = [executionContext completion];
    if (completion != nil) {
        if (self->_active) {
            v8 = @"Provided execution context was not used because the scene was already active.";
        } else {
            v8 = (self->_invalidated) ? @"Scene was not activated because it had already been invalidated." : @"Provided execution context was not used to create a process.";
        }
        if (!self->_clientProcess) {
            NSObject<OS_dispatch_queue> *queue = [FBProcess calloutQueue];
            void (^block)(void) = ^void(void) {
                NSError *v34 = FBSceneErrorCreate(3, v8, v5);
                completion(0, v34);
            };
            dispatch_async(queue, block);
        } else {
            void (^v13)(FBProcess *, NSError *) = ^void(FBProcess *arg1, NSError *arg2) {
                NSError *v36 = FBSceneErrorCreate(3, v8, v5);
                completion(arg1, v36);
            };
            [self->_clientProcess _executeBlockAfterBootstrap:v13];
        }
    }
    bool v14 = self->_remnant != nil;
    [self performUpdate:^void(FBSMutableSceneSettings *arg1, FBSSceneTransitionContext *arg2) {
        if (v0 != nil) {
            self->_settingsUpdate->_context = v0;
        }
        id v38 = self;
        if (!self->_transactionID) {
            if (v38->_legacy || v14 == 1) {
                [v38->_workspace didAddScene:v38];
                v38 = self;
                if (self->_legacy == 0) {
                    [v38 _iterateObservers:^void(FBSceneObserver *arg1) {
                        [arg1 sceneWillActivate:v38];
                    }];
                }
            } else {
                [v38 _iterateObservers:^void(FBSceneObserver *arg1) {
                    [arg1 sceneWillActivate:v38];
                }];
            }
            if ([arg1 isClientFuture] != 0) {
                [arg1 setClientFuture:0];
                [arg1 setClientProcess:nil];
            }
        }
    } withCompletion:^void(bool arg1, NSError *arg2) {
        NSError *v43;
        if (arg1 && (v4 & 1) == 0) {
            NSString *v40 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"activated || !success"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v41 = NSStringFromSelector(_cmd);
                NSString *v46 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v46, self, @"FBScene.m", 395, v40);
            }
            _bs_set_crash_log_message([v40 UTF8String]);
            __break(0);
        }
        if (!arg1) {
            NSError *v42 = FBSceneErrorCreate(1, @"Scene activation failed.", (!v5) ? arg2 : v5);
            v43 = v42;
            id _createTransitionContext = [self _createTransitionContext];
            [_createTransitionContext setError:v42];
            [self _deactivateAndInvalidate:0 transitionContext:_createTransitionContext];
        } else {
            v43 = nil;
        }
        if (a2 != nil) {
            a2(arg1, v43);
        }
    }];
    [v2 invalidate];
}


bool -[FBScene _activateWithTransitionContext:error:](id a1, id *a2)
{
    NSError *v7;
    uint8_t v16;
    FBProcess *v17;
    FBProcess *v18;
    FBWorkspace *v28;
    FBProcess *v19;
    os_log_t v45;
    int v46;
    id v47;
    bool v117 = false;
    if (self) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _activateWithTransitionContext:error:]");
        }
        if (self->_active != 1) {
            if (self->_invalidated != 1) {
                if (!self->_workspace) {
                    NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_workspace"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v63 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                        NSString *v64 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v63, v64, self, @"FBScene.m", 1060, v1);
                    }
                    _bs_set_crash_log_message([v1 UTF8String]);
                    __break(0);
                }
                if (self->_clientHandle != nil) {
                    NSString *v65 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_clientHandle == nil"];
                    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                        NSString *v66 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                        NSString *v67 = NSStringFromClass([self class]);
                        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v66, v67, self, @"FBScene.m", 1061, v65);
                    }
                    _bs_set_crash_log_message([v65 UTF8String]);
                    __break(0);
                }
                if (self->_legacy == 1) {
                    if (!self->_client) {
                        NSString *v69 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_client != nil"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v70 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                            NSString *v71 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v70, v71, self, @"FBScene.m", 1066, v69);
                        }
                        _bs_set_crash_log_message([v69 UTF8String]);
                        __break(0);
                    }
                    id clientProcessHandle = [a1 clientProcessHandle];
                    if (clientProcessHandle != nil) {
                        NSString *v73 = [NSString stringWithFormat:@"legacy scenes do not support targeting clients by PID"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v74 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                            NSString *v75 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v74, v75, self, @"FBScene.m", 1067, v73);
                        }
                        _bs_set_crash_log_message([v73 UTF8String]);
                        __break(0);
                    }
                    Class v77 = [FBWorkspace class];
                    if (![self->_client isKindOfClass:v77]) {
                        id domain4 = [self->_workspace domain];
                        self->_clientProcess = [domain4 currentProcess];
                    } else {
                        FBProcess *process2 = [self->_client process];
                        FBProcess *v118 = self->_clientProcess;
                        self->_clientProcess = process2;
                    }
                    self->_clientHandle = [FBSceneClientHandle handleForScene:self clientProcess:self->_clientProcess];
                    v7 = nil;
                } else {
                    if (self->_client != nil) {
                        NSString *v85 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_client == nil"];
                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                            NSString *v86 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                            NSString *v87 = NSStringFromClass([self class]);
                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v86, v87, self, @"FBScene.m", 1076, v85);
                        }
                        _bs_set_crash_log_message([v85 UTF8String]);
                        __break(0);
                    }
                    id clientIdentity = [self->_definition clientIdentity];
                    if ([clientIdentity isLocal] != 0) {
                        id domain5 = [self->_workspace domain];
                        self->_clientProcess = [domain5 currentProcess];
                        self->_clientHandle = [FBSceneClientHandle handleForScene:self clientProcess:self->_clientProcess];
                        id domain6 = [self->_workspace domain];
                        self->_client = [domain6 syncLocalSceneClientProvider];
                        v7 = nil;
                    } else {
                        if (!self->_remnant) {
                            RBSProcessIdentity *processIdentity = [clientIdentity processIdentity];
                            id v11 = [a1 clientProcessHandle];
                            if ([self->_settings isClientFuture] != 0) {
                                FBProcess *clientProcess = [self->_settings clientProcess];
                                BSProcessHandle *handle = [clientProcess handle];
                                if (handle != nil) {
                                    if (v11 != nil && ![v11 isEqual:handle]) {
                                        NSString *v97 = [NSString stringWithFormat:@"a client future can only activate for the process that requested it"];
                                        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                                            NSString *v98 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                                            NSString *v99 = NSStringFromClass([self class]);
                                            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v98, v99, self, @"FBScene.m", 1102, v97);
                                        }
                                        _bs_set_crash_log_message([v97 UTF8String]);
                                        __break(0);
                                    }
                                    v11 = handle;
                                }
                            }
                            if (!v11) {
                                if (![self->_settings isClientFuture]) {
                                    id identityOfCurrentProcess = [RBSProcessIdentity identityOfCurrentProcess];
                                    if ([identityOfCurrentProcess isEqual:processIdentity]) {
                                        id domain = [self->_workspace domain];
                                        long currentProcess = [domain currentProcess];
                                        v16 = currentProcess;
                                        self->_clientHandle = [FBSceneClientHandle handleForScene:self clientProcess:currentProcess];
                                        v7 = nil;
                                        v17 = v16;
                                        if (v16 != 0) {
                                            goto blk_1c4ee5a00;
                                        } else {
                                            goto blk_1c4ee5a3c;
                                        }
blk_1c4ee5a40:
                                        v18 = self->_clientProcess;
                                        self->_clientProcess = v17;
                                        goto blk_1c4ee5a48;
                                    }
                                    FBProcessExecutionContext *executionContext = [a1 executionContext];
                                    FBMutableProcessExecutionContext *v21 = [executionContext mutableCopy];
                                    if (!v21) {
                                        v21 = [[FBMutableProcessExecutionContext alloc] initWithIdentity:processIdentity];
                                    } else if (![v21 identity]) {
                                        [v21 setIdentity:processIdentity];
                                    } else {
                                        RBSProcessIdentity *identity = [v21 identity];
                                        if (![identity isEqual:processIdentity]) {
                                            NSString *v105 = [NSString stringWithFormat:@"Client process identity does not match execution context identity"];
                                            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                                                NSString *v106 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                                                NSString *v107 = NSStringFromClass([self class]);
                                                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v106, v107, self, @"FBScene.m", 1124, v105);
                                            }
                                            _bs_set_crash_log_message([v105 UTF8String]);
                                            __break(0);
                                        }
                                    }
                                    id v25 = [v21 copyOrUpdateForSceneActivationWithSettings:self->_settings];
                                    id domain2 = [self->_workspace domain];
                                    id v27 = nil;
                                    v17 = [domain2 _createProcessFutureWithExecutionContext:v25 error:&v27];
                                    v7 = v27;
                                    [a1 setExecutionContext:0];
                                    if (v17 != nil) {
                                        goto blk_1c4ee5a00;
                                    }
                                } else {
                                    v7 = FBSceneErrorCreate(3, @"client futures must be activated with a specific client process", 0);
                                    v17 = nil;
                                }
blk_1c4ee5a3c:
                                v28 = nil;
                                goto blk_1c4ee5a40;
                            }
                            id identity2 = [v11 identity];
                            if (![identity2 isEqual:processIdentity]) {
                                NSString *v109 = [NSString stringWithFormat:@"Client process identity does not match provided handle's identity"];
                                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                                    NSString *v110 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                                    NSString *v111 = NSStringFromClass([self class]);
                                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v110, v111, self, @"FBScene.m", 1108, v109);
                                }
                                _bs_set_crash_log_message([v109 UTF8String]);
                                __break(0);
                            }
                            id domain3 = [self->_workspace domain];
                            id v32 = nil;
                            v17 = [domain3 _createProcessFutureForProcessHandle:v11 error:&v32];
                            v7 = v32;
                            if (!v17) {
                                goto blk_1c4ee5a3c;
                            }
blk_1c4ee5a00:
                            FBWorkspace *workspace = [v17 workspace];
                            v28 = workspace;
                            v7 = nil;
                            goto blk_1c4ee5a40;
                        }
                        v28 = [self->_remnant _workspace];
                        FBProcess *process = [v28 process];
                        bool v62 = !v28 || !process;
                        if (!v62) {
                            BSSimpleAssertion *_assertion = [self->_remnant _assertion];
                            BOOL isValid = [_assertion isValid];
                            v62 = !isValid;
                        }
                        if (v62) {
                            v7 = FBSceneErrorCreate(1, @"failed to activate scene from remnant", 0);
                            v28 = nil;
                            v18 = self->_clientProcess;
                            self->_clientProcess = nil;
                            v19 = nil;
                        } else {
                            v7 = nil;
                            v18 = self->_clientProcess;
                            self->_clientProcess = process;
                            v19 = self->_clientProcess;
                        }
blk_1c4ee5a48:
                        self->_client = v28;
                    }
                }
                FBProcessExecutionContext *executionContext2 = [a1 executionContext];
                if (executionContext2 != nil) {
                    os_log_t oslog = FBLogScene();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        id loggingIdentifier = [self loggingIdentifier];
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Execution contexts are not supported for this scene.", loggingIdentifier);
                    }
                }
                self->_clientSettings = [self->_clientSettings copy:^void(FBSMutableSceneClientSettings *arg1) {
                    [arg1 _removeVolatileSettings];
                }];
                id layers = [self->_clientSettings layers];
                [self->_layerManager _setLayers:layers];
                if (!self->_client) {
                    v45 = FBLogScene();
                    if (os_log_type_enabled(v45, OS_LOG_TYPE_ERROR)) {
                        id loggingIdentifier2 = [self loggingIdentifier];
                        id v116 = [v7 descriptionWithMultilinePrefix:0];
                        os_log_with_type(v45, OS_LOG_TYPE_ERROR, "[%{public}@] Failed to resolve a scene client provider: %{public}@", loggingIdentifier2, v116);
                    }
blk_1c4ee5b70:
                    v46 = 0;
                    v47 = v7;
                } else {
                    id v48 = nil;
                    id<NSObject> v49 = [self->_client registerHost:self settings:self->_settings initialClientSettings:self->_clientSettings fromRemnant:self->_remnant error:&v48];
                    v47 = v48;
                    self->_clientToken = v49;
                    if (!self->_clientToken) {
                        v45 = FBLogScene();
                        bool v51 = os_log_type_enabled(v45, OS_LOG_TYPE_ERROR);
                        v7 = v47;
                        if (v51) {
                            id loggingIdentifier3 = [self loggingIdentifier];
                            id v53 = [v47 descriptionWithMultilinePrefix:0];
                            v16 = 0x8420302;
                            _os_log_error_impl(&_mh_dylib_header, v45, OS_LOG_TYPE_ERROR, "[%{public}@] Failed to connect with %{public}@: %{public}@.", &v16, 32);
                            v7 = v47;
                            goto blk_1c4ee5b70;
                        }
                        goto blk_1c4ee5b70;
                    } else {
                        v46 = 1;
                    }
                }
                self->_active = YES;
                self->_remnant = nil;
                self->_activationID = self->_activationID + 1;
                os_log_t oslog2 = FBLogScene();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    [self loggingIdentifier];
                    v16 = 0x8420202;
                    _os_log_impl(&_mh_dylib_header, oslog2, OS_LOG_TYPE_DEFAULT, "[%{public}@][%lu] Scene activated.", &v16, 22);
                }
                if (v46 && !self->_clientHandle) {
                    unsigned long v57 = self->_activationID;
                    FBProcess *v58 = self->_clientProcess;
                    [v58 _executeBlockAfterLaunchCompletes:^void(bool arg1) {
                        [self _dispatchClientMessageWithBlock:^void(void) {
                            if (arg1 != 1) {
                                return;
                            }
                            if (self->_invalidated || self->_active != 1 || v57 != self->_activationID) {
                                return;
                            }
                            if (self->_clientHandle != nil) {
                                NSString *v119 = [NSString stringWithFormat:@"client handle must be nil"];
                                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                                    NSString *v120 = NSStringFromSelector(@selector(_activateWithTransitionContext:error:));
                                    NSString *v121 = NSStringFromClass([self class]);
                                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v120, v121, self, @"FBScene.m", 1181, v119);
                                }
                                _bs_set_crash_log_message([v119 UTF8String]);
                                __break(0);
                            }
                            self->_clientHandle = [FBSceneClientHandle handleForScene:self clientProcess:v58];
                            os_log_t oslog = FBLogScene();
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                                id loggingIdentifier = [self loggingIdentifier];
                                FBSceneClientHandle *v1 = self->_clientHandle;
                                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Client process connected: %{public}@", loggingIdentifier, v1);
                            }
                            if (![self->_workspace _suppressConnectionHandshakes]) {
                                [self _iterateObservers:^void(FBSceneObserver *arg1) {
                                    [arg1 scene:self clientDidConnect:self->_clientHandle];
                                }];
                            }
                        }];
                    }];
                }
                if (a2 != 0) {
                    *(a2) = v47;
                }
                v117 = v46;
            } else if (!a2) {
                v117 = false;
            } else {
                NSError *v61 = FBSceneErrorCreate(2, @"Cannot activate an invalidated scene.", 0);
                v117 = false;
                *(a2) = v61;
            }
        } else {
            if (a2 != 0) {
                *(a2) = nil;
            }
            v117 = true;
        }
    }
    return v117;
}


id -[FBScene delegate](void)
{
    return [self->_delegateProxy delegate];
}


FBSSceneClientSettings *-[FBScene(UIApp) uiClientSettings](void)
{
    FBSSceneClientSettings *clientSettings = [self clientSettings];
    if (([clientSettings _uikitShimming_isUISubclass] & 1) == 0) {
        NSString *v1 = [NSString stringWithFormat:@"clientSettings is of an unexpected class : %@", clientSettings];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene+UIApp.m", 29, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    return clientSettings;
}


long -[FBScene contentState](void)
{
    return self->_contentState;
}


long -[FBScene(UIApp) currentInterfaceOrientation](void)
{
    FBSSceneSettings *settings = [self settings];
    id _uiApplicationSceneSettingsShim = [settings _uiApplicationSceneSettingsShim];
    FBSSceneClientSettings *clientSettings = [self clientSettings];
    id _uiApplicationSceneClientSettingsShim = [clientSettings _uiApplicationSceneClientSettingsShim];
    if (!_uiApplicationSceneSettingsShim || !_uiApplicationSceneClientSettingsShim) {
        if (!_uiApplicationSceneSettingsShim) {
            return 0;
        }
        return [_uiApplicationSceneSettingsShim interfaceOrientation];
    } else if (![_uiApplicationSceneSettingsShim deviceOrientationEventsEnabled]) {
        return [_uiApplicationSceneSettingsShim interfaceOrientation];
    }
    long interfaceOrientation = [_uiApplicationSceneClientSettingsShim interfaceOrientation];
    if (!interfaceOrientation) {
        return [_uiApplicationSceneSettingsShim interfaceOrientation];
    }
    return interfaceOrientation;
}


BOOL -[FBScene isEqual:](id a1)
{
    id v0 = a1;
    if ([a1 isProxy]) {
        id v1 = [v0 forwardingTargetForSelector:_cmd];
        v0 = v1;
    }
    return [super isEqual:v0];
}


FBProcess *-[FBScene clientProcess](void)
{
    if (self->_legacy || self->_clientHandle != nil) {
        return self->_clientProcess;
    } else {
        return nil;
    }
}


FBSceneClientHandle *-[FBScene clientHandle](void)
{
    return self->_clientHandle;
}


NSString *-[FBScene workspaceIdentifier](void)
{
    return self->_workspaceIdentifier;
}


void -[FBScene _propagateSettings:fromSettings:toSettings:](id a1, id a2, id a3)
{
    long v15;
    if (self != nil) {
        if (!a1) {
            NSString *v21 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"settingsToPropagate"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v22 = NSStringFromSelector(@selector(_propagateSettings:fromSettings:toSettings:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v22, v3, self, @"FBScene.m", 1758, v21);
            }
            _bs_set_crash_log_message([v21 UTF8String]);
            __break(0);
        }
        if (!a2) {
            NSString *v24 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"parentSettings"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v25 = NSStringFromSelector(@selector(_propagateSettings:fromSettings:toSettings:));
                NSString *v26 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v25, v26, self, @"FBScene.m", 1759, v24);
            }
            _bs_set_crash_log_message([v24 UTF8String]);
            __break(0);
        }
        if (!a3) {
            NSString *v28 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"mutableSettings"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v29 = NSStringFromSelector(@selector(_propagateSettings:fromSettings:toSettings:));
                NSString *v30 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v29, v30, self, @"FBScene.m", 1760, v28);
            }
            _bs_set_crash_log_message([v28 UTF8String]);
            __break(0);
        }
        id otherSettings2 = [a2 otherSettings];
        for (id v12 in a1) {
            os_log_t oslog = FBLogScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
                id loggingIdentifier = [self loggingIdentifier];
                id indirect_name = [v12 indirect_name];
                os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "[%{public}@] Propagating %@", loggingIdentifier, indirect_name);
            }
            if ([v12 indirect_isLegacy] != 0) {
                long indirect_legacySetting = [v12 indirect_legacySetting];
                v15 = [otherSettings2 objectForSetting:indirect_legacySetting];
                long v16 = [otherSettings2 flagForSetting:indirect_legacySetting];
                id otherSettings = [a3 otherSettings];
                [otherSettings setObject:v15 forSetting:indirect_legacySetting];
                [otherSettings setFlag:v16 forSetting:indirect_legacySetting];
            } else {
                v15 = FBSSettingsValueForSetting(a2, v12);
                FBSSettingsSetValueForSetting(a3, v12, v15);
            }
        }
    }
}


void -[FBScene scene:didUpdateSettings:](id a1, id a2)
{
    id v1 = a2;
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene scene:didUpdateSettings:]");
    }
    FBSSceneSettings *settings = [v1 settings];
    NSMutableSet *set = [NSMutableSet set];
    id _propagatedSettings = [self->_settings _propagatedSettings];
    FBSSceneSettingsDiff *settingsDiff = [v1 settingsDiff];
    id changedSettings = [settingsDiff changedSettings];
    for (id v12 in changedSettings) {
        if (([v12 indirect_isPropagating] & 1) != 0 || [_propagatedSettings containsObject:v12]) {
            [set addObject:v12];
        }
    }
    [self _joinUpdate:0 block:^void(FBSMutableSceneSettings *arg1, FBSSceneTransitionContext *arg2) {
        id loggingIdentifier2;
        id loggingIdentifier;
        if (self->_newlyReparented == 1) {
            NSOrderedSet *_allSceneExtensions = [arg1 _allSceneExtensions];
            FBSSceneSettings *v24 = [a1 settings];
            id _allSceneExtensions2 = [v24 _allSceneExtensions];
            for (id v10 in _allSceneExtensions2) {
                if ([_allSceneExtensions containsObject:v10] || ![v10 propagateToSceneWithDefinition:self->_definition]) {
                    continue;
                }
                [arg1 _addSceneExtension:v10];
            }
        }
        if ([set count] != 0) {
            do {
                os_log_t log = FBLogScene();
                bool v23 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
                if (self->_active != 1) {
                    if (!v23) {
                        break;
                    }
                    loggingIdentifier2 = [self loggingIdentifier];
                    NSUInteger count2 = [set count];
                    loggingIdentifier = [a1 loggingIdentifier];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@ (inactive)] propagating %lu settings from %{public}@", loggingIdentifier2, count2, loggingIdentifier);
                } else {
                    if (!v23) {
                        break;
                    }
                    loggingIdentifier2 = [self loggingIdentifier];
                    NSUInteger count = [set count];
                    loggingIdentifier = [a1 loggingIdentifier];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] propagating %lu settings from %{public}@", loggingIdentifier2, count, loggingIdentifier);
                }
            } while (0);
            [self _propagateSettings:set fromSettings:settings toSettings:arg1];
            if (self->_active == 1) {
                id animationSettings = [*(v1) animationSettings];
                [arg2 setAnimationSettings:animationSettings];
                id animationFence = [*(v1) animationFence];
                id v21 = [animationFence copy];
                [arg2 setAnimationFence:v21];
            }
        }
        [arg2 setParentUpdate:v1];
    } completion:nil];
    self->_newlyReparented = NO;
}


void -[FBScene setParentScene:](FBSScene *a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene setParentScene:]");
    }
    FBSScene *v1 = self->_parentScene;
    if (v1 != a1) {
        [v1 removeObserver:self];
        self->_parentScene = a1;
        FBSSceneUpdate *v2 = FBLogScene([a1 addObserver:self]);
        bool v3 = os_log_type_enabled(v2, OS_LOG_TYPE_DEFAULT);
        if (a1) {
            if (v3) {
                id loggingIdentifier2 = [self loggingIdentifier];
                id loggingIdentifier3 = [a1 loggingIdentifier];
                os_log_with_type(v2, OS_LOG_TYPE_DEFAULT, "[%{public}@] Setting parent scene: %{public}@", loggingIdentifier2, loggingIdentifier3);
            }
            self->_newlyReparented = YES;
            v2 = [FBSSceneUpdate new];
            FBSSceneSettings *settings = [a1 settings];
            long *v10 = &v2->_settings;
            *(v10) = settings;
            long *v12 = &v2->_previousSettings;
            *(v12) = 0;
            id v14 = [FBSSettingsDiff diffFromSettings:0 toSettings:v2->_settings];
            long *v15 = &v2->_diff;
            *(v15) = v14;
            [self scene:a1 didUpdateSettings:v2];
            if (self->_newlyReparented) {
                NSString *v17 = [NSString stringWithFormat:@"reparenting was not completed"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v18 = NSStringFromSelector(_cmd);
                    NSString *v19 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBScene.m", 502, v17);
                }
                _bs_set_crash_log_message([v17 UTF8String]);
                __break(0);
            }
        } else if (v3) {
            id loggingIdentifier = [self loggingIdentifier];
            os_log_with_type(v2, OS_LOG_TYPE_DEFAULT, "[%{public}@] Removing parent scene.", loggingIdentifier);
        }
    }
}


FBSSceneIdentityToken *-[FBScene identityToken](void)
{
    return self->_identityToken;
}


FBSScene *-[FBScene parentScene](void)
{
    return self->_parentScene;
}


void -[FBScene removeObserver:](long a1)
{
    os_unfair_lock_lock(&self->_lock);
    id v1 = [self->_lock_observerProxies copy];
    for (id v6 in v1) {
        id observer = [v6 observer];
        if (!observer || observer == a1) {
            [self->_lock_observerProxies removeObject:v6];
            [v6 invalidate];
        }
    }
    os_unfair_lock_unlock(&self->_lock);
}


long -[FBScene performUpdate:](long a1)
{
    return [self performUpdate:a1 withCompletion:0];
}


NSString *-[FBScene loggingIdentifier](void)
{
    return [self->_eventQueue name];
}


FBSSceneClientSettings *-[FBScene clientSettings](void)
{
    return self->_clientSettings;
}


void -[FBScene addExtensions:](id a1)
{
    id v0 = a1;
    if ([a1 count] != 0) {
        [self updateSettings:^void(FBSMutableSceneSettings *arg1) {
            for (id v2 in v0) {
                [arg1 _addSceneExtension:v2];
            }
        }];
    }
}


FBSSceneTransitionContext *-[FBScene _createTransitionContext](void)
{
    FBSSceneSpecification *specification = [self->_definition specification];
    id transitionContextClass = [specification transitionContextClass];
    return [transitionContextClass transitionContext];
}


int -[FBScene updateWhenMutable:](void (^a1)(FBSMutableSceneSettings *, long))
{
    return [self executeWhenMutable:^void(void) {
        if (![self isActive]) {
            [self updateSettings:^void(FBSMutableSceneSettings *arg1) {
                a1(arg1, 0);
            }];
            return;
        }
        [self performUpdate:a1];
    }];
}


int -[FBScene executeWhenMutable:](void (^a1)(void))
{
    int v1;
    if (self->_invalidated) {
        return 0;
    }
    if (![self isMutable]) {
        [FBSceneEventQueue executeWhenIdle:a1];
        v1 = 0;
    } else {
        a1();
        v1 = 1;
    }
    return v1;
}


void -[FBScene .cxx_destruct](void)
{
    self->_workspace = nil;
    self->_clientHandle = nil;
    self->_updateSuspendIdleWork = nil;
    self->_updateCompletion = nil;
    self->_settingsUpdate = nil;
    self->_parentScene = nil;
    self->_orderedComponents = nil;
    self->_components = nil;
    self->_settingsAtDeactivation = nil;
    self->_remnant = nil;
    self->_definition = nil;
    self->_clientSettings = nil;
    self->_settings = nil;
    self->_identityToken = nil;
    self->_workspaceIdentifier = nil;
    self->_identifier = nil;
    self->_clientProcess = nil;
    self->_client = nil;
    self->_clientToken = nil;
    self->_eventQueue = nil;
    self->_stateCaptureAssertion = nil;
    self->_lock_observerProxies = nil;
    self->_delegateProxy = nil;
    self->_layerManager = nil;
}


void -[FBScene _objc_initiateDealloc](void)
{
    if (pthread_main_np() != 0) {
        _objc_deallocOnMainThreadHelper(self);
        return;
    }
    dispatch_async_f(dispatch_get_main_queue(), self, &_objc_deallocOnMainThreadHelper);
}


void -[FBScene dealloc](void)
{
    if (!self->_invalidated) {
        NSString *v5 = [NSString stringWithFormat:@"Scene must be invalidated before it can deallocate."];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene.m", 212, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    self->_delegateProxy = nil;
    self->_workspace = nil;
    [self->_stateCaptureAssertion invalidate];
    [super dealloc];
}


void -[FBScene activate:](void (^a1)(id))
{
    id v0;
    if (!a1) {
        v0 = nil;
    } else {
        v0 = [self _createTransitionContext];
        a1(v0);
    }
    [self activateWithTransitionContext:v0];
}


FBSceneLayerManager *-[FBScene layerManager](void)
{
    return self->_layerManager;
}


id -[FBScene succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


long -[FBScene identity](void)
{
    return [self->_definition identity];
}


void -[FBScene addExtension:](id a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"extension != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene.m", 444, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    NSArray *v1 = @[a1];
    [self addExtensions:v1];
}


long -[FBScene activateWithTransitionContext:](long a1)
{
    return [self activateWithTransitionContext:a1 completion:0];
}


void -[FBScene clientToken:didReceiveActions:forExtension:](id a1, id a2, Class a3)
{
    [self _dispatchClientMessageWithBlock:^void(void) {
        os_log_t oslog6;
        id loggingIdentifier2;
        NSSet *v24;
        if (a1 != self->_clientToken) {
            oslog6 = FBLogScene();
            if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
                id loggingIdentifier = [self loggingIdentifier];
                id<NSObject> v2 = self->_clientToken;
                os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "[%{public}@] Ignoring actions due to token mismatch (probably due to prior deactivation). expected=%p received=%p", loggingIdentifier, v2, a1);
            }
            return;
        } else {
            loggingIdentifier2 = [self loggingIdentifier];
            os_log_t log = FBLogScene();
            bool v5 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
            if (a3 == 0) {
                if (v5) {
                    NSString *fbs_singleLineDescriptionOfBSActions = [a2 fbs_singleLineDescriptionOfBSActions];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Received action(s): %{public}@", loggingIdentifier2, fbs_singleLineDescriptionOfBSActions);
                }
            }
            if (a3 != 0 && v5) {
                NSString *v66 = NSStringFromClass(a3);
                id fbs_singleLineDescriptionOfBSActions2 = [a2 fbs_singleLineDescriptionOfBSActions];
                os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Received action(s) for \"%{public}@\": %{public}@", loggingIdentifier2, v66, fbs_singleLineDescriptionOfBSActions2);
            }
        }
        id v6 = a2;
        id v9 = (a3 != 0) ? [self _componentProxiesForExtension:a3] : [self _allComponentProxies];
        if ([v9 count]) {
            id v14 = [v6 mutableCopy];
            for (id v22 in v9) {
                if (a3 != 0) {
                    v24 = [v22 scene:self handlePrivateActions:v14];
                } else {
                    v24 = [v22 scene:self handleActions:v14];
                }
                if ([v24 count] != 0) {
                    os_log_t oslog = FBLogScene();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                        id v27 = [BSDescriptionBuilder succinctDescriptionForObject:v22];
                        id fbs_singleLineDescriptionOfBSActions3 = [v24 fbs_singleLineDescriptionOfBSActions];
                        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Component %{public}@ handled action(s): %@", loggingIdentifier2, v27, fbs_singleLineDescriptionOfBSActions3);
                    }
                    [v14 minusSet:v24];
                }
                long count = [v14 count];
                if (!count) {
                    break;
                }
            }
            id v31 = [v14 copy];
            v6 = v31;
        }
        if (a3 != 0 && [v6 count] != 0) {
            os_log_t oslog2 = FBLogScene();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                NSString *v33 = NSStringFromClass(a3);
                id fbs_singleLineDescriptionOfBSActions4 = [v6 fbs_singleLineDescriptionOfBSActions];
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "[%{public}@] Extension \"%{public}@\" did not handle actions: %{public}@", loggingIdentifier2, v33, fbs_singleLineDescriptionOfBSActions4);
            }
            v6 = nil;
        }
        if (![v6 count]) {
            return;
        }
        id _synchronizer = [self _synchronizer];
        if (![_synchronizer delegateReceivesActions]) {
            id v37 = [v6 mutableCopy];
            os_log_t v40 = loggingIdentifier2;
            [self _iterateObservers:^void(FBSceneObserver *arg1) {
                if ([v37 count] != 0) {
                    id component = [arg1 component];
                    if (component != 0) {
                        return;
                    }
                    if (![arg1 observerHandlesActions]) {
                        return;
                    }
                    id observer = [arg1 observer];
                    NSSet *v64 = [arg1 scene:self handleActions:v37];
                    NSUInteger v68 = [v64 count];
                    os_log_t v70 = FBLogScene();
                    if (!v68) {
                        if (os_log_type_enabled(v70, OS_LOG_TYPE_DEBUG)) {
                            id v8 = [BSDescriptionBuilder succinctDescriptionForObject:observer];
                            os_log_with_type(v70, OS_LOG_TYPE_DEBUG, "[%{public}@] %{public}s %{public}@ handled no actions.", oslog6, (arg1 == _synchronizer) ? "Delegate" : "Observer", v8);
                        }
                    } else {
                        if (os_log_type_enabled(v70, OS_LOG_TYPE_DEFAULT)) {
                            id v61 = [BSDescriptionBuilder succinctDescriptionForObject:observer];
                            id v69 = [v64 fbs_singleLineDescriptionOfBSActions];
                            os_log_with_type(v70, OS_LOG_TYPE_DEFAULT, "[%{public}@] %{public}s %{public}@ handled action(s): %@", oslog6, (arg1 == _synchronizer) ? "Delegate" : "Observer", v61, v69);
                        }
                        [v37 minusSet:v64];
                    }
                }
            }];
            if (![v37 count]) {
                return;
            }
            os_log_t oslog5 = FBLogScene();
            if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
                id fbs_singleLineDescriptionOfBSActions5 = [v37 fbs_singleLineDescriptionOfBSActions];
                os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "[%{public}@] Dropping unhandled action(s): %{public}@", v40, fbs_singleLineDescriptionOfBSActions5);
            }
            for (id v54 in v37) {
                if ([v54 canSendResponse] != 0) {
                    NSError *v55 = FBSceneErrorCreate(3, @"No handler for action.", 0);
                    id v56 = [BSActionResponse responseForError:v55];
                    [v54 sendResponse:v56];
                }
                [v54 invalidate];
            }
        } else {
            os_log_t oslog3 = FBLogScene();
            bool v42 = os_log_type_enabled(oslog3, OS_LOG_TYPE_DEBUG);
            if (!v42) {
                [_synchronizer scene:self didReceiveActions:v6];
                return;
            }
            id delegate = [_synchronizer delegate];
            os_log_t oslog4 = FBLogScene();
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEBUG)) {
                id v57 = [BSDescriptionBuilder succinctDescriptionForObject:delegate];
                os_log_with_type(oslog4, OS_LOG_TYPE_DEBUG, "[%{public}@] Handing all actions to delegate: %@", loggingIdentifier2, v57);
            }
            [_synchronizer scene:self didReceiveActions:v6];
        }
    }];
}


void -[FBScene configureParameters:](void (^a1)(FBSMutableSceneParameters *))
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene configureParameters:]");
    }
    if (!a1) {
        NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"block != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBScene.m", 550, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    if (self->_active == 1) {
        NSString *v14 = [NSString stringWithFormat:@"cannot call configureParameters on an active scene"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v15 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v15, v16, self, @"FBScene.m", 551, v14);
        }
        _bs_set_crash_log_message([v14 UTF8String]);
        __break(0);
    }
    if (self->_configuringParameters == 1) {
        NSString *v18 = [NSString stringWithFormat:@"re-entrant mutation during configureParameters is not supported"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBScene.m", 552, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    FBSMutableSceneParameters *v3 = [[FBSMutableSceneParameters alloc] initWithSpecification:[self->_definition specification]];
    FBSSceneSettings *settings = [self settings];
    [v3 setSettings:settings];
    [v3 setClientSettings:self->_clientSettings];
    id v5 = [FBSceneEventQueue suspendIdleWorkForReason:@"configureParameters"];
    self->_configuringParameters = YES;
    a1(v3);
    self->_configuringParameters = NO;
    FBSSceneClientSettings *clientSettings = [v3 clientSettings];
    self->_clientSettings = [clientSettings copy];
    FBSSceneSettings *settings2 = [v3 settings];
    [self updateSettings:settings2 withTransitionContext:0];
    [v5 invalidate];
}


void -[FBScene invalidate](void)
{
    [self _deactivateAndInvalidate:1 transitionContext:0];
}


void -[FBScene _deactivateAndInvalidate:transitionContext:](int a1, id a2)
{
    bool v2;
    id<NSObject> v25;
    id v0 = a2;
    if (self != nil) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene _deactivateAndInvalidate:transitionContext:]");
        }
        if (!self->_invalidated) {
            if (([self isMutable] & 1) == 0) {
                NSString *v1 = [NSString stringWithFormat:@"scene is not currently mutable"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v41 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v42 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v41, v42, self, @"FBScene.m", 1590, v1);
                }
                _bs_set_crash_log_message([v1 UTF8String]);
                __break(0);
            }
            if (self->_deactivating == 1) {
                NSString *v44 = [NSString stringWithFormat:@"cannot re-entrantly deactivate a scene"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v45 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v46 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v45, v46, self, @"FBScene.m", 1591, v44);
                }
                _bs_set_crash_log_message([v44 UTF8String]);
                __break(0);
            }
            if (self->_midUpdate == 1) {
                NSString *v48 = [NSString stringWithFormat:@"cannot deactivate a scene while it is updating"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v49 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v50 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v49, v50, self, @"FBScene.m", 1592, v48);
                }
                _bs_set_crash_log_message([v48 UTF8String]);
                __break(0);
            }
            if (self->_inTransaction == 1) {
                NSString *v52 = [NSString stringWithFormat:@"cannot deactivate while updating"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v53 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v54 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v53, v54, self, @"FBScene.m", 1593, v52);
                }
                _bs_set_crash_log_message([v52 UTF8String]);
                __break(0);
            }
            if (self->_contentStateIsChanging == 1) {
                NSString *v56 = [NSString stringWithFormat:@"cannot deactivate a scene while content state is changing"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v57 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v58 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v57, v58, self, @"FBScene.m", 1594, v56);
                }
                _bs_set_crash_log_message([v56 UTF8String]);
                __break(0);
            }
            if (!a1) {
                v2 = self->_legacy;
                if ((self->_active | self->_legacy) == 0) {
                    return;
                }
            } else {
                v2 = true;
            }
            NSError *error = [v0 error];
            NSErrorDomain domain = [error domain];
            BOOL v6 = [domain isEqualToString:FBSceneErrorDomain];
            NSError *v8 = error;
            if (v2 && !error) {
                v8 = FBSceneErrorCreate(2, @"Scene was invalidated.", 0);
            }
            if (v8 != nil) {
                if (!v0) {
                    v0 = [self _createTransitionContext];
                }
                [v0 setError:v8];
            } else if ([v0 _indirect_isEmpty] != 0) {
                v0 = nil;
            }
            os_log_t log = FBLogScene();
            if (os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT)) {
                if (!v2) {
                    id loggingIdentifier = [self loggingIdentifier];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Deactivating scene: %{public}@", loggingIdentifier);
                } else {
                    id loggingIdentifier2 = [self loggingIdentifier];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Invalidating scene: %{public}@", loggingIdentifier2);
                }
            }
            self->_deactivating = YES;
            id v15 = [FBSceneEventQueue suspendIdleWorkForReason:@"deactivation"];
            if (!self->_workspace) {
                NSString *v60 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_workspace != nil"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v61 = NSStringFromSelector(@selector(_deactivateAndInvalidate:transitionContext:));
                    NSString *v62 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v61, v62, self, @"FBScene.m", 1628, v60);
                }
                _bs_set_crash_log_message([v60 UTF8String]);
                __break(0);
            }
            id v16 = [self->_layerManager _suspendUpdatesWithReason:@"deactivation"];
            self->_clientSettings = [self->_clientSettings copy:^void(FBSMutableSceneClientSettings *arg1) {
                [arg1 _removeVolatileSettings];
            }];
            id layers = [self->_clientSettings layers];
            [self->_layerManager _setLayers:layers];
            bool isActive = [self isActive];
            if (isActive) {
                [self _iterateObservers:^void(FBSceneObserver *arg1) {
                    [arg1 sceneWillDeactivate:self withContext:v0];
                }];
            }
            if (v2) {
                FBSScene *v22 = self->_parentScene;
                [v22 removeObserver:self];
            }
            FBSceneWorkspace *v23 = self->_workspace;
            id<FBSceneClient> v24 = self->_client;
            if (self->_active == 1) {
                v25 = (!self->_clientToken || v6) ? nil : self->_clientToken;
            } else {
                v25 = nil;
            }
            id<NSObject> v28 = v25;
            unsigned long v29 = self->_activationID;
            self->_active = NO;
            self->_deactivating = NO;
            self->_transactionID = 0;
            self->_lastForegroundingTransitionID = 0;
            [self _setContentState:0 notifyObservers:1 & ~self->_legacy];
            self->_clientToken = nil;
            self->_clientHandle = nil;
            self->_client = nil;
            if (!self->_legacy) {
                self->_clientProcess = nil;
            }
            if (!v2) {
                self->_settingsAtDeactivation = self->_settings;
            } else {
                self->_invalidated = YES;
                self->_workspace = nil;
                [self->_stateCaptureAssertion invalidate];
                self->_stateCaptureAssertion = nil;
                [self->_remnant invalidate];
                self->_remnant = nil;
            }
            void (^v39)(bool, NSError *) = ^void(bool arg1, NSError *arg2) {
                id loggingIdentifier;
                id succinctDescription;
                os_log_t log = FBLogScene();
                bool v66 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
                if (v2 != 1) {
                    if (!arg2) {
                        if (!v66) {
                            return;
                        }
                        loggingIdentifier = [self loggingIdentifier];
                        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@][%lu] Scene deactivated.", loggingIdentifier, v29);
                    } else {
                        if (!v66) {
                            return;
                        }
                        loggingIdentifier = [self loggingIdentifier];
                        succinctDescription = [arg2 succinctDescription];
                        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@][%lu] Scene deactivated with error: %{public}@.", loggingIdentifier, v29, succinctDescription);
                    }
                    return;
                } else if (!arg2) {
                    if (!v66) {
                        return;
                    }
                    loggingIdentifier = [self loggingIdentifier];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@][%lu] Scene invalidated.", loggingIdentifier, v29);
                    return;
                } else if (!v66) {
                    return;
                }
                loggingIdentifier = [self loggingIdentifier];
                succinctDescription = [arg2 succinctDescription];
                os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@][%lu] Scene invalidated with error: %{public}@.", loggingIdentifier, v29, succinctDescription);
            };
            if (v28 != nil) {
                [v24 host:self didInvalidateWithTransitionContext:v0 completion:v39];
            } else {
                v39(YES, nil);
            }
            [v24 unregisterHost:self];
            [self _iterateObservers:^void(FBSceneObserver *arg1) {
                if (isActive == 1) {
                    [arg1 sceneDidDeactivate:self withContext:v0];
                }
                if (v2 == 1) {
                    [arg1 sceneDidInvalidate:self withContext:v0];
                }
            }];
            if (v2) {
                [v23 sceneDidInvalidate:self];
            }
            [v16 invalidate];
            [v15 invalidate];
        }
    }
}


void -[FBScene sendActions:toExtension:](id a1, Class a2)
{
    os_log_t v8;
    id loggingIdentifier3;
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene sendActions:toExtension:]");
    }
    id fbs_singleLineDescriptionOfBSActions = [a1 fbs_singleLineDescriptionOfBSActions];
    os_log_t log = FBLogScene();
    bool v3 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (a2) {
        if (v3) {
            loggingIdentifier3 = [self loggingIdentifier];
            NSString *v5 = NSStringFromClass(a2);
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending action(s) to \"%{public}@\": %{public}@", loggingIdentifier3, v5, fbs_singleLineDescriptionOfBSActions);
        }
    } else if (v3) {
        loggingIdentifier3 = [self loggingIdentifier];
        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[%{public}@] Sending action(s): %{public}@", loggingIdentifier3, fbs_singleLineDescriptionOfBSActions);
    }
    if (self->_legacy == 1) {
        if (self->_invalidated == 1) {
            v8 = FBLogScene();
            if (os_log_type_enabled(v8, OS_LOG_TYPE_ERROR)) {
                id loggingIdentifier = [self loggingIdentifier];
                os_log_with_type(v8, OS_LOG_TYPE_ERROR, "[%{public}@]  Dropping actions for invalidated scene.", loggingIdentifier);
                return;
            } else {
                return;
            }
        }
    } else {
        if (!self->_active) {
            NSString *v19 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_active"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v20 = NSStringFromSelector(_cmd);
                NSString *v21 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBScene.m", 726, v19);
            }
            _bs_set_crash_log_message([v19 UTF8String]);
            __break(0);
        }
        if (self->_invalidated == 1) {
            NSString *v23 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"!_invalidated"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v24 = NSStringFromSelector(_cmd);
                NSString *v25 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v24, v25, self, @"FBScene.m", 727, v23);
            }
            _bs_set_crash_log_message([v23 UTF8String]);
            __break(0);
        }
    }
    if (a2 != 0 && ([self conformsToExtension:a2] & 1) == 0) {
        NSString *v27 = NSStringFromClass(a2);
        NSString *v28 = [NSString stringWithFormat:@"scene does not conform to extension \"%@\"", v27];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v29 = NSStringFromSelector(_cmd);
            NSString *v30 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v29, v30, self, @"FBScene.m", 731, v28);
        }
        _bs_set_crash_log_message([v28 UTF8String]);
        __break(0);
    }
    Class v9 = [BSAction class];
    for (id v16 in a1) {
        if (![v16 isKindOfClass:v9]) {
            NSString *v32 = [NSString stringWithFormat:@"only actions of type BSAction can be sent : tried to send %@", v16];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v33 = NSStringFromSelector(_cmd);
                NSString *v34 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v33, v34, self, @"FBScene.m", 736, v32);
            }
            _bs_set_crash_log_message([v32 UTF8String]);
            __break(0);
        }
    }
    if (!self->_clientToken) {
        v8 = FBLogScene();
        if (os_log_type_enabled(v8, OS_LOG_TYPE_ERROR)) {
            id loggingIdentifier2 = [self loggingIdentifier];
            os_log_with_type(v8, OS_LOG_TYPE_ERROR, "[%{public}@] Dropping actions for scene with no client.", loggingIdentifier2);
        }
    } else {
        [self->_client host:self didReceiveActions:a1 forExtension:a2];
    }
}


long -[FBScene sendActions:](long a1)
{
    return [self sendActions:a1 toExtension:0];
}


id -[FBScene succinctDescriptionBuilder](void)
{
    NSString *v2;
    NSString *v4;
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    if (!self->_workspaceIdentifier) {
        v2 = [self->_workspace identifier];
        v4 = [NSString stringWithFormat:@"%@:%@", v2, self->_identifier];
    } else {
        NSString *identifier = [self->_workspace identifier];
        if (![self->_workspaceIdentifier isEqualToString:identifier]) {
            NSString *identifier2 = [self->_workspace identifier];
            v4 = [NSString stringWithFormat:@"%@(%@):%@", self->_workspaceIdentifier, identifier2, self->_identifier];
        } else {
            v2 = [self->_workspace identifier];
            v4 = [NSString stringWithFormat:@"%@:%@", v2, self->_identifier];
        }
    }
    [v0 appendObject:v4 withName:0];
    return v0;
}


void -[FBScene invalidate:](void (^a1)(id))
{
    id v0;
    if (!a1) {
        v0 = nil;
    } else {
        v0 = [self _createTransitionContext];
        a1(v0);
    }
    [self _deactivateAndInvalidate:1 transitionContext:v0];
}


void -[FBScene clientToken:deactivateWithContext:](id a1, id a2)
{
    os_log_t oslog = FBLogScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id loggingIdentifier = [self loggingIdentifier];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Explicit client invalidation.", loggingIdentifier);
    }
    id v5 = a2;
    if (!a2) {
        v5 = [self _createTransitionContext];
    }
    NSError *error = [v5 error];
    NSError *v7 = FBSceneErrorCreate(5, @"Scene was invalidated by the client.", error);
    [v5 setError:v7];
    [self _deactivateClient:a1 withContext:v5];
}


void -[FBScene _deactivateClient:withContext:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    if (self != nil) {
        NSError *error = [v1 error];
        if (!error) {
            NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"error != nil"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(_deactivateClient:withContext:));
                NSString *v8 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v8, self, @"FBScene.m", 1571, v7);
            }
            _bs_set_crash_log_message([v7 UTF8String]);
            __break(0);
        }
        NSErrorDomain domain = [error domain];
        if (![domain isEqualToString:FBSceneErrorDomain]) {
            NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[[error domain] isEqualToString:FBSceneErrorDomain]"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v11 = NSStringFromSelector(@selector(_deactivateClient:withContext:));
                NSString *v12 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBScene.m", 1572, v10);
            }
            _bs_set_crash_log_message([v10 UTF8String]);
            __break(0);
        }
        [self _dispatchClientMessageWithBlock:^void(void) {
            if (v0 == self->_clientToken) {
                [self _deactivateAndInvalidate:0 transitionContext:v1];
                return;
            }
            os_log_t oslog = FBLogScene();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id loggingIdentifier = [self loggingIdentifier];
                id<NSObject> v2 = self->_clientToken;
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Ignoring client invalidation due to token mismatch (probably due to prior deactivation). expected=%p received=%p", loggingIdentifier, v2, v0);
            }
        }];
    }
}


id -[FBScene descriptionBuilderWithMultilinePrefix:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene descriptionBuilderWithMultilinePrefix:]");
    }
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendBool:self->_legacy withName:@"legacy" ifEqualTo:1];
    [succinctDescriptionBuilder appendBool:self->_invalidated withName:@"invalidated" ifEqualTo:1];
    if (!self->_invalidated) {
        [succinctDescriptionBuilder appendBool:self->_active withName:@"active"];
    }
    bool isForeground = [self->_settings isForeground];
    [succinctDescriptionBuilder appendBool:isForeground withName:@"FG"];
    [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
        FBSSceneSpecification *specification = [self->_definition specification];
        Class v6 = [specification class];
        [succinctDescriptionBuilder appendClass:v6 withName:@"specification"];
        FBSScene *v7 = self->_parentScene;
        id succinctDescription = [v7 succinctDescription];
        [succinctDescriptionBuilder appendObject:succinctDescription withName:@"parentScene" skipIfNil:1];
        id v4 = NSStringFromFBSceneContentState(self->_contentState);
        [succinctDescriptionBuilder appendString:v4 withName:@"contentState"];
        [succinctDescriptionBuilder appendObject:self->_settings withName:@"settings" skipIfNil:1];
        [succinctDescriptionBuilder appendObject:self->_clientSettings withName:@"clientSettings" skipIfNil:1];
        id v5 = [BSDescriptionBuilder succinctDescriptionForObject:self->_client];
        [succinctDescriptionBuilder appendObject:v5 withName:@"clientProvider"];
        [succinctDescriptionBuilder appendObject:self->_clientHandle withName:@"clientProcess"];
    }];
    return succinctDescriptionBuilder;
}


bool -[FBScene isMutable](void)
{
    if ((self->_inTransaction == 1 && self->_midUpdate) || self->_contentStateIsChanging || self->_deactivating) {
        return false;
    }
    if (!self->_configuringParameters) {
        return !self->_invalidated;
    } else {
        return false;
    }
}


void -[FBScene removeExtension:](id a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"extension != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBScene.m", 459, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    NSArray *v1 = @[a1];
    [self removeExtensions:v1];
}


long -[FBScene updateSettings:withTransitionContext:](long a1, long a2)
{
    return [self updateSettings:a1 withTransitionContext:a2 completion:0];
}


void -[FBScene removeExtensions:](id a1)
{
    id v0 = a1;
    if ([a1 count] != 0) {
        FBSSceneSpecification *specification = [self->_definition specification];
        id v2 = FBSGetDefaultExtensions(specification);
        [self updateSettings:^void(FBSMutableSceneSettings *arg1) {
            for (Class v9 in v0) {
                if ([v2 containsObject:v9]) {
                    os_log_t oslog = FBLogScene();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        id identity = [self->_definition identity];
                        NSString *v12 = NSStringFromClass(v9);
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Cannot remove extension \"%{public}@\" because it is part of this scene's specification", identity, v12);
                    }
                } else {
                    [arg1 _removeSceneExtension:v9];
                    continue;
                }
            }
        }];
    }
}


long -[FBScene description](void)
{
    return [self succinctDescription];
}


void -[FBScene clientToken:didInvalidateWithError:](id a1, id a2)
{
    id _createTransitionContext = [self _createTransitionContext];
    [_createTransitionContext setError:a2];
    [self _deactivateClient:a1 withContext:_createTransitionContext];
}


void -[FBScene(UIApp) updateUISettingsWithBlock:](void (^a1)(FBSMutableSceneSettings *))
{
    long v2;
    void (^v0)(FBSMutableSceneSettings *) = a1;
    if (a1 != nil) {
        [self updateSettingsWithBlock:^void(FBSMutableSceneSettings *arg1) {
            if (([arg1 _uikitShimming_isUISubclass] & 1) == 0) {
                NSString *v5 = [NSString stringWithFormat:@"settings is of an unexpected class : %@", arg1];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v8 = NSStringFromSelector(v2);
                    NSString *v3 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v3, self, @"FBScene+UIApp.m", 36, v5);
                }
                _bs_set_crash_log_message([v5 UTF8String]);
                __break(0);
            }
            v0(arg1);
        }];
    }
}


FBSceneSnapshot *-[FBScene prepareSnapshotWithConfigurator:](void (^a1)(FBSceneSnapshotContext *))
{
    return [[FBSceneSnapshot alloc] initWithScene:self context:[[FBSceneSnapshotContext alloc] initWithScene:self configurator:a1]];
}


FBSceneSnapshot *-[FBScene prepareSnapshot](void)
{
    return [[FBSceneSnapshot alloc] initWithScene:self context:[[FBSceneSnapshotContext alloc] initWithScene:self configurator:nil]];
}


id -[FBScene parameters](void)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene parameters]");
    }
    FBSSceneSpecification *specification = [self->_definition specification];
    id v1 = [FBSSceneParameters parametersForSpecification:specification];
    FBSSceneSettings *settings = [self settings];
    [v1 setSettings:settings];
    [v1 setClientSettings:self->_clientSettings];
    return v1;
}


long -[FBScene add:](long a1)
{
    return [self addObserver:a1];
}


long -[FBScene remove:](id a1)
{
    return [self removeObserver:a1];
}


void -[FBScene deactivate:](void (^a1)(id))
{
    id v0;
    if (!a1) {
        v0 = nil;
    } else {
        v0 = [self _createTransitionContext];
        a1(v0);
    }
    [self deactivateWithTransitionContext:v0];
}


void -[FBScene deactivateWithTransitionContext:](long a1)
{
    [self _deactivateAndInvalidate:0 transitionContext:a1];
}


id -[FBScene createSnapshot](void)
{
    id snapshotContext = [self snapshotContext];
    return [self createSnapshotWithContext:snapshotContext];
}


FBSceneSnapshot *-[FBScene createSnapshotWithContext:](id a1)
{
    FBSceneSnapshot *v2;
    if (![self isValid] || !self->_active) {
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id loggingIdentifier = [self loggingIdentifier];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "cannot take a snapshot for an invalid or inactive scene: %{public}@", loggingIdentifier);
        }
        v2 = nil;
    } else if (a1) {
        v2 = [[FBSceneSnapshot alloc] initWithScene:self context:a1];
    } else {
        v2 = nil;
    }
    return v2;
}


FBSceneSnapshotContext *-[FBScene snapshotContext](void)
{
    return [[FBSceneSnapshotContext alloc] initWithScene:self configurator:nil];
}


void -[FBScene sceneWillInvalidate:](long a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene sceneWillInvalidate:]");
    }
    os_log_t oslog = FBLogScene();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id loggingIdentifier = [self loggingIdentifier];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Parent scene invalidated", loggingIdentifier);
    }
    [self setParentScene:nil];
}


void -[FBScene sendInvocation:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene sendInvocation:]");
    }
    if (![self isActive]) {
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            id loggingIdentifier = [self loggingIdentifier];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[%{public}@] Dropping invocations for non-active scene.", loggingIdentifier);
        }
        [a1 cannotResolveForReason:@"scene is not active"];
    } else {
        id resolve = [a1 resolve];
        if (!resolve) {
            [self->_client host:self sendInvocation:a1 withReply:nil];
        } else {
            [self->_client host:self sendInvocation:a1 withReply:^void(FBSInvocationReply *arg1, NSError *arg2) {
                [self _dispatchClientMessageWithBlock:^void(void) {
                    resolve->field_16(resolve, arg1, arg2);
                }];
            }];
        }
    }
}


BOOL -[FBScene conformsToExtension:](id a1)
{
    BOOL v2;
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene conformsToExtension:]");
    }
    FBSSceneSettings *settings = [self settings];
    Class v1 = [FBSSceneExtension class];
    if (![a1 isSubclassOfClass:v1]) {
        v2 = [settings conformsToExtension:a1];
    } else {
        FBSSceneSpecification *specification = [self->_definition specification];
        id v4 = FBSGetDefaultExtensions(specification);
        if (![v4 containsObject:a1]) {
            id _allSceneExtensions = [settings _allSceneExtensions];
            v2 = [_allSceneExtensions containsObject:a1];
        } else {
            v2 = YES;
        }
    }
    return v2;
}


long -[FBScene debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBScene hostProcess](void)
{
    id domain = [self->_workspace domain];
    return [domain currentProcess];
}


FBSSceneSpecification *-[FBScene specification](void)
{
    return [self->_definition specification];
}


id -[FBScene descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


unsigned long -[FBScene _transactionID](void)
{
    return self->_transactionID;
}


bool -[FBScene _isInTransaction](void)
{
    return self->_inTransaction;
}


id -[FBScene(DEPRECATED) display](void)
{
    FBSSceneSettings *settings = [self settings];
    return [settings displayConfiguration];
}


id -[FBScene _componentProxiesForExtension:](id a1)
{
    if (!self) {
        return nil;
    }
    id v1 = [self->_components objectForKey:a1];
    id v2 = [v1 copy];
    return (!v2) ? @[] : v2;
}


void -[FBScene clientToken:handleInvocation:withReply:](id a1, id a2, id a3)
{
    [self _dispatchClientMessageWithBlock:^void(void) {
        if (a1 == self->_clientToken) {
            [a2 invokeWithReceiver:self replyHandler:a3];
            return;
        }
        os_log_t oslog = FBLogScene();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id loggingIdentifier = [self loggingIdentifier];
            id<NSObject> v1 = self->_clientToken;
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[%{public}@] Ignoring invocations due to token mismatch (probably due to prior deactivation). expected=%p received=%p", loggingIdentifier, v1, a1);
        }
    }];
}


id -[FBScene targetForInvocation:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBScene targetForInvocation:]");
    }
    long extension = [a1 extension];
    id v3 = [self _componentProxiesForExtension:extension];
    for (id v9 in v3) {
        id component = [v9 component];
        if (([a1 compatibleWithTarget:component] & 1) != 0) {
            return component;
        }
    }
    return nil;
}
