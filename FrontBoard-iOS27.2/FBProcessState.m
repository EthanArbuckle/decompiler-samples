struct FBProcessState {
    bool _running; // +0x8
    bool _foreground; // +0x9
    bool _debugging; // +0xa
    int _pid; // +0xc
    long _taskState; // +0x10
    long _visibility; // +0x18
};

FBProcessState *-[FBProcessState copyWithZone:](long a1)
{
    FBProcessState *v0 = [[FBProcessState alloc] initWithPid:[self pid]];
    long taskState = [self taskState];
    [v0 setTaskState:taskState];
    long visibility = [self visibility];
    [v0 setVisibility:visibility];
    bool isDebugging = [self isDebugging];
    [v0 setDebugging:isDebugging];
    return v0;
}


FBProcessState *-[FBProcessState initWithPid:](int a1)
{
    long v1;
    FBProcessState *v0 = [self init];
    if (!v0) {
        return v0;
    }
    v0->_pid = a1;
    v0->_visibility = 0;
    if (a1 < 1) {
        v1 = 0;
    } else {
        v0->_running = YES;
        v1 = 2;
    }
    v0->_taskState = v1;
    return v0;
}


FBProcessState *-[FBProcessState init](void)
{
    FBProcessState *v1 = [super init];
    if (v1 != nil) {
        v1->_pid = -1;
    }
    return v1;
}


int -[FBProcessState pid](void)
{
    return self->_pid;
}


long -[FBProcessState visibility](void)
{
    return self->_visibility;
}


bool -[FBProcessState isForeground](void)
{
    return self->_foreground;
}


void -[FBProcessState setTaskState:](long a1)
{
    if (self->_taskState == a1) {
        return;
    }
    self->_taskState = a1;
    self->_running = (a1 & 0xfffffffffffffffe) == 2;
}


void -[FBProcessState setVisibility:](long a1)
{
    if (self->_visibility == a1) {
        return;
    }
    self->_visibility = a1;
    self->_foreground = (a1 & 0xfffffffffffffffe) == 2;
}


void -[FBProcessState setDebugging:](bool a1)
{
    self->_debugging = a1;
}


bool -[FBProcessState isDebugging](void)
{
    return self->_debugging;
}


long -[FBProcessState taskState](void)
{
    return self->_taskState;
}


bool -[FBProcessState isRunning](void)
{
    return self->_running;
}


bool -[FBProcessState isEqual:](id a1)
{
    bool v1;
    if (self == a1) {
        return true;
    }
    Class v2 = [self class];
    Class v3 = [a1 class];
    if (v2 != v3 || self->_pid != a1->field_12 || self->_taskState != a1->field_16 || self->_visibility != a1->field_24) {
        v1 = false;
    } else {
        v1 = self->_debugging == a1->field_10;
    }
    return v1;
}


void -[FBProcessState setPid:](int a1)
{
    self->_pid = a1;
}


long -[FBProcessState description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBProcessState succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBProcessState succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendInt:self->_pid withName:@"pid"];
    [v0 appendObject:(self->_taskState > 3) ? 0 : (&qword_1e17d70f8)[self->_taskState] withName:@"taskState"];
    [v0 appendObject:(self->_visibility > 3) ? 0 : (&qword_1e17d7118)[self->_visibility] withName:@"visibility"];
    [v0 appendBool:self->_debugging withName:@"debugging" ifEqualTo:1];
    return v0;
}


id -[FBProcessState descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


long -[FBProcessState descriptionBuilderWithMultilinePrefix:](long a1)
{
    return [self succinctDescriptionBuilder];
}
