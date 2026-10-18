struct UARPSettingsAccessory {
    NSDictionary *_originalSettings; // +0x8
    bool _otaDisabled; // +0x10
    bool _authListingEnabled; // +0x11
    bool _personalizationRequired; // +0x12
    bool _accessoryReachable; // +0x13
    bool _supportsDeveloperSettings; // +0x14
    bool _pallasSupportEnabled; // +0x15
    bool _pallasInternalAssetVariant; // +0x16
    NSString *_name; // +0x18
    NSString *_serialNumber; // +0x20
    NSString *_modelNumber; // +0x28
    NSString *_mobileAssetModelNumber; // +0x30
    NSString *_hwFusing; // +0x38
    NSString *_hwRevision; // +0x40
    NSString *_activeVersion; // +0x48
    NSArray *_partnerSerialNumbers; // +0x50
    NSString *_assetLocation; // +0x58
    NSString *_customTrain; // +0x60
    NSString *_customBuild; // +0x68
    NSString *_supplementalAssetLocation; // +0x70
    NSString *_supplementalCustomTrain; // +0x78
    NSString *_supplementalCustomBuild; // +0x80
    NSString *_downloadedVersion; // +0x88
    NSString *_dropboxVersion; // +0x90
    NSString *_assetURLOverride; // +0x98
    unsigned long _pallasAudience; // +0xa0
    NSString *_pallasAudienceOverride; // +0xa8
};

static long kAccessoryReachableKey;
static long kAccessorySupportsDeveloperSettingsKey;
static long kActiveVersionKey;
static long kAssetLocationKey;
static long kAssetURLOverrideKey;
static long kAuthListingEnabledKey;
static long kBasejumperBuildKey;
static long kBasejumperTrainKey;
static long kDownloadedVersionKey;
static long kDropboxVersionKey;
static long kFusingKey;
static long kHWRevisionKey;
static long kIsOTADisabledKey;
static long kMobileAssetModelNumberKey;
static long kModelNumberKey;
static long kNameKey;
static long kPallasAudienceKey;
static long kPallasAudienceOverrideKey;
static long kPallasInternalAssetVariant;
static long kPallasSupportEnabledKey;
static long kPartnerSerialNumbersKey;
static long kPersonalizationRequiredKey;
static long kSerialNumberKey;
static long kSupplementalAssetLocationKey;
static long kSupplementalBasejumperBuildKey;
static long kSupplementalBasejumperTrainKey;

bool +[UARPSettingsAccessory supportsSecureCoding](void)
{
    return true;
}


UARPSettingsAccessory *-[UARPSettingsAccessory initWithDictionary:](id a1)
{
    UARPSettingsAccessory *v0 = [super init];
    if (v0 != nil) {
        id v7 = [a1 objectForKeyedSubscript:kNameKey];
        v0->_name = [v7 copy];
        id v11 = [a1 objectForKeyedSubscript:kSerialNumberKey];
        v0->_serialNumber = [v11 copy];
        id v15 = [a1 objectForKeyedSubscript:kModelNumberKey];
        v0->_modelNumber = [v15 copy];
        id v19 = [a1 objectForKeyedSubscript:kMobileAssetModelNumberKey];
        v0->_mobileAssetModelNumber = [v19 copy];
        id v23 = [a1 objectForKeyedSubscript:kFusingKey];
        v0->_hwFusing = [v23 copy];
        id v27 = [a1 objectForKeyedSubscript:kActiveVersionKey];
        v0->_activeVersion = [v27 copy];
        id v31 = [a1 objectForKeyedSubscript:kHWRevisionKey];
        v0->_hwRevision = [v31 copy];
        id v35 = [a1 objectForKeyedSubscript:kPartnerSerialNumbersKey];
        v0->_partnerSerialNumbers = [v35 copy];
        id v39 = [a1 objectForKeyedSubscript:kAssetLocationKey];
        v0->_assetLocation = [v39 copy];
        id v43 = [a1 objectForKeyedSubscript:kBasejumperTrainKey];
        v0->_customTrain = [v43 copy];
        id v47 = [a1 objectForKeyedSubscript:kBasejumperBuildKey];
        v0->_customBuild = [v47 copy];
        id v51 = [a1 objectForKeyedSubscript:kSupplementalAssetLocationKey];
        v0->_supplementalAssetLocation = [v51 copy];
        id v55 = [a1 objectForKeyedSubscript:kSupplementalBasejumperTrainKey];
        v0->_supplementalCustomTrain = [v55 copy];
        id v59 = [a1 objectForKeyedSubscript:kSupplementalBasejumperBuildKey];
        v0->_supplementalCustomBuild = [v59 copy];
        id v63 = [a1 objectForKeyedSubscript:kIsOTADisabledKey];
        v0->_otaDisabled = [v63 boolValue];
        id v64 = [a1 objectForKeyedSubscript:kAuthListingEnabledKey];
        v0->_authListingEnabled = [v64 boolValue];
        id v65 = [a1 objectForKeyedSubscript:kPersonalizationRequiredKey];
        v0->_personalizationRequired = [v65 boolValue];
        id v66 = [a1 objectForKeyedSubscript:kAccessoryReachableKey];
        v0->_accessoryReachable = [v66 boolValue];
        id v67 = [a1 objectForKeyedSubscript:kAccessorySupportsDeveloperSettingsKey];
        v0->_supportsDeveloperSettings = [v67 boolValue];
        id v68 = [a1 objectForKeyedSubscript:kDownloadedVersionKey];
        v0->_downloadedVersion = [v68 copy];
        id v72 = [a1 objectForKeyedSubscript:kDropboxVersionKey];
        v0->_dropboxVersion = [v72 copy];
        id v76 = [a1 objectForKeyedSubscript:kAssetURLOverrideKey];
        v0->_assetURLOverride = [v76 copy];
        id v80 = [a1 objectForKeyedSubscript:kPallasSupportEnabledKey];
        v0->_pallasSupportEnabled = [v80 boolValue];
        id v81 = [a1 objectForKeyedSubscript:kPallasInternalAssetVariant];
        v0->_pallasInternalAssetVariant = [v81 boolValue];
        id v82 = [a1 objectForKeyedSubscript:kPallasAudienceKey];
        v0->_pallasAudience = [v82 integerValue];
        id v83 = [a1 objectForKeyedSubscript:kPallasAudienceOverrideKey];
        v0->_pallasAudienceOverride = [v83 copy];
        v0->_originalSettings = [v0 encodeAsDictionary];
    }
    return v0;
}


UARPSettingsAccessory *-[UARPSettingsAccessory initWithCoder:](NSCoder *a1)
{
    UARPSettingsAccessory *v0 = [super init];
    if (v0 != nil) {
        Class aClass16 = [NSString class];
        v0->_name = [a1 decodeObjectOfClass:aClass16 forKey:kNameKey];
        Class aClass = [NSString class];
        v0->_serialNumber = [a1 decodeObjectOfClass:aClass forKey:kSerialNumberKey];
        Class aClass2 = [NSString class];
        v0->_modelNumber = [a1 decodeObjectOfClass:aClass2 forKey:kModelNumberKey];
        Class aClass3 = [NSString class];
        v0->_mobileAssetModelNumber = [a1 decodeObjectOfClass:aClass3 forKey:kMobileAssetModelNumberKey];
        Class aClass4 = [NSString class];
        v0->_hwFusing = [a1 decodeObjectOfClass:aClass4 forKey:kFusingKey];
        Class aClass5 = [NSString class];
        v0->_activeVersion = [a1 decodeObjectOfClass:aClass5 forKey:kActiveVersionKey];
        Class aClass6 = [NSString class];
        v0->_hwRevision = [a1 decodeObjectOfClass:aClass6 forKey:kHWRevisionKey];
        Class aClass7 = [NSArray class];
        v0->_partnerSerialNumbers = [a1 decodeObjectOfClass:aClass7 forKey:kPartnerSerialNumbersKey];
        Class aClass8 = [NSString class];
        v0->_assetLocation = [a1 decodeObjectOfClass:aClass8 forKey:kAssetLocationKey];
        Class aClass9 = [NSString class];
        v0->_customTrain = [a1 decodeObjectOfClass:aClass9 forKey:kBasejumperTrainKey];
        Class aClass10 = [NSString class];
        v0->_customBuild = [a1 decodeObjectOfClass:aClass10 forKey:kBasejumperBuildKey];
        Class aClass11 = [NSString class];
        v0->_supplementalAssetLocation = [a1 decodeObjectOfClass:aClass11 forKey:kSupplementalAssetLocationKey];
        Class aClass12 = [NSString class];
        v0->_supplementalCustomTrain = [a1 decodeObjectOfClass:aClass12 forKey:kSupplementalBasejumperTrainKey];
        Class aClass13 = [NSString class];
        v0->_supplementalCustomBuild = [a1 decodeObjectOfClass:aClass13 forKey:kSupplementalBasejumperBuildKey];
        v0->_otaDisabled = [a1 decodeBoolForKey:kIsOTADisabledKey];
        v0->_authListingEnabled = [a1 decodeBoolForKey:kAuthListingEnabledKey];
        v0->_personalizationRequired = [a1 decodeBoolForKey:kPersonalizationRequiredKey];
        v0->_accessoryReachable = [a1 decodeBoolForKey:kAccessoryReachableKey];
        v0->_supportsDeveloperSettings = [a1 decodeBoolForKey:kAccessorySupportsDeveloperSettingsKey];
        Class aClass14 = [NSString class];
        v0->_downloadedVersion = [a1 decodeObjectOfClass:aClass14 forKey:kDownloadedVersionKey];
        Class aClass15 = [NSString class];
        v0->_dropboxVersion = [a1 decodeObjectOfClass:aClass15 forKey:kDropboxVersionKey];
        Class aClass17 = [NSString class];
        v0->_assetURLOverride = [a1 decodeObjectOfClass:aClass17 forKey:kAssetURLOverrideKey];
        v0->_pallasAudience = [a1 decodeIntegerForKey:kPallasAudienceKey];
        v0->_pallasSupportEnabled = [a1 decodeBoolForKey:kPallasSupportEnabledKey];
        v0->_pallasInternalAssetVariant = [a1 decodeBoolForKey:kPallasInternalAssetVariant];
        Class aClass18 = [NSString class];
        v0->_pallasAudienceOverride = [a1 decodeObjectOfClass:aClass18 forKey:kPallasAudienceOverrideKey];
    }
    return v0;
}


void -[UARPSettingsAccessory encodeWithCoder:](NSCoder *a1)
{
    [a1 encodeObject:self->_name forKey:kNameKey];
    [a1 encodeObject:self->_serialNumber forKey:kSerialNumberKey];
    [a1 encodeObject:self->_modelNumber forKey:kModelNumberKey];
    [a1 encodeObject:self->_mobileAssetModelNumber forKey:kMobileAssetModelNumberKey];
    [a1 encodeObject:self->_hwFusing forKey:kFusingKey];
    [a1 encodeObject:self->_activeVersion forKey:kActiveVersionKey];
    [a1 encodeObject:self->_hwRevision forKey:kHWRevisionKey];
    [a1 encodeObject:self->_partnerSerialNumbers forKey:kPartnerSerialNumbersKey];
    [a1 encodeObject:self->_assetLocation forKey:kAssetLocationKey];
    [a1 encodeObject:self->_customTrain forKey:kBasejumperTrainKey];
    [a1 encodeObject:self->_customBuild forKey:kBasejumperBuildKey];
    [a1 encodeObject:self->_supplementalAssetLocation forKey:kSupplementalAssetLocationKey];
    [a1 encodeObject:self->_supplementalCustomTrain forKey:kSupplementalBasejumperTrainKey];
    [a1 encodeObject:self->_supplementalCustomBuild forKey:kSupplementalBasejumperBuildKey];
    [a1 encodeBool:self->_otaDisabled forKey:kIsOTADisabledKey];
    [a1 encodeBool:self->_authListingEnabled forKey:kAuthListingEnabledKey];
    [a1 encodeBool:self->_personalizationRequired forKey:kPersonalizationRequiredKey];
    [a1 encodeBool:self->_accessoryReachable forKey:kAccessoryReachableKey];
    [a1 encodeBool:self->_supportsDeveloperSettings forKey:kAccessorySupportsDeveloperSettingsKey];
    [a1 encodeObject:self->_downloadedVersion forKey:kDownloadedVersionKey];
    [a1 encodeObject:self->_dropboxVersion forKey:kDropboxVersionKey];
    [a1 encodeObject:self->_assetURLOverride forKey:kAssetURLOverrideKey];
    [a1 encodeInteger:self->_pallasAudience forKey:kPallasAudienceKey];
    [a1 encodeBool:self->_pallasSupportEnabled forKey:kPallasSupportEnabledKey];
    [a1 encodeBool:self->_pallasInternalAssetVariant forKey:kPallasInternalAssetVariant];
    [a1 encodeObject:self->_pallasAudienceOverride forKey:kPallasAudienceOverrideKey];
}


UARPSettingsAccessory *-[UARPSettingsAccessory copyWithZone:](struct _NSZone *a1)
{
    NSDictionary *encodeAsDictionary = [self encodeAsDictionary];
    return [[UARPSettingsAccessory alloc] initWithDictionary:encodeAsDictionary];
}


bool -[UARPSettingsAccessory isFusingEqual:](NSString *a1)
{
    if (!self->_hwFusing) {
        return !a1;
    }
    return [self->_hwFusing caseInsensitiveCompare:a1] == NSOrderedSame;
}


bool -[UARPSettingsAccessory isEqual:](id a1)
{
    bool v10;
    Class v2 = [UARPSettingsAccessory class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        NSDictionary *encodeAsDictionary = [self encodeAsDictionary];
        NSDictionary *encodeAsDictionary2 = [a1 encodeAsDictionary];
        v10 = [encodeAsDictionary isEqualToDictionary:encodeAsDictionary2] == 1;
    } else {
        v10 = true;
    }
    return v10;
}


NSDictionary *-[UARPSettingsAccessory encodeAsDictionary](void)
{
    NSMutableDictionary *v0 = [NSMutableDictionary new];
    if ([self->_name length] > 0) {
        id obj = [self->_name copy];
        [v0 setObject:obj forKeyedSubscript:kNameKey];
    }
    if ([self->_serialNumber length] > 0) {
        id obj12 = [self->_serialNumber copy];
        [v0 setObject:obj12 forKeyedSubscript:kSerialNumberKey];
    }
    if ([self->_modelNumber length] > 0) {
        id obj20 = [self->_modelNumber copy];
        [v0 setObject:obj20 forKeyedSubscript:kModelNumberKey];
    }
    if ([self->_mobileAssetModelNumber length] > 0) {
        id obj21 = [self->_mobileAssetModelNumber copy];
        [v0 setObject:obj21 forKeyedSubscript:kMobileAssetModelNumberKey];
    }
    if ([self->_hwFusing length] > 0) {
        id obj22 = [self->_hwFusing copy];
        [v0 setObject:obj22 forKeyedSubscript:kFusingKey];
    }
    if ([self->_activeVersion length] > 0) {
        id obj23 = [self->_activeVersion copy];
        [v0 setObject:obj23 forKeyedSubscript:kActiveVersionKey];
    }
    if ([self->_hwRevision length] > 0) {
        id obj24 = [self->_hwRevision copy];
        [v0 setObject:obj24 forKeyedSubscript:kHWRevisionKey];
    }
    if ([self->_partnerSerialNumbers count] > 0) {
        id obj25 = [self->_partnerSerialNumbers copy];
        [v0 setObject:obj25 forKeyedSubscript:kPartnerSerialNumbersKey];
    }
    if ([self->_assetLocation length] > 0) {
        id obj26 = [self->_assetLocation copy];
        [v0 setObject:obj26 forKeyedSubscript:kAssetLocationKey];
    }
    if ([self->_customTrain length] > 0) {
        id obj2 = [self->_customTrain copy];
        [v0 setObject:obj2 forKeyedSubscript:kBasejumperTrainKey];
    }
    if ([self->_customBuild length] > 0) {
        id obj3 = [self->_customBuild copy];
        [v0 setObject:obj3 forKeyedSubscript:kBasejumperBuildKey];
    }
    if ([self->_supplementalAssetLocation length] > 0) {
        id obj4 = [self->_supplementalAssetLocation copy];
        [v0 setObject:obj4 forKeyedSubscript:kSupplementalAssetLocationKey];
    }
    if ([self->_supplementalCustomTrain length] > 0) {
        id obj5 = [self->_supplementalCustomTrain copy];
        [v0 setObject:obj5 forKeyedSubscript:kSupplementalBasejumperTrainKey];
    }
    if ([self->_supplementalCustomBuild length] > 0) {
        id obj6 = [self->_supplementalCustomBuild copy];
        [v0 setObject:obj6 forKeyedSubscript:kSupplementalBasejumperBuildKey];
    }
    NSNumber *obj7 = [NSNumber numberWithBool:self->_otaDisabled];
    [v0 setObject:obj7 forKeyedSubscript:kIsOTADisabledKey];
    NSNumber *obj8 = [NSNumber numberWithBool:self->_authListingEnabled];
    [v0 setObject:obj8 forKeyedSubscript:kAuthListingEnabledKey];
    NSNumber *obj9 = [NSNumber numberWithBool:self->_personalizationRequired];
    [v0 setObject:obj9 forKeyedSubscript:kPersonalizationRequiredKey];
    NSNumber *obj10 = [NSNumber numberWithBool:self->_accessoryReachable];
    [v0 setObject:obj10 forKeyedSubscript:kAccessoryReachableKey];
    NSNumber *obj11 = [NSNumber numberWithBool:self->_supportsDeveloperSettings];
    [v0 setObject:obj11 forKeyedSubscript:kAccessorySupportsDeveloperSettingsKey];
    if ([self->_downloadedVersion length] > 0) {
        id obj13 = [self->_downloadedVersion copy];
        [v0 setObject:obj13 forKeyedSubscript:kDownloadedVersionKey];
    }
    if ([self->_dropboxVersion length] > 0) {
        id obj14 = [self->_dropboxVersion copy];
        [v0 setObject:obj14 forKeyedSubscript:kDropboxVersionKey];
    }
    if ([self->_assetURLOverride length] > 0) {
        id obj15 = [self->_assetURLOverride copy];
        [v0 setObject:obj15 forKeyedSubscript:kAssetURLOverrideKey];
    }
    NSNumber *obj16 = [NSNumber numberWithBool:self->_pallasSupportEnabled];
    [v0 setObject:obj16 forKeyedSubscript:kPallasSupportEnabledKey];
    NSNumber *obj17 = [NSNumber numberWithBool:self->_pallasInternalAssetVariant];
    [v0 setObject:obj17 forKeyedSubscript:kPallasInternalAssetVariant];
    NSNumber *obj18 = [NSNumber numberWithUnsignedInteger:self->_pallasAudience];
    [v0 setObject:obj18 forKeyedSubscript:kPallasAudienceKey];
    if ([self->_pallasAudienceOverride length] > 0) {
        id obj19 = [self->_pallasAudienceOverride copy];
        [v0 setObject:obj19 forKeyedSubscript:kPallasAudienceOverrideKey];
    }
    return [NSDictionary dictionaryWithDictionary:v0];
}


NSMutableDictionary *-[UARPSettingsAccessory encodeAsChangedDictionary](void)
{
    NSDictionary *encodeAsDictionary = [self encodeAsDictionary];
    NSMutableDictionary *v1 = [NSMutableDictionary new];
    [encodeAsDictionary enumerateKeysAndObjectsUsingBlock:^void(id arg1, id arg2, bool *arg3) {
        NSString *v13 = [self->_originalSettings objectForKeyedSubscript:arg1];
        if (v13 != nil) {
            if ([arg2 isKindOfClass:[NSString class]] != 1) {
                if ([arg2 isKindOfClass:[NSNumber class]] != 1) {
                    if ([arg2 isKindOfClass:[NSArray class]] == 1 && ![arg2 isEqualToArray:v13]) {
                        [v1 setObject:arg2 forKeyedSubscript:arg1];
                    }
                } else if (![arg2 isEqualToNumber:v13]) {
                    [v1 setObject:arg2 forKeyedSubscript:arg1];
                }
            } else if (![arg2 isEqualToString:v13]) {
                [v1 setObject:arg2 forKeyedSubscript:arg1];
            }
        } else {
            [v1 setObject:arg2 forKeyedSubscript:arg1];
        }
    }];
    [self->_originalSettings enumerateKeysAndObjectsUsingBlock:^void(id arg1, id arg2, bool *arg3) {
        id v14 = arg3;
        id v16 = [encodeAsDictionary objectForKeyedSubscript:v14];
        if (!v16) {
            NSNull *null = [NSNull null];
            [v1 setObject:null forKeyedSubscript:v14];
        }
    }];
    return ([v1 count] <= 0) ? nil : v1;
}


void -[UARPSettingsAccessory setName:](id a1)
{
    self->_name = [a1 copy];
}


void -[UARPSettingsAccessory setSerialNumber:](id a1)
{
    self->_serialNumber = [a1 copy];
}


void -[UARPSettingsAccessory setModelNumber:](id a1)
{
    self->_modelNumber = [a1 copy];
}


void -[UARPSettingsAccessory setMobileAssetModelNumber:](id a1)
{
    self->_mobileAssetModelNumber = [a1 copy];
}


void -[UARPSettingsAccessory setHwFusing:](id a1)
{
    self->_hwFusing = [a1 copy];
}


void -[UARPSettingsAccessory setHwRevision:](id a1)
{
    self->_hwRevision = [a1 copy];
}


void -[UARPSettingsAccessory setActiveVersion:](id a1)
{
    self->_activeVersion = [a1 copy];
}


void -[UARPSettingsAccessory setPartnerSerialNumbers:](id a1)
{
    self->_partnerSerialNumbers = [a1 copy];
}


void -[UARPSettingsAccessory setOtaDisabled:](bool a1)
{
    self->_otaDisabled = a1;
}


void -[UARPSettingsAccessory setAuthListingEnabled:](bool a1)
{
    self->_authListingEnabled = a1;
}


void -[UARPSettingsAccessory setPersonalizationRequired:](bool a1)
{
    self->_personalizationRequired = a1;
}


void -[UARPSettingsAccessory setAccessoryReachable:](bool a1)
{
    self->_accessoryReachable = a1;
}


void -[UARPSettingsAccessory setSupportsDeveloperSettings:](bool a1)
{
    self->_supportsDeveloperSettings = a1;
}


void -[UARPSettingsAccessory setAssetLocation:](NSString *a1)
{
    self->_assetLocation = [a1 copy];
}


void -[UARPSettingsAccessory setCustomTrain:](id a1)
{
    self->_customTrain = [a1 copy];
}


void -[UARPSettingsAccessory setCustomBuild:](id a1)
{
    self->_customBuild = [a1 copy];
}


void -[UARPSettingsAccessory setSupplementalAssetLocation:](id a1)
{
    self->_supplementalAssetLocation = [a1 copy];
}


void -[UARPSettingsAccessory setSupplementalCustomTrain:](id a1)
{
    self->_supplementalCustomTrain = [a1 copy];
}


void -[UARPSettingsAccessory setSupplementalCustomBuild:](id a1)
{
    self->_supplementalCustomBuild = [a1 copy];
}


void -[UARPSettingsAccessory setDownloadedVersion:](id a1)
{
    self->_downloadedVersion = [a1 copy];
}


void -[UARPSettingsAccessory setDropboxVersion:](id a1)
{
    self->_dropboxVersion = [a1 copy];
}


void -[UARPSettingsAccessory setAssetURLOverride:](id a1)
{
    self->_assetURLOverride = [a1 copy];
}


void -[UARPSettingsAccessory setPallasAudience:](unsigned long a1)
{
    self->_pallasAudience = a1;
}


void -[UARPSettingsAccessory setPallasSupportEnabled:](bool a1)
{
    self->_pallasSupportEnabled = a1;
}


void -[UARPSettingsAccessory setPallasInternalAssetVariant:](bool a1)
{
    self->_pallasInternalAssetVariant = a1;
}


void -[UARPSettingsAccessory setPallasAudienceOverride:](id a1)
{
    self->_pallasAudienceOverride = [a1 copy];
}


NSString *-[UARPSettingsAccessory description](void)
{
    NSDictionary *encodeAsDictionary = [self encodeAsDictionary];
    return [NSString stringWithFormat:@"%@", encodeAsDictionary];
}


NSString *-[UARPSettingsAccessory name](void)
{
    return objc_getProperty(self, _cmd, 24, 1);
}


NSString *-[UARPSettingsAccessory serialNumber](void)
{
    return objc_getProperty(self, _cmd, 32, 1);
}


NSString *-[UARPSettingsAccessory modelNumber](void)
{
    return objc_getProperty(self, _cmd, 40, 1);
}


NSString *-[UARPSettingsAccessory mobileAssetModelNumber](void)
{
    return objc_getProperty(self, _cmd, 48, 1);
}


NSString *-[UARPSettingsAccessory hwFusing](void)
{
    return objc_getProperty(self, _cmd, 56, 1);
}


NSString *-[UARPSettingsAccessory hwRevision](void)
{
    return objc_getProperty(self, _cmd, 64, 1);
}


NSString *-[UARPSettingsAccessory activeVersion](void)
{
    return objc_getProperty(self, _cmd, 72, 1);
}


NSArray *-[UARPSettingsAccessory partnerSerialNumbers](void)
{
    return objc_getProperty(self, _cmd, 80, 1);
}


bool -[UARPSettingsAccessory otaDisabled](void)
{
    return self->_otaDisabled;
}


bool -[UARPSettingsAccessory authListingEnabled](void)
{
    return self->_authListingEnabled;
}


bool -[UARPSettingsAccessory personalizationRequired](void)
{
    return self->_personalizationRequired;
}


bool -[UARPSettingsAccessory accessoryReachable](void)
{
    return self->_accessoryReachable;
}


bool -[UARPSettingsAccessory supportsDeveloperSettings](void)
{
    return self->_supportsDeveloperSettings;
}


NSString *-[UARPSettingsAccessory assetLocation](void)
{
    return objc_getProperty(self, _cmd, 88, 1);
}


NSString *-[UARPSettingsAccessory customTrain](void)
{
    return objc_getProperty(self, _cmd, 96, 1);
}


NSString *-[UARPSettingsAccessory customBuild](void)
{
    return objc_getProperty(self, _cmd, 104, 1);
}


NSString *-[UARPSettingsAccessory supplementalAssetLocation](void)
{
    return objc_getProperty(self, _cmd, 112, 1);
}


NSString *-[UARPSettingsAccessory supplementalCustomTrain](void)
{
    return objc_getProperty(self, _cmd, 120, 1);
}


NSString *-[UARPSettingsAccessory supplementalCustomBuild](void)
{
    return objc_getProperty(self, _cmd, 128, 1);
}


NSString *-[UARPSettingsAccessory downloadedVersion](void)
{
    return objc_getProperty(self, _cmd, 136, 1);
}


NSString *-[UARPSettingsAccessory dropboxVersion](void)
{
    return objc_getProperty(self, _cmd, 144, 1);
}


NSString *-[UARPSettingsAccessory assetURLOverride](void)
{
    return objc_getProperty(self, _cmd, 152, 1);
}


bool -[UARPSettingsAccessory pallasSupportEnabled](void)
{
    return self->_pallasSupportEnabled;
}


bool -[UARPSettingsAccessory pallasInternalAssetVariant](void)
{
    return self->_pallasInternalAssetVariant;
}


unsigned long -[UARPSettingsAccessory pallasAudience](void)
{
    return self->_pallasAudience;
}


NSString *-[UARPSettingsAccessory pallasAudienceOverride](void)
{
    return objc_getProperty(self, _cmd, 168, 1);
}


void -[UARPSettingsAccessory .cxx_destruct](void)
{
    self->_pallasAudienceOverride = nil;
    self->_assetURLOverride = nil;
    self->_dropboxVersion = nil;
    self->_downloadedVersion = nil;
    self->_supplementalCustomBuild = nil;
    self->_supplementalCustomTrain = nil;
    self->_supplementalAssetLocation = nil;
    self->_customBuild = nil;
    self->_customTrain = nil;
    self->_assetLocation = nil;
    self->_partnerSerialNumbers = nil;
    self->_activeVersion = nil;
    self->_hwRevision = nil;
    self->_hwFusing = nil;
    self->_mobileAssetModelNumber = nil;
    self->_modelNumber = nil;
    self->_serialNumber = nil;
    self->_name = nil;
    self->_originalSettings = nil;
}
