struct FBProcessExecutionContext {
    bool _waitForDebugger; // +0x8
    bool _disableASLR; // +0x9
    bool _checkForLeaks; // +0xa
    bool _enableMTE; // +0xb
    bool _forSceneActivation; // +0xc
    RBSProcessIdentity *_identity; // +0x10
    NSArray *_arguments; // +0x18
    NSDictionary *_environment; // +0x20
    NSURL *_standardOutputURL; // +0x28
    NSURL *_standardErrorURL; // +0x30
    long _launchIntent; // +0x38
    id<FBProcessWatchdogProviding> _watchdogProvider; // +0x40
    double _watchdogExtension; // +0x48
    NSString *_overrideExecutablePath; // +0x50
    FBSProcessExecutableSlice *_overrideExecutableSlice; // +0x58
    id _completion; // +0x60
};

void -[FBProcessExecutionContext .cxx_destruct](void)
{
    self->_completion = nil;
    self->_overrideExecutableSlice = nil;
    self->_overrideExecutablePath = nil;
    self->_watchdogProvider = nil;
    self->_standardErrorURL = nil;
    self->_standardOutputURL = nil;
    self->_environment = nil;
    self->_arguments = nil;
    self->_identity = nil;
}


long -[FBProcessExecutionContext copyWithZone:](long a1)
{
    return self;
}


FBMutableProcessExecutionContext *-[FBProcessExecutionContext mutableCopyWithZone:](long a1)
{
    FBMutableProcessExecutionContext *v0 = [FBMutableProcessExecutionContext allocWithZone:a1];
    return [v0 _initWithExecutionContext:self];
}


long -[FBProcessExecutionContext launchIntent](void)
{
    return self->_launchIntent;
}


NSURL *-[FBProcessExecutionContext standardErrorURL](void)
{
    return self->_standardErrorURL;
}


void -[FBProcessExecutionContext setCheckForLeaks:](bool a1)
{
    self->_checkForLeaks = a1;
}


void -[FBProcessExecutionContext setCompletion:](void (^a1)(FBProcess *, NSError *))
{
    void (^v0)(FBProcess *, NSError *) = a1;
    if (!a1) {
        self->_completion = nil;
    } else {
        BSAtomicSignal *v2 = [BSAtomicSignal new];
        BSAtomicSignal *v5 = v2;
        id v7 = [BSBlockSentinel sentinelWithCompletion:^void(id<BSBlockSentinelSignalContext> arg1) {
            if (![arg1 isFailed]) {
                return;
            }
            if (![v2 signal]) {
                return;
            }
            NSError *v12 = [NSError bs_errorWithDomain:@"FBProcessExecutionContext" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureReason:@"No process execution was performed"];
            }];
            v0(nil, v12);
        }];
        self->_completion = [^void(FBProcess *arg1, NSError *arg2) {
            if ([v5 signal] != 0) {
                v0(arg1, arg2);
            }
            [v7 signal];
        } copy];
    }
}


RBSProcessIdentity *-[FBProcessExecutionContext identity](void)
{
    return self->_identity;
}


id<FBProcessWatchdogProviding> -[FBProcessExecutionContext watchdogProvider](void)
{
    return self->_watchdogProvider;
}


NSDictionary *-[FBProcessExecutionContext environment](void)
{
    return self->_environment;
}


void -[FBProcessExecutionContext setEnableMTE:](bool a1)
{
    self->_enableMTE = a1;
}


void -[FBProcessExecutionContext setDisableASLR:](bool a1)
{
    self->_disableASLR = a1;
}


long -[FBProcessExecutionContext setIdentity:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 16);
}


bool -[FBProcessExecutionContext disableASLR](void)
{
    return self->_disableASLR;
}


NSURL *-[FBProcessExecutionContext standardOutputURL](void)
{
    return self->_standardOutputURL;
}


NSString *-[FBProcessExecutionContext overrideExecutablePath](void)
{
    return self->_overrideExecutablePath;
}


bool -[FBProcessExecutionContext checkForLeaks](void)
{
    return self->_checkForLeaks;
}


id -[FBProcessExecutionContext completion](void)
{
    return self->_completion;
}


bool -[FBProcessExecutionContext waitForDebugger](void)
{
    return self->_waitForDebugger;
}


long -[FBProcessExecutionContext setEnvironment:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 32);
}


void -[FBProcessExecutionContext setStandardErrorURL:](NSURL *a1)
{
    self->_standardErrorURL = a1;
}


bool -[FBProcessExecutionContext forSceneActivation](void)
{
    return self->_forSceneActivation;
}


FBSProcessExecutableSlice *-[FBProcessExecutionContext overrideExecutableSlice](void)
{
    return self->_overrideExecutableSlice;
}


FBProcessExecutionContext *-[FBProcessExecutionContext _initWithExecutionContext:](id a1)
{
    FBProcessExecutionContext *v2 = [self initWithIdentity:[a1 identity]];
    if (v2 != nil) {
        id arguments = [a1 arguments];
        v2->_arguments = [arguments copy];
        NSDictionary *environment = [a1 environment];
        v2->_environment = [environment copy];
        v2->_standardOutputURL = [a1 standardOutputURL];
        v2->_standardErrorURL = [a1 standardErrorURL];
        v2->_waitForDebugger = [a1 waitForDebugger];
        v2->_disableASLR = [a1 disableASLR];
        v2->_checkForLeaks = [a1 checkForLeaks];
        v2->_enableMTE = [a1 enableMTE];
        v2->_launchIntent = [a1 launchIntent];
        v2->_watchdogProvider = [a1 watchdogProvider];
        v2->_watchdogExtension = [a1 watchdogExtension];
        v2->_overrideExecutablePath = [a1 overrideExecutablePath];
        v2->_forSceneActivation = [a1 forSceneActivation];
        v2->_overrideExecutableSlice = [a1 overrideExecutableSlice];
        id completion = [a1 completion];
        v2->_completion = [completion copy];
    }
    return v2;
}


FBProcessExecutionContext *-[FBProcessExecutionContext initWithIdentity:](id a1)
{
    FBProcessExecutionContext *v1 = [self init];
    if (v1 != nil) {
        v1->_identity = [a1 copy];
    }
    return v1;
}


void -[FBProcessExecutionContext setLaunchIntent:](long a1)
{
    self->_launchIntent = a1;
}


NSArray *-[FBProcessExecutionContext arguments](void)
{
    return self->_arguments;
}


FBProcessExecutionContext *-[FBProcessExecutionContext copyOrUpdateForSceneActivationWithSettings:](id a1)
{
    long v1 = [self launchIntent];
    if (!v1) {
        if ([a1 isForeground]) {
            v1 = ([a1 jetsamMode] != -10) ? 4 : 3;
        } else {
            v1 = 2;
        }
    }
    id v2 = self;
    if (![self isKindOfClass:[FBMutableProcessExecutionContext class]]) {
        v2 = [[FBProcessExecutionContext alloc] _initWithExecutionContext:v2];
    }
    [v2 setForSceneActivation:YES];
    [v2 setLaunchIntent:v1];
    return v2;
}


void -[FBProcessExecutionContext setForSceneActivation:](bool a1)
{
    self->_forSceneActivation = a1;
}


bool -[FBProcessExecutionContext enableMTE](void)
{
    return self->_enableMTE;
}


double -[FBProcessExecutionContext watchdogExtension](void)
{
    return self->_watchdogExtension;
}


long -[FBProcessExecutionContext setArguments:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 24);
}


void -[FBProcessExecutionContext setStandardOutputURL:](NSURL *a1)
{
    self->_standardOutputURL = a1;
}


void -[FBProcessExecutionContext setWaitForDebugger:](bool a1)
{
    self->_waitForDebugger = a1;
}


void -[FBProcessExecutionContext setWatchdogProvider:](id<FBProcessWatchdogProviding> a1)
{
    self->_watchdogProvider = a1;
}


void -[FBProcessExecutionContext setWatchdogExtension:](long a1)
{
    double v0;
    self->_watchdogExtension = v0;
}


long -[FBProcessExecutionContext setOverrideExecutablePath:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 80);
}


void -[FBProcessExecutionContext setOverrideExecutableSlice:](FBSProcessExecutableSlice *a1)
{
    self->_overrideExecutableSlice = a1;
}
