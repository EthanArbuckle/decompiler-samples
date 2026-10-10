id +[FBDisplayManager sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        id v3;
        id v5;
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSDictionary<NSString *, id> *infoDictionary = [mainBundle infoDictionary];
        NSString *aClassName = [infoDictionary bs_safeStringForKey:@"FBDisplayManagerTransformer"];
        if (!aClassName) {
            v3 = nil;
        } else {
            v3 = [[NSClassFromString(aClassName) alloc] init];
            if (![v3 respondsToSelector:@selector(transformDisplayConfiguration:)]) {
                NSString *v8 = [NSString stringWithFormat:@"Transformer specified must conform to <FBSDisplayTransformer>."];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v9 = NSStringFromSelector(_cmd);
                    NSString *v10 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, self, @"FBDisplayManager.m", 48, v8);
                }
                _bs_set_crash_log_message([v8 UTF8String]);
                __break(0);
            }
        }
        if (!UIKitLibraryCore(0)) {
            v5 = 0;
        } else {
            long v7 = getUIApplicationClass();
            if (!v7) {
                v5 = 0;
            } else {
                v5 = [v7 displayManagerObserver];
            }
        }
        sharedInstance.__sharedInstance = [[FBDisplayManager alloc] _initWithBookendObserver:v5 transformer:v3];
    });
    return sharedInstance.__sharedInstance;
}


FBSDisplayConfiguration *+[FBDisplayManager mainConfiguration](void)
{
    id sharedInstance = [FBDisplayManager sharedInstance];
    return [sharedInstance mainConfiguration];
}


FBSDisplayIdentity *+[FBDisplayManager mainIdentity](void)
{
    id sharedInstance = [FBDisplayManager sharedInstance];
    return [sharedInstance mainIdentity];
}


NSSet *+[FBDisplayManager alwaysConnectedIdentities](void)
{
    id sharedInstance = [FBDisplayManager sharedInstance];
    return [sharedInstance alwaysConnectedIdentities];
}


long -[FBDisplayManager postBookendConnections](void)
{
    return [self _postInitialBookendObserverConnections];
}


void -[FBDisplayManager init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"-init is not allowed - call +sharedInstance instead"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayManager.m", 21, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBDisplayManager initWithInitializationCompletion:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"-initWithInitializationCompletion: is not allowed - call +sharedInstance instead"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayManager.m", 26, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBDisplayManager initWithTransformer:](long a1)
{
    NSString *v1 = [NSString stringWithFormat:@"-initWithTransformer: is not allowed - call +sharedInstance instead"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayManager.m", 31, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBDisplayManager invalidate](void)
{
    NSString *v1 = [NSString stringWithFormat:@"you cannot invalidate FBDisplayManager"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayManager.m", 36, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}


void -[FBDisplayManager dealloc](void)
{
    NSString *v1 = [NSString stringWithFormat:@"this singleton must be not deallocated"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayManager.m", 62, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
