struct FBSceneLayer {
    long _type; // +0x8
    double _level; // +0x10
    long _alignment; // +0x18
    unsigned int _contextID; // +0x20
    unsigned long _renderID; // +0x28
    FBSSceneIdentityToken *_proxiedKeyboardOwner; // +0x30
};

void -[FBSceneLayer .cxx_destruct](void)
{
    self->_proxiedKeyboardOwner = nil;
}


long -[FBSceneLayer isEqual:](id a1)
{
    id v0 = a1;
    id v1 = [BSEqualsBuilder builderWithObject:a1 ofExpectedClass:[FBSceneLayer class]];
    [v1 appendInteger:self->_type counterpart:^long(void) {
        return [v0 type];
    }];
    [v1 appendUnsignedInteger:self->_contextID counterpart:^unsigned long(void) {
        return [v0 contextID];
    }];
    [v1 appendInt64:self->_renderID counterpart:^long(void) {
        return [v0 renderID];
    }];
    [v1 appendObject:self->_proxiedKeyboardOwner counterpart:^NSObject *(void) {
        return [v0 proxiedKeyboardOwner];
    }];
    objc_msgSend$appendCGFloat:counterpart:(v1, ^double(void) {
        return [v0 level];
    }, self->_level);
    [v1 appendInteger:self->_alignment counterpart:^long(void) {
        return [v0 alignment];
    }];
    return [v1 isEqual];
}


FBSceneLayer *-[FBSceneLayer initWithContextID:renderID:](unsigned int a1, unsigned long a2)
{
    FBSceneLayer *v1 = [super init];
    if (v1 != nil) {
        v1->_contextID = a1;
        v1->_renderID = a2;
        v1->_type = 1;
    }
    return v1;
}


long -[FBSceneLayer type](void)
{
    return self->_type;
}


unsigned long -[FBSceneLayer renderID](void)
{
    return self->_renderID;
}


unsigned long -[FBSceneLayer hash](void)
{
    id builder = [BSHashBuilder builder];
    [builder appendInteger:self->_type];
    [builder appendUnsignedInteger:self->_contextID];
    [builder appendInt64:self->_renderID];
    [builder appendObject:self->_proxiedKeyboardOwner];
    [builder appendCGFloat:self->_level];
    [builder appendInteger:self->_alignment];
    return [builder hash];
}


id +[FBSceneLayer layerWithFBSSceneLayer:](id a1)
{
    id v4;
    long type = [a1 type];
    if (type == 2) {
        id keyboardOwner = [a1 keyboardOwner];
        id v3 = [self alloc];
        if (keyboardOwner) {
            v4 = [v3 initAsKeyboardProxyWithOwner:[a1 keyboardOwner]];
        } else {
            v4 = [v3 initAsKeyboard];
        }
    } else if (type == 1) {
        id v6 = [self alloc];
        unsigned int contextID = [a1 contextID];
        v4 = [v6 initWithContextID:contextID renderID:[a1 renderID]];
    } else {
        v4 = nil;
    }
    double level = [a1 level];
    [v4 setLevel:level];
    long alignment = [a1 alignment];
    [v4 setAlignment:alignment];
    return v4;
}


void -[FBSceneLayer setLevel:](long a1)
{
    double v0;
    self->_level = v0;
}


unsigned int -[FBSceneLayer contextID](void)
{
    return self->_contextID;
}


long -[FBSceneLayer alignment](void)
{
    return self->_alignment;
}


long -[FBSceneLayer copyWithZone:](long a1)
{
    return self;
}


double -[FBSceneLayer level](void)
{
    return self->_level;
}


FBSSceneIdentityToken *-[FBSceneLayer proxiedKeyboardOwner](void)
{
    return self->_proxiedKeyboardOwner;
}


void -[FBSceneLayer setAlignment:](long a1)
{
    self->_alignment = a1;
}


long -[FBSceneLayer description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneLayer descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


long -[FBSceneLayer descriptionBuilderWithMultilinePrefix:](long a1)
{
    return [self succinctDescriptionBuilder];
}


id -[FBSceneLayer succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    NSString *v1 = FBSceneLayerTypeDescription(self->_type);
    [v0 appendObject:v1 withName:@"type"];
    if (self->_contextID != 0) {
        NSString *v3 = [NSString stringWithFormat:@"0x%x (%u)", self->_contextID, self->_contextID];
        [v0 appendObject:v3 withName:@"contextID"];
    }
    if (self->_renderID != 0) {
        NSString *v5 = [NSString stringWithFormat:@"0x%llx", self->_renderID];
        [v0 appendObject:v5 withName:@"renderID"];
    }
    id v6 = NSStringFromFBSSceneLayerAlignment([self alignment]);
    [v0 appendObject:v6 withName:@"alignment"];
    return v0;
}


FBSceneLayer *-[FBSceneLayer initAsKeyboard](void)
{
    FBSceneLayer *v1 = [super init];
    if (v1 != nil) {
        v1->_type = 3;
    }
    return v1;
}


FBSceneLayer *-[FBSceneLayer initAsKeyboardProxyWithOwner:](FBSSceneIdentityToken *a1)
{
    FBSceneLayer *v1 = [super init];
    if (v1 != nil) {
        v1->_type = 4;
        v1->_proxiedKeyboardOwner = a1;
    }
    return v1;
}


long -[FBSceneLayer externalSceneID](void)
{
    return 0;
}


bool -[FBSceneLayer isKeyboardLayer](void)
{
    return self->_type == 3;
}


bool -[FBSceneLayer isKeyboardProxyLayer](void)
{
    return self->_type == 4;
}


id -[FBSceneLayer succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


void -[FBSceneLayer init](void)
{
    NSString *v1 = [NSString stringWithFormat:@"you should not be instantiating this class"];
    if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromSelector(_cmd);
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSceneLayer.m", 59, v1);
    }
    _bs_set_crash_log_message([v1 UTF8String]);
    __break(0);
}
