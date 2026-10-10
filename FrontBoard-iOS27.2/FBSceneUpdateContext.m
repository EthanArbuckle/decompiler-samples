struct FBSceneUpdateContext {
    bool _lifecycleExternallyManaged; // +0x8
    NSString *_sceneID; // +0x10
    unsigned long _transactionID; // +0x18
    FBSSceneSettings *_settings; // +0x20
    FBSSceneSettingsDiff *_settingsDiff; // +0x28
    __weak FBSSceneTransitionContext *_transitionContext; // +0x30
    id<NSObject, NSCopying> _clientContext; // +0x38
};

id +[FBSceneUpdateContext contextWithSceneID:transactionID:settings:settingsDiff:transitionContext:](id a1, long a2, id a3, id a4, id a5)
{
    id v2 = [[self alloc] init];
    if (v2 != nil) {
        v2->field_16 = [a1 copy];
        v2->field_24 = a2;
        objc_storeStrong(v2 + 32, a3);
        objc_storeStrong(v2 + 40, a4);
        objc_storeWeak(v2 + 48, a5);
        v2->field_8 = [a5 isRunningBoardAssertionDisabled];
    }
    return v2;
}


void -[FBSceneUpdateContext .cxx_destruct](void)
{
    self->_clientContext = nil;
    self->_transitionContext = nil;
    self->_settingsDiff = nil;
    self->_settings = nil;
    self->_sceneID = nil;
}


unsigned long -[FBSceneUpdateContext transactionID](void)
{
    return self->_transactionID;
}


bool -[FBSceneUpdateContext isClientLifecycleExternallyManaged](void)
{
    return self->_lifecycleExternallyManaged;
}


FBSSceneSettings *-[FBSceneUpdateContext settings](void)
{
    return self->_settings;
}


FBSSceneSettingsDiff *-[FBSceneUpdateContext settingsDiff](void)
{
    return self->_settingsDiff;
}


FBSSceneTransitionContext *-[FBSceneUpdateContext transitionContext](void)
{
    return self->_transitionContext;
}


long -[FBSceneUpdateContext description](void)
{
    return [self succinctDescription];
}


long -[FBSceneUpdateContext debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneUpdateContext succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneUpdateContext succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_sceneID withName:@"scene"];
    [v0 appendUnsignedInteger:self->_transactionID withName:@"tID"];
    return v0;
}


id -[FBSceneUpdateContext descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBSceneUpdateContext descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
        id v0 = [BSDescriptionBuilder succinctDescriptionForObject:self->_settings];
        [succinctDescriptionBuilder appendObject:v0 withName:@"settings" skipIfNil:1];
        id v6 = [BSDescriptionBuilder succinctDescriptionForObject:self->_settingsDiff];
        [succinctDescriptionBuilder appendObject:v6 withName:@"settingsDiff" skipIfNil:1];
        FBSSceneTransitionContext *v7 = self->_transitionContext;
        id v3 = [BSDescriptionBuilder succinctDescriptionForObject:v7];
        [succinctDescriptionBuilder appendObject:v3 withName:@"transitionContext" skipIfNil:1];
        [succinctDescriptionBuilder appendBool:self->_lifecycleExternallyManaged withName:@"lifecycleExternallyManaged" ifEqualTo:1];
        id<NSObject, NSCopying> v5 = self->_clientContext;
        if (!self->_clientContext) {
            [succinctDescriptionBuilder appendObject:v5 withName:@"clientContext"];
            return;
        }
        v5 = [BSDescriptionBuilder descriptionForObject:v5];
        [succinctDescriptionBuilder appendObject:v5 withName:@"clientContext"];
    }];
    return succinctDescriptionBuilder;
}


NSString *-[FBSceneUpdateContext sceneID](void)
{
    return self->_sceneID;
}


id<NSObject, NSCopying> -[FBSceneUpdateContext clientContext](void)
{
    return self->_clientContext;
}


long -[FBSceneUpdateContext setClientContext:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 56);
}
