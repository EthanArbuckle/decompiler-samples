struct FBMainDisplayLayoutPublisher {
    FBSDisplayLayoutPublisher *_publisher; // +0x8
    id<BSInvalidatable> _backlightTransition; // +0x10
};

static long FBDisplayLayoutDidUpdateNotification;

long -[FBMainDisplayLayoutPublisher transitionAssertionWithReason:](long a1)
{
    return [self->_publisher transitionAssertionWithReason:a1];
}


long -[FBMainDisplayLayoutPublisher addElement:](long a1)
{
    return [self->_publisher addElement:a1];
}


void -[FBMainDisplayLayoutPublisher setInterfaceOrientation:](long a1)
{
    [self->_publisher setInterfaceOrientation:a1];
}


id +[FBMainDisplayLayoutPublisher sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        id bootstrapConfiguration = [BSServicesConfiguration bootstrapConfiguration];
        id environmentAliases = [BSMachServiceAliases environmentAliases];
        id defaultShellMachName = [BSServiceConnectionEndpoint defaultShellMachName];
        id v3 = [environmentAliases resolveMachService:defaultShellMachName];
        id v4 = [bootstrapConfiguration domainForMachName:v3];
        if (v4 != nil) {
            id serviceIdentifier = [FBSDisplayLayoutMonitor serviceIdentifier];
            id v6 = [v4 serviceForIdentifier:serviceIdentifier];
            if (!v6) {
                FBSDisplayLayoutPublisherConfiguration *oslog = FBLogCommon();
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "No layout monitor service specified. This process will not publish layout for the main display.");
                }
            } else {
                FBSDisplayLayoutPublisherConfiguration *v13 = [FBSDisplayLayoutPublisherConfiguration new];
                id identifier = [v4 identifier];
                [v13 setDomainIdentifier:identifier];
                id mainDisplayInstanceIdentifier = [FBSDisplayLayoutMonitor mainDisplayInstanceIdentifier];
                [v13 setInstanceIdentifier:mainDisplayInstanceIdentifier];
                sharedInstance.__sharedInstance = [[FBMainDisplayLayoutPublisher alloc] _initWithPublisher:[FBSDisplayLayoutPublisher publisherWithConfiguration:v13]];
            }
        }
    });
    return sharedInstance.__sharedInstance;
}


void -[FBMainDisplayLayoutPublisher setBacklightLevel:](long a1)
{
    [self->_publisher setBacklightLevel:a1];
}


void -[FBMainDisplayLayoutPublisher backlightHost:willTransitionToState:forEvent:](long a1, long a2, long a3)
{
    id<BSInvalidatable> v0 = self->_backlightTransition;
    self->_backlightTransition = [self->_publisher transitionAssertionWithReason:@"BLSBacklight"];
    [self _updateWithBacklightState:a2];
    [v0 invalidate];
}


long -[FBMainDisplayLayoutPublisher _updateWithBacklightState:](long a1)
{
    if ((unsigned long)a1 <= 3) {
        [self->_publisher setBacklightLevel:(&qword_1c4f5d148)[a1]];
    }
    return [self->_publisher setBacklightState:a1];
}


FBMainDisplayLayoutPublisher *-[FBMainDisplayLayoutPublisher _initWithPublisher:](FBSDisplayLayoutPublisher *a1)
{
    os_log_t v14;
    if (a1 != nil) {
        FBMainDisplayLayoutPublisher *v2 = [super init];
        if (v2 != nil) {
            long v1 = 0;
            v2->_publisher = a1;
            id v3 = [v2->_publisher transitionAssertionWithReason:0];
            id sharedInstance = [FBDisplayManager sharedInstance];
            [sharedInstance addObserver:v2];
            FBSDisplayConfiguration *mainConfiguration = [sharedInstance mainConfiguration];
            [v2->_publisher setDisplayConfiguration:mainConfiguration];
            id v9 = getBLSBacklightClass.softClass;
            __block long v6 = getBLSBacklightClass.softClass;
            if (!v9) {
                ^void(void) {
                    BacklightServicesLibrary();
                    v6 = objc_getClass("BLSBacklight");
                    if (!v6) {
                        NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                        NSString *v23 = [NSString stringWithUTF8String:"Class getBLSBacklightClass(void)_block_invoke"];
                        [currentHandler handleFailureInFunction:v23 file:@"FBMainDisplayLayoutPublisher.m" lineNumber:25 description:@"Unable to find class %s", "BLSBacklight"];
                        __builtin_trap();
                    }
                    getBLSBacklightClass.softClass = v6;
                }();
                v9 = v6;
            }
            id sharedBacklight = [v9 sharedBacklight];
            if (!sharedBacklight) {
                v14 = FBLogCommon();
                if (os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v14, OS_LOG_TYPE_ERROR, "[FBMainDisplayLayoutPublisher] Unable to create BLSBacklight. Main display backlight updates are unavilable.");
                }
                v1 = 1;
            } else {
                id v15 = getBLSRuntimeClass.softClass;
                __block long v11 = getBLSRuntimeClass.softClass;
                if (!v15) {
                    ^void(void) {
                        BacklightServicesLibrary();
                        v11 = objc_getClass("BLSRuntime");
                        if (!v11) {
                            NSAssertionHandler *currentHandler = [NSAssertionHandler currentHandler];
                            NSString *v24 = [NSString stringWithUTF8String:"Class getBLSRuntimeClass(void)_block_invoke"];
                            [currentHandler handleFailureInFunction:v24 file:@"FBMainDisplayLayoutPublisher.m" lineNumber:26 description:@"Unable to find class %s", "BLSRuntime"];
                            __builtin_trap();
                        }
                        getBLSRuntimeClass.softClass = v11;
                    }();
                    v15 = v11;
                }
                if (![v15 isHostProcess]) {
                    v14 = FBLogCommon();
                    if (os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(v14, OS_LOG_TYPE_ERROR, "[FBMainDisplayLayoutPublisher] This process is not a BacklightServices host process. Main display backlight updates are unavilable.");
                    }
                    v1 = 1;
                }
                if (!v1) {
                    [sharedBacklight addObserver:v2];
                    long backlightState = [sharedBacklight backlightState];
                    [v2 _updateWithBacklightState:backlightState];
                }
            }
            if (v1) {
                [v2->_publisher setBacklightLevel:100];
            }
            [v2->_publisher addObserver:v2];
            [v2->_publisher activate];
            [v3 invalidate];
        }
        return v2;
    }
    NSString *v19 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"publisher"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v20 = NSStringFromSelector(_cmd);
        NSString *v21 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v20, v21, self, @"FBMainDisplayLayoutPublisher.m", 48, v19);
    }
    _bs_set_crash_log_message([v19 UTF8String]);
    __break(0);
}


long -[FBMainDisplayLayoutPublisher interfaceOrientation](void)
{
    return [self->_publisher interfaceOrientation];
}


long -[FBMainDisplayLayoutPublisher backlightLevel](void)
{
    return [self->_publisher backlightLevel];
}


bool -[FBMainDisplayLayoutPublisher isTransitioning](void)
{
    return [self->_publisher isTransitioning];
}


long -[FBMainDisplayLayoutPublisher flush](void)
{
    return [self->_publisher flush];
}


id -[FBMainDisplayLayoutPublisher currentLayout](void)
{
    return [self->_publisher currentLayout];
}


long -[FBMainDisplayLayoutPublisher addObserver:](long a1)
{
    return [self->_publisher addObserver:a1];
}


long -[FBMainDisplayLayoutPublisher removeObserver:](id a1)
{
    return [self->_publisher removeObserver:a1];
}


long -[FBMainDisplayLayoutPublisher _addElement:forKey:](long a1, long a2)
{
    return [self->_publisher _addElement:a1 forKey:a2];
}


void -[FBMainDisplayLayoutPublisher displayMonitor:didUpdateIdentity:withConfiguration:](id a1, id a2, id a3)
{
    FBSDisplayIdentity *mainIdentity = [a1 mainIdentity];
    if (a2 == mainIdentity) {
        [self->_publisher setDisplayConfiguration:a3];
    }
}


void -[FBMainDisplayLayoutPublisher publisher:didUpdateLayout:withTransition:](long a1, long a2, long a3)
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:FBDisplayLayoutDidUpdateNotification object:@0LL];
}


void -[FBMainDisplayLayoutPublisher backlight:didCompleteUpdateToState:forEvents:abortedEvents:](long a1, long a2, long a3, long a4)
{
    id<BSInvalidatable> v0 = self->_backlightTransition;
    self->_backlightTransition = nil;
    if (!v0) {
        v0 = [self->_publisher transitionAssertionWithReason:@"BLSBacklight"];
    }
    [self _updateWithBacklightState:a2];
    [v0 invalidate];
}


void -[FBMainDisplayLayoutPublisher .cxx_destruct](void)
{
    self->_backlightTransition = nil;
    self->_publisher = nil;
}


void -[FBMainDisplayLayoutPublisher init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"init is not allowed on FBMainDisplayLayoutPublisher"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBMainDisplayLayoutPublisher.m", 43, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBMainDisplayLayoutPublisher dealloc](void)
{
    NSString *v1 = [NSString stringWithFormat:@"FBMainDisplayLayoutPublisher is a singleton"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBMainDisplayLayoutPublisher.m", 85, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
