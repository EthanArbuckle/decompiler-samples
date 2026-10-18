struct AUHelperInstance {
    NSXPCConnection *_xpcConnection; // +0x8
};

static long _OBJC_PROTOCOL_REFERENCE_$_AUHelperServiceProtocol;

AUHelperInstance *-[AUHelperInstance init](void)
{
    AUHelperInstance *v0 = [super init];
    if (v0 != nil) {
        v0->_xpcConnection = [AUHelperInstance xpcConnectionToHelper];
    }
    return v0;
}


AUHelperInstance *+[AUHelperInstance sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        AUHelperInstance *v4 = objc_allocWithZone(self);
        sharedInstance.DefaultInstance = [v4 init];
    });
    return sharedInstance.DefaultInstance;
}


id<AUHelperServiceProtocol> -[AUHelperInstance remoteObject](void)
{
    if (self->_xpcConnection == nil) {
        return nil;
    }
    return [self->_xpcConnection synchronousRemoteObjectProxyWithErrorHandler:^void(NSError *arg1) {
        os_log_t v2 = OS_LOG_DEFAULT;
        if (os_log_type_enabled(v2, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v2, OS_LOG_TYPE_ERROR, "%s: Failed to get remote object: %@", "-[AUHelperInstance remoteObject]_block_invoke", arg1);
        }
    }];
}


NSXPCConnection *+[AUHelperInstance xpcConnectionToHelper](void)
{
    NSXPCConnection *v17;
    uint8_t v12[176];
    NSXPCConnection *v1 = [[NSXPCConnection alloc] initWithMachServiceName:@"com.apple.accessoryupdater.launchauhelper" options:NSXPCConnectionPrivileged];
    if (v1 != nil) {
        NSXPCInterface *remoteObjectInterface3 = [NSXPCInterface interfaceWithProtocol:_OBJC_PROTOCOL_REFERENCE_$_AUHelperServiceProtocol];
        [v1 setRemoteObjectInterface:remoteObjectInterface3];
        Class v5 = [NSDictionary class];
        Class v6 = [NSArray class];
        Class v7 = [NSString class];
        Class v8 = [NSURL class];
        Class v9 = [NSError class];
        Class v10 = [NSData class];
        Class v11 = [NSNumber class];
        NSSet<Class> *v13 = [NSSet setWithObjects:v5, v6, v7, v8, v9, v10, v11, nil];
        NSSet *v0 = v13;
        NSXPCInterface *remoteObjectInterface = [v1 remoteObjectInterface];
        *(uint64_t *)&v12[144] = 0;
        *(uint32_t *)&v12[164] = 1;
        [remoteObjectInterface setClasses:v0 forSelector:@selector(userPreferenceSetObject:forSuite:withKey:) argumentIndex:0 ofReply:NO];
        NSXPCInterface *remoteObjectInterface2 = [v1 remoteObjectInterface];
        [remoteObjectInterface2 setClasses:v0 forSelector:@selector(userPreferenceObjectForSuite:withKey:withReply:) argumentIndex:*(uint64_t *)&v12[144] ofReply:*(uint32_t *)&v12[164] & 1];
        [v1 resume];
        v17 = v1;
    } else {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: Failed to get xpc connection", "+[AUHelperInstance xpcConnectionToHelper]");
        }
        v17 = nil;
    }
    return v17;
}


void -[AUHelperInstance .cxx_destruct](void)
{
    self->_xpcConnection = nil;
}
