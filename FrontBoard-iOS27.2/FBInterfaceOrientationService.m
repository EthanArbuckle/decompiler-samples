struct FBInterfaceOrientationService {
    FBInterfaceOrientationServiceServer *_server; // +0x8
};

id +[FBInterfaceOrientationService sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        sharedInstance.__SharedInstance = [[FBInterfaceOrientationService alloc] init];
    });
    return sharedInstance.__SharedInstance;
}


FBInterfaceOrientationService *-[FBInterfaceOrientationService init](void)
{
    FBInterfaceOrientationService *v1 = [super init];
    if (v1 != nil) {
        v1->_server = [[FBInterfaceOrientationServiceServer alloc] init];
    }
    return v1;
}


void -[FBInterfaceOrientationService initialize](void)
{
    [self->_server initialize];
}


long -[FBInterfaceOrientationService startService](void)
{
    return [self->_server startService];
}


long -[FBInterfaceOrientationService setInterfaceOrientation:](long a1)
{
    return [self setInterfaceOrientation:a1 animationSettings:0 direction:0];
}


void -[FBInterfaceOrientationService setInterfaceOrientation:animationSettings:direction:](long a1, id a2, long a3)
{
    id sharedInstance = [FBDisplayManager sharedInstance];
    NSSet *alwaysConnectedIdentities = [sharedInstance alwaysConnectedIdentities];
    id v3 = [alwaysConnectedIdentities bs_firstObjectPassingTest:^bool(FBSDisplayIdentity *arg1) {
        return [arg1 isMainDisplay];
    }];
    [self setInterfaceOrientation:a1 forDisplayIdentity:v3 animationSettings:a2 rotationDirection:a3];
}


long -[FBInterfaceOrientationService setInterfaceOrientation:forDisplayIdentity:](long a1, long a2)
{
    return [self setInterfaceOrientation:a1 forDisplayIdentity:a2 animationSettings:0 rotationDirection:0];
}


void -[FBInterfaceOrientationService setInterfaceOrientation:forDisplayIdentity:animationSettings:rotationDirection:](long a1, id a2, id a3, long a4)
{
    if (!a2) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"displayIdentity != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v5 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v5, v3, self, @"FBInterfaceOrientationService.m", 79, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    FBSActiveInterfaceOrientationState *v2 = [[FBSActiveInterfaceOrientationState alloc] _initWithDisplayIdentity:a2 interfaceOrientation:a1];
    [self->_server noteActiveInterfaceOrientationStateDidChange:v2 animationSettings:a3 rotationDirection:a4];
}


void -[FBInterfaceOrientationService .cxx_destruct](void)
{
    self->_server = nil;
}
