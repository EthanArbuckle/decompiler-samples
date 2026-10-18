static long FBAssertionDomain;

os_log_t FBLogProcess(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "Process");
    });
    return __logObj;
}


NSString *_descriptionForObject(id a1)
{
    NSString *v3;
    os_log_t oslog = FBLogAppDataStore();
    if (!os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        v3 = _publicDescriptionForObject(a1);
    } else {
        if (([a1 isNSNumber__] & 1) == 0) {
            if (([a1 isNSDate__] & 1) == 0 && a1 != kCFNull) {
                if ([a1 isNSString__] != 0) {
                    NSString *description2 = [a1 description];
                    v3 = [NSString stringWithFormat:@"<NSString: %p; \"%@\">", a1, description2];
                } else if ([a1 isNSData__]) {
                    NSUInteger length = [a1 length];
                    v3 = [NSString stringWithFormat:@"<NSData: %p; length = %lu>", a1, length];
                } else if (!a1) {
                    v3 = nil;
                } else {
                    NSString *v5 = NSStringFromClass([a1 classForCoder]);
                    NSString *description = [a1 description];
                    v3 = [NSString stringWithFormat:@"<%@: %p; %@>", v5, a1, description];
                }
                return v3;
            }
        }
        v3 = _publicDescriptionForObject(a1);
    }
    return v3;
}


NSString *_publicDescriptionForObject(id a1)
{
    NSString *v1;
    if (a1 == kCFNull) {
        return @"<null>";
    }
    if (([a1 isNSNumber__] & 1) != 0 || [a1 isNSDate__] != 0) {
        NSString *v2 = NSStringFromClass([a1 classForCoder]);
        NSString *description = [a1 description];
        return [NSString stringWithFormat:@"<%@; %@>", v2, description];
    }
    if ([a1 isNSString__] != 0) {
        NSUInteger length = [a1 length];
        return [NSString stringWithFormat:@"<NSString; length = %lu>", length];
    }
    if ([a1 isNSData__] != 0) {
        NSUInteger length2 = [a1 length];
        return [NSString stringWithFormat:@"<NSData; length = %lu>", length2];
    }
    if ([a1 isNSArray__] != 0) {
        long count2 = [a1 count];
        return [NSString stringWithFormat:@"<NSArray; count = %lu>", count2];
    }
    if ([a1 isNSDictionary__]) {
        long count = [a1 count];
        NSString *v7 = [NSString stringWithFormat:@"<NSDictionary; count = %lu>", count];
        v1 = v7;
    } else if (!a1) {
        v1 = nil;
    } else {
        NSString *v5 = NSStringFromClass([a1 classForCoder]);
        v1 = [NSString stringWithFormat:@"<%@>", v5];
    }
    return v1;
}


os_log_t FBLogProcessWorkspace(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "ProcessWorkspace");
    });
    return __logObj;
}


long FBProcessLaunchIntentDescription(long a1)
{
    if ((unsigned long)a1 > 5) {
        return 0;
    } else {
        return (&qword_1e17d5550)[a1];
    }
}


long OUTLINED_FUNCTION_12(long a1, long a2, long a3)
{
    return a1;
}


long OUTLINED_FUNCTION_24(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_24(long a1)
{
    return a1;
}


int FBWorkspaceStateCreate(int a1, int a2, int a3)
{
    int v0 = a1 | (a2 << 8);
    return v0 | (a3 << 16);
}


bool FBWorkspaceActivityIsValid(int a1)
{
    return (unsigned int)a1 < 4;
}


bool FBWorkspaceJetsamBandIsValid(long a1)
{
    return ((unsigned long)a1 <= 40 && ((1 << a1) & 0x10e40100001) != 0) || ((unsigned long)(a1 - 80) <= 21 && ((1 << a1 - 80) & 3146753) != 0);
}


bool FBWorkspaceStateEqual(int a1, int a2)
{
    return a1 == a2;
}


int FBWorkspaceStateGetActivity(int a1)
{
    return a1 & 255;
}


int FBWorkspaceStateGetProcessRole(int a1)
{
    return (a1 >> 8) & 255;
}


bool FBWorkspaceProcessRoleIsValid(int a1)
{
    return (unsigned int)a1 < 6;
}


int FBWorkspaceStateGetJetsamBand(int a1)
{
    return (a1 >> 16) & 255;
}


BSEventQueue *FBSceneIdleEventQueue(void)
{
    static dispatch_once_t onceToken;
    static BSEventQueue *__IdleEventQueue;
    dispatch_once(&onceToken, ^void(void) {
        __IdleEventQueue = [[BSEventQueue alloc] initWithName:@"SceneIdleEvents" onQueue:dispatch_get_main_queue()];
    });
    return __IdleEventQueue;
}


Class OUTLINED_FUNCTION_5(id self)
{
    return [self class];
}


Class OUTLINED_FUNCTION_5(id a1)
{
    return [a1 class];
}


long OUTLINED_FUNCTION_14(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_0(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_21(long a1, long a2)
{
}


void OUTLINED_FUNCTION_21(long a1, long a2)
{
    long *v0 = a1 + a2;
    *(v0) = 0;
}


long OUTLINED_FUNCTION_21(void *self)
{
    return self;
}


long OUTLINED_FUNCTION_25(long a1)
{
    return a1;
}


long OUTLINED_FUNCTION_25(long a1)
{
    return a1;
}


Class OUTLINED_FUNCTION_25(void)
{
    return [FBWorkspaceConnectionsState class];
}


long OUTLINED_FUNCTION_30(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_12(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[58];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 58);
}


void OUTLINED_FUNCTION_3(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[58];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 58);
}


void OUTLINED_FUNCTION_14(long a1)
{
}


Class OUTLINED_FUNCTION_14(id a1)
{
    return [a1 class];
}


long _OUTLINED_FUNCTION_33(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_14(long a1)
{
}


long OUTLINED_FUNCTION_14(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_10(long a1, long a2, long a3)
{
    return a1;
}


long NSStringFromFBProcessTaskState(long a1)
{
    if ((unsigned long)a1 > 3) {
        return 0;
    } else {
        return (&qword_1e17d70f8)[a1];
    }
}


Class OUTLINED_FUNCTION_19(void)
{
    return [FBWorkspaceEventDispatcherSource class];
}


void OUTLINED_FUNCTION_17(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[12];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 12);
}


long OUTLINED_FUNCTION_3(void)
{
    return &_mh_dylib_header;
}


Class OUTLINED_FUNCTION_22(id a1)
{
    return [a1 class];
}


long OUTLINED_FUNCTION_19(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_19(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_13(long a1, long a2, long a3)
{
}


bool OUTLINED_FUNCTION_1(void)
{
    return os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR);
}


void OUTLINED_FUNCTION_2(long a1)
{
}


long OUTLINED_FUNCTION_23(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_2(long a1)
{
}


long OUTLINED_FUNCTION_2(void)
{
    return &_mh_dylib_header;
}


bool OUTLINED_FUNCTION_2(void)
{
    return os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR);
}


long OUTLINED_FUNCTION_6(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_2(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_4(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


void OUTLINED_FUNCTION_2(long a1)
{
}


long OUTLINED_FUNCTION_2(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_2(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_2(long a1)
{
}


id NSStringFromProcessWatchdogEvent(long a1)
{
    if ((unsigned long)a1 < 5) {
        return (&qword_1e17d56b0)[a1];
    }
    return [NSString stringWithFormat:@"(invalid - %d)", a1];
}


void OUTLINED_FUNCTION_8(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[58];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 58);
}


Class OUTLINED_FUNCTION_10(id a1, long a2, long a3)
{
    return [a1 classForCoder];
}


void OUTLINED_FUNCTION_7(long a1)
{
}


long OUTLINED_FUNCTION_6(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_12(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_7(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_9(void *a1, os_log_t a2, char *a3, uint8_t *a4)
{
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, a4, 58);
}


void OUTLINED_FUNCTION_7(long a1)
{
}


void OUTLINED_FUNCTION_7(long a1)
{
}


void OUTLINED_FUNCTION_7(long a1)
{
}


long NSStringFromFBProcessVisibility(long a1)
{
    if ((unsigned long)a1 > 3) {
        return 0;
    } else {
        return (&qword_1e17d7118)[a1];
    }
}


NSUInteger OUTLINED_FUNCTION_29(id a1)
{
    NSFastEnumerationState v0;
    long v1;
    return [a1 countByEnumeratingWithState:&v0 objects:&v1 count:16];
}


NSString *NSStringFromFBWorkspaceState(int a1)
{
    id v0 = NSStringFromFBWorkspaceActivity(a1 & 255);
    id v1 = NSStringFromFBWorkspaceProcessRole((a1 >> 8) & 255);
    return [NSString stringWithFormat:@"%@-%@[%u]", v0, v1, (a1 >> 16) & 255];
}


void (^FBAnalyticsLogHangTracerEvent(id a1, long a2))(bool)
{
    int v8;
    int v9;
    id v19;
    void (^v2)(bool);
    NSString *bundleIdentifier = [a1 bundleIdentifier];
    if (!bundleIdentifier || ![[a1 identity] isEmbeddedApplication]) {
        return nil;
    }
    id v5 = objc_getAssociatedObject(a1, &FBAnalyticsLogHangTracerEvent.__FBAnalyticsHangTracerID);
    unsigned long v6 = [v5 unsignedLongLongValue];
    if (!v6) {
        v6 = HTAppActivationGenerateAppIdentifier([bundleIdentifier UTF8String]);
        NSNumber *value = [NSNumber numberWithUnsignedLongLong:v6];
        objc_setAssociatedObject(a1, &FBAnalyticsLogHangTracerEvent.__FBAnalyticsHangTracerID, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    switch (a2) {
        case 1:
            v8 = 1;
            v9 = 2;
            break;
        case 2:
            v8 = 1;
            v9 = 4;
            break;
        default:
            if (a2 != 3) {
                return nil;
            }
            v8 = 0;
            v9 = 8;
            break;
    }
    int pid = [a1 pid];
    NSNumber *v12 = [NSNumber numberWithInt:pid];
    bool isForeground = [a1 isForeground];
    NSNumber *v15 = [NSNumber numberWithInt:isForeground];
    NSDictionary *v16 = @{kHTAppActivationKeyPID: v12, kHTAppActivationKeyBundleID: bundleIdentifier, kHTAppActivationKeyState: v15};
    if (a2 != 1) {
        if (a2 == 3) {
            FBProcessExitContext *exitContext = [a1 exitContext];
            unsigned long exitReason = [exitContext exitReason];
            if (exitReason == 16) {
                v19 = [v16 mutableCopy];
                [v19 setObject:kHTAppActivationKeyFailureReason forKey:@8ULL];
                v16 = v19;
            } else if (exitReason == 2) {
                v19 = [v16 mutableCopy];
                NSNumber *v20 = [NSNumber numberWithInt:kHTAppActivationFailureReasonWatchdog];
                [v19 setObject:kHTAppActivationKeyFailureReason forKey:v20];
                v16 = v19;
            }
        }
    } else {
        HTAppActivationEvent(v6, 1, v16);
    }
    long v21 = HTAppActivationEvent(v6, v9, v16);
    if (((!v21) ? 0 : v8) != 1) {
        v2 = nil;
    } else {
        v2 = ^void(bool arg1) {
            if (!arg1) {
                return;
            }
            id v24 = v16;
            if (v21 != 0) {
                id v25 = [v24 mutableCopy];
                NSNumber *v26 = [NSNumber numberWithUnsignedLongLong:v21];
                [v25 setObject:kHTAppActivationKeyEventToken forKey:v26];
                v24 = v25;
            }
            HTAppActivationEvent(v6, 5, v24);
        };
    }
    return v2;
}


long OUTLINED_FUNCTION_4(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_11(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_4(void *a1)
{
}


void OUTLINED_FUNCTION_4(void *self, char *a1)
{
}


long OUTLINED_FUNCTION_11(long a1)
{
    return a1;
}


void *OUTLINED_FUNCTION_4(void *a1)
{
    return a1;
}


long OUTLINED_FUNCTION_12(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_4(void *a1, char *a2)
{
}


void OUTLINED_FUNCTION_4(void *a1)
{
}


void OUTLINED_FUNCTION_4(void *a1, char *a2, os_log_t a3)
{
    unsigned char v0[28];
    _os_log_error_impl(a1, a3, OS_LOG_TYPE_ERROR, a2, v0, 28);
}


void OUTLINED_FUNCTION_12(void *a1, os_log_t a2, char *a3, uint8_t *a4)
{
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, a4, 38);
}


long OUTLINED_FUNCTION_12(void)
{
    return BSServiceConnection;
}


long OUTLINED_FUNCTION_12(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_12(long a1)
{
    return a1;
}


os_log_t FBLogTransaction(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "Transaction");
    });
    return __logObj;
}


NSUInteger OUTLINED_FUNCTION_23(NSFastEnumerationState *a1, long a2, id a3)
{
    return [a3 countByEnumeratingWithState:a1 objects:a2 count:16];
}


void OUTLINED_FUNCTION_23(void *a1, os_log_t a2, char *a3, uint8_t *a4)
{
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, a4, 12);
}


void OUTLINED_FUNCTION_23(long a1)
{
}


bool _FBSceneActionIsSignificant(int a1)
{
    return (unsigned int)a1 > 1;
}


int FBSceneLifecycleStateForSettings(id a1)
{
    if (!a1) {
        return 0;
    } else {
        return (([a1 isForeground]) ? 2 : 1) & 255;
    }
}


os_log_t FBLogProcessScene(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "ProcessScene");
    });
    return __logObj;
}


id _FBSceneActionToString(int a1)
{
    if ((unsigned int)a1 < 6) {
        return (&qword_1e17d6638)[a1];
    }
    return [NSString stringWithFormat:@"(invalid - %d)", a1];
}


id NSStringFromFBWorkspaceActivity(int a1)
{
    if ((unsigned int)a1 < 4) {
        return (&qword_1e17d7780)[a1];
    }
    return [NSString stringWithFormat:@"(unknown %i)", a1];
}


id NSStringFromFBWorkspaceProcessRole(int a1)
{
    if ((unsigned int)a1 < 6) {
        return (&qword_1e17d77a0)[a1];
    }
    return [NSString stringWithFormat:@"(unknown %i)", a1];
}


long OUTLINED_FUNCTION_9(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_1(long a1)
{
    return a1;
}


long OUTLINED_FUNCTION_11(long a1)
{
    return a1;
}


long OUTLINED_FUNCTION_11(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_11(void)
{
    return NSString;
}


Class OUTLINED_FUNCTION_11(id a1, long a2, long a3)
{
    return [a1 classForCoder];
}


void OUTLINED_FUNCTION_11(long a1)
{
}


long OUTLINED_FUNCTION_5(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_5(long a1)
{
}


long OUTLINED_FUNCTION_5(void)
{
    return NSString;
}


long *OUTLINED_FUNCTION_5(long *a1)
{
    *(a1) = &_NSConcreteStackBlock;
    return a1;
}


long OUTLINED_FUNCTION_5(void)
{
    return NSString;
}


os_log_t FBLogScene(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "Scene");
    });
    return __logObj;
}


id NSStringFromFBSceneContentState(long a1)
{
    if ((unsigned long)a1 < 3) {
        return (&qword_1e17d7538)[a1];
    }
    return [NSString stringWithFormat:@"(%li)", a1];
}


id FBSceneLifecycleStateDescription(int a1)
{
    if ((unsigned int)a1 < 3) {
        return (&qword_1e17d6278)[a1];
    }
    return [NSString stringWithFormat:@"(Unknown:%li)", a1];
}


void OUTLINED_FUNCTION_15(long a1)
{
}


void OUTLINED_FUNCTION_15(long a1)
{
}


long OUTLINED_FUNCTION_1(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_15(long a1, long *a2)
{
    *(a2) = &_NSConcreteStackBlock;
    return a1;
}


void OUTLINED_FUNCTION_20(long a1)
{
}


void OUTLINED_FUNCTION_20(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[22];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 22);
}


long OUTLINED_FUNCTION_13(void *self)
{
    return self;
}


long OUTLINED_FUNCTION_13(void)
{
    return BSServiceDispatchQueue;
}


void OUTLINED_FUNCTION_13(long a1)
{
}


long OUTLINED_FUNCTION_13(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_13(void)
{
    return NSString;
}


void OUTLINED_FUNCTION_13(long a1)
{
}


int *OUTLINED_FUNCTION_13(void)
{
    return __error();
}


void OUTLINED_FUNCTION_8(long a1)
{
}


long OUTLINED_FUNCTION_8(void)
{
    return &_mh_dylib_header;
}


long OUTLINED_FUNCTION_8(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_22(void)
{
    objc_opt_self(FBWorkspaceEventDispatcher);
}


void OUTLINED_FUNCTION_22(void *a1, os_log_t a2, char *a3, uint8_t *a4)
{
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, a4, 22);
}


BOOL OUTLINED_FUNCTION_22(void)
{
    return [NSThread isMainThread];
}


void OUTLINED_FUNCTION_22(long a1)
{
}


int FBWorkspaceStateCombine(int a1, int a2)
{
    int v0 = a1 & 255;
    int v1 = a2 & 255;
    if ((unsigned int)v0 <= (uint8_t)a2) {
        v0 = v1;
    }
    int v2 = (a1 >> 8) & 255;
    int v3 = (a2 >> 8) & 255;
    if ((unsigned int)v2 <= (uint8_t)(a2 / 0x100)) {
        v2 = v3;
    }
    int v4 = (a1 >> 16) & 255;
    int v5 = (a2 >> 16) & 255;
    if ((unsigned int)v4 <= (uint8_t)(a2 >> 16)) {
        v4 = v5;
    }
    int v6 = v0 | (v2 << 8);
    return v6 | (v4 << 16);
}


void OUTLINED_FUNCTION_17(long a1)
{
}


id FBSystemAppBundleID(void)
{
    static dispatch_once_t onceToken;
    static id __BundleID;
    dispatch_once(&onceToken, ^void(void) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *bundleIdentifier = [mainBundle bundleIdentifier];
        __BundleID = [bundleIdentifier copy];
    });
    return __BundleID;
}


void FBOpenAppSystemServiceExecuteCallOut(id a1, void (^a2)(void))
{
    void (^v0)(void) = a2;
    if (a1 != nil && ![a1 isKindOfClass:[NSString class]]) {
        Class v8 = [a1 classForCoder];
        if (!v8) {
            v8 = [a1 class];
        }
        NSString *v9 = NSStringFromClass(v8);
        NSString *v10 = NSStringFromClass([NSString class]);
        NSString *v11 = [NSString stringWithFormat:@"Value for '%@' was of unexpected class %@. Expected %@.", @"instance", v9, v10];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v12 = [NSString stringWithUTF8String:"void FBOpenAppSystemServiceExecuteCallOut(NSString *__strong, __strong dispatch_block_t)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v12, @"FBSystemService.m", 104, v11);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    NSThread *currentThread2 = [NSThread currentThread];
    NSMutableDictionary *threadDictionary = [currentThread2 threadDictionary];
    if (!threadDictionary) {
        NSThread *currentThread = [NSThread currentThread];
        NSString *v15 = [NSString stringWithFormat:@"missing thread-local storage on %@", currentThread];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = [NSString stringWithUTF8String:"void FBOpenAppSystemServiceExecuteCallOut(NSString *__strong, __strong dispatch_block_t)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v16, @"FBSystemService.m", 108, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    id v4 = [threadDictionary objectForKey:@"FBOpenAppSystemServiceInstance"];
    if (v4 != nil) {
        NSString *v18 = [NSString stringWithFormat:@"FBCurrentOpenAppSystemServiceInstanceKey should be nil when not in a callout"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = [NSString stringWithUTF8String:"void FBOpenAppSystemServiceExecuteCallOut(NSString *__strong, __strong dispatch_block_t)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v19, @"FBSystemService.m", 109, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    if (!a1) {
        @autoreleasepool {
            v0();
        }
    } else {
        [threadDictionary setObject:a1 forKey:@"FBOpenAppSystemServiceInstance"];
        @autoreleasepool {
            v0();
        }
        [threadDictionary removeObjectForKey:@"FBOpenAppSystemServiceInstance"];
    }
    id v7 = [threadDictionary objectForKey:@"FBOpenAppSystemServiceInstance"];
    if (v7 != nil) {
        NSString *v21 = [NSString stringWithFormat:@"FBCurrentOpenAppSystemServiceInstanceKey should be nil when not in a callout"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v22 = [NSString stringWithUTF8String:"void FBOpenAppSystemServiceExecuteCallOut(NSString *__strong, __strong dispatch_block_t)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v22, @"FBSystemService.m", 119, v21);
        }
        _bs_set_crash_log_message([v21 UTF8String]);
        __break(0);
    }
}


id NSStringFromFBWorkspaceDomainSelfAssertRuntime(int a1)
{
    if ((unsigned int)a1 < 3) {
        return (&qword_1e17d5e58)[a1];
    }
    return [NSString stringWithFormat:@"unknown(%i)", a1];
}


void OUTLINED_FUNCTION_32(long a1, dispatch_queue_t a2, long a3, long a4, long a5)
{
    long v0;
    dispatch_async_and_wait(a2, &v0);
}


long OUTLINED_FUNCTION_26(void *self)
{
    return self;
}


long OUTLINED_FUNCTION_26(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_27(void *a1, long a2)
{
}


void OUTLINED_FUNCTION_27(void *a1)
{
}


Class OUTLINED_FUNCTION_27(void *a1)
{
    return [a1->field_2696 class];
}


NSArray *OUTLINED_FUNCTION_28(long a1)
{
    if (!a1) {
        return @[];
    }
    return a1;
}


NSError *FBSceneErrorCreate(NSInteger a1, id a2, id a3)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    id v3 = NSStringFromFBSceneErrorCode(a1);
    [dictionary setObject:v3 forKey:BSErrorCodeDescriptionKey];
    [dictionary setObject:a2 forKey:NSLocalizedFailureReasonErrorKey];
    if (a3 != nil) {
        [dictionary setObject:a3 forKey:NSUnderlyingErrorKey];
    }
    return [NSError errorWithDomain:@"FBSceneErrorDomain" code:a1 userInfo:dictionary];
}


id NSStringFromFBSceneErrorCode(long a1)
{
    if ((unsigned long)a1 < 6) {
        return (&qword_1e17d67a8)[a1];
    }
    return [NSString stringWithFormat:@"(unknown:%ld)", a1];
}


NSString *FBSceneLayerTypeDescription(long a1)
{
    if ((unsigned long)a1 > 4) {
        return @"(unknown)";
    } else {
        return (&qword_1e17d6ac8)[a1];
    }
}


void OUTLINED_FUNCTION_18(long a1)
{
}


long OUTLINED_FUNCTION_18(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_18(long a1)
{
}


long OUTLINED_FUNCTION_18(void)
{
    return NSString;
}


long UIKitLibraryCore(long a1)
{
    static long frameworkLibrary;
    uint8_t v3[48];
    long v2 = frameworkLibrary;
    if (!v2) {
        *(__uint128_t *)&v3[0] = xmmword_1e17d77d0;
        *(__uint128_t *)&v3[16] = xmmword_1e17d77e0;
        *(uint64_t *)&v3[32] = 0;
        __block long v0 = _sl_dlopen(&v3, a1);
        frameworkLibrary = v0;
        v2 = v0;
    }
    return v2;
}


long getUIApplicationClass(void)
{
    static long softClass;
    long v2 = softClass;
    if (!v2) {
        UIKitLibraryCore(0);
        __block long v0 = objc_getClass("UIApplication");
        softClass = v0;
        v2 = v0;
    }
    return v2;
}


id FBWorkspaceSceneErrorCreate(long a1, id a2, id a3, id a4)
{
    return [NSError bs_errorWithDomain:@"FBWorkspaceScene" code:a1 configuration:^void(id<BSErrorConfiguring> arg1) {
        id v1 = NSStringFromFBWorkspaceSceneErrorCode(a1);
        [arg1 setCodeDescription:v1];
        [arg1 setFailureDescription:a2];
        [arg1 setFailureReason:@"%@", a3];
        [arg1 setUnderlyingError:a4];
    }];
}


id NSStringFromFBWorkspaceSceneErrorCode(long a1)
{
    if ((unsigned long)a1 < 3) {
        return (&qword_1e17d6880)[a1];
    }
    return [NSString stringWithFormat:@"(unknown:%ld)", a1];
}


void OUTLINED_FUNCTION_16(long a1)
{
}


long OUTLINED_FUNCTION_16(void)
{
    return &_mh_dylib_header;
}


id FBGetFencingProvider(void)
{
    return [_FBDefaultFencingProvider sharedInstance];
}


long getUIWindowClass(void)
{
    static long softClass;
    long v2 = softClass;
    if (!v2) {
        UIKitLibraryCore(0);
        __block long v0 = objc_getClass("UIWindow");
        softClass = v0;
        v2 = v0;
    }
    return v2;
}


NSString *NSStringFromFBProcessExitReason(long a1)
{
    if (a1 <= 7) {
        if (a1 > 1) {
            if (a1 == 2) {
                return @"watchdog";
            }
            if (a1 == 4) {
                return @"crash";
            }
            return @"(invalid)";
        }
        if (!a1) {
            return @"unknown";
        }
        if (a1 != 1) {
            return @"(invalid)";
        } else {
            return @"voluntary";
        }
    }
    if (a1 <= 31) {
        switch (a1) {
            case 8:
                return @"signal";
            case 16:
                return @"jetsam";
            default:
                return @"(invalid)";
        }
    } else {
        switch (a1) {
            case 32:
                return @"fairplay";
            case 64:
                return @"launch-failed";
            case 128:
                return @"other";
            default:
                return @"(invalid)";
        }
    }
}


void OUTLINED_FUNCTION_10(long a1)
{
}


void OUTLINED_FUNCTION_10(long a1)
{
}


long OUTLINED_FUNCTION_10(void)
{
    return NSString;
}


long OUTLINED_FUNCTION_10(void)
{
    return NSString;
}


void OUTLINED_FUNCTION_10(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_debug_impl(a1, a2, OS_LOG_TYPE_DEBUG, a3, v0, 2);
}


Class OUTLINED_FUNCTION_10(void)
{
    return [RBSProcessHandle class];
}


void OUTLINED_FUNCTION_3(long a1)
{
}


long OUTLINED_FUNCTION_3(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_3(long a1)
{
}


void OUTLINED_FUNCTION_3(long a1)
{
}


long OUTLINED_FUNCTION_9(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_3(long a1)
{
}


void OUTLINED_FUNCTION_3(long a1)
{
}


void OUTLINED_FUNCTION_3(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[22];
    _os_log_debug_impl(a1, a2, OS_LOG_TYPE_DEBUG, a3, v0, 22);
}


void OUTLINED_FUNCTION_3(long a1)
{
}


long OUTLINED_FUNCTION_6(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_6(long a1)
{
}


void OUTLINED_FUNCTION_6(long a1)
{
}


long OUTLINED_FUNCTION_6(void)
{
    return &_mh_dylib_header;
}


Class __getBLSBacklightClass_block_invoke(void *a1)
{
    BacklightServicesLibrary();
    Class v0 = objc_getClass("BLSBacklight");
    a1->field_32->field_8->field_24 = v0;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v1 = [NSString stringWithUTF8String:"Class getBLSBacklightClass(void)_block_invoke"];
        [currentHandler handleFailureInFunction:v1 file:@"FBMainDisplayLayoutPublisher.m" lineNumber:25 description:@"Unable to find class %s", "BLSBacklight"];
        __builtin_trap();
    }
    getBLSBacklightClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


void BacklightServicesLibrary(void)
{
    uint8_t v2[32];
    void *v0 = 0;
    if (!BacklightServicesLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v2[0] = xmmword_1e17d5048;
        *(uint64_t *)&v2[16] = 0;
        BacklightServicesLibraryCore.frameworkLibrary = _sl_dlopen(&v2, &v0);
    }
    if (!BacklightServicesLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v4 = [NSString stringWithUTF8String:"void *BacklightServicesLibrary(void)"];
        [currentHandler handleFailureInFunction:v4 file:@"FBMainDisplayLayoutPublisher.m" lineNumber:24 description:@"%s", v0];
        __builtin_trap();
    }
    if (v0 != 0) {
        free(v0);
    }
}


long __BacklightServicesLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5048;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    BacklightServicesLibraryCore.frameworkLibrary = v1;
    return v1;
}


Class __getBLSRuntimeClass_block_invoke(void *a1)
{
    BacklightServicesLibrary();
    Class v0 = objc_getClass("BLSRuntime");
    a1->field_32->field_8->field_24 = v0;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v1 = [NSString stringWithUTF8String:"Class getBLSRuntimeClass(void)_block_invoke"];
        [currentHandler handleFailureInFunction:v1 file:@"FBMainDisplayLayoutPublisher.m" lineNumber:26 description:@"Unable to find class %s", "BLSRuntime"];
        __builtin_trap();
    }
    getBLSRuntimeClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


long NSStringFromFBSystemShellState(long a1)
{
    if ((unsigned long)a1 >= 3) {
        NSString *v1 = [NSString stringWithFormat:@"Unexplained system shell state defined: %d", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = [NSString stringWithUTF8String:"NSString * _Nonnull NSStringFromFBSystemShellState(FBSystemShellState)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v0, @"FBSystemShell.m", 39, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    } else {
        return (&qword_1e17d5450)[a1];
    }
}


void OUTLINED_FUNCTION_0(long a1)
{
}


long OUTLINED_FUNCTION_0(void)
{
    return &_mh_dylib_header;
}


void FBAnalyticsLogWatchdogEvent(id a1, id a2, id a3, id a4)
{
    NSInteger v8;
    id v1 = a2;
    id v2 = a3;
    id v3 = a4;
    if (!a1 || !v1 || !a4) {
        os_log_t oslog = FBLogWatchdog();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Invalid parameters for sending watchdog termination to Core Analytics");
        }
        return;
    }
    NSString *executablePath = [a1 executablePath];
    NSString *bundleIdentifier = [a1 bundleIdentifier];
    if (![v1 sceneSettings]) {
        v8 = 0;
    } else {
        FBSSceneSettings *sceneSettings = [v1 sceneSettings];
        v8 = ([sceneSettings isForeground]) ? 2 : 1;
    }
    long event = [v1 event];
    switch (event) {
        case 1:
        case 2:
        case 3:
        case 4:
            break;
        default:
            AnalyticsSendEventLazy(@"com.apple.frontboard.watchdog-terminate", ^NSDictionary *(void) {
                NSDictionary *v16 = [[NSMutableDictionary alloc] init];
                NSString *lastPathComponent = [executablePath lastPathComponent];
                [v16 bs_setSafeObject:lastPathComponent forKey:@"executableName"];
                [v16 bs_setSafeObject:bundleIdentifier forKey:@"bundleIdentifier"];
                NSNumber *v20 = [NSNumber numberWithInteger:v8];
                [v16 bs_setSafeObject:v20 forKey:@"watchdogVisibility"];
                long v21 = [v1 event];
                if (v21 - 1 >= 4) {
                    v21 = 0;
                }
                NSNumber *v22 = [NSNumber numberWithInteger:v21];
                [v16 bs_setSafeObject:v22 forKey:@"watchdogEventType"];
                long v23 = [v3 taskState];
                if (v23 - 1 >= 3) {
                    v23 = 0;
                }
                NSNumber *v24 = [NSNumber numberWithInteger:v23];
                [v16 bs_setSafeObject:v24 forKey:@"taskState"];
                long visibility = [v3 visibility];
                NSInteger v26 = 0;
                if (visibility - 1 <= 2) {
                    v26 = (&qword_1c4f5d1c8)[visibility - 1];
                }
                NSNumber *v27 = [NSNumber numberWithInteger:v26];
                [v16 bs_setSafeObject:v27 forKey:@"visibility"];
                if ([v2 isResourceProvision] != 0) {
                    long type = [v2 type];
                    NSNumber *v19 = [NSNumber numberWithInteger:(type == 2) ? type : type == 1];
                    [v16 bs_setSafeObject:v19 forKey:@"resourceType"];
                }
                return v16;
            });
            return;
    }
    id v13 = (&qword_1e17d54c0)[event - 1];
    if (v8 != 0) {
        NSString *v12 = [NSString stringWithFormat:(v8 == 2) ? @"com.apple.frontboard.watchdog-terminate.foreground.%@" : @"com.apple.frontboard.watchdog-terminate.background.%@", v13];
        ADClientAddValueForScalarKey(v12, 1);
    }
    if (bundleIdentifier != nil) {
        os_log_t log = FBLogWatchdog();
        if (os_signpost_enabled(log)) {
            os_signpost_emit_with_type(log, OS_SIGNPOST_EVENT, 0xeeeeb0b5b2b2eeee, "WatchdogKill", " enableTelemetry=YES BundleIdOverride=%{public, signpost.description:attribute}@ event=%{public, signpost.telemetry:string1}@ ExecutableURLKey=%{public, signpost.description:attribute}@", bundleIdentifier, v13, executablePath);
        }
    }
    AnalyticsSendEventLazy(@"com.apple.frontboard.watchdog-terminate", ^NSDictionary *(void) {
        NSDictionary *v28 = [[NSMutableDictionary alloc] init];
        NSString *lastPathComponent = [executablePath lastPathComponent];
        [v28 bs_setSafeObject:lastPathComponent forKey:@"executableName"];
        [v28 bs_setSafeObject:bundleIdentifier forKey:@"bundleIdentifier"];
        NSNumber *v32 = [NSNumber numberWithInteger:v8];
        [v28 bs_setSafeObject:v32 forKey:@"watchdogVisibility"];
        long v33 = [v1 event];
        if (v33 - 1 >= 4) {
            v33 = 0;
        }
        NSNumber *v34 = [NSNumber numberWithInteger:v33];
        [v28 bs_setSafeObject:v34 forKey:@"watchdogEventType"];
        long v35 = [v3 taskState];
        if (v35 - 1 >= 3) {
            v35 = 0;
        }
        NSNumber *v36 = [NSNumber numberWithInteger:v35];
        [v28 bs_setSafeObject:v36 forKey:@"taskState"];
        long visibility = [v3 visibility];
        NSInteger v38 = 0;
        if (visibility - 1 <= 2) {
            v38 = (&qword_1c4f5d1c8)[visibility - 1];
        }
        NSNumber *v39 = [NSNumber numberWithInteger:v38];
        [v28 bs_setSafeObject:v39 forKey:@"visibility"];
        if ([v2 isResourceProvision] != 0) {
            long type = [v2 type];
            NSNumber *v31 = [NSNumber numberWithInteger:(type == 2) ? type : type == 1];
            [v28 bs_setSafeObject:v31 forKey:@"resourceType"];
        }
        return v28;
    });
}


void OUTLINED_FUNCTION_0(long a1)
{
}


long OUTLINED_FUNCTION_0(long a1)
{
    return a1;
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


id _FBSNSStringFromUBIssueType(long a1)
{
    if ((unsigned long)a1 < 3) {
        return (&qword_1e17d5790)[a1];
    }
    return [NSString stringWithFormat:@"(unknown - %ld)", a1];
}


Class __getUBStuckServiceClass_block_invoke(void *a1)
{
    UnblockClientLibrary();
    Class v0 = objc_getClass("UBStuckService");
    a1->field_32->field_8->field_24 = v0;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v1 = [NSString stringWithUTF8String:"Class getUBStuckServiceClass(void)_block_invoke"];
        [currentHandler handleFailureInFunction:v1 file:@"FBProcessWatchdog.m" lineNumber:20 description:@"Unable to find class %s", "UBStuckService"];
        __builtin_trap();
    }
    getUBStuckServiceClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


void UnblockClientLibrary(void)
{
    uint8_t v2[32];
    void *v0 = 0;
    if (!UnblockClientLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v2[0] = xmmword_1e17d5750;
        *(uint64_t *)&v2[16] = 0;
        UnblockClientLibraryCore.frameworkLibrary = _sl_dlopen(&v2, &v0);
    }
    if (!UnblockClientLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v4 = [NSString stringWithUTF8String:"void *UnblockClientLibrary(void)"];
        [currentHandler handleFailureInFunction:v4 file:@"FBProcessWatchdog.m" lineNumber:19 description:@"%s", v0];
        __builtin_trap();
    }
    if (v0 != 0) {
        free(v0);
    }
}


long __UnblockClientLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5750;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    UnblockClientLibraryCore.frameworkLibrary = v1;
    return v1;
}


Class __getUBUnblockClientClass_block_invoke(void *a1)
{
    UnblockClientLibrary();
    Class v0 = objc_getClass("UBUnblockClient");
    a1->field_32->field_8->field_24 = v0;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v1 = [NSString stringWithUTF8String:"Class getUBUnblockClientClass(void)_block_invoke"];
        [currentHandler handleFailureInFunction:v1 file:@"FBProcessWatchdog.m" lineNumber:21 description:@"Unable to find class %s", "UBUnblockClient"];
        __builtin_trap();
    }
    getUBUnblockClientClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


NSBundle *FBFrameworkBundle(void)
{
    static NSBundle *__bundle;
    static dispatch_once_t __once;
    dispatch_once(&__once, ^void(void) {
        Class v0 = [FBSystemShell class];
        __bundle = [NSBundle bundleForClass:v0];
    });
    return __bundle;
}


void __FB_REPORT_MAIN_THREAD_VIOLATION__(int a1, char *a2)
{
    os_log_t oslog = FBLogCommon();
    os_log_type_t type = (a1 != 0) ? OS_LOG_TYPE_FAULT : OS_LOG_TYPE_ERROR;
    if (os_log_type_enabled(oslog, type)) {
        os_log_with_type(oslog, type & 255, "Use of SPI %{public}s is restricted to the main thread.", a2);
    }
    if ((a1 & 1) == 0) {
        NSString *v4 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"soft"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = [NSString stringWithUTF8String:"void __FB_REPORT_MAIN_THREAD_VIOLATION__(BOOL, const char *)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v2, @"FBBase.m", 33, v4);
        }
        _bs_set_crash_log_message([v4 UTF8String]);
        __break(0);
    }
}


long getCBControllerLowPowerModeCompletionTimeoutSeconds(void)
{
    long *v2 = getCBControllerLowPowerModeCompletionTimeoutSecondsSymbolLoc.ptr;
    if (!v2) {
        __block long v0 = dlsym(CoreBluetoothLibrary(), "CBControllerLowPowerModeCompletionTimeoutSeconds");
        getCBControllerLowPowerModeCompletionTimeoutSecondsSymbolLoc.ptr = v0;
        v2 = v0;
    }
    if (v2 != 0) {
        return *(v2);
    }
    NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
    NSString *v6 = [NSString stringWithUTF8String:"const NSInteger getCBControllerLowPowerModeCompletionTimeoutSeconds(void)"];
    [currentHandler handleFailureInFunction:v6 file:@"FBSystemService.m" lineNumber:69 description:@"%s", dlerror()];
    __builtin_trap();
}


long getNFHardwareManagerClass(void)
{
    static long softClass;
    long v2 = softClass;
    __block long v0 = softClass;
    if (!v2) {
        ^void(void) {
            uint8_t v8[32];
            void *v7 = 0;
            if (!NearFieldLibraryCore.frameworkLibrary) {
                *(__uint128_t *)&v8[0] = xmmword_1e17d5cf0;
                *(uint64_t *)&v8[16] = 0;
                NearFieldLibraryCore.frameworkLibrary = _sl_dlopen(&v8, &v7);
            }
            if (!NearFieldLibraryCore.frameworkLibrary) {
                NSAssertionHandler *currentHandler2 = [NSAssertionHandler currentHandler];
                NSString *v4 = [NSString stringWithUTF8String:"void *NearFieldLibrary(void)"];
                [currentHandler2 handleFailureInFunction:v4 file:@"FBSystemService.m" lineNumber:63 description:@"%s", v7];
                __builtin_trap();
            }
            if (v7 != 0) {
                free(v7);
            }
            v0 = objc_getClass("NFHardwareManager");
            if (!v0) {
                NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                NSString *v6 = [NSString stringWithUTF8String:"Class getNFHardwareManagerClass(void)_block_invoke"];
                [currentHandler handleFailureInFunction:v6 file:@"FBSystemService.m" lineNumber:64 description:@"Unable to find class %s", "NFHardwareManager"];
                __builtin_trap();
            }
            softClass = v0;
        }();
        v2 = v0;
    }
    return v2;
}


long getCBControllerClass(void)
{
    static long softClass;
    long v2 = softClass;
    __block long v0 = softClass;
    if (!v2) {
        ^void(void) {
            CoreBluetoothLibrary();
            v0 = objc_getClass("CBController");
            if (!v0) {
                NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                NSString *v5 = [NSString stringWithUTF8String:"Class getCBControllerClass(void)_block_invoke"];
                [currentHandler handleFailureInFunction:v5 file:@"FBSystemService.m" lineNumber:68 description:@"Unable to find class %s", "CBController"];
                __builtin_trap();
            }
            softClass = v0;
        }();
        v2 = v0;
    }
    return v2;
}


void *__getCBControllerLowPowerModeCompletionTimeoutSecondsSymbolLoc_block_invoke(void *a1)
{
    long v0 = CoreBluetoothLibrary();
    void *v1 = dlsym(v0, "CBControllerLowPowerModeCompletionTimeoutSeconds");
    a1->field_32->field_8->field_24 = v1;
    getCBControllerLowPowerModeCompletionTimeoutSecondsSymbolLoc.ptr = a1->field_32->field_8->field_24;
    return v1;
}


long CoreBluetoothLibrary(void)
{
    uint8_t v2[32];
    void *v0 = 0;
    if (!CoreBluetoothLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v2[0] = xmmword_1e17d5cc0;
        *(uint64_t *)&v2[16] = 0;
        CoreBluetoothLibraryCore.frameworkLibrary = _sl_dlopen(&v2, &v0);
    }
    if (!CoreBluetoothLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v4 = [NSString stringWithUTF8String:"void *CoreBluetoothLibrary(void)"];
        [currentHandler handleFailureInFunction:v4 file:@"FBSystemService.m" lineNumber:67 description:@"%s", v0];
        __builtin_trap();
    }
    if (v0 != 0) {
        free(v0);
    }
    return CoreBluetoothLibraryCore.frameworkLibrary;
}


long __CoreBluetoothLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5cc0;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    CoreBluetoothLibraryCore.frameworkLibrary = v1;
    return v1;
}


void *__getAKSEventsRegisterSymbolLoc_block_invoke(void *a1)
{
    uint8_t v3[32];
    void *v1 = 0;
    if (!AppleKeyStoreLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v3[0] = xmmword_1e17d5cd8;
        *(uint64_t *)&v3[16] = 0;
        AppleKeyStoreLibraryCore.frameworkLibrary = _sl_dlopen(&v3, &v1);
    }
    if (!AppleKeyStoreLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v6 = [NSString stringWithUTF8String:"void *AppleKeyStoreLibrary(void)"];
        [currentHandler handleFailureInFunction:v6 file:@"FBSystemService.m" lineNumber:54 description:@"%s", v1];
        __builtin_trap();
    }
    if (v1 != 0) {
        free(v1);
    }
    void *v5 = dlsym(AppleKeyStoreLibraryCore.frameworkLibrary, "AKSEventsRegister");
    a1->field_32->field_8->field_24 = v5;
    getAKSEventsRegisterSymbolLoc.ptr = a1->field_32->field_8->field_24;
    return v5;
}


long __AppleKeyStoreLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5cd8;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    AppleKeyStoreLibraryCore.frameworkLibrary = v1;
    return v1;
}


Class __getNFHardwareManagerClass_block_invoke(void *a1)
{
    uint8_t v2[32];
    void *v0 = 0;
    if (!NearFieldLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v2[0] = xmmword_1e17d5cf0;
        *(uint64_t *)&v2[16] = 0;
        NearFieldLibraryCore.frameworkLibrary = _sl_dlopen(&v2, &v0);
    }
    if (!NearFieldLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v5 = [NSString stringWithUTF8String:"void *NearFieldLibrary(void)"];
        [currentHandler handleFailureInFunction:v5 file:@"FBSystemService.m" lineNumber:63 description:@"%s", v0];
        __builtin_trap();
    }
    if (v0 != 0) {
        free(v0);
    }
    Class v3 = objc_getClass("NFHardwareManager");
    a1->field_32->field_8->field_24 = v3;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler2 = [NSAssertionHandler currentHandler];
        NSString *v7 = [NSString stringWithUTF8String:"Class getNFHardwareManagerClass(void)_block_invoke"];
        [currentHandler2 handleFailureInFunction:v7 file:@"FBSystemService.m" lineNumber:64 description:@"Unable to find class %s", "NFHardwareManager"];
        __builtin_trap();
    }
    getNFHardwareManagerClass.softClass = a1->field_32->field_8->field_24;
    return v3;
}


long __NearFieldLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5cf0;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    NearFieldLibraryCore.frameworkLibrary = v1;
    return v1;
}


Class __getCBControllerClass_block_invoke(void *a1)
{
    CoreBluetoothLibrary();
    Class v0 = objc_getClass("CBController");
    a1->field_32->field_8->field_24 = v0;
    if (!a1->field_32->field_8->field_24) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v1 = [NSString stringWithUTF8String:"Class getCBControllerClass(void)_block_invoke"];
        [currentHandler handleFailureInFunction:v1 file:@"FBSystemService.m" lineNumber:68 description:@"Unable to find class %s", "CBController"];
        __builtin_trap();
    }
    getCBControllerClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


long NearbyInteractionLibrary(void)
{
    uint8_t v2[32];
    void *v0 = 0;
    if (!NearbyInteractionLibraryCore.frameworkLibrary) {
        *(__uint128_t *)&v2[0] = xmmword_1e17d5d08;
        *(uint64_t *)&v2[16] = 0;
        NearbyInteractionLibraryCore.frameworkLibrary = _sl_dlopen(&v2, &v0);
    }
    if (!NearbyInteractionLibraryCore.frameworkLibrary) {
        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
        NSString *v4 = [NSString stringWithUTF8String:"void *NearbyInteractionLibrary(void)"];
        [currentHandler handleFailureInFunction:v4 file:@"FBSystemService.m" lineNumber:74 description:@"%s", v0];
        __builtin_trap();
    }
    if (v0 != 0) {
        free(v0);
    }
    return NearbyInteractionLibraryCore.frameworkLibrary;
}


long __NearbyInteractionLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[32];
    *(__uint128_t *)&v0[0] = xmmword_1e17d5d08;
    *(uint64_t *)&v0[16] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_32);
    NearbyInteractionLibraryCore.frameworkLibrary = v1;
    return v1;
}


void *__getNINotifySystemShutdownWithReasonSymbolLoc_block_invoke(void *a1)
{
    long v0 = NearbyInteractionLibrary();
    void *v1 = dlsym(v0, "NINotifySystemShutdownWithReason");
    a1->field_32->field_8->field_24 = v1;
    getNINotifySystemShutdownWithReasonSymbolLoc.ptr = a1->field_32->field_8->field_24;
    return v1;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


long OUTLINED_FUNCTION_9(void *self, long a1, float a2)
{
    *(uint32_t *)((uint8_t *)x29 - 96) = a2;
    *(x29 - 92) = a1;
    *(uint16_t *)((uint8_t *)x29 - 84) = 2114;
    *(x29 - 82) = self;
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


long OUTLINED_FUNCTION_0(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


long OUTLINED_FUNCTION_9(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


NSString *NSStringFromFBSceneLayerTypeMask(long a1, __uint128_t a2)
{
    Block_layout v3;
    uint8_t v4[32];
    long v0 = a1 & 26;
    if ((a1 & 26) == 26) {
        return @"all";
    }
    NSMutableArray *array = [NSMutableArray array];
    v3.isa = &_NSConcreteStackBlock;
    v3.flags = 0xc0000000;
    *(uint64_t *)&v4[0] = &__NSStringFromFBSceneLayerTypeMask_block_invoke;
    *(uint64_t *)&v4[8] = &qword_1e17d6aa8;
    if (v0) {
        long v8 = 0;
        *(uint8_t *)&v4[31] = 0;
        int v9 = addv(cnt(a2));
        do {
            if (((1 << v8) & v0) != 0) {
                __NSStringFromFBSceneLayerTypeMask_block_invoke(&v3, 1 << v8, v8);
                if ((*(uint8_t *)&v4[31] & 1) != 0) {
                    break;
                }
                v9--;
            }
            v8++;
        } while (v9 >= 1 && v8 < 63);
    }
    return (![array count]) ? @"none" : [array componentsJoinedByString:@", "];
}


void *__NSStringFromFBSceneLayerTypeMask_block_invoke(void *a1, int a2)
{
    if ((unsigned int)a2 > 4 || ((1 << a2) & 26) == 0) {
        return a1;
    }
    if ((unsigned int)(a2 - 1) > 3) {
        return [a1->field_32 addObject:@"(unknown)"];
    } else {
        return [a1->field_32 addObject:(&qword_1e17d6af0)[a2 - 1]];
    }
}


long FBSceneLayerTypeMaskForType(long a1)
{
    if ((unsigned long)(a1 - 1) > 3) {
        return 0;
    } else {
        return (&qword_1c4f5d370)[a1 - 1];
    }
}


bool FBSceneLayerTypeMaskContainsType(long a1, long a2)
{
    if ((unsigned long)(a2 - 1) > 3) {
        return false;
    } else {
        return ((&qword_1c4f5d370)[a2 - 1] & a1) != 0;
    }
}


id NSStringFromFBWatchdogBehavior(long a1)
{
    if ((unsigned long)a1 < 3) {
        return (&qword_1e17d6b10)[a1];
    }
    return [NSString stringWithFormat:@"UnknownWatchdogBehavior (%ld)", a1];
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


long OUTLINED_FUNCTION_1(void)
{
    return NSString;
}


void _handleApplicationsRegisteredNotification(CFNotificationCenterRef a1, void *a2, CFNotificationName a3, const void *a4, CFDictionaryRef a5)
{
    id v2;
    id v6 = a2;
    Class v0 = [NSDictionary class];
    if (v0) {
        v2 = ([a5 isKindOfClass:v0]) ? a5 : nil;
    } else {
        v2 = nil;
    }
    id v3 = [v2 bs_safeArrayForKey:@"bundleIDs"];
    id v4 = [v3 bs_objectsOfClass:[NSString class]];
    [v6 _performAfterDeferredWork:^void(void) {
        [v6 _handleApplicationInstalled:v4];
    }];
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


NSString *FBServiceClientAuthenticatorErrorCodeDescription(int a1)
{
    if (a1 > 12 || a1 != 0) {
        if ((a1 <= 12 || (a1 != 13 && a1 != 22)) && (a1 > 12 || !a1 || a1 != 3)) {
            return nil;
        }
        return [NSString stringWithCString:strerror(a1) encoding:NSUTF8StringEncoding];
    }
    return @"(none)";
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_9(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


os_log_t FBLogSceneMutation(void)
{
    static dispatch_once_t onceToken;
    static os_log_t __logObj;
    dispatch_once(&onceToken, ^void(void) {
        __logObj = os_log_create(FBLoggingSubsystem, "SceneMutation");
    });
    return __logObj;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


id FBWorkspaceDomainInitialize(void)
{
    return [FBProcessManager sharedInstance];
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_0(long a1)
{
}


NSString *_pathForIdentifierAndBuffer(id a1, int a2)
{
    NSUInteger length = [a1 length];
    if (length - 26 <= -26) {
        NSString *v5 = [NSString stringWithFormat:@"improper length identifier : \"%@\"", a1];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = [NSString stringWithUTF8String:"NSString *_pathForIdentifierAndBuffer(NSString *__strong, BOOL)"];
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ (%{public}@:%i) : %{public}@", v6, @"FBWorkspaceConnectionsStateStore.m", 57, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    return [NSString stringWithFormat:@"/FBW%d:%@", (a2 != 0) ? 2 : 1, a1];
}


long OUTLINED_FUNCTION_0(void)
{
    return &_mh_dylib_header;
}


void OUTLINED_FUNCTION_1(long a1)
{
}


long OUTLINED_FUNCTION_35(void *self)
{
    return self;
}


id FBSystemShellInitialize(void (^a1)(long))
{
    id v11;
    id v22;
    void (^v0)(long) = a1;
    BSSetMainThreadPriorityFixedForUI(1);
    RBSAssertion *v1 = [RBSAssertion alloc];
    id currentProcess = [RBSTarget currentProcess];
    id v3 = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:@"SystemShell-Initialize"];
    NSArray *v5 = @[v3];
    RBSAssertion *v6 = [v1 initWithExplanation:@"FBSystemShellInitialize" target:currentProcess attributes:v5];
    [v6 acquireWithError:0];
    @autoreleasepool {
        id extendAutomaticBootstrapCompletion = [BSServicesConfiguration extendAutomaticBootstrapCompletion];
        FBMutableSystemShellInitializationOptions *v9 = [[FBMutableSystemShellInitializationOptions alloc] init];
        if (v0 != 0) {
            v0(v9);
        }
        kdebug_trace(0x2b850030, 0, 0, 0, 0);
        v11 = [FBSystemShell _createSingletonWithOptions:v9];
        bool initializeDisplayManager = [v9 initializeDisplayManager];
        id v13 = nil;
        if (initializeDisplayManager) {
            v13 = [FBDisplayManager sharedInstance];
        }
        kdebug_trace(0x2b850058, 0, 0, 0, 0);
        [FBServiceFacilityServer sharedInstance];
        [FBApplicationDataStoreRepositoryServer sharedInstance];
        if ([v9 initializeDisplayManager]) {
            [FBMainDisplayLayoutPublisher sharedInstance];
        }
        [FBSystemService sharedInstance];
        [FBSystemAppProxyServiceServer sharedInstance];
        [FBInterfaceOrientationService sharedInstance];
        void (^registerAdditionalServicesBlock)(void) = [v9 registerAdditionalServicesBlock];
        if (registerAdditionalServicesBlock != 0) {
            registerAdditionalServicesBlock();
        }
        id sharedInstance = [FBServiceFacilityServer sharedInstance];
        [sharedInstance run];
        id sharedInstance2 = [FBInterfaceOrientationService sharedInstance];
        [sharedInstance2 initialize];
        id sharedInstance3 = [FBServiceFacilityServer sharedInstance];
        [sharedInstance3 noteMilestoneReached:FBSServiceMilestoneServicesInitialized];
        kdebug_trace(0x2b85005c, 0, 0, 0, 0);
        kdebug_trace(0x2b850040, 0, 0, 0, 0);
        [v11 _startSystemShellService];
        kdebug_trace(0x2b850044, 0, 0, 0, 0);
        kdebug_trace(0x2b850060, 0, 0, 0, 0);
        id sharedInstance4 = [FBServiceFacilityServer sharedInstance];
        [sharedInstance4 noteMilestoneReached:FBSServiceMilestoneDataMigrationCompleted];
        [FBSceneManager sharedInstance];
        [FBProcessManager sharedInstance];
        if ([v9 initializeDisplayManager]) {
            [v13 postBookendConnections];
        }
        kdebug_trace(0x2b850064, 0, 0, 0, 0);
        kdebug_trace(0x2b850068, 0, 0, 0, 0);
        id sharedInstance5 = [FBServiceFacilityServer sharedInstance];
        [sharedInstance5 noteMilestoneReached:FBSServiceMilestoneFrontBoardInitialized];
        id sharedInstance6 = [FBInterfaceOrientationService sharedInstance];
        [sharedInstance6 startService];
        kdebug_trace(0x2b85006c, 0, 0, 0, 0);
        kdebug_trace(0x2b850034, 0, 0, 0, 0);
        if ([v9 resetDarkBootState]) {
            _FBDarkBootHelper *v21 = [[_FBDarkBootHelper alloc] init];
            [v21 clearBootedDark];
        }
        if (![v9 initializeDisplayManager]) {
            v22 = nil;
        } else {
            id sharedInstance7 = [FBMainDisplayLayoutPublisher sharedInstance];
            NSBundle *mainBundle = [NSBundle mainBundle];
            NSString *bundleIdentifier = [mainBundle bundleIdentifier];
            NSString *v26 = [NSString stringWithFormat:@"%@ Loading", bundleIdentifier];
            v22 = [sharedInstance7 transitionAssertionWithReason:v26];
        }
        [v11 _addBlockToExecuteWhenReady:^void(void) {
            id v27 = [FBServiceFacilityServer sharedInstance];
            [v27 noteMilestoneReached:FBSServiceMilestoneSystemApplicationInitialized];
            [v11 _informSystemShellServiceDidFinishLaunching];
            dispatch_async(dispatch_get_main_queue(), ^void(void) {
                NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
                [defaultCenter postNotificationName:_FBSApplicationLibraryReloadPlaceholdersNotification object:nil];
                [extendAutomaticBootstrapCompletion invalidate];
                id v28 = [FBProcessManager sharedInstance];
                [v28 _noteShellInitializationComplete];
                [v6 invalidate];
            });
            if (v22 != nil) {
                [v22 invalidate];
            }
        }];
        [v11 _initializationComplete];
        if ([v9 initializeReadyForInteraction]) {
            [v11 readyForInteraction];
        }
    }
    return v11;
}


void OUTLINED_FUNCTION_0(long a1)
{
}


void OUTLINED_FUNCTION_1(long a1)
{
}


long OUTLINED_FUNCTION_0(void)
{
    return &_mh_dylib_header;
}


long FBWorkspaceStateCompare(int a1, int a2)
{
    int v1;
    int v0 = a1 & 255;
    if ((a1 & 255) != (uint8_t)a2) {
        v1 = a2 & 255;
    }
    if ((a1 & 255) == (uint8_t)a2) {
        v0 = (a1 >> 8) & 255;
        if (((a1 >> 8) & 255) != (uint8_t)(a2 / 0x100)) {
            v1 = (a2 >> 8) & 255;
        }
    }
    if ((a1 & 255) != (uint8_t)a2 || ((a1 & 255) == (uint8_t)a2 && ((a1 >> 8) & 255) != (uint8_t)(a2 / 0x100))) {
        if ((unsigned int)v0 <= (unsigned int)v1) {
            return -1;
        } else {
            return 1;
        }
    }
    int v2 = (a1 >> 16) & 255;
    unsigned int v3 = a2 >> 16;
    if ((unsigned int)v2 < (uint8_t)(a2 >> 16)) {
        return -1;
    } else {
        return (unsigned int)v2 > (uint8_t)v3;
    }
}


long __UIKitLibraryCore_block_invoke(void *a1)
{
    uint8_t v0[48];
    *(__uint128_t *)&v0[0] = xmmword_1e17d77d0;
    *(__uint128_t *)&v0[16] = xmmword_1e17d77e0;
    *(uint64_t *)&v0[32] = 0;
    long v1 = _sl_dlopen(&v0, a1->field_40);
    a1->field_32->field_8->field_24 = v1;
    UIKitLibraryCore.frameworkLibrary = a1->field_32->field_8->field_24;
    return v1;
}


Class __getUIApplicationClass_block_invoke(void *a1)
{
    UIKitLibraryCore(0);
    Class v0 = objc_getClass("UIApplication");
    a1->field_32->field_8->field_24 = v0;
    getUIApplicationClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


long getUIApplicationSceneSpecificationClass(void)
{
    static long softClass;
    long v2 = softClass;
    if (!v2) {
        UIKitLibraryCore(0);
        __block long v0 = objc_getClass("UIApplicationSceneSpecification");
        softClass = v0;
        v2 = v0;
    }
    return v2;
}


Class __getUIApplicationSceneSpecificationClass_block_invoke(void *a1)
{
    UIKitLibraryCore(0);
    Class v0 = objc_getClass("UIApplicationSceneSpecification");
    a1->field_32->field_8->field_24 = v0;
    getUIApplicationSceneSpecificationClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


long getUIApplicationSceneTransitionContextClass(void)
{
    static long softClass;
    long v2 = softClass;
    if (!v2) {
        UIKitLibraryCore(0);
        __block long v0 = objc_getClass("UIApplicationSceneTransitionContext");
        softClass = v0;
        v2 = v0;
    }
    return v2;
}


Class __getUIApplicationSceneTransitionContextClass_block_invoke(void *a1)
{
    UIKitLibraryCore(0);
    Class v0 = objc_getClass("UIApplicationSceneTransitionContext");
    a1->field_32->field_8->field_24 = v0;
    getUIApplicationSceneTransitionContextClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}


Class __getUIWindowClass_block_invoke(void *a1)
{
    UIKitLibraryCore(0);
    Class v0 = objc_getClass("UIWindow");
    a1->field_32->field_8->field_24 = v0;
    getUIWindowClass.softClass = a1->field_32->field_8->field_24;
    return v0;
}
