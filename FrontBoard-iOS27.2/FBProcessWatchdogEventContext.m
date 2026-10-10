struct FBProcessWatchdogEventContext {
    long _event; // +0x8
    FBSSceneSettings *_sceneSettings; // +0x10
    __weak FBSSceneTransitionContext *_sceneTransitionContext; // +0x18
    FBSceneUpdateContext *_sceneUpdateContext; // +0x20
};

void -[FBProcessWatchdogEventContext .cxx_destruct](void)
{
    self->_sceneUpdateContext = nil;
    self->_sceneTransitionContext = nil;
    self->_sceneSettings = nil;
}


long -[FBProcessWatchdogEventContext event](void)
{
    return self->_event;
}


FBSSceneTransitionContext *-[FBProcessWatchdogEventContext sceneTransitionContext](void)
{
    return self->_sceneTransitionContext;
}


id +[FBProcessWatchdogEventContext contextForEvent:settings:transitionContext:](long a1, id a2, id a3)
{
    id v1 = [[self alloc] init];
    v1->field_8 = a1;
    v1->field_16 = a2;
    objc_storeWeak(v1 + 24, a3);
    v1->field_32 = [a3 updateContext];
    return v1;
}


FBSSceneSettings *-[FBProcessWatchdogEventContext sceneSettings](void)
{
    return self->_sceneSettings;
}


FBSceneUpdateContext *-[FBProcessWatchdogEventContext sceneUpdateContext](void)
{
    return self->_sceneUpdateContext;
}


long -[FBProcessWatchdogEventContext description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBProcessWatchdogEventContext succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBProcessWatchdogEventContext succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    id v1 = NSStringFromProcessWatchdogEvent(self->_event);
    [v0 appendObject:v1 withName:@"event"];
    return v0;
}


id -[FBProcessWatchdogEventContext descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBProcessWatchdogEventContext descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    if (self->_sceneUpdateContext != nil) {
        [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
            [succinctDescriptionBuilder appendObject:self->_sceneUpdateContext withName:@"updateContext"];
        }];
    }
    return succinctDescriptionBuilder;
}
