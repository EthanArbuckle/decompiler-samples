void -[FBMutableSystemShellInitializationOptions setInitializeReadyForInteraction:](bool a1)
{
    self->_initializeReadyForInteraction = a1;
}


void -[FBMutableSystemShellInitializationOptions setResetDarkBootState:](bool a1)
{
    self->_resetDarkBootState = a1;
}


void -[FBMutableSystemShellInitializationOptions setShouldWaitForMigrator:](bool a1)
{
    self->_shouldWaitForMigrator = a1;
}


void -[FBMutableSystemShellInitializationOptions setInitializeDisplayManager:](bool a1)
{
    self->_initializeDisplayManager = a1;
}


void -[FBMutableSystemShellInitializationOptions setSystemSleepInterval:](long a1)
{
    double v0;
    self->_systemSleepInterval = v0;
}


void -[FBMutableSystemShellInitializationOptions setRegisterAdditionalServicesBlock:](id a1)
{
    self->_registerServicesBlock = [a1 copy];
}


void -[FBMutableSystemShellInitializationOptions setIndependentWatchdogPortName:](id a1)
{
    self->_independentWatchdogPortName = [a1 copy];
}


FBSystemShellInitializationOptions *-[FBMutableSystemShellInitializationOptions copyWithZone:](long a1)
{
    return [[FBSystemShellInitializationOptions alloc] _initWithOptions:self];
}
