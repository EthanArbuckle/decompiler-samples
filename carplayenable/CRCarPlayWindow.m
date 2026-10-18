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
    id v58;
    id v68;
    id v70;
    id v72;
    id v79;
    id v81;
    id v85;
    long v88;
    id v90;
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
            if (!v10 || ![v10 isKindOfClass:NSClassFromString(@"CADisplay")]) {
                [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"CADisplay", v10];
            }
            FBSDisplayConfiguration *v12 = [[objc_getClass("FBSDisplayConfiguration") alloc] initWithCADisplay:v10 isMainDisplay:0];
            if (!v12 || ![v12 isKindOfClass:NSClassFromString(@"FBSDisplayConfiguration")]) {
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
        if (![v57 respondsToSelector:NSSelectorFromString(@"appViewControllers")]) {
            v58 = nil;
            LogSelectorError(v57, NSSelectorFromString(@"appViewControllers"));
        } else {
            v58 = [v57 appViewControllers];
        }
        for (id v67 in v58) {
            if ([v67 respondsToSelector:NSSelectorFromString(@"_applicationSceneViewController")]) {
                v68 = [v67 _applicationSceneViewController];
            } else {
                v68 = nil;
                LogSelectorError(v67, NSSelectorFromString(@"_applicationSceneViewController"));
            }
            if ([v68 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
                v70 = [v68 _sceneView];
            } else {
                v70 = nil;
                LogSelectorError(v68, NSSelectorFromString(@"_sceneView"));
            }
            if ([v70 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v72 = [v70 sceneHandle];
            } else {
                v72 = nil;
                LogSelectorError(v70, NSSelectorFromString(@"sceneHandle"));
            }
            if ([v72 isEqual:v54]) {
                if ([v70 respondsToSelector:NSSelectorFromString(@"drawCarplayPlaceholder")]) {
                    [v70 drawCarplayPlaceholder];
                } else {
                    LogSelectorError(v70, NSSelectorFromString(@"drawCarplayPlaceholder"));
                }
            }
        }
        NSDistributedNotificationCenter *defaultCenter = [objc_getClass("NSDistributedNotificationCenter") defaultCenter];
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        id<NSObject> v78 = [defaultCenter addObserverForName:@"com.carplay.preferences.changed" object:@"dockAlignment" queue:mainQueue usingBlock:^void(NSNotification *arg1) {
            CRPreferences *sharedInstance = [CRPreferences sharedInstance];
            [sharedInstance reloadPreferences];
            [v2 setupDock];
            [v2 resizeAppViewForOrientation:v2->_orientation fullscreen:v2->_isFullscreen forceUpdate:YES];
        }];
        [v2->_observers addObject:v78];
        v2->_screenTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:v2 action:@selector(handleScreenTapped)];
        if (![objc_getClass("_UISystemGestureManager") respondsToSelector:NSSelectorFromString(@"sharedInstance")]) {
            v79 = nil;
            LogSelectorError(objc_getClass("_UISystemGestureManager"), NSSelectorFromString(@"sharedInstance"));
        } else {
            v79 = [objc_getClass("_UISystemGestureManager") sharedInstance];
        }
        UIWindow *rootWindow8 = [v2 rootWindow];
        if (![rootWindow8 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
            v81 = nil;
            UIWindow *rootWindow9 = [v2 rootWindow];
            LogSelectorError(rootWindow9, NSSelectorFromString(@"displayConfiguration"));
        } else {
            UIWindow *rootWindow10 = [v2 rootWindow];
            v81 = [rootWindow10 displayConfiguration];
        }
        if (![v81 respondsToSelector:NSSelectorFromString(@"identity")]) {
            UIWindow *rootWindow11 = [v2 rootWindow];
            if (![rootWindow11 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
                v85 = nil;
                UIWindow *rootWindow12 = [v2 rootWindow];
                LogSelectorError(rootWindow12, NSSelectorFromString(@"displayConfiguration"));
            } else {
                UIWindow *rootWindow13 = [v2 rootWindow];
                v85 = [rootWindow13 displayConfiguration];
            }
            v88 = 0;
            LogSelectorError(v85, NSSelectorFromString(@"identity"));
        } else {
            UIWindow *rootWindow14 = [v2 rootWindow];
            if (![rootWindow14 respondsToSelector:NSSelectorFromString(@"displayConfiguration")]) {
                v90 = nil;
                UIWindow *rootWindow15 = [v2 rootWindow];
                LogSelectorError(rootWindow15, NSSelectorFromString(@"displayConfiguration"));
            } else {
                UIWindow *rootWindow16 = [v2 rootWindow];
                v90 = [rootWindow16 displayConfiguration];
            }
            v88 = [v90 identity];
        }
        [v79 addGestureRecognizer:v2->_screenTapRecognizer toDisplayWithIdentity:v88];
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
    if (!v3 || ![v3 isKindOfClass:NSClassFromString(@"CRSUIWallpaper")]) {
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
    UIView *v41;
    id v45;
    id v56;
    id v60;
    id v31;
    NSString *v0 = [NSString stringWithFormat:@"%s", "-[CRCarPlayWindow setupLiveAppView]"];
    NSLog(@"carplayenable LOG_LIFECYCLE_EVENT %@", v0);
    id application = [self application];
    if (![application respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
        v2 = nil;
        id application5 = [self application];
        LogSelectorError(application5, NSSelectorFromString(@"bundleIdentifier"));
    } else {
        id application6 = [self application];
        v2 = [application6 bundleIdentifier];
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
    if (!v7 || ![v7 isKindOfClass:NSClassFromString(@"SBMainDisplaySceneManager")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplaySceneManager", v7];
    }
    SEL v9 = NSSelectorFromString(@"_layoutStateManager");
    if (![v7 respondsToSelector:v9]) {
        v10 = nil;
        LogSelectorError(v7, NSSelectorFromString(@"_layoutStateManager"));
    } else {
        v10 = [v7 _layoutStateManager];
    }
    if (!v10 || ![v10 isKindOfClass:NSClassFromString(@"SBMainDisplayLayoutStateManager")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBMainDisplayLayoutStateManager", v10];
    }
    SEL v12 = NSSelectorFromString(@"displayIdentity");
    if (![v7 respondsToSelector:v12]) {
        v13 = nil;
        LogSelectorError(v7, NSSelectorFromString(@"displayIdentity"));
    } else {
        v13 = [v7 displayIdentity];
    }
    if (!v13 || ![v13 isKindOfClass:NSClassFromString(@"FBSDisplayIdentity")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSDisplayIdentity", v13];
    }
    id v15 = nil;
    SEL v16 = NSSelectorFromString(@"_sceneIdentityForApplication:createPrimaryIfRequired:");
    if ([v7 respondsToSelector:v16]) {
        id application3 = [self application];
        v15 = [v7 _sceneIdentityForApplication:application3 createPrimaryIfRequired:1];
    } else if ([v7 respondsToSelector:NSSelectorFromString(@"_sceneIdentityForApplication:createPrimaryIfRequired:sceneSessionRole:")]) {
        id application2 = [self application];
        v15 = [v7 _sceneIdentityForApplication:application2 createPrimaryIfRequired:1 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
    }
    if (!v15 || ![v15 isKindOfClass:NSClassFromString(@"FBSSceneIdentity")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBSSceneIdentity", v15];
    }
    Class v20 = objc_getClass("SBApplicationSceneHandleRequest");
    id application4 = [self application];
    id v22 = [v20 defaultRequestForApplication:application4 sceneIdentity:v15 displayIdentity:v13];
    if (!v22 || ![v22 isKindOfClass:NSClassFromString(@"SBApplicationSceneHandleRequest")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneHandleRequest", v22];
    }
    id v24 = [v7 fetchOrCreateApplicationSceneHandleForRequest:v22];
    if (!v24 || ![v24 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneHandle")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneHandle", v24];
    }
    SBDeviceApplicationSceneEntity *v26 = [[objc_getClass("SBDeviceApplicationSceneEntity") alloc] initWithApplicationSceneHandle:v24];
    if (!v26 || ![v26 isKindOfClass:NSClassFromString(@"SBDeviceApplicationSceneEntity")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBDeviceApplicationSceneEntity", v26];
    }
    [self setAppViewController:[[objc_getClass("SBAppViewController") alloc] initWithIdentifier:v2 andApplicationSceneEntity:v26]];
    if (![self appViewController] || ![(v31 = [self appViewController]) isKindOfClass:NSClassFromString(@"SBAppViewController")]) {
        id appViewController = [self appViewController];
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBAppViewController", appViewController];
    }
    id appViewController2 = [self appViewController];
    [appViewController2 setIgnoresOcclusions:0];
    id appViewController3 = [self appViewController];
    [appViewController3 setValue:@2 forKey:@"_currentMode"];
    id appViewController4 = [self appViewController];
    id v35 = [appViewController4 valueForKey:@"_activationSettings"];
    if (![v35 respondsToSelector:NSSelectorFromString(@"clearActivationSettings")]) {
        id appViewController5 = [self appViewController];
        id v37 = [appViewController5 valueForKey:@"_activationSettings"];
        LogSelectorError(v37, NSSelectorFromString(@"clearActivationSettings"));
    } else {
        id appViewController6 = [self appViewController];
        id v39 = [appViewController6 valueForKey:@"_activationSettings"];
        [v39 clearActivationSettings];
    }
    id appViewController7 = [self appViewController];
    if (![appViewController7 respondsToSelector:NSSelectorFromString(@"view")]) {
        v41 = nil;
        id appViewController8 = [self appViewController];
        LogSelectorError(appViewController8, NSSelectorFromString(@"view"));
    } else {
        id appViewController9 = [self appViewController];
        v41 = [appViewController9 view];
    }
    SEL v44 = NSSelectorFromString(@"recursiveDescription");
    if (![v41 respondsToSelector:v44]) {
        v45 = nil;
        LogSelectorError(v41, NSSelectorFromString(@"recursiveDescription"));
    } else {
        v45 = [v41 recursiveDescription];
    }
    NSLog(@"carplayenable appviewcontroller view recursive description: %@", v45);
    id appViewController10 = [self appViewController];
    id v47 = [appViewController10 _createSceneUpdateTransactionForApplicationSceneEntity:v26 deliveringActions:1];
    if (!v47 || ![v47 isKindOfClass:NSClassFromString(@"SBApplicationSceneUpdateTransaction")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"SBApplicationSceneUpdateTransaction", v47];
    }
    id appViewController11 = [self appViewController];
    __block id v49 = [appViewController11 valueForKey:@"_activeTransitions"];
    [v47 setCompletionBlock:^void(int arg1) {
        id v70;
        [v49 removeObject:v47];
        id v69 = [v47 valueForKey:@"_processLaunchTransaction"];
        if (!v69 || ![v69 isKindOfClass:NSClassFromString(@"FBApplicationProcessLaunchTransaction")]) {
            [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"FBApplicationProcessLaunchTransaction", v69];
        }
        if (![v69 respondsToSelector:NSSelectorFromString(@"process")]) {
            v70 = nil;
            LogSelectorError(v69, NSSelectorFromString(@"process"));
        } else {
            v70 = [v69 process];
        }
        if (!v70 || ![v70 isKindOfClass:NSClassFromString(@"FBProcess")]) {
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
                        if (!v14 || ![v14 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
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
    id appViewController12 = [self appViewController];
    if (![appViewController12 respondsToSelector:NSSelectorFromString(@"_createSceneViewController")]) {
        id appViewController13 = [self appViewController];
        LogSelectorError(appViewController13, NSSelectorFromString(@"_createSceneViewController"));
    } else {
        id appViewController14 = [self appViewController];
        [appViewController14 _createSceneViewController];
    }
    if (![objc_getClass("SBApplicationSceneView") respondsToSelector:NSSelectorFromString(@"defaultDisplayModeAnimationFactory")]) {
        LogSelectorError(objc_getClass("SBApplicationSceneView"), NSSelectorFromString(@"defaultDisplayModeAnimationFactory"));
        v56 = nil;
    } else {
        v56 = [objc_getClass("SBApplicationSceneView") defaultDisplayModeAnimationFactory];
    }
    if (!v56 || ![v56 isKindOfClass:NSClassFromString(@"BSUIAnimationFactory")]) {
        [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"BSUIAnimationFactory", v56];
    }
    id appViewController15 = [self appViewController];
    if (![appViewController15 respondsToSelector:NSSelectorFromString(@"appView")]) {
        id appViewController16 = [self appViewController];
        LogSelectorError(appViewController16, NSSelectorFromString(@"appView"));
        v60 = nil;
    } else {
        id appViewController17 = [self appViewController];
        v60 = [appViewController17 appView];
    }
    [v60 setDisplayMode:4 animationFactory:v56 completion:0];
    id appViewController18 = [self appViewController];
    UIView *view = [appViewController18 view];
    UIColor *clearColor = [UIColor clearColor];
    [view setBackgroundColor:clearColor];
    long v65 = 0;
    SEL v66 = NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:");
    if ([v10 respondsToSelector:v66]) {
        v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2];
    } else if ([v10 respondsToSelector:NSSelectorFromString(@"primarySceneIdentifierForBundleIdentifier:sceneSessionRole:")]) {
        v65 = [v10 primarySceneIdentifierForBundleIdentifier:v2 sceneSessionRole:@"UIWindowSceneSessionRoleApplication"];
    }
    [self setSceneMonitor:[[objc_getClass("FBSceneMonitor") alloc] initWithSceneID:v65]];
    id sceneMonitor = [self sceneMonitor];
    [sceneMonitor setDelegate:self];
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
        uint8_t v75[48];
        id v13;
        id v16;
        id v78;
        id v79;
        id v80;
        id v82;
        id v37;
        id v42;
        id v45;
        id v47;
        id v51;
        id v52;
        id v53;
        id v54;
        id v55;
        id v56;
        id v57;
        id v58;
        NSString *v59;
        id v60;
        id v61;
        id v62;
        id v63;
        id v64;
        NSString *v67;
        id v68;
        id v69;
        BOOL v71;
        *(uint32_t *)&v75[44] = -1;
        id appViewController14 = [self appViewController];
        NSString *anObject = [appViewController14 valueForKey:@"_identifier"];
        Class v5 = objc_getClass("NSDistributedNotificationCenter");
        NSDistributedNotificationCenter *defaultCenter = [v5 defaultCenter];
        NSDictionary<NSString *, NSNumber *> *aUserInfo = @{@"orientation": [NSNumber numberWithInt:*(uint32_t *)&v75[44]]};
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
        SEL v77 = NSSelectorFromString(@"appViewControllers");
        if (![v16 respondsToSelector:v77]) {
            v78 = nil;
            LogSelectorError(v16, NSSelectorFromString(@"appViewControllers"));
        } else {
            v78 = [v16 appViewControllers];
        }
        for (id v75 in v78) {
            if ([v75 respondsToSelector:NSSelectorFromString(@"_applicationSceneViewController")]) {
                v79 = [v75 _applicationSceneViewController];
            } else {
                v79 = nil;
                LogSelectorError(v75, NSSelectorFromString(@"_applicationSceneViewController"));
            }
            if ([v79 respondsToSelector:NSSelectorFromString(@"_sceneView")]) {
                v80 = [v79 _sceneView];
            } else {
                v80 = nil;
                LogSelectorError(v79, NSSelectorFromString(@"_sceneView"));
            }
            if ([v80 respondsToSelector:NSSelectorFromString(@"sceneHandle")]) {
                v82 = [v80 sceneHandle];
            } else {
                v82 = nil;
                LogSelectorError(v80, NSSelectorFromString(@"sceneHandle"));
            }
            if ([v82 isEqual:v13]) {
                [v80 setDisplayMode:4 animationFactory:0 completion:0];
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
            if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                v51 = nil;
                LogSelectorError(v45, NSSelectorFromString(@"client"));
            } else {
                v51 = [v45 client];
            }
            if (![v51 respondsToSelector:NSSelectorFromString(@"process")]) {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v52 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v52 = [v45 client];
                }
                v53 = nil;
                LogSelectorError(v52, NSSelectorFromString(@"process"));
            } else {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v54 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v54 = [v45 client];
                }
                v53 = [v54 process];
            }
            if (![v53 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v55 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v55 = [v45 client];
                }
                if (![v55 respondsToSelector:NSSelectorFromString(@"process")]) {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v56 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v56 = [v45 client];
                    }
                    v57 = nil;
                    LogSelectorError(v56, NSSelectorFromString(@"process"));
                } else {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v58 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v58 = [v45 client];
                    }
                    v57 = [v58 process];
                }
                v59 = nil;
                LogSelectorError(v57, NSSelectorFromString(@"bundleIdentifier"));
            } else {
                if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                    v60 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"client"));
                } else {
                    v60 = [v45 client];
                }
                if (![v60 respondsToSelector:NSSelectorFromString(@"process")]) {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v61 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v61 = [v45 client];
                    }
                    v62 = nil;
                    LogSelectorError(v61, NSSelectorFromString(@"process"));
                } else {
                    if (![v45 respondsToSelector:NSSelectorFromString(@"client")]) {
                        v63 = nil;
                        LogSelectorError(v45, NSSelectorFromString(@"client"));
                    } else {
                        v63 = [v45 client];
                    }
                    v62 = [v63 process];
                }
                v59 = [v62 bundleIdentifier];
            }
            [v35 removeObject:v59];
            if (![sharedApplication respondsToSelector:NSSelectorFromString(@"_accessibilityFrontMostApplication")]) {
                v64 = nil;
                LogSelectorError(sharedApplication, NSSelectorFromString(@"_accessibilityFrontMostApplication"));
            } else {
                v64 = [sharedApplication _accessibilityFrontMostApplication];
            }
            BOOL v66 = NO;
            if (v64 != nil) {
                if (![v64 respondsToSelector:NSSelectorFromString(@"bundleIdentifier")]) {
                    v67 = nil;
                    LogSelectorError(v64, NSSelectorFromString(@"bundleIdentifier"));
                } else {
                    v67 = [v64 bundleIdentifier];
                }
                v66 = [v67 isEqualToString:v59];
            }
            if (!v66) {
                if (![v45 respondsToSelector:NSSelectorFromString(@"settings")]) {
                    v68 = nil;
                    LogSelectorError(v45, NSSelectorFromString(@"settings"));
                } else {
                    v68 = [v45 settings];
                }
                if (![v68 respondsToSelector:NSSelectorFromString(@"mutableCopy")]) {
                    v69 = nil;
                    LogSelectorError(v68, NSSelectorFromString(@"mutableCopy"));
                } else {
                    v69 = [v68 mutableCopy];
                }
                if (!v69 || ![v69 isKindOfClass:NSClassFromString(@"UIMutableApplicationSceneSettings")]) {
                    [NSException raise:@"UnexpectedObjectException" format:@"Expected %@ but got %@", @"UIMutableApplicationSceneSettings", v69];
                }
                [v69 setBackgrounded:1];
                [v69 setForeground:0];
                NSLog(@"carplay scene is going to background withTransitionContext %@", v69);
                NSLog(@"carplay withTransitionContext %@", v45);
                [v45 updateSettings:v69 withTransitionContext:0 completion:^void(void) {
                }];
            }
        }
        if (![sharedApplication respondsToSelector:NSSelectorFromString(@"isLocked")]) {
            LogSelectorError(sharedApplication, NSSelectorFromString(@"isLocked"));
            v71 = NO;
        } else {
            v71 = [sharedApplication isLocked];
        }
        if (v71 == 1 && (double)dlsym(-2, "BKSHIDServicesGetBacklightFactor")() < 0.2) {
            orig_BKSDisplayServicesSetScreenBlanked(1);
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
    long v6 = 0;
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
                    v6 = 1;
                }
            } else {
                LogSelectorError(v13, NSSelectorFromString(@"_isCarScreen"));
            }
            if (v6) {
                break;
            }
        }
        if (!v6) {
            v13 = nil;
        }
    } else {
        v13 = [UIScreen mainScreen];
    }
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
    return [[v7 _endpointValueForKey:@"RightHandDrive"] boolValue];
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
