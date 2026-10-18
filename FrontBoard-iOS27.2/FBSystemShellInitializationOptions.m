struct FBSystemShellInitializationOptions {
    bool _initializeReadyForInteraction; // +0x8
    bool _shouldWaitForMigrator; // +0x9
    bool _resetDarkBootState; // +0xa
    bool _initializeDisplayManager; // +0xb
    NSString *_independentWatchdogPortName; // +0x10
    double _systemSleepInterval; // +0x18
    id _registerServicesBlock; // +0x20
};

FBSystemShellInitializationOptions *-[FBSystemShellInitializationOptions _initWithOptions:](id a1)
{
    FBSystemShellInitializationOptions *v1 = [self init];
    if (v1 != nil) {
        v1->_resetDarkBootState = a1->field_10;
        v1->_initializeReadyForInteraction = a1->field_8;
        v1->_shouldWaitForMigrator = a1->field_9;
        v1->_systemSleepInterval = a1->field_24;
        v1->_independentWatchdogPortName = a1->field_16;
        v1->_initializeDisplayManager = a1->field_11;
        v1->_registerServicesBlock = [a1->field_32 copy];
    }
    return v1;
}


FBSystemShellInitializationOptions *-[FBSystemShellInitializationOptions init](void)
{
    FBSystemShellInitializationOptions *v1 = [super init];
    if (v1 != nil) {
        v1->_shouldWaitForMigrator = YES;
        v1->_initializeDisplayManager = YES;
        v1->_systemSleepInterval = 1.0;
    }
    return v1;
}


unsigned long -[FBSystemShellInitializationOptions hash](void)
{
    id builder = [BSHashBuilder builder];
    [builder appendBool:self->_resetDarkBootState];
    [builder appendBool:self->_initializeReadyForInteraction];
    [builder appendBool:self->_shouldWaitForMigrator];
    [builder appendBool:self->_initializeDisplayManager];
    [builder appendDouble:self->_systemSleepInterval];
    id v1 = _Block_copy(self->_registerServicesBlock);
    [builder appendObject:v1];
    [builder appendObject:self->_independentWatchdogPortName];
    return [builder hash];
}


int -[FBSystemShellInitializationOptions isEqual:](id a1)
{
    if (self == a1) {
        return 1;
    }
    if ([a1 isKindOfClass:[self class]] && BSEqualBools(self->_initializeReadyForInteraction, a1->field_8) && BSEqualBools(self->_resetDarkBootState, a1->field_10) != 0 && BSEqualBools(self->_shouldWaitForMigrator, a1->field_9) != 0) {
        long v3 = BSEqualBools(self->_initializeDisplayManager, a1->field_11);
        if (v3 != 0 && BSFloatEqualToFloat(v3) != 0) {
            id v4 = _Block_copy(self->_registerServicesBlock);
            id v5 = _Block_copy(a1->field_32);
            return (!BSEqualObjects(v4, v5)) ? 0 : BSEqualObjects(self->_independentWatchdogPortName, a1->field_16);
        }
    }
    return 0;
}


long -[FBSystemShellInitializationOptions copyWithZone:](long a1)
{
    return self;
}


FBMutableSystemShellInitializationOptions *-[FBSystemShellInitializationOptions mutableCopyWithZone:](long a1)
{
    return [[FBMutableSystemShellInitializationOptions alloc] _initWithOptions:self];
}


bool -[FBSystemShellInitializationOptions initializeReadyForInteraction](void)
{
    return self->_initializeReadyForInteraction;
}


bool -[FBSystemShellInitializationOptions resetDarkBootState](void)
{
    return self->_resetDarkBootState;
}


bool -[FBSystemShellInitializationOptions shouldWaitForMigrator](void)
{
    return self->_shouldWaitForMigrator;
}


double -[FBSystemShellInitializationOptions systemSleepInterval](void)
{
    return self->_systemSleepInterval;
}


id -[FBSystemShellInitializationOptions registerAdditionalServicesBlock](void)
{
    return self->_registerServicesBlock;
}


NSString *-[FBSystemShellInitializationOptions independentWatchdogPortName](void)
{
    return self->_independentWatchdogPortName;
}


bool -[FBSystemShellInitializationOptions initializeDisplayManager](void)
{
    return self->_initializeDisplayManager;
}


void -[FBSystemShellInitializationOptions .cxx_destruct](void)
{
    self->_registerServicesBlock = nil;
    self->_independentWatchdogPortName = nil;
}
