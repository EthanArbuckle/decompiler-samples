struct CRCarPlayWindow {
    bool _isFullscreen; // +0x8
    bool _shouldGenerateSnapshot; // +0x9
    bool _drawOnMainScreen; // +0xa
    int _orientation; // +0xc
    UIWindow *_rootWindow; // +0x10
    UIView *_dockView; // +0x18
    UIView *_appContainerView; // +0x20
    UIImageView *_launchImageView; // +0x28
    UIView *_fullscreenTransparentOverlay; // +0x30
    id _appViewController; // +0x38
    id _sceneMonitor; // +0x40
    id _application; // +0x48
    id _sessionStatus; // +0x50
    NSMutableArray *_observers; // +0x58
    UITapGestureRecognizer *_screenTapRecognizer; // +0x60
};

static int (*orig_BKSDisplayServicesSetScreenBlanked)(int);

CRCarPlayWindow *-[CRCarPlayWindow initWithBundleIdentifier:](id a1)
{
    CARSessionStatus *v5;
    id v6;
    UIView *v28;
    id v42;
    UIView *v46;
    id v54;
    id v57;
    id v59;
    id v69;
    id v71;
    id v73;
    id v81;
    id v83;
    id v88;
    long v91;
    id v93;
    id v9;
    CRCarPlayWindow *v2 = [super init];
    if (v2 != nil) {
        v2->_observers = [[NSMutableArray alloc] init];
        CRPreferences *sharedInstance = [CRPreferences sharedInstance];
        [sharedInstance reloadPreferences];
        [v2 setOrientation:3];
        if (![[objc_getClass("CARSessionStatus") alloc] respondsToSelector:NSSelectorFromString(@"initForCarPlayShell")]) {
            v5 = nil;
            LogSelectorError([objc_getClass("CARSessionStatus") alloc], NSSelectorFromString(@"initForCarPlayShell"));
        } else {
            v5 = [[objc_getClass("CARSessionStatus") alloc] initForCarPlayShell];
        }
        [v2 setSessionStatus:v5];
        if (![objc_getClass("SBApplicationController") respondsToSelector:NSSelectorFromString(@"sharedInstance")]) {
            v6 = nil;
            LogSelectorError(objc_getClass("SBApplicationController"), NSSelectorFromString(@"sharedInstance"));
        } else {
            v6 = [objc_getClass("SBApplicationController") sharedInstance];
        }
        [v2 setApplication:[v6 applicationWithBundleIdentifier:a1]];
        if (![v2 application] || ![(v9 = [v2 application]) isKindOfClass:NSClassFromString(@"SBApplication")]) {
            id application = [v2 application];
            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplication", application];
        }
        if (!v2->_drawOnMainScreen) {
            id v10 = getCarplayCADisplay();
            if (!v10) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CADisplay", v10];
            } else if (![v10 isKindOfClass:NSClassFromString(@"CADisplay")]) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CADisplay", v10];
            }
            FBSDisplayConfiguration *v12 = [[objc_getClass("FBSDisplayConfiguration") alloc] initWithCADisplay:v10 isMainDisplay:0];
            if (!v12) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSDisplayConfiguration", v12];
            } else if (![v12 isKindOfClass:NSClassFromString(@"FBSDisplayConfiguration")]) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSDisplayConfiguration", v12];
            }
            [v2 setRootWindow:[[objc_getClass("UIRootSceneWindow") alloc] initWithDisplayConfiguration:v12]];
        } else {
            UIWindow *v14 = [UIWindow alloc];
            UIScreen *mainScreen = [UIScreen mainScreen];
            [v2 setRootWindow:[v14 initWithFrame:[mainScreen bounds]]];
            UIWindow *rootWindow = [v2 rootWindow];
            [rootWindow _rotateWindowToOrientation:3 updateStatusBar:1 duration:0 skipCallbacks:0];
        }
        UIWindow *rootWindow2 = [v2 rootWindow];
        CALayer *layer = [rootWindow2 layer];
        [layer setCornerRadius:13.0];
        UIWindow *rootWindow3 = [v2 rootWindow];
        CALayer *layer2 = [rootWindow3 layer];
        [layer2 setMasksToBounds:YES];
        [v2 setupWallpaperBackground];
        [v2 setupDock];
        [v2 setupLiveAppView];
        UIWindow *rootWindow4 = [v2 rootWindow];
        CGRect frame = [rootWindow4 frame];
        [v2 setAppContainerView:[[UIView alloc] initWithFrame:CGRectMake(40.0, frame.origin.y, frame.size.width - 40.0, frame.size.height)]];
        UIView *appContainerView = [v2 appContainerView];
        UIColor *clearColor = [UIColor clearColor];
        [appContainerView setBackgroundColor:clearColor];
        UIWindow *rootWindow5 = [v2 rootWindow];
        UIView *appContainerView2 = [v2 appContainerView];
        [rootWindow5 addSubview:appContainerView2];
        [v2 setupLaunchImage];
        id appViewController = [v2 appViewController];
        if (![appViewController respondsToSelector:NSSelectorFromString(@"view")]) {
            v28 = nil;
            id appViewController2 = [v2 appViewController];
            LogSelectorError(appViewController2, NSSelectorFromString(@"view"));
        } else {
            id appViewController3 = [v2 appViewController];
            v28 = [appViewController3 view];
        }
        NSArray<UIView *> *subviews = [v28 subviews];
        for (UIView *v40 in subviews) {
            if ([v40 isKindOfClass:objc_getClass("SBHomeGrabberView")]) {
                [v40 removeFromSuperview];
            }
            if ([v40 respondsToSelector:NSSelectorFromString(@"recursiveDescription")]) {
                v42 = [v40 recursiveDescription];
            } else {
                v42 = nil;
                LogSelectorError(v40, NSSelectorFromString(@"recursiveDescription"));
            }
            NSLog(@"carplayenable appviewcontroller view subview: %@ %@", v40, v42);
        }
        UIView *appContainerView3 = [v2 appContainerView];
        id appViewController4 = [v2 appViewController];
        if (![appViewController4 respondsToSelector:NSSelectorFromString(@"view")]) {
            v46 = nil;
            id appViewController5 = [v2 appViewController];
            LogSelectorError(appViewController5, NSSelectorFromString(@"view"));
        } else {
            id appViewController6 = [v2 appViewController];
            v46 = [appViewController6 view];
        }
        [appContainerView3 addSubview:v46];
        int orientation = [v2 orientation];
        [v2 resizeAppViewForOrientation:orientation fullscreen:NO forceUpdate:YES];
        UIWindow *rootWindow6 = [v2 rootWindow];
        [rootWindow6 setAlpha:0.0];
        UIWindow *rootWindow7 = [v2 rootWindow];
        [rootWindow7 setHidden:NO];
        orig_BKSDisplayServicesSetScreenBlanked(0);
        [UIView animateWithDuration:1.0 animations:^void(void) {
            UIWindow *rootWindow = [v2 rootWindow];
            [rootWindow setAlpha:1.0];
        } completion:nil];
        id appViewController7 = [v2 appViewController];
        if (![appViewController7 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
            v54 = nil;
            id appViewController8 = [v2 appViewController];
            LogSelectorError(appViewController8, NSSelectorFromString(@"sceneHandle"));
        } else {
            id appViewController9 = [v2 appViewController];
            v54 = [appViewController9 sceneHandle];
        }
        if (![objc_getClass("SBMainDisplaySceneLayoutViewController") respondsToSelector:NSSelectorFromString(@"mainDisplaySceneLayoutViewController")]) {
            v57 = nil;
            LogSelectorError(objc_getClass("SBMainDisplaySceneLayoutViewController"), NSSelectorFromString(@"mainDisplaySceneLayoutViewController"));
        } else {
            v57 = [objc_getClass("SBMainDisplaySceneLayoutViewController") mainDisplaySceneLayoutViewController];
        }
        SEL v58 = NSSelectorFromString(@"appViewControllers");
        if (![v57 respondsToSelector:v58]) {
            v59 = nil;
            LogSelectorError(v57, NSSelectorFromString(@"appViewControllers"));
        } else {
            v59 = [v57 appViewControllers];
        }
        for (id v68 in v59) {
            if ([v68 respondsToSelector:NSSelectorFromString(@"_applicationSceneViewController")]) {
                v69 = [v68 _applicationSceneViewController];
            } else {
                v69 = nil;
                LogSelectorError(v68, NSSelectorFromString(@"_applicationSceneViewController"));
            }
            if ([v69 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
                v71 = [v69 _sceneView];
            } else {
                v71 = nil;
                LogSelectorError(v69, NSSelectorFromString(@"_sceneView"));
            }
            if ([v71 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v73 = [v71 sceneHandle];
            } else {
                v73 = nil;
                LogSelectorError(v71, NSSelectorFromString(@"sceneHandle"));
            }
            if ([v73 isEqual:v54]) {
                if ([v71 respondsToSelector:NSSelectorFromString(@"drawCarplayPlaceholder")]) {
                    [v71 drawCarplayPlaceholder];
                } else {
                    LogSelectorError(v71, NSSelectorFromString(@"drawCarplayPlaceholder"));
                }
            }
        }
        Class v76 = objc_getClass("NSDistributedNotificationCenter");
        NSDistributedNotificationCenter *defaultCenter = [v76 defaultCenter];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        id<NSObject> v80 = [defaultCenter addObserverForName:@"com.carplay.preferences.changed" object:@"dockAlignment" queue:mainQueue usingBlock:^void(NSNotification *arg1) {
            CRPreferences *sharedInstance = [CRPreferences sharedInstance];
            [sharedInstance reloadPreferences];
            [v2 setupDock];
            [v2 resizeAppViewForOrientation:v2->_orientation fullscreen:v2->_isFullscreen forceUpdate:YES];
        }];
        [v2->_observers addObject:v80];
        v2->_screenTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:v2 action:@selector(handleScreenTapped)];
        if (![objc_getClass("_UISystemGestureManager") respondsToSelector:NSSelectorFromString(@"sharedInstance")]) {
            v81 = nil;
            LogSelectorError(objc_getClass("_UISystemGestureManager"), NSSelectorFromString(@"sharedInstance"));
        } else {
            v81 = [objc_getClass("_UISystemGestureManager") sharedInstance];
        }
        UIWindow *rootWindow8 = [v2 rootWindow];
        if (![rootWindow8 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
            v83 = nil;
            UIWindow *rootWindow9 = [v2 rootWindow];
            LogSelectorError(rootWindow9, NSSelectorFromString(@"displayConfiguration"));
        } else {
            UIWindow *rootWindow10 = [v2 rootWindow];
            v83 = [rootWindow10 displayConfiguration];
        }
        SEL v86 = NSSelectorFromString(@"identity");
        if (![v83 respondsToSelector:v86]) {
            UIWindow *rootWindow11 = [v2 rootWindow];
            if (![rootWindow11 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
                v88 = nil;
                UIWindow *rootWindow12 = [v2 rootWindow];
                LogSelectorError(rootWindow12, NSSelectorFromString(@"displayConfiguration"));
            } else {
                UIWindow *rootWindow13 = [v2 rootWindow];
                v88 = [rootWindow13 displayConfiguration];
            }
            v91 = 0;
            LogSelectorError(v88, NSSelectorFromString(@"identity"));
        } else {
            UIWindow *rootWindow14 = [v2 rootWindow];
            if (![rootWindow14 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
                v93 = nil;
                UIWindow *rootWindow15 = [v2 rootWindow];
                LogSelectorError(rootWindow15, NSSelectorFromString(@"displayConfiguration"));
            } else {
                UIWindow *rootWindow16 = [v2 rootWindow];
                v93 = [rootWindow16 displayConfiguration];
            }
            v91 = [v93 identity];
        }
        [v81 addGestureRecognizer:v2->_screenTapRecognizer toDisplayWithIdentity:v91];
    }
    return v2;
}


void -[CRCarPlayWindow setupWallpaperBackground](void)
{
    id v3;
    UIWindow *rootWindow = [self rootWindow];
    CGRect frame = [rootWindow frame];
    UIImageView *v2 = [[UIImageView alloc] initWithFrame:frame];
    if (![objc_getClass("CRSUIWallpaperPreferences") respondsToSelector:NSSelectorFromString(@"defaultWallpaper")]) {
        v3 = nil;
        LogSelectorError(objc_getClass("CRSUIWallpaperPreferences"), NSSelectorFromString(@"defaultWallpaper"));
    } else {
        v3 = [objc_getClass("CRSUIWallpaperPreferences") defaultWallpaper];
    }
    if (!v3) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CRSUIWallpaper", v3];
    } else if (![v3 isKindOfClass:NSClassFromString(@"CRSUIWallpaper")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CRSUIWallpaper", v3];
    }
    [v2 setImage:[v3 wallpaperImageCompatibleWithTraitCollection:0]];
    UIVisualEffectView *v5 = [[UIVisualEffectView alloc] initWithEffect:[objc_getClass("UIBlurEffect") effectWithBlurRadius:10.0]];
    [v5 setFrame:frame];
    [v2 addSubview:v5];
    UIWindow *rootWindow2 = [self rootWindow];
    [rootWindow2 addSubview:v2];
}


void -[CRCarPlayWindow setupDock](void)
{
    if (self->_dockView != nil) {
        [self->_dockView removeFromSuperview];
    }
    UIWindow *rootWindow = [self rootWindow];
    CGRect frame = [rootWindow frame];
    CGFloat sizeheight = frame.size.height;
    CGFloat x = (![self shouldUseRightHandDock]) ? 0.0 : frame.size.width - 40.0;
    UIView *v6 = [UIView alloc];
    [self setDockView:[v6 initWithFrame:CGRectMake(x, frame.origin.y, 40.0, sizeheight)]];
    id v8 = [objc_getClass("UIBlurEffect") effectWithBlurRadius:20.0];
    UIVisualEffectView *v9 = [[UIVisualEffectView alloc] init];
    [v9 setFrame:CGRectMake(0.0, 0.0, 40.0, sizeheight)];
    Class v10 = objc_getClass("UIColorEffect");
    id v12 = [v10 colorEffectSaturate:2.0];
    Class v13 = objc_getClass("UIVisualEffect");
    SEL v14 = NSSelectorFromString(@"effectCompositingColor:withMode:alpha:");
    UIColor *blackColor = [UIColor blackColor];
    NSArray *v18 = @[objc_msgSend(v13, v14, blackColor, 7, 0.6), v12, v8];
    [v9 setBackgroundEffects:v18];
    UIView *dockView = [self dockView];
    [dockView addSubview:v9];
    UIWindow *rootWindow2 = [self rootWindow];
    UIView *dockView2 = [self dockView];
    [rootWindow2 addSubview:dockView2];
    NSBundle *v22 = [NSBundle bundleWithPath:@"/System/Library/CoreServices/CarPlay.app"];
    UITraitCollection *v23 = [UITraitCollection traitCollectionWithUserInterfaceIdiom:UIUserInterfaceIdiomCarPlay];
    UITraitCollection *v24 = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight];
    UITraitCollection *v27 = [UITraitCollection traitCollectionWithTraitsFromCollections:@[v23, v24]];
    UIButton *v30 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *v31 = [UIImage imageNamed:@"CarStatusBarIconsHomeButton" inBundle:v22 compatibleWithTraitCollection:v27];
    UIImage *v32 = [v31 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [v30 setImage:v32 forState:UIControlStateNormal];
    [v30 addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [v30 setFrame:CGRectMake((40.0 - 35.0) / 2.0, sizeheight - 35.0, 35.0, 35.0)];
    UIColor *whiteColor = [UIColor whiteColor];
    [v30 setTintColor:whiteColor];
    UIView *dockView3 = [self dockView];
    [dockView3 addSubview:v30];
    UIImageSymbolConfiguration *v36 = [UIImageSymbolConfiguration configurationWithPointSize:24.0 weight:UIImageSymbolWeightLight];
    UIButton *v38 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *v39 = [UIImage systemImageNamed:@"arrow.up.left.and.arrow.down.right" withConfiguration:v36];
    [v38 setImage:v39 forState:UIControlStateNormal];
    [v38 addTarget:self action:@selector(enterFullscreen) forControlEvents:UIControlEventTouchUpInside];
    [v38 setFrame:CGRectMake((40.0 - 30.0) / 2.0, 10.0, 30.0, 30.0)];
    UIColor *whiteColor2 = [UIColor whiteColor];
    [v38 setTintColor:whiteColor2];
    UIView *dockView4 = [self dockView];
    [dockView4 addSubview:v38];
    UIButton *v42 = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *v43 = [UIImage systemImageNamed:@"rotate.right" withConfiguration:v36];
    [v42 setImage:v43 forState:UIControlStateNormal];
    [v42 addTarget:self action:@selector(handleRotate) forControlEvents:UIControlEventTouchUpInside];
    CGRect frame2 = [v38 frame];
    [v42 setFrame:CGRectMake((40.0 - 30.0) / 2.0, frame2.origin.y + 10.0 + 30.0, 30.0, 30.0)];
    UIColor *whiteColor3 = [UIColor whiteColor];
    [v42 setTintColor:whiteColor3];
    UIView *dockView5 = [self dockView];
    [dockView5 addSubview:v42];
}


void -[CRCarPlayWindow setupLaunchImage](void)
{
    long v4;
    id v10;
    id v20;
    UIInterfaceOrientation v30;
    int v32;
    NSString *v36;
    UIInterfaceOrientation v43;
    NSString *v1 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow setupLaunchImage]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v1);
    XBApplicationSnapshotManifest *v2 = [objc_getClass("XBApplicationSnapshotManifest") alloc];
    id application = [self application];
    if (![application respondsToSelector:NSSelectorFromString(@"info")]) {
        v4 = 0;
        id application2 = [self application];
        LogSelectorError(application2, NSSelectorFromString(@"info"));
    } else {
        id application3 = [self application];
        v4 = [application3 info];
    }
    XBApplicationSnapshotManifest *v7 = [v2 initWithApplicationInfo:v4];
    id v8 = nil;
    if (![v7 respondsToSelector:NSSelectorFromString(@"_allSnapshotGroups")]) {
        v10 = nil;
        LogSelectorError(v7, NSSelectorFromString(@"_allSnapshotGroups"));
    } else {
        v10 = [v7 _allSnapshotGroups];
    }
    for (id v18 in v10) {
        if ([v18 respondsToSelector:NSSelectorFromString(@"snapshots")]) {
            v20 = [v18 snapshots];
        } else {
            v20 = nil;
            LogSelectorError(v18, NSSelectorFromString(@"snapshots"));
        }
        for (id v29 in v20) {
            if ([v29 respondsToSelector:NSSelectorFromString(@"interfaceOrientation")]) {
                v30 = [v29 interfaceOrientation];
            } else {
                v30 = UIInterfaceOrientationUnknown;
                LogSelectorError(v29, NSSelectorFromString(@"interfaceOrientation"));
            }
            if ([v29 respondsToSelector:NSSelectorFromString(@"contentType")]) {
                v32 = [v29 contentType];
            } else {
                v32 = 0;
                LogSelectorError(v29, NSSelectorFromString(@"contentType"));
            }
            if (UIInterfaceOrientationIsLandscape(v30)) {
                if (v8 == nil && !v32) {
                    if ([v29 respondsToSelector:NSSelectorFromString(@"name")]) {
                        v36 = [v29 name];
                    } else {
                        v36 = nil;
                        LogSelectorError(v29, NSSelectorFromString(@"name"));
                    }
                    if ([v36 isEqualToString:@"CarPlayLaunchImage"]) {
                        v8 = v29;
                        goto blk_e518;
                    }
                }
                bool v39 = true;
                if (v32 != 1) {
                    v39 = v32 == 2;
                }
                if (v39) {
                    v8 = v29;
                    goto blk_e518;
                }
            }
            if (!v8) {
                v8 = v29;
            }
        }
        continue;
blk_e518:
    }
    SEL v42 = NSSelectorFromString(@"interfaceOrientation");
    if (![v8 respondsToSelector:v42]) {
        v43 = UIInterfaceOrientationUnknown;
        LogSelectorError(v8, NSSelectorFromString(@"interfaceOrientation"));
    } else {
        v43 = [v8 interfaceOrientation];
    }
    BOOL v44 = UIInterfaceOrientationIsPortrait(v43);
    [self setShouldGenerateSnapshot:v44];
    UIImage *v45 = [v8 imageForInterfaceOrientation:1];
    UIImageView *v46 = [UIImageView alloc];
    UIView *appContainerView = [self appContainerView];
    CGRect frame = [appContainerView frame];
    UIView *appContainerView2 = [self appContainerView];
    CGRect frame2 = [appContainerView2 frame];
    [self setLaunchImageView:[v46 initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame2.size.height)]];
    UIImageView *launchImageView = [self launchImageView];
    [launchImageView setImage:v45];
    UIImageView *launchImageView2 = [self launchImageView];
    [launchImageView2 setContentMode:UIViewContentModeScaleToFill];
    UIView *appContainerView3 = [self appContainerView];
    UIImageView *launchImageView3 = [self launchImageView];
    [appContainerView3 addSubview:launchImageView3];
}


void -[CRCarPlayWindow setupLiveAppView](void)
{
    NSString *v2;
    id v7;
    id v10;
    id v13;
    bool v19;
    Class v20;
    id v21;
    id v22;
    bool v23;
    id v24;
    bool v25;
    SBDeviceApplicationSceneEntity *v26;
    bool v27;
    id v30;
    id v32;
    id v33;
    id v34;
    id v35;
    id v36;
    id v37;
    id v38;
    id v39;
    id v40;
    UIView *v41;
    id v42;
    id v43;
    SEL v44;
    id v45;
    id v46;
    id v47;
    bool v48;
    id v50;
    id v53;
    id v54;
    id v55;
    id v56;
    bool v57;
    id v58;
    id v59;
    id v60;
    id v61;
    id v62;
    UIView *v63;
    UIColor *v64;
    long v65;
    SEL v66;
    id v68;
    id v31;
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow setupLiveAppView]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    id application = [self application];
    if (![application respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        v2 = nil;
        id application4 = [self application];
        LogSelectorError(application4, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        id application5 = [self application];
        v2 = [application5 bundleIdentifier];
    }
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    id v6 = objc_getAssociatedObject(sharedApplication, NSSelectorFromString(@"lockAssertions"));
    [v6 addObject:v2];
    if (![objc_getClass("SBSceneManagerCoordinator") respondsToSelector:NSSelectorFromString(@"mainDisplaySceneManager")]) {
        v7 = nil;
        LogSelectorError(objc_getClass("SBSceneManagerCoordinator"), NSSelectorFromString(@"mainDisplaySceneManager"));
    } else {
        v7 = [objc_getClass("SBSceneManagerCoordinator") mainDisplaySceneManager];
    }
    if (!v7) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplaySceneManager", v7];
    } else if ([v7 isKindOfClass:NSClassFromString(@"SBMainDisplaySceneManager")]) {
        SEL v9 = NSSelectorFromString(@"_layoutStateManager");
        if (![v7 respondsToSelector:v9]) {
            v10 = nil;
            LogSelectorError(v7, NSSelectorFromString(@"_layoutStateManager"));
        } else {
            v10 = [v7 _layoutStateManager];
        }
        if (!v10) {
            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplayLayoutStateManager", v10];
        } else if ([v10 isKindOfClass:NSClassFromString(@"SBMainDisplayLayoutStateManager")]) {
            SEL v12 = NSSelectorFromString(@"displayIdentity");
            if (![v7 respondsToSelector:v12]) {
                v13 = nil;
                LogSelectorError(v7, NSSelectorFromString(@"displayIdentity"));
            } else {
                v13 = [v7 displayIdentity];
            }
            if (!v13) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSDisplayIdentity", v13];
            } else if ([v13 isKindOfClass:NSClassFromString(@"FBSDisplayIdentity")]) {
                id v15 = nil;
                SEL v16 = NSSelectorFromString(@"_sceneIdentityForApplication:createPrimaryIfRequired:");
                if ([v7 respondsToSelector:v16]) {
                    id application2 = [self application];
                    v15 = [v7 _sceneIdentityForApplication:application2 createPrimaryIfRequired:1];
                    v19 = !v15;
                    if (v19) {
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
                    } else if ([v15 isKindOfClass:NSClassFromString(@"FBSSceneIdentity")]) {
                        v20 = objc_getClass("SBApplicationSceneHandleRequest");
                        v21 = [self application];
                        v22 = [v20 defaultRequestForApplication:v21 sceneIdentity:v15 displayIdentity:v13];
                        v23 = !v22;
                        if (v23) {
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                        } else if ([v22 isKindOfClass:NSClassFromString(@"SBApplicationSceneHandleRequest")]) {
                            v24 = [v7 fetchOrCreateApplicationSceneHandleForRequest:v22];
                            v25 = !v24;
                            if (v25) {
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                            } else if ([v24 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneHandle")]) {
                                v26 = [[objc_getClass("SBDeviceApplicationSceneEntity") alloc] initWithApplicationSceneHandle:v24];
                                v27 = !v26;
                                if (v27) {
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                                } else if ([v26 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneEntity")]) {
                                    [self setAppViewController:[[objc_getClass("SBAppViewController") alloc] initWithIdentifier:v2 andApplicationSceneEntity:v26]];
                                    if (![self appViewController] || ![(v31 = [self appViewController]) isKindOfClass:NSClassFromString(@"SBAppViewController")]) {
                                        v30 = [self appViewController];
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBAppViewController", v30];
                                    }
                                    v32 = [self appViewController];
                                    [v32 setIgnoresOcclusions:0];
                                    v33 = [self appViewController];
                                    [v33 setValue:@2 forKey:@"_currentMode"];
                                    v34 = [self appViewController];
                                    v35 = [v34 valueForKey:@"_activationSettings"];
                                    if (![v35 respondsToSelector:NSSelectorFromString(@"clearActivationSettings")]) {
                                        v36 = [self appViewController];
                                        v37 = [v36 valueForKey:@"_activationSettings"];
                                        LogSelectorError(v37, NSSelectorFromString(@"clearActivationSettings"));
                                    } else {
                                        v38 = [self appViewController];
                                        v39 = [v38 valueForKey:@"_activationSettings"];
                                        [v39 clearActivationSettings];
                                    }
                                    v40 = [self appViewController];
                                    if (![v40 respondsToSelector:NSSelectorFromString(@"view")]) {
                                        v41 = nil;
                                        v42 = [self appViewController];
                                        LogSelectorError(v42, NSSelectorFromString(@"view"));
                                    } else {
                                        v43 = [self appViewController];
                                        v41 = [v43 view];
                                    }
                                    v44 = NSSelectorFromString(@"recursiveDescription");
                                    if (![v41 respondsToSelector:v44]) {
                                        v45 = nil;
                                        LogSelectorError(v41, NSSelectorFromString(@"recursiveDescription"));
                                    } else {
                                        v45 = [v41 recursiveDescription];
                                    }
                                    NSLog(@"carplayenable appviewcontroller view recursive description: %@", v45);
                                    v46 = [self appViewController];
                                    v47 = [v46 _createSceneUpdateTransactionForApplicationSceneEntity:v26 deliveringActions:1];
                                    v48 = !v47;
                                    if (v48) {
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                                    } else if ([v47 isKindOfClass:NSClassFromString(@"SBApplicationSceneUpdateTransaction")]) {
                                        v50 = [self appViewController];
                                        __block id v49 = [v50 valueForKey:@"_activeTransitions"];
                                        [v47 setCompletionBlock:^void(int arg1) {
                                            id v70;
                                            [v49 removeObject:v47];
                                            id v69 = [v47 valueForKey:@"_processLaunchTransaction"];
                                            if (!v69) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v69];
                                            } else if (![v69 isKindOfClass:NSClassFromString(@"FBApplicationProcessLaunchTransaction")]) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v69];
                                            }
                                            if (![v69 respondsToSelector:NSSelectorFromString(@"process")]) {
                                                v70 = nil;
                                                LogSelectorError(v69, NSSelectorFromString(@"process"));
                                            } else {
                                                v70 = [v69 process];
                                            }
                                            if (!v70) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v70];
                                            } else if (![v70 isKindOfClass:NSClassFromString(@"FBProcess")]) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v70];
                                            }
                                            [v70 _executeBlockAfterLaunchCompletes:^void(void) {
                                                dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
                                                dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
                                                    id v77;
                                                    id v80;
                                                    id v14;
                                                    id v78;
                                                    UIImageView *launchImageView = [self launchImageView];
                                                    [launchImageView removeFromSuperview];
                                                    if ([self shouldGenerateSnapshot]) {
                                                        if (![v24 respondsToSelector:NSSelectorFromString(@"sceneIfExists")]) {
                                                            v77 = nil;
                                                            LogSelectorError(v24, NSSelectorFromString(@"sceneIfExists"));
                                                        } else {
                                                            v77 = [v24 sceneIfExists];
                                                        }
                                                        if (v77 != nil) {
                                                            if (![v77 respondsToSelector:NSSelectorFromString(@"settings")]) {
                                                                v80 = nil;
                                                                LogSelectorError(v77, NSSelectorFromString(@"settings"));
                                                            } else {
                                                                v80 = [v77 settings];
                                                            }
                                                            if (![v80 respondsToSelector:NSSelectorFromString(@"mutableCopy")]) {
                                                                v14 = nil;
                                                                LogSelectorError(v80, NSSelectorFromString(@"mutableCopy"));
                                                            } else {
                                                                v14 = [v80 mutableCopy];
                                                            }
                                                            if (!v14) {
                                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                            } else if (![v14 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                            }
                                                            int orientation = [self orientation];
                                                            [v14 setInterfaceOrientation:orientation];
                                                            Class v8 = objc_getClass("FBSSceneSnapshotContext");
                                                            if (![v77 respondsToSelector:NSSelectorFromString(@"identifier")]) {
                                                                v78 = nil;
                                                                LogSelectorError(v77, NSSelectorFromString(@"identifier"));
                                                            } else {
                                                                v78 = [v77 identifier];
                                                            }
                                                            id v79 = [v8 contextWithSceneID:v78 settings:v14];
                                                            [v79 setName:@"CarPlayLaunchImage"];
                                                            [v79 setScale:2];
                                                            [v79 setExpirationInterval:99999];
                                                            id application = [self application];
                                                            [application saveSnapshotForSceneHandle:v24 context:v79 completion:0];
                                                        }
                                                        return;
                                                    }
                                                });
                                                Class v72 = objc_getClass("NSDistributedNotificationCenter");
                                                NSDistributedNotificationCenter *defaultCenter = [v72 defaultCenter];
                                                int orientation = [self orientation];
                                                NSNumber *v75 = [NSNumber numberWithInt:orientation];
                                                [defaultCenter postNotificationName:@"com.carplayenable.orientation" object:v2 userInfo:@{@"orientation": v75}];
                                            }];
                                        }];
                                        [v49 addObject:v47];
                                        if (![v47 respondsToSelector:NSSelectorFromString(@"begin")]) {
                                            LogSelectorError(v47, NSSelectorFromString(@"begin"));
                                        } else {
                                            [v47 begin];
                                        }
                                        v53 = [self appViewController];
                                        if (![v53 respondsToSelector:NSSelectorFromString(@"_createSceneViewController")]) {
                                            v54 = [self appViewController];
                                            LogSelectorError(v54, NSSelectorFromString(@"_createSceneViewController"));
                                        } else {
                                            v55 = [self appViewController];
                                            [v55 _createSceneViewController];
                                        }
                                        if (![objc_getClass("SBApplicationSceneView") respondsToSelector:NSSelectorFromString(@"defaultDisplayModeAnimationFactory")]) {
                                            LogSelectorError(objc_getClass("SBApplicationSceneView"), NSSelectorFromString(@"defaultDisplayModeAnimationFactory"));
                                            v56 = nil;
                                        } else {
                                            v56 = [objc_getClass("SBApplicationSceneView") defaultDisplayModeAnimationFactory];
                                        }
                                        v57 = !v56;
                                        if (v57) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                        } else if ([v56 isKindOfClass:NSClassFromString(@"BSUIAnimationFactory")]) {
                                            v58 = [self appViewController];
                                            if (![v58 respondsToSelector:NSSelectorFromString(@"appView")]) {
                                                v59 = [self appViewController];
                                                LogSelectorError(v59, NSSelectorFromString(@"appView"));
                                                v60 = nil;
                                            } else {
                                                v61 = [self appViewController];
                                                v60 = [v61 appView];
                                            }
                                            [v60 setDisplayMode:4 animationFactory:v56 completion:0];
                                            v62 = [self appViewController];
                                            v63 = [v62 view];
                                            v64 = [UIColor clearColor];
                                            [v63 setBackgroundColor:v64];
                                            v65 = 0;
                                            v66 = NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:");
                                            if (![v10 respondsToSelector:v66]) {
                                                if (![v10 respondsToSelector:NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:sceneSessionRole:")]) {
                                                    [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                                    v68 = [self sceneMonitor];
                                                    [v68 setDelegate:self];
                                                    return;
                                                }
                                                v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
                                            } else {
                                                v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2];
                                            }
                                            [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                            v68 = [self sceneMonitor];
                                            [v68 setDelegate:self];
                                            return;
                                        }
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                    }
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                                }
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                            }
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                        }
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                    }
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
                }
                if (![v7 respondsToSelector:NSSelectorFromString(@"_sceneIdentityForApplication:createPrimaryIfRequired:sceneSessionRole:")]) {
                    v19 = !v15;
                    if (v19) {
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
                    } else if ([v15 isKindOfClass:NSClassFromString(@"FBSSceneIdentity")]) {
                        v20 = objc_getClass("SBApplicationSceneHandleRequest");
                        v21 = [self application];
                        v22 = [v20 defaultRequestForApplication:v21 sceneIdentity:v15 displayIdentity:v13];
                        v23 = !v22;
                        if (v23) {
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                        } else if ([v22 isKindOfClass:NSClassFromString(@"SBApplicationSceneHandleRequest")]) {
                            v24 = [v7 fetchOrCreateApplicationSceneHandleForRequest:v22];
                            v25 = !v24;
                            if (v25) {
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                            } else if ([v24 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneHandle")]) {
                                v26 = [[objc_getClass("SBDeviceApplicationSceneEntity") alloc] initWithApplicationSceneHandle:v24];
                                v27 = !v26;
                                if (v27) {
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                                } else if ([v26 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneEntity")]) {
                                    [self setAppViewController:[[objc_getClass("SBAppViewController") alloc] initWithIdentifier:v2 andApplicationSceneEntity:v26]];
                                    if (![self appViewController] || ![(v31 = [self appViewController]) isKindOfClass:NSClassFromString(@"SBAppViewController")]) {
                                        v30 = [self appViewController];
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBAppViewController", v30];
                                    }
                                    v32 = [self appViewController];
                                    [v32 setIgnoresOcclusions:0];
                                    v33 = [self appViewController];
                                    [v33 setValue:@2 forKey:@"_currentMode"];
                                    v34 = [self appViewController];
                                    v35 = [v34 valueForKey:@"_activationSettings"];
                                    if (![v35 respondsToSelector:NSSelectorFromString(@"clearActivationSettings")]) {
                                        v36 = [self appViewController];
                                        v37 = [v36 valueForKey:@"_activationSettings"];
                                        LogSelectorError(v37, NSSelectorFromString(@"clearActivationSettings"));
                                    } else {
                                        v38 = [self appViewController];
                                        v39 = [v38 valueForKey:@"_activationSettings"];
                                        [v39 clearActivationSettings];
                                    }
                                    v40 = [self appViewController];
                                    if (![v40 respondsToSelector:NSSelectorFromString(@"view")]) {
                                        v41 = nil;
                                        v42 = [self appViewController];
                                        LogSelectorError(v42, NSSelectorFromString(@"view"));
                                    } else {
                                        v43 = [self appViewController];
                                        v41 = [v43 view];
                                    }
                                    v44 = NSSelectorFromString(@"recursiveDescription");
                                    if (![v41 respondsToSelector:v44]) {
                                        v45 = nil;
                                        LogSelectorError(v41, NSSelectorFromString(@"recursiveDescription"));
                                    } else {
                                        v45 = [v41 recursiveDescription];
                                    }
                                    NSLog(@"carplayenable appviewcontroller view recursive description: %@", v45);
                                    v46 = [self appViewController];
                                    v47 = [v46 _createSceneUpdateTransactionForApplicationSceneEntity:v26 deliveringActions:1];
                                    v48 = !v47;
                                    if (v48) {
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                                    } else if ([v47 isKindOfClass:NSClassFromString(@"SBApplicationSceneUpdateTransaction")]) {
                                        v50 = [self appViewController];
                                        __block id byref1 = [v50 valueForKey:@"_activeTransitions"];
                                        [v47 setCompletionBlock:^void(int arg1) {
                                            id v83;
                                            [byref1 removeObject:v47];
                                            id v82 = [v47 valueForKey:@"_processLaunchTransaction"];
                                            if (!v82) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v82];
                                            } else if (![v82 isKindOfClass:NSClassFromString(@"FBApplicationProcessLaunchTransaction")]) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v82];
                                            }
                                            if (![v82 respondsToSelector:NSSelectorFromString(@"process")]) {
                                                v83 = nil;
                                                LogSelectorError(v82, NSSelectorFromString(@"process"));
                                            } else {
                                                v83 = [v82 process];
                                            }
                                            if (!v83) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v83];
                                            } else if (![v83 isKindOfClass:NSClassFromString(@"FBProcess")]) {
                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v83];
                                            }
                                            [v83 _executeBlockAfterLaunchCompletes:^void(void) {
                                                dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
                                                dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
                                                    id v90;
                                                    id v93;
                                                    id v14;
                                                    id v91;
                                                    UIImageView *launchImageView = [self launchImageView];
                                                    [launchImageView removeFromSuperview];
                                                    if ([self shouldGenerateSnapshot]) {
                                                        if (![v24 respondsToSelector:NSSelectorFromString(@"sceneIfExists")]) {
                                                            v90 = nil;
                                                            LogSelectorError(v24, NSSelectorFromString(@"sceneIfExists"));
                                                        } else {
                                                            v90 = [v24 sceneIfExists];
                                                        }
                                                        if (v90 != nil) {
                                                            if (![v90 respondsToSelector:NSSelectorFromString(@"settings")]) {
                                                                v93 = nil;
                                                                LogSelectorError(v90, NSSelectorFromString(@"settings"));
                                                            } else {
                                                                v93 = [v90 settings];
                                                            }
                                                            if (![v93 respondsToSelector:NSSelectorFromString(@"mutableCopy")]) {
                                                                v14 = nil;
                                                                LogSelectorError(v93, NSSelectorFromString(@"mutableCopy"));
                                                            } else {
                                                                v14 = [v93 mutableCopy];
                                                            }
                                                            if (!v14) {
                                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                            } else if (![v14 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                                                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                            }
                                                            int orientation = [self orientation];
                                                            [v14 setInterfaceOrientation:orientation];
                                                            Class v8 = objc_getClass("FBSSceneSnapshotContext");
                                                            if (![v90 respondsToSelector:NSSelectorFromString(@"identifier")]) {
                                                                v91 = nil;
                                                                LogSelectorError(v90, NSSelectorFromString(@"identifier"));
                                                            } else {
                                                                v91 = [v90 identifier];
                                                            }
                                                            id v92 = [v8 contextWithSceneID:v91 settings:v14];
                                                            [v92 setName:@"CarPlayLaunchImage"];
                                                            [v92 setScale:2];
                                                            [v92 setExpirationInterval:99999];
                                                            id application = [self application];
                                                            [application saveSnapshotForSceneHandle:v24 context:v92 completion:0];
                                                        }
                                                        return;
                                                    }
                                                });
                                                Class v85 = objc_getClass("NSDistributedNotificationCenter");
                                                NSDistributedNotificationCenter *defaultCenter = [v85 defaultCenter];
                                                int orientation = [self orientation];
                                                NSNumber *v88 = [NSNumber numberWithInt:orientation];
                                                [defaultCenter postNotificationName:@"com.carplayenable.orientation" object:v2 userInfo:@{@"orientation": v88}];
                                            }];
                                        }];
                                        [byref1 addObject:v47];
                                        if (![v47 respondsToSelector:NSSelectorFromString(@"begin")]) {
                                            LogSelectorError(v47, NSSelectorFromString(@"begin"));
                                        } else {
                                            [v47 begin];
                                        }
                                        v53 = [self appViewController];
                                        if (![v53 respondsToSelector:NSSelectorFromString(@"_createSceneViewController")]) {
                                            v54 = [self appViewController];
                                            LogSelectorError(v54, NSSelectorFromString(@"_createSceneViewController"));
                                        } else {
                                            v55 = [self appViewController];
                                            [v55 _createSceneViewController];
                                        }
                                        if (![objc_getClass("SBApplicationSceneView") respondsToSelector:NSSelectorFromString(@"defaultDisplayModeAnimationFactory")]) {
                                            LogSelectorError(objc_getClass("SBApplicationSceneView"), NSSelectorFromString(@"defaultDisplayModeAnimationFactory"));
                                            v56 = nil;
                                        } else {
                                            v56 = [objc_getClass("SBApplicationSceneView") defaultDisplayModeAnimationFactory];
                                        }
                                        v57 = !v56;
                                        if (v57) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                        } else if ([v56 isKindOfClass:NSClassFromString(@"BSUIAnimationFactory")]) {
                                            v58 = [self appViewController];
                                            if (![v58 respondsToSelector:NSSelectorFromString(@"appView")]) {
                                                v59 = [self appViewController];
                                                LogSelectorError(v59, NSSelectorFromString(@"appView"));
                                                v60 = nil;
                                            } else {
                                                v61 = [self appViewController];
                                                v60 = [v61 appView];
                                            }
                                            [v60 setDisplayMode:4 animationFactory:v56 completion:0];
                                            v62 = [self appViewController];
                                            v63 = [v62 view];
                                            v64 = [UIColor clearColor];
                                            [v63 setBackgroundColor:v64];
                                            v65 = 0;
                                            v66 = NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:");
                                            if (![v10 respondsToSelector:v66]) {
                                                if (![v10 respondsToSelector:NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:sceneSessionRole:")]) {
                                                    [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                                    v68 = [self sceneMonitor];
                                                    [v68 setDelegate:self];
                                                    return;
                                                }
                                                v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
                                            } else {
                                                v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2];
                                            }
                                            [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                            v68 = [self sceneMonitor];
                                            [v68 setDelegate:self];
                                            return;
                                        }
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                    }
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                                }
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                            }
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                        }
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                    }
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
                }
                id application3 = [self application];
                v15 = [v7 _sceneIdentityForApplication:application3 createPrimaryIfRequired:1 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
                v19 = !v15;
                if (v19) {
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
                } else if ([v15 isKindOfClass:NSClassFromString(@"FBSSceneIdentity")]) {
                    v20 = objc_getClass("SBApplicationSceneHandleRequest");
                    v21 = [self application];
                    v22 = [v20 defaultRequestForApplication:v21 sceneIdentity:v15 displayIdentity:v13];
                    v23 = !v22;
                    if (v23) {
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                    } else if ([v22 isKindOfClass:NSClassFromString(@"SBApplicationSceneHandleRequest")]) {
                        v24 = [v7 fetchOrCreateApplicationSceneHandleForRequest:v22];
                        v25 = !v24;
                        if (v25) {
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                        } else if ([v24 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneHandle")]) {
                            v26 = [[objc_getClass("SBDeviceApplicationSceneEntity") alloc] initWithApplicationSceneHandle:v24];
                            v27 = !v26;
                            if (v27) {
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                            } else if ([v26 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneEntity")]) {
                                [self setAppViewController:[[objc_getClass("SBAppViewController") alloc] initWithIdentifier:v2 andApplicationSceneEntity:v26]];
                                if (![self appViewController] || ![(v31 = [self appViewController]) isKindOfClass:NSClassFromString(@"SBAppViewController")]) {
                                    v30 = [self appViewController];
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBAppViewController", v30];
                                }
                                v32 = [self appViewController];
                                [v32 setIgnoresOcclusions:0];
                                v33 = [self appViewController];
                                [v33 setValue:@2 forKey:@"_currentMode"];
                                v34 = [self appViewController];
                                v35 = [v34 valueForKey:@"_activationSettings"];
                                if (![v35 respondsToSelector:NSSelectorFromString(@"clearActivationSettings")]) {
                                    v36 = [self appViewController];
                                    v37 = [v36 valueForKey:@"_activationSettings"];
                                    LogSelectorError(v37, NSSelectorFromString(@"clearActivationSettings"));
                                } else {
                                    v38 = [self appViewController];
                                    v39 = [v38 valueForKey:@"_activationSettings"];
                                    [v39 clearActivationSettings];
                                }
                                v40 = [self appViewController];
                                if (![v40 respondsToSelector:NSSelectorFromString(@"view")]) {
                                    v41 = nil;
                                    v42 = [self appViewController];
                                    LogSelectorError(v42, NSSelectorFromString(@"view"));
                                } else {
                                    v43 = [self appViewController];
                                    v41 = [v43 view];
                                }
                                v44 = NSSelectorFromString(@"recursiveDescription");
                                if (![v41 respondsToSelector:v44]) {
                                    v45 = nil;
                                    LogSelectorError(v41, NSSelectorFromString(@"recursiveDescription"));
                                } else {
                                    v45 = [v41 recursiveDescription];
                                }
                                NSLog(@"carplayenable appviewcontroller view recursive description: %@", v45);
                                v46 = [self appViewController];
                                v47 = [v46 _createSceneUpdateTransactionForApplicationSceneEntity:v26 deliveringActions:1];
                                v48 = !v47;
                                if (v48) {
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                                } else if ([v47 isKindOfClass:NSClassFromString(@"SBApplicationSceneUpdateTransaction")]) {
                                    v50 = [self appViewController];
                                    __block id byref2 = [v50 valueForKey:@"_activeTransitions"];
                                    [v47 setCompletionBlock:^void(int arg1) {
                                        id v96;
                                        [byref2 removeObject:v47];
                                        id v95 = [v47 valueForKey:@"_processLaunchTransaction"];
                                        if (!v95) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v95];
                                        } else if (![v95 isKindOfClass:NSClassFromString(@"FBApplicationProcessLaunchTransaction")]) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v95];
                                        }
                                        if (![v95 respondsToSelector:NSSelectorFromString(@"process")]) {
                                            v96 = nil;
                                            LogSelectorError(v95, NSSelectorFromString(@"process"));
                                        } else {
                                            v96 = [v95 process];
                                        }
                                        if (!v96) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v96];
                                        } else if (![v96 isKindOfClass:NSClassFromString(@"FBProcess")]) {
                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBProcess", v96];
                                        }
                                        [v96 _executeBlockAfterLaunchCompletes:^void(void) {
                                            dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
                                            dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
                                                id v103;
                                                id v106;
                                                id v14;
                                                id v104;
                                                UIImageView *launchImageView = [self launchImageView];
                                                [launchImageView removeFromSuperview];
                                                if ([self shouldGenerateSnapshot]) {
                                                    if (![v24 respondsToSelector:NSSelectorFromString(@"sceneIfExists")]) {
                                                        v103 = nil;
                                                        LogSelectorError(v24, NSSelectorFromString(@"sceneIfExists"));
                                                    } else {
                                                        v103 = [v24 sceneIfExists];
                                                    }
                                                    if (v103 != nil) {
                                                        if (![v103 respondsToSelector:NSSelectorFromString(@"settings")]) {
                                                            v106 = nil;
                                                            LogSelectorError(v103, NSSelectorFromString(@"settings"));
                                                        } else {
                                                            v106 = [v103 settings];
                                                        }
                                                        if (![v106 respondsToSelector:NSSelectorFromString(@"mutableCopy")]) {
                                                            v14 = nil;
                                                            LogSelectorError(v106, NSSelectorFromString(@"mutableCopy"));
                                                        } else {
                                                            v14 = [v106 mutableCopy];
                                                        }
                                                        if (!v14) {
                                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                        } else if (![v14 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                                                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v14];
                                                        }
                                                        int orientation = [self orientation];
                                                        [v14 setInterfaceOrientation:orientation];
                                                        Class v8 = objc_getClass("FBSSceneSnapshotContext");
                                                        if (![v103 respondsToSelector:NSSelectorFromString(@"identifier")]) {
                                                            v104 = nil;
                                                            LogSelectorError(v103, NSSelectorFromString(@"identifier"));
                                                        } else {
                                                            v104 = [v103 identifier];
                                                        }
                                                        id v105 = [v8 contextWithSceneID:v104 settings:v14];
                                                        [v105 setName:@"CarPlayLaunchImage"];
                                                        [v105 setScale:2];
                                                        [v105 setExpirationInterval:99999];
                                                        id application = [self application];
                                                        [application saveSnapshotForSceneHandle:v24 context:v105 completion:0];
                                                    }
                                                    return;
                                                }
                                            });
                                            Class v98 = objc_getClass("NSDistributedNotificationCenter");
                                            NSDistributedNotificationCenter *defaultCenter = [v98 defaultCenter];
                                            int orientation = [self orientation];
                                            NSNumber *v101 = [NSNumber numberWithInt:orientation];
                                            [defaultCenter postNotificationName:@"com.carplayenable.orientation" object:v2 userInfo:@{@"orientation": v101}];
                                        }];
                                    }];
                                    [byref2 addObject:v47];
                                    if (![v47 respondsToSelector:NSSelectorFromString(@"begin")]) {
                                        LogSelectorError(v47, NSSelectorFromString(@"begin"));
                                    } else {
                                        [v47 begin];
                                    }
                                    v53 = [self appViewController];
                                    if (![v53 respondsToSelector:NSSelectorFromString(@"_createSceneViewController")]) {
                                        v54 = [self appViewController];
                                        LogSelectorError(v54, NSSelectorFromString(@"_createSceneViewController"));
                                    } else {
                                        v55 = [self appViewController];
                                        [v55 _createSceneViewController];
                                    }
                                    if (![objc_getClass("SBApplicationSceneView") respondsToSelector:NSSelectorFromString(@"defaultDisplayModeAnimationFactory")]) {
                                        LogSelectorError(objc_getClass("SBApplicationSceneView"), NSSelectorFromString(@"defaultDisplayModeAnimationFactory"));
                                        v56 = nil;
                                    } else {
                                        v56 = [objc_getClass("SBApplicationSceneView") defaultDisplayModeAnimationFactory];
                                    }
                                    v57 = !v56;
                                    if (v57) {
                                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                    } else if ([v56 isKindOfClass:NSClassFromString(@"BSUIAnimationFactory")]) {
                                        v58 = [self appViewController];
                                        if (![v58 respondsToSelector:NSSelectorFromString(@"appView")]) {
                                            v59 = [self appViewController];
                                            LogSelectorError(v59, NSSelectorFromString(@"appView"));
                                            v60 = nil;
                                        } else {
                                            v61 = [self appViewController];
                                            v60 = [v61 appView];
                                        }
                                        [v60 setDisplayMode:4 animationFactory:v56 completion:0];
                                        v62 = [self appViewController];
                                        v63 = [v62 view];
                                        v64 = [UIColor clearColor];
                                        [v63 setBackgroundColor:v64];
                                        v65 = 0;
                                        v66 = NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:");
                                        if (![v10 respondsToSelector:v66]) {
                                            if (![v10 respondsToSelector:NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:sceneSessionRole:")]) {
                                                [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                                v68 = [self sceneMonitor];
                                                [v68 setDelegate:self];
                                                return;
                                            }
                                            v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
                                        } else {
                                            v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2];
                                        }
                                        [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
                                        v68 = [self sceneMonitor];
                                        [v68 setDelegate:self];
                                        return;
                                    }
                                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
                                }
                                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
                            }
                            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
                        }
                        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
                    }
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
                }
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
            }
            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSDisplayIdentity", v13];
        }
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplayLayoutStateManager", v10];
    }
    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplaySceneManager", v7];
}


void -[CRCarPlayWindow sceneMonitor:sceneWasDestroyed:](id a1, id a2)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow sceneMonitor:sceneWasDestroyed:]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    SEL v1 = NSSelectorFromString(@"dismiss");
    if (![self respondsToSelector:v1]) {
        LogSelectorError(self, NSSelectorFromString(@"dismiss"));
    } else {
        [self dismiss];
    }
}


void -[CRCarPlayWindow handleScreenTapped](void)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow handleScreenTapped]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    if (self->_isFullscreen) {
        [self exitFullscreen];
    }
}


void -[CRCarPlayWindow exitFullscreen](void)
{
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow exitFullscreen]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    if (!self->_isFullscreen) {
        return;
    }
    int orientation = [self orientation];
    [self resizeAppViewForOrientation:orientation fullscreen:NO forceUpdate:NO];
}


void -[CRCarPlayWindow enterFullscreen](void)
{
    NSString *v1 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow enterFullscreen]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v1);
    if (UIInterfaceOrientationIsPortrait([self orientation])) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^void(void) {
        int orientation = [self orientation];
        [self resizeAppViewForOrientation:orientation fullscreen:YES forceUpdate:NO];
    } completion:nil];
}


void -[CRCarPlayWindow dismiss](void)
{
    id v17;
    id v20;
    id v25;
    long v28;
    id v30;
    NSString *v2 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow dismiss]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v2);
    id sceneMonitor = [self sceneMonitor];
    [sceneMonitor invalidate];
    for (id v1 in self->_observers) {
        NSDistributedNotificationCenter *defaultCenter = [objc_getClass("NSDistributedNotificationCenter") defaultCenter];
        [defaultCenter removeObserver:v1];
    }
    if (![objc_getClass("_UISystemGestureManager") respondsToSelector:NSSelectorFromString(@"sharedInstance")]) {
        v17 = nil;
        LogSelectorError(objc_getClass("_UISystemGestureManager"), NSSelectorFromString(@"sharedInstance"));
    } else {
        v17 = [objc_getClass("_UISystemGestureManager") sharedInstance];
    }
    UIWindow *rootWindow = [self rootWindow];
    if (![rootWindow respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
        v20 = nil;
        UIWindow *rootWindow2 = [self rootWindow];
        LogSelectorError(rootWindow2, NSSelectorFromString(@"displayConfiguration"));
    } else {
        UIWindow *rootWindow3 = [self rootWindow];
        v20 = [rootWindow3 displayConfiguration];
    }
    SEL v23 = NSSelectorFromString(@"identity");
    if (![v20 respondsToSelector:v23]) {
        UIWindow *rootWindow4 = [self rootWindow];
        if (![rootWindow4 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
            v25 = nil;
            UIWindow *rootWindow5 = [self rootWindow];
            LogSelectorError(rootWindow5, NSSelectorFromString(@"displayConfiguration"));
        } else {
            UIWindow *rootWindow6 = [self rootWindow];
            v25 = [rootWindow6 displayConfiguration];
        }
        v28 = 0;
        LogSelectorError(v25, NSSelectorFromString(@"identity"));
    } else {
        UIWindow *rootWindow7 = [self rootWindow];
        if (![rootWindow7 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
            v30 = nil;
            UIWindow *rootWindow8 = [self rootWindow];
            LogSelectorError(rootWindow8, NSSelectorFromString(@"displayConfiguration"));
        } else {
            UIWindow *rootWindow9 = [self rootWindow];
            v30 = [rootWindow9 displayConfiguration];
        }
        v28 = [v30 identity];
    }
    [v17 removeGestureRecognizer:self->_screenTapRecognizer fromDisplayWithIdentity:v28];
    void (^v18)(void) = ^void(void) {
        uint8_t v83[48];
        id v13;
        id v16;
        id v86;
        id v87;
        id v88;
        id v90;
        id v37;
        id v42;
        id v45;
        id v47;
        id v52;
        id v54;
        id v55;
        id v56;
        id v58;
        id v59;
        id v60;
        id v61;
        NSString *v62;
        id v63;
        id v64;
        id v65;
        id v66;
        id v67;
        SEL v72;
        id v73;
        SEL v74;
        id v75;
        bool v76;
        NSString *v71;
        BOOL v78;
        *(uint32_t *)&v83[44] = -1;
        id appViewController14 = [self appViewController];
        NSString *anObject = [appViewController14 valueForKey:@"_identifier"];
        Class v5 = objc_getClass("NSDistributedNotificationCenter");
        NSDistributedNotificationCenter *defaultCenter = [v5 defaultCenter];
        NSDictionary<NSString *, NSNumber *> *aUserInfo = @{@"orientation": [NSNumber numberWithInt:*(uint32_t *)&v83[44]]};
        [defaultCenter postNotificationName:@"com.carplayenable.orientation" object:anObject userInfo:aUserInfo];
        UIWindow *rootWindow = [self rootWindow];
        [rootWindow setHidden:YES];
        id appViewController = [self appViewController];
        [appViewController _setCurrentMode:0];
        id appViewController2 = [self appViewController];
        if (![appViewController2 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
            v13 = nil;
            id appViewController13 = [self appViewController];
            LogSelectorError(appViewController13, NSSelectorFromString(@"sceneHandle"));
        } else {
            id appViewController3 = [self appViewController];
            v13 = [appViewController3 sceneHandle];
        }
        if (![objc_getClass("SBMainDisplaySceneLayoutViewController") respondsToSelector:NSSelectorFromString(@"mainDisplaySceneLayoutViewController")]) {
            v16 = nil;
            LogSelectorError(objc_getClass("SBMainDisplaySceneLayoutViewController"), NSSelectorFromString(@"mainDisplaySceneLayoutViewController"));
        } else {
            v16 = [objc_getClass("SBMainDisplaySceneLayoutViewController") mainDisplaySceneLayoutViewController];
        }
        SEL v85 = NSSelectorFromString(@"appViewControllers");
        if (![v16 respondsToSelector:v85]) {
            v86 = nil;
            LogSelectorError(v16, NSSelectorFromString(@"appViewControllers"));
        } else {
            v86 = [v16 appViewControllers];
        }
        for (id v83 in v86) {
            if ([v83 respondsToSelector:NSSelectorFromString(@"_applicationSceneViewController")]) {
                v87 = [v83 _applicationSceneViewController];
            } else {
                v87 = nil;
                LogSelectorError(v83, NSSelectorFromString(@"_applicationSceneViewController"));
            }
            if ([v87 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
                v88 = [v87 _sceneView];
            } else {
                v88 = nil;
                LogSelectorError(v87, NSSelectorFromString(@"_sceneView"));
            }
            if ([v88 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v90 = [v88 sceneHandle];
            } else {
                v90 = nil;
                LogSelectorError(v88, NSSelectorFromString(@"sceneHandle"));
            }
            if ([v90 isEqual:v13]) {
                [v88 setDisplayMode:4 animationFactory:0 completion:0];
            }
        }
        UIApplication *sharedApplication = [UIApplication sharedApplication];
        id v35 = objc_getAssociatedObject(sharedApplication, NSSelectorFromString(@"lockAssertions"));
        id appViewController4 = [self appViewController];
        if (![appViewController4 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
            v37 = nil;
            id appViewController5 = [self appViewController];
            LogSelectorError(appViewController5, NSSelectorFromString(@"sceneHandle"));
        } else {
            id appViewController6 = [self appViewController];
            v37 = [appViewController6 sceneHandle];
        }
        SEL v40 = NSSelectorFromString(@"sceneIfExists");
        if (![v37 respondsToSelector:v40]) {
            id appViewController7 = [self appViewController];
            if (![appViewController7 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v42 = nil;
                id appViewController8 = [self appViewController];
                LogSelectorError(appViewController8, NSSelectorFromString(@"sceneHandle"));
            } else {
                id appViewController9 = [self appViewController];
                v42 = [appViewController9 sceneHandle];
            }
            v45 = nil;
            LogSelectorError(v42, NSSelectorFromString(@"sceneIfExists"));
        } else {
            id appViewController10 = [self appViewController];
            if (![appViewController10 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v47 = nil;
                id appViewController11 = [self appViewController];
                LogSelectorError(appViewController11, NSSelectorFromString(@"sceneHandle"));
            } else {
                id appViewController12 = [self appViewController];
                v47 = [appViewController12 sceneHandle];
            }
            v45 = [v47 sceneIfExists];
        }
        if (v45 != nil) {
            SEL v51 = NSSelectorFromString(@"client");
            if (![v45 respondsToSelector:v51]) {
                v52 = nil;
                LogSelectorError(v45, NSSelectorFromString(@"client"));
            } else {
                v52 = [v45 client];
            }
            SEL v53 = NSSelectorFromString(@"process");
            if (![v52 respondsToSelector:v53]) {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v54 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v54 = [v45 client];
                }
                v55 = nil;
                LogSelectorError(v54, NSSelectorFromString(@"process"));
            } else {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v56 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v56 = [v45 client];
                }
                v55 = [v56 process];
            }
            SEL v57 = NSSelectorFromString(@"bundleIdentifier");
            if (![v55 respondsToSelector:v57]) {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v58 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v58 = [v45 client];
                }
                if (![v58 respondsToSelector:NSSelectorFromString(@"process")]) {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v59 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v59 = [v45 client];
                    }
                    v60 = nil;
                    LogSelectorError(v59, NSSelectorFromString(@"process"));
                } else {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v61 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v61 = [v45 client];
                    }
                    v60 = [v61 process];
                }
                v62 = nil;
                LogSelectorError(v60, NSSelectorFromString(@"bundleIdentifier"));
            } else {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v63 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v63 = [v45 client];
                }
                if (![v63 respondsToSelector:NSSelectorFromString(@"process")]) {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v64 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v64 = [v45 client];
                    }
                    v65 = nil;
                    LogSelectorError(v64, NSSelectorFromString(@"process"));
                } else {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v66 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v66 = [v45 client];
                    }
                    v65 = [v66 process];
                }
                v62 = [v65 bundleIdentifier];
            }
            [v35 removeObject:v62];
            if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_accessibilityFrontMostApplication")]) {
                v67 = nil;
                LogSelectorError(sharedApplication, NSSelectorFromString(@"_accessibilityFrontMostApplication"));
            } else {
                v67 = [sharedApplication _accessibilityFrontMostApplication];
            }
            if (!v67) {
                if (0) {
                    goto blk_12268;
                }
                v72 = NSSelectorFromString(@"settings");
                if (![v45 respondsToSelector:v72]) {
                    v73 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"settings"));
                } else {
                    v73 = [v45 settings];
                }
                v74 = NSSelectorFromString(@"mutableCopy");
                if (![v73 respondsToSelector:v74]) {
                    v75 = nil;
                    LogSelectorError(v73, NSSelectorFromString(@"mutableCopy"));
                } else {
                    v75 = [v73 mutableCopy];
                }
                v76 = !v75;
                if (v76) {
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v75];
                } else if ([v75 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                    goto blk_121bc;
                }
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v75];
            }
            SEL v70 = NSSelectorFromString(@"bundleIdentifier");
            if (![v67 respondsToSelector:v70]) {
                v71 = nil;
                LogSelectorError(v67, NSSelectorFromString(@"bundleIdentifier"));
            } else {
                v71 = [v67 bundleIdentifier];
            }
            if (![v71 isEqualToString:v62]) {
                v72 = NSSelectorFromString(@"settings");
                if (![v45 respondsToSelector:v72]) {
                    v73 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"settings"));
                } else {
                    v73 = [v45 settings];
                }
                v74 = NSSelectorFromString(@"mutableCopy");
                if (![v73 respondsToSelector:v74]) {
                    v75 = nil;
                    LogSelectorError(v73, NSSelectorFromString(@"mutableCopy"));
                } else {
                    v75 = [v73 mutableCopy];
                }
                v76 = !v75;
                if (v76) {
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v75];
                } else if ([v75 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                    goto blk_121bc;
                }
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v75];
blk_121bc:
                [v75 setBackgrounded:1];
                [v75 setForeground:0];
                NSLog(@"carplay scene is going to background withTransitionContext %@", v75);
                NSLog(@"carplay withTransitionContext %@", v45);
                [v45 updateSettings:v75 withTransitionContext:0 completion:^void(void) {
                }];
            }
        }
blk_12268:
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"isLocked")]) {
            LogSelectorError(sharedApplication, NSSelectorFromString(@"isLocked"));
            v78 = NO;
        } else {
            v78 = [sharedApplication isLocked];
        }
        if (v78 == 1) {
            float (*v80)(void) = dlsym(-2, "BKSHIDServicesGetBacklightFactor");
            if ((double)v80() < 0.2) {
                orig_BKSDisplayServicesSetScreenBlanked(1);
            }
        }
        objc_setAssociatedObject(sharedApplication, NSSelectorFromString(@"liveCarplayWindow"), nil, OBJC_ASSOCIATION_RETAIN);
        UIWindow *rootWindow2 = [self rootWindow];
        [rootWindow2 removeFromSuperview];
        [self rootWindow];
        [self setRootWindow:nil];
    };
    [UIView animateWithDuration:0.5 animations:^void(void) {
        UIWindow *rootWindow = [self rootWindow];
        [rootWindow setAlpha:0.0];
    } completion:^void(bool arg1) {
        v18();
    }];
}


void -[CRCarPlayWindow handleRotate](void)
{
    id v3;
    id v8;
    id v11;
    id v13;
    id v17;
    id v18;
    id v19;
    id v20;
    id v21;
    id v22;
    id v23;
    id v24;
    NSString *v25;
    id v26;
    id v27;
    id v28;
    id v29;
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow handleRotate]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    int v1 = (!UIInterfaceOrientationIsLandscape([self orientation])) ? 3 : 1;
    id appViewController5 = [self appViewController];
    if (![appViewController5 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
        v3 = nil;
        id appViewController6 = [self appViewController];
        LogSelectorError(appViewController6, NSSelectorFromString(@"sceneHandle"));
    } else {
        id appViewController7 = [self appViewController];
        v3 = [appViewController7 sceneHandle];
    }
    SEL v6 = NSSelectorFromString(@"sceneIfExists");
    if (![v3 respondsToSelector:v6]) {
        id appViewController8 = [self appViewController];
        if (![appViewController8 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
            v8 = nil;
            id appViewController9 = [self appViewController];
            LogSelectorError(appViewController9, NSSelectorFromString(@"sceneHandle"));
        } else {
            id appViewController = [self appViewController];
            v8 = [appViewController sceneHandle];
        }
        v11 = nil;
        LogSelectorError(v8, NSSelectorFromString(@"sceneIfExists"));
    } else {
        id appViewController2 = [self appViewController];
        if (![appViewController2 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
            v13 = nil;
            id appViewController3 = [self appViewController];
            LogSelectorError(appViewController3, NSSelectorFromString(@"sceneHandle"));
        } else {
            id appViewController4 = [self appViewController];
            v13 = [appViewController4 sceneHandle];
        }
        v11 = [v13 sceneIfExists];
    }
    if (!v11) {
        return;
    }
    if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
        v17 = nil;
        LogSelectorError(v11, NSSelectorFromString(@"client"));
    } else {
        v17 = [v11 client];
    }
    if (![v17 respondsToSelector:NSSelectorFromString(@"process")]) {
        if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
            v18 = nil;
            LogSelectorError(v11, NSSelectorFromString(@"client"));
        } else {
            v18 = [v11 client];
        }
        v19 = nil;
        LogSelectorError(v18, NSSelectorFromString(@"process"));
    } else {
        if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
            v20 = nil;
            LogSelectorError(v11, NSSelectorFromString(@"client"));
        } else {
            v20 = [v11 client];
        }
        v19 = [v20 process];
    }
    if (![v19 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
            v21 = nil;
            LogSelectorError(v11, NSSelectorFromString(@"client"));
        } else {
            v21 = [v11 client];
        }
        if (![v21 respondsToSelector:NSSelectorFromString(@"process")]) {
            if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
                v22 = nil;
                LogSelectorError(v11, NSSelectorFromString(@"client"));
            } else {
                v22 = [v11 client];
            }
            v23 = nil;
            LogSelectorError(v22, NSSelectorFromString(@"process"));
        } else {
            if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
                v24 = nil;
                LogSelectorError(v11, NSSelectorFromString(@"client"));
            } else {
                v24 = [v11 client];
            }
            v23 = [v24 process];
        }
        v25 = nil;
        LogSelectorError(v23, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
            v26 = nil;
            LogSelectorError(v11, NSSelectorFromString(@"client"));
        } else {
            v26 = [v11 client];
        }
        if (![v26 respondsToSelector:NSSelectorFromString(@"process")]) {
            if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
                v27 = nil;
                LogSelectorError(v11, NSSelectorFromString(@"client"));
            } else {
                v27 = [v11 client];
            }
            v28 = nil;
            LogSelectorError(v27, NSSelectorFromString(@"process"));
        } else {
            if (![v11 respondsToSelector:NSSelectorFromString(@"client")]) {
                v29 = nil;
                LogSelectorError(v11, NSSelectorFromString(@"client"));
            } else {
                v29 = [v11 client];
            }
            v28 = [v29 process];
        }
        v25 = [v28 bundleIdentifier];
    }
    NSDistributedNotificationCenter *defaultCenter = [objc_getClass("NSDistributedNotificationCenter") defaultCenter];
    NSDictionary<NSString *, NSNumber *> *aUserInfo = @{@"orientation": [NSNumber numberWithInt:v1]};
    [defaultCenter postNotificationName:@"com.carplayenable.orientation" object:v25 userInfo:aUserInfo];
    bool isFullscreen = [self isFullscreen];
    [self resizeAppViewForOrientation:v1 fullscreen:isFullscreen forceUpdate:NO];
}


void -[CRCarPlayWindow resizeAppViewForOrientation:fullscreen:forceUpdate:](UIInterfaceOrientation a1, bool a2, bool a3)
{
    UIScreen *v13;
    id v33;
    bool v26;
    NSString *v2 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow resizeAppViewForOrientation:fullscreen:forceUpdate:]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v2);
    if (!a3) {
        int orientation = [self orientation];
        if (a1 == orientation && (v26 = [self isFullscreen]) == a2) {
            return;
        }
    }
    NSLog(@"Resizing carplayenable app view for orientation %d, fullscreen: %d", a1, a2);
    id appViewController = [self appViewController];
    id v4 = [appViewController valueForKey:@"_deviceAppViewController"];
    id v5 = [v4 valueForKey:@"_sceneView"];
    if (!v5 || ![v5 isKindOfClass:NSClassFromString(@"SBSceneView")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBSceneView", v5];
    }
    id v7 = [v5 valueForKey:@"_sceneContentContainerView"];
    if (!self->_drawOnMainScreen) {
        NSArray<UIScreen *> *screens = [UIScreen screens];
        for (v13 in screens) {
            if ([v13 respondsToSelector:NSSelectorFromString(@"_isCarScreen")]) {
                if (([v13 _isCarScreen] & 1) != 0) {
                    goto blk_13354;
                }
            } else {
                LogSelectorError(v13, NSSelectorFromString(@"_isCarScreen"));
            }
        }
        v13 = nil;
    } else {
        v13 = [UIScreen mainScreen];
    }
blk_13354:
    NSArray<UIView *> *subviews = [v7 subviews];
    for (UIView *v32 in subviews) {
        if ([v32 respondsToSelector:NSSelectorFromString(@"recursiveDescription")]) {
            v33 = [v32 recursiveDescription];
        } else {
            v33 = nil;
            LogSelectorError(v32, NSSelectorFromString(@"recursiveDescription"));
        }
        NSLog(@"carplayenable hostingContentView view subview: %@ %@", v32, v33);
    }
    if (!v13) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIScreen", v13];
    } else if ([v13 isKindOfClass:NSClassFromString(@"UIScreen")]) {
        CGRect bounds = [v13 bounds];
        double v37 = (double)((a2) ? 0 : 40);
        CGSize v38 = CGSizeMake(bounds.size.width - v37, bounds.size.height);
        CGFloat width = v38.width;
        CGFloat height = v38.height;
        UIScreen *mainScreen = [UIScreen mainScreen];
        CGRect v42 = [mainScreen boundsForOrientation:a1];
        CGFloat v43 = v42.size.width;
        double v44 = width / v42.size.width;
        UIWindow *rootWindow = [self rootWindow];
        CGRect frame = [rootWindow frame];
        CGFloat v47 = frame.origin.x;
        if (UIInterfaceOrientationIsPortrait(a1)) {
            NSLog(@"carplayenable app is in portrait mode");
            v44 = width / 1.0 / v43;
            v47 = width / 1.0 - width * v44 / 1.0;
        }
        NSLog(@"Scaling carplayenable app view to %.2fx%.2f (target size: %.2fx%.2f)", v44, height / v42.size.height, width, height);
        id appViewController2 = [self appViewController];
        UIView *view = [appViewController2 view];
        id appViewController3 = [self appViewController];
        UIView *view2 = [appViewController3 view];
        CGRect frame2 = [view2 frame];
        [view setFrame:CGRectMake(v47, frame2.origin.y, width, height)];
        bool shouldUseRightHandDock = [self shouldUseRightHandDock];
        UIView *appContainerView = [self appContainerView];
        CGRect frame3 = [appContainerView frame];
        if (shouldUseRightHandDock) {
            v37 = 0.0;
        }
        frame3.origin.x = v37;
        [appContainerView setFrame:frame3];
        UIView *dockView = [self dockView];
        [dockView setAlpha:(double)!a2];
        [self setOrientation:a1];
        [self setIsFullscreen:a2];
        return;
    }
    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIScreen", v13];
}


BOOL -[CRCarPlayWindow shouldUseRightHandDock](void)
{
    id v7;
    CRPreferences *sharedInstance = [CRPreferences sharedInstance];
    long dockAlignment = [sharedInstance dockAlignment];
    if (!dockAlignment) {
        return NO;
    }
    if (dockAlignment == 1) {
        return YES;
    }
    if (dockAlignment != 2) {
        return NO;
    }
    id sessionStatus = [self sessionStatus];
    if (![sessionStatus respondsToSelector:NSSelectorFromString(@"session")]) {
        v7 = nil;
        id sessionStatus2 = [self sessionStatus];
        LogSelectorError(sessionStatus2, NSSelectorFromString(@"session"));
    } else {
        id sessionStatus3 = [self sessionStatus];
        v7 = [sessionStatus3 session];
    }
    BOOL boolValue = [[v7 _endpointValueForKey:@"RightHandDrive"] boolValue];
    return boolValue;
}


UIWindow *-[CRCarPlayWindow rootWindow](void)
{
    return self->_rootWindow;
}


void -[CRCarPlayWindow setRootWindow:](UIWindow *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 16);
}


UIView *-[CRCarPlayWindow dockView](void)
{
    return self->_dockView;
}


void -[CRCarPlayWindow setDockView:](UIView *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 24);
}


UIView *-[CRCarPlayWindow appContainerView](void)
{
    return self->_appContainerView;
}


void -[CRCarPlayWindow setAppContainerView:](UIView *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 32);
}


UIImageView *-[CRCarPlayWindow launchImageView](void)
{
    return self->_launchImageView;
}


void -[CRCarPlayWindow setLaunchImageView:](UIImageView *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 40);
}


UIView *-[CRCarPlayWindow fullscreenTransparentOverlay](void)
{
    return self->_fullscreenTransparentOverlay;
}


void -[CRCarPlayWindow setFullscreenTransparentOverlay:](UIView *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 48);
}


id -[CRCarPlayWindow appViewController](void)
{
    return self->_appViewController;
}


void -[CRCarPlayWindow setAppViewController:](SBAppViewController *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 56);
}


id -[CRCarPlayWindow sceneMonitor](void)
{
    return self->_sceneMonitor;
}


void -[CRCarPlayWindow setSceneMonitor:](FBSceneMonitor *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 64);
}


id -[CRCarPlayWindow application](void)
{
    return self->_application;
}


void -[CRCarPlayWindow setApplication:](id a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 72);
}


id -[CRCarPlayWindow sessionStatus](void)
{
    return self->_sessionStatus;
}


void -[CRCarPlayWindow setSessionStatus:](CARSessionStatus *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 80);
}


NSMutableArray *-[CRCarPlayWindow observers](void)
{
    return self->_observers;
}


void -[CRCarPlayWindow setObservers:](NSMutableArray *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 88);
}


UITapGestureRecognizer *-[CRCarPlayWindow screenTapRecognizer](void)
{
    return self->_screenTapRecognizer;
}


void -[CRCarPlayWindow setScreenTapRecognizer:](UITapGestureRecognizer *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 96);
}


int -[CRCarPlayWindow orientation](void)
{
    return self->_orientation;
}


void -[CRCarPlayWindow setOrientation:](int a1)
{
    self->_orientation = a1;
}


bool -[CRCarPlayWindow isFullscreen](void)
{
    return self->_isFullscreen;
}


void -[CRCarPlayWindow setIsFullscreen:](bool a1)
{
    self->_isFullscreen = a1;
}


bool -[CRCarPlayWindow shouldGenerateSnapshot](void)
{
    return self->_shouldGenerateSnapshot;
}


void -[CRCarPlayWindow setShouldGenerateSnapshot:](bool a1)
{
    self->_shouldGenerateSnapshot = a1;
}


bool -[CRCarPlayWindow drawOnMainScreen](void)
{
    return self->_drawOnMainScreen;
}


void -[CRCarPlayWindow setDrawOnMainScreen:](bool a1)
{
    self->_drawOnMainScreen = a1;
}
