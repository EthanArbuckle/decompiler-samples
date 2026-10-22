struct FBSceneLayerManager {
    NSString *_identifier; // +0x8
    NSOrderedSet *_layers; // +0x10
    NSOrderedSet *_fbsLayers; // +0x18
    NSHashTable *_suspendAssertions; // +0x20
    NSHashTable *_observers; // +0x28
    __weak FBScene *_scene; // +0x30
    bool _needsRebuildLayers; // +0x38
};

void -[FBSceneLayerManager addObserver:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager addObserver:]");
    }
    if (a1 != nil) {
        NSHashTable *v1 = self->_observers;
        if (!self->_observers) {
            self->_observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsZeroingWeakMemory | NSPointerFunctionsMachVirtualMemory | NSPointerFunctionsObjectPointerPersonality capacity:4];
            v1 = self->_observers;
        }
        [v1 addObject:a1];
    }
}


void -[FBSceneLayerManager _setLayers:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager _setLayers:]");
    }
    if ((BSEqualObjects(self->_fbsLayers, a1) & 1) == 0) {
        self->_needsRebuildLayers = YES;
        self->_fbsLayers = [a1 copy];
    }
    if (self->_needsRebuildLayers == 1 && ![self->_suspendAssertions count]) {
        [self _rebuildLayers];
    }
}


NSOrderedSet *-[FBSceneLayerManager layers](void)
{
    return self->_layers;
}


void -[FBSceneLayerManager .cxx_destruct](void)
{
    self->_scene = nil;
    self->_observers = nil;
    self->_suspendAssertions = nil;
    self->_fbsLayers = nil;
    self->_layers = nil;
    self->_identifier = nil;
}


void -[FBSceneLayerManager _objc_initiateDealloc](void)
{
    if (pthread_main_np() != 0) {
        _objc_deallocOnMainThreadHelper(self);
        return;
    }
    dispatch_async_f(dispatch_get_main_queue(), self, &_objc_deallocOnMainThreadHelper);
}


FBSceneLayerManager *-[FBSceneLayerManager _initWithScene:](FBScene *a1)
{
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v7 = NSStringFromSelector(_cmd);
            NSString *v8 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSceneLayerManager.m", 115, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    dispatch_once(&_initWithScene:.onceToken, ^void(void) {
        _class_setCustomDeallocInitiation([FBSceneLayerManager class]);
    });
    FBSceneLayerManager *v2 = [super init];
    if (v2 != nil) {
        v2->_identifier = [a1 identifier];
        v2->_scene = a1;
        v2->_layers = [NSOrderedSet orderedSet];
    }
    return v2;
}


void -[FBSceneLayerManager _rebuildLayers](void)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager _rebuildLayers]");
    }
    FBScene *v0 = self->_scene;
    NSUInteger count = [self->_layers count];
    NSUInteger count3 = [self->_fbsLayers count];
    NSMutableOrderedSet *v3 = [NSMutableOrderedSet orderedSetWithCapacity:count3];
    for (id v11 in self->_fbsLayers) {
        id v13 = [FBSceneLayer layerWithFBSSceneLayer:v11];
        if (!v13) {
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                FBSceneClientHandle *clientHandle = [v0 clientHandle];
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Ignoring bogus scene layer %{public}@ from %{public}@", v11, clientHandle);
            }
        } else {
            [v3 addObject:v13];
        }
    }
    if ([v0 isValid]) {
        NSUInteger count2 = [v3 count];
        if (!count2 || count != 0) {
            if (count2 || count) {
                [self _observer_sceneLayerManagerWillUpdateLayers];
                if (!count2 && count != 0) {
                    [self _observer_willStopTrackingLayers];
                }
            }
        } else {
            [self _observer_willStartTrackingLayers];
            [self _observer_sceneLayerManagerWillUpdateLayers];
        }
    }
    self->_layers = [v3 copy];
    self->_needsRebuildLayers = NO;
    if ([v0 isValid]) {
        NSUInteger count4 = [v3 count];
        if (!count4 || count != 0) {
            if (count4 || count) {
                [self _observer_sceneLayerManagerDidUpdateLayers];
                if (!count4 && count != 0) {
                    [self _observer_didStopTrackingLayers];
                }
            }
        } else {
            [self _observer_didStartTrackingLayers];
            [self _observer_sceneLayerManagerDidUpdateLayers];
        }
    }
}


void -[FBSceneLayerManager removeObserver:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager removeObserver:]");
    }
    [self->_observers removeObject:a1];
    if (![self->_observers count]) {
        self->_observers = nil;
    }
}


void -[FBSceneLayerManager _observer_sceneLayerManagerDidUpdateLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerDidUpdateLayers:)]) {
            [v6 sceneLayerManagerDidUpdateLayers:self];
        }
    }
}


void -[FBSceneLayerManager _observer_didStartTrackingLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerDidStartTrackingLayers:)]) {
            [v6 sceneLayerManagerDidStartTrackingLayers:self];
        }
    }
}


void -[FBSceneLayerManager _observer_didStopTrackingLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerDidStopTrackingLayers:)]) {
            [v6 sceneLayerManagerDidStopTrackingLayers:self];
        }
    }
}


void -[FBSceneLayerManager _observer_sceneLayerManagerWillUpdateLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerWillUpdateLayers:)]) {
            [v6 sceneLayerManagerWillUpdateLayers:self];
        }
    }
}


void -[FBSceneLayerManager _observer_willStartTrackingLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerWillStartTrackingLayers:)]) {
            [v6 sceneLayerManagerWillStartTrackingLayers:self];
        }
    }
}


FBScene *-[FBSceneLayerManager scene](void)
{
    return self->_scene;
}


BSSimpleAssertion *-[FBSceneLayerManager _suspendUpdatesWithReason:](id a1)
{
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager _suspendUpdatesWithReason:]");
    }
    __weak FBSceneLayerManager *v1 = self;
    BSSimpleAssertion *v6 = [[BSSimpleAssertion alloc] initWithReason:a1 invalidatedWithContextBlock:^void(id<BSSimpleAssertionInvalidationContext> arg1) {
        if (![NSThread isMainThread]) {
            __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneLayerManager _suspendUpdatesWithReason:]_block_invoke");
        }
        id assertion = [arg1 assertion];
        [v1 _removeSuspendAssertion:assertion];
    }];
    NSHashTable *v7 = self->_suspendAssertions;
    if (!self->_suspendAssertions) {
        self->_suspendAssertions = [NSHashTable weakObjectsHashTable];
        v7 = self->_suspendAssertions;
    }
    [v7 addObject:v6];
    return v6;
}


long -[FBSceneLayerManager add:](long a1)
{
    return [self addObserver:a1];
}


long -[FBSceneLayerManager remove:](id a1)
{
    return [self removeObserver:a1];
}


FBSceneLayer *-[FBSceneLayerManager layerWithContextID:](int a1)
{
    FBSceneLayer *v4 = nil;
    for (FBSceneLayer *v7 in self->_layers) {
        unsigned int contextID = [v7 contextID];
        if (contextID == a1) {
            v4 = v7;
            break;
        }
    }
    if (!v4) {
        v4 = nil;
    }
    return v4;
}


long -[FBSceneLayerManager description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneLayerManager succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneLayerManager succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    NSString *identifier = [self identifier];
    [v0 appendObject:identifier withName:@"identifier"];
    [v0 appendBool:self->_needsRebuildLayers withName:@"needsRebuild" ifEqualTo:1];
    return v0;
}


id -[FBSceneLayerManager descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBSceneLayerManager descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    if (![self->_layers count]) {
        [succinctDescriptionBuilder appendObject:@"(none)" withName:@"layers"];
    } else {
        NSArray *array = [self->_layers array];
        [succinctDescriptionBuilder appendArraySection:array withName:@"layers" multilinePrefix:a1 skipIfEmpty:1];
    }
    if (![self->_suspendAssertions count]) {
        [succinctDescriptionBuilder appendObject:@"(none)" withName:@"suspendAssertions"];
    } else {
        NSArray *allObjects = [self->_suspendAssertions allObjects];
        [succinctDescriptionBuilder appendArraySection:allObjects withName:@"suspendAssertions" skipIfEmpty:1];
    }
    return succinctDescriptionBuilder;
}


NSUInteger -[FBSceneLayerManager _removeSuspendAssertion:](id a1)
{
    [self->_suspendAssertions removeObject:a1];
    NSUInteger count = [self->_suspendAssertions count];
    if (count != 0) {
        return count;
    }
    self->_suspendAssertions = nil;
    if (self->_needsRebuildLayers != 1) {
        return count;
    }
    return [self _rebuildLayers];
}


void -[FBSceneLayerManager _observer_willStopTrackingLayers](void)
{
    id v1 = [self->_observers copy];
    for (id v6 in v1) {
        if ([v6 respondsToSelector:@selector(sceneLayerManagerWillStopTrackingLayers:)]) {
            [v6 sceneLayerManagerWillStopTrackingLayers:self];
        }
    }
}


NSString *-[FBSceneLayerManager identifier](void)
{
    return self->_identifier;
}
