struct AnonymousStruct_1 {
    double field_0; // +0x0
    double field_8; // +0x8
    double field_16; // +0x10
    double field_24; // +0x18
};

struct AnonymousStruct_9 {
    unsigned long field_0; // +0x0
    unsigned long field_8; // +0x8
};

static int (*_logos_meta_orig$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$)(int, int, id, int);
static int (*_logos_orig$APPS$UIApplication$init)(int, int);
static int (*_logos_orig$APPS$UIWindow$_setRotatableViewOrientation$duration$force$)(int, int, int, int);
static int (*_logos_orig$CARPLAY$CARIconView$initWithConfigurationOptions$listLayoutProvider$)(int, int, int, int);
static int (*_logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$numberOfPortraitColumns)(int, int);
static int (*_logos_orig$CARPLAY$_CARDashboardHomeViewController$_handleAppLibraryRefresh)(id, int);
static int (*_logos_orig$CARPLAY$_CARDashboardHomeViewController$initWithEnvironment$)(int, int, int);
static int (*_logos_orig$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$)(id, int, id, int, int);
static int (*_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView)(id, int);
static int (*_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$)(id, int, int, int, int);
static int (*_logos_orig$SPRINGBOARD$SBMainDisplaySceneManager$_sceneIdentityForApplication$createPrimaryIfRequired$sceneSessionRole$)(int, int, id, bool, id);
static int (*_logos_orig$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$)(int, int, int);
static int (*_logos_orig$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$)(struct SBSceneView *, struct objc_selector *, int, int, int);
static int (*_logos_orig$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$)(int, int, id, int);
static int (*orig_BKSDisplayServicesSetScreenBlanked)(int);
static int orientationOverride = -1;
static long _logos_meta_orig$CARPLAY$CARApplication$_newApplicationLibrary;
static long kPropertyKey_didDrawPlaceholder;
static struct AnonymousStruct_1 (*_logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$iconImageInfoForGridSizeClass$)(int, int, int);
static void (*_logos_orig$CARPLAY$CARAppDockViewController$_dockButtonPressed$)(id, int, id);
static void (*_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews)(id, int);
static void (*_logos_orig$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$)(id, int, int);

void addCarplayDeclarationsToAppLibrary(id a1)
{
    id v5;
    NSString *v15;
    id v17;
    NSURL *v22;
    NSSet<NSString *> *v24;
    NSSet<NSString *> *v26;
    CRPreferences *sharedInstance = [CRPreferences sharedInstance];
    id excludedApplications = [sharedInstance excludedApplications];
    SEL v4 = NSSelectorFromString(@"allInstalledApplications");
    if (![a1 respondsToSelector:v4]) {
        v5 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"allInstalledApplications"));
    } else {
        v5 = [a1 allInstalledApplications];
    }
    for (id v13 in v5) {
        if ([v13 valueForKey:@"_carPlayDeclaration"] != nil) {
            continue;
        }
        if ([v13 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            v15 = [v13 bundleIdentifier];
        } else {
            v15 = nil;
            LogSelectorError(v13, NSSelectorFromString(@"bundleIdentifier"));
        }
        if ([v13 respondsToSelector:NSSelectorFromString(@"bundleType")]) {
            v17 = [v13 bundleType];
        } else {
            v17 = nil;
            LogSelectorError(v13, NSSelectorFromString(@"bundleType"));
        }
        if ((![v17 isEqualToString:@"User"] && [v15 containsString:@"com.apple."]) || (excludedApplications && [excludedApplications containsObject:v15])) {
            continue;
        }
        CRCarPlayAppDeclaration *v21 = [[objc_getClass("CRCarPlayAppDeclaration") alloc] init];
        [v21 setSupportsTemplates:0];
        [v21 setSupportsMaps:1];
        [v21 setBundleIdentifier:v15];
        if ([v13 respondsToSelector:NSSelectorFromString(@"bundleURL")]) {
            v22 = [v13 bundleURL];
        } else {
            v22 = nil;
            LogSelectorError(v13, NSSelectorFromString(@"bundleURL"));
        }
        [v21 setBundlePath:v22];
        [v13 setValue:v21 forKey:@"_carPlayDeclaration"];
        NSArray *v23 = @[@"CarPlayEnable"];
        if ([v13 respondsToSelector:NSSelectorFromString(@"tags")]) {
            v24 = [v13 tags];
        } else {
            v24 = nil;
            LogSelectorError(v13, NSSelectorFromString(@"tags"));
        }
        if (v24 != nil) {
            if ([v13 respondsToSelector:NSSelectorFromString(@"tags")]) {
                v26 = [v13 tags];
            } else {
                v26 = nil;
                LogSelectorError(v13, NSSelectorFromString(@"tags"));
            }
            v23 = [v23 arrayByAddingObjectsFromArray:v26];
        }
        [v13 setValue:v23 forKey:@"_tags"];
    }
}


void LogSelectorError(id a1, SEL a2)
{
    NSLog(@"carplayenable error: %@ does not respond to selector %@", a1, NSStringFromSelector(a2));
}


__attribute__((constructor))
void _logosLocalCtor_b2eb7349(void)
{
    uint8_t v12[5];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = [currentDevice systemVersion];
    if ([systemVersion compare:@"14.0" options:NSNumericSearch] == NSOrderedAscending) {
        return;
    }
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [mainBundle bundleIdentifier];
    if ([bundleIdentifier isEqualToString:@"com.apple.CarPlayApp"]) {
        Class v5 = object_getClass(objc_getClass("CARApplication"));
        MSHookMessageEx(v5, @selector(_newApplicationLibrary), &_logos_meta_method$CARPLAY$CARApplication$_newApplicationLibrary, &_logos_meta_orig$CARPLAY$CARApplication$_newApplicationLibrary);
        Class v6 = objc_getClass("SBIconListGridLayoutConfiguration");
        MSHookMessageEx(v6, @selector(numberOfPortraitColumns), &_logos_method$CARPLAY$SBIconListGridLayoutConfiguration$numberOfPortraitColumns, &_logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$numberOfPortraitColumns);
        MSHookMessageEx(v6, @selector(iconImageInfoForGridSizeClass:), &_logos_method$CARPLAY$SBIconListGridLayoutConfiguration$iconImageInfoForGridSizeClass$, &_logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$iconImageInfoForGridSizeClass$);
        Class v7 = object_getClass(objc_getClass("CARApplicationLaunchInfo"));
        MSHookMessageEx(v7, @selector(launchInfoForApplication:withActivationSettings:), &_logos_meta_method$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$, &_logos_meta_orig$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$);
        Class v8 = objc_getClass("CARAppDockViewController");
        MSHookMessageEx(v8, @selector(_dockButtonPressed:), &_logos_method$CARPLAY$CARAppDockViewController$_dockButtonPressed$, &_logos_orig$CARPLAY$CARAppDockViewController$_dockButtonPressed$);
        Class v9 = objc_getClass("_CARDashboardHomeViewController");
        MSHookMessageEx(v9, @selector(initWithEnvironment:), &_logos_method$CARPLAY$_CARDashboardHomeViewController$initWithEnvironment$, &_logos_orig$CARPLAY$_CARDashboardHomeViewController$initWithEnvironment$);
        MSHookMessageEx(v9, @selector(_handleAppLibraryRefresh), &_logos_method$CARPLAY$_CARDashboardHomeViewController$_handleAppLibraryRefresh, &_logos_orig$CARPLAY$_CARDashboardHomeViewController$_handleAppLibraryRefresh);
        Class cls = objc_getClass("CARIconView");
        _strcpy(v12, "v@:@");
        class_addMethod(cls, @selector(handleLaunchAppInNormalMode:), &_logos_method$CARPLAY$CARIconView$handleLaunchAppInNormalMode$, (const char *)v12);
        MSHookMessageEx(cls, @selector(initWithConfigurationOptions:listLayoutProvider:), &_logos_method$CARPLAY$CARIconView$initWithConfigurationOptions$listLayoutProvider$, &_logos_orig$CARPLAY$CARIconView$initWithConfigurationOptions$listLayoutProvider$);
    }
}


FBSApplicationLibrary *_logos_meta_method$CARPLAY$CARApplication$_newApplicationLibrary(long a1, long a2)
{
    id v14;
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_meta_method$CARPLAY$CARApplication$_newApplicationLibrary"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    FBSApplicationLibraryConfiguration *v1 = [[objc_getClass("FBSApplicationLibraryConfiguration") alloc] init];
    [v1 setApplicationInfoClass:objc_getClass("CARApplicationInfo")];
    [v1 setApplicationPlaceholderClass:objc_getClass("FBSApplicationPlaceholder")];
    [v1 setAllowConcurrentLoading:1];
    [v1 setInstalledApplicationFilter:^bool(id arg1, NSSet *arg2) {
        id v16;
        SEL v15 = NSSelectorFromString(@"appTags");
        if (![arg1 respondsToSelector:v15]) {
            v16 = nil;
            LogSelectorError(arg1, NSSelectorFromString(@"appTags"));
        } else {
            v16 = [arg1 appTags];
        }
        return ![v16 containsObject:@"hidden"];
    }];
    FBSApplicationLibrary *v2 = [[objc_getClass("FBSApplicationLibrary") alloc] initWithConfiguration:v1];
    addCarplayDeclarationsToAppLibrary(v2);
    for (NSString *v7 in @[@"com.apple.CarPlayTemplateUIHost", @"com.apple.MusicUIService", @"com.apple.springboard", @"com.apple.InCallService", @"com.apple.CarPlaySettings", @"com.apple.CarPlayApp"]) {
        id v13 = [objc_getClass("LSApplicationProxy") applicationProxyForIdentifier:v7];
        if ([v13 respondsToSelector:NSSelectorFromString(@"appState")]) {
            v14 = [v13 appState];
        } else {
            v14 = nil;
            LogSelectorError(v13, NSSelectorFromString(@"appState"));
        }
        if ([v14 respondsToSelector:NSSelectorFromString(@"isValid")]) {
            [v14 isValid];
        } else {
            LogSelectorError(v14, NSSelectorFromString(@"isValid"));
        }
    }
    return v2;
}


int _logos_method$CARPLAY$SBIconListGridLayoutConfiguration$numberOfPortraitColumns(long a1, long a2)
{
    int v0 = _logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$numberOfPortraitColumns(a1, a2);
    CRPreferences *sharedInstance = [CRPreferences sharedInstance];
    bool fiveColumnIconLayout = [sharedInstance fiveColumnIconLayout];
    if (!fiveColumnIconLayout || v0 > 5) {
        return v0;
    }
    return 5;
}


struct AnonymousStruct_1 _logos_method$CARPLAY$SBIconListGridLayoutConfiguration$iconImageInfoForGridSizeClass$(long a1, long a2, long a3)
{
    struct AnonymousStruct_1 v0 = _logos_orig$CARPLAY$SBIconListGridLayoutConfiguration$iconImageInfoForGridSizeClass$(a1, a2, a3);
    double v1 = v0.field_0;
    double v2 = v0.field_8;
    CRPreferences *sharedInstance = [CRPreferences sharedInstance];
    if ([sharedInstance fiveColumnIconLayout]) {
        CGSize v4 = CGSizeMake(50.0, 50.0);
        v1 = v4.width;
        v2 = v4.height;
    }
    return (struct AnonymousStruct_1){v1, v2, v0.field_16, v0.field_24};
}


int _logos_meta_method$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$(long a1, long a2, id a3, long a4)
{
    NSSet<NSString *> *v1;
    NSString *v6;
    id v10;
    id v12;
    NSString *v17;
    id v18;
    id v19;
    UIViewController *v20;
    id v21;
    id v22;
    id v23;
    id v25;
    SEL v0 = NSSelectorFromString(@"tags");
    if (![a3 respondsToSelector:v0]) {
        v1 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"tags"));
    } else {
        v1 = [a3 tags];
    }
    if (![v1 containsObject:@"CarPlayEnable"]) {
        return _logos_meta_orig$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$(a1, a2, a3, a4);
    }
    NSString *v3 = [NSString stringWithFormat:@"%s", "_logos_meta_method$CARPLAY$CARApplicationLaunchInfo$launchInfoForApplication$withActivationSettings$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v3);
    NSDistributedNotificationCenter *defaultCenter = [objc_getClass("NSDistributedNotificationCenter") defaultCenter];
    if (![a3 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        v6 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        v6 = [a3 bundleIdentifier];
    }
    [defaultCenter postNotificationName:@"com.carplayenable" object:nil userInfo:@{@"identifier": v6}];
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentAppHistory")]) {
        v10 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentAppHistory"));
    } else {
        v10 = [sharedApplication _currentAppHistory];
    }
    NSString *v11 = nil;
    if (![v10 respondsToSelector:NSSelectorFromString(@"orderedAppHistory")]) {
        v12 = nil;
        LogSelectorError(v10, NSSelectorFromString(@"orderedAppHistory"));
    } else {
        v12 = [v10 orderedAppHistory];
    }
    if ([v12 count] > 0) {
        id firstObject = [v12 firstObject];
        if (![firstObject respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            id firstObject2 = [v12 firstObject];
            LogSelectorError(firstObject2, NSSelectorFromString(@"bundleIdentifier"));
        } else {
            id firstObject3 = [v12 firstObject];
            v11 = [firstObject3 bundleIdentifier];
        }
    }
    if (![a3 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        v17 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        v17 = [a3 bundleIdentifier];
    }
    [v10 _bundleIdentifierDidBecomeVisible:v17 previousBundleIdentifier:v11];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
        v18 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
    } else {
        v18 = [sharedApplication _currentDashboard];
    }
    if (![v18 respondsToSelector:NSSelectorFromString(@"rootViewController")]) {
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
            v19 = nil;
            LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
        } else {
            v19 = [sharedApplication _currentDashboard];
        }
        v20 = nil;
        LogSelectorError(v19, NSSelectorFromString(@"rootViewController"));
    } else {
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
            v21 = nil;
            LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
        } else {
            v21 = [sharedApplication _currentDashboard];
        }
        v20 = [v21 rootViewController];
    }
    if (![v20 respondsToSelector:NSSelectorFromString(@"appDockViewController")]) {
        v22 = nil;
        LogSelectorError(v20, NSSelectorFromString(@"appDockViewController"));
    } else {
        v22 = [v20 appDockViewController];
    }
    if (![v22 respondsToSelector:NSSelectorFromString(@"_refreshAppDock")]) {
        LogSelectorError(v22, NSSelectorFromString(@"_refreshAppDock"));
    } else {
        [v22 _refreshAppDock];
    }
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
        v23 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
    } else {
        v23 = [sharedApplication _currentDashboard];
    }
    if (!v23 || ![v23 isKindOfClass:NSClassFromString(@"CARDashboard")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CARDashboard", v23];
    }
    if (![v23 respondsToSelector:NSSelectorFromString(@"identifierToForegroundAppScenesMap")]) {
        v25 = nil;
        LogSelectorError(v23, NSSelectorFromString(@"identifierToForegroundAppScenesMap"));
    } else {
        v25 = [v23 identifierToForegroundAppScenesMap];
    }
    NSArray *allKeys = [v25 allKeys];
    if ([allKeys count] > 0) {
        id v28 = [objc_getClass("CAREvent") eventWithType:1 context:@"Close carplay app"];
        if (!v28 || ![v28 isKindOfClass:NSClassFromString(@"CAREvent")]) {
            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CAREvent", v28];
        }
        [v23 handleEvent:v28];
    }
    return 0;
}


BOOL _logos_method$CARPLAY$CARAppDockViewController$_dockButtonPressed$(id a1, long a2, id a3)
{
    NSString *v1;
    id v3;
    NSSet<NSString *> *v5;
    _logos_orig$CARPLAY$CARAppDockViewController$_dockButtonPressed$(a1, a2, a3);
    SEL v0 = NSSelectorFromString(@"bundleIdentifier");
    if (![a3 respondsToSelector:v0]) {
        v1 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        v1 = [a3 bundleIdentifier];
    }
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"sharedApplicationLibrary")]) {
        v3 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"sharedApplicationLibrary"));
    } else {
        v3 = [sharedApplication sharedApplicationLibrary];
    }
    id v4 = [v3 applicationInfoForBundleIdentifier:v1];
    if (![v4 respondsToSelector:NSSelectorFromString(@"tags")]) {
        v5 = nil;
        LogSelectorError(v4, NSSelectorFromString(@"tags"));
    } else {
        v5 = [v4 tags];
    }
    BOOL v6 = [v5 containsObject:@"CarPlayEnable"];
    if (!v6) {
        return v6;
    }
    return [a1 setDockEnabled:1];
}


int _logos_method$CARPLAY$_CARDashboardHomeViewController$initWithEnvironment$(id a1, long a2, long a3)
{
    int v0 = _logos_orig$CARPLAY$_CARDashboardHomeViewController$initWithEnvironment$(a1, a2, a3);
    Class v1 = objc_getClass("NSDistributedNotificationCenter");
    NSDistributedNotificationCenter *defaultCenter = [v1 defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [defaultCenter addObserverForName:@"com.carplay.preferences.changed" object:nil queue:mainQueue usingBlock:^void(NSNotification *arg1) {
        id v8;
        CRPreferences *sharedInstance = [CRPreferences sharedInstance];
        [sharedInstance reloadPreferences];
        id object = [arg1 object];
        if (![object isEqualToString:@"appLibrary"]) {
            id object2 = [arg1 object];
            if ([object2 isEqualToString:@"iconLayout"]) {
                if (![a1 respondsToSelector:NSSelectorFromString(@"resetIconState")]) {
                    LogSelectorError(a1, NSSelectorFromString(@"resetIconState"));
                } else {
                    [a1 resetIconState];
                }
            }
        } else {
            if (![objc_getClass("CARApplication") respondsToSelector:NSSelectorFromString(@"_newApplicationLibrary")]) {
                v8 = nil;
                LogSelectorError(objc_getClass("CARApplication"), NSSelectorFromString(@"_newApplicationLibrary"));
            } else {
                v8 = [objc_getClass("CARApplication") _newApplicationLibrary];
            }
            [a1 setLibrary:v8];
            if (![a1 respondsToSelector:NSSelectorFromString(@"_handleAppLibraryRefresh")]) {
                LogSelectorError(a1, NSSelectorFromString(@"_handleAppLibraryRefresh"));
            } else {
                [a1 _handleAppLibraryRefresh];
            }
        }
    }];
    return v0;
}


int _logos_method$CARPLAY$_CARDashboardHomeViewController$_handleAppLibraryRefresh(id a1, long a2)
{
    id v1;
    SEL v0 = NSSelectorFromString(@"library");
    if (![a1 respondsToSelector:v0]) {
        v1 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"library"));
    } else {
        v1 = [a1 library];
    }
    addCarplayDeclarationsToAppLibrary(v1);
    return _logos_orig$CARPLAY$_CARDashboardHomeViewController$_handleAppLibraryRefresh(a1, a2);
}


void _logos_method$CARPLAY$CARIconView$handleLaunchAppInNormalMode$(id a1, SEL a2, id a3)
{
    id v1;
    id v3;
    id v9;
    id v11;
    id v16;
    id v17;
    UIViewController *v18;
    id v19;
    id v20;
    if ([a3 state] != 1) {
        return;
    }
    if (![a1 respondsToSelector:NSSelectorFromString(@"icon")]) {
        v1 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"icon"));
    } else {
        v1 = [a1 icon];
    }
    if (!v1 || ![v1 isKindOfClass:NSClassFromString(@"SBIcon")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBIcon", v1];
    }
    if (![v1 respondsToSelector:NSSelectorFromString(@"applicationBundleID")]) {
        v3 = nil;
        LogSelectorError(v1, NSSelectorFromString(@"applicationBundleID"));
    } else {
        v3 = [v1 applicationBundleID];
    }
    NSDistributedNotificationCenter *defaultCenter = [objc_getClass("NSDistributedNotificationCenter") defaultCenter];
    [defaultCenter postNotificationName:@"com.carplayenable" object:nil userInfo:@{@"identifier": v3}];
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentAppHistory")]) {
        v9 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentAppHistory"));
    } else {
        v9 = [sharedApplication _currentAppHistory];
    }
    NSString *v10 = nil;
    if (![v9 respondsToSelector:NSSelectorFromString(@"orderedAppHistory")]) {
        v11 = nil;
        LogSelectorError(v9, NSSelectorFromString(@"orderedAppHistory"));
    } else {
        v11 = [v9 orderedAppHistory];
    }
    if ([v11 count] > 0) {
        id firstObject = [v11 firstObject];
        if (![firstObject respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            id firstObject2 = [v11 firstObject];
            LogSelectorError(firstObject2, NSSelectorFromString(@"bundleIdentifier"));
        } else {
            id firstObject3 = [v11 firstObject];
            v10 = [firstObject3 bundleIdentifier];
        }
    }
    [v9 _bundleIdentifierDidBecomeVisible:v3 previousBundleIdentifier:v10];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
        v16 = nil;
        LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
    } else {
        v16 = [sharedApplication _currentDashboard];
    }
    if (![v16 respondsToSelector:NSSelectorFromString(@"rootViewController")]) {
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
            v17 = nil;
            LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
        } else {
            v17 = [sharedApplication _currentDashboard];
        }
        v18 = nil;
        LogSelectorError(v17, NSSelectorFromString(@"rootViewController"));
    } else {
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_currentDashboard")]) {
            v19 = nil;
            LogSelectorError(sharedApplication, NSSelectorFromString(@"_currentDashboard"));
        } else {
            v19 = [sharedApplication _currentDashboard];
        }
        v18 = [v19 rootViewController];
    }
    if (![v18 respondsToSelector:NSSelectorFromString(@"appDockViewController")]) {
        v20 = nil;
        LogSelectorError(v18, NSSelectorFromString(@"appDockViewController"));
    } else {
        v20 = [v18 appDockViewController];
    }
    if (![v20 respondsToSelector:NSSelectorFromString(@"_refreshAppDock")]) {
        LogSelectorError(v20, NSSelectorFromString(@"_refreshAppDock"));
    } else {
        [v20 _refreshAppDock];
    }
}


id _logos_method$CARPLAY$CARIconView$initWithConfigurationOptions$listLayoutProvider$(long a1, long a2, long a3, long a4)
{
    id v0 = _logos_orig$CARPLAY$CARIconView$initWithConfigurationOptions$listLayoutProvider$(a1, a2, a3, a4);
    UILongPressGestureRecognizer *v1 = [[UILongPressGestureRecognizer alloc] initWithTarget:v0 action:NSSelectorFromString(@"handleLaunchAppInNormalMode:")];
    [v1 setMinimumPressDuration:1.5];
    [v0 addGestureRecognizer:v1];
    return v0;
}


double CGSizeMake(double a1)
{
    return a1;
}


int hook_BKSDisplayServicesSetScreenBlanked(int a1)
{
    id v1;
    id v11;
    id v14;
    id v16;
    id v17;
    id v18;
    id v19;
    id v20;
    id v21;
    id v22;
    id v23;
    NSString *v24;
    id v25;
    id v26;
    id v27;
    id v28;
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"liveCarplayWindow")]) {
        v1 = nil;
        UIApplication *sharedApplication2 = [UIApplication sharedApplication];
        LogSelectorError(sharedApplication2, NSSelectorFromString(@"liveCarplayWindow"));
    } else {
        UIApplication *sharedApplication3 = [UIApplication sharedApplication];
        v1 = [sharedApplication3 liveCarplayWindow];
    }
    if (a1 != 1 || !v1) {
        return orig_BKSDisplayServicesSetScreenBlanked(a1);
    }
    NSString *v7 = [NSString stringWithFormat:@"%s", "hook_BKSDisplayServicesSetScreenBlanked"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v7);
    UIApplication *sharedApplication4 = [UIApplication sharedApplication];
    id v9 = objc_getAssociatedObject(sharedApplication4, NSSelectorFromString(@"lockAssertions"));
    id appViewController = [v1 appViewController];
    if (![appViewController respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v11 = nil;
        id appViewController2 = [v1 appViewController];
        LogSelectorError(appViewController2, NSSelectorFromString(@"sceneHandle"));
    } else {
        id appViewController3 = [v1 appViewController];
        v11 = [appViewController3 sceneHandle];
    }
    if (![v11 respondsToSelector:NSSelectorFromString(@"sceneIfExists")]) {
        v14 = nil;
        LogSelectorError(v11, NSSelectorFromString(@"sceneIfExists"));
    } else {
        v14 = [v11 sceneIfExists];
    }
    if (v14) {
        if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
            v16 = nil;
            LogSelectorError(v14, NSSelectorFromString(@"client"));
        } else {
            v16 = [v14 client];
        }
        if (![v16 respondsToSelector:NSSelectorFromString(@"process")]) {
            if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                v17 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"client"));
            } else {
                v17 = [v14 client];
            }
            v18 = nil;
            LogSelectorError(v17, NSSelectorFromString(@"process"));
        } else {
            if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                v19 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"client"));
            } else {
                v19 = [v14 client];
            }
            v18 = [v19 process];
        }
        if (![v18 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                v20 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"client"));
            } else {
                v20 = [v14 client];
            }
            if (![v20 respondsToSelector:NSSelectorFromString(@"process")]) {
                if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v21 = nil;
                    LogSelectorError(v14, NSSelectorFromString(@"client"));
                } else {
                    v21 = [v14 client];
                }
                v22 = nil;
                LogSelectorError(v21, NSSelectorFromString(@"process"));
            } else {
                if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v23 = nil;
                    LogSelectorError(v14, NSSelectorFromString(@"client"));
                } else {
                    v23 = [v14 client];
                }
                v22 = [v23 process];
            }
            v24 = nil;
            LogSelectorError(v22, NSSelectorFromString(@"bundleIdentifier"));
        } else {
            if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                v25 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"client"));
            } else {
                v25 = [v14 client];
            }
            if (![v25 respondsToSelector:NSSelectorFromString(@"process")]) {
                if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v26 = nil;
                    LogSelectorError(v14, NSSelectorFromString(@"client"));
                } else {
                    v26 = [v14 client];
                }
                v27 = nil;
                LogSelectorError(v26, NSSelectorFromString(@"process"));
            } else {
                if (![v14 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v28 = nil;
                    LogSelectorError(v14, NSSelectorFromString(@"client"));
                } else {
                    v28 = [v14 client];
                }
                v27 = [v28 process];
            }
            v24 = [v27 bundleIdentifier];
        }
        if ([v9 containsObject:v24]) {
            orig_BKSDisplayServicesSetScreenBlanked(1);
            dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
            dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
                orig_BKSDisplayServicesSetScreenBlanked(0);
            });
            return 0;
        }
    }
    return orig_BKSDisplayServicesSetScreenBlanked(a1);
}


void LogSelectorError(id a1, SEL a2)
{
    NSLog(@"carplayenable error: %@ does not respond to selector %@", a1, NSStringFromSelector(a2));
}


__attribute__((constructor))
void _logosLocalCtor_63538fe6(void)
{
    uint8_t v8[5];
    uint8_t v13[5];
    uint8_t v18[4];
    uint8_t v20[4];
    uint8_t v24[4];
    uint8_t v29[4];
    uint8_t v34[4];
    uint8_t v37[4];
    uint8_t v39[4];
    uint8_t v43[36];
    long hook_BKSDisplayServicesSetScreenBlanked;
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = [currentDevice systemVersion];
    if ([systemVersion compare:@"14.0" options:NSNumericSearch] == NSOrderedAscending) {
        return;
    }
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [mainBundle bundleIdentifier];
    if ([bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        Class v5 = objc_getClass("SBSuspendedUnderLockManager");
        MSHookMessageEx(v5, @selector(_shouldBeBackgroundUnderLockForScene:withSettings:), &_logos_method$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$, &_logos_orig$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$);
        Class cls4 = objc_getClass("SpringBoard");
        _strcpy(v8, "v@:@");
        class_addMethod(cls4, @selector(handleCarPlayLaunchNotification:), &_logos_method$SPRINGBOARD$SpringBoard$handleCarPlayLaunchNotification$, (const char *)v8);
        _strcpy(v13, "v@:@");
        class_addMethod(cls4, @selector(launchAppOnCarplay:), &_logos_method$SPRINGBOARD$SpringBoard$launchAppOnCarplay$, (const char *)v13);
        MSHookMessageEx(cls4, @selector(applicationDidFinishLaunching:), &_logos_method$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$, &_logos_orig$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$);
        _strcpy(v18, "@@:");
        class_addMethod(cls4, @selector(liveCarplayWindow), &_logos_method$SPRINGBOARD$SpringBoard$liveCarplayWindow, (const char *)v18);
        _strcpy(v20, "v@:");
        class_addMethod(cls4, @selector(carplayIsConnectedChanged), &_logos_method$SPRINGBOARD$SpringBoard$carplayIsConnectedChanged, (const char *)v20);
        Class v21 = objc_getClass("SBSceneView");
        MSHookMessageEx(v21, @selector(_updateReferenceSize:andOrientation:), &_logos_method$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$, &_logos_orig$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$);
        Class cls = objc_getClass("FBScene");
        MSHookMessageEx(cls, @selector(updateSettings:withTransitionContext:completion:), &_logos_method$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$, &_logos_orig$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$);
        _strcpy(v24, "@@:");
        class_addMethod(cls, @selector(client), &_logos_method$SPRINGBOARD$FBScene$client, (const char *)v24);
        Class v25 = objc_getClass("SBMainSwitcherViewController");
        MSHookMessageEx(v25, @selector(_updateContentViewInterfaceOrientation:), &_logos_method$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$, &_logos_orig$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$);
        Class cls2 = objc_getClass("SBDeviceApplicationSceneView");
        _strcpy(v29, "B@:");
        class_addMethod(cls2, @selector(isMainScreenCounterpartToLiveCarplayApp), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isMainScreenCounterpartToLiveCarplayApp, (const char *)v29);
        _strcpy(v34, "B@:");
        class_addMethod(cls2, @selector(isHostingContentOnCarplayScreen), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isHostingContentOnCarplayScreen, (const char *)v34);
        MSHookMessageEx(cls2, @selector(layoutSubviews), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews, &_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews);
        MSHookMessageEx(cls2, @selector(homeGrabberView), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView, &_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView);
        _strcpy(v37, "v@:");
        class_addMethod(cls2, @selector(rotateToDeviceOrientation), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$rotateToDeviceOrientation, (const char *)v37);
        _strcpy(v39, "v@:");
        class_addMethod(cls2, @selector(drawCarplayPlaceholder), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$drawCarplayPlaceholder, (const char *)v39);
        MSHookMessageEx(cls2, @selector(setDisplayMode:animationFactory:completion:), &_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$, &_logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$);
        Class cls3 = objc_getClass("UIScreen");
        _strcpy(v43, "{CGRect={CGPoint=dd}{CGSize=dd}}@:i");
        class_addMethod(cls3, @selector(boundsForOrientation:), &_logos_method$SPRINGBOARD$UIScreen$boundsForOrientation$, (const char *)v43);
        Class v46 = objc_getClass("SBMainDisplaySceneManager");
        MSHookMessageEx(v46, @selector(_sceneIdentityForApplication:createPrimaryIfRequired:sceneSessionRole:), &_logos_method$SPRINGBOARD$SBMainDisplaySceneManager$_sceneIdentityForApplication$createPrimaryIfRequired$sceneSessionRole$, &_logos_orig$SPRINGBOARD$SBMainDisplaySceneManager$_sceneIdentityForApplication$createPrimaryIfRequired$sceneSessionRole$);
        MSHookFunction(dlsym(dlopen(NULL, 0), "BKSDisplayServicesSetScreenBlanked"), &hook_BKSDisplayServicesSetScreenBlanked, &orig_BKSDisplayServicesSetScreenBlanked);
    }
}


bool _logos_method$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$(long a1, long a2, id a3, long a4)
{
    id v2;
    id v3;
    id v4;
    id v5;
    id v6;
    id v7;
    id v8;
    id v9;
    NSString *v10;
    id v11;
    id v12;
    id v13;
    id v14;
    bool v1 = _logos_orig$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$(a1, a2, a3, a4) != 0;
    if (!v1) {
        return v1;
    }
    if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
        v2 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"client"));
    } else {
        v2 = [a3 client];
    }
    if (![v2 respondsToSelector:NSSelectorFromString(@"process")]) {
        if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
            v3 = nil;
            LogSelectorError(a3, NSSelectorFromString(@"client"));
        } else {
            v3 = [a3 client];
        }
        v4 = nil;
        LogSelectorError(v3, NSSelectorFromString(@"process"));
    } else {
        if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
            v5 = nil;
            LogSelectorError(a3, NSSelectorFromString(@"client"));
        } else {
            v5 = [a3 client];
        }
        v4 = [v5 process];
    }
    if (![v4 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
            v6 = nil;
            LogSelectorError(a3, NSSelectorFromString(@"client"));
        } else {
            v6 = [a3 client];
        }
        if (![v6 respondsToSelector:NSSelectorFromString(@"process")]) {
            if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
                v7 = nil;
                LogSelectorError(a3, NSSelectorFromString(@"client"));
            } else {
                v7 = [a3 client];
            }
            v8 = nil;
            LogSelectorError(v7, NSSelectorFromString(@"process"));
        } else {
            if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
                v9 = nil;
                LogSelectorError(a3, NSSelectorFromString(@"client"));
            } else {
                v9 = [a3 client];
            }
            v8 = [v9 process];
        }
        v10 = nil;
        LogSelectorError(v8, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
            v11 = nil;
            LogSelectorError(a3, NSSelectorFromString(@"client"));
        } else {
            v11 = [a3 client];
        }
        if (![v11 respondsToSelector:NSSelectorFromString(@"process")]) {
            if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
                v12 = nil;
                LogSelectorError(a3, NSSelectorFromString(@"client"));
            } else {
                v12 = [a3 client];
            }
            v13 = nil;
            LogSelectorError(v12, NSSelectorFromString(@"process"));
        } else {
            if (![a3 respondsToSelector:NSSelectorFromString(@"client")]) {
                v14 = nil;
                LogSelectorError(a3, NSSelectorFromString(@"client"));
            } else {
                v14 = [a3 client];
            }
            v13 = [v14 process];
        }
        v10 = [v13 bundleIdentifier];
    }
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if ([objc_getAssociatedObject(sharedApplication, NSSelectorFromString(@"lockAssertions")) containsObject:v10]) {
        NSString *v16 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBSuspendedUnderLockManager$_shouldBeBackgroundUnderLockForScene$withSettings$"];
        NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v16);
        v1 = false;
    }
    return v1;
}


void _logos_method$SPRINGBOARD$SpringBoard$handleCarPlayLaunchNotification$(id a1, SEL a2, id a3)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SpringBoard$handleCarPlayLaunchNotification$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    id userInfo = [a3 userInfo];
    id v2 = [userInfo objectForKeyedSubscript:@"identifier"];
    [a1 launchAppOnCarplay:v2];
}


void _logos_method$SPRINGBOARD$SpringBoard$launchAppOnCarplay$(id a1, SEL a2, id a3)
{
    id v3;
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SpringBoard$launchAppOnCarplay$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    @try {
        UIApplication *sharedApplication = [UIApplication sharedApplication];
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"liveCarplayWindow")]) {
            UIApplication *sharedApplication2 = [UIApplication sharedApplication];
            LogSelectorError(sharedApplication2, NSSelectorFromString(@"liveCarplayWindow"));
            v3 = nil;
        } else {
            UIApplication *sharedApplication3 = [UIApplication sharedApplication];
            v3 = [sharedApplication3 liveCarplayWindow];
        }
        if (v3 != nil) {
            if (![v3 respondsToSelector:NSSelectorFromString(@"dismiss")]) {
                LogSelectorError(v3, NSSelectorFromString(@"dismiss"));
            } else {
                [v3 dismiss];
            }
        }
        CRCarPlayWindow *value = [[CRCarPlayWindow alloc] initWithBundleIdentifier:a3];
        objc_setAssociatedObject(a1, NSSelectorFromString(@"liveCarplayWindow"), value, OBJC_ASSOCIATION_RETAIN);
    } @catch (id v13) {
        NSLog(@"carplay window launch failed! %@", v13);
    }
}


long _logos_method$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$(id a1, long a2, long a3)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    Class v1 = objc_getClass("NSDistributedNotificationCenter");
    NSDistributedNotificationCenter *defaultCenter = [v1 defaultCenter];
    [defaultCenter addObserver:a1 selector:NSSelectorFromString(@"handleCarPlayLaunchNotification:") name:@"com.carplayenable" object:nil];
    NSNotificationCenter *defaultCenter2 = [NSNotificationCenter defaultCenter];
    [defaultCenter2 addObserver:a1 selector:@selector(carplayIsConnectedChanged) name:@"CarPlayIsConnectedDidChange" object:nil];
    objc_setAssociatedObject(a1, NSSelectorFromString(@"lockAssertions"), [[NSMutableArray alloc] init], OBJC_ASSOCIATION_RETAIN);
    _logos_orig$SPRINGBOARD$SpringBoard$applicationDidFinishLaunching$(a1, a2, a3);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    Class v5 = objc_getClass("NSDistributedNotificationCenter");
    NSDistributedNotificationCenter *defaultCenter3 = [v5 defaultCenter];
    return symbolicateAndUploadCrashlogs([defaultCenter3 addObserverForName:@"com.carplay.prefs.app_data" object:@"Requesting" queue:queue usingBlock:^void(NSNotification *arg1) {
        id v36;
        id v39;
        NSString *v15;
        id v17;
        NSString *v27;
        if (![objc_getClass("SBApplicationController") respondsToSelector:NSSelectorFromString(@"sharedInstance")]) {
            v36 = nil;
            LogSelectorError(objc_getClass("SBApplicationController"), NSSelectorFromString(@"sharedInstance"));
        } else {
            v36 = [objc_getClass("SBApplicationController") sharedInstance];
        }
        NSMutableArray *v37 = [[NSMutableArray alloc] init];
        SEL v38 = NSSelectorFromString(@"allInstalledApplications");
        if (![v36 respondsToSelector:v38]) {
            v39 = nil;
            LogSelectorError(v36, NSSelectorFromString(@"allInstalledApplications"));
        } else {
            v39 = [v36 allInstalledApplications];
        }
        for (id v14 in v39) {
            if ([v14 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
                v15 = [v14 bundleIdentifier];
            } else {
                v15 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"bundleIdentifier"));
            }
            if ([v14 respondsToSelector:NSSelectorFromString(@"bundleType")]) {
                v17 = [v14 bundleType];
            } else {
                v17 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"bundleType"));
            }
            BOOL v18 = [v17 isEqualToString:@"User"];
            if ((!v18 && [v15 containsString:@"com.apple."]) || [v14 valueForKey:@"_carPlayDeclaration"]) {
                continue;
            }
            Class v21 = objc_getClass("UIImage");
            SEL v22 = NSSelectorFromString(@"_applicationIconImageForBundleIdentifier:format:scale:");
            UIScreen *mainScreen = [UIScreen mainScreen];
            CGFloat scale = [mainScreen scale];
            NSData *v25 = UIImagePNGRepresentation(objc_msgSend(v21, v22, v15, 0, scale));
            if ([v14 respondsToSelector:NSSelectorFromString(@"displayName")]) {
                v27 = [v14 displayName];
            } else {
                v27 = nil;
                LogSelectorError(v14, NSSelectorFromString(@"displayName"));
            }
            [v37 addObject:@{@"name": v27, @"bundleID": v15, @"iconImage": v25}];
        }
        Class v33 = objc_getClass("NSDistributedNotificationCenter");
        NSDistributedNotificationCenter *defaultCenter = [v33 defaultCenter];
        NSNotification *notification = [NSNotification notificationWithName:@"com.carplay.prefs.app_data" object:@"Receiving" userInfo:@{@"appList": v37}];
        [defaultCenter postNotification:notification];
    }]);
}


id _logos_method$SPRINGBOARD$SpringBoard$liveCarplayWindow(id a1, SEL a2)
{
    return objc_getAssociatedObject(a1, NSSelectorFromString(@"liveCarplayWindow"));
}


void _logos_method$SPRINGBOARD$SpringBoard$carplayIsConnectedChanged(id a1, SEL a2)
{
    id v2;
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SpringBoard$carplayIsConnectedChanged"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    SEL v1 = NSSelectorFromString(@"liveCarplayWindow");
    if (![a1 respondsToSelector:v1]) {
        v2 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"liveCarplayWindow"));
    } else {
        v2 = [a1 liveCarplayWindow];
    }
    if (v2 != nil && !getCarplayCADisplay()) {
        dispatch_sync(dispatch_get_main_queue(), ^void(void) {
            SEL v6 = NSSelectorFromString(@"dismiss");
            if (![v2 respondsToSelector:v6]) {
                LogSelectorError(v2, NSSelectorFromString(@"dismiss"));
            } else {
                [v2 dismiss];
            }
        });
    }
}


int _logos_method$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$(struct SBSceneView *a1, struct objc_selector *a2, CGSize a3, long long a4)
{
    if (a4 <= 4) {
        return _logos_orig$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$(a1, a2, (struct CGSize){a3.width, a3.height}, a4);
    } else {
        return _logos_orig$SPRINGBOARD$SBSceneView$_updateReferenceSize$andOrientation$(a1, a2, (struct CGSize){a3.width, a3.height}, 3);
    }
}


long _logos_method$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$(id a1, long a2, id a3, long a4, long a5)
{
    NSString *v3;
    id v15;
    long v17;
    id v18;
    id v19;
    NSString *v20;
    id v21;
    int v23;
    NSString *v1 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v1);
    SEL v2 = NSSelectorFromString(@"debugDescription");
    if (![a3 respondsToSelector:v2]) {
        v3 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"debugDescription"));
    } else {
        v3 = [a3 debugDescription];
    }
    NSArray<NSString *> *v5 = [v3 componentsSeparatedByString:@"\n"];
    for (NSString *v25 in v5) {
        NSLog(@"carplayenable FBScene updateSettings: %@", v25);
    }
    SEL v14 = NSSelectorFromString(@"client");
    if (![a1 respondsToSelector:v14]) {
        v15 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"client"));
    } else {
        v15 = [a1 client];
    }
    SEL v16 = NSSelectorFromString(@"process");
    if (![v15 respondsToSelector:v16]) {
        v17 = _logos_orig$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$(a1, a2, a3, a4, a5);
    } else {
        if (![v15 respondsToSelector:NSSelectorFromString(@"process")]) {
            v18 = nil;
            LogSelectorError(v15, NSSelectorFromString(@"process"));
        } else {
            v18 = [v15 process];
        }
        if (![v18 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
            if (![v15 respondsToSelector:NSSelectorFromString(@"process")]) {
                v19 = nil;
                LogSelectorError(v15, NSSelectorFromString(@"process"));
            } else {
                v19 = [v15 process];
            }
            v20 = nil;
            LogSelectorError(v19, NSSelectorFromString(@"bundleIdentifier"));
        } else {
            if (![v15 respondsToSelector:NSSelectorFromString(@"process")]) {
                v21 = nil;
                LogSelectorError(v15, NSSelectorFromString(@"process"));
            } else {
                v21 = [v15 process];
            }
            v20 = [v21 bundleIdentifier];
        }
        UIApplication *sharedApplication = [UIApplication sharedApplication];
        if ([objc_getAssociatedObject(sharedApplication, NSSelectorFromString(@"lockAssertions")) containsObject:v20]) {
            if (![a3 respondsToSelector:NSSelectorFromString(@"isForeground")]) {
                LogSelectorError(a3, NSSelectorFromString(@"isForeground"));
                v23 = 0;
            } else {
                v23 = [a3 isForeground];
                v17 = v23;
            }
            if ((v23 & 1) == 0) {
                return v17;
            }
        }
        v17 = _logos_orig$SPRINGBOARD$FBScene$updateSettings$withTransitionContext$completion$(a1, a2, a3, a4, a5);
    }
    return v17;
}


id _logos_method$SPRINGBOARD$FBScene$client(id a1, SEL a2)
{
    return [a1 valueForKey:@"_client"];
}


int _logos_method$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$(long a1, long a2, int a3)
{
    long v1;
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"liveCarplayWindow")]) {
        v1 = 0;
        UIApplication *sharedApplication2 = [UIApplication sharedApplication];
        LogSelectorError(sharedApplication2, NSSelectorFromString(@"liveCarplayWindow"));
    } else {
        UIApplication *sharedApplication3 = [UIApplication sharedApplication];
        v1 = [sharedApplication3 liveCarplayWindow];
    }
    if (!v1) {
        return _logos_orig$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$(a1, a2, a3);
    }
    NSString *v5 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v5);
    UIDevice *currentDevice = [UIDevice currentDevice];
    UIDeviceOrientation orientation = [currentDevice orientation];
    return _logos_orig$SPRINGBOARD$SBMainSwitcherViewController$_updateContentViewInterfaceOrientation$(a1, a2, orientation);
}


bool _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isMainScreenCounterpartToLiveCarplayApp(id a1, SEL a2)
{
    id v1;
    id v7;
    id v8;
    id v11;
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"liveCarplayWindow")]) {
        v1 = nil;
        UIApplication *sharedApplication2 = [UIApplication sharedApplication];
        LogSelectorError(sharedApplication2, NSSelectorFromString(@"liveCarplayWindow"));
    } else {
        UIApplication *sharedApplication3 = [UIApplication sharedApplication];
        v1 = [sharedApplication3 liveCarplayWindow];
    }
    if (!v1) {
        return false;
    }
    id appViewController = [v1 appViewController];
    if (![appViewController respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v7 = nil;
        LogSelectorError(appViewController, NSSelectorFromString(@"sceneHandle"));
    } else {
        v7 = [appViewController sceneHandle];
    }
    if (![a1 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v8 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"sceneHandle"));
    } else {
        v8 = [a1 sceneHandle];
    }
    if (![v7 isEqual:v8]) {
        return false;
    }
    NSString *v9 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isMainScreenCounterpartToLiveCarplayApp"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v9);
    id v10 = [appViewController valueForKey:@"_deviceAppViewController"];
    if (![v10 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
        v11 = nil;
        LogSelectorError(v10, NSSelectorFromString(@"_sceneView"));
    } else {
        v11 = [v10 _sceneView];
    }
    return v11 && ![a1 isEqual:v11];
}


BOOL _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isHostingContentOnCarplayScreen(id a1, SEL a2)
{
    id v2;
    id v8;
    id v9;
    id v11;
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$isHostingContentOnCarplayScreen"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    if (![sharedApplication respondsToSelector:NSSelectorFromString(@"liveCarplayWindow")]) {
        v2 = nil;
        UIApplication *sharedApplication2 = [UIApplication sharedApplication];
        LogSelectorError(sharedApplication2, NSSelectorFromString(@"liveCarplayWindow"));
    } else {
        UIApplication *sharedApplication3 = [UIApplication sharedApplication];
        v2 = [sharedApplication3 liveCarplayWindow];
    }
    if (!v2) {
        return NO;
    }
    id appViewController = [v2 appViewController];
    if (![appViewController respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v8 = nil;
        LogSelectorError(appViewController, NSSelectorFromString(@"sceneHandle"));
    } else {
        v8 = [appViewController sceneHandle];
    }
    if (![a1 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v9 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"sceneHandle"));
    } else {
        v9 = [a1 sceneHandle];
    }
    if (![v8 isEqual:v9]) {
        return NO;
    }
    id v10 = [appViewController valueForKey:@"_deviceAppViewController"];
    if (![v10 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
        v11 = nil;
        LogSelectorError(v10, NSSelectorFromString(@"_sceneView"));
    } else {
        v11 = [v10 _sceneView];
    }
    if (!v11) {
        return NO;
    }
    return [a1 isEqual:v11];
}


BOOL _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews(id a1, long a2)
{
    int v2;
    BOOL v1;
    int v4;
    UIView *v6;
    _logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews(a1, a2);
    SEL v0 = NSSelectorFromString(@"isMainScreenCounterpartToLiveCarplayApp");
    if (![a1 respondsToSelector:v0]) {
        LogSelectorError(a1, NSSelectorFromString(@"isMainScreenCounterpartToLiveCarplayApp"));
        v2 = 0;
    } else {
        v2 = [a1 isMainScreenCounterpartToLiveCarplayApp];
        v1 = v2;
    }
    if ((v2 & 1) == 0) {
        return v1;
    }
    NSString *v3 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$layoutSubviews"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v3);
    if (![a1 respondsToSelector:NSSelectorFromString(@"displayMode")]) {
        v4 = 0;
        LogSelectorError(a1, NSSelectorFromString(@"displayMode"));
    } else {
        v4 = [a1 displayMode];
        v1 = v4;
    }
    if (v4 == 4) {
        return v1;
    }
    if (![a1 respondsToSelector:NSSelectorFromString(@"rotateToDeviceOrientation")]) {
        LogSelectorError(a1, NSSelectorFromString(@"rotateToDeviceOrientation"));
    } else {
        [a1 rotateToDeviceOrientation];
    }
    if (![a1 respondsToSelector:NSSelectorFromString(@"backgroundView")]) {
        v6 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"backgroundView"));
    } else {
        v6 = [a1 backgroundView];
        v1 = v6;
    }
    if (!v6) {
        return v1;
    }
    CGRect frame = [v6 frame];
    CGRect frame2 = [v6 frame];
    UIDevice *currentDevice = [UIDevice currentDevice];
    v1 = UIInterfaceOrientationIsLandscape([currentDevice orientation]);
    if (frame.size.width > frame2.size.height == v1) {
        v1 = (![a1 respondsToSelector:NSSelectorFromString(@"drawCarplayPlaceholder")]) ? LogSelectorError(a1, NSSelectorFromString(@"drawCarplayPlaceholder")) : [a1 drawCarplayPlaceholder];
    }
    return v1;
}


id _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView(id a1, long a2)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    id v1 = _logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$homeGrabberView(a1, a2);
    if (v1 != nil) {
        if (![a1 respondsToSelector:NSSelectorFromString(@"isHostingContentOnCarplayScreen")]) {
            LogSelectorError(a1, NSSelectorFromString(@"isHostingContentOnCarplayScreen"));
        } else if (([a1 isHostingContentOnCarplayScreen] & 1) != 0) {
            NSLog(@"Hiding home grabber for CarPlay scene");
            [v1 setHidden:1 forReason:@"CarPlay" withAnimationSettings:0];
            [v1 setUserInteractionEnabled:NO];
        }
    }
    return v1;
}


void _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$rotateToDeviceOrientation(id a1, SEL a2)
{
    UIView *v1;
    UIDevice *v7;
    UIDeviceOrientation v8;
    SEL v0 = NSSelectorFromString(@"backgroundView");
    if (![a1 respondsToSelector:v0]) {
        v1 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"backgroundView"));
    } else {
        v1 = [a1 backgroundView];
    }
    id v2 = nil;
    UIView *superview = [v1 superview];
    while (superview) {
        if (superview != nil && [superview isKindOfClass:objc_getClass("SBOrientationTransformWrapperView")]) {
            SBOrientationTransformWrapperView *v9 = superview;
            if (superview) {
                v7 = [UIDevice currentDevice];
                v8 = [v7 orientation];
                [v9 setContentOrientation:v8];
            }
            return;
        }
        superview = [superview superview];
    }
    if (!v2) {
        return;
    }
    v7 = [UIDevice currentDevice];
    v8 = [v7 orientation];
    [v2 setContentOrientation:v8];
}


void _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$drawCarplayPlaceholder(id a1, SEL a2)
{
    UIView *v5;
    long v28;
    NSString *v1 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$drawCarplayPlaceholder"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v1);
    UIDevice *currentDevice = [UIDevice currentDevice];
    UIDeviceOrientation orientation = [currentDevice orientation];
    SEL v4 = NSSelectorFromString(@"backgroundView");
    if (![a1 respondsToSelector:v4]) {
        v5 = nil;
        LogSelectorError(a1, NSSelectorFromString(@"backgroundView"));
    } else {
        v5 = [a1 backgroundView];
    }
    if (v5 != nil) {
        id v7 = objc_getAssociatedObject(v5, &kPropertyKey_didDrawPlaceholder);
        int v9 = (!v7) ? -1 : [v7 intValue];
        if (v9 != orientation) {
            if (v9 > 0) {
                NSArray<UIView *> *subviews = [v5 subviews];
                for (UIView *v29 in subviews) {
                    if ([v29 isKindOfClass:objc_getClass("UILabel")]) {
                        [v29 removeFromSuperview];
                    }
                }
            }
            NSNumber *value = [NSNumber numberWithInt:orientation];
            objc_setAssociatedObject(v5, &kPropertyKey_didDrawPlaceholder, value, OBJC_ASSOCIATION_RETAIN);
            UIScreen *mainScreen = [UIScreen mainScreen];
            CGRect v24 = [mainScreen boundsForOrientation:orientation];
            UILabel *v25 = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 300.0, v24.size.width, 50.0)];
            [v25 setText:@"Running on CarPlay Screen"];
            [v25 setTextAlignment:NSTextAlignmentCenter];
            UIFont *v26 = [UIFont systemFontOfSize:24.0 weight:UIFontWeightSemibold];
            [v25 setFont:v26];
            CGPoint center = [v5 center];
            [v25 setCenter:center];
            [v5 addSubview:v25];
        }
        [v5 setWallpaperStyle:18];
        if (![objc_getClass("SBApplicationSceneView") respondsToSelector:NSSelectorFromString(@"defaultDisplayModeAnimationFactory")]) {
            v28 = 0;
            LogSelectorError(objc_getClass("SBApplicationSceneView"), NSSelectorFromString(@"defaultDisplayModeAnimationFactory"));
        } else {
            v28 = [objc_getClass("SBApplicationSceneView") defaultDisplayModeAnimationFactory];
        }
        [a1 setDisplayMode:1 animationFactory:v28 completion:0];
    } else {
        NSLog(@"On-device app scene for a carplay-hosted app has a nil background view");
    }
}


int _logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$(id a1, long a2, int a3, long a4, long a5)
{
    int v1;
    SEL v0 = NSSelectorFromString(@"isMainScreenCounterpartToLiveCarplayApp");
    if (![a1 respondsToSelector:v0]) {
        LogSelectorError(a1, NSSelectorFromString(@"isMainScreenCounterpartToLiveCarplayApp"));
        v1 = 0;
    } else {
        v1 = [a1 isMainScreenCounterpartToLiveCarplayApp];
    }
    if (a3 != 4 || (v1 & 1) == 0) {
        return _logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$(a1, a2, a3, a4, a5);
    }
    NSString *v3 = [NSString stringWithFormat:@"%s", "_logos_method$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v3);
    return _logos_orig$SPRINGBOARD$SBDeviceApplicationSceneView$setDisplayMode$animationFactory$completion$(a1, a2, 1, a4, a5);
}


CGRect _logos_method$SPRINGBOARD$UIScreen$boundsForOrientation$(id a1, SEL a2, UIInterfaceOrientation a3)
{
    CGRect bounds = [a1 bounds];
    CGFloat v3 = bounds.size.width;
    CGRect bounds2 = [a1 bounds];
    CGFloat v5 = bounds2.size.height;
    CGRect v1 = CGRectZero;
    if (!UIInterfaceOrientationIsLandscape(a3)) {
        double v7 = v3 >= v5;
        CGFloat width2 = (v7) ? v5 : v3;
        if (v3 >= v5) {
            v5 = v3;
        }
        v1.size = CGSizeMake(width2, v5);
    } else {
        double v11 = v3 >= v5;
        CGFloat width = (v11) ? v3 : v5;
        if (v3 >= v5) {
            v3 = v5;
        }
        v1.size = CGSizeMake(width, v3);
    }
    return v1;
}


int _logos_method$SPRINGBOARD$SBMainDisplaySceneManager$_sceneIdentityForApplication$createPrimaryIfRequired$sceneSessionRole$(long a1, long a2, id a3, int a4, id a5)
{
    bool v0 = a4 & 1;
    NSLog(@"CARPLAY ** _sceneIdentityForApplication: %@ createPrimaryIfRequired: %d sceneSessionRole: %@", a3, v0, a5);
    return _logos_orig$SPRINGBOARD$SBMainDisplaySceneManager$_sceneIdentityForApplication$createPrimaryIfRequired$sceneSessionRole$(a1, a2, a3, v0, a5);
}


bool UIInterfaceOrientationIsLandscape(UIInterfaceOrientation a1)
{
    if (a1 == UIInterfaceOrientationLandscapeLeft) {
        return true;
    }
    return a1 == UIInterfaceOrientationLandscapeRight;
}


double CGRectMake(double a1)
{
    return a1;
}


double CGSizeMake(double a1)
{
    return a1;
}


__attribute__((constructor))
void _logosLocalCtor_fc490ca4(void)
{
    uint8_t v9[5];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *systemVersion = [currentDevice systemVersion];
    if ([systemVersion compare:@"14.0" options:NSNumericSearch] == NSOrderedAscending) {
        return;
    }
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = [mainBundle bundlePath];
    NSBundle *mainBundle2 = [NSBundle mainBundle];
    NSString *bundleIdentifier = [mainBundle2 bundleIdentifier];
    if ([bundlePath containsString:@".app"] && ![bundleIdentifier containsString:@"com.apple."]) {
        Class cls = objc_getClass("UIApplication");
        MSHookMessageEx(cls, @selector(init), &_logos_method$APPS$UIApplication$init, &_logos_orig$APPS$UIApplication$init);
        _strcpy(v9, "v@:@");
        class_addMethod(cls, @selector(handleRotationRequest:), &_logos_method$APPS$UIApplication$handleRotationRequest$, (const char *)v9);
        Class v10 = objc_getClass("UIWindow");
        MSHookMessageEx(v10, @selector(_setRotatableViewOrientation:duration:force:), &_logos_method$APPS$UIWindow$_setRotatableViewOrientation$duration$force$, &_logos_orig$APPS$UIWindow$_setRotatableViewOrientation$duration$force$);
    }
}


id _logos_method$APPS$UIApplication$init(long a1, long a2)
{
    id observer = _logos_orig$APPS$UIApplication$init(a1, a2);
    Class v1 = objc_getClass("NSDistributedNotificationCenter");
    NSDistributedNotificationCenter *defaultCenter = [v1 defaultCenter];
    SEL aSelector = NSSelectorFromString(@"handleRotationRequest:");
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = [mainBundle bundleIdentifier];
    [defaultCenter addObserver:observer selector:aSelector name:@"com.carplayenable.orientation" object:bundleIdentifier];
    return observer;
}


void _logos_method$APPS$UIApplication$handleRotationRequest$(id a1, SEL a2, id a3)
{
    id v2;
    UIWindow *v9;
    NSString *v0 = [NSString stringWithFormat:@"%s", "_logos_method$APPS$UIApplication$handleRotationRequest$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    SEL v1 = NSSelectorFromString(@"userInfo");
    if (![a3 respondsToSelector:v1]) {
        v2 = nil;
        LogSelectorError(a3, NSSelectorFromString(@"userInfo"));
    } else {
        v2 = [a3 userInfo];
    }
    id v3 = [v2 objectForKeyedSubscript:@"orientation"];
    orientationOverride = [v3 intValue];
    UIDeviceOrientation v4 = orientationOverride;
    if ((uint32_t)(orientationOverride + 1) == 0) {
        UIDevice *currentDevice = [UIDevice currentDevice];
        v4 = [currentDevice orientation];
        if (v4 <= UIDeviceOrientationPortrait) {
            v4 = UIDeviceOrientationPortrait;
        }
    }
    UIApplication *sharedApplication3 = [UIApplication sharedApplication];
    if (![sharedApplication3 respondsToSelector:NSSelectorFromString(@"keyWindow")]) {
        v9 = nil;
        UIApplication *sharedApplication = [UIApplication sharedApplication];
        LogSelectorError(sharedApplication, NSSelectorFromString(@"keyWindow"));
    } else {
        UIApplication *sharedApplication2 = [UIApplication sharedApplication];
        v9 = [sharedApplication2 keyWindow];
    }
    [v9 _setRotatableViewOrientation:v4 duration:0 force:1];
}


int _logos_method$APPS$UIWindow$_setRotatableViewOrientation$duration$force$(long a1, long a2, int a3, int a4)
{
    if (orientationOverride <= 0) {
        return _logos_orig$APPS$UIWindow$_setRotatableViewOrientation$duration$force$(a1, a2, a3, a4);
    }
    NSString *v1 = [NSString stringWithFormat:@"%s", "_logos_method$APPS$UIWindow$_setRotatableViewOrientation$duration$force$"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v1);
    return _logos_orig$APPS$UIWindow$_setRotatableViewOrientation$duration$force$(a1, a2, orientationOverride, a4);
}


void LogSelectorError(id a1, SEL a2)
{
    NSLog(@"carplayenable error: %@ does not respond to selector %@", a1, NSStringFromSelector(a2));
}


id getCarplayCADisplay(void)
{
    id v1;
    id v3;
    id v6;
    NSString *v15;
    if (![objc_getClass("AVExternalDevice") respondsToSelector:NSSelectorFromString(@"currentCarPlayExternalDevice")]) {
        v1 = nil;
        LogSelectorError(objc_getClass("AVExternalDevice"), NSSelectorFromString(@"currentCarPlayExternalDevice"));
    } else {
        v1 = [objc_getClass("AVExternalDevice") currentCarPlayExternalDevice];
    }
    if (v1 != nil) {
        if (![v1 respondsToSelector:NSSelectorFromString(@"screenIDs")]) {
            v3 = nil;
            LogSelectorError(v1, NSSelectorFromString(@"screenIDs"));
        } else {
            v3 = [v1 screenIDs];
        }
        id v4 = [v3 objectAtIndexedSubscript:0];
        if (![objc_getClass("CADisplay") respondsToSelector:NSSelectorFromString(@"displays")]) {
            v6 = nil;
            LogSelectorError(objc_getClass("CADisplay"), NSSelectorFromString(@"displays"));
        } else {
            v6 = [objc_getClass("CADisplay") displays];
        }
        for (id v10 in v6) {
            if ([v10 respondsToSelector:NSSelectorFromString(@"uniqueId")]) {
                v15 = [v10 uniqueId];
            } else {
                v15 = nil;
                LogSelectorError(v10, NSSelectorFromString(@"uniqueId"));
            }
            if ([v4 isEqualToString:v15]) {
                return v10;
            }
        }
    }
    return nil;
}


void LogSelectorError(id a1, SEL a2)
{
    NSLog(@"carplayenable error: %@ does not respond to selector %@", a1, NSStringFromSelector(a2));
}


double CGRectMake(double a1)
{
    return a1;
}


bool UIInterfaceOrientationIsLandscape(UIInterfaceOrientation a1)
{
    if (a1 == UIInterfaceOrientationLandscapeLeft) {
        return true;
    }
    return a1 == UIInterfaceOrientationLandscapeRight;
}


bool UIInterfaceOrientationIsPortrait(UIInterfaceOrientation a1)
{
    if (a1 == UIInterfaceOrientationPortrait) {
        return true;
    }
    return a1 == UIInterfaceOrientationPortraitUpsideDown;
}


double CGSizeMake(double a1)
{
    return a1;
}


BOOL writeSymbolicatedLogToFile(NSString *a1, NSString *a2)
{
    struct AnonymousStruct_9 v0 = CSSymbolicatorCreateWithTask(mach_task_self_);
    NSString *v1 = [a1 copy];
    NSRegularExpression *v3 = [NSRegularExpression regularExpressionWithPattern:@"0[xX][0-9a-fA-F]+" options:0 error:nil];
    NSUInteger length = [a1 length];
    NSArray<NSTextCheckingResult *> *v5 = [v3 matchesInString:a1 options:0 range:(NSRange){0, length}];
    for (NSTextCheckingResult *v2 in v5) {
        NSRange range = [v2 range];
        NSString *target = [a1 substringWithRange:range];
        const char *UTF8String = [target UTF8String];
        struct AnonymousStruct_9 v17 = CSSymbolicatorGetSymbolWithAddressAtTime(v0.field_0, v0.field_8, strtoull(UTF8String, NULL, 0), 0x80000000);
        unsigned long v18 = v17.field_0;
        unsigned long v19 = v17.field_8;
        if ((CSIsNull(v18, v17.field_8) & 255) == 0) {
            NSString *replacement = [NSString stringWithFormat:@"%s", CSSymbolGetName(v18, v19)];
            v1 = [v1 stringByReplacingOccurrencesOfString:target withString:replacement];
        }
    }
    return [v1 writeToFile:a2 atomically:NO encoding:NSUTF8StringEncoding error:nil];
}


void gatherUnsymbolicatedCrashlogs(id a1, id a2)
{
    NSFileManager *defaultManager2 = [NSFileManager defaultManager];
    NSArray<NSString *> *v3 = [defaultManager2 contentsOfDirectoryAtPath:@"/var/mobile/Library/Logs/CrashReporter" error:nil];
    for (NSString *v12 in v3) {
        if ([a2 containsObject:v12]) {
            continue;
        }
        NSString *pathExtension = [v12 pathExtension];
        if (![pathExtension isEqualToString:@"ips"]) {
            continue;
        }
        NSString *path = [NSString stringWithFormat:@"%@/%@", @"/var/mobile/Library/Logs/CrashReporter", v12];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSDictionary<NSFileAttributeKey, id> *v16 = [defaultManager attributesOfItemAtPath:path error:nil];
        NSDate *fileCreationDate = [v16 fileCreationDate];
        NSTimeInterval v18 = [fileCreationDate timeIntervalSinceNow];
        if (v18 < 0.0) {
            v18 = -v18;
        }
        if (v18 / 3600.0 > 1.0) {
            continue;
        }
        NSArray<NSString *> *v21 = [v12 componentsSeparatedByString:@"-"];
        NSString *v22 = [v21 objectAtIndexedSubscript:0];
        if (![@[@"SpringBoard", @"CarPlay"] containsObject:v22]) {
            continue;
        }
        NSString *v23 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if (![v23 containsString:@"/Library/MobileSubstrate/DynamicLibraries/carplayenable.dylib"]) {
            continue;
        }
        NSString *v24 = [NSString stringWithFormat:@"%@/%@", a1, v12];
        writeSymbolicatedLogToFile(v23, v24);
    }
}


void gatherCr4shedLogs(id a1, id a2)
{
    NSFileManager *defaultManager2 = [NSFileManager defaultManager];
    NSArray<NSString *> *v3 = [defaultManager2 contentsOfDirectoryAtPath:@"/var/mobile/Library/Cr4shed" error:nil];
    for (NSString *v12 in v3) {
        if ([a2 containsObject:v12]) {
            continue;
        }
        NSString *pathExtension = [v12 pathExtension];
        if (![pathExtension isEqualToString:@"log"]) {
            continue;
        }
        NSString *v14 = [NSString stringWithFormat:@"%@/%@", @"/var/mobile/Library/Cr4shed", v12];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSDictionary<NSFileAttributeKey, id> *v16 = [defaultManager attributesOfItemAtPath:v14 error:nil];
        NSDate *fileCreationDate = [v16 fileCreationDate];
        NSTimeInterval v18 = [fileCreationDate timeIntervalSinceNow];
        if (v18 < 0.0) {
            v18 = -v18;
        }
        if (v18 / 3600.0 > 1.0) {
            continue;
        }
        NSArray<NSString *> *v21 = [v12 componentsSeparatedByString:@"@"];
        NSString *v22 = [v21 objectAtIndexedSubscript:0];
        if (![@[@"SpringBoard", @"CarPlay"] containsObject:v22]) {
            continue;
        }
        NSString *v23 = [NSString stringWithContentsOfFile:v14 encoding:NSUTF8StringEncoding error:nil];
        if (![v23 containsString:@"Culprit: carplayenable.dylib"]) {
            continue;
        }
        NSString *dstPath = [NSString stringWithFormat:@"%@/%@", a1, v12];
        NSFileManager *defaultManager3 = [NSFileManager defaultManager];
        [defaultManager3 copyItemAtPath:v14 toPath:dstPath error:nil];
    }
}


long symbolicateAndUploadCrashlogs(long a1)
{
    return a1;
}
