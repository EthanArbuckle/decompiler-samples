struct FBApplicationProcessWatchdogPolicy {
    double _deviceLaunchScale; // +0x8
    double _deviceResumeScale; // +0x10
    double _additionalFirstPartyScale; // +0x18
    bool _enableThirdPartyPre9; // +0x20
    int _daNotificationToken; // +0x24
    NSDictionary *_watchdogPolicyExceptions; // +0x28
    NSObject<OS_dispatch_queue> *_queue; // +0x30
};

long -[FBApplicationProcessWatchdogPolicy watchdogPolicyForProcess:eventContext:](id a1, id a2)
{
    void *v5;
    double v18;
    double v23;
    long v27;
    FBSApplicationInfo *applicationInfo;
    uint8_t v6[32];
    long v28;
    long event = [a2 event];
    long isApplicationProcess = [a1 isApplicationProcess];
    if ((isApplicationProcess & 1) != 0 || event != 1) {
        applicationInfo = [a1 applicationInfo];
        v5 = &v6;
        *(uint64_t *)&v6[0] = 0;
        if ((unsigned long)(event - 2) < 2) {
            FBSSceneSettings *sceneSettings = [a2 sceneSettings];
            bool isForeground = [sceneSettings isForeground];
            FBSceneUpdateContext *sceneUpdateContext = [a2 sceneUpdateContext];
            FBSSceneSettingsDiff *settingsDiff = [sceneUpdateContext settingsDiff];
            long v12 = [settingsDiff containsProperty:@selector(isForeground)];
            if (((isForeground | v12) & 1) == 0) {
                FBSSceneTransitionContext *sceneTransitionContext = [a2 sceneTransitionContext];
                long allowCPUThrottling = [sceneTransitionContext allowCPUThrottling];
                if ((allowCPUThrottling & 1) == 0) {
                    v5->field_24 = 0x403e000000000000;
                }
                NSProcessInfo *processInfo = [NSProcessInfo processInfo];
                NSProcessInfoThermalState thermalState = [processInfo thermalState];
                long v17 = 1.0;
                if ((unsigned long)(thermalState - 1) < 3) {
                    v17 = (&qword_1c4f5d358)[thermalState - 1];
                }
                v5->field_24 = v17 * v5->field_24;
            } else {
                v5->field_24 = 0x4024000000000000;
            }
            v18 = -1.0;
            if (isForeground) {
                dispatch_sync(self->_queue, ^void(void) {
                    [self _queue_watchdogScalingFactorForAppInfo:applicationInfo isResume:1];
                    void *v40 = *(uint64_t *)&v6[8];
                    v40->field_24 = a2 * v40->field_24;
                });
            }
        } else if (event == 4) {
            FBSSceneTransitionContext *sceneTransitionContext2 = [a2 sceneTransitionContext];
            id _uiApplicationSceneTransitionContextShim = [sceneTransitionContext2 _uiApplicationSceneTransitionContextShim];
            if (!_uiApplicationSceneTransitionContextShim) {
                v23 = 5.0;
            } else if (([_uiApplicationSceneTransitionContextShim waitForBackgroundTaskCompletion] & 1) == 0) {
                v23 = 5.0;
            } else {
                v23 = 60.0;
            }
            v5->field_24 = v23;
            v18 = -1.0;
        } else {
            v18 = -1.0;
            if (event == 1) {
                goto blk_1c4ee8048;
            }
        }
blk_1c4ee82c4:
        NSString *bundleIdentifier = [a1 bundleIdentifier];
        id v25 = [self->_watchdogPolicyExceptions objectForKey:bundleIdentifier];
        if (v25 != nil) {
            double doubleValue = [v25 doubleValue];
            v5->field_24 = doubleValue + v5->field_24;
        }
        if (v5->field_24 <= 0.0) {
            v27 = 0;
        } else {
            FBSProcessResourceAllowanceMakeWithRealTimeInterval(&v28);
            id v29 = [FBSProcessResourceProvision provisionWithAllowance:&v28];
            if (v18 <= 0.0) {
                NSArray *v30 = @[v29];
                v27 = [FBSProcessWatchdogPolicy policyWithProvisions:v30];
            } else {
                FBSProcessResourceAllowanceMakeWithScheduledTimeInterval(&v28, v18);
                id v31 = [FBSProcessResourceProvision provisionWithAllowance:&v28];
                NSArray *v33 = @[v29, v31];
                v27 = [FBSProcessWatchdogPolicy policyWithProvisions:v33];
            }
        }
        _Block_object_dispose(v6, 8);
    } else {
        FBProcessExecutionContext *executionContext = [a1 executionContext];
        if ([executionContext forSceneActivation]) {
            applicationInfo = [a1 applicationInfo];
            *(uint64_t *)&v6[0] = 0;
            *(uint64_t *)&v6[8] = &v6;
            *(uint64_t *)&v6[16] = 0x2020000000;
            *(uint64_t *)&v6[24] = 0xbff0000000000000;
blk_1c4ee8048:
            FBProcessExecutionContext *executionContext2 = [a1 executionContext];
            long launchIntent = [executionContext2 launchIntent];
            v18 = -1.0;
            long v38 = launchIntent - 3;
            if ((unsigned long)(launchIntent - 3) >= 3) {
                if (launchIntent == 2) {
                    v5->field_24 = 0x403e000000000000;
                    v18 = 10.0;
                    goto blk_1c4ee82c4;
                }
            } else {
                v5->field_24 = 0x4034000000000000;
                if ((unsigned long)v38 <= 1) {
                    dispatch_sync(self->_queue, ^void(void) {
                        [self _queue_watchdogScalingFactorForAppInfo:applicationInfo isResume:0];
                        void *v41 = *(uint64_t *)&v6[8];
                        v41->field_24 = a2 * v41->field_24;
                    });
                    goto blk_1c4ee82c4;
                }
            }
            goto blk_1c4ee82c4;
        }
        v27 = 0;
    }
    return v27;
}


FBApplicationProcessWatchdogPolicy *+[FBApplicationProcessWatchdogPolicy defaultPolicy](void)
{
    dispatch_once(&defaultPolicy.onceToken, ^void(void) {
        defaultPolicy.__DefaultPolicy = [[FBApplicationProcessWatchdogPolicy alloc] init];
    });
    return defaultPolicy.__DefaultPolicy;
}


FBApplicationProcessWatchdogPolicy *-[FBApplicationProcessWatchdogPolicy init](void)
{
    FBApplicationProcessWatchdogPolicy *v1 = [super init];
    if (v1 != nil) {
        v1->_deviceLaunchScale = 1.0;
        v1->_additionalFirstPartyScale = 1.0;
        v1->_enableThirdPartyPre9 = NO;
        v1->_queue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.FBApplicationProcessWatchdogPolicy");
        dispatch_async(v1->_queue, ^void(void) {
            [v1 _queue_reloadDefaultSettings];
        });
        __weak FBApplicationProcessWatchdogPolicy *v7 = v1;
        notify_register_dispatch("com.apple.da.tasking_changed", &v1->_daNotificationToken, v1->_queue, ^void(int arg1) {
            [v7 _queue_reloadDefaultSettings];
        });
    }
    return v1;
}


NSUserDefaults *+[FBApplicationProcessWatchdogPolicy _defaultLaunchScale](void)
{
    NSUserDefaults *standardUserDefaults;
    if (os_variant_has_internal_content("+[FBApplicationProcessWatchdogPolicy _defaultLaunchScale]") != 0) {
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        double v1 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogScaleOverride"];
        if (v1 > 0.0) {
            return standardUserDefaults;
        }
    }
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    double v2 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogScale"];
    if (v2 > 0.0) {
        return standardUserDefaults;
    }
    return [FBApplicationProcessWatchdogPolicy _scaleForGestaltKey:@"DeviceLaunchTimeLimitScale"];
}


double +[FBApplicationProcessWatchdogPolicy _scaleForGestaltKey:](long a1)
{
    long v0 = BSSystemHasCapability(@"LaunchTimeLimitScaleSupported");
    double v1 = 1.0;
    if (!v0) {
        return v1;
    }
    id v2 = MGCopyAnswer(a1, 0);
    id v3 = v2;
    if (v2 != nil) {
        v1 = [v2 doubleValue];
    }
    fbs_release(&v3);
    return v1;
}


NSUserDefaults *+[FBApplicationProcessWatchdogPolicy _defaultResumeScale](void)
{
    NSUserDefaults *standardUserDefaults;
    if (os_variant_has_internal_content("+[FBApplicationProcessWatchdogPolicy _defaultResumeScale]") != 0) {
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        double v1 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogResumeScaleOverride"];
        if (v1 > 0.0) {
            return standardUserDefaults;
        }
    }
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    double v2 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogResumeScale"];
    if (v2 > 0.0) {
        return standardUserDefaults;
    }
    return [FBApplicationProcessWatchdogPolicy _scaleForGestaltKey:@"DeviceSceneUpdateTimeLimitScale"];
}


NSUserDefaults *+[FBApplicationProcessWatchdogPolicy _defaultFirstPartyAdditionalScale](void)
{
    NSUserDefaults *standardUserDefaults;
    if (os_variant_has_internal_content("+[FBApplicationProcessWatchdogPolicy _defaultFirstPartyAdditionalScale]") != 0) {
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        double v1 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogFirstPartyScaleOverride"];
        if (v1 > 0.0) {
            return standardUserDefaults;
        }
    }
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    double v2 = [standardUserDefaults doubleForKey:@"FBLaunchWatchdogFirstPartyScale"];
    if (v2 > 0.0) {
        return standardUserDefaults;
    }
    return [FBApplicationProcessWatchdogPolicy _scaleForGestaltKey:@"FirstPartyLaunchTimeLimitScale"];
}


void -[FBApplicationProcessWatchdogPolicy _queue_watchdogScalingFactorForAppInfo:isResume:](id a1, int a2)
{
    if (a1 != nil) {
        long type = [a1 type];
        if ([a1 type] != 2 || self->_enableThirdPartyPre9) {
            if (type != 0) {
                [a1 type];
            }
        } else {
            long v2 = [a1 builtOnOrAfterSDKVersion:@"10.0"];
            if (v2 != 0 && type != 0) {
                [a1 type];
            }
        }
    }
}


void -[FBApplicationProcessWatchdogPolicy dealloc](void)
{
    int v0 = self->_daNotificationToken;
    dispatch_sync(self->_queue, ^void(void) {
        notify_cancel(v0);
    });
    [super dealloc];
}


void -[FBApplicationProcessWatchdogPolicy _queue_reloadDefaultSettings](void)
{
    self->_deviceLaunchScale = [[self class] _defaultLaunchScale];
    self->_deviceResumeScale = [[self class] _defaultResumeScale];
    self->_additionalFirstPartyScale = [[self class] _defaultFirstPartyAdditionalScale];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self->_enableThirdPartyPre9 = [standardUserDefaults boolForKey:@"FBLaunchWatchdogEnableThirdPartyPre9"];
    NSUserDefaults *standardUserDefaults2 = [NSUserDefaults standardUserDefaults];
    NSDictionary<NSString *, id> *v2 = [standardUserDefaults2 dictionaryForKey:@"FBLaunchWatchdogExceptions"];
    self->_watchdogPolicyExceptions = [v2 copy];
}


void -[FBApplicationProcessWatchdogPolicy .cxx_destruct](void)
{
    self->_queue = nil;
    self->_watchdogPolicyExceptions = nil;
}
