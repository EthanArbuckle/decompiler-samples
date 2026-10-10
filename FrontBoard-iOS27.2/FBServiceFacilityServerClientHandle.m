struct FBServiceFacilityServerClientHandle {
    NSString *_facilityID; // +0x8
    BSServiceConnection *_connection; // +0x10
    FBProcess *_process; // +0x18
    BSProcessHandle *_processHandle; // +0x20
    id<FBSServiceFacilityClientContext> _context; // +0x28
};

FBServiceFacilityServerClientHandle *-[FBServiceFacilityServerClientHandle initWithFacilityID:connection:](id a1, BSServiceConnection *a2)
{
    uint8_t v10[32];
    if (!a1) {
        NSString *v13 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"facilityID"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v14, self, @"FBServiceFacilityServerClientHandle.m", 29, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v16 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"connection"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v17 = NSStringFromSelector(_cmd);
            NSString *v18 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v17, v18, self, @"FBServiceFacilityServerClientHandle.m", 30, v16);
        }
        _bs_set_crash_log_message([v16 UTF8String]);
        __break(0);
    }
    FBServiceFacilityServerClientHandle *v3 = [super init];
    if (v3 != nil) {
        v3->_facilityID = [a1 copy];
        v3->_connection = a2;
        v3->_processHandle = [a2 remoteProcess];
        id sharedInstance = [FBProcessManager sharedInstance];
        BSAuditToken *auditToken = [v3->_processHandle auditToken];
        if (!auditToken) {
            _memset(v10, 0, 32);
        } else {
            [auditToken realToken:&v10];
        }
        v3->_process = [sharedInstance registerProcessForAuditToken:&v10];
    }
    return v3;
}


BSProcessHandle *-[FBServiceFacilityServerClientHandle processHandle](void)
{
    return self->_processHandle;
}


void -[FBServiceFacilityServerClientHandle .cxx_destruct](void)
{
    self->_context = nil;
    self->_processHandle = nil;
    self->_process = nil;
    self->_connection = nil;
    self->_facilityID = nil;
}


NSString *-[FBServiceFacilityServerClientHandle facilityID](void)
{
    return self->_facilityID;
}


int -[FBServiceFacilityServerClientHandle pid](void)
{
    return [self->_processHandle pid];
}


long -[FBServiceFacilityServerClientHandle prettyProcessDescription](void)
{
    if (!self->_process) {
        return FBSProcessPrettyDescription(self->_processHandle);
    } else {
        return FBSProcessPrettyDescription(self->_process);
    }
}


void -[FBServiceFacilityServerClientHandle invalidate](void)
{
    [self->_connection invalidate];
}


RBSProcessIdentity *-[FBServiceFacilityServerClientHandle processIdentity](void)
{
    return [self->_process identity];
}


bool -[FBServiceFacilityServerClientHandle isSuspended](void)
{
    return [self->_process taskState] == 3;
}


void -[FBServiceFacilityServerClientHandle setContext:](id<FBSServiceFacilityClientContext> a1)
{
    if (self->_context != a1) {
        [self->_context setClientHandle:nil];
        self->_context = a1;
        [self->_context setClientHandle:self];
    }
}


BSServiceConnection *-[FBServiceFacilityServerClientHandle clientHandle_messageBuilder](void)
{
    return self->_connection;
}


id -[FBServiceFacilityServerClientHandle description](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_facilityID withName:0 skipIfNil:1];
    id v1 = self->_process;
    if (!self->_process) {
        v1 = self->_processHandle;
    }
    long v2 = FBSProcessPrettyDescription(v1);
    [v0 appendObject:@"remote" withName:v2 skipIfNil:1];
    return [v0 build];
}


id<FBSServiceFacilityClientContext> -[FBServiceFacilityServerClientHandle context](void)
{
    return self->_context;
}
