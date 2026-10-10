struct FBWatchdogTransitionContext {
    long _watchdogBehavior; // +0x8
    id<FBProcessWatchdogProviding> _watchdogProvider; // +0x10
    bool _runIndependently; // +0x18
};

id -[FBWatchdogTransitionContext copyWithZone:](NSZone *a1)
{
    return [self mutableCopyWithZone:a1];
}


FBWatchdogTransitionContext *-[FBWatchdogTransitionContext mutableCopyWithZone:](long a1)
{
    FBWatchdogTransitionContext *v0 = [[FBWatchdogTransitionContext alloc] init];
    [v0 setWatchdogBehavior:self->_watchdogBehavior];
    [v0 setWatchdogProvider:self->_watchdogProvider];
    [v0 setRunIndependently:self->_runIndependently];
    return v0;
}


long -[FBWatchdogTransitionContext watchdogBehavior](void)
{
    return self->_watchdogBehavior;
}


void -[FBWatchdogTransitionContext setWatchdogBehavior:](long a1)
{
    self->_watchdogBehavior = a1;
}


id<FBProcessWatchdogProviding> -[FBWatchdogTransitionContext watchdogProvider](void)
{
    return self->_watchdogProvider;
}


void -[FBWatchdogTransitionContext setWatchdogProvider:](id<FBProcessWatchdogProviding> a1)
{
    self->_watchdogProvider = a1;
}


bool -[FBWatchdogTransitionContext runIndependently](void)
{
    return self->_runIndependently;
}


void -[FBWatchdogTransitionContext setRunIndependently:](bool a1)
{
    self->_runIndependently = a1;
}


void -[FBWatchdogTransitionContext .cxx_destruct](void)
{
    self->_watchdogProvider = nil;
}
