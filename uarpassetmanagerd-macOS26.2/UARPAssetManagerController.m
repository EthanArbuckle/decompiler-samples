struct UARPAssetManagerController {
    long _idleExitTimeoutSec; // +0x8
    NSObject<OS_dispatch_source> *_idleTimer; // +0x10
    NSObject<OS_dispatch_queue> *_internalQueue; // +0x18
    NSObject<OS_os_log> *_log; // +0x20
    UARPAssetManagerListener *_assetManagerListener; // +0x28
    UARPAssetManagerSettingsListener *_settingsListener; // +0x30
    NSObject<OS_xpc_event_publisher> *_publisher; // +0x38
    NSMutableDictionary *_subscriberTokens; // +0x40
    UARPAssetManagerServiceManager *_assetManagerServiceManager; // +0x48
    NSDate *_lastSettingsPaneTriggeredCacheRefreshDate; // +0x50
};

UARPAssetManagerController *-[UARPAssetManagerController initWithIdleTimeout:](long a1)
{
    UARPAssetManagerController *v0 = [super init];
    if (v0 != nil) {
        v0->_idleExitTimeoutSec = a1;
        v0->_internalQueue = dispatch_queue_create("com.apple.AsyncAssetManager.queue", nil);
        v0->_assetManagerServiceManager = [[UARPAssetManagerServiceManager alloc] initWithDelegate:v0];
        v0->_log = os_log_create("com.apple.uarpassetmanager.uarp", "uarpAssetManager");
        v0->_assetManagerListener = [[UARPAssetManagerListener alloc] initWithDelegate:v0];
        v0->_settingsListener = [[UARPAssetManagerSettingsListener alloc] initWithController:v0 dispatchQueue:v0->_internalQueue];
        [v0 setActivityForUARPPeriodicLaunch];
        v0->_subscriberTokens = [NSMutableDictionary new];
        const char *UTF8String = [kUARPAssetAvailabilityXPCEventName UTF8String];
        v0->_publisher = xpc_event_publisher_create(UTF8String, v0->_internalQueue);
        __weak UARPAssetManagerController *v27 = v0;
        xpc_event_publisher_set_handler(v0->_publisher, ^void(unsigned int arg1, unsigned long arg2, NSObject<OS_xpc_object> *arg3) {
            [v27 handleXPCEventWithAction:arg1 token:arg2 descriptor:arg3];
        });
        xpc_event_publisher_set_error_handler(v0->_publisher, ^void(int arg1) {
            [v27 handleXPCEventError:arg1];
        });
        xpc_event_publisher_activate(v0->_publisher);
    }
    return v0;
}


void -[UARPAssetManagerController setActivityForUARPPeriodicLaunch](void)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Registering Activity handler for = %s", "com.apple.UARPAssetManager.periodicFirmwareCheck");
    }
    xpc_activity_register("com.apple.UARPAssetManager.periodicFirmwareCheck", XPC_ACTIVITY_CHECK_IN, ^void(NSObject<OS_xpc_object> *arg1) {
        xpc_activity_state_t v3 = xpc_activity_get_state(arg1);
        NSObject<OS_os_log> *oslog3 = self->_log;
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "UARP Periodic Firmware Check Kicked Off - STATE=%ld", v3);
        }
        if (!v3) {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "Handling CHECKIN state for activity: %s", "com.apple.UARPAssetManager.periodicFirmwareCheck");
            }
        } else if (v3 == 2) {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "%s: Handling RUN state for activity: %s", "-[UARPAssetManagerController setActivityForUARPPeriodicLaunch]_block_invoke", "com.apple.UARPAssetManager.periodicFirmwareCheck");
            }
            xpc_activity_set_state(arg1, 4);
            [self->_assetManagerServiceManager checkForUpdate];
            xpc_activity_set_state(arg1, 5);
        }
    });
}


void -[UARPAssetManagerController handleXPCEventError:](int a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        char *v2 = xpc_strerror(a1);
        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Received error: %{public}s", v2);
    }
}


void -[UARPAssetManagerController handleXPCEventWithAction:token:descriptor:](unsigned int a1, unsigned long a2, xpc_object_t a3)
{
    xpc_object_t xdict = nil;
    xdict = a3;
    NSObject<OS_os_log> *oslog4 = self->_log;
    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog4, OS_LOG_TYPE_DEBUG, "Received event for token=%llu", a2);
    }
    if (a1) {
        if (a1 == 1) {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "Remove Subscriber with token=%llu", a2);
            }
            [self removeXPCEventSubscriber:a2];
        } else if (a1 == 2) {
            NSObject<OS_os_log> *oslog3 = self->_log;
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_DEBUG, "Received initial barrier");
            }
        }
    } else {
        const char *key = [kUARPAssetAvailabilityXPCEventDomainKey UTF8String];
        const char *v6 = xpc_dictionary_get_string(xdict, key);
        if (v6 != 0) {
            NSObject<OS_os_log> *oslog5 = self->_log;
            if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog5, OS_LOG_TYPE_DEBUG, "Add Subscriber for %s with token=%llu", v6, a2);
            }
            NSString *v10 = [NSString stringWithUTF8String:v6];
            [self addXPCEventSubscriber:a2 withDomain:v10];
        } else {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "No domain found for registration! Ignoring");
            }
        }
    }
    xdict = nil;
}


void -[UARPAssetManagerController addXPCEventSubscriber:withDomain:](unsigned long a1, NSString *a2)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Adding subscriber token for identifier %{public}@", a2);
    }
    id v5 = [self->_subscriberTokens objectForKeyedSubscript:a2];
    if (!v5) {
        NSMutableSet *v6 = [NSMutableSet new];
        v5 = v6;
        [self->_subscriberTokens setObject:v5 forKeyedSubscript:a2];
    }
    NSNumber *v8 = [NSNumber numberWithUnsignedLongLong:a1];
    [v5 addObject:v8];
}


void -[UARPAssetManagerController removeXPCEventSubscriber:](unsigned long a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Removing subscriber token");
    }
    NSArray *allKeys = [self->_subscriberTokens allKeys];
    for (id v8 in allKeys) {
        id v9 = [self->_subscriberTokens objectForKeyedSubscript:v8];
        if (v9 != nil) {
            NSNumber *v10 = [NSNumber numberWithUnsignedLongLong:a1];
            [v9 removeObject:v10];
        }
    }
}


void -[UARPAssetManagerController subscribeForPersonality:](id a1)
{
    [self->_assetManagerServiceManager subscribeForPersonality:a1];
}


void -[UARPAssetManagerController updateReachabilityForPersonality:reachable:](id a1, bool a2)
{
    [self->_assetManagerServiceManager updateReachabilityForPersonality:a1 reachable:a2];
}


void -[UARPAssetManagerController updateSettingsForPersonality:](id a1)
{
    [self->_assetManagerServiceManager updateSettingsForPersonality:a1];
}


id -[UARPAssetManagerController getAssetURLForPersonality:](id a1)
{
    return [self->_assetManagerServiceManager checkCacheForPersonality:a1];
}


void -[UARPAssetManagerController checkAssetAvailabilityForDomain:](id a1)
{
    [self->_assetManagerServiceManager checkAssetAvailabilityForDomain:a1];
}


void -[UARPAssetManagerController clearAssetCacheForDomain:](id a1)
{
    [self->_assetManagerServiceManager clearAssetCacheForDomain:a1];
}


void -[UARPAssetManagerController primeCache:](id a1)
{
    [self->_assetManagerServiceManager primeCache:a1];
}


void -[UARPAssetManagerController notifySubscribers:withDomain:](xpc_object_t a1, id a2)
{
    xpc_object_t object = nil;
    object = a1;
    id v4 = nil;
    v4 = a2;
    xpc_object_t v5 = xpc_copy(object);
    xpc_object_t v7 = v5;
    dispatch_async(self->_internalQueue, ^void(void) {
        id v21 = [self->_subscriberTokens objectForKeyedSubscript:v4];
        if ([v21 count] != 0) {
            for (NSNumber *v24 in v21) {
                NSObject<OS_os_log> *oslog3 = self->_log;
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                    unsigned long unsignedLongLongValue3 = [v24 unsignedLongLongValue];
                    os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "Sending notification %{public}@ to %{public}llu", v7, unsignedLongLongValue3);
                }
                unsigned long unsignedLongLongValue = [v24 unsignedLongLongValue];
                long v14 = xpc_event_publisher_fire(self->_publisher, unsignedLongLongValue, v7);
                if (v14 != 0) {
                    NSObject<OS_os_log> *oslog = self->_log;
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        unsigned long unsignedLongLongValue2 = [v24 unsignedLongLongValue];
                        char *v18 = xpc_strerror(v14);
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Sending %{public}@ to %{public}llu failed with error: %{public}s", v7, unsignedLongLongValue2, v18);
                    }
                }
            }
        } else {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Did not find any subscribers for domain %{public}@", v4);
            }
        }
    });
}


void -[UARPAssetManagerController assetAvailabilityUpdateForPersonality:serialNumbers:assetVersion:creationDate:status:](id a1, id a2, id a3, id a4, long a5)
{
    int v40;
    if (a5 == 2) {
        NSError *v9 = nil;
        NSData *v12 = [NSKeyedArchiver archivedDataWithRootObject:a1 requiringSecureCoding:YES error:&v9];
        if (v12 != nil) {
            xpc_object_t xdict = xpc_dictionary_create(NULL, NULL, 0);
            const char *key = [kUARPAssetAvailabilityXPCEventPersonalityKey UTF8String];
            const void *bytes = [v12 bytes];
            NSUInteger length = [v12 length];
            xpc_dictionary_set_data(xdict, key, bytes, length);
            const char *key2 = [kUARPAssetAvailabilityXPCEventStatusKey UTF8String];
            xpc_dictionary_set_uint64(xdict, key2, a5);
            if ([a2 count] > 0) {
                xpc_object_t v19 = xpc_array_create(NULL, 0);
                for (NSString *v42 in a2) {
                    xpc_object_t value = xpc_string_create([v42 UTF8String]);
                    xpc_array_append_value(v19, value);
                }
                const char *key3 = [kUARPAssetAvailabilityXPCEventSerialNumbersKey UTF8String];
                xpc_dictionary_set_value(xdict, key3, v19);
            }
            bool v55 = !a3;
            if (!v55) {
                NSError *v32 = nil;
                NSData *v35 = [NSKeyedArchiver archivedDataWithRootObject:a3 requiringSecureCoding:YES error:&v32];
                if (v35 != nil) {
                    const char *key5 = [kUARPAssetAvailabilityXPCEventAssetVersionKey UTF8String];
                    const void *bytes2 = [v35 bytes];
                    NSUInteger length2 = [v35 length];
                    xpc_dictionary_set_data(xdict, key5, bytes2, length2);
                    v40 = 0;
                } else {
                    NSObject<OS_os_log> *oslog = self->_log;
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Error serializing asset version %{public}@", a3);
                    }
                    v40 = 1;
                }
                v55 = !v40;
            }
            if (v55) {
                if (a4 != nil) {
                    const char *key4 = [kUARPAssetAvailabilityXPCEventAssetCreationDateKey UTF8String];
                    NSTimeInterval timeIntervalSince1970 = [a4 timeIntervalSince1970];
                    xpc_dictionary_set_date(xdict, key4, (long)timeIntervalSince1970);
                }
                id domain = [a1 domain];
                [self notifySubscribers:xdict withDomain:domain];
            }
            xdict = nil;
        } else {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Error serializing personality %{public}@", a1);
            }
        }
    } else {
        NSObject<OS_os_log> *oslog3 = self->_log;
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
            id v49 = UARPAssetManagerAvailabilityStatusToString(a5);
            os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Asset lookup failed with status %@, not reporting to client.", v49);
        }
    }
}


void -[UARPAssetManagerController settingsChangedForSerialNumber:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Received request for settings changed for %@", a1);
    }
    if (a1 != nil) {
        [self->_assetManagerServiceManager settingsChangedForSerialNumber:a1];
    } else {
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            NSDate *v2 = self->_lastSettingsPaneTriggeredCacheRefreshDate;
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Attempting periodic cache refresh since last time %@", v2);
        }
        NSDate *date = [NSDate date];
        if (!self->_lastSettingsPaneTriggeredCacheRefreshDate) {
            self->_lastSettingsPaneTriggeredCacheRefreshDate = date;
            [self->_assetManagerServiceManager checkForUpdate];
        } else if ([date timeIntervalSinceDate:self->_lastSettingsPaneTriggeredCacheRefreshDate] >= 900.0) {
            self->_lastSettingsPaneTriggeredCacheRefreshDate = date;
            [self->_assetManagerServiceManager checkForUpdate];
        }
    }
}


void -[UARPAssetManagerController .cxx_destruct](void)
{
    self->_lastSettingsPaneTriggeredCacheRefreshDate = nil;
    self->_assetManagerServiceManager = nil;
    self->_subscriberTokens = nil;
    self->_publisher = nil;
    self->_settingsListener = nil;
    self->_assetManagerListener = nil;
    self->_log = nil;
    self->_internalQueue = nil;
    self->_idleTimer = nil;
}
