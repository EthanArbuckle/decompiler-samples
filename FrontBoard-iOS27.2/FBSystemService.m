struct FBSystemService {
    BSServiceDispatchQueue *_queue; // +0x8
    BSServiceConnectionListener *_legacyOpenServiceListener; // +0x10
    int _pendingExit; // +0x18
    id<FBSApplicationInfoProvider> _lock_defaultInfoProvider; // +0x20
    struct os_unfair_lock_s _defaultInfoProviderLock; // +0x28
    struct _AKSEvent *_aksEvent; // +0x30
    double _BTLPMTimeout; // +0x38
    NSObject<OS_dispatch_group> *_BTLPMTimeoutFetchGroup; // +0x40
    __weak id<FBSystemServiceDelegate> _delegate; // +0x48
};

static long FBDebugApplicationsEntitlement;
static long FBDebugApplicationsEntitlementLegacy;
static long FBDebugApplicationsEntitlementLegacyLegacy;
static long FBLaunchApplicationsEntitlement;
static long FBLaunchApplicationsEntitlementLegacy;
static long FBLaunchApplicationsEntitlementLegacyLegacy;
static long FBOpenSensitiveURLEntitlementLegacy;

id +[FBSystemService sharedInstanceIfExists](void)
{
    id sharedInstanceDomain = [FBServiceFacilityServer sharedInstanceDomain];
    return [FBSystemService _sharedInstanceCreatingIfNecessary:sharedInstanceDomain != nil];
}


id +[FBSystemService _sharedInstanceCreatingIfNecessary:](int a1)
{
    Class v0 = objc_opt_self(self);
    os_unfair_lock_lock(&_sharedInstanceCreatingIfNecessary:.__lock);
    id v1 = _sharedInstanceCreatingIfNecessary:.__sharedInstance;
    if (a1 != 0 && !_sharedInstanceCreatingIfNecessary:.__sharedInstance) {
        id v4 = [[v0 alloc] initWithQueue:[BSServiceDispatchQueue mainQueue]];
        _sharedInstanceCreatingIfNecessary:.__sharedInstance = v4;
        v1 = v4;
    }
    os_unfair_lock_unlock(&_sharedInstanceCreatingIfNecessary:.__lock);
    return v1;
}


void -[FBSystemService listener:didReceiveConnection:withContext:](long a1, id a2, long a3)
{
    id v0 = a2;
    [v0 configureConnection:^void(id<BSServiceConnectionConfiguring> arg1) {
        id targetQueue = [FBSystemAppProxyServiceServer targetQueue];
        [arg1 setQueue:targetQueue];
        id interface = [FBSOpenApplicationServiceSpecification interface];
        [arg1 setInterface:interface];
        [arg1 setInterfaceTarget:self];
        [arg1 setInvalidationHandler:^void(BSServiceConnection<BSServiceConnectionContext> *arg1) {
            [v0 invalidate];
        }];
    }];
    [v0 activate];
}


id<FBSApplicationInfoProvider> -[FBSystemService _applicationInfoProvider](void)
{
    os_unfair_lock_lock(&self->_defaultInfoProviderLock);
    id<FBSApplicationInfoProvider> v0 = self->_lock_defaultInfoProvider;
    os_unfair_lock_unlock(&self->_defaultInfoProviderLock);
    return v0;
}


void -[FBSystemService _activateBundleID:requestID:isTrusted:options:serviceInstance:source:originalSourceToken:withResult:](id a1, id a2, int a3, FBSOpenApplicationOptions *a4, id a5, id a6, id a7, void (^a8)(NSError *))
{
    double v26;
    int v28;
    id v0 = a1;
    id v1 = a2;
    FBSOpenApplicationOptions *v2 = a4;
    id v3 = a5;
    id v4 = a6;
    id v5 = a7;
    void (^v6)(NSError *) = a8;
    [self->_queue assertBarrierOnQueue];
    if (!v0) {
        NSString *v45 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"bundleID != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v46 = NSStringFromSelector(_cmd);
            NSString *v47 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v46, v47, self, @"FBSystemService.m", 527, v45);
        }
        _bs_set_crash_log_message([v45 UTF8String]);
        __break(0);
    }
    if (!v1) {
        NSString *v49 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"requestID != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v50 = NSStringFromSelector(_cmd);
            NSString *v51 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v50, v51, self, @"FBSystemService.m", 528, v49);
        }
        _bs_set_crash_log_message([v49 UTF8String]);
        __break(0);
    }
    if (!v4) {
        NSString *v53 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"sourceToken != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v54 = NSStringFromSelector(_cmd);
            NSString *v55 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v54, v55, self, @"FBSystemService.m", 529, v53);
        }
        _bs_set_crash_log_message([v53 UTF8String]);
        __break(0);
    }
    if (!v5) {
        NSString *v57 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"originalSourceToken != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v58 = NSStringFromSelector(_cmd);
            NSString *v59 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v58, v59, self, @"FBSystemService.m", 530, v57);
        }
        _bs_set_crash_log_message([v57 UTF8String]);
        __break(0);
    }
    if (v6 != nil) {
        NSString *v11 = FBSystemAppBundleID();
        if ([v0 isEqualToString:v11]) {
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Open request is targeting the system app itself; swizzling bundleID to nil.", v1);
            }
            v0 = nil;
        }
        id dictionary = [v2 dictionary];
        id v15 = [dictionary objectForKey:FBSOpenApplicationOptionKeyServiceAvailabilityTimeout];
        double doubleValue = [v15 doubleValue];
        CFTimeInterval v17 = CACurrentMediaTime();
        bool v18 = ((doubleValue > 0.0) ? !v15 : 1) == 1;
        double v19 = fmin(doubleValue, 30.0);
        double v21 = (((doubleValue > 0.0) ? !v15 : 1) == 1) ? v17 : v17 + v19;
        double v22 = (((doubleValue > 0.0) ? !v15 : 1) == 1) ? doubleValue : v19;
        id v23 = [dictionary objectForKey:FBSOpenApplicationOptionKeyLSSequenceNumber];
        NSString *v24 = [dictionary objectForKey:FBSOpenApplicationOptionKeyLSCacheGUID];
        NSUUID *v25 = v24;
        if (v24 != nil) {
            v25 = [[NSUUID alloc] initWithUUIDString:v24];
            if (((!v23) ? 0 : v18) == 1 && v25 != nil) {
                v22 = fmin(fmax(v22, 0.0), 2.0);
                v21 = v22 + v21;
                v26 = 0.5;
                goto blk_1c4ef7704;
            }
        }
        v26 = 2.0;
        if (!v18) {
blk_1c4ef7704:
            os_log_t oslog2 = FBLogCommon();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Activation request for %{public}@ will wait %.2fs for app availability, with retry every %.2fs.", v1, v0, v22, v26);
            }
            v28 = 1;
        } else {
            v28 = 0;
        }
        __block bool v30 = false;
        __block void (^byref1)(void) = nil;
        void (^v41)(void) = [^void(void) {
            id v72;
            id<FBSApplicationInfoProvider> _applicationInfoProvider = [self _applicationInfoProvider];
            id v66 = [_applicationInfoProvider applicationInfoForBundleIdentifier:v0];
            long sequenceNumber = [v66 sequenceNumber];
            id cacheGUID = [v66 cacheGUID];
            if (v30 == 1) {
                id v73 = [LSApplicationProxy applicationProxyForIdentifier:v0];
                sequenceNumber = [v73 sequenceNumber];
                v72 = [v73 cacheGUID];
            } else {
                v72 = cacheGUID;
            }
            BSAction *v67 = [[BSAction alloc] initWithInfo:0 responder:[BSActionResponder responderWithHandler:^void(BSActionResponse *arg1) {
                NSError *error = [arg1 error];
                NSInteger code = [error code];
                if (code != 1) {
                    return;
                }
                byref1 = nil;
            }]];
            NSUInteger unsignedIntegerValue = [v23 unsignedIntegerValue];
            void (^v69)(NSError *) = ^void(NSError *arg1) {
                [v67 invalidate];
                NSErrorDomain domain = [arg1 domain];
                BOOL v87 = [domain isEqualToString:FBSOpenApplicationErrorDomain];
                if (v87) {
                    NSInteger code = [arg1 code];
                    if ((unsigned long)code <= 9 && ((1 << code) & 592) != 0 && v28 == 1) {
                        os_log_t oslog3 = FBLogCommon();
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                            id v91 = FBSOpenApplicationErrorCodeToString(code);
                            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Retry attempt failed for %{public}@ with reason \"%{public}@\"", v1, v0, v91);
                        }
                        CFTimeInterval v82 = CACurrentMediaTime();
                        if (v17 >= v82 || v82 >= v21) {
                            if (code != 9 || (code == 9 && v30)) {
                                os_log_t oslog = FBLogCommon();
                                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                                    id v84 = FBSProcessPrettyDescription(v4);
                                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Exhausted retry attempts for opening application: %{public}@ from source: %{public}@", v1, v0, v84);
                                }
                                goto blk_1c4efac80;
                            }
                            os_log_t oslog2 = FBLogCommon();
                            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                                id v86 = FBSProcessPrettyDescription(v4);
                                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Attempting final launch request of: %{public}@ from source: %{public}@", v1, v0, v86);
                            }
                            v30 = true;
                        }
                        [self->_queue performAfter:v26 withBlock:byref1];
                        return;
                    }
                }
blk_1c4efac80:
                v6(arg1);
                byref1 = nil;
            };
            [self _reallyActivateApplication:v0 requestID:v1 options:v2 serviceInstance:v3 source:v4 originalSourceToken:v5 isTrusted:a3 sequenceNumber:unsignedIntegerValue cacheGUID:v25 ourSequenceNumber:sequenceNumber ourCacheGUID:v72 withResult:v69];
        } copy];
        byref1 = v41;
        void (^v44)(void) = byref1;
        v44();
        return;
    }
    NSString *v61 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"resultBlock != ((void *)0)"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v62 = NSStringFromSelector(_cmd);
        NSString *v63 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v62, v63, self, @"FBSystemService.m", 531, v61);
    }
    _bs_set_crash_log_message([v61 UTF8String]);
    __break(0);
}


void -[FBSystemService _reallyActivateApplication:requestID:options:serviceInstance:source:originalSourceToken:isTrusted:sequenceNumber:cacheGUID:ourSequenceNumber:ourCacheGUID:withResult:](id a1, id a2, FBSOpenApplicationOptions *a3, id a4, long a5, id a6, long a7, long a8, id a9, long a10, id a11, void (^a12)(NSError *))
{
    NSError *v16;
    os_log_t v10;
    long v11;
    long v12;
    long v13;
    uint8_t v14[32];
    id v0 = a1;
    FBSOpenApplicationOptions *v2 = a3;
    id v4 = a6;
    void (^v7)(NSError *) = a12;
    id<FBSApplicationInfoProvider> _applicationInfoProvider = [self _applicationInfoProvider];
    id v9 = [_applicationInfoProvider applicationInfoForBundleIdentifier:v0];
    if (v0 && a9) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *UUIDString = [a9 UUIDString];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Attempting activation of %@ with {UUID: %{public}@, Sequence: %lu} vs {UUID: %{public}@, Sequence: %lu}", a2, v0, UUIDString, a8, a11, a10);
        }
        if ([self _shouldPendRequestForClientSequenceNumber:a8 clientCacheGUID:a9 ourSequenceNumber:a10 ourCacheGUID:a11]) {
            os_log_t oslog2 = FBLogCommon();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Pending activate request due to LS value mismatch.\n\tClient LS values: {%{public}@, %lu}\n\t Our LS values: {%{public}@, %lu}", a2, a9, a8, a11, a10);
            }
            v16 = FBSOpenApplicationErrorCreate(9, @"LaunchServices GUID and sequence number do not match expected values.");
            v7(v16);
            return;
        }
    }
    if (!v0 || v9 != nil) {
        if (([v9 _isInstalling] & 1) != 0) {
            v10 = FBLogCommon();
            if (os_log_type_enabled(v10, OS_LOG_TYPE_DEFAULT)) {
                v11 = [v9 _isInstalling];
                v12 = [v9 _isUninstalling];
                v13 = [v9 _isPendingUninstall];
                os_log_with_type(v10, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Application \"%@\" is installing (%d), uninstalling (%d), or pending uninstall (%d) and cannot be launched.", a2, v0, v11, v12, v13);
            }
            v16 = FBSOpenApplicationErrorCreate(6, @"Application \"%@\" is installing or uninstalling, and cannot be launched.", v0);
            v7(v16);
            return;
        }
        if (([v9 _isUninstalling] & 1) == 0) {
            if ([v9 _isPendingUninstall]) {
                if (([v9 _isTentativeUninstall] & 1) == 0) {
                    v10 = FBLogCommon();
                    if (os_log_type_enabled(v10, OS_LOG_TYPE_DEFAULT)) {
                        v11 = [v9 _isInstalling];
                        v12 = [v9 _isUninstalling];
                        v13 = [v9 _isPendingUninstall];
                        os_log_with_type(v10, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Application \"%@\" is installing (%d), uninstalling (%d), or pending uninstall (%d) and cannot be launched.", a2, v0, v11, v12, v13);
                    }
                    v16 = FBSOpenApplicationErrorCreate(6, @"Application \"%@\" is installing or uninstalling, and cannot be launched.", v0);
                    v7(v16);
                    return;
                }
            }
            id<FBSystemServiceDelegate> delegate = [self delegate];
            if (!delegate) {
                NSError *v27 = FBSOpenApplicationErrorCreate(8, @"No delegate exists to handle open application requests.");
                v7(v27);
            } else if (![delegate respondsToSelector:@selector(systemService:handleOpenApplicationRequest:withCompletion:)]) {
                NSURL *url = [v2 url];
                if (a7) {
                    if ([delegate respondsToSelector:@selector(systemService:handleOpenApplicationRequest:options:origin:withResult:)]) {
                        FBOpenAppSystemServiceExecuteCallOut(a4, ^void(void) {
                            id dictionary = [v2 dictionary];
                            [delegate systemService:self handleOpenApplicationRequest:v0 options:dictionary origin:v4 withResult:^void(long arg1) {
                                id v44 = FBSOpenApplicationErrorCodeToString(arg1);
                                NSError *v42 = FBSOpenApplicationErrorCreate(arg1, @"Service delegate denied open-application request for reason: %@", v44);
                                v7(v42);
                            }];
                        });
                        return;
                    }
                } else if (url) {
                    if (![delegate respondsToSelector:@selector(systemService:handleOpenURLRequest:application:options:origin:withResult:)]) {
                        NSError *v35 = FBSOpenApplicationErrorCreate(8, @"Service delegate does not implement -handleOpenURLRequest:");
                        v7(v35);
                    } else {
                        FBOpenAppSystemServiceExecuteCallOut(a4, ^void(void) {
                            id dictionary = [v2 dictionary];
                            [delegate systemService:self handleOpenURLRequest:url application:v0 options:dictionary origin:v4 withResult:^void(long arg1) {
                                id v40 = FBSOpenApplicationErrorCodeToString(arg1);
                                NSError *v38 = FBSOpenApplicationErrorCreate(arg1, @"Service delegate denied open-URL request for reason: %@", v40);
                                v7(v38);
                            }];
                        });
                    }
                    return;
                }
                NSError *v29 = FBSOpenApplicationErrorCreate(8, @"Service delegate does not implement -handleOpenApplicationRequest:");
                v7(v29);
            } else {
                FBSystemServiceOpenApplicationRequest *v31 = [[FBSystemServiceOpenApplicationRequest alloc] initWithBundleId:v0];
                [v31 setTrusted:a7];
                [v31 setOptions:v2];
                id sharedInstance = [FBProcessManager sharedInstance];
                if (!v4) {
                    _memset(v14, 0, 32);
                } else {
                    [v4 realToken];
                }
                FBProcess *v33 = [sharedInstance registerProcessForAuditToken:&v14];
                [v31 setClientProcess:v33];
                FBOpenAppSystemServiceExecuteCallOut(a4, ^void(void) {
                    [delegate systemService:self handleOpenApplicationRequest:v31 withCompletion:v7];
                });
            }
            return;
        }
        v10 = FBLogCommon();
        if (os_log_type_enabled(v10, OS_LOG_TYPE_DEFAULT)) {
            v11 = [v9 _isInstalling];
            v12 = [v9 _isUninstalling];
            v13 = [v9 _isPendingUninstall];
            os_log_with_type(v10, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Application \"%@\" is installing (%d), uninstalling (%d), or pending uninstall (%d) and cannot be launched.", a2, v0, v11, v12, v13);
        }
        v16 = FBSOpenApplicationErrorCreate(6, @"Application \"%@\" is installing or uninstalling, and cannot be launched.", v0);
        v7(v16);
    } else {
        NSError *v18 = FBSOpenApplicationErrorCreate(4, @"Application \"%@\" is unknown to FrontBoard.", v0);
        v7(v18);
    }
    return;
}


void -[FBSystemService openApplication:withOptions:originator:requestID:completion:](id a1, id a2, id a3, id a4, id a5)
{
    long v20;
    NSError *v21;
    os_log_t v31;
    id v76;
    id v77;
    id v78;
    id v79;
    id v92;
    long v93;
    BSAction *v98;
    void (^v100)(long, NSError *);
    id<FBSApplicationInfoProvider> v101;
    void (^v103)(void);
    NSError *v82;
    uint8_t v6[32];
    id v0 = a1;
    id v1 = a3;
    id currentContext = [BSServiceConnection currentContext];
    id remoteProcess = [currentContext remoteProcess];
    id v4 = FBSProcessPrettyDescription(remoteProcess);
    if (!v1) {
        v1 = remoteProcess;
    } else if (([remoteProcess hasEntitlement:FBSLaunchServicesEntitlement] & 1) == 0) {
        v1 = remoteProcess;
    }
    if (!v0) {
        v0 = FBSystemAppBundleID();
    }
    id sharedInstance2 = [FBProcessManager sharedInstance];
    BSAuditToken *auditToken3 = [v1 auditToken];
    if (!auditToken3) {
        _memset(v6, 0, 32);
    } else {
        [auditToken3 realToken:&v6];
    }
    id v9 = [sharedInstance2 registerProcessForAuditToken:&v6];
    BSAtomicFlag *v10 = [[BSAtomicFlag alloc] initWithFlag:0];
    id v13 = a4;
    void (^v15)(BSProcessHandle *, NSError *) = ^void(BSProcessHandle *arg1, NSError *arg2) {
        BSProcessHandle *v107 = arg1;
        id v108 = arg2;
        if (arg2 != nil && ([v10 getFlag] & 1) == 0) {
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Returning generic error for un-trusted client (147937300).", a4);
            }
            id v5 = [NSError bs_errorWithDomain:FBSOpenApplicationServiceErrorDomain code:4 configuration:^void(id<BSErrorConfiguring> arg1) {
                NSString *v114 = [NSString stringWithFormat:@"The request to open \"%@\" failed.", v0];
                [arg1 setFailureDescription:v114];
                id v115 = FBSOpenApplicationServiceErrorCodeToString(4);
                [arg1 setCodeDescription:v115];
                id v112 = FBSOpenApplicationErrorCreate(3, @"Request is not trusted.", 0);
                [arg1 setUnderlyingError:v112];
                [arg1 setUserInfoValue:@147937300 forKey:@"FBSErrorContext"];
            }];
            v107 = 0;
            v108 = v5;
        }
        if (a5 != nil) {
            a5->field_16(a5, v107, v108);
        }
    };
    BSAtomicSignal *v16 = [[BSAtomicSignal alloc] init];
    id v18 = a2;
    void (^v19)(long, NSError *) = ^void(long arg1, NSError *arg2) {
        NSString *v146;
        BSProcessHandle *v34;
        if (([v16 signal] & 1) == 0) {
            arg1 = FBLogCommon();
            if (os_log_type_enabled(arg1, OS_LOG_TYPE_ERROR)) {
                NSProcessInfo *processInfo2 = [NSProcessInfo processInfo];
                NSString *processName2 = [processInfo2 processName];
                os_log_with_type(arg1, OS_LOG_TYPE_ERROR, "[%{public}@] %{public}@ called open application completion more than once. Ignoring.", v13, processName2);
            }
        } else {
            NSErrorDomain domain = [arg2 domain];
            BOOL v126 = [domain isEqualToString:FBSOpenApplicationErrorDomain];
            if (arg1 != nil) {
                id sharedInstance2 = [FBSystemService sharedInstance];
                id delegate = [sharedInstance2 delegate];
                NSString *v5 = NSStringFromClass([delegate class]);
                if (arg1 == 1) {
                    if (!v126) {
                        v146 = [NSString stringWithFormat:@"The request was denied by service delegate (%@).", v5];
                    } else {
                        NSDictionary<NSErrorUserInfoKey, id> *userInfo = [arg2 userInfo];
                        NSString *v148 = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
                        id v119 = FBSOpenApplicationErrorCodeToString([arg2 code]);
                        if (!v148) {
                            v146 = [NSString stringWithFormat:@"The request was denied by service delegate (%@) for reason: %@.", v5, v119];
                        } else {
                            NSCharacterSet *set = [NSCharacterSet punctuationCharacterSet];
                            NSString *v120 = [v148 stringByTrimmingCharactersInSet:set];
                            v146 = [NSString stringWithFormat:@"The request was denied by service delegate (%@) for reason: %@ (\"%@\").", v5, v119, v120];
                        }
                    }
                } else if (arg1 == 2) {
                    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
                    NSString *processName = [processInfo processName];
                    NSString *v122 = [NSString stringWithFormat:@"This is probably a bug in %@.", processName];
                    v146 = [NSString stringWithFormat:@"The request was ignored by service delegate (%@). %@", v5, v122];
                } else {
                    v146 = nil;
                }
                NSDictionary<NSErrorUserInfoKey, id> *dictionary = [NSMutableDictionary dictionary];
                NSString *v124 = [NSString stringWithFormat:@"The request to open \"%@\" failed.", v0];
                [dictionary bs_setSafeObject:v124 forKey:NSLocalizedDescriptionKey];
                [dictionary bs_setSafeObject:v146 forKey:NSLocalizedFailureReasonErrorKey];
                [dictionary bs_setSafeObject:arg2 forKey:NSUnderlyingErrorKey];
                id v125 = FBSOpenApplicationServiceErrorCodeToString(arg1);
                [dictionary bs_setSafeObject:v125 forKey:BSErrorCodeDescriptionKey];
                [dictionary bs_setSafeObject:v13 forKey:@"FBSOpenApplicationRequestID"];
                arg1 = [NSError errorWithDomain:FBSOpenApplicationServiceErrorDomain code:arg1 userInfo:dictionary];
            }
            bool v127 = !v126;
            int v128 = arg2 != nil && v127;
            if (v127) {
                if (v128 != 0) {
blk_1c4f1aad8:
                    id dictionary2 = [a2 dictionary];
                    long v130 = [dictionary2 bs_boolForKey:FBSOpenApplicationOptionKeyActivateSuspended];
                    if ((v130 & 1) == 0) {
                        dispatch_queue_global_t queue = dispatch_get_global_queue(21, 0);
                        dispatch_async(queue, ^void(void) {
                            id defaultWorkspace = [LSApplicationWorkspace defaultWorkspace];
                            NSURL *url = [a2 url];
                            [defaultWorkspace _LSFailedToOpenURL:url withBundle:v0];
                        });
                    }
                }
            } else {
                bool v132 = ([arg2 code] & 0xfffffffffffffffe) == 4;
                if (((v132 | v128) & 1) != 0) {
                    goto blk_1c4f1aad8;
                }
            }
            id sharedInstance = [FBProcessManager sharedInstance];
            id v134 = [sharedInstance _bestProcessForOpenApplicationIdentifier:v0];
            os_log_t log = FBLogCommon();
            if (arg1 != nil) {
                if (os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT)) {
                    id v141 = [arg1 descriptionWithMultilinePrefix:0];
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Open \"%{public}@\" request from %{public}@ failed with error: %{public}@", v13, v0, v4, v141);
                    goto blk_1c4f1ac48;
                }
                goto blk_1c4f1ac48;
            }
            bool v137 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
            if (!v134) {
                if (v137) {
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Request complete; no error reported, but no process was found to return to the requestor.", v13);
                }
blk_1c4f1ac48:
                v34 = [v134 handle];
                v15(v34, arg1);
            } else {
                if (v137) {
                    os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Request complete; no error reported.", v13);
                }
                id state = [v134 state];
                int pid = [state pid];
                if (pid > 0) {
                    v34 = [v134 handle];
                    v15(v34, arg1);
                } else {
                    [v134 _executeBlockAfterBootstrap:^void(FBProcess *arg1, NSError *arg2) {
                        NSError *v152;
                        NSError *v151 = arg2;
                        if (!arg2) {
                            v152 = nil;
                        } else {
                            v152 = [NSError bs_errorWithDomain:FBSOpenApplicationServiceErrorDomain code:3 configuration:^void(id<BSErrorConfiguring> arg1) {
                                NSString *v160 = ([v134 pid] > 0) ? @"Process exited after launching." : @"Process failed to launch.";
                                [arg1 setFailureDescription:v160];
                                id v159 = FBSOpenApplicationServiceErrorCodeToString(3);
                                [arg1 setCodeDescription:v159];
                                [arg1 setUnderlyingError:v151];
                                [arg1 setUserInfoValue:v13 forKey:@"FBSOpenApplicationRequestID"];
                            }];
                        }
                        BSProcessHandle *handle = [v134 handle];
                        v15(handle, v152);
                    }];
                }
            }
        }
    };
    if (!v1) {
        v20 = FBSProcessPrettyDescription(v1);
        v21 = FBSOpenApplicationErrorCreate(3, @"Identity of originator process (%@) could not be verified", v20, 0);
        v19(4, v21);
        return;
    } else if (![v1 isValid]) {
        v20 = FBSProcessPrettyDescription(v1);
        v21 = FBSOpenApplicationErrorCreate(3, @"Identity of originator process (%@) could not be verified", v20, 0);
        v19(4, v21);
        return;
    }
    __block bool v22 = false;
    id dictionary = [v18 dictionary];
    [dictionary enumerateKeysAndObjectsUsingBlock:^void(id arg1, id arg2, bool *arg3) {
        if ([arg1 isEqualToString:FBSOpenApplicationOptionKeyDocumentOpen4LS] || [arg1 isEqualToString:FBSOpenApplicationOptionKeyUserActivity4LS] || [arg1 isEqualToString:FBSOpenApplicationOptionKeyPayloadIsValid4LS] || [arg1 isEqualToString:FBSOpenApplicationOptionKeyAppLink4LS] || [arg1 isEqualToString:FBSOpenApplicationOptionKeyBrowserAppLinkState4LS] || [arg1 hasSuffix:@"4LS"]) {
            v22 = true;
            *(arg3) = 1;
        }
    }];
    if (v22 == 1) {
        if (([remoteProcess hasEntitlement:FBSLaunchServicesEntitlement] & 1) == 0) {
            NSError *v46 = FBSOpenApplicationErrorCreate(3, @"Caller specified LaunchServices-only keys, but is not LaunchServices");
            v19(4, v46);
            return;
        }
    }
    NSURL *url = [v18 url];
    BSAuditToken *auditToken = [remoteProcess auditToken];
    BSAuditToken *auditToken2 = [v1 auditToken];
    if ([auditToken isEqual:auditToken2]) {
        if (!url) {
            v31 = FBLogCommon();
            if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Received request to open \"%{public}@\" from %{public}@.", v13, v0, v4);
            }
        } else {
            v31 = FBLogCommon();
            if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
                NSString *scheme = [url scheme];
                NSString *resourceSpecifier = [url resourceSpecifier];
                os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Received request to open \"%{public}@\" with url \"%{public}@:%{sensitive}@\" from %{public}@.", v13, v0, scheme, resourceSpecifier, v4);
            }
        }
    } else if (!url) {
        v31 = FBLogCommon();
        if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
            id v32 = FBSProcessPrettyDescription(v1);
            os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Received request to open \"%{public}@\" from %{public}@ on behalf of %{public}@.", v13, v0, v4, v32);
        }
    } else {
        v31 = FBLogCommon();
        if (os_log_type_enabled(v31, OS_LOG_TYPE_DEFAULT)) {
            NSString *scheme2 = [url scheme];
            NSString *resourceSpecifier2 = [url resourceSpecifier];
            id v44 = FBSProcessPrettyDescription(v1);
            os_log_with_type(v31, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Received request to open \"%{public}@\" with url \"%{public}@:%{sensitive}@\" from %{public}@ on behalf of %{public}@.", v13, v0, scheme2, resourceSpecifier2, v4, v44);
        }
    }
    id actions = [v18 actions];
    if ([actions count]) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id fbs_singleLineDescriptionOfBSActions = [actions fbs_singleLineDescriptionOfBSActions];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Request contains action(s): %{public}@", v13, fbs_singleLineDescriptionOfBSActions);
        }
    }
    id dictionary2 = [v18 dictionary];
    id v51 = FBSOpenApplicationOptionClickAttribution;
    id v52 = [dictionary2 objectForKey:FBSOpenApplicationOptionClickAttribution];
    if (v52 != nil) {
        id dictionary3 = [v18 dictionary];
        id v54 = [dictionary3 objectForKey:v51];
        FBSApplicationInfo *applicationInfo = [v9 applicationInfo];
        id advertisingAttributionReportEndpoint = [applicationInfo advertisingAttributionReportEndpoint];
        if (!advertisingAttributionReportEndpoint) {
            os_log_t oslog2 = FBLogCommon();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Ignoring click attribution from client without a valid report endpoint.", v13);
            }
            [v18 _updateOption:0 forKey:v51];
        } else {
            id eventMessage = [v54 eventMessage];
            if (!eventMessage) {
                os_log_t oslog3 = FBLogCommon();
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Ignoring click attribution that contained no authentication message.", v13);
                }
                [v18 _updateOption:0 forKey:v51];
            } else {
                long originIdentifier = [eventMessage originIdentifier];
                id context = [eventMessage context];
                if (originIdentifier != 0xc181badb23d8497b || context != nil) {
                    os_log_t oslog4 = FBLogCommon();
                    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                        long originIdentifier2 = [eventMessage originIdentifier];
                        id context2 = [eventMessage context];
                        os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Ignoring click attribution with invalid origin (%llx) or context (%llx).", v13, originIdentifier2, context2);
                    }
                    [v18 _updateOption:0 forKey:v51];
                } else {
                    long timestamp = [eventMessage timestamp];
                    if (timestamp <= openApplication:withOptions:originator:requestID:completion:.sLastSeenBackBoardTimestamp) {
                        os_log_t oslog5 = FBLogCommon();
                        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                            os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Ignoring click attribution from the past.", v13);
                        }
                        [v18 _updateOption:0 forKey:v51];
                    } else {
                        openApplication:withOptions:originator:requestID:completion:.sLastSeenBackBoardTimestamp = timestamp;
                        id sharedInstance = [BKSHIDEventDeliveryManager sharedInstance];
                        long v70 = [sharedInstance authenticateMessage:eventMessage];
                        if ((v70 & 0xfffffffffffffffe) != 2) {
                            os_log_t oslog6 = FBLogCommon();
                            if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                                id v72 = NSStringFromBKSHIDEventAuthenticationStatus(v70);
                                os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Ignoring click attribution that failed authentication: %{public}@.", v13, v72);
                            }
                            [v18 _updateOption:0 forKey:v51];
                        } else {
                            os_log_t oslog7 = FBLogCommon();
                            if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
                                os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Request contains valid click attribution.", v13);
                            }
                            id v75 = [v54 clickAttributionWithReportEndpoint:advertisingAttributionReportEndpoint];
                            [v18 _updateOption:v75 forKey:v51];
                        }
                    }
                }
            }
        }
    }
    if (!url) {
        v76 = [v18 dictionary];
        v77 = v76;
        v78 = [v76 objectForKey:FBSOpenApplicationOptionKeyLSSequenceNumber];
        v79 = [v77 objectForKey:FBSOpenApplicationOptionKeyLSCacheGUID];
        if (v78 != nil == (v79 != nil)) {
            if (!v79) {
                v92 = [BSServiceConnection currentContext];
                v93 = [v92 instance];
                v98 = [[BSAction alloc] initWithInfo:0 responder:[BSActionResponder responderWithHandler:^void(BSActionResponse *arg1) {
                    NSError *error = [arg1 error];
                    NSInteger code = [error code];
                    if (code != 1) {
                        return;
                    }
                    v19(2, nil);
                }]];
                v100 = ^void(long arg1, NSError *arg2) {
                    v19();
                    [v98 invalidate];
                };
                v101 = [self _applicationInfoProvider];
                v103 = ^void(void) {
                    int v172;
                    long v166 = [v101 applicationInfoForBundleIdentifier:v0];
                    if (!v166) {
                        if ([v101 isKindOfClass:[FBSApplicationLibrary class]]) {
                            v166 = [v101 placeholderWithBundleIdentifier:v0];
                            if (v166 != 0) {
                                goto blk_1c4f1af5c;
                            }
                        }
                        os_log_t v177 = FBLogCommon();
                        if (os_log_type_enabled(v177, OS_LOG_TYPE_DEFAULT)) {
                            NSString *v170 = NSStringFromClass([v101 class]);
                            os_log_with_type(v177, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Application info provider (%@) returned nil for \"%{public}@\"", v13, v170, v0);
                        }
                        v166 = 0;
                        v172 = 1;
                    } else {
blk_1c4f1af5c:
                        v172 = 0;
                    }
                    NSError *v173 = nil;
                    long v174 = [self _isTrustedRequest:v13 forCaller:remoteProcess fromClient:v1 forBundleInfo:v166 withOptions:v77 fatalError:&v173];
                    [v10 setFlag:v174];
                    if (!v173) {
                        if (!v172 || v79 != nil) {
                            id v176 = self;
                            [self->_queue performAsync:^void(void) {
                                long flag = [v10 getFlag];
                                BSAuditToken *v180 = [v1 auditToken];
                                void (^v179)(NSError *) = ^void(NSError *arg1) {
                                    if (arg1 != nil) {
                                        v100(1, arg1);
                                        return;
                                    } else {
                                        v100(0, arg1);
                                        return;
                                    }
                                };
                                [v176 _activateBundleID:v0 requestID:v13 isTrusted:flag options:v18 serviceInstance:v93 source:remoteProcess originalSourceToken:v180 withResult:v179];
                            }];
                        } else {
                            NSString *v168 = NSStringFromClass([v101 class]);
                            NSError *v12 = FBSOpenApplicationErrorCreate(4, @"Application info provider (%@) returned nil for \"%@\"", v168, v0, 0);
                            v100(4, v12);
                        }
                    } else {
                        v100(4, v173);
                    }
                };
                if (![v101 respondsToSelector:@selector(synchronize:)]) {
                    v103();
                } else {
                    [v101 synchronize:v103];
                }
                return;
            }
            goto blk_1c4ef9144;
        }
        v82 = FBSOpenApplicationErrorCreate(2, @"Request supplied only one of sequenceNumber (%@) or cacheGUID (%@); You need to pass both or none.", v78, v79);
        v19(4, v82);
        return;
    }
    BSAuditToken *auditToken4 = [v1 auditToken];
    if (!auditToken4) {
        _memset(v6, 0, 32);
    } else {
        [auditToken4 realToken];
    }
    if (!sandbox_check_by_audit_token(&v6, "lsopen", 0)) {
        v76 = [v18 dictionary];
        v77 = v76;
        v78 = [v76 objectForKey:FBSOpenApplicationOptionKeyLSSequenceNumber];
        v79 = [v77 objectForKey:FBSOpenApplicationOptionKeyLSCacheGUID];
        if (v78 != nil == (v79 != nil)) {
            if (!v79) {
                goto blk_1c4ef91b8;
            }
        } else {
            v82 = FBSOpenApplicationErrorCreate(2, @"Request supplied only one of sequenceNumber (%@) or cacheGUID (%@); You need to pass both or none.", v78, v79);
            v19(4, v82);
            return;
        }
    } else {
        os_log_t oslog8 = FBLogCommon();
        if (os_log_type_enabled(oslog8, OS_LOG_TYPE_DEFAULT)) {
            id v87 = FBSProcessPrettyDescription(v1);
            os_log_with_type(oslog8, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Caller \"%{public}@\" has a sandbox that does not allow opening URL's.", v13, v87);
        }
        v77 = FBSProcessPrettyDescription(v1);
        NSError *v89 = FBSOpenApplicationErrorCreate(3, @"Sandbox check failed for process (%@) openURL not allowed", v77, 0);
        v19(4, v89);
        return;
    }
blk_1c4ef9144:
    os_log_t oslog9 = FBLogCommon();
    if (os_log_type_enabled(oslog9, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog9, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Activation request for %{public}@ contained LSCacheGUID %{public}@ and LSSequenceNumber %{public}@.", v13, v0, v79, v78);
    }
blk_1c4ef91b8:
    v92 = [BSServiceConnection currentContext];
    v93 = [v92 instance];
    v98 = [[BSAction alloc] initWithInfo:0 responder:[BSActionResponder responderWithHandler:^void(BSActionResponse *arg1) {
        NSError *error = [arg1 error];
        NSInteger code = [error code];
        if (code != 1) {
            return;
        }
        v19(2, nil);
    }]];
    v100 = ^void(long arg1, NSError *arg2) {
        v19();
        [v98 invalidate];
    };
    v101 = [self _applicationInfoProvider];
    v103 = ^void(void) {
        int v191;
        long v185 = [v101 applicationInfoForBundleIdentifier:v0];
        if (!v185) {
            if ([v101 isKindOfClass:[FBSApplicationLibrary class]]) {
                v185 = [v101 placeholderWithBundleIdentifier:v0];
                if (v185 != 0) {
                    goto blk_1c4f1af5c;
                }
            }
            os_log_t v196 = FBLogCommon();
            if (os_log_type_enabled(v196, OS_LOG_TYPE_DEFAULT)) {
                NSString *v189 = NSStringFromClass([v101 class]);
                os_log_with_type(v196, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Application info provider (%@) returned nil for \"%{public}@\"", v13, v189, v0);
            }
            v185 = 0;
            v191 = 1;
        } else {
blk_1c4f1af5c:
            v191 = 0;
        }
        NSError *v192 = nil;
        long v193 = [self _isTrustedRequest:v13 forCaller:remoteProcess fromClient:v1 forBundleInfo:v185 withOptions:v77 fatalError:&v192];
        [v10 setFlag:v193];
        if (!v192) {
            if (!v191 || v79 != nil) {
                id v195 = self;
                [self->_queue performAsync:^void(void) {
                    long flag = [v10 getFlag];
                    BSAuditToken *v199 = [v1 auditToken];
                    void (^v198)(NSError *) = ^void(NSError *arg1) {
                        if (arg1 != nil) {
                            v100(1, arg1);
                            return;
                        } else {
                            v100(0, arg1);
                            return;
                        }
                    };
                    [v195 _activateBundleID:v0 requestID:v13 isTrusted:flag options:v18 serviceInstance:v93 source:remoteProcess originalSourceToken:v199 withResult:v198];
                }];
            } else {
                NSString *v187 = NSStringFromClass([v101 class]);
                NSError *v12 = FBSOpenApplicationErrorCreate(4, @"Application info provider (%@) returned nil for \"%@\"", v187, v0, 0);
                v100(4, v12);
            }
        } else {
            v100(4, v192);
        }
    };
    if (![v101 respondsToSelector:@selector(synchronize:)]) {
        v103();
    } else {
        [v101 synchronize:v103];
    }
}


long +[FBSystemService sharedInstance](void)
{
    return [FBSystemService _sharedInstanceCreatingIfNecessary:1];
}


void -[FBSystemService setSystemIdleSleepDisabled:forReason:](long a1, id a2)
{
    id sharedInstance = [FBSystemShell sharedInstance];
    [sharedInstance _setSystemIdleSleepDisabled:a1 forReason:a2];
}


id<FBSystemServiceDelegate> -[FBSystemService delegate](void)
{
    return self->_delegate;
}


int -[FBSystemService _isTrustedRequest:forCaller:fromClient:forBundleInfo:withOptions:fatalError:](id a1, id a2, id a3, id a4, id a5, id *a6)
{
    id v9;
    os_log_t v6;
    int v10;
    int v11;
    int v25;
    NSString *v20;
    id v5 = [a5 objectForKey:FBSOpenApplicationOptionKeyDebuggingOptions];
    if (v5 != nil) {
        if (([a3 hasEntitlement:FBDebugApplicationsEntitlement] & 1) != 0 || ([a3 hasEntitlement:FBDebugApplicationsEntitlementLegacy] & 1) != 0 || ([a3 hasEntitlement:FBDebugApplicationsEntitlementLegacyLegacy] & 1) != 0) {
            goto blk_1c4f0c30c;
        }
        v9 = FBSOpenApplicationErrorCreate(3, @"Missing entitlement required to launch applications for debugging.");
        if (!v9) {
            goto blk_1c4f0c3d4;
        } else {
            goto blk_1c4f0c270;
        }
    }
    if (([a3 hasEntitlement:FBLaunchApplicationsEntitlement] & 1) != 0 || ([a3 hasEntitlement:FBLaunchApplicationsEntitlementLegacy] & 1) != 0 || ([a3 hasEntitlement:FBLaunchApplicationsEntitlementLegacyLegacy] & 1) != 0 || ([a3 hasEntitlement:FBDebugApplicationsEntitlement] & 1) != 0 || ([a3 hasEntitlement:FBDebugApplicationsEntitlementLegacy] & 1) != 0 || [a3 hasEntitlement:FBDebugApplicationsEntitlementLegacyLegacy] != 0) {
blk_1c4f0c30c:
        v6 = FBLogCommon();
        if (os_log_type_enabled(v6, OS_LOG_TYPE_DEFAULT)) {
            id v7 = FBSProcessPrettyDescription(a3);
            os_log_with_type(v6, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Trusting entitled client %{public}@.", a1, v7);
        }
blk_1c4f0c378:
        v9 = nil;
        v10 = 1;
        v11 = 1;
blk_1c4f0c384:
        if (a6 != 0) {
blk_1c4f0c38c:
            *(a6) = v9;
        }
    } else {
blk_1c4f0c3d4:
        if ([a5 bs_boolForKey:FBSOpenApplicationOptionKeyIsSensitiveURL] != 0) {
            if (![a3 hasEntitlement:FBOpenSensitiveURLEntitlementLegacy]) {
                if (([a2 hasEntitlement:FBSLaunchServicesEntitlement] & 1) != 0 || (v9 = FBSOpenApplicationErrorCreate(3, @"Un-trusted clients may not open private/sensitive URLs.")) == 0) {
                    goto blk_1c4f0c48c;
                }
blk_1c4f0c270:
                v11 = 0;
                goto blk_1c4f0c714;
            }
            v6 = FBLogCommon();
            if (os_log_type_enabled(v6, OS_LOG_TYPE_DEFAULT)) {
                id v28 = FBSProcessPrettyDescription(a3);
                os_log_with_type(v6, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Trusting legacy sensitive URL request from %{public}@.", a1, v28);
                goto blk_1c4f0c378;
            }
            goto blk_1c4f0c378;
        }
blk_1c4f0c48c:
        if ([a5 bs_boolForKey:FBSOpenApplicationOptionKeyActivateSuspended] != 0) {
            id v22 = ([a4 isKindOfClass:[FBSApplicationInfo class]]) ? a4 : nil;
            NSString *bundleIdentifier = [a4 bundleIdentifier];
            long v24 = [self _isAllowListedLaunchSuspendedApp:bundleIdentifier];
            if (!v22 || [a4 type] > 1) {
                v25 = 0;
            } else {
                v25 = [a4 hasViewServicesEntitlement];
            }
            v11 = v24 | v25;
            if (((v24 | v25) & 1) == 0) {
                v9 = FBSOpenApplicationErrorCreate(3, @"Un-trusted clients may not open applications in the background.");
            } else {
                os_log_t oslog2 = FBLogCommon();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    id v27 = FBSProcessPrettyDescription(a3);
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Trusting allow-listed background activation from %{public}@.", a1, v27);
                }
                v9 = nil;
            }
        } else {
            v11 = 0;
            v9 = nil;
        }
        if ((v11 & 1) != 0 || v9 != nil) {
blk_1c4f0c710:
            if (v9 != nil) {
blk_1c4f0c714:
                v6 = FBLogCommon();
                if (os_log_type_enabled(v6, OS_LOG_TYPE_ERROR)) {
                    id v12 = FBSProcessPrettyDescription(a3);
                    id succinctDescription = [v9 succinctDescription];
                    os_log_with_type(v6, OS_LOG_TYPE_ERROR, "[FBSystemService][%{public}@] Request from %{public}@ is denied: %{public}@", a1, v12, succinctDescription);
blk_1c4f0c72c:
                    v10 = 0;
                    goto blk_1c4f0c384;
                } else {
                    goto blk_1c4f0c72c;
                }
            }
            v10 = 1;
            if (a6 != 0) {
                goto blk_1c4f0c38c;
            }
        } else {
            id v15 = [a5 bs_safeURLForKey:FBSOpenApplicationOptionKeyPayloadURL];
            if (!v15) {
                long v16 = [a5 bs_boolForKey:FBSOpenApplicationOptionKeyUserActivity4LS];
                long v17 = [a5 bs_boolForKey:FBSOpenApplicationOptionKeyPayloadIsValid4LS];
                if ((v16 & 1) != 0 || v17 != 0) {
blk_1c4f0c660:
                    os_log_t oslog = FBLogCommon();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                        id v19 = FBSProcessPrettyDescription(a3);
                        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService][%{public}@] Allowing un-trusted request from %{public}@.", a1, v19);
                    }
                    v9 = nil;
                    goto blk_1c4f0c710;
                }
blk_1c4f0c6f4:
                v9 = FBSOpenApplicationErrorCreate(3, @"Un-trusted clients may not open applications without a valid user activity.");
                goto blk_1c4f0c710;
            }
            if (![a2 hasEntitlement:FBSLaunchServicesEntitlement]) {
                v20 = @"Only LaunchServices may open URLs on behalf of un-trusted clients.";
            } else {
                if (![v15 isFileURL] || ([a5 bs_boolForKey:FBSOpenApplicationOptionKeyDocumentOpen4LS] & 1) != 0) {
                    goto blk_1c4f0c660;
                }
                v20 = @"Un-trusted clients may not open file URLs.";
            }
            v9 = FBSOpenApplicationErrorCreate(3, v20);
            if (v9 != nil) {
                goto blk_1c4f0c710;
            } else {
                goto blk_1c4f0c6f4;
            }
        }
    }
    return v10 & v11;
}


id +[FBSystemService currentOpenApplicationInstance](void)
{
    NSThread *currentThread = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread threadDictionary];
    if (!threadDictionary) {
        NSThread *currentThread2 = [NSThread currentThread];
        NSString *v6 = [NSString stringWithFormat:@"missing thread-local storage on %@", currentThread2];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = [NSString stringWithUTF8String:"+[FBSystemService currentOpenApplicationInstance]"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v7, @"FBSystemService.m", 245, v6);
        }
        _bs_set_crash_log_message([v6 UTF8String]);
        __break(0);
    }
    id v2 = [threadDictionary objectForKey:@"FBOpenAppSystemServiceInstance"];
    if (v2 != nil && ![v2 isKindOfClass:[NSString class]]) {
        Class v8 = [v2 classForCoder];
        if (!v8) {
            v8 = [v2 class];
        }
        NSString *v9 = NSStringFromClass(v8);
        NSString *v10 = NSStringFromClass([NSString class]);
        NSString *v11 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"instance", v9, v10];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBSystemService.m", 248, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    return v2;
}


FBSystemService *-[FBSystemService initWithQueue:](BSServiceDispatchQueue *a1)
{
    FBSystemService *v1 = [super init];
    if (v1 != nil) {
        v1->_queue = a1;
        id sharedInstance = [FBServiceFacilityServer sharedInstance];
        id domain = [sharedInstance domain];
        id identifier = [FBSOpenApplicationServiceSpecification identifier];
        id v5 = [domain serviceForIdentifier:identifier];
        if (v5 != nil && [v5 isDerived] != 0) {
            v1->_legacyOpenServiceListener = [BSServiceConnectionListener listenerWithConfigurator:^void(id<BSServiceConnectionListenerConfiguring> arg1) {
                id v25 = [sharedInstance domain];
                id v26 = [v25 identifier];
                [arg1 setDomain:v26];
                id identifier2 = [v5 identifier];
                [arg1 setService:identifier2];
                [arg1 setDelegate:v1];
            }];
        }
        v1->_defaultInfoProviderLock._os_unfair_lock_opaque = 0;
        v1->_BTLPMTimeout = (double)(long)getCBControllerLowPowerModeCompletionTimeoutSeconds();
        v1->_BTLPMTimeoutFetchGroup = dispatch_group_create();
        [v1 _beginFetchBTLPMTimeout];
        [v1 _setInfoProvider];
        [v1->_legacyOpenServiceListener activate];
        if ([FBSApplicationDataStore isServerProcess] != 0) {
            void (^v15)(int, struct __CFDictionary *) = ^void(int arg1, struct __CFDictionary *arg2) {
                if (arg1 != 5) {
                    return;
                }
                os_log_t oslog = FBLogCommon();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Received device inactivity notification. Rebooting...");
                }
                FBSShutdownOptions *v34 = [[FBSShutdownOptions alloc] initWithReason:@"SEP idle reboot"];
                [v34 setRebootType:1];
                [v1 shutdownUsingOptions:v34];
            };
            struct _AKSEvent *(*v18)(id, id) = getAKSEventsRegisterSymbolLoc.ptr;
            __block long v16 = getAKSEventsRegisterSymbolLoc.ptr;
            if (!v18) {
                ^void(void) {
                    uint8_t v30[32];
                    void *v29 = 0;
                    if (!AppleKeyStoreLibraryCore.frameworkLibrary) {
                        *(__uint128_t *)&v30[0] = xmmword_1e17d5cd8;
                        *(uint64_t *)&v30[16] = 0;
                        AppleKeyStoreLibraryCore.frameworkLibrary = _sl_dlopen(&v30, &v29);
                    }
                    if (!AppleKeyStoreLibraryCore.frameworkLibrary) {
                        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                        NSString *v32 = [NSString stringWithUTF8String:"void *AppleKeyStoreLibrary(void)"];
                        [currentHandler handleFailureInFunction:v32 file:@"FBSystemService.m" lineNumber:54 description:@"%s", v29];
                        __builtin_trap();
                    }
                    if (v29 != 0) {
                        free(v29);
                    }
                    v16 = dlsym(AppleKeyStoreLibraryCore.frameworkLibrary, "AKSEventsRegister");
                    getAKSEventsRegisterSymbolLoc.ptr = v16;
                }();
                v18 = v16;
            }
            if (!v18) {
                NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                NSString *v24 = [NSString stringWithUTF8String:"AKSEvent *soft_AKSEventsRegister(__strong dispatch_queue_t, void (^__strong)(AKSEventType, CFDictionaryRef))"];
                [currentHandler handleFailureInFunction:v24 file:@"FBSystemService.m" lineNumber:55 description:@"%s", dlerror()];
                __builtin_trap();
            }
            id v21 = dispatch_get_main_queue();
            v1->_aksEvent = v18(v21, v15);
        }
        atexit_b(^void(void) {
            if (![NSThread isMainThread]) {
                dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
                [v1->_queue performAsync:^void(void) {
                    id v38 = [FBSystemService sharedInstance];
                    [v38 prepareForExitAndRelaunch:1];
                    dispatch_semaphore_signal(dsema);
                }];
                dispatch_semaphore_wait(dsema, dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC));
                return;
            }
            id sharedInstance = [FBSystemService sharedInstance];
            [sharedInstance prepareForExitAndRelaunch:1];
        });
    }
    return v1;
}


void -[FBSystemService setDelegate:](id<FBSystemServiceDelegate> a1)
{
    id<FBSystemServiceDelegate> v1 = self->_delegate;
    if (v1 != a1) {
        self->_delegate = a1;
        [self _setInfoProvider];
    }
}


long -[FBSystemService shutdownAndReboot:](int a1)
{
    [self shutdownWithOptions:a1 forSource:0];
}


long -[FBSystemService shutdownWithOptions:forSource:](long a1, NSString *a2)
{
    FBSShutdownOptions *v0 = [[FBSShutdownOptions alloc] initWithReason:@"GenericSystemService"];
    int v1 = a1 & 1;
    if ((a1 & 2) != 0) {
        v1 = 2;
    }
    [v0 setRebootType:v1];
    [v0 setSource:a2];
    [self shutdownWithOptions:v0 origin:0];
}


long -[FBSystemService shutdownUsingOptions:](id a1)
{
    [self shutdownWithOptions:a1 origin:0];
}


void -[FBSystemService shutdownWithOptions:origin:](id a1, id a2)
{
    int v14;
    __block long v19;
    int v11;
    id v0 = a1;
    long v1 = a2;
    long rebootType = [v0 rebootType];
    long isReboot = [v0 isReboot];
    [self setPendingExit:1];
    if (![v0 isShutdown]) {
        objc_msgSend$startTaskWithName:timeout:workItem:(FBAsynchronousShutdownTask, @"NotifyNearField", ^void(NSObject<OS_dispatch_queue> *arg1, void (^arg2)(NSError *)) {
            long v25 = getNFHardwareManagerClass();
            id sharedHardwareManager = [v25 sharedHardwareManager];
            [sharedHardwareManager actOnUserInitiatedSystemShutDown:4 completion:^void(void) {
                arg2(nil);
            }];
        }, 1.0);
    } else {
        long LPEMOption = [v0 LPEMOption];
        if (LPEMOption != 0) {
            v14 = LPEMOption == 2;
        } else {
            v14 = [v0 isUserInitiated] ^ 1;
        }
        os_log_t oslog = FBLogShutdown();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            long isUserInitiated = [v0 isUserInitiated];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Performing shutdown for low power: %{bool}u; userInitiated: %{bool}u", v14, isUserInitiated);
        }
        if ((v14 & 1) == 0) {
            objc_msgSend$startTaskWithName:timeout:workItem:(FBAsynchronousShutdownTask, @"NotifyNearField", ^void(NSObject<OS_dispatch_queue> *arg1, void (^arg2)(NSError *)) {
                long v28 = getNFHardwareManagerClass();
                id sharedHardwareManager = [v28 sharedHardwareManager];
                [sharedHardwareManager actOnUserInitiatedSystemShutDown:2 completion:^void(void) {
                    arg2(nil);
                }];
            }, 1.0);
        }
        [self _bluetoothLPMTimeoutWithFetchTimeout:1.0];
        objc_msgSend$startTaskWithName:timeout:workItem:(FBAsynchronousShutdownTask, @"NotifyBluetooth", ^void(NSObject<OS_dispatch_queue> *arg1, void (^arg2)(NSError *)) {
            id v31 = [[getCBControllerClass() alloc] init];
            [v31 setDispatchQueue:arg1];
            [v31 setLowPowerModeWithReason:(!v14) ? 2 : 1 completion:^void(NSError *arg1) {
                [v31 invalidate];
                arg2(arg1);
            }];
        });
        long *v21 = getkNISystemShutdownCompletionTimeoutSecondsSymbolLoc.ptr;
        v19 = getkNISystemShutdownCompletionTimeoutSecondsSymbolLoc.ptr;
        if (!v21) {
            v19 = dlsym(NearbyInteractionLibrary(), "kNISystemShutdownCompletionTimeoutSeconds");
            getkNISystemShutdownCompletionTimeoutSecondsSymbolLoc.ptr = v19;
            v21 = v19;
        }
        if (!v21) {
            NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
            NSString *v23 = [NSString stringWithUTF8String:"NSTimeInterval getkNISystemShutdownCompletionTimeoutSeconds(void)"];
            [currentHandler handleFailureInFunction:v23 file:@"FBSystemService.m" lineNumber:79 description:@"%s", dlerror()];
            __builtin_trap();
        }
        objc_msgSend$startTaskWithName:timeout:workItem:(FBAsynchronousShutdownTask, @"NotifyNearbyInteraction", ^void(NSObject<OS_dispatch_queue> *arg1, void (^arg2)(NSError *)) {
            int v34;
            if ((v14 & 1) == 0) {
                v34 = ([v0 isUserInitiated] != 0) ? 0 : 2;
            } else {
                v34 = 1;
            }
            void (*v36)(int, id) = getNINotifySystemShutdownWithReasonSymbolLoc.ptr;
            if (!v36) {
                __block void *v4 = dlsym(NearbyInteractionLibrary(), "NINotifySystemShutdownWithReason");
                getNINotifySystemShutdownWithReasonSymbolLoc.ptr = v4;
                v36 = v4;
            }
            if (v36 != 0) {
                v36(v34, arg2);
                return;
            }
            NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
            NSString *v37 = [NSString stringWithUTF8String:"void soft_NINotifySystemShutdownWithReason(NISystemShutdownReason, void (^__strong)(NSError * _Nullable __strong))"];
            [currentHandler handleFailureInFunction:v37 file:@"FBSystemService.m" lineNumber:78 description:@"%s", dlerror()];
            __builtin_trap();
        }, *(v21));
    }
    id<FBSystemServiceDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(systemService:prepareForShutdownWithOptions:origin:)]) {
        [delegate systemService:self prepareForShutdownWithOptions:v0 origin:v1];
    } else if ([delegate respondsToSelector:@selector(systemServicePrepareForShutdown:withOptions:)]) {
        long v6 = [self _mapShutdownOptionsToOptions:v0];
        [delegate systemServicePrepareForShutdown:self withOptions:v6];
    }
    [self _performExitTasksForRelaunch:0];
    _FBDarkBootHelper *v7 = [[_FBDarkBootHelper alloc] init];
    if (rebootType == 2) {
        [v7 setNextBootDark];
    }
    os_log_t log = FBLogShutdown();
    bool v9 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (!isReboot) {
        if (v9) {
            _os_log_impl(&_mh_dylib_header, log, OS_LOG_TYPE_DEFAULT, "Shutting Down... options:%@", ^void(void) {
                long v38 = NearbyInteractionLibrary();
                v19->field_8->field_24 = dlsym(v38, "kNISystemShutdownCompletionTimeoutSeconds");
                getkNISystemShutdownCompletionTimeoutSecondsSymbolLoc.ptr = v19->field_8->field_24;
            }, 12);
        }
        v11 = 8;
    } else {
        if (v9) {
            long isBootingDark = [v7 isBootingDark];
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Rebooting... options:%@ darkBootGotSet:%{BOOL}u", v0, isBootingDark);
        }
        v11 = 0;
    }
    [FBAsynchronousShutdownTask waitForTasks];
    if (reboot3(v11) != 0) {
        exit(-1);
    }
    exit(0);
}


long -[FBSystemService shutdownWithOptions:](long a1)
{
    [self shutdownWithOptions:a1 forSource:0];
}


long -[FBSystemService exitAndRelaunch:](long a1)
{
    return [self exitAndRelaunch:a1 withOptions:0];
}


long -[FBSystemService prepareForExitAndRelaunch:](long a1)
{
    return [self exitAndRelaunch:a1 withOptions:2];
}


void -[FBSystemService prepareDisplaysForExit](void)
{
    [CATransaction flush];
    [CATransaction synchronize];
    id serverIfRunning = [CAWindowServer serverIfRunning];
    [serverIfRunning removeAllDisplays];
}


long -[FBSystemService isPendingExit](void)
{
    return BSAtomicGetFlag(&self->_pendingExit);
}


long -[FBSystemService setPendingExit:](long a1)
{
    return BSAtomicSetFlag(a1, &self->_pendingExit);
}


bool -[FBSystemService exitAndRelaunch:withOptions:](int a1, int a2)
{
    bool v0 = [self isPendingExit];
    if (v0) {
        return v0;
    }
    [self setPendingExit:1];
    os_log_t log = FBLogCommon();
    bool v2 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (a1) {
        if (v2) {
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Exiting...");
        }
    } else if (v2) {
        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Tearing Down...");
    }
    id<FBSystemServiceDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(systemServicePrepareForExit:andRelaunch:)]) {
        [delegate systemServicePrepareForExit:self andRelaunch:a1];
    }
    v0 = [self _performExitTasksForRelaunch:a1];
    if ((a1 & 1) == 0) {
        v0 = BKSHIDServicesSetBacklightFactorWithFadeDuration(1);
    }
    if ((a2 & 2) == 0) {
        exit(0);
    }
    return v0;
}


void -[FBSystemService _terminateProcesses:forReason:andReport:withDescription:completion:](NSArray *a1, long a2, long a3, id a4, void (^a5)(long))
{
    long v4;
    void (^v2)(long) = a5;
    if (![a1 count]) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Found no processes to terminate.");
        }
        if (v2 != nil) {
            v2(0);
        }
    } else {
        void *v5 = &v4;
        __block long v16 = 0;
        NSUInteger count = [a1 count];
        id v10 = [BSBlockSentinel sentinelWithSignalCount:count signalHandler:^void(id<BSBlockSentinelSignalContext> arg1) {
            if (![arg1 isComplete]) {
                return;
            }
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                long v1 = v5->field_8->field_24;
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Completed termination of %lu process(es)", v1);
            }
            if (!v2) {
                return;
            }
            v2(v5->field_8->field_24 != 0);
        }];
        for (FBProcess *v8 in a1) {
            if ([v8 isCurrentProcess]) {
                [v10 signal];
            } else {
                [v8 _killForReason:a2 andReport:a3 withDescription:a4 completion:^void(bool arg1) {
                    v16++;
                    [v10 signal];
                }];
            }
        }
    }
}


void -[FBSystemService terminateApplication:forReason:andReport:withDescription:completion:](id a1, long a2, int a3, id a4, id a5)
{
    long v16;
    id sharedInstance2 = [FBProcessManager sharedInstance];
    id v4 = [sharedInstance2 applicationProcessesForBundleIdentifier:a1];
    if (![v4 count]) {
        NSMutableArray *array = [NSMutableArray array];
        id v6 = [RBSProcessPredicate predicateMatchingBundleIdentifier:a1];
        id v7 = [RBSProcessState statesForPredicate:v6 withDescriptor:0 error:0];
        for (id v13 in v7) {
            id process = [v13 process];
            if (process != nil) {
                id sharedInstance = [FBProcessManager sharedInstance];
                [process auditToken:&v16];
                id v17 = [sharedInstance registerProcessForAuditToken:&v16];
                if (v17 != nil) {
                    [array addObject:v17];
                }
            }
        }
        v4 = array;
    }
    [self _terminateProcesses:v4 forReason:a2 andReport:a3 withDescription:a4 completion:a5];
}


void -[FBSystemService terminateApplicationGroup:forReason:andReport:withDescription:completion:](long a1, long a2, int a3, id a4, id a5)
{
    NSMutableSet *v2 = [[NSMutableSet alloc] init];
    id sharedInstance = [FBProcessManager sharedInstance];
    id allApplicationProcesses = [sharedInstance allApplicationProcesses];
    for (id v10 in allApplicationProcesses) {
        if (a1 != 0 || [v10 isForeground]) {
            [v2 addObject:v10];
        }
    }
    NSArray *allObjects = [v2 allObjects];
    [self _terminateProcesses:allObjects forReason:a2 andReport:a3 withDescription:a4 completion:a5];
}


bool -[FBSystemService _shouldPendRequestForClientSequenceNumber:clientCacheGUID:ourSequenceNumber:ourCacheGUID:](long a1, id a2, long a3, id a4)
{
    BOOL v0 = [a2 isEqual:a4];
    if (a1 == a3) {
        return !v0;
    } else {
        return true;
    }
}


void -[FBSystemService isPasscodeLockedOrBlockedWithResult:](void (^a1)(long))
{
    [self->_queue assertBarrierOnQueue];
    id<FBSystemServiceDelegate> delegate = [self delegate];
    if ([delegate respondsToSelector:@selector(systemService:isPasscodeLockedOrBlockedWithResult:)]) {
        [delegate systemService:self isPasscodeLockedOrBlockedWithResult:a1];
    } else if (a1 != nil) {
        a1(0);
    }
}


void -[FBSystemService handleActions:source:withResult:](id a1, id a2, id a3)
{
    int v9;
    [self->_queue assertBarrierOnQueue];
    void (^v4)(long) = ^void(long arg1) {
        if (arg1 != 0) {
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                id v16 = FBSOpenApplicationErrorCodeToString(arg1);
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "[FBSystemService] Error handling sent actions %{public}@: %{public}@ (%d)", a1, v16, arg1);
            }
        }
        if (a3 != nil) {
            a3->field_16(a3, arg1);
        }
    };
    id<FBSystemServiceDelegate> delegate = [self delegate];
    id v6 = FBLaunchApplicationsEntitlement;
    if (([a2 hasEntitlement:FBLaunchApplicationsEntitlement] & 1) == 0 && ([a2 hasEntitlement:FBLaunchApplicationsEntitlementLegacy] & 1) == 0 && ([a2 hasEntitlement:FBLaunchApplicationsEntitlementLegacyLegacy] & 1) == 0) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Entitlement %@ is required to send actions to the system app.", v6);
        }
        v9 = 3;
        goto blk_1c4f1a1a8;
    }
    BOOL v7 = [delegate respondsToSelector:@selector(systemService:handleActions:origin:withResult:)];
    os_log_t oslog2 = FBLogCommon();
    if (!v7) {
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%s is not available with this system app", "-[FBSystemService handleActions:source:withResult:]");
        }
        v9 = 8;
blk_1c4f1a1a8:
        v4(v9);
    } else {
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            id fbs_singleLineDescriptionOfBSActions = [a1 fbs_singleLineDescriptionOfBSActions];
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Received action(s): %{public}@", fbs_singleLineDescriptionOfBSActions);
        }
        [delegate systemService:self handleActions:a1 origin:a2 withResult:v4];
    }
}


void -[FBSystemService canOpenApplication:completion:](id a1, void (^a2)(long))
{
    long v4;
    long v8;
    void (^v1)(long) = a2;
    if (a2 != nil) {
        id currentContext = [BSServiceConnection currentContext];
        long remoteProcess = [currentContext remoteProcess];
        if (([self _isTrustedRequest:@"(CanOpen)" forCaller:remoteProcess fromClient:remoteProcess forBundleInfo:0 withOptions:0 fatalError:0] & 1) == 0) {
            v4 = FBSOpenApplicationErrorCreate(3, @"Request is not trusted.");
            v1(v4);
        } else if (!a1) {
            v4 = FBSOpenApplicationErrorCreate(2, @"no bundleID provided");
            v1(v4);
        } else {
            id<FBSystemServiceDelegate> delegate = [self delegate];
            if (!delegate) {
                v8 = FBSOpenApplicationErrorCreate(8, @"Service delegate does not implement -canActivateApplication:");
                v1(v8);
            } else if (![delegate respondsToSelector:@selector(systemService:canActivateApplication:withResult:)]) {
                v8 = FBSOpenApplicationErrorCreate(8, @"Service delegate does not implement -canActivateApplication:");
                v1(v8);
            } else {
                id currentContext2 = [BSServiceConnection currentContext];
                id instance = [currentContext2 instance];
                BSServiceDispatchQueue *queue = [self queue];
                [queue performAsync:^void(void) {
                    v13 = ^void(void) {
                        [delegate systemService:self canActivateApplication:v13 withResult:^void(long arg1) {
                            if (!arg1) {
                                v1(arg1);
                                return;
                            }
                            id v15 = FBSOpenApplicationErrorCreate(arg1, 0);
                            v1(v15);
                        }];
                    };
                    FBOpenAppSystemServiceExecuteCallOut(instance, v13);
                }];
            }
        }
    }
}


void -[FBSystemService _setInfoProvider](void)
{
    FBSLazyApplicationInfoProvider *v1;
    os_unfair_lock_lock(&self->_defaultInfoProviderLock);
    id<FBSystemServiceDelegate> v0 = self->_delegate;
    if (![v0 respondsToSelector:@selector(systemServiceApplicationInfoProvider:)]) {
        v1 = [[FBSLazyApplicationInfoProvider alloc] init];
    } else {
        v1 = [v0 systemServiceApplicationInfoProvider:self];
        if (!v1) {
            v1 = [[FBSLazyApplicationInfoProvider alloc] init];
        }
    }
    self->_lock_defaultInfoProvider = v1;
    os_unfair_lock_unlock(&self->_defaultInfoProviderLock);
}


long -[FBSystemService _performExitTasksForRelaunch:](int a1)
{
    [self prepareDisplaysForExit];
    if ([FBSApplicationDataStore isServerProcess] != 0) {
        [FBSApplicationDataStore synchronize];
    }
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults synchronize];
    Boolean v1 = CFPreferencesSynchronize(kCFPreferencesAnyApplication, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if ((a1 & 1) == 0) {
        return signal(15, 1);
    } else {
        return v1;
    }
}


BOOL -[FBSystemService _isAllowListedLaunchSuspendedApp:](id a1)
{
    dispatch_once(&_isAllowListedLaunchSuspendedApp:.onceToken, ^void(void) {
        _isAllowListedLaunchSuspendedApp:.__allowListedLaunchSuspendedApps = [NSSet setWithObjects:@"com.apple.Music", @"com.apple.mobilemail", @"com.apple.AdSheetPhone", @"com.apple.AdSheetPad", @"com.apple.DataActivation", nil];
    });
    if (a1 == nil) {
        return NO;
    }
    BOOL v1 = [_isAllowListedLaunchSuspendedApp:.__allowListedLaunchSuspendedApps containsObject:a1];
    return v1;
}


long -[FBSystemService _mapShutdownOptionsToOptions:](id a1)
{
    long rebootType = [a1 rebootType];
    if (rebootType == 1) {
        return 1;
    } else if (rebootType == 2) {
        return rebootType;
    } else {
        return 0;
    }
}


void -[FBSystemService _beginFetchBTLPMTimeout](void)
{
    id v0 = [[getCBControllerClass() alloc] init];
    if (v0 != nil) {
        id v1 = BSDispatchQueueCreateSerialWithQoS(@"CoreBluetoothLPMCompletionTimeout", 33);
        [v0 setDispatchQueue:v1];
        dispatch_group_enter(self->_BTLPMTimeoutFetchGroup);
        [v0 activateWithCompletion:^void(NSError *arg1) {
            if (!arg1) {
                long LPMCompletionTimeoutSeconds = [v0 LPMCompletionTimeoutSeconds];
                os_log_t oslog2 = FBLogShutdown();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Got BT LPM timeout %ds", LPMCompletionTimeoutSeconds);
                }
                self->_BTLPMTimeout = (double)(unsigned int)LPMCompletionTimeoutSeconds;
            } else {
                os_log_t oslog = FBLogShutdown();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "CoreBluetooth error activating controller: %{public}@", arg1);
                }
            }
            [v0 invalidate];
            dispatch_group_leave(self->_BTLPMTimeoutFetchGroup);
        }];
    }
}


double -[FBSystemService _bluetoothLPMTimeoutWithFetchTimeout:](long a1)
{
    os_log_t v3;
    long v2;
    long v0 = getCBControllerLowPowerModeCompletionTimeoutSeconds();
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (long)(v2 * 1000000000.0));
    if (!dispatch_group_wait(self->_BTLPMTimeoutFetchGroup, timeout)) {
        v0 = (int)self->_BTLPMTimeout;
        v3 = FBLogShutdown();
        if (os_log_type_enabled(v3, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(v3, OS_LOG_TYPE_DEFAULT, "CoreBluetooth LPM completion timeout updated to %ds.", v0);
        }
    } else {
        v3 = FBLogShutdown();
        if (os_log_type_enabled(v3, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v3, OS_LOG_TYPE_ERROR, "CoreBluetooth query for LPM completion timed out, using default %ds.", v0 & 255);
        }
    }
}


BSServiceDispatchQueue *-[FBSystemService queue](void)
{
    return self->_queue;
}


void -[FBSystemService .cxx_destruct](void)
{
    self->_delegate = nil;
    self->_BTLPMTimeoutFetchGroup = nil;
    self->_lock_defaultInfoProvider = nil;
    self->_legacyOpenServiceListener = nil;
    self->_queue = nil;
}


void -[FBSystemService init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBSystemService"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSystemService.m", 223, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBSystemService dealloc](void)
{
    NSString *v1 = [NSString stringWithFormat:@"%s should NEVER be deallocated: %@", "-[FBSystemService dealloc]", self];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSystemService.m", 228, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
