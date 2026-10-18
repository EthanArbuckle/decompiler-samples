static long kAUAssetLocationTypeMobileAssetServerBasejumperBaseStr;
static long kAUAssetLocationTypeMobileAssetServerBasejumperStr;
static long kAUAssetLocationTypeMobileAssetServerLivabilityStr;
static long kAUAssetLocationTypeMobileAssetServerMesuStagingStr;
static long kAUAssetLocationTypeMobileAssetServerMesuStr;
static long kAccessoryReachableKey;
static long kAssetLocationKey;
static long kDownloadedVersionKey;
static long kDropboxVersionKey;
static long kFusingKey;
static long kIsOTADisabledKey;
static long kPallasSupportEnabledKey;
static long kPartnerSerialNumbersKey;
static long kPersonalizationRequiredKey;
static long kSettingsFromSeedBuild;
static long kUARPAssetManagerServiceCHIPiCloud;
static long kUARPAssetManagerServiceMobileAsset;
static long kUARPAssetManagerServiceUARPiCloud;
static long kUARPAssetManagerServiceUnknown;
static long kUARPMobileAssetMaxOSVersionKey;
static long kUARPMobileAssetMinOSVersionKey;
static long kUARPMobileAssetPrefix;
static long kUARPMobileAssetServerAirPodsDeveloperSeed;
static long kUARPMobileAssetServerAirPodsPublicSeed;
static long kUARPMobileAssetServerBasejumperAddress;
static long kUARPMobileAssetServerBasejumperBaseAddress;
static long kUARPMobileAssetServerLivabilityAddress;
static long kUARPMobileAssetServerMesuStagingAddress;
static long kUARPUnknownFieldValue;

char *AUDeveloperSettingsAccessoryFusingTypeToString(long a1)
{
    char *v0;
    if (!a1) {
        return "Dev";
    }
    if (a1 == 1) {
        return "Prod";
    }
    if (a1 == 2) {
        v0 = "Unfused";
    } else {
        v0 = (a1 == 3) ? "Pending" : "unrecognized";
    }
    return v0;
}


long AUDeveloperSettingsAccessoryFusingStringToType(id a1)
{
    long v10;
    if (a1 == nil) {
        return 4;
    }
    NSString *v2 = [NSString stringWithUTF8String:"Dev"];
    NSComparisonResult v3 = [a1 caseInsensitiveCompare:v2];
    if (v3 != NSOrderedSame) {
        NSString *v4 = [NSString stringWithUTF8String:"Prod"];
        NSComparisonResult v5 = [a1 caseInsensitiveCompare:v4];
        if (v5 != NSOrderedSame) {
            NSString *v6 = [NSString stringWithUTF8String:"Unfused"];
            NSComparisonResult v7 = [a1 caseInsensitiveCompare:v6];
            if (v7 != NSOrderedSame) {
                NSString *v8 = [NSString stringWithUTF8String:"Pending"];
                NSComparisonResult v9 = [a1 caseInsensitiveCompare:v8];
                v10 = (v9 != NSOrderedSame) ? 4 : 3;
            } else {
                v10 = 2;
            }
        } else {
            v10 = 1;
        }
    } else {
        v10 = 0;
    }
    return v10;
}


char *AUDeveloperSettingsURLTypeToString(long a1)
{
    char *v0;
    if (!a1) {
        return "Livability";
    }
    switch (a1) {
        case 1:
            v0 = "Internal Seed";
            break;
        case 2:
            v0 = "Customer";
            break;
        case 3:
            v0 = "Public Seed";
            break;
        case 4:
            v0 = "Basejumper";
            break;
        case 5:
            v0 = "Custom Basejumper";
            break;
        case 6:
            v0 = "Mesu Staging";
            break;
        case 7:
            v0 = "Internal Staging";
            break;
        default:
            v0 = (a1 == 8) ? "Developer Seed" : "unrecognized";
            break;
    }
    return v0;
}


long AUDeveloperSettingsURLStringToType(id a1)
{
    long v20;
    NSString *v2 = [NSString stringWithUTF8String:"Livability"];
    if ([a1 isEqualToString:v2]) {
        return 0;
    }
    NSString *v4 = [NSString stringWithUTF8String:"Customer"];
    if (![a1 isEqualToString:v4]) {
        NSString *v6 = [NSString stringWithUTF8String:"Basejumper"];
        if (![a1 isEqualToString:v6]) {
            NSString *v8 = [NSString stringWithUTF8String:"Custom Basejumper"];
            if (![a1 isEqualToString:v8]) {
                NSString *v10 = [NSString stringWithUTF8String:"Mesu Staging"];
                if (![a1 isEqualToString:v10]) {
                    NSString *v12 = [NSString stringWithUTF8String:"Public Seed"];
                    if (![a1 isEqualToString:v12]) {
                        NSString *v14 = [NSString stringWithUTF8String:"Developer Seed"];
                        if (![a1 isEqualToString:v14]) {
                            NSString *v16 = [NSString stringWithUTF8String:"Internal Seed"];
                            if (![a1 isEqualToString:v16]) {
                                NSString *v18 = [NSString stringWithUTF8String:"Internal Staging"];
                                BOOL v19 = [a1 isEqualToString:v18];
                                v20 = (!v19) ? 9 : 7;
                            } else {
                                v20 = 1;
                            }
                        } else {
                            v20 = 8;
                        }
                    } else {
                        v20 = 3;
                    }
                } else {
                    v20 = 6;
                }
            } else {
                v20 = 5;
            }
        } else {
            v20 = 4;
        }
    } else {
        v20 = 2;
    }
    return v20;
}


NSString *AUSettingsPallasAudienceTypeToString(long a1)
{
    NSString *v0;
    switch (a1) {
        case 1:
            NSString *v1 = [NSString stringWithUTF8String:"Customer Audience"];
            v0 = v1;
            break;
        case 2:
            NSString *v3 = [NSString stringWithUTF8String:"Customer Seed Audience"];
            v0 = v3;
            break;
        case 3:
            NSString *v5 = [NSString stringWithUTF8String:"Internal Living On"];
            v0 = v5;
            break;
        case 4:
            NSString *v7 = [NSString stringWithUTF8String:"Custom Audience"];
            v0 = v7;
            break;
        case 5:
            NSString *v9 = [NSString stringWithUTF8String:"Mobile Asset Untested"];
            v0 = v9;
            break;
        default:
            NSString *v11 = [NSString stringWithUTF8String:"unrecognized"];
            v0 = v11;
            break;
    }
    return v0;
}


long AUSettingsPallasStringToAudienceType(id a1)
{
    long v12;
    NSString *v2 = [NSString stringWithUTF8String:"Customer Audience"];
    BOOL v3 = [a1 isEqualToString:v2];
    if (v3 == 1) {
        return 1;
    }
    NSString *v4 = [NSString stringWithUTF8String:"Customer Seed Audience"];
    BOOL v5 = [a1 isEqualToString:v4];
    if (v5 != 1) {
        NSString *v6 = [NSString stringWithUTF8String:"Internal Living On"];
        BOOL v7 = [a1 isEqualToString:v6];
        if (v7 != 1) {
            NSString *v8 = [NSString stringWithUTF8String:"Custom Audience"];
            BOOL v9 = [a1 isEqualToString:v8];
            if (v9 != 1) {
                NSString *v10 = [NSString stringWithUTF8String:"Mobile Asset Untested"];
                BOOL v11 = [a1 isEqualToString:v10];
                v12 = (v11 != 1) ? 0 : 5;
            } else {
                v12 = 4;
            }
        } else {
            v12 = 3;
        }
    } else {
        v12 = 2;
    }
    return v12;
}


id getInfoForAccessory(id a1)
{
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
    return [accessoriesDictionary objectForKeyedSubscript:a1];
}


bool configuredToDefaultAssetLocationForAccessory(id a1)
{
    bool v5;
    id v2 = [a1 objectForKeyedSubscript:kFusingKey];
    long v3 = AUDeveloperSettingsAccessoryFusingStringToType(v2);
    if (!v3 || v3 == 2) {
        id v4 = [a1 objectForKeyedSubscript:kAssetLocationKey];
        v5 = !AUDeveloperSettingsURLStringToType(v4);
    } else {
        id v6 = [a1 objectForKeyedSubscript:kAssetLocationKey];
        v5 = AUDeveloperSettingsURLStringToType(v6) == 2;
    }
    return v5;
}


id getURLForAssetURLType(long a1)
{
    id v0 = nil;
    if (!a1) {
        return kAUAssetLocationTypeMobileAssetServerLivabilityStr;
    }
    if (a1 == 1) {
        v0 = kAUAssetLocationTypeMobileAssetServerBasejumperBaseStr;
    } else if ((unsigned long)a1 <= 3) {
        v0 = kAUAssetLocationTypeMobileAssetServerMesuStr;
    } else if ((unsigned long)a1 <= 5) {
        v0 = kAUAssetLocationTypeMobileAssetServerBasejumperStr;
    } else {
        switch (a1) {
            case 6:
                v0 = kAUAssetLocationTypeMobileAssetServerMesuStagingStr;
                break;
            case 7:
                v0 = kAUAssetLocationTypeMobileAssetServerBasejumperBaseStr;
                break;
            case 8:
                v0 = kAUAssetLocationTypeMobileAssetServerMesuStr;
                break;
        }
    }
    return v0;
}


void cleanupPersonalizedUpdateAvailable(id a1)
{
    AUDeveloperSettingsDatabase *sharedDatabase2 = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary = [sharedDatabase2 accessoriesDictionary];
    id v7 = [accessoriesDictionary objectForKey:a1];
    NSDictionary *v8 = [v7 mutableCopy];
    [v8 setObject:nil forKeyedSubscript:kDownloadedVersionKey];
    [v8 setObject:nil forKeyedSubscript:kPersonalizationRequiredKey];
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *v12 = [NSDictionary dictionaryWithDictionary:v8];
    [sharedDatabase addAccessoryWithSerialNumber:a1 info:v12];
}


NSArray *findPartnerSerialNumbersInDatabase(NSString *a1)
{
    NSString *v1 = a1;
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *v5 = array;
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
    [accessoriesDictionary enumerateKeysAndObjectsUsingBlock:^void(NSString *arg1, NSDictionary *arg2, bool *arg3) {
        id v19 = [arg2 objectForKeyedSubscript:kPartnerSerialNumbersKey];
        for (NSString *v17 in v19) {
            BOOL v16 = [v17 isEqualToString:v1];
            if (v16 == 1 && ![arg1 isEqualToString:v1]) {
                [v5 addObject:arg1];
                return;
            }
        }
    }];
    return [NSArray arrayWithArray:v5];
}


NSString *findPartnerSerialNumberForAccessoryID(id a1)
{
    NSString *serialNumber = [a1 serialNumber];
    NSString *modelNumber = [a1 modelNumber];
    id hwFusingType = [a1 hwFusingType];
    NSArray *partnerSerialNumbers = [a1 partnerSerialNumbers];
    return findPartnerSerialNumberForAccessory(serialNumber, modelNumber, hwFusingType, partnerSerialNumbers);
}


NSString *findPartnerSerialNumberForAccessory(NSString *a1, id a2, NSString *a3, id a4)
{
    NSArray *v0;
    int v15;
    NSString *v29;
    long v9 = 0;
    v0.field_24 = 0;
    v0 = nil;
    v0 = a4;
    if (![v0 count]) {
        NSArray *v7 = findPartnerSerialNumbersInDatabase(a1);
        v0 = v7;
    }
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    for (NSString *v18 in v0) {
        NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
        id v20 = [accessoriesDictionary objectForKey:v18];
        id v21 = [v20 objectForKey:kFusingKey];
        if (!v21) {
            v15 = 3;
        } else if ([v18 isEqualToString:a1] == 1) {
            v15 = 3;
        } else {
            NSComparisonResult v22 = [v21 caseInsensitiveCompare:a3];
            bool v25 = true;
            if (v22 != NSOrderedSame) {
                NSString *string = [NSString stringWithUTF8String:"Prod"];
                NSComparisonResult v27 = [a3 caseInsensitiveCompare:string];
                v25 = false;
                if (v27) {
                    NSString *v28 = [NSString stringWithUTF8String:"Prod"];
                    v25 = [v21 caseInsensitiveCompare:v28] != NSOrderedSame;
                }
            }
            if (v25) {
                v29 = v18;
                v15 = 1;
            } else {
                v15 = 0;
            }
        }
        if (v15 != 0 && v15 != 3) {
            v9 = 1;
        }
        if (v9) {
            break;
        }
    }
    if (!v9) {
        v15 = 0;
    }
    if (!v15) {
        v29 = nil;
    }
    return v29;
}


id getAccessoryDatabaseKeyForAccessoryID(id a1)
{
    NSString *serialNumber = [a1 serialNumber];
    NSString *modelNumber = [a1 modelNumber];
    id hwFusingType = [a1 hwFusingType];
    NSArray *partnerSerialNumbers = [a1 partnerSerialNumbers];
    return getAccessoryDatabaseKeyForAccessory(serialNumber, modelNumber, hwFusingType, partnerSerialNumbers);
}


id getAccessoryDatabaseKeyForAccessory(id a1, id a2, id a3, id a4)
{
    if (a1 == nil) {
        return nil;
    }
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary2 = [sharedDatabase accessoriesDictionary];
    id v10 = [accessoriesDictionary2 objectForKey:a1];
    id v11 = nil;
    if (v10 != nil) {
        v11 = a1;
    } else {
        NSString *aKey = findPartnerSerialNumberForAccessory(a1, a2, a3, a4);
        NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
        id v14 = [accessoriesDictionary objectForKey:aKey];
        v10 = v14;
        if (v10 != nil) {
            v11 = aKey;
        }
    }
    return v11;
}


BOOL isOTAUpdateDisabledForAccessoryID(id a1)
{
    NSString *serialNumber = [a1 serialNumber];
    NSString *modelNumber = [a1 modelNumber];
    id hwFusingType = [a1 hwFusingType];
    NSArray *partnerSerialNumbers = [a1 partnerSerialNumbers];
    return isOTAUpdateDisabledForAccessory(serialNumber, modelNumber, hwFusingType, partnerSerialNumbers);
}


BOOL isOTAUpdateDisabledForAccessory(id a1, id a2, id a3, id a4)
{
    int v13;
    BOOL v9;
    id aKey = getAccessoryDatabaseKeyForAccessory(a1, a2, a3, a4);
    if (!aKey) {
        return NO;
    }
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
    id v12 = [accessoriesDictionary objectForKey:aKey];
    if (!v12) {
        v13 = 0;
    } else {
        id v14 = [v12 objectForKeyedSubscript:kIsOTADisabledKey];
        v9 = [v14 boolValue];
        v13 = 1;
    }
    if (!v13) {
        v9 = NO;
    }
    return v9;
}


BOOL isPallasEnabledForAccessory(id a1, id a2, id a3, id a4)
{
    int v13;
    BOOL v9;
    id aKey = getAccessoryDatabaseKeyForAccessory(a1, a2, a3, a4);
    if (!aKey) {
        return NO;
    }
    AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
    NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
    id v12 = [accessoriesDictionary objectForKey:aKey];
    if (!v12) {
        v13 = 0;
    } else {
        id v14 = [v12 objectForKeyedSubscript:kPallasSupportEnabledKey];
        v9 = [v14 boolValue];
        v13 = 1;
    }
    if (!v13) {
        v9 = NO;
    }
    return v9;
}


void dropboxFileUpdateForAccessoryID(id a1, id a2)
{
    NSString *serialNumber = [a1 serialNumber];
    NSString *modelNumber = [a1 modelNumber];
    id hwFusingType = [a1 hwFusingType];
    NSArray *partnerSerialNumbers = [a1 partnerSerialNumbers];
    dropboxFileUpdateForAccessory(serialNumber, modelNumber, hwFusingType, partnerSerialNumbers, a2);
}


void dropboxFileUpdateForAccessory(id a1, id a2, id a3, id a4, id a5)
{
    id aKey = getAccessoryDatabaseKeyForAccessory(a1, a2, a3, a4);
    if (aKey != nil) {
        AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
        NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
        NSDictionary *v13 = [accessoriesDictionary objectForKey:aKey];
        if (v13 != nil) {
            NSMutableDictionary *v14 = [NSMutableDictionary dictionaryWithDictionary:v13];
            [v14 setObject:a5 forKeyedSubscript:kDropboxVersionKey];
            NSDictionary *v17 = [NSDictionary dictionaryWithDictionary:v14];
            [sharedDatabase addAccessoryWithSerialNumber:aKey info:v17];
        }
    }
}


void updateReachabilityForAccessoryID(id a1, bool a2)
{
    NSString *serialNumber = [a1 serialNumber];
    NSString *modelNumber = [a1 modelNumber];
    id hwFusingType = [a1 hwFusingType];
    NSArray *partnerSerialNumbers = [a1 partnerSerialNumbers];
    updateReachabilityForAccessory(serialNumber, modelNumber, hwFusingType, partnerSerialNumbers, a2);
}


long updateReachabilityForAccessory(id a1, id a2, id a3, id a4, bool a5)
{
    id v1 = nil;
    v1 = a1;
    AUDeveloperSettingsDatabase *sharedDatabase2 = [AUDeveloperSettingsDatabase sharedDatabase];
    if (!v1) {
        NSDictionary *accessoriesDictionary3 = [sharedDatabase2 accessoriesDictionary];
        NSArray *allKeys = [accessoriesDictionary3 allKeys];
        for (id v17 in allKeys) {
            NSDictionary *accessoriesDictionary = [sharedDatabase2 accessoriesDictionary];
            NSDictionary *v19 = [accessoriesDictionary objectForKey:v17];
            if (v19 != nil) {
                NSMutableDictionary *v20 = [NSMutableDictionary dictionaryWithDictionary:v19];
                NSNumber *obj = [NSNumber numberWithBool:a5];
                [v20 setObject:obj forKeyedSubscript:kAccessoryReachableKey];
                NSDictionary *v24 = [NSDictionary dictionaryWithDictionary:v20];
                [sharedDatabase2 addAccessoryWithSerialNumber:v17 info:v24];
            }
        }
    } else {
        id aKey = getAccessoryDatabaseKeyForAccessory(v1, a2, a3, a4);
        if (aKey != nil) {
            AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
            NSDictionary *accessoriesDictionary2 = [sharedDatabase accessoriesDictionary];
            NSDictionary *v28 = [accessoriesDictionary2 objectForKey:aKey];
            if (v28 != nil) {
                NSMutableDictionary *v29 = [NSMutableDictionary dictionaryWithDictionary:v28];
                NSNumber *obj2 = [NSNumber numberWithBool:a5];
                [v29 setObject:obj2 forKeyedSubscript:kAccessoryReachableKey];
                NSDictionary *v33 = [NSDictionary dictionaryWithDictionary:v29];
                [sharedDatabase addAccessoryWithSerialNumber:aKey info:v33];
            }
        }
    }
    v1 = nil;
    return &v1;
}


long generateAssetLocationBasePath(id a1, id a2, int a3)
{
    return 0;
}


long updateSeedEnablementForAccessory(id a1)
{
    id v1 = nil;
    v1 = a1;
    if (v1 != nil) {
        AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
        NSDictionary *accessoriesDictionary = [sharedDatabase accessoriesDictionary];
        id v4 = [accessoriesDictionary objectForKey:v1];
        NSDictionary *v5 = [v4 mutableCopy];
        if (v5 != nil) {
            id v6 = [v5 objectForKeyedSubscript:kSettingsFromSeedBuild];
            if ([sharedDatabase isSeedParticipationEnabled:v1] == 1 && (!v6 || [v6 boolValue] == 1)) {
                NSString *v7 = [NSString stringWithUTF8String:AUDeveloperSettingsURLTypeToString(2)];
                [v5 setObject:v7 forKeyedSubscript:kAssetLocationKey];
                os_log_t oslog = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Clearing seed enablement for %{public}@", v1);
                }
            }
            [v5 setObject:@NO forKeyedSubscript:kSettingsFromSeedBuild];
            NSDictionary *v11 = [NSDictionary dictionaryWithDictionary:v5];
            [sharedDatabase addAccessoryWithSerialNumber:v1 info:v11];
        }
    }
    v1 = nil;
    return &v1;
}


NSString *MapPreferenceSuiteToString(long a1)
{
    NSString *v0;
    if (!a1) {
        return @"com.apple.accessoryupdaterd";
    }
    if (a1 != 1) {
        v0 = nil;
    } else {
        v0 = @"com.apple.AUDeveloperSettings";
    }
    return v0;
}


NSString *currentOSTrainName(void)
{
    static dispatch_once_t onceToken;
    static char *trainName;
    NSString *v0 = nil;
    dispatch_once(&onceToken, ^void(void) {
        NSString *v11 = [NSString stringWithFormat:@"%s", "$SIDEBUILD_PARENT_TRAIN"];
        BOOL v1 = [v11 isEqualToString:@""];
        bool v13 = false;
        if (!v1) {
            NSString *v14 = [NSString stringWithFormat:@"%s", "$SIDEBUILD_PARENT_TRAIN"];
            v13 = ![v14 isEqualToString:@"$SIDEBUILD_PARENT_TRAIN"];
        }
        if (v13) {
            trainName = "$SIDEBUILD_PARENT_TRAIN";
            return;
        }
        NSString *v15 = [NSString stringWithFormat:@"%s", "CheerC"];
        BOOL v7 = [v15 isEqualToString:@""];
        bool v9 = false;
        if (!v7) {
            NSString *v10 = [NSString stringWithFormat:@"%s", "CheerC"];
            v9 = ![v10 isEqualToString:@"$RC_RELEASE"];
        }
        if (v9) {
            trainName = "CheerC";
        }
    });
    if (trainName != 0) {
        NSString *v4 = [NSString stringWithFormat:@"%s", trainName];
        v0 = v4;
    }
    return v0;
}


UARPAssetSubscriptionMobileAsset *createSubscriptionForPersonality(id a1, bool a2, bool a3)
{
    UARPEndpointPersonalityMobileAsset *v3;
    id v9;
    id v10;
    NSMutableString *v16;
    NSString *v95;
    os_log_t oslog;
    os_log_t oslog5;
    os_log_t oslog6;
    oslog.field_176 = 0;
    Class v2 = [UARPEndpointPersonalityMobileAsset class];
    if ([a1 isKindOfClass:v2]) {
        v3 = a1;
        _mergePartnerAccessoriesInAssetSettings(v3);
        AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
        NSString *serialNumber3 = [v3 serialNumber];
        NSString *identifier = [v3 identifier];
        NSString *hwFusing6 = [v3 hwFusing];
        NSArray *partnerSerialNumbers3 = [v3 partnerSerialNumbers];
        v9 = [sharedDatabase copyAccessoryForSignature:serialNumber3 modelNumber:identifier fusingType:hwFusing6 partnerSerialNumbers:partnerSerialNumbers3];
        v10 = nil;
        id friendlyName = [v3 friendlyName];
        NSUInteger length = [friendlyName length];
        if (length <= 0) {
            if (![v9 name]) {
                v16 = [kUARPUnknownFieldValue mutableCopy];
                NSString *serialNumber = [v3 serialNumber];
                NSUInteger length2 = [serialNumber length];
                if (length2 <= 0) {
                    goto blk_10000ff40;
                }
                goto blk_10000fe8c;
            }
            NSString *name = [v9 name];
            v10 = name;
        } else {
            id friendlyName2 = [v3 friendlyName];
            v10 = friendlyName2;
        }
blk_10000ffcc:
        if (v9 != nil) {
            oslog5 = OS_LOG_DEFAULT;
            if (!os_log_type_enabled(oslog5, OS_LOG_TYPE_INFO)) {
                goto blk_100010318;
            }
            goto blk_1000102c8;
        }
        oslog6 = OS_LOG_DEFAULT;
        if (!os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
            goto blk_100010064;
        }
        goto blk_100010014;
blk_10001079c:
        if (a3 != 1) {
            goto blk_1000107f0;
        }
    } else {
        os_log_t oslog7 = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog7, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog7, OS_LOG_TYPE_ERROR, "Only mobile asset accessory personalities are currently supported");
        }
        return nil;
blk_10000fe8c:
        NSMutableString *v28 = [NSMutableString alloc];
        NSString *appleModelNumber2 = [v3 appleModelNumber];
        v16 = [v28 initWithFormat:@"%@ (%@)", appleModelNumber2, [v3 serialNumber]];
blk_10000ff40:
        NSString *v33 = [NSString stringWithString:v16];
        v10 = v33;
        v16 = nil;
        goto blk_10000ffcc;
blk_100010014:
        os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "No Settings Entry found for personality %{public}@", a1);
blk_100010064:
        UARPSettingsAccessory *v36 = [[UARPSettingsAccessory alloc] init];
        v9 = v36;
        NSString *serialNumber2 = [v3 serialNumber];
        [v9 setSerialNumber:serialNumber2];
        NSString *appleModelNumber3 = [v3 appleModelNumber];
        [v9 setModelNumber:appleModelNumber3];
        id mobileAssetAppleModelNumber = [v3 mobileAssetAppleModelNumber];
        [v9 setMobileAssetModelNumber:mobileAssetAppleModelNumber];
        NSString *hwFusing2 = [v3 hwFusing];
        NSString *lowercaseString2 = [hwFusing2 lowercaseString];
        [v9 setHwFusing:lowercaseString2];
        [v9 setName:v10];
        [v9 setPallasSupportEnabled:YES];
        if ([v3 softwareUpdateAsset] == 1) {
            [v9 setPallasInternalAssetVariant:NO];
        }
        NSString *hwFusing3 = [v3 hwFusing];
        NSString *lowercaseString3 = [hwFusing3 lowercaseString];
        unsigned long v45 = getPallasSettingForAccessory(0, lowercaseString3);
        [v9 setPallasAudience:v45];
        goto blk_10001079c;
blk_1000102c8:
        os_log_with_type(oslog5, OS_LOG_TYPE_INFO, "Updating Settings Entry with personality %{public}@", a1);
blk_100010318:
        [v9 setName:v10];
        id mobileAssetAppleModelNumber2 = [v3 mobileAssetAppleModelNumber];
        NSUInteger length3 = [mobileAssetAppleModelNumber2 length];
        if (length3 > 0) {
            id mobileAssetAppleModelNumber3 = [v3 mobileAssetAppleModelNumber];
            [v9 setMobileAssetModelNumber:mobileAssetAppleModelNumber3];
        }
        NSString *activeVersion = [v3 activeVersion];
        [v9 setActiveVersion:activeVersion];
        NSString *hwRevision = [v3 hwRevision];
        [v9 setHwRevision:hwRevision];
        id mobileAssetAppleModelNumber4 = [v3 mobileAssetAppleModelNumber];
        NSUInteger length4 = [mobileAssetAppleModelNumber4 length];
        if (length4 > 0) {
            id mobileAssetAppleModelNumber5 = [v3 mobileAssetAppleModelNumber];
            [v9 setMobileAssetModelNumber:mobileAssetAppleModelNumber5];
        }
        NSString *serialNumber4 = [v3 serialNumber];
        NSString *serialNumber5 = [v9 serialNumber];
        BOOL v57 = [serialNumber4 isEqualToString:serialNumber5];
        bool v59 = false;
        if (v57 == 1) {
            NSArray *partnerSerialNumbers = [v3 partnerSerialNumbers];
            v59 = [partnerSerialNumbers count] > 0;
        }
        if (v59) {
            NSArray *partnerSerialNumbers2 = [v3 partnerSerialNumbers];
            [v9 setPartnerSerialNumbers:partnerSerialNumbers2];
        }
        if (![v9 pallasAudience]) {
            [v9 setPallasSupportEnabled:YES];
            if ([v3 softwareUpdateAsset] == 1) {
                [v9 setPallasInternalAssetVariant:NO];
            }
            NSString *hwFusing4 = [v3 hwFusing];
            NSString *lowercaseString4 = [hwFusing4 lowercaseString];
            unsigned long v65 = getPallasSettingForAccessory(0, lowercaseString4);
            [v9 setPallasAudience:v65];
        }
        if (![v9 pallasAudience]) {
            NSString *hwFusing5 = [v3 hwFusing];
            NSString *lowercaseString5 = [hwFusing5 lowercaseString];
            unsigned long v69 = getPallasSettingForAccessory(0, lowercaseString5);
            [v9 setPallasAudience:v69];
        }
        goto blk_10001079c;
    }
    AUDeveloperSettingsDatabase *sharedDatabase2 = [AUDeveloperSettingsDatabase sharedDatabase];
    [sharedDatabase2 updateAccessory:v9];
blk_1000107f0:
    bool v71 = false;
    NSString *assetURLOverride = [v9 assetURLOverride];
    id v73 = loadProfileAssetOverrideSettings(&oslog);
    id identifier2 = [a1 identifier];
    id v75 = [v73 objectForKeyedSubscript:identifier2];
    BOOL v77 = [v75 isEqualToString:assetURLOverride];
    if (v77 || !v75 || !assetURLOverride) {
        [v9 setAssetURLOverride:nil];
    } else {
        [v9 setAssetURLOverride:v75];
        v71 = true;
    }
    long v78 = MGGetBoolAnswer(@"InternalBuild");
    oslog.field_15 = 0;
    bool v79 = false;
    if (1 == (v78 & 1)) {
        NSString *hwFusing7 = [v3 hwFusing];
        oslog.field_15 = 1;
        v79 = [hwFusing7 caseInsensitiveCompare:@"prod"] != NSOrderedSame;
    }
    if (v79) {
        NSString *assetLocation2 = [v9 assetLocation];
        if (assetLocation2 == nil) {
            char *v83 = AUDeveloperSettingsURLTypeToString(0);
            NSString *v84 = [NSString stringWithUTF8String:v83];
            [v9 setAssetLocation:v84];
            v71 = true;
        }
    } else {
        NSString *assetLocation = [v9 assetLocation];
        if (assetLocation == nil) {
            char *v85 = AUDeveloperSettingsURLTypeToString(2);
            NSString *v86 = [NSString stringWithUTF8String:v85];
            [v9 setAssetLocation:v86];
            v71 = true;
        }
    }
    if (v71 == 1 && a3 == 1) {
        oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *serialNumber6 = [v3 serialNumber];
            NSString *assetLocation3 = [v9 assetLocation];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Updating Asset Location for %{public}@ to %{public}@", serialNumber6, assetLocation3);
        }
        oslog = nil;
        AUDeveloperSettingsDatabase *sharedDatabase3 = [AUDeveloperSettingsDatabase sharedDatabase];
        [sharedDatabase3 updateAccessory:v9];
    }
    long mobileAssetAppleModelNumber6 = [v3 mobileAssetAppleModelNumber];
    if (mobileAssetAppleModelNumber6) {
        v95 = [v3 mobileAssetAppleModelNumber];
    } else {
        v95 = [v3 appleModelNumber];
    }
    NSString *v98 = v95;
    UARPAssetSubscriptionMobileAsset *v99 = [UARPAssetSubscriptionMobileAsset alloc];
    NSString *hwFusing = [v3 hwFusing];
    NSString *lowercaseString = [hwFusing lowercaseString];
    UARPAssetSubscriptionMobileAsset *v103 = [v99 initWithAppleModelNumber:v98 hwFusing:lowercaseString domain:[a1 domain]];
    if (a2 != 1) {
        NSString *v104 = currentOSTrainName();
        NSString *v105 = generateMobileAssetBaseAddress(v9, v104);
        NSURL *v106 = [NSURL URLWithString:v105];
        [v103 setAssetURL:v106];
        NSURL *assetURL = [v103 assetURL];
        if (assetURL != nil) {
            os_log_t oslog2 = OS_LOG_DEFAULT;
            if (!os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                return v103;
            }
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Using %{public}@ for subscription %{public}@", v105, v103);
            return v103;
        }
        os_log_t oslog3 = OS_LOG_DEFAULT;
        if (!os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
            return nil;
        }
        os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "Invalid asset location for subscription %{public}@", v103);
        return nil;
    }
    NSString *appleModelNumber = [v103 appleModelNumber];
    id v114 = mobileAssetPrefixForAppleModelNumber(appleModelNumber);
    NSString *v115 = [NSString stringWithFormat:@"%@%@", v114, v98];
    bool softwareUpdateAsset = [v3 softwareUpdateAsset];
    NSString *v117 = getPallasAudienceForAccessory(v9, softwareUpdateAsset);
    if ([v117 length] != 0) {
        [v103 setAssetAudience:v117];
        bool pallasInternalAssetVariant = [v9 pallasInternalAssetVariant];
        [v103 setInternalAsset:pallasInternalAssetVariant];
        bool softwareUpdateAsset2 = [v3 softwareUpdateAsset];
        [v103 setSoftwareUpdateAsset:softwareUpdateAsset2];
        return v103;
    }
    os_log_t oslog4 = OS_LOG_DEFAULT;
    if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
        os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "Invalid pallas audience detected for asset %{public}@", v115);
    }
    return nil;
}


long _mergePartnerAccessoriesInAssetSettings(id a1)
{
    NSUInteger count;
    NSUInteger count2;
    uint8_t v0[192];
    *(uint64_t *)&v0[184] = 0;
    id v1 = a1;
    NSString *hwFusing2 = [v1 hwFusing];
    NSUInteger length = [hwFusing2 length];
    bool v5 = true;
    if (length != 0) {
        NSString *serialNumber7 = [v1 serialNumber];
        v5 = ![serialNumber7 length];
    }
    if (!v5) {
        AUDeveloperSettingsDatabase *sharedDatabase2 = [AUDeveloperSettingsDatabase sharedDatabase];
        NSString *serialNumber9 = [v1 serialNumber];
        id identifier = [v1 identifier];
        NSString *hwFusing = [v1 hwFusing];
        NSArray *partnerSerialNumbers = [v1 partnerSerialNumbers];
        id v12 = [sharedDatabase2 copyAccessoryForSignature:serialNumber9 modelNumber:identifier fusingType:hwFusing partnerSerialNumbers:partnerSerialNumbers];
        NSArray *v13 = [v1 partnerSerialNumbers];
        NSString *serialNumber = [v12 serialNumber];
        NSString *serialNumber2 = [v1 serialNumber];
        BOOL v16 = [serialNumber isEqualToString:serialNumber2];
        if (!v16) {
            NSArray *partnerSerialNumbers2 = [v12 partnerSerialNumbers];
            count = [partnerSerialNumbers2 count];
            if (count <= 0) {
                NSArray *partnerSerialNumbers3 = [v1 partnerSerialNumbers];
                NSArray *v20 = [partnerSerialNumbers3 mutableCopy];
                NSArray *v22 = v20;
                NSString *serialNumber3 = [v12 serialNumber];
                [v22 removeObject:serialNumber3];
                NSString *serialNumber4 = [v1 serialNumber];
                [v22 addObject:serialNumber4];
                NSArray *v25 = [NSArray arrayWithArray:v22];
                [v12 setPartnerSerialNumbers:v25];
                NSArray *partnerSerialNumbers4 = [v12 partnerSerialNumbers];
                v13 = partnerSerialNumbers4;
            } else {
                os_log_t oslog4 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_INFO)) {
                    os_log_with_type(oslog4, OS_LOG_TYPE_INFO, "Settings accessory found for personality %@", v1);
                }
            }
        } else {
            NSArray *partnerSerialNumbers5 = [v12 partnerSerialNumbers];
            count2 = [partnerSerialNumbers5 count];
            if (count2 <= 0) {
                NSArray *partnerSerialNumbers6 = [v1 partnerSerialNumbers];
                [v12 setPartnerSerialNumbers:partnerSerialNumbers6];
            }
            if (count2 > 0) {
                os_log_t oslog5 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog5, OS_LOG_TYPE_INFO)) {
                    os_log_with_type(oslog5, OS_LOG_TYPE_INFO, "Settings accessory found for personality %@", v1);
                }
            }
        }
        if ((!v16 && count <= 0) || (v16 && count2 <= 0)) {
            NSMutableArray *v28 = [NSMutableArray new];
            os_log_t oslog = OS_LOG_DEFAULT;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Using reported Partner Serial Numbers %@ for personality %@", v13, v1);
            }
            AUDeveloperSettingsDatabase *sharedDatabase = [AUDeveloperSettingsDatabase sharedDatabase];
            NSString *hwFusing3 = [v12 hwFusing];
            NSArray *accessoryList = [sharedDatabase accessoryList];
            for (UARPSettingsAccessory *v39 in accessoryList) {
                NSString *serialNumber5 = [v39 serialNumber];
                if (![v13 containsObject:serialNumber5]) {
                    continue;
                }
                NSString *hwFusing4 = [v39 hwFusing];
                if (![hwFusing4 length]) {
                    os_log_t oslog2 = OS_LOG_DEFAULT;
                    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                        NSString *serialNumber6 = [v39 serialNumber];
                        NSString *hwFusing5 = [v39 hwFusing];
                        os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "Unexpected Accessory Entry for %@ with fusing %@", serialNumber6, hwFusing5);
                    }
                    continue;
                }
                NSString *hwFusing6 = [v39 hwFusing];
                NSComparisonResult v50 = [hwFusing6 caseInsensitiveCompare:hwFusing3];
                bool v52 = true;
                if (v50 != NSOrderedSame) {
                    NSComparisonResult v53 = [hwFusing3 caseInsensitiveCompare:@"prod"];
                    v52 = false;
                    if (v53) {
                        NSString *hwFusing7 = [v39 hwFusing];
                        v52 = [hwFusing7 caseInsensitiveCompare:@"prod"] != NSOrderedSame;
                    }
                }
                if (!v52) {
                    continue;
                }
                [v28 addObject:v39];
            }
            for (UARPSettingsAccessory *v61 in v28) {
                os_log_t oslog3 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                    NSString *serialNumber8 = [v61 serialNumber];
                    os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Removing Entry from AUDeveloperSettingsDatabase with serialNumber %@", serialNumber8);
                }
                [sharedDatabase removeAccessory:v61];
            }
        }
    }
    v1 = nil;
    return &v1;
}


unsigned long getPallasSettingForAccessory(id a1, id a2)
{
    unsigned long v4;
    long v3 = MGGetBoolAnswer(@"InternalBuild");
    if ((v3 & 1) != 1 || a1 != nil) {
        if (a1) {
            v4 = [a1 pallasAudience];
        } else {
            v4 = 1;
        }
    } else {
        v4 = 3;
    }
    return v4;
}


id loadProfileAssetOverrideSettings(void)
{
    id v0 = nil;
    NSURL *v1 = [NSURL fileURLWithPath:@"/Library/Managed Preferences/mobile/com.apple.AUDeveloperSettings.plist"];
    NSError *v3 = nil;
    NSDictionary *v6 = [NSDictionary dictionaryWithContentsOfURL:v1 error:&v3];
    if (v6 != nil) {
        id v8 = [v6 objectForKeyedSubscript:@"models"];
        if ([v8 isKindOfClass:[NSDictionary class]]) {
            v0 = v8;
            for (id v16 in v0) {
                id v17 = [v0 objectForKeyedSubscript:v16];
                if (![v17 isKindOfClass:[NSString class]]) {
                    v0 = nil;
                    break;
                }
            }
        }
    }
    return v0;
}


NSString *getPallasAudienceForAccessory(id a1, bool a2)
{
    unsigned long v2;
    NSString *v3;
    if ((MGGetBoolAnswer(@"InternalBuild", a2) & 1) == 1) {
        if ([a1 pallasAudience] != 4) {
            if ([a1 pallasAudience] != 3) {
                if ([a1 pallasAudience] != 5) {
                    v2 = [a1 pallasAudience];
                    v3 = (v2 != 2) ? getDefaultPallasAudience(a2) : @"0206c249-b301-46e0-9d6a-23ce9c5d875d";
                } else {
                    v3 = @"b1f792b1-0797-48f1-8603-107cefcf1d45";
                }
            } else {
                v3 = @"ce9c2203-903b-4fb3-9f03-040dc2202694";
            }
        } else {
            v3 = [a1 pallasAudienceOverride];
        }
    } else {
        v2 = [a1 pallasAudience];
        v3 = (v2 != 2) ? getDefaultPallasAudience(a2) : @"0206c249-b301-46e0-9d6a-23ce9c5d875d";
    }
    return v3;
}


NSString *generateMobileAssetBaseAddress(id a1, id a2)
{
    id v9;
    NSString *v30;
    if (a1 == nil) {
        return nil;
    }
    if (![a1 assetURLOverride]) {
        NSString *assetLocation = [a1 assetLocation];
        if ([assetLocation length] != 0) {
            NSString *customTrain = [a1 customTrain];
            NSString *customBuild = [a1 customBuild];
            long v8 = AUDeveloperSettingsURLStringToType(assetLocation);
            if (v8 != 5) {
                if (v8 != 0) {
                    if (v8 != 1) {
                        if (v8 != 4) {
                            if (v8 != 2) {
                                if (v8 != 6) {
                                    if (v8 != 7) {
                                        if (v8 != 8) {
                                            if (v8 != 3) {
                                                v9 = nil;
                                            } else {
                                                id v10 = getDefaultMesuAddress();
                                                NSString *v13 = [v10 stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsPublicSeed];
                                                v9 = v13;
                                            }
                                        } else {
                                            id v15 = getDefaultMesuAddress();
                                            NSString *v18 = [v15 stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsDeveloperSeed];
                                            v9 = v18;
                                        }
                                    } else {
                                        NSString *v20 = [kUARPMobileAssetServerBasejumperBaseAddress stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsPublicSeed];
                                        v9 = v20;
                                    }
                                } else {
                                    v9 = kUARPMobileAssetServerMesuStagingAddress;
                                }
                            } else {
                                id v22 = getDefaultMesuAddress();
                                v9 = v22;
                            }
                        } else {
                            v9 = kUARPMobileAssetServerBasejumperAddress;
                        }
                    } else {
                        NSString *v24 = [kUARPMobileAssetServerBasejumperBaseAddress stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsDeveloperSeed];
                        v9 = v24;
                    }
                } else if ([customTrain length] <= 0) {
                    NSString *v26 = [NSString stringWithFormat:@"%@/%@", kUARPMobileAssetServerLivabilityAddress, a2];
                    v9 = v26;
                } else {
                    NSString *v28 = [NSString stringWithFormat:@"%@/%@", kUARPMobileAssetServerLivabilityAddress, customTrain];
                    v9 = v28;
                }
                v30 = v9;
            } else if (![customTrain length]) {
                v30 = nil;
            } else if ([customBuild length] != 0) {
                NSString *v31 = [NSString stringWithFormat:@"%@/%@/%@%@", kUARPMobileAssetServerBasejumperAddress, customTrain, customTrain, customBuild];
                v9 = v31;
                v30 = v9;
            } else {
                v30 = nil;
            }
        } else {
            v30 = nil;
        }
    } else {
        v30 = [a1 assetURLOverride];
    }
    return v30;
}


UARPEndpointPersonalityMobileAsset *createPersonalityForSubscription(id a1, id a2, id a3)
{
    NSString *v9;
    UARPEndpointPersonalityMobileAsset *v18;
    Class v6 = [UARPAssetSubscriptionMobileAsset class];
    if ([a1 isKindOfClass:v6]) {
        UARPAssetSubscriptionMobileAsset *v7 = a1;
        if (a3) {
            v9 = a3;
        } else {
            v9 = [v7 appleModelNumber];
        }
        id v11 = v9;
        UARPEndpointPersonalityMobileAsset *v12 = [UARPEndpointPersonalityMobileAsset alloc];
        NSString *hwFusing = [v7 hwFusing];
        v18 = [v12 initWithAppleModelNumber:v11 serialNumber:a2 hwFusing:hwFusing domain:[v7 domain]];
    } else {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Only mobile asset accessory subscriptions are currently supported");
        }
        v18 = nil;
    }
    return v18;
}


NSString *getDefaultMesuAddress(void)
{
    return @"https://mesu.apple.com/assets/macos";
}


NSString *getDefaultPallasAudience(bool a1)
{
    if (a1 != 1) {
        return @"02d8e57e-dd1c-4090-aa50-b4ed2aef0062";
    }
    return @"60b55e25-a8ed-4f45-826c-c1495a4ccc65";
}


long assetLocationTypeFromBasePath(id a1)
{
    long v6;
    int v14;
    if ([a1 hasPrefix:kUARPMobileAssetServerLivabilityAddress] == 1) {
        return 0;
    }
    if ([a1 isEqualToString:kUARPMobileAssetServerMesuStagingAddress] != 1) {
        if ([a1 isEqualToString:kUARPMobileAssetServerBasejumperAddress] != 1) {
            NSString *v2 = getDefaultMesuAddress();
            BOOL v3 = [a1 isEqualToString:v2];
            if (v3 != 1) {
                NSString *v4 = getDefaultMesuAddress();
                BOOL v5 = [a1 hasPrefix:v4];
                if (v5 != 1) {
                    if ([a1 hasPrefix:kUARPMobileAssetServerBasejumperBaseAddress] != 1) {
                        v6 = 9;
                    } else {
                        NSString *v7 = [kUARPMobileAssetServerBasejumperBaseAddress stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsPublicSeed];
                        if ([a1 isEqualToString:v7] != 1) {
                            NSString *v8 = [kUARPMobileAssetServerBasejumperBaseAddress stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsDeveloperSeed];
                            v7 = v8;
                            v6 = ([a1 isEqualToString:v7] != 1) ? 5 : 1;
                        } else {
                            v6 = 7;
                        }
                    }
                } else {
                    id v10 = getDefaultMesuAddress();
                    NSString *v11 = [v10 stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsDeveloperSeed];
                    if ([a1 isEqualToString:v11] != 1) {
                        NSString *v12 = [v10 stringByAppendingPathComponent:kUARPMobileAssetServerAirPodsPublicSeed];
                        v11 = v12;
                        if ([a1 isEqualToString:v11] == 1) {
                            v6 = 3;
                            v14 = 1;
                        } else {
                            v14 = 0;
                        }
                    } else {
                        v6 = 8;
                        v14 = 1;
                    }
                    v11 = nil;
                    v10 = nil;
                    if (!v14) {
                        return 9;
                    }
                }
            } else {
                v6 = 2;
            }
        } else {
            v6 = 4;
        }
    } else {
        v6 = 6;
    }
    return v6;
}


int AUSandboxPlatformInitWithBundleIdentifierHomeDirectory(id a1, char *a2, long a3, long a4)
{
    id v1 = a1;
    if (!v1) {
        v1 = OS_LOG_DEFAULT;
    }
    if (!a2) {
        a2 = "com.apple.MobileAccessoryUpdater";
    }
    return AUSandboxPlatformInitMacOS(v1, a2, a3);
}


int AUSandboxPlatformInitMacOS(os_log_t a1, char *a2, char *a3)
{
    char *v4;
    NSString *v6;
    int v50;
    uint8_t v5[1024];
    uint8_t v40[48];
    uint8_t v41[64];
    char *v2 = 0;
    char *v3 = 0;
    v4.field_8 = 0;
    bzero(v5, 0x400);
    v4 = 0;
    if (!a3) {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *bundleIdentifier = [mainBundle bundleIdentifier];
        v6 = bundleIdentifier;
    } else {
        NSString *v11 = [NSString stringWithUTF8String:a3];
        v6 = v11;
    }
    if (!v6) {
        os_log_t oslog = a1;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: Error 'bundleIdentifier' not valid", "int AUSandboxPlatformInitMacOS(__strong os_log_t, const char *, const char *)");
        }
    }
    if (v6 != nil) {
        NSString *v17 = [NSString stringWithFormat:@"%@/%@.%@", @"/System/Library/Sandbox/Profiles", v6, @"sb"];
        const char *v19 = getenv("HOME");
        if (!v19) {
            os_log_t oslog2 = a1;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "$HOME not set, falling back to using getpwuid");
            }
            struct passwd *v22 = getpwuid(getuid());
            if (!v22) {
                os_log_t oslog3 = a1;
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                    uid_t v25 = getuid();
                    os_log_with_type(oslog3, OS_LOG_TYPE_ERROR, "failed to get passwd entry for uid %u", v25);
                }
            } else {
                v19 = v22->field_48;
            }
        }
        if (!v19) {
            os_log_t oslog4 = a1;
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Using hardcoded home dir path %s", "/private/var/db/accessoryupdater/");
            }
            v2 = strdup("/private/var/db/accessoryupdater/");
        } else {
            v2 = realpath(v19, NULL);
        }
        if (!v2) {
            os_log_t oslog5 = a1;
            if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
                int *v32 = __error();
                int v13 = *(v32);
                os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "failed to resolve user's home directory: %d", v13);
            }
        }
        if (v2 != 0) {
            if (!AUSandboxPlatformInitializeDedicatedTempDir(a1, a2, &v5, 0x400)) {
                v3 = realpath((const char * restrict)v5, NULL);
            }
            if (!v3) {
                os_log_t oslog6 = a1;
                if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                    int *v37 = __error();
                    int v14 = *(v37);
                    os_log_with_type(oslog6, OS_LOG_TYPE_ERROR, "Failed to resolve temp directory: %d, using hardcoded path: %s", v14, "/private/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/com.apple.MobileAccessoryUpdater");
                }
                v3 = strdup("/private/var/folders/zz/zyxvpxvq6csfxvn_n0000000000000/T/com.apple.MobileAccessoryUpdater");
            }
            if (v3 != 0) {
                memset(v40, 0, 40);
                *(uint64_t *)&v40[0] = "HOME";
                *(uint64_t *)&v40[8] = v2;
                *(uint64_t *)&v40[16] = "TMPDIR";
                *(uint64_t *)&v40[24] = v3;
                *(uint64_t *)&v40[32] = 0;
                memset(v41, 0, 56);
                *(uint64_t *)&v41[0] = "HOME";
                *(uint64_t *)&v41[8] = v2;
                *(uint64_t *)&v41[16] = "TMPDIR";
                *(uint64_t *)&v41[24] = v3;
                *(uint64_t *)&v41[32] = "DARWIN_CACHE_DIR";
                *(uint64_t *)&v41[40] = v4.field_8;
                *(uint64_t *)&v41[48] = 0;
                const char *UTF8String = [v17 UTF8String];
                long v43 = sandbox_init_with_parameters(UTF8String, 1, (!v4.field_8) ? &v40 : &v41, &v4);
                if (v43 != 0) {
                    os_log_t oslog7 = a1;
                    if (os_log_type_enabled(oslog7, OS_LOG_TYPE_ERROR)) {
                        os_log_with_type(oslog7, OS_LOG_TYPE_ERROR, "Failed to enter sandbox: %s", v4);
                    }
                }
                if (0 == v43) {
                    os_log_t oslog8 = a1;
                    if (os_log_type_enabled(oslog8, OS_LOG_TYPE_INFO)) {
                        os_log_with_type(oslog8, OS_LOG_TYPE_INFO, "Sandboxing should now be active");
                    }
                    v50 = 0;
                } else {
                    v50 = 1;
                }
            } else {
                v50 = 1;
            }
        } else {
            v50 = 1;
        }
    } else {
        v50 = 1;
    }
    if (v2 != 0) {
        free(v2);
    }
    if (v3 != 0) {
        free(v3);
    }
    return v50;
}


int AUSandboxPlatformInitWithBundleIdentifier(id a1, long a2, long a3)
{
    return AUSandboxPlatformInitWithBundleIdentifierHomeDirectory(a1, a2, a3, "/private/var/db/accessoryupdater/");
}


int AUSandboxPlatformInit(id a1, long a2)
{
    return AUSandboxPlatformInitWithBundleIdentifier(a1, a2, 0);
}


int AUSandboxPlatformInitWithHomeDirectory(id a1, long a2, long a3)
{
    return AUSandboxPlatformInitWithBundleIdentifierHomeDirectory(a1, a2, 0, a3);
}


bool AUSandboxPlatformInitializeDedicatedTempDir(os_log_t a1, char *a2, char *a3, size_t a4)
{
    long v2 = _set_user_dir_suffix(a2, a2, a3, a4);
    if ((v2 & 1) == 0) {
        os_log_t oslog = a1;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            int *v5 = __error();
            int v3 = *(v5);
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "failed to set temporary directory suffix: %d", v3);
        }
    }
    if ((v2 & 1) == 0) {
        return true;
    }
    size_t v7 = confstr(65537, a3, a4);
    if (!v7) {
        os_log_t oslog2 = a1;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
            int *v10 = __error();
            int v4 = *(v10);
            os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "failed to initialize temporary directory: %d", v4);
        }
    }
    return !v7;
}


id UARPAssetManagerServiceCacheTypeToString(long a1)
{
    long v0;
    if (!a1) {
        return kUARPAssetManagerServiceMobileAsset;
    }
    if (a1 == 1) {
        v0 = kUARPAssetManagerServiceUARPiCloud;
    } else if (a1 == 2) {
        v0 = kUARPAssetManagerServiceCHIPiCloud;
    } else {
        v0 = kUARPAssetManagerServiceUnknown;
    }
    return v0;
}


int isRoamingEnabledCheck(void)
{
    return 0;
}


bool allowConditionalDownloadOnCellular(void)
{
    if ((MGGetBoolAnswer(@"InternalBuild") & 1) == 1) {
        return true;
    } else {
        return isRoamingEnabledCheck() == 0;
    }
}


NSBundle *getAssetBundle(id a1)
{
    NSBundle *v7;
    id attributes = [a1 attributes];
    NSString *pathComponent = [attributes objectForKey:@"FirmwareBundle"];
    if (pathComponent == nil) {
        return nil;
    }
    NSURL *localFileUrl = [a1 getLocalFileUrl];
    NSURL *v5 = [localFileUrl URLByAppendingPathComponent:pathComponent];
    NSURL *filePathURL = [v5 filePathURL];
    if (filePathURL != nil) {
        v7 = [NSBundle bundleWithURL:filePathURL];
    } else {
        v7 = nil;
    }
    return v7;
}


id getRestoreVersionForMAAsset(id a1)
{
    id attributes = [a1 attributes];
    return [attributes objectForKey:@"RestoreVersion"];
}


id getOSVersionForMAAsset(id a1)
{
    id attributes = [a1 attributes];
    return [attributes objectForKey:@"OSVersion"];
}


id getBuildVersionForMAAsset(id a1)
{
    id attributes = [a1 attributes];
    return [attributes objectForKey:@"Build"];
}


id getMinOSVersionForMAAsset(id a1)
{
    id attributes = [a1 attributes];
    return [attributes objectForKey:kUARPMobileAssetMinOSVersionKey];
}


id getMaxOSVersionForMAAsset(id a1)
{
    id attributes = [a1 attributes];
    return [attributes objectForKey:kUARPMobileAssetMaxOSVersionKey];
}


NSString *getAssetVersionForMAAsset(id a1)
{
    id attributes2 = [a1 attributes];
    id v3 = [attributes2 objectForKey:@"FirmwareVersionMajor"];
    unsigned int unsignedIntValue3 = [v3 unsignedIntValue];
    id attributes3 = [a1 attributes];
    id v6 = [attributes3 objectForKey:@"FirmwareVersionMinor"];
    unsigned int unsignedIntValue4 = [v6 unsignedIntValue];
    id attributes4 = [a1 attributes];
    id v9 = [attributes4 objectForKey:@"FirmwareVersionRelease"];
    unsigned int unsignedIntValue = [v9 unsignedIntValue];
    NSMutableString *v11 = [NSMutableString stringWithFormat:@"%u.%u.%u", unsignedIntValue3, unsignedIntValue4, unsignedIntValue];
    id attributes = [a1 attributes];
    id v13 = [attributes objectForKey:@"FirmwareVersionBuild"];
    if (v13 != nil) {
        unsigned int unsignedIntValue2 = [v13 unsignedIntValue];
        [v11 appendFormat:@".%u", unsignedIntValue2];
    }
    return [NSString stringWithString:v11];
}


id assetWithMaxVersion(id a1)
{
    id v12;
    if ([a1 count] > 1) {
        id v2 = nil;
        NSString *v3 = nil;
        for (id v10 in a1) {
            if ([v10 state] != 3) {
                NSString *v11 = getAssetVersionForMAAsset(v10);
                if (isOSVersionNewer(v11, v3) == 1) {
                    v3 = v11;
                    v2 = v10;
                }
            }
        }
        v12 = v2;
    } else {
        v12 = [a1 firstObject];
    }
    return v12;
}


bool isOSVersionNewer(id a1, id a2)
{
    NSArray<NSString *> *v4 = [a1 componentsSeparatedByString:@"."];
    NSArray<NSString *> *v5 = [a2 componentsSeparatedByString:@"."];
    NSUInteger v6 = 0;
    while (1) {
        NSUInteger count3 = [v4 count];
        bool v8 = true;
        if (v6 >= count3) {
            NSUInteger count4 = [v5 count];
            v8 = v6 < count4;
        }
        if (!v8) {
            return false;
        }
        NSUInteger count = [v4 count];
        if (v6 >= count) {
            break;
        }
        NSUInteger count2 = [v5 count];
        if (v6 >= count2) {
            return true;
        }
        NSString *v12 = [v4 objectAtIndexedSubscript:v6];
        NSInteger integerValue = [v12 integerValue];
        NSString *v14 = [v5 objectAtIndexedSubscript:v6];
        NSInteger integerValue2 = [v14 integerValue];
        if (integerValue > integerValue2) {
            return true;
        }
        if (integerValue < integerValue2) {
            return false;
        }
        v6++;
    }
    return false;
}


bool isBuildVersionNewer(NSString *a1, NSString *a2)
{
    bool v43;
    NSString *v6 = @"([0-9]+)([A-Z]{1})([0-9]+)([a-z]?)";
    NSRegularExpression *v7 = [NSRegularExpression regularExpressionWithPattern:v6 options:0 error:nil];
    if (v7 == nil) {
        return false;
    }
    NSUInteger length2 = [a1 length];
    NSArray<NSTextCheckingResult *> *v9 = [v7 matchesInString:a1 options:0 range:(NSRange){0, length2}];
    NSTextCheckingResult *v10 = [v9 objectAtIndex:0];
    if ([v10 numberOfRanges] >= 4) {
        NSUInteger length = [a2 length];
        NSArray<NSTextCheckingResult *> *v12 = [v7 matchesInString:a2 options:0 range:(NSRange){0, length}];
        NSTextCheckingResult *v13 = [v12 objectAtIndex:0];
        if ([v13 numberOfRanges] >= 4) {
            NSRange range = [v10 rangeAtIndex:1];
            NSString *v16 = [a1 substringWithRange:range];
            NSRange v17 = [v13 rangeAtIndex:1];
            NSUInteger v18 = v17.length;
            NSRange v1 = v17;
            NSString *v19 = [a2 substringWithRange:(NSRange){v1, v18}];
            NSInteger integerValue = [v16 integerValue];
            NSInteger integerValue2 = [v19 integerValue];
            if (integerValue <= integerValue2) {
                NSInteger integerValue3 = [v19 integerValue];
                NSInteger integerValue4 = [v16 integerValue];
                if (integerValue3 <= integerValue4) {
                    v1.field_32 = [v10 rangeAtIndex:2];
                    NSString *string = [a1 substringWithRange:range];
                    NSRange v25 = [v13 rangeAtIndex:2];
                    NSRange v26 = v25;
                    v26.length = v25.length;
                    v1 = v26;
                    NSString *v27 = [a2 substringWithRange:(NSRange){v1, v18}];
                    NSComparisonResult v28 = [v27 caseInsensitiveCompare:string];
                    if (v28 == NSOrderedAscending) {
                        v43 = true;
                    } else if (v28 == NSOrderedDescending) {
                        v43 = false;
                    } else {
                        NSRange v29 = [v10 rangeAtIndex:3];
                        NSRange v30 = v29;
                        v30.length = v29.length;
                        v1.field_32 = v30;
                        NSString *v31 = [a1 substringWithRange:range];
                        v1.location = [v13 rangeAtIndex:3];
                        NSString *v32 = [a2 substringWithRange:(NSRange){v1, v18}];
                        NSInteger integerValue5 = [v31 integerValue];
                        NSInteger integerValue6 = [v32 integerValue];
                        if (integerValue5 <= integerValue6) {
                            NSInteger integerValue7 = [v32 integerValue];
                            NSInteger integerValue8 = [v31 integerValue];
                            if (integerValue7 <= integerValue8) {
                                if ([v13 numberOfRanges] != 4) {
                                    NSRange v37 = [v10 rangeAtIndex:4];
                                    NSRange v38 = v37;
                                    v38.length = v37.length;
                                    v1.field_32 = v38;
                                    NSString *string2 = [a1 substringWithRange:range];
                                    NSRange v40 = [v13 rangeAtIndex:4];
                                    NSRange v41 = v40;
                                    v41.length = v40.length;
                                    v1 = v41;
                                    NSString *v42 = [a2 substringWithRange:(NSRange){v1, v18}];
                                    if ([v42 caseInsensitiveCompare:string2] == NSOrderedAscending) {
                                        v43 = true;
                                    } else {
                                        v43 = false;
                                    }
                                } else {
                                    v43 = false;
                                }
                            } else {
                                v43 = false;
                            }
                        } else {
                            v43 = true;
                        }
                    }
                } else {
                    v43 = false;
                }
            } else {
                v43 = true;
            }
        } else {
            v43 = true;
        }
    } else {
        v43 = false;
    }
    return v43;
}


NSString *getSoftwareUpdateAssetVersionForMAAsset(id a1)
{
    id v2 = getRestoreVersionForMAAsset(a1);
    if (v2) {
        return v2;
    }
    id v3 = getBuildVersionForMAAsset(a1);
    id v5 = getOSVersionForMAAsset(a1);
    return (!v3 || !v5) ? nil : [NSString stringWithFormat:@"%@:%@", v5, v3];
}


id softwareUpdateAssetWithMaxVersion(id a1, bool a2)
{
    id v35;
    id v36;
    id v37;
    NSString *v38;
    id v40;
    if ([a1 count] > 1) {
        id v3 = nil;
        bool v4 = false;
        for (id v11 in a1) {
            if ([v11 state] != 3) {
                id attributes = [v11 attributes];
                id v13 = [attributes objectForKeyedSubscript:kUARPMobileAssetMinOSVersionKey];
                id attributes2 = [v11 attributes];
                id v16 = [attributes2 objectForKeyedSubscript:kUARPMobileAssetMaxOSVersionKey];
                if (!v13 || !v16) {
                    os_log_t oslog = OS_LOG_DEFAULT;
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%s: Asset missing _MinOSVersion or _MaxOSVersion", "softwareUpdateAssetWithMaxVersion");
                    }
                } else {
                    id attributes3 = [v11 attributes];
                    id v23 = [attributes3 objectForKeyedSubscript:@"ReleaseType"];
                    if (!v23) {
                        os_log_t oslog2 = OS_LOG_DEFAULT;
                        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%s: Asset missing ReleaseType", "softwareUpdateAssetWithMaxVersion");
                        }
                    } else if (a2 == 1 && ![v23 isEqualToString:@"Darwin Internal"]) {
                        os_log_t oslog3 = OS_LOG_DEFAULT;
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%s: Asset does not match internal=%d", "softwareUpdateAssetWithMaxVersion", a2);
                        }
                    } else if (!v3) {
                        v3 = v11;
                    } else {
                        id v30 = getRestoreVersionForMAAsset(v11);
                        long continuationRoute2 = 0;
                        if (v30 != nil) {
                            id v31 = getRestoreVersionForMAAsset(v3);
                            SUCoreRestoreVersion *v32 = [[SUCoreRestoreVersion alloc] initWithRestoreVersion:v30];
                            id v33 = [[*(uint64_t *)&_UARPAssetManagerAvailabilityStatusToString[648] alloc] initWithRestoreVersion:v31];
                            if ([v32 isComparable:v33] == 1) {
                                if ([v32 compare:v33] == NSOrderedDescending) {
                                    v3 = v11;
                                    v4 = true;
                                }
                            } else {
                                v3 = v11;
                                v4 = true;
                            }
                            v33 = nil;
                            v32 = nil;
                            v31 = nil;
                        } else {
                            if (v4 == 1) {
                                continue;
                            }
                            v35 = getBuildVersionForMAAsset(v11);
                            v36 = getOSVersionForMAAsset(v11);
                            v37 = getBuildVersionForMAAsset(v3);
                            v38 = getOSVersionForMAAsset(v3);
                            if (isOSVersionNewer(v36, v38) == 1) {
                                continuationRoute2 = 1;
                            }
                            if (!continuationRoute2) {
                                if ([v36 isEqualToString:v38] != 1 || isBuildVersionNewer(v35, v37) != 1) {
                                    continuationRoute2 = 2;
                                }
                                if (!continuationRoute2) {
                                    continuationRoute2 = 1;
                                }
                            }
                        }
                        if (continuationRoute2 == 1) {
                            v3 = v11;
                            continuationRoute2 = 2;
                        }
                        if (continuationRoute2 == 2) {
                            v38 = nil;
                            v37 = nil;
                            v36 = nil;
                            v35 = nil;
                        }
                    }
                }
            }
        }
        v40 = v3;
    } else {
        v40 = [a1 firstObject];
    }
    return v40;
}


bool copyFileToLocalPath(NSString *a1, NSString *a2)
{
    NSError *v1;
    bool v35;
    v1.field_40 = 0;
    NSURL *srcURL = [NSURL fileURLWithPath:a1];
    NSError *v7 = nil;
    v1 = v7;
    BOOL v9 = [srcURL checkResourceIsReachableAndReturnError:&v1];
    v7 = v1;
    if (v9) {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: Valid firmware file %@", "copyFileToLocalPath", srcURL);
        }
        NSString *lastPathComponent = [srcURL lastPathComponent];
        NSString *v14 = [a2 stringByAppendingPathComponent:lastPathComponent];
        NSURL *v15 = [NSURL fileURLWithPath:v14];
        NSURL *url = [NSURL fileURLWithPath:a2 isDirectory:YES];
        if (![url checkResourceIsReachableAndReturnError:nil]) {
            NSDictionary *attributes = @{NSFilePosixPermissions: @509};
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            if ([defaultManager createDirectoryAtURL:url withIntermediateDirectories:YES attributes:attributes error:&v7]) {
                os_log_t oslog2 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: UARP Firmware directory created %@", "copyFileToLocalPath", a2);
                }
            } else {
                os_log_t oslog3 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                    os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%s: Failed to create UARP Firmware directory error: %@", "copyFileToLocalPath", v7);
                }
            }
        }
        NSFileManager *defaultManager2 = [NSFileManager defaultManager];
        [defaultManager2 removeItemAtURL:v15 error:nil];
        NSFileManager *defaultManager3 = [NSFileManager defaultManager];
        if ([defaultManager3 copyItemAtURL:srcURL toURL:v15 error:&v7]) {
            v35 = true;
        } else {
            os_log_t oslog4 = OS_LOG_DEFAULT;
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_INFO, "%s: Failed to write to path %@ error: %@", "copyFileToLocalPath", v15, v7);
            }
            v35 = false;
        }
    } else {
        os_log_t oslog5 = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog5, OS_LOG_TYPE_ERROR, "%s: Invalid firmware file %@ error: %@", "copyFileToLocalPath", srcURL, v7);
        }
        v35 = false;
    }
    return v35;
}


NSString *AssetManagerDirectoryPath(void)
{
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^void(void) {
        path = @"/var/db/accessoryupdater/";
    });
    return path;
}


bool isDeploymentAllowed(id a1)
{
    if (![a1 count]) {
        return true;
    }
    NSMutableArray *v2 = [[NSMutableArray alloc] init];
    NSDateFormatter *v3 = [[NSDateFormatter alloc] init];
    [v3 setDateFormat:@"MM/dd/yyyy"];
    for (id v11 in a1) {
        id v12 = [v11 objectForKey:@"minOSVersion"];
        id v14 = [v11 objectForKey:@"maxOSVersion"];
        if (v12 != nil && v14 != nil) {
            UARPDeploymentRule *v15 = [[UARPDeploymentRule alloc] initWithMinOSVersion:v12 maxOSVersion:v14];
            if (v15 != nil) {
                [v2 addObject:v15];
            }
        } else {
            NSNumber *v17 = [v11 objectForKey:@"rampPeriod"];
            NSNumber *v18 = [v11 objectForKey:@"deploymentLimit"];
            NSArray *v19 = [v11 objectForKey:@"countryList"];
            NSString *string = [v11 objectForKey:@"goLiveDate"];
            NSDate *v21 = [v3 dateFromString:string];
            UARPDeploymentRuleConfig *v22 = [[UARPDeploymentRuleConfig alloc] init];
            [v22 setGoLiveDate:v21];
            [v22 setCountryList:v19];
            [v22 setRampPeriod:v17];
            [v22 setDeploymentLimit:v18];
            UARPDeploymentRule *v23 = [[UARPDeploymentRule alloc] initWithConfig:v22];
            if (v23) {
                [v2 addObject:v23];
            }
        }
    }
    bool v25 = true;
    NSError *v26 = nil;
    for (UARPDeploymentRule *v16 in v2) {
        v25 = [v16 isDeploymentAllowed:&v26];
        if (1 == v25) {
            bool v8 = v25;
            v26 = nil;
            return v8;
        }
    }
    return v25;
}


bool nullableObjectsAreEqual(id a1, id a2)
{
    if (!a1) {
        return !a2;
    }
    return [a1 isEqual:a2];
}


NSString *mobileAssetPrefixForAppleModelNumber(id a1)
{
    return ([a1 isEqualToString:@"A2525"] != 1) ? kUARPMobileAssetPrefix : @"com.apple.MobileAsset.DarwinAccessoryUpdate.";
}


int main(int a1, char **a2)
{
    uint8_t v6[64];
    int v0 = 0;
    @autoreleasepool {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Starting uarpassetmanagerd");
        }
        if (!AUSandboxPlatformInitWithHomeDirectory(0, 0, "/private/var/db/accessoryupdater/")) {
            *(uint64_t *)&v6[0] = 0;
            *(uint64_t *)&v6[8] = &v6;
            *(uint32_t *)&v6[16] = 0x32000000;
            *(uint32_t *)&v6[20] = 48;
            *(uint64_t *)&v6[24] = &__Block_byref_object_copy_;
            *(uint64_t *)&v6[32] = &__Block_byref_object_dispose_;
            *(uint64_t *)&v6[40] = 0;
            dispatch_queue_global_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^void(void) {
                UARPAssetManagerController *v12 = [[UARPAssetManagerController alloc] initWithIdleTimeout:30];
                void *v13 = *(uint64_t *)&v6[8];
                v13->field_40 = v12;
                if ((*(uint64_t *)&v6[8])->field_40) {
                    return;
                }
                os_log_t v15 = OS_LOG_DEFAULT;
                if (os_log_type_enabled(v15, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v15, OS_LOG_TYPE_ERROR, "Failed to initialize asset manager daemon controller");
                }
            });
            _Block_object_dispose(v6, 8);
            *(uint32_t *)&v6[52] = 0;
        } else {
            os_log_t oslog2 = OS_LOG_DEFAULT;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Failed to enter sandbox");
            }
            v0 = 1;
            *(uint32_t *)&v6[52] = 1;
        }
    }
    if (!*(uint32_t *)&v6[52]) {
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        [currentRunLoop run];
        return 0;
    }
    return v0;
}


void __Block_byref_object_copy_(void *a1, void *a2)
{
    a1->field_40 = 0;
    objc_storeStrong(a1 + 40, a2->field_40);
    objc_storeStrong(a2 + 40, nil);
}


void __Block_byref_object_dispose_(void *a1)
{
    objc_storeStrong(a1 + 40, nil);
}
