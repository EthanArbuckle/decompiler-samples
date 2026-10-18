struct UARPAssetManagerServiceInstance {
    NSXPCConnection *_xpcConnection; // +0x8
    NSXPCListener *_xpcListener; // +0x10
    NSObject<OS_dispatch_queue> *_queue; // +0x18
    NSObject<OS_os_log> *_log; // +0x20
    NSMutableDictionary *_subscriptionToCacheRecords; // +0x28
    __weak id<UARPAssetManagerServiceDelegate> _delegate; // +0x30
    NSString *_serviceName; // +0x38
};

static long _OBJC_PROTOCOL_REFERENCE_$_UARPAssetManagerServiceProtocol;
static long _OBJC_PROTOCOL_REFERENCE_$_UARPAsyncAssetManagerDelegate;

UARPAssetManagerServiceInstance *-[UARPAssetManagerServiceInstance initWithServiceName:delegate:](id a1, id<UARPAssetManagerServiceDelegate> a2)
{
    UARPAssetManagerServiceInstance *v0 = [super init];
    if (v0 != nil) {
        v0->_log = os_log_create("com.apple.uarpassetmanager.uarp", "uarpAssetManager");
        v0->_serviceName = [a1 copy];
        const char *label = [v0->_serviceName UTF8String];
        v0->_queue = dispatch_queue_create(label, nil);
        v0->_delegate = a2;
        v0->_xpcListener = [NSXPCListener anonymousListener];
        [v0->_xpcListener setDelegate:v0];
        [v0->_xpcListener resume];
        v0->_subscriptionToCacheRecords = [NSMutableDictionary new];
    }
    return v0;
}


void -[UARPAssetManagerServiceInstance dealloc](void)
{
    [self releaseXPCConnection];
    [self->_xpcListener invalidate];
    [super dealloc];
}


bool -[UARPAssetManagerServiceInstance listener:shouldAcceptNewConnection:](NSXPCListener *a1, NSXPCConnection *a2)
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
    dispatch_sync(self->_queue, ^void(void) {
        NSXPCInterface *exportedInterface = [NSXPCInterface interfaceWithProtocol:_OBJC_PROTOCOL_REFERENCE_$_UARPAsyncAssetManagerDelegate];
        [v3 setExportedInterface:exportedInterface];
        [v3 setExportedObject:self];
        NSXPCInterface *exportedInterface2 = [v3 exportedInterface];
        NSSet<Class> *classes = [self encodedClasses];
        [exportedInterface2 setClasses:classes forSelector:@selector(assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:) argumentIndex:0 ofReply:NO];
        NSXPCInterface *exportedInterface3 = [v3 exportedInterface];
        NSSet<Class> *classes2 = [self encodedClasses];
        [exportedInterface3 setClasses:classes2 forSelector:@selector(assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:) argumentIndex:1 ofReply:NO];
        pid_t processIdentifier2 = [v3 processIdentifier];
        void (^interruptionHandler)(void) = ^void(void) {
            NSObject<OS_os_log> *v22 = self->_log;
            if (os_log_type_enabled(v22, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(v22, OS_LOG_TYPE_ERROR, "Connection to PID %d interrupted", processIdentifier2);
            }
        };
        [v3 setInterruptionHandler:interruptionHandler];
        void (^invalidationHandler)(void) = ^void(void) {
            NSObject<OS_os_log> *v23 = self->_log;
            if (os_log_type_enabled(v23, OS_LOG_TYPE_INFO)) {
                os_log_with_type(v23, OS_LOG_TYPE_INFO, "Connection from PID %d invalidated", processIdentifier2);
            }
        };
        [v3 setInvalidationHandler:invalidationHandler];
        [v3 _setQueue:self->_queue];
        [v3 resume];
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            pid_t processIdentifier = [v3 processIdentifier];
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "New connection from PID %d", processIdentifier);
        }
        (*(uint64_t *)&v5[8])->field_24 = 1;
    });
    void *v8 = *(uint64_t *)&v5[8];
    _Block_object_dispose(v5, 8);
    return *((uint8_t *)v8 + 24) & 1;
}


void -[UARPAssetManagerServiceInstance initializeAssetManagerServiceConnection](void)
{
    if (self->_xpcConnection) {
        return;
    }
    self->_xpcConnection = [[NSXPCConnection alloc] initWithServiceName:self->_serviceName];
    NSXPCInterface *v2 = [NSXPCInterface interfaceWithProtocol:_OBJC_PROTOCOL_REFERENCE_$_UARPAssetManagerServiceProtocol];
    [self->_xpcConnection setRemoteObjectInterface:v2];
    NSXPCInterface *remoteObjectInterface = [self->_xpcConnection remoteObjectInterface];
    NSSet<Class> *encodedClasses = [self encodedClasses];
    [remoteObjectInterface setClasses:encodedClasses forSelector:@selector(copyCacheWithReply:) argumentIndex:0 ofReply:YES];
    NSXPCInterface *remoteObjectInterface2 = [self->_xpcConnection remoteObjectInterface];
    NSSet<Class> *encodedClasses2 = [self encodedClasses];
    [remoteObjectInterface2 setClasses:encodedClasses2 forSelector:@selector(copySubscriptionsWithReply:) argumentIndex:0 ofReply:YES];
    NSXPCInterface *v9 = [NSXPCInterface interfaceWithProtocol:_OBJC_PROTOCOL_REFERENCE_$_UARPAsyncAssetManagerDelegate];
    [self->_xpcConnection setExportedInterface:v9];
    [self->_xpcConnection setExportedObject:self];
    [self->_xpcConnection resume];
}


void -[UARPAssetManagerServiceInstance releaseXPCConnection](void)
{
    [self->_xpcConnection invalidate];
    self->_xpcConnection = nil;
}


id -[UARPAssetManagerServiceInstance checkCacheForSubscription:](id a1)
{
    id v7;
    uint8_t v3[64];
    long v4;
    id v1 = a1;
    if ([self isSubscriptionSupported:v1]) {
        *(uint64_t *)&v3[0] = 0;
        *(uint64_t *)&v3[8] = &v3;
        *(uint32_t *)&v3[16] = 0x32000000;
        *(uint32_t *)&v3[20] = 48;
        *(uint64_t *)&v3[24] = &__Block_byref_object_copy_;
        *(uint64_t *)&v3[32] = &__Block_byref_object_dispose_;
        *(uint64_t *)&v3[40] = 0;
        dispatch_sync(self->_queue, ^void(void) {
            NSObject<OS_os_log> *oslog3 = self->_log;
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%@ Looking for cached asset for subscription:%@", self, v1);
            }
            *(uint64_t *)&v4[0] = 0;
            *(uint32_t *)&v4[16] = 0x32000000;
            *(uint32_t *)&v4[20] = 48;
            *(uint64_t *)&v4[24] = &__Block_byref_object_copy_;
            *(uint64_t *)&v4[32] = &__Block_byref_object_dispose_;
            *(uint64_t *)&v4[40] = [self->_subscriptionToCacheRecords objectForKeyedSubscript:v1];
            if (!*(uint64_t *)&v4[40]) {
                [self initializeAssetManagerServiceConnection];
                void (^v24)(NSError *) = ^void(NSError *arg1) {
                    [self releaseXPCConnection];
                };
                id v25 = [self->_xpcConnection synchronousRemoteObjectProxyWithErrorHandler:v24];
                [v25 checkCacheForSubscription:v1 withReply:^void(UARPAssetCacheRecord *arg1) {
                    objc_storeStrong(*(uint64_t *)&v4[8] + 40, arg1);
                }];
            }
            if (*(uint64_t *)&v4[40] != 0) {
                NSObject<OS_os_log> *oslog4 = self->_log;
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_INFO)) {
                    id v5 = *(uint64_t *)&v4[40];
                    os_log_with_type(oslog4, OS_LOG_TYPE_INFO, "%@ Cache record available:%{public}@ for accessory:%{public}@", self, v5, v1);
                }
                NSArray *deploymentRules = [*(uint64_t *)&v4[40] deploymentRules];
                bool v14 = isDeploymentAllowed(deploymentRules);
                if (v14) {
                    NSURL *assetURL = [*(uint64_t *)&v4[40] assetURL];
                    void *v16 = *(uint64_t *)&v3[8];
                    v16->field_40 = assetURL;
                } else {
                    NSObject<OS_os_log> *oslog = self->_log;
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        id v6 = *(uint64_t *)&v4[40];
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ Deployment not allowed for this asset:%{public}@", self, v6);
                    }
                }
            } else {
                NSObject<OS_os_log> *oslog2 = self->_log;
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%@ No cached record found for subscription:%{public}@", self, v1);
                }
            }
            _Block_object_dispose(v4, 8);
            *(uint64_t *)&v4[40] = nil;
        });
        v7 = (*(uint64_t *)&v3[8])->field_40;
        *(uint32_t *)&v3[48] = 1;
        _Block_object_dispose(v3, 8);
    } else {
        NSObject<OS_os_log> *oslog = self->_log;
        *(uint8_t *)&v3[55] = 2;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "%@ Current service does not support subscription: %@", self, v1);
        }
        v7 = nil;
        *(uint32_t *)&v3[48] = 1;
    }
    return v7;
}


id -[UARPAssetManagerServiceInstance copyCache](void)
{
    __block id v0 = nil;
    id v3 = self;
    void (^block)(void) = ^void(void) {
        os_log_t oslog = v3->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ copying entire cache for service", v3);
        }
        [v3 initializeAssetManagerServiceConnection];
        void (^buf)(NSError *) = ^void(NSError *arg1) {
            [v3 releaseXPCConnection];
        };
        id v6 = [v3->_xpcConnection synchronousRemoteObjectProxyWithErrorHandler:buf];
        void (^v7)(NSDictionary *) = ^void(NSDictionary *arg1) {
            id v13 = [arg1 copy];
            v0 = v13;
        };
        [v6 copyCacheWithReply:v7];
        if (![v0 count]) {
            os_log_t oslog2 = v3->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%@ No asset cache found for service", v3);
            }
        }
    };
    dispatch_sync(self->_queue, block);
    return v0;
}


id -[UARPAssetManagerServiceInstance copySubscriptions](void)
{
    __block id v0 = nil;
    id v3 = self;
    void (^block)(void) = ^void(void) {
        os_log_t oslog = v3->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ copying entire cache for service", v3);
        }
        [v3 initializeAssetManagerServiceConnection];
        void (^buf)(NSError *) = ^void(NSError *arg1) {
            [v3 releaseXPCConnection];
        };
        id v6 = [v3->_xpcConnection synchronousRemoteObjectProxyWithErrorHandler:buf];
        void (^v7)(NSArray *) = ^void(NSArray *arg1) {
            id v13 = [arg1 copy];
            v0 = v13;
        };
        [v6 copySubscriptionsWithReply:v7];
        if (![v0 count]) {
            os_log_t oslog2 = v3->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%@ No subscriptions found for service", v3);
            }
        }
    };
    dispatch_sync(self->_queue, block);
    return v0;
}


void -[UARPAssetManagerServiceInstance registerForSubscription:](id a1)
{
    id v1 = a1;
    if ([self isSubscriptionSupported:v1]) {
        void (^block)(void) = ^void(void) {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ Registering for subscription:%{public}@", self, v1);
            }
            [self initializeAssetManagerServiceConnection];
            void (^v11)(NSError *) = ^void(NSError *arg1) {
                [self releaseXPCConnection];
            };
            id v12 = [self->_xpcConnection remoteObjectProxyWithErrorHandler:v11];
            [v12 subscribeForAsset:v1];
        };
        dispatch_async(self->_queue, block);
    } else {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "%@ Current service does not support subscription: %@", self, v1);
        }
    }
}


void -[UARPAssetManagerServiceInstance checkForUpdate](void)
{
    id v1 = self;
    void (^block)(void) = ^void(void) {
        os_log_t oslog = v1->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ check for asset updates", v1);
        }
        [v1 initializeAssetManagerServiceConnection];
        void (^v4)(NSError *) = ^void(NSError *arg1) {
            [v1 releaseXPCConnection];
        };
        id v7 = [v1->_xpcConnection remoteObjectProxyWithErrorHandler:v4];
        [v7 checkForUpdate];
    };
    dispatch_async(self->_queue, block);
}


bool -[UARPAssetManagerServiceInstance queryIsBusy](void)
{
    __block bool v0 = false;
    id v2 = self;
    dispatch_sync(self->_queue, ^void(void) {
        os_log_t oslog = v2->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ check if asset manager service is busy", v2);
        }
        [v2 initializeAssetManagerServiceConnection];
        void (^v12)(NSError *) = ^void(NSError *arg1) {
            [v2 releaseXPCConnection];
        };
        id v7 = [v2->_xpcConnection synchronousRemoteObjectProxyWithErrorHandler:v12];
        void (^v10)(bool) = ^void(bool arg1) {
            v0 = arg1;
        };
        [v7 getIsBusyStatusWithReply:v10];
    });
    return v0;
}


NSString *-[UARPAssetManagerServiceInstance description](void)
{
    NSString *v0 = NSStringFromClass([self class]);
    return [NSString stringWithFormat:@"%@:", v0];
}


void -[UARPAssetManagerServiceInstance assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:](id<NSCopying> a1, id a2, bool a3)
{
    id<NSCopying> v1 = a1;
    id v3 = a2;
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ Found asset=%{public}@ for subscription: %{public}@", self, v3, v1);
    }
    dispatch_sync(self->_queue, ^void(void) {
        [self->_subscriptionToCacheRecords setObject:v3 forKeyedSubscript:v1];
    });
}


id -[UARPAssetManagerServiceInstance encodedClasses](void)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v2, "-[UARPAssetManagerServiceInstance encodedClasses]");
    }
    return nil;
}


bool -[UARPAssetManagerServiceInstance isSubscriptionSupported:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance isSubscriptionSupported:]");
    }
    return false;
}


void -[UARPAssetManagerServiceInstance subscribeForPersonality:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance subscribeForPersonality:]");
    }
}


id -[UARPAssetManagerServiceInstance checkCacheForPersonality:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance checkCacheForPersonality:]");
    }
    return nil;
}


void -[UARPAssetManagerServiceInstance checkAssetAvailabilityForDomain:](NSString *a1)
{
    NSString *v1 = a1;
    id v3 = [self copyCache];
    [v3 enumerateKeysAndObjectsUsingBlock:^void(id arg1, id arg2, bool *arg3) {
        Class v12 = [UARPAssetSubscription class];
        if ([arg1 isKindOfClass:v12]) {
            if ([arg2 isKindOfClass:[UARPAssetCacheRecord class]]) {
                UARPAssetSubscription *v13 = arg1;
                NSString *domain = [v13 domain];
                BOOL v15 = [domain isEqualToString:v1];
                if (v15 == 1) {
                    [self assetAvailabilityUpdateForSubscription:arg1 cacheRecord:arg2 asyncUpdate:YES];
                }
            }
        }
    }];
}


void -[UARPAssetManagerServiceInstance clearAssetCacheForDomain:](NSString *a1)
{
    NSString *v1 = nil;
    v1 = a1;
    dispatch_async(self->_queue, ^void(void) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%@ Clearing cache for domain:%{public}@", self, v1);
        }
        [self initializeAssetManagerServiceConnection];
        void (^v21)(NSError *) = ^void(NSError *arg1) {
            [self releaseXPCConnection];
        };
        id v22 = [self->_xpcConnection remoteObjectProxyWithErrorHandler:v21];
        [v22 clearAssetCacheForDomain:v1];
        NSMutableArray *array = [NSMutableArray array];
        NSArray *allKeys = [self->_subscriptionToCacheRecords allKeys];
        for (id v14 in allKeys) {
            id domain = [v14 domain];
            BOOL v16 = [domain isEqualToString:v1];
            if (v16 == 1) {
                [array addObject:v14];
            }
        }
        for (id v20 in array) {
            [self->_subscriptionToCacheRecords removeObjectForKey:v20];
        }
    });
}


void -[UARPAssetManagerServiceInstance primeCache:](id a1)
{
    id v1 = nil;
    v1 = a1;
    dispatch_async(self->_queue, ^void(void) {
        NSObject<OS_os_log> *oslog3 = self->_log;
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%@ Priming the cache for %@", self, v1);
        }
        id domain3 = [v1 domain];
        NSString *appleModelNumber2 = [v1 appleModelNumber];
        NSString *hwFusing = [v1 hwFusing];
        UARPAssetVersionBase *assetVersion2 = [v1 assetVersion];
        id v8 = createEndpointPersonality(domain3, appleModelNumber2, @"TempSerialNumber", hwFusing, 0, assetVersion2, 0, 0);
        if (v8 != nil) {
            int usePallas = [v1 usePallas];
            UARPAssetSubscriptionMobileAsset *v10 = createSubscriptionForPersonality(v8, usePallas, 0);
            if (v10 != nil) {
                NSMutableArray *array = [NSMutableArray array];
                NSArray *allKeys = [self->_subscriptionToCacheRecords allKeys];
                for (id v18 in allKeys) {
                    id domain = [v18 domain];
                    NSString *domain2 = [v1 domain];
                    BOOL v21 = [domain isEqualToString:domain2];
                    bool v24 = false;
                    if (v21 == 1) {
                        id identifier = [v18 identifier];
                        NSString *appleModelNumber = [v1 appleModelNumber];
                        v24 = [identifier isEqualToString:appleModelNumber] == 1;
                    }
                    if (v24) {
                        [array addObject:v18];
                    }
                }
                for (id v46 in array) {
                    [self->_subscriptionToCacheRecords removeObjectForKey:v46];
                }
                [self initializeAssetManagerServiceConnection];
                void (^v33)(NSError *) = ^void(NSError *arg1) {
                    [self releaseXPCConnection];
                };
                id v35 = [self->_xpcConnection remoteObjectProxyWithErrorHandler:v33];
                UARPAssetVersionBase *assetVersion = [v1 assetVersion];
                id filePath = [v1 filePath];
                [v35 primeCacheForSubscription:v10 assetVersion:assetVersion filePath:filePath];
            } else {
                NSObject<OS_os_log> *oslog = self->_log;
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ Could not create subscription for %@", self, v8);
                }
            }
        } else {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%@ Could not create personality for %@", self, v1);
            }
        }
    });
}


void -[UARPAssetManagerServiceInstance updateReachabilityForPersonality:reachable:](id a1, bool a2)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance updateReachabilityForPersonality:reachable:]");
    }
}


void -[UARPAssetManagerServiceInstance updateSettingsForPersonality:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance updateSettingsForPersonality:]");
    }
}


void -[UARPAssetManagerServiceInstance settingsChangedForSerialNumber:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v3 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v3, "-[UARPAssetManagerServiceInstance settingsChangedForSerialNumber:]");
    }
}


id -[UARPAssetManagerServiceInstance assetManagerService](void)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        NSString *v2 = NSStringFromClass([self class]);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%@ does not provide %s", v2, "-[UARPAssetManagerServiceInstance assetManagerService]");
    }
    return nil;
}


id<UARPAssetManagerServiceDelegate> -[UARPAssetManagerServiceInstance delegate](void)
{
    return self->_delegate;
}


NSString *-[UARPAssetManagerServiceInstance serviceName](void)
{
    return objc_getProperty(self, _cmd, 56, 1);
}


void -[UARPAssetManagerServiceInstance .cxx_destruct](void)
{
    self->_serviceName = nil;
    self->_delegate = nil;
    self->_subscriptionToCacheRecords = nil;
    self->_log = nil;
    self->_queue = nil;
    self->_xpcListener = nil;
    self->_xpcConnection = nil;
}
