struct FBDisplayLayoutTransition {
    FBMainDisplayLayoutPublisher *_publisher; // +0x8
    NSString *_name; // +0x10
    NSString *_transitionReason; // +0x18
    long _displayType; // +0x20
    id<BSInvalidatable> _transition; // +0x28
    long _interfaceOrientation; // +0x30
    long _backlightLevel; // +0x38
};

id +[FBDisplayLayoutTransition layoutForDisplayType:](long a1)
{
    id currentLayout;
    if (!a1) {
        id sharedInstance = [FBMainDisplayLayoutPublisher sharedInstance];
        currentLayout = [sharedInstance currentLayout];
    } else {
        return nil;
    }
    return currentLayout;
}


id +[FBDisplayLayoutTransition flushLayoutForDisplayType:](long a1)
{
    if (!a1) {
        id sharedInstance = [FBMainDisplayLayoutPublisher sharedInstance];
        [sharedInstance flush];
        return sharedInstance;
    } else {
        return self;
    }
}


FBDisplayLayoutTransition *-[FBDisplayLayoutTransition init](void)
{
    return [self initWithDisplayType:7 name:0];
}


FBDisplayLayoutTransition *-[FBDisplayLayoutTransition initWithDisplayType:name:](long a1, id a2)
{
    FBDisplayLayoutTransition *v2 = [super init];
    if (v2 != nil) {
        if (a1) {
            v2->_publisher = nil;
        } else {
            v2->_publisher = [FBMainDisplayLayoutPublisher sharedInstance];
        }
        v2->_name = [a2 copy];
        v2->_transitionReason = nil;
        v2->_displayType = a1;
        v2->_interfaceOrientation = xmmword_1c4f5d230;
    }
    return v2;
}


void -[FBDisplayLayoutTransition dealloc](void)
{
    if (self->_transition != nil) {
        NSString *v1 = [NSString stringWithFormat:@"object deallocated while in a transition"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBDisplayLayoutTransition.m", 61, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    [super dealloc];
}


bool -[FBDisplayLayoutTransition isTransitioning](void)
{
    return self->_transition != nil;
}


id -[FBDisplayLayoutTransition description](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_name withName:@"name" skipIfNil:1];
    [v0 appendObject:self->_transitionReason withName:@"transitionReason" skipIfNil:1];
    bool isTransitioning = [self isTransitioning];
    [v0 appendBool:isTransitioning withName:@"transitioning"];
    if (self->_interfaceOrientation != 0) {
        id v3 = BSInterfaceOrientationDescription(self->_interfaceOrientation);
        [v0 appendObject:v3 withName:@"interfaceOrientation"];
    }
    if (self->_backlightLevel != -1) {
        [v0 appendInteger:self->_backlightLevel withName:@"backlightLevel"];
    }
    return [v0 build];
}


id -[FBDisplayLayoutTransition beginTransition](void)
{
    id<BSInvalidatable> v0 = self->_publisher;
    if (!self->_publisher || self->_transition != nil) {
        return v0;
    }
    v0 = [v0 transitionAssertionWithReason:self->_transitionReason];
    self->_transition = v0;
    if (self->_interfaceOrientation != 0) {
        v0 = [self->_publisher setInterfaceOrientation:self->_interfaceOrientation];
    }
    if (self->_backlightLevel == -1) {
        return v0;
    }
    return [self->_publisher setBacklightLevel:self->_backlightLevel];
}


id -[FBDisplayLayoutTransition endTransition](void)
{
    if (!self->_publisher || !self->_transition) {
        return self->_publisher;
    }
    if (self->_interfaceOrientation != 0) {
        [self->_publisher setInterfaceOrientation:self->_interfaceOrientation];
    }
    if (self->_backlightLevel != -1) {
        [self->_publisher setBacklightLevel:self->_backlightLevel];
    }
    [self->_transition invalidate];
    id<BSInvalidatable> v3 = self->_transition;
    self->_transition = nil;
    return v3;
}


long -[FBDisplayLayoutTransition displayType](void)
{
    return self->_displayType;
}


NSString *-[FBDisplayLayoutTransition name](void)
{
    return self->_name;
}


NSString *-[FBDisplayLayoutTransition transitionReason](void)
{
    return self->_transitionReason;
}


long -[FBDisplayLayoutTransition setTransitionReason:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 24);
}


long -[FBDisplayLayoutTransition interfaceOrientation](void)
{
    return self->_interfaceOrientation;
}


void -[FBDisplayLayoutTransition setInterfaceOrientation:](long a1)
{
    self->_interfaceOrientation = a1;
}


long -[FBDisplayLayoutTransition backlightLevel](void)
{
    return self->_backlightLevel;
}


void -[FBDisplayLayoutTransition setBacklightLevel:](long a1)
{
    self->_backlightLevel = a1;
}


void -[FBDisplayLayoutTransition .cxx_destruct](void)
{
    self->_transition = nil;
    self->_transitionReason = nil;
    self->_name = nil;
    self->_publisher = nil;
}
