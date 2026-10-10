struct FBWaitForSceneDestructionTransaction {
    FBScene *_sceneToWaitForDeath; // +0x98
};

FBWaitForSceneDestructionTransaction *-[FBWaitForSceneDestructionTransaction initWithScene:](FBScene *a1)
{
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWaitForSceneDestructionTransaction.m", 31, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    FBWaitForSceneDestructionTransaction *v1 = [super init];
    if (v1 != nil) {
        v1->_sceneToWaitForDeath = a1;
    }
    return v1;
}


void -[FBWaitForSceneDestructionTransaction dealloc](void)
{
    [self->_sceneToWaitForDeath removeObserver:self];
    [super dealloc];
}


long -[FBWaitForSceneDestructionTransaction _begin](void)
{
    if ([self->_sceneToWaitForDeath isValid]) {
        [self addMilestone:@"SBWTMilestoneSceneDestruction"];
        [self->_sceneToWaitForDeath addObserver:self];
    }
    return [super _begin];
}


int -[FBWaitForSceneDestructionTransaction _canBeInterrupted](void)
{
    return 1;
}


long -[FBWaitForSceneDestructionTransaction _didComplete](void)
{
    [self->_sceneToWaitForDeath removeObserver:self];
    return [super _didComplete];
}


NSMutableDictionary *-[FBWaitForSceneDestructionTransaction _customizedDescriptionProperties](void)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    id succinctDescription = [self->_sceneToWaitForDeath succinctDescription];
    [dictionary setObject:succinctDescription forKey:@"Scene"];
    return dictionary;
}


FBWaitForSceneDestructionTransaction *-[FBWaitForSceneDestructionTransaction sceneDidInvalidate:](id a1)
{
    if (a1 != self->_sceneToWaitForDeath) {
        return self;
    }
    [a1 removeObserver:self];
    dispatch_queue_t queue = [self queue];
    dispatch_async(queue, ^void(void) {
        [self satisfyMilestone:@"SBWTMilestoneSceneDestruction"];
    });
    return queue;
}


FBScene *-[FBWaitForSceneDestructionTransaction scene](void)
{
    return self->_sceneToWaitForDeath;
}


void -[FBWaitForSceneDestructionTransaction .cxx_destruct](void)
{
    self->_sceneToWaitForDeath = nil;
}
