struct FBProcessWatchdog {
    RBSProcessHandle *_handle; // +0x30
    BSAtomicSignal *_unblockSignal; // +0x38
    long _event; // +0x40
    FBProcessWatchdogEventContext *_eventContext; // +0x48
    FBProcessCPUStatistics *_cpuStatistics; // +0x50
};

FBProcessWatchdog *-[FBProcessWatchdog initWithProcess:context:policy:](id a1, FBProcessWatchdogEventContext *a2, id a3)
{
    long event = [a2 event];
    FBProcessWatchdog *v6 = [super initWithName:NSStringFromProcessWatchdogEvent(event) process:a1 policy:a3];
    if (v6 != nil) {
        v6->_event = event;
        v6->_eventContext = a2;
        v6->_handle = [a1 rbsHandle];
    }
    return v6;
}


int *-[FBProcessWatchdog activate](void)
{
    if (self->_handle != nil) {
        self->_cpuStatistics = [[FBProcessCPUStatistics alloc] initWithProcessHandle:self->_handle];
    }
    int *v5 = [super activate];
    dispatch_once(&activate.onceToken, ^void(void) {
        activate.__UnblockEntitled = BSSelfTaskHasEntitlement(@"com.apple.private.unblock");
    });
    if (activate.__UnblockEntitled == 1) {
        long v6 = 0;
        [self _getPolicyWallTime:&v6 cpuTime:0];
        int pid = [self->_handle pid];
        id process = [self process];
        id logProem = [process logProem];
        BSAtomicSignal *v10 = [BSAtomicSignal new];
        self->_unblockSignal = v10;
        BSAtomicSignal *v13 = v10;
        double v15 = (v6 * 0.5 > 5.0) ? 5.0 : v6 * 0.5;
        long v16 = self->_event;
        __weak FBProcessWatchdog *v17 = self;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (long)(v15 * 1000000000.0));
        NSObject<OS_dispatch_workloop> *queue = [FBProcess userInitiatedWorkloop];
        dispatch_after(when, queue, ^void(void) {
            if (![v13 signal]) {
                return;
            }
            os_log_t oslog = FBLogProcess();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id v2 = NSStringFromProcessWatchdogEvent(v16);
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Watchdog for %{public}@ is still active after %.1fs, notifying Unblock.", logProem, v2, v15);
            }
            Class v28 = getUBStuckServiceClass.softClass;
            __block long v4 = getUBStuckServiceClass.softClass;
            if (!v28) {
                ^void(void) {
                    UnblockClientLibrary();
                    v4 = objc_getClass("UBStuckService");
                    if (!v4) {
                        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                        NSString *v31 = [NSString stringWithUTF8String:"Class getUBStuckServiceClass(void)_block_invoke"];
                        [currentHandler handleFailureInFunction:v31 file:@"FBProcessWatchdog.m" lineNumber:20 description:@"Unable to find class %s", "UBStuckService"];
                        __builtin_trap();
                    }
                    getUBStuckServiceClass.softClass = v4;
                }();
                v28 = v4;
            }
            id v29 = [v28 alloc];
            v28 = objc_msgSend$initForPid:threadID:timeElapsed:incidentUUID:(v29, pid, 1, 0, v15);
            Class v23 = getUBUnblockClientClass.softClass;
            __block long v30 = getUBUnblockClientClass.softClass;
            if (!v23) {
                ^void(void) {
                    UnblockClientLibrary();
                    v30 = objc_getClass("UBUnblockClient");
                    if (!v30) {
                        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                        NSString *v32 = [NSString stringWithUTF8String:"Class getUBUnblockClientClass(void)_block_invoke"];
                        [currentHandler handleFailureInFunction:v32 file:@"FBProcessWatchdog.m" lineNumber:21 description:@"Unable to find class %s", "UBUnblockClient"];
                        __builtin_trap();
                    }
                    getUBUnblockClientClass.softClass = v30;
                }();
                v23 = v30;
            }
            id v11 = [[v23 alloc] init];
            NSArray *v24 = @[v28];
            NSObject<OS_dispatch_workloop> *userInitiatedWorkloop = [FBProcess userInitiatedWorkloop];
            void (^v25)(NSError *, NSArray *) = ^void(NSError *arg1, NSArray *arg2) {
                NSString *v38;
                if (!arg1) {
                    id firstObject = [arg2 firstObject];
                    if (!firstObject) {
                        os_log_t oslog3 = FBLogProcess();
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%{public}@ Unblock returned no result.", logProem);
                        }
                    } else {
                        long issueType = [firstObject issueType];
                        long recoveryStatus = [firstObject recoveryStatus];
                        long recoveryConfidence = [firstObject recoveryConfidence];
                        os_log_t oslog = FBLogProcess();
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                            id v34 = _FBSNSStringFromUBIssueType(issueType);
                            if (recoveryConfidence > 74) {
                                switch (recoveryConfidence) {
                                    case 75:
                                        v38 = @"indirect-correlation";
                                        break;
                                    case 100:
                                        v38 = @"definitive";
                                        break;
                                    default:
blk_1c4f17170:
                                        v38 = [NSString stringWithFormat:@"(unknown - %ld)", recoveryConfidence];
                                        break;
                                }
                            } else if (!recoveryConfidence) {
                                v38 = @"undefined";
                            } else if (recoveryConfidence != 25) {
                                goto blk_1c4f17170;
                            } else {
                                v38 = @"opportunistic";
                            }
                            NSString *v35 = (recoveryStatus >= 5) ? [NSString stringWithFormat:@"(unknown - %ld)", recoveryStatus] : (&qword_1e17d5768)[recoveryStatus];
                            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%{public}@ Unblock returned with issue: %{public}@; confidence: %{public}@; status: %{public}@", logProem, v34, v38, v35);
                        }
                        BOOL isActive = [v17 isActive];
                        if (isActive && recoveryStatus == 3 && recoveryConfidence == 100) {
                            id v41 = 0;
                            if ([process _watchdog:v17 shouldTerminateWithDeclineReason:&v41] != 0) {
                                os_log_t oslog2 = FBLogProcess();
                                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                                    os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%{public}@ Terminating stuck process.", logProem);
                                }
                                id v43 = [NSError bs_errorWithDomain:FBSProcessWatchdogErrorDomain code:2 configuration:^void(id<BSErrorConfiguring> arg1) {
                                    id v53 = FBSProcessPrettyDescription(process);
                                    id v54 = _FBSNSStringFromUBIssueType(issueType);
                                    [arg1 setFailureReason:@"%@ is stuck (%@)", v53, v54];
                                }];
                                id v44 = [process _watchdog:v17 terminationRequestForError:v43];
                                [process _terminateWithRequest:v44 forWatchdog:v17];
                            }
                        }
                    }
                } else {
                    os_log_t oslog4 = FBLogProcess();
                    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                        id v36 = [arg1 descriptionWithMultilinePrefix:0];
                        os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "%{public}@ Unblock returned an error: %{public}@", logProem, v36);
                    }
                }
            };
            [v11 recover:v24 stackshotData:0 replyQueue:userInitiatedWorkloop callback:v25];
        });
        v5 = &v17;
    }
    return v5;
}


void -[FBProcessWatchdog .cxx_destruct](void)
{
    self->_cpuStatistics = nil;
    self->_eventContext = nil;
    self->_unblockSignal = nil;
    self->_handle = nil;
}


long -[FBProcessWatchdog event](void)
{
    return self->_event;
}


long -[FBProcessWatchdog deactivate](void)
{
    [self->_unblockSignal signal];
    self->_unblockSignal = nil;
    return [super deactivate];
}


void -[FBProcessWatchdog _getPolicyWallTime:cpuTime:](long *a1, long *a2)
{
    uint8_t v11[24];
    id policy = [self policy];
    id provisions = [policy provisions];
    double v5 = 0.0;
    double v6 = 0.0;
    for (id v9 in provisions) {
        long type = [v9 type];
        _memset(v11, 0, 24);
        if (v9 != nil) {
            [v9 allowance];
        }
        double v12 = FBSProcessResourceTimeIntervalForValue(FBSProcessResourceAllowanceGetValue(&v11));
        if (type != 2) {
            if (type == 1) {
                v6 = v12 + v6;
            }
        } else {
            v5 = v12 + v5;
        }
    }
    if (a1 != 0) {
        *(a1) = v6;
    }
    if (a2 != 0) {
        *(a2) = v5;
    }
}


NSString *-[FBProcessWatchdog _policyDesc](void)
{
    NSString *v5;
    double v0 = 0;
    double v1 = 0;
    [self _getPolicyWallTime:&v0 cpuTime:&v1];
    if (v0 <= 0.0 || v1 <= 0.0) {
        if (v0 > 0.0) {
            v5 = [NSString stringWithFormat:@"%.2fs", v0];
        } else if (v1 <= 0.0) {
            return @"n/a";
        } else {
            v5 = [NSString stringWithFormat:@"%.2fs cpu", v1];
        }
    } else {
        v5 = [NSString stringWithFormat:@"%.2fs cpu over %.2fs", v1, v0];
    }
    return v5;
}


FBProcessWatchdogEventContext *-[FBProcessWatchdog eventContext](void)
{
    return self->_eventContext;
}


FBProcessCPUStatistics *-[FBProcessWatchdog cpuStatistics](void)
{
    return self->_cpuStatistics;
}
