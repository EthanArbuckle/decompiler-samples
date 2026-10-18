struct UARPAssetManagerServiceManager {
    NSArray *_assetManagerServiceList; // +0x8
    id<UARPAssetManagerServiceDelegate> _delegate; // +0x10
    NSObject<OS_os_log> *_log; // +0x18
};

static long kUARPAssetManagerServiceAssetTypeKey;
static long kUARPAssetManagerServiceMobileAsset;

UARPAssetManagerServiceManager *-[UARPAssetManagerServiceManager initWithDelegate:](id<UARPAssetManagerServiceDelegate> a1)
{
    UARPAssetManagerServiceManager *v0 = [super init];
    if (v0 != nil) {
        v0->_log = os_log_create("com.apple.uarpassetmanager.uarp", "uarpAssetManager");
        v0->_delegate = a1;
        [v0 initServiceNameList];
    }
    return v0;
}


void -[UARPAssetManagerServiceManager initServiceNameList](void)
{
    NSMutableArray *array = [NSMutableArray array];
    NSURL *url = [NSURL fileURLWithPath:@"/System/Library/PrivateFrameworks/UARPAssetManager.framework/XPCServices/" isDirectory:YES];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator<NSURL *> *v4 = [defaultManager enumeratorAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    NSURL *v5 = [v4 nextObject];
    while (v5 != nil) {
        @autoreleasepool {
            NSBundle *v7 = [NSBundle bundleWithURL:v5];
            if (!v7) {
                NSObject<OS_os_log> *oslog4 = self->_log;
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "Unable to access XPC bundle at %{public}@", v5);
                }
            } else {
                NSDictionary<NSString *, id> *infoDictionary = [v7 infoDictionary];
                id v13 = [infoDictionary objectForKeyedSubscript:@"UARP Asset Manager"];
                if ([v13 boolValue]) {
                    NSDictionary<NSString *, id> *infoDictionary2 = [v7 infoDictionary];
                    id v16 = [infoDictionary2 objectForKeyedSubscript:kUARPAssetManagerServiceAssetTypeKey];
                    if (!v16) {
                        NSObject<OS_os_log> *oslog = self->_log;
                        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "No asset type found for Asset Manager Service");
                        }
                    }
                    NSString *bundleIdentifier = [v7 bundleIdentifier];
                    if (bundleIdentifier != nil) {
                        NSObject<OS_os_log> *oslog2 = self->_log;
                        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "Located UARP asset manager bundle %@", bundleIdentifier);
                        }
                        if ([v16 isEqualToString:kUARPAssetManagerServiceMobileAsset] == 1) {
                            UARPAssetManagerServiceInstanceMobileAsset *v24 = [UARPAssetManagerServiceInstanceMobileAsset alloc];
                            NSString *bundleIdentifier2 = [v7 bundleIdentifier];
                            [array addObject:[v24 initWithServiceName:bundleIdentifier2 delegate:self->_delegate]];
                        } else {
                            NSObject<OS_os_log> *oslog3 = self->_log;
                            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                                os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Invalid asset manager type %@", v16);
                            }
                        }
                    }
                }
            }
        }
        NSURL *nextObject = [v4 nextObject];
        v5 = nextObject;
    }
    NSArray *v34 = [[NSArray alloc] initWithArray:array];
    self->_assetManagerServiceList = v34;
}


void -[UARPAssetManagerServiceManager subscribeForPersonality:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 subscribeForPersonality:a1];
    }
}


id -[UARPAssetManagerServiceManager checkCacheForPersonality:](id a1)
{
    id v11;
    for (id v9 in self->_assetManagerServiceList) {
        id v10 = [v9 checkCacheForPersonality:a1];
        if (v10 != nil) {
            return v10;
        }
    }
    int v6 = 0;
    if (!v6) {
        v11 = nil;
    }
    return v11;
}


void -[UARPAssetManagerServiceManager checkAssetAvailabilityForDomain:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 checkAssetAvailabilityForDomain:a1];
    }
}


void -[UARPAssetManagerServiceManager clearAssetCacheForDomain:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 clearAssetCacheForDomain:a1];
    }
}


void -[UARPAssetManagerServiceManager primeCache:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 primeCache:a1];
    }
}


void -[UARPAssetManagerServiceManager checkForUpdate](void)
{
    for (id v6 in self->_assetManagerServiceList) {
        [v6 checkForUpdate];
    }
}


void -[UARPAssetManagerServiceManager updateReachabilityForPersonality:reachable:](id a1, bool a2)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 updateReachabilityForPersonality:a1 reachable:a2];
    }
}


void -[UARPAssetManagerServiceManager updateSettingsForPersonality:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 updateSettingsForPersonality:a1];
    }
}


void -[UARPAssetManagerServiceManager settingsChangedForSerialNumber:](id a1)
{
    for (id v8 in self->_assetManagerServiceList) {
        [v8 settingsChangedForSerialNumber:a1];
    }
}


bool -[UARPAssetManagerServiceManager queryIsBusy](void)
{
    int v0 = 0;
    for (id v8 in self->_assetManagerServiceList) {
        bool queryIsBusy = [v8 queryIsBusy];
        v0 |= queryIsBusy;
    }
    return v0;
}


void -[UARPAssetManagerServiceManager .cxx_destruct](void)
{
    self->_log = nil;
    self->_delegate = nil;
    self->_assetManagerServiceList = nil;
}
