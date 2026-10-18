struct FBSystemShellInitializationContext {
    FBSystemShellInitializationOptions *_options; // +0x8
    bool _bootedDark; // +0x10
};

FBSystemShellInitializationContext *-[FBSystemShellInitializationContext _initWithOptions:](FBSystemShellInitializationOptions *a1)
{
    FBSystemShellInitializationContext *v1 = [super init];
    if (v1 != nil) {
        v1->_options = a1;
        _FBDarkBootHelper *v2 = [[_FBDarkBootHelper alloc] init];
        v1->_bootedDark = [v2 isBootingDark];
    }
    return v1;
}


unsigned long -[FBSystemShellInitializationContext lastExitReason](void)
{
    id currentProcess = [RBSProcessHandle currentProcess];
    id lastExitContext = [currentProcess lastExitContext];
    if (!lastExitContext) {
        return 0;
    }
    return [[[FBProcessExitContext alloc] initWithUnderlyingContext:lastExitContext] exitReason];
}


bool -[FBSystemShellInitializationContext wasBootedDark](void)
{
    return self->_bootedDark;
}


long -[FBSystemShellInitializationContext copyWithZone:](long a1)
{
    return self;
}


FBSystemShellInitializationOptions *-[FBSystemShellInitializationContext options](void)
{
    return self->_options;
}


void -[FBSystemShellInitializationContext .cxx_destruct](void)
{
    self->_options = nil;
}
