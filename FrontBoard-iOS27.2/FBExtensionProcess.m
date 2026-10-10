struct FBExtensionProcess {
    FBSExtensionInfo *_extensionInfo; // +0x170
    int _hostPID; // +0x178
    struct os_unfair_lock_s _hostProcessLock; // +0x17c
    FBProcess *_lock_hostProcess; // +0x180
};

void -[FBExtensionProcess .cxx_destruct](void)
{
    self->_lock_hostProcess = nil;
    self->_extensionInfo = nil;
}


FBSExtensionInfo *-[FBExtensionProcess extensionInfo](void)
{
    return self->_extensionInfo;
}


int -[FBExtensionProcess isExtensionProcess](void)
{
    return 1;
}


void -[FBExtensionProcess _finishInit](void)
{
    long isXPCService = [self->_identity isXPCService];
    RBSProcessIdentity *v3 = self->_identity;
    if ((isXPCService & 1) == 0) {
        NSString *v1 = [NSString stringWithFormat:@"cannot initialize FBExtensionProcess without an extension identity (%@)", v3];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBExtensionProcess.m", 28, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    long xpcServiceIdentifier = [v3 xpcServiceIdentifier];
    id v5 = [LSPlugInKitProxy pluginKitProxyForIdentifier:xpcServiceIdentifier];
    if (v5 != nil) {
        self->_extensionInfo = [[FBSExtensionInfo alloc] _initWithPlugInKitProxy:v5];
    }
    if (![self->_identity hostIdentifier]) {
        self->_hostPID = -1;
    } else {
        id hostIdentifier = [self->_identity hostIdentifier];
        self->_hostPID = [hostIdentifier pid];
    }
    memset(&self->_hostProcessLock, 0, 4);
    [super _finishInit];
}


FBProcess *-[FBExtensionProcess hostProcess](void)
{
    os_unfair_lock_lock(&self->_hostProcessLock);
    FBProcess *v2 = self->_lock_hostProcess;
    if (!self->_lock_hostProcess) {
        if (self->_hostPID < 1) {
            v2 = nil;
        } else {
            FBProcessManager *v4 = self->_processManager;
            self->_lock_hostProcess = [v4 processForPID:self->_hostPID];
            v2 = self->_lock_hostProcess;
        }
    }
    os_unfair_lock_unlock(&self->_hostProcessLock);
    return v2;
}


id -[FBExtensionProcess succinctDescriptionBuilder](void)
{
    id v1 = [super succinctDescriptionBuilder];
    NSString *typeIdentifier = [self->_extensionInfo typeIdentifier];
    [v1 appendObject:typeIdentifier withName:@"typeID" skipIfNil:1];
    return v1;
}


int -[FBExtensionProcess hostPID](void)
{
    return self->_hostPID;
}
