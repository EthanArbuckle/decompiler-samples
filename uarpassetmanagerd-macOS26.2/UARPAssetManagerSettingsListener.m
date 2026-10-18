struct UARPAssetManagerSettingsListener {
    UARPAssetManagerController *_controller; // +0x8
    NSXPCListener *_listener; // +0x10
    NSObject<OS_os_log> *_xpcLog; // +0x18
    NSObject<OS_dispatch_queue> *_internalQueue; // +0x20
};

static long _OBJC_PROTOCOL_REFERENCE_$_AUInternalSettingsAssetManagerXPCProvider;
static long kAUSettingsAssetManagerXpcServiceName;

UARPAssetManagerSettingsListener *-[UARPAssetManagerSettingsListener initWithController:dispatchQueue:](UARPAssetManagerController *a1, NSObject<OS_dispatch_queue> *a2)
{
    UARPAssetManagerSettingsListener *v0 = [super init];
    if (v0 != nil) {
        v0->_controller = a1;
        v0->_internalQueue = a2;
        v0->_xpcLog = os_log_create("com.apple.accessoryupdater.uarp", "observer");
        v0->_listener = [[NSXPCListener alloc] initWithMachServiceName:kAUSettingsAssetManagerXpcServiceName];
        [v0->_listener setDelegate:v0];
        [v0->_listener resume];
    }
    return v0;
}


void -[UARPAssetManagerSettingsListener dealloc](void)
{
    [self->_listener invalidate];
    [super dealloc];
}


bool -[UARPAssetManagerSettingsListener listener:shouldAcceptNewConnection:](NSXPCListener *a1, NSXPCConnection *a2)
{
    NSXPCListener *v0;
    uint8_t v5[32];
    v0.field_8 = _cmd;
    NSXPCConnection *v3 = nil;
    v3 = a2;
    *(uint64_t *)&v5[0] = 0;
    *(uint64_t *)&v5[8] = &v5;
    *(uint32_t *)&v5[16] = 0x20000000;
    *(uint32_t *)&v5[20] = 32;
    *(uint8_t *)&v5[24] = 0;
    dispatch_sync(self->_internalQueue, ^void(void) {
        __weak id v20;
        if ([self xpcConnectionHasEntitlement:v3]) {
            NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:_OBJC_PROTOCOL_REFERENCE_$_AUInternalSettingsAssetManagerXPCProvider];
            [v3 setExportedInterface:exportedInterface];
            [v3 setExportedObject:self];
            pid_t processIdentifier3 = [v3 processIdentifier];
            v20 = self;
            void (^interruptionHandler)(void) = ^void(void) {
                os_log_t v24 = v20->_xpcLog;
                if (os_log_type_enabled(v24, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v24, OS_LOG_TYPE_ERROR, "Connection to PID %d interrupted", processIdentifier3);
                }
            };
            [v3 setInterruptionHandler:interruptionHandler];
            void (^invalidationHandler)(void) = ^void(void) {
                os_log_t v25 = v20->_xpcLog;
                if (os_log_type_enabled(v25, OS_LOG_TYPE_INFO)) {
                    os_log_with_type(v25, OS_LOG_TYPE_INFO, "Connection from PID %d invalidated", processIdentifier3);
                }
            };
            [v3 setInvalidationHandler:invalidationHandler];
            [v3 _setQueue:self->_internalQueue];
            [v3 resume];
            NSObject<OS_os_log> *oslog2 = self->_xpcLog;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                pid_t processIdentifier = [v3 processIdentifier];
                os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "New connection from PID %d", processIdentifier);
            }
            (*(uint64_t *)&v5[8])->field_24 = 1;
        } else {
            NSObject<OS_os_log> *oslog = self->_xpcLog;
            v20.field_15 = 16;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                pid_t processIdentifier2 = [v3 processIdentifier];
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Client connection from PID %{public}d not entitled", processIdentifier2);
            }
        }
    });
    void *v8 = *(uint64_t *)&v5[8];
    _Block_object_dispose(v5, 8);
    return *((uint8_t *)v8 + 24) & 1;
}


bool -[UARPAssetManagerSettingsListener xpcConnectionHasEntitlement:](id a1)
{
    id v2 = [a1 valueForEntitlement:@"com.apple.accessoryupdater.launchauhelper.entitled"];
    Class v3 = [NSNumber class];
    if ([v2 isKindOfClass:v3] == 1 && [v2 boolValue] == 1) {
        return true;
    }
    NSObject<OS_os_log> *oslog = self->_xpcLog;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        int processIdentifier = [a1 processIdentifier];
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Connection from PID %d does not have the correct entitlement", processIdentifier);
    }
    return false;
}


void -[UARPAssetManagerSettingsListener settingsChangedForSerialNumber:](id a1)
{
    [self->_controller settingsChangedForSerialNumber:a1];
}


void -[UARPAssetManagerSettingsListener .cxx_destruct](void)
{
    self->_internalQueue = nil;
    self->_xpcLog = nil;
    self->_listener = nil;
    self->_controller = nil;
}
