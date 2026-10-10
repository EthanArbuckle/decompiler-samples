static Class _logos_superclass$_ungrouped$DOCKFileTile;
static NSHashTable *gTiles;
static bool gEnabled = true;
static id (*_logos_orig$_ungrouped$DOCKFileTile$label)(id, SEL);
static id gStyle = @"parens";
static void (*_logos_orig$_ungrouped$DOCKFileTile$setLabel$stripAppSuffix$)(id, SEL, id, bool);

__attribute__((constructor))
void _logosLocalCtor_bcc7232f(void)
{
    DockPidLoadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &DockPidPrefsChanged, @"com.doraorak.dockpid/prefsChanged", NULL, CFNotificationSuspensionBehaviorCoalesce);
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSNotificationCenter *notificationCenter = [sharedWorkspace notificationCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [notificationCenter addObserverForName:NSWorkspaceDidLaunchApplicationNotification object:nil queue:mainQueue usingBlock:^void(NSNotification *arg1) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 10);
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_after(when, queue, ^void(void) {
            DockPidRefreshTiles();
        });
    }];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue2 = [NSOperationQueue mainQueue];
    [defaultCenter addObserverForName:NSApplicationWillTerminateNotification object:nil queue:mainQueue2 usingBlock:^void(NSNotification *arg1) {
        DockPidRestoreTiles();
    }];
    NSOperationQueue *mainQueue3 = [NSOperationQueue mainQueue];
    [notificationCenter addObserverForName:NSWorkspaceDidTerminateApplicationNotification object:nil queue:mainQueue3 usingBlock:^void(NSNotification *arg1) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC / 10);
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_after(when, queue, ^void(void) {
            DockPidRefreshTiles();
        });
    }];
}


void DockPidLoadPrefs(void)
{
    bool v4;
    bool v2 = false;
    bool v3 = PSPreferencesGetAppBooleanValue(@"enabled", @"com.doraorak.dockpid", &v2);
    if (v2) {
        v4 = v3;
    } else {
        v4 = true;
    }
    bool v5 = v4;
    gEnabled = v5;
    id v6 = PSPreferencesCopyAppValue(@"style", @"com.doraorak.dockpid");
    Class v7 = [NSString class];
    if (![v6 isKindOfClass:v7]) {
        gStyle = @"parens";
        return;
    }
    gStyle = v6;
}


void DockPidPrefsChanged(CFNotificationCenterRef a1, void *a2, CFNotificationName a3, const void *a4, CFDictionaryRef a5)
{
    DockPidLoadPrefs();
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^void(void) {
        DockPidRefreshTiles();
    });
}


void DockPidRefreshTiles(void)
{
    if (!gTiles) {
        return;
    }
    NSArray *allObjects = [gTiles allObjects];
    for (id v7 in allObjects) {
        NSString *v8 = DockPidDecoratedLabel(v7);
        if (v8 != nil && [v7 respondsToSelector:@selector(setLabel:stripAppSuffix:)]) {
            [v7 setLabel:v8 stripAppSuffix:1];
        }
    }
}


void DockPidRestoreTiles(void)
{
    if (!gTiles) {
        return;
    }
    NSArray *allObjects = [gTiles allObjects];
    for (id v7 in allObjects) {
        id v8 = objc_getAssociatedObject(v7, @selector(label));
        if (v8 != nil && [v7 respondsToSelector:@selector(setLabel:stripAppSuffix:)]) {
            [v7 setLabel:v8 stripAppSuffix:1];
        }
    }
}


void _logosLocalDtor_d2bd0324(void *a1)
{
    DockPidRestoreTiles();
}


__attribute__((constructor))
void _logosLocalInit(void)
{
    Class cls = objc_getClass("DOCKFileTile");
    _logos_superclass$_ungrouped$DOCKFileTile = class_getSuperclass(cls);
    _logos_register_hook(cls, @selector(label), &_logos_method$_ungrouped$DOCKFileTile$label, &_logos_orig$_ungrouped$DOCKFileTile$label);
    _logos_register_hook(cls, @selector(setLabel:stripAppSuffix:), &_logos_method$_ungrouped$DOCKFileTile$setLabel$stripAppSuffix$, &_logos_orig$_ungrouped$DOCKFileTile$setLabel$stripAppSuffix$);
}


void _logos_register_hook(Class a1, SEL a2, IMP a3, IMP *a4)
{
    unsigned int v2;
    Class v0 = a1;
    while (1) {
        if (!v0) {
            return;
        }
        Method *v5 = class_copyMethodList(v0, &v2);
        for (int v3 = 0; (unsigned int)v3 < v2; v3++) {
            SEL v4 = method_getName(v5[v3]);
            if (v4 == a2) {
                if (a1 != v0) {
                    *(a4) = method_getImplementation(v5[v3]);
                    class_addMethod(a1, a2, a3, method_getTypeEncoding(v5[v3]));
                } else {
                    *(a4) = method_setImplementation(v5[v3], a3);
                }
                free(v5);
                return;
            }
        }
        free(v5);
        v0 = class_getSuperclass(v0);
    }
}


id _logos_method$_ungrouped$DOCKFileTile$label(id a1, SEL a2)
{
    NSString *v7;
    id v0 = objc_getAssociatedObject(a1, @selector(label));
    if (!v0) {
        id v1 = DockPidStripSuffix(_logos_orig$_ungrouped$DOCKFileTile$label(a1, a2));
        v0 = v1;
        objc_setAssociatedObject(a1, @selector(label), v0, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (!gTiles) {
        gTiles = [NSHashTable weakObjectsHashTable];
    }
    [gTiles addObject:a1];
    if (!gEnabled) {
        return v0;
    }
    id v4 = [v0 mutableCopy];
    if ([a1 respondsToSelector:@selector(bundleIdentifier)]) {
        v7 = [a1 bundleIdentifier];
    } else {
        v7 = nil;
    }
    NSString *v9 = v7;
    pid_t v11 = DockPidRunningPID(v9);
    if (v11 > 0) {
        NSString *v12 = DockPidSuffix(v11);
        NSString *v13 = [v0 stringByAppendingString:v12];
        id v14 = [v13 mutableCopy];
        v4 = v14;
    }
    [a1 setLabel:v4 stripAppSuffix:1];
    id v10 = [v4 copy];
    return v10;
}


void _logos_method$_ungrouped$DOCKFileTile$setLabel$stripAppSuffix$(id a1, SEL a2, id a3, bool a4)
{
    _logos_orig$_ungrouped$DOCKFileTile$setLabel$stripAppSuffix$(a1, a2, a3, a4);
}


NSString *DockPidDecoratedLabel(id a1)
{
    NSString *v8;
    NSString *v5;
    id v2 = objc_getAssociatedObject(a1, @selector(label));
    if (!v2) {
        return nil;
    }
    if (!gEnabled) {
        v8 = v2;
    } else {
        if ([a1 respondsToSelector:@selector(bundleIdentifier)]) {
            v5 = [a1 bundleIdentifier];
        } else {
            v5 = nil;
        }
        NSString *v7 = v5;
        pid_t v9 = DockPidRunningPID(v7);
        if (v9 != 0) {
            NSString *v10 = DockPidSuffix(v9);
            v8 = [v2 stringByAppendingString:v10];
        } else {
            v8 = v2;
        }
    }
    return v8;
}


pid_t DockPidRunningPID(id a1)
{
    pid_t v3;
    Class v2 = [NSString class];
    if (![a1 isKindOfClass:v2]) {
        return 0;
    }
    if ([a1 length] != 0) {
        NSArray<NSRunningApplication *> *v4 = [NSRunningApplication runningApplicationsWithBundleIdentifier:a1];
        if ([v4 count] != 0) {
            NSRunningApplication *v5 = [v4 objectAtIndex:0];
            v3 = [v5 processIdentifier];
        } else {
            v3 = 0;
        }
    } else {
        v3 = 0;
    }
    return v3;
}


NSString *DockPidSuffix(pid_t a1)
{
    if (![gStyle isEqualToString:@"brackets"]) {
        return (![gStyle isEqualToString:@"dash"]) ? [NSString stringWithFormat:@" (%d)", a1] : [NSString stringWithFormat:@" — %d", a1];
    }
    return [NSString stringWithFormat:@" [%d]", a1];
}


id DockPidStripSuffix(id a1)
{
    static NSRegularExpression *re;
    static dispatch_once_t once;
    id v3;
    Class v2 = [NSString class];
    if (![a1 isKindOfClass:v2]) {
        return a1;
    }
    if ([a1 length] != 0) {
        dispatch_once(&once, ^void(void) {
            re = [NSRegularExpression regularExpressionWithPattern:@"(\\s\\(\\d+\\)|\\s\\[\\d+\\]|\\s\\u2014\\s\\d+)$" options:0 error:nil];
        });
        if (re != nil) {
            NSString *v6 = a1;
            while (1) {
                NSUInteger length = [v6 length];
                long v17 = 0;
                NSTextCheckingResult *v8 = [re firstMatchInString:v6 options:0 range:(NSRange){v17, length}];
                bool v9 = true;
                if (v8 != nil) {
                    NSRange range = [v8 range];
                    if (range.location != NSNotFound) {
                        NSRange range2 = [v8 range];
                        v9 = !range2.length;
                    }
                }
                if (v9) {
                    break;
                } else {
                    NSRange range3 = [v8 range];
                    NSString *v14 = [v6 substringToIndex:range3.location];
                    v6 = v14;
                }
            }
            v3 = v6;
        } else {
            v3 = a1;
        }
    } else {
        v3 = a1;
    }
    return v3;
}


__attribute__((constructor))
void __GLOBAL_init_65535(void)
{
    __cxa_atexit(&_logosLocalDtor_d2bd0324, NULL, &_mh_dylib_header);
}
