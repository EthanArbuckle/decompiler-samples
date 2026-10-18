struct UARPAssetManagerServiceInstanceMobileAsset {
    id<UARPAssetManagerServiceBase> _assetManagerService; // +0x8
    NSObject<OS_os_log> *_log; // +0x10
};

UARPAssetManagerServiceInstanceMobileAsset *-[UARPAssetManagerServiceInstanceMobileAsset initWithServiceName:delegate:](id a1, id a2)
{
    UARPAssetManagerServiceInstanceMobileAsset *v0 = [super initWithServiceName:a1 delegate:a2];
    if (v0 != nil) {
        v0->_log = os_log_create("com.apple.uarpassetmanager.uarp", "uarpAssetManager");
    }
    return v0;
}


bool -[UARPAssetManagerServiceInstanceMobileAsset isSubscriptionSupported:](id a1)
{
    Class v2 = [UARPAssetSubscriptionMobileAsset class];
    return [a1 isKindOfClass:v2] == 1;
}


void -[UARPAssetManagerServiceInstanceMobileAsset subscribeForPersonality:](id a1)
{
    Class v2 = [UARPEndpointPersonalityMobileAsset class];
    if ([a1 isKindOfClass:v2]) {
        UARPEndpointPersonalityMobileAsset *v3 = a1;
        NSString *serialNumber = [v3 serialNumber];
        NSString *identifier = [v3 identifier];
        NSString *hwFusing = [v3 hwFusing];
        NSArray *partnerSerialNumbers = [v3 partnerSerialNumbers];
        BOOL v8 = isOTAUpdateDisabledForAccessory(serialNumber, identifier, hwFusing, partnerSerialNumbers);
        if (v8 != 1) {
            NSString *hwFusing2 = [v3 hwFusing];
            NSUInteger length = [hwFusing2 length];
            if (length != 0) {
                UARPAssetSubscriptionMobileAsset *v11 = createSubscriptionForPersonality(a1, 1, 1);
                if ([v11 isKindOfClass:[UARPAssetSubscriptionMobileAsset class]]) {
                    NSObject<OS_os_log> *oslog = self->_log;
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Registering for primary subscription %{public}@", v11);
                    }
                    [super registerForSubscription:v11];
                    UARPAssetSubscriptionMobileAsset *v16 = createSubscriptionForPersonality(a1, 0, 1);
                    if ([v16 isKindOfClass:[UARPAssetSubscriptionMobileAsset class]]) {
                        NSObject<OS_os_log> *oslog2 = self->_log;
                        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "Registering for secondary subscription %{public}@", v16);
                        }
                        [super registerForSubscription:v16];
                    } else {
                        NSObject<OS_os_log> *oslog3 = self->_log;
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Could not create valid legacy subscription for %{public}@", a1);
                        }
                        id delegate = [self delegate];
                        [delegate assetAvailabilityUpdateForPersonality:v3 serialNumbers:nil assetVersion:nil creationDate:nil status:3];
                    }
                } else {
                    NSObject<OS_os_log> *oslog4 = self->_log;
                    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "Could not create valid pallas subscription for %{public}@", a1);
                    }
                    id delegate2 = [self delegate];
                    [delegate2 assetAvailabilityUpdateForPersonality:v3 serialNumbers:nil assetVersion:nil creationDate:nil status:3];
                }
            } else {
                NSObject<OS_os_log> *oslog5 = self->_log;
                if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "Invalid provided hw fusing for %{public}@", v3);
                }
            }
        } else {
            NSObject<OS_os_log> *oslog6 = self->_log;
            if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "OTA Update disabled for %{public}@", v3);
            }
            id delegate3 = [self delegate];
            [delegate3 assetAvailabilityUpdateForPersonality:v3 serialNumbers:nil assetVersion:nil creationDate:nil status:4];
        }
    }
}


id -[UARPAssetManagerServiceInstanceMobileAsset checkCacheForPersonality:](id a1)
{
    int v41;
    long v20;
    Class v3 = [UARPEndpointPersonalityMobileAsset class];
    if (![a1 isKindOfClass:v3]) {
        return nil;
    }
    UARPEndpointPersonalityMobileAsset *v4 = a1;
    NSString *serialNumber2 = [v4 serialNumber];
    NSString *identifier2 = [v4 identifier];
    NSString *hwFusing3 = [v4 hwFusing];
    NSArray *partnerSerialNumbers2 = [v4 partnerSerialNumbers];
    BOOL v9 = isOTAUpdateDisabledForAccessory(serialNumber2, identifier2, hwFusing3, partnerSerialNumbers2);
    if (v9 != 1) {
        NSString *hwFusing = [v4 hwFusing];
        NSUInteger length = [hwFusing length];
        if (length != 0) {
            NSString *serialNumber = [v4 serialNumber];
            NSString *identifier = [v4 identifier];
            NSString *hwFusing2 = [v4 hwFusing];
            NSArray *partnerSerialNumbers = [v4 partnerSerialNumbers];
            BOOL v16 = isPallasEnabledForAccessory(serialNumber, identifier, hwFusing2, partnerSerialNumbers);
            bool v51 = v16 != 1;
            if (v16 == 1) {
                UARPAssetSubscriptionMobileAsset *v39 = createSubscriptionForPersonality(a1, 1, 1);
                if ([v39 isKindOfClass:[UARPAssetSubscriptionMobileAsset class]]) {
                    long v40 = [self checkCacheForSubscription:v39];
                    if (!v40) {
                        v41 = 0;
                    } else {
                        v20 = v40;
                        v41 = 1;
                    }
                } else {
                    NSObject<OS_os_log> *oslog3 = self->_log;
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "%s Could not create valid pallas subscription for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset checkCacheForPersonality:]", a1);
                    }
                    v20 = 0;
                    v41 = 1;
                }
                v51 = !v41;
            }
            if (v51) {
                UARPAssetSubscriptionMobileAsset *v18 = createSubscriptionForPersonality(a1, 0, 1);
                if ([v18 isKindOfClass:[UARPAssetSubscriptionMobileAsset class]]) {
                    long v19 = [self checkCacheForSubscription:v18];
                    if (!v19) {
                        NSURL *assetURL = [v18 assetURL];
                        NSString *absoluteString = [assetURL absoluteString];
                        long v24 = assetLocationTypeFromBasePath(absoluteString);
                        if (v24 == 8 || v24 == 3) {
                            UARPSettingsAccessory *v25 = [[UARPSettingsAccessory alloc] init];
                            NSString *v26 = [NSString stringWithUTF8String:AUDeveloperSettingsURLTypeToString(2)];
                            [v25 setAssetLocation:v26];
                            NSString *v27 = currentOSTrainName();
                            NSString *v28 = generateMobileAssetBaseAddress(v25, v27);
                            NSURL *v29 = [NSURL URLWithString:v28];
                            [v18 setAssetURL:v29];
                            NSObject<OS_os_log> *oslog = self->_log;
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%s check cache for next asset location %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset checkCacheForPersonality:]", v18);
                            }
                            id v34 = [self checkCacheForSubscription:v18];
                            v19 = v34;
                            v20 = v19;
                        } else {
                            v20 = 0;
                        }
                    } else {
                        v20 = v19;
                    }
                } else {
                    NSObject<OS_os_log> *oslog2 = self->_log;
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%s Could not create valid legacy subscription for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset checkCacheForPersonality:]", a1);
                    }
                    v20 = 0;
                }
            }
        } else {
            NSObject<OS_os_log> *oslog4 = self->_log;
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "Invalid provided hw fusing for %{public}@", v4);
            }
            v20 = 0;
        }
    } else {
        NSObject<OS_os_log> *oslog5 = self->_log;
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "%s OTA Update disabled for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset checkCacheForPersonality:]", v4);
        }
        v20 = 0;
    }
    return v20;
}


void -[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:](id a1, id a2, bool a3)
{
    bool v89;
    os_log_type_t v8;
    Class v5 = [UARPAssetSubscriptionMobileAsset class];
    if ([a1 isKindOfClass:v5]) {
        NSArray *deploymentRules = [a2 deploymentRules];
        if (isDeploymentAllowed(deploymentRules)) {
            [super assetAvailabilityUpdateForSubscription:a1 cacheRecord:a2 asyncUpdate:a3];
            bool v1 = a2 != nil;
            if (!v1) {
                UARPAssetSubscriptionMobileAsset *v76 = a1;
                NSURL *assetURL3 = [v76 assetURL];
                NSString *absoluteString = [assetURL3 absoluteString];
                long v79 = assetLocationTypeFromBasePath(absoluteString);
                if (v79 == 8 || v79 == 3) {
                    UARPSettingsAccessory *v80 = [[UARPSettingsAccessory alloc] init];
                    NSString *v81 = [NSString stringWithUTF8String:AUDeveloperSettingsURLTypeToString(2)];
                    [v80 setAssetLocation:v81];
                    NSString *v82 = currentOSTrainName();
                    NSString *v83 = generateMobileAssetBaseAddress(v80, v82);
                    NSURL *v84 = [NSURL URLWithString:v83];
                    [v76 setAssetURL:v84];
                    NSObject<OS_os_log> *oslog4 = self->_log;
                    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "%s falling back to next asset location %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:]", v76);
                    }
                    [self registerForSubscription:v76];
                    v89 = true;
                } else {
                    v89 = a3 == 1;
                }
                v1 = !v89;
            }
            if (v1) {
                long v9 = 3;
                id v10 = nil;
                NSURL *assetURL = [a2 assetURL];
                if (assetURL != nil) {
                    v9 = 2;
                    NSFileManager *defaultManager = [NSFileManager defaultManager];
                    NSURL *assetURL2 = [a2 assetURL];
                    NSString *path = [assetURL2 path];
                    NSDictionary<NSFileAttributeKey, id> *v15 = [defaultManager attributesOfItemAtPath:path error:nil];
                    id v18 = [v15 objectForKey:NSFileCreationDate];
                    v10 = v18;
                }
                UARPAssetSubscriptionMobileAsset *v20 = a1;
                UARPEndpointPersonalityMobileAsset *v21 = createPersonalityForSubscription(a1, @"", 0);
                if ([v21 isKindOfClass:[UARPEndpointPersonalityMobileAsset class]]) {
                    NSString *appleModelNumber = [v20 appleModelNumber];
                    [v21 setMobileAssetAppleModelNumber:appleModelNumber];
                    NSMutableArray *array = [NSMutableArray array];
                    int v24 = 0;
                    if (a2 != nil) {
                        AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
                        NSArray *accessoryList = [sharedDatabase accessoryList];
                        UARPAssetSubscriptionMobileAsset *v27 = a1;
                        for (UARPSettingsAccessory *v34 in accessoryList) {
                            NSString *modelNumber = [v34 modelNumber];
                            NSString *appleModelNumber2 = [v27 appleModelNumber];
                            BOOL v37 = [modelNumber isEqualToString:appleModelNumber2];
                            bool v40 = true;
                            if (v37 != 1) {
                                NSString *mobileAssetModelNumber = [v34 mobileAssetModelNumber];
                                NSString *appleModelNumber3 = [v27 appleModelNumber];
                                v40 = [mobileAssetModelNumber isEqualToString:appleModelNumber3] == 1;
                            }
                            if (!v40) {
                                continue;
                            }
                            NSString *serialNumber = [v34 serialNumber];
                            NSString *modelNumber2 = [v34 modelNumber];
                            NSString *hwFusing = [v34 hwFusing];
                            NSArray *partnerSerialNumbers = [v34 partnerSerialNumbers];
                            BOOL v47 = isOTAUpdateDisabledForAccessory(serialNumber, modelNumber2, hwFusing, partnerSerialNumbers);
                            if (v47 == 1) {
                                continue;
                            }
                            NSString *domain = [v27 domain];
                            NSString *modelNumber3 = [v34 modelNumber];
                            NSString *serialNumber2 = [v34 serialNumber];
                            NSString *hwFusing2 = [v34 hwFusing];
                            NSString *hwRevision = [v34 hwRevision];
                            id v53 = createEndpointPersonality(domain, modelNumber3, serialNumber2, hwFusing2, hwRevision, 0, 0, 0);
                            if (![v53 isKindOfClass:[UARPEndpointPersonalityMobileAsset class]]) {
                                NSObject<OS_os_log> *oslog = self->_log;
                                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s Could not create personality for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:]", a1);
                                }
                            } else if ([v53 isPersonalityMatch:v21]) {
                                v24++;
                                bool softwareUpdateAsset = [v27 softwareUpdateAsset];
                                [v53 setSoftwareUpdateAsset:softwareUpdateAsset];
                                NSString *assetAudience = [v27 assetAudience];
                                UARPAssetSubscriptionMobileAsset *v62 = createSubscriptionForPersonality(v53, assetAudience != nil, 0);
                                NSObject<OS_os_log> *oslog2 = self->_log;
                                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                                    os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s Comparing %@ with test subscription %@", "-[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:]", a1, v62);
                                }
                                if ([a1 isEqual:v62] == 1) {
                                    NSString *serialNumber3 = [v34 serialNumber];
                                    [array addObject:serialNumber3];
                                }
                            }
                        }
                    }
                    NSArray *v67 = nil;
                    NSUInteger count = [array count];
                    if (count != v24) {
                        NSArray *v69 = [NSArray arrayWithArray:array];
                        v67 = v69;
                    }
                    UARPAssetVersionBase *assetVersion = [a2 assetVersion];
                    [self assetAvailabilityUpdateForPersonality:v21 serialNumbers:v67 assetVersion:assetVersion creationDate:v10 status:v9];
                } else {
                    NSObject<OS_os_log> *oslog3 = self->_log;
                    if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "%s Could not create personality for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:]", a1);
                    }
                }
            }
        } else {
            NSObject<OS_os_log> *oslog5 = self->_log;
            if (os_log_type_enabled(oslog5, v8)) {
                NSArray *deploymentRules2 = [a2 deploymentRules];
                os_log_with_type(oslog5, v8, "%s Not sending notification, deployment not allowed at this time for %@", "-[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForSubscription:cacheRecord:asyncUpdate:]", deploymentRules2);
            }
        }
    }
}


void -[UARPAssetManagerServiceInstanceMobileAsset updateReachabilityForPersonality:reachable:](id a1, bool a2)
{
    Class v2 = [UARPEndpointPersonalityMobileAsset class];
    if ([a1 isKindOfClass:v2]) {
        UARPEndpointPersonalityMobileAsset *v3 = a1;
        NSString *hwFusing = [v3 hwFusing];
        NSUInteger length = [hwFusing length];
        if (length != 0) {
            NSString *serialNumber = [v3 serialNumber];
            if (serialNumber != nil) {
                NSString *serialNumber2 = [v3 serialNumber];
                NSString *identifier = [v3 identifier];
                NSString *hwFusing2 = [v3 hwFusing];
                NSArray *partnerSerialNumbers = [v3 partnerSerialNumbers];
                updateReachabilityForAccessory(serialNumber2, identifier, hwFusing2, partnerSerialNumbers, a2);
            }
        } else {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Invalid provided hw fusing for %{public}@", v3);
            }
        }
    }
}


void -[UARPAssetManagerServiceInstanceMobileAsset updateSettingsForPersonality:](id a1)
{
    Class v2 = [UARPEndpointPersonalityMobileAsset class];
    if ([a1 isKindOfClass:v2] && !createSubscriptionForPersonality(a1, 0, 1)) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s error updating Settings Database with personality %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset updateSettingsForPersonality:]", a1);
        }
    }
}


void -[UARPAssetManagerServiceInstanceMobileAsset settingsChangedForSerialNumber:](NSString *a1)
{
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    id v4 = [sharedDatabase copyAccessoryWithSerialNumber:a1];
    if (v4 != nil) {
        NSMutableArray *array = [NSMutableArray array];
        id array2 = [*(uint64_t *)&_UARPAssetManagerAvailabilityStatusToString[952] array];
        id v7 = [self copySubscriptions];
        for (id v29 in v7) {
            if ([v29 isKindOfClass:[UARPAssetSubscriptionMobileAsset class]]) {
                UARPAssetSubscriptionMobileAsset *v14 = v29;
                NSObject<OS_os_log> *oslog = self->_log;
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                    NSString *modelNumber = [v4 modelNumber];
                    NSString *mobileAssetModelNumber = [v4 mobileAssetModelNumber];
                    NSString *hwFusing = [v4 hwFusing];
                    os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Checking subscription: %{public}@ against settings accessory model: %{public}@ / %{public}@ fusing: %{public}@", v14, modelNumber, mobileAssetModelNumber, hwFusing);
                }
                NSString *appleModelNumber = [v14 appleModelNumber];
                NSString *mobileAssetModelNumber2 = [v4 mobileAssetModelNumber];
                BOOL v23 = [appleModelNumber isEqualToString:mobileAssetModelNumber2];
                bool v26 = false;
                if (!v23) {
                    NSString *appleModelNumber2 = [v14 appleModelNumber];
                    NSString *modelNumber2 = [v4 modelNumber];
                    v26 = ![appleModelNumber2 isEqualToString:modelNumber2];
                }
                if (!v26) {
                    NSString *hwFusing2 = [v14 hwFusing];
                    NSString *hwFusing3 = [v4 hwFusing];
                    if ([hwFusing2 caseInsensitiveCompare:hwFusing3] == NSOrderedSame) {
                        [array addObject:v14];
                    } else {
                        [array2 addObject:v14];
                    }
                }
            }
        }
        if ([array count] != 0) {
            NSMutableSet *v33 = [NSMutableSet new];
            for (id v16 in array) {
                NSString *modelNumber3 = [v4 modelNumber];
                UARPEndpointPersonalityMobileAsset *v41 = createPersonalityForSubscription(v16, a1, modelNumber3);
                if (![v33 containsObject:v41]) {
                    [self subscribeForPersonality:v41];
                    [v33 addObject:v41];
                }
            }
        } else if ([array2 count] != 0) {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "%s WARNING: only found matches for other fusings. Cache may have been seeded incorrectly for %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset settingsChangedForSerialNumber:]", v4);
            }
        } else {
            NSObject<OS_os_log> *oslog3 = self->_log;
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "%s no existing subscriptions found that matches accessory %{public}@", "-[UARPAssetManagerServiceInstanceMobileAsset settingsChangedForSerialNumber:]", v4);
            }
        }
    } else {
        NSObject<OS_os_log> *oslog4 = self->_log;
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "%s error retrieving accessory for serial number %@", "-[UARPAssetManagerServiceInstanceMobileAsset settingsChangedForSerialNumber:]", a1);
        }
    }
}


void -[UARPAssetManagerServiceInstanceMobileAsset assetAvailabilityUpdateForPersonality:serialNumbers:assetVersion:creationDate:status:](UARPEndpointPersonalityMobileAsset *a1, NSArray *a2, UARPAssetVersionBase *a3, id a4, long a5)
{
    id delegate = [self delegate];
    [delegate assetAvailabilityUpdateForPersonality:a1 serialNumbers:a2 assetVersion:a3 creationDate:a4 status:a5];
}


NSSet *-[UARPAssetManagerServiceInstanceMobileAsset encodedClasses](void)
{
    NSMutableArray *v0 = [[NSMutableArray alloc] init];
    Class v3 = [NSURL class];
    [v0 addObject:v3];
    Class v4 = [NSString class];
    [v0 addObject:v4];
    Class v5 = [NSArray class];
    [v0 addObject:v5];
    Class v6 = [NSDictionary class];
    [v0 addObject:v6];
    Class v7 = [UARPAssetCacheRecord class];
    [v0 addObject:v7];
    Class v8 = [UARPAssetSubscriptionMobileAsset class];
    [v0 addObject:v8];
    return [NSSet setWithArray:v0];
}


id<UARPAssetManagerServiceBase> -[UARPAssetManagerServiceInstanceMobileAsset assetManagerService](void)
{
    return self->_assetManagerService;
}


void -[UARPAssetManagerServiceInstanceMobileAsset .cxx_destruct](void)
{
    self->_log = nil;
    self->_assetManagerService = nil;
}
