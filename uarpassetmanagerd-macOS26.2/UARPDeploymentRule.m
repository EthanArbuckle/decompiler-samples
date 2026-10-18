struct UARPDeploymentRule {
    NSObject<OS_os_log> *_log; // +0x8
    NSString *_testSerialNumber; // +0x10
    NSNumber *_deploymentPercent; // +0x18
    NSNumber *_deploymentDay; // +0x20
    NSString *_serialNumber; // +0x28
    NSString *_minOSVersion; // +0x30
    NSString *_maxOSVersion; // +0x38
    bool _isFullyDeployedDeploymentLimits; // +0x40
    NSString *_currentISOCountryCode; // +0x48
    NSDate *_goLiveDate; // +0x50
    NSArray *_countryList; // +0x58
    NSNumber *_rampPeriod; // +0x60
    NSNumber *_deploymentLimit; // +0x68
    NSMutableDictionary *_deploymentLimits; // +0x70
};

static long kUARPErrorDomain;

bool +[UARPDeploymentRule supportsSecureCoding](void)
{
    return true;
}


UARPDeploymentRule *-[UARPDeploymentRule initWithMinOSVersion:maxOSVersion:](id a1, id a2)
{
    UARPDeploymentRule *v0 = [super init];
    if (v0 != nil) {
        v0->_minOSVersion = [a1 copy];
        v0->_maxOSVersion = [a2 copy];
    }
    return v0;
}


UARPDeploymentRule *-[UARPDeploymentRule initWithConfig:](id a1)
{
    bool v9;
    UARPDeploymentRule *v53;
    NSNumber *rampPeriod3 = [a1 rampPeriod];
    bool v5 = false;
    if (rampPeriod3 != nil) {
        NSNumber *deploymentLimit3 = [a1 deploymentLimit];
        v5 = deploymentLimit3 != nil;
    }
    if (v5) {
        return nil;
    }
    if ([a1 rampPeriod]) {
        NSNumber *rampPeriod = [a1 rampPeriod];
        unsigned int unsignedIntValue2 = [rampPeriod unsignedIntValue];
        v9 = unsignedIntValue2 == 7 || unsignedIntValue2 == 28;
    } else if (![a1 deploymentLimit]) {
        v9 = true;
    } else {
        NSNumber *deploymentLimit = [a1 deploymentLimit];
        unsigned int unsignedIntValue = [deploymentLimit unsignedIntValue];
        v9 = !(unsignedIntValue <= 0 || unsignedIntValue > 99);
    }
    if (v9) {
        UARPDeploymentRule *v0 = [super init];
        if (v0 != nil) {
            NSDate *goLiveDate = [a1 goLiveDate];
            v0->_goLiveDate = [goLiveDate copy];
            NSArray *countryList = [a1 countryList];
            v0->_countryList = [countryList copy];
            NSNumber *rampPeriod2 = [a1 rampPeriod];
            v0->_rampPeriod = [rampPeriod2 copy];
            NSNumber *deploymentLimit2 = [a1 deploymentLimit];
            v0->_deploymentLimit = [deploymentLimit2 copy];
            v0->_log = os_log_create("com.apple.accessoryupdater.uarp", "deployment");
            if ([GEOCountryConfiguration class] != 0) {
                id sharedConfiguration = [GEOCountryConfiguration sharedConfiguration];
                NSString *countryCode = [sharedConfiguration countryCode];
                v0->_currentISOCountryCode = [countryCode copy];
            }
            v0->_deploymentLimits = [[NSMutableDictionary alloc] init];
            v0->_isFullyDeployedDeploymentLimits = NO;
            NSError *v45 = nil;
            id v46 = [v0->_deploymentLimit copy];
            id v47 = [v0->_goLiveDate copy];
            [v0 addDeploymentLimit:v46 withGoLiveDate:v47 error:&v45];
            if (v45 != nil) {
                NSObject<OS_os_log> *oslog = v0->_log;
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: Failed to initialize deployment limits with error %@", "-[UARPDeploymentRule initWithConfig:]", v45);
                }
            }
        }
        v53 = v0;
    } else {
        v53 = nil;
    }
    return v53;
}


UARPDeploymentRule *-[UARPDeploymentRule initWithCoder:](NSCoder *a1)
{
    UARPDeploymentRule *v0 = [super init];
    if (v0 != nil) {
        v0->_goLiveDate = [a1 decodeObjectOfClass:[NSDate class] forKey:@"goLiveDate"];
        v0->_rampPeriod = [a1 decodeObjectOfClass:[NSNumber class] forKey:@"rampPeriod"];
        v0->_deploymentLimit = [a1 decodeObjectOfClass:[NSNumber class] forKey:@"deploymentLimit"];
        NSArray *v17 = @[[NSArray class], [NSString class]];
        NSSet *classes = [NSSet setWithArray:v17];
        v0->_countryList = [a1 decodeObjectOfClasses:classes forKey:@"countryList"];
        v0->_minOSVersion = [a1 decodeObjectOfClass:[NSString class] forKey:@"minOSVersion"];
        v0->_maxOSVersion = [a1 decodeObjectOfClass:[NSString class] forKey:@"maxOSVersion"];
    }
    return v0;
}


void -[UARPDeploymentRule encodeWithCoder:](NSCoder *a1)
{
    [a1 encodeObject:self->_goLiveDate forKey:@"goLiveDate"];
    [a1 encodeObject:self->_countryList forKey:@"countryList"];
    [a1 encodeObject:self->_rampPeriod forKey:@"rampPeriod"];
    [a1 encodeObject:self->_deploymentLimit forKey:@"deploymentLimit"];
    [a1 encodeObject:self->_minOSVersion forKey:@"minOSVersion"];
    [a1 encodeObject:self->_maxOSVersion forKey:@"maxOSVersion"];
}


UARPDeploymentRule *-[UARPDeploymentRule copyWithZone:](struct _NSZone *a1)
{
    UARPDeploymentRule *v0 = [[UARPDeploymentRule alloc] init];
    objc_storeStrong(v0 + 72, self->_currentISOCountryCode);
    objc_storeStrong(v0 + 80, self->_goLiveDate);
    objc_storeStrong(v0 + 88, self->_countryList);
    objc_storeStrong(v0 + 96, self->_rampPeriod);
    objc_storeStrong(v0 + 104, self->_deploymentLimit);
    v0->field_112 = [self->_deploymentLimits mutableCopy];
    v0->field_64 = self->_isFullyDeployedDeploymentLimits;
    v0->field_48 = [self->_minOSVersion copy];
    v0->field_56 = [self->_maxOSVersion copy];
    return v0;
}


NSString *-[UARPDeploymentRule description](void)
{
    NSString *v0 = NSStringFromClass([self class]);
    return [NSString stringWithFormat:@"<%@: goLiveDate=%@, countryList=%@, rampPeriod=%@, deploymentLimit=%@>", v0, self->_goLiveDate, self->_countryList, self->_rampPeriod, self->_deploymentLimit];
}


void -[UARPDeploymentRule setTestSerialNumber:](id a1)
{
    self->_testSerialNumber = [a1 copy];
}


NSString *-[UARPDeploymentRule testSerialNumber](void)
{
    return self->_testSerialNumber;
}


void -[UARPDeploymentRule setDeploymentDay:](NSNumber *a1)
{
    self->_deploymentDay = a1;
}


NSNumber *-[UARPDeploymentRule deploymentDay](void)
{
    return self->_deploymentDay;
}


void -[UARPDeploymentRule setDeploymentPercent:](NSNumber *a1)
{
    self->_deploymentPercent = a1;
}


NSNumber *-[UARPDeploymentRule deploymentPercent](void)
{
    return self->_deploymentPercent;
}


bool -[UARPDeploymentRule isDeploymentAllowed:](NSError **a1)
{
    bool v0 = true;
    [self createSerialNumber];
    [self calculateDeploymentDay];
    [self calculateDeploymentPercent];
    if (self->_goLiveDate != nil) {
        v0 = [self isDeploymentAllowedPerGoLiveDate];
    }
    if (v0) {
        if ([self->_countryList count] != 0) {
            v0 = [self isDeploymentAllowedPerCountryList];
        }
        if (v0) {
            if (self->_rampPeriod != nil) {
                v0 = [self isDeploymentAllowedPerRampPeriod];
            }
            if (v0) {
                if (self->_deploymentLimit != nil) {
                    v0 = [self isDeploymentAllowedPerDeploymentLimit];
                }
                if (self->_minOSVersion != nil && self->_maxOSVersion != nil) {
                    NSOperatingSystemVersion v2 = 0;
                    memset(v2 + 8, 0, 16);
                    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
                    if (!processInfo) {
                        v2 = 0;
                        memset(v2 + 8, 0, 16);
                    } else {
                        v2 = [processInfo operatingSystemVersion];
                    }
                    NSString *v5 = [NSString stringWithFormat:@"%ld.%ld.%ld", v2, v2.minorVersion, v2.patchVersion];
                    long v6 = [self compareOSVersion:self->_minOSVersion withVersion:v5];
                    long v7 = [self compareOSVersion:self->_maxOSVersion withVersion:v5];
                    bool v8 = true;
                    if (v6 != 0) {
                        v8 = v6 == -1;
                    }
                    bool v9 = true;
                    if (v7 != 0) {
                        v9 = v7 == 1;
                    }
                    v0 = v8 && v9;
                }
            }
        }
    }
    if (!v0) {
        *(a1) = [NSError errorWithDomain:kUARPErrorDomain code:6 userInfo:nil];
    }
    return v0;
}


long -[UARPDeploymentRule compareOSVersion:withVersion:](NSString *a1, NSString *a2)
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
            return 0;
        }
        NSUInteger count = [v4 count];
        if (v6 >= count) {
            break;
        }
        NSUInteger count2 = [v5 count];
        if (v6 >= count2) {
            return 1;
        }
        NSString *v12 = [v4 objectAtIndexedSubscript:v6];
        NSInteger integerValue = [v12 integerValue];
        NSString *v14 = [v5 objectAtIndexedSubscript:v6];
        NSInteger integerValue2 = [v14 integerValue];
        if (integerValue > integerValue2) {
            return 1;
        }
        if (integerValue < integerValue2) {
            return -1;
        }
        v6++;
    }
    return -1;
}


bool -[UARPDeploymentRule isDeploymentAllowedPerCountryList](void)
{
    bool v5;
    if (!self->_currentISOCountryCode) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            NSString *v1 = self->_currentISOCountryCode;
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: Current location unknown %@", "-[UARPDeploymentRule isDeploymentAllowedPerCountryList]", v1);
        }
        if ([GEOCountryConfiguration class] == 0) {
            return true;
        }
    }
    if (self->_currentISOCountryCode != nil) {
        if ([self->_countryList containsObject:self->_currentISOCountryCode] != 1) {
            NSObject<OS_os_log> *oslog2 = self->_log;
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Device not in country list, deployment not allowed", "-[UARPDeploymentRule isDeploymentAllowedPerCountryList]");
            }
            v5 = false;
        } else {
            NSObject<OS_os_log> *oslog3 = self->_log;
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%s: Device is in country list", "-[UARPDeploymentRule isDeploymentAllowedPerCountryList]");
            }
            v5 = true;
        }
    } else {
        return false;
    }
    return v5;
}


bool -[UARPDeploymentRule isDeploymentAllowedPerGoLiveDate](void)
{
    bool v6;
    NSDate *date = [NSDate date];
    NSComparisonResult v2 = [date compare:self->_goLiveDate];
    if (v2 == NSOrderedDescending) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            NSDate *v7 = self->_goLiveDate;
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: GoLive %@ date in past (today: %@), deployment allowed", "-[UARPDeploymentRule isDeploymentAllowedPerGoLiveDate]", v7, date);
        }
        v6 = true;
    } else if (v2 != NSOrderedSame) {
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            NSDate *v3 = self->_goLiveDate;
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: GoLive date (%@) in future (today: %@), deployment not allowed", "-[UARPDeploymentRule isDeploymentAllowedPerGoLiveDate]", v3, date);
        }
        v6 = false;
    } else {
        NSObject<OS_os_log> *oslog3 = self->_log;
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
            NSDate *v4 = self->_goLiveDate;
            os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "%s: GoLive %@ date today (today: %@), deployment allowed", "-[UARPDeploymentRule isDeploymentAllowedPerGoLiveDate]", v4, date);
        }
        v6 = true;
    }
    return v6;
}


bool -[UARPDeploymentRule isDeploymentAllowedPerRampPeriod](void)
{
    uint8_t v1[32];
    *(uint64_t *)&v1[24] = _cmd;
    *(uint8_t *)&v1[23] = 0;
    *(uint64_t *)&v1[8] = 0;
    *(uint64_t *)&v1[0] = 0;
    time((time_t *)v1);
    struct tm *v2 = localtime((const time_t *)v1);
    if (self->_deploymentDay != nil) {
        unsigned int unsignedIntValue = [self->_deploymentDay unsignedIntValue];
        if (v2->tm_wday == unsignedIntValue) {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
                os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: Today is the day for Ramped Updates: Day %d", "-[UARPDeploymentRule isDeploymentAllowedPerRampPeriod]", unsignedIntValue);
            }
            *(uint8_t *)&v1[23] = 1;
            return *(uint8_t *)&v1[23] & 1;
        }
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            int v4 = v2->tm_wday;
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Cannot apply update today is Day %d and this device can only do Ramped Updates on Day %d", "-[UARPDeploymentRule isDeploymentAllowedPerRampPeriod]", v4, unsignedIntValue);
        }
        *(uint8_t *)&v1[23] = 0;
        return *(uint8_t *)&v1[23] & 1;
    } else {
        return false;
    }
}


bool -[UARPDeploymentRule isDeploymentAllowedPerDeploymentLimit](void)
{
    bool v6;
    if (self->_deploymentPercent == nil) {
        return false;
    }
    unsigned int unsignedIntValue = [self->_deploymentLimit unsignedIntValue];
    unsigned int unsignedIntValue2 = [self->_deploymentPercent unsignedIntValue];
    if (unsignedIntValue2 > unsignedIntValue) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: Device cannot apply metered rollout as it doesn't fall under %d percent. Device is %d percent.", "-[UARPDeploymentRule isDeploymentAllowedPerDeploymentLimit]", unsignedIntValue, unsignedIntValue2);
        }
        v6 = false;
    } else {
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Device can apply metered rollout, %d percent.", "-[UARPDeploymentRule isDeploymentAllowedPerDeploymentLimit]", unsignedIntValue2);
        }
        v6 = true;
    }
    return v6;
}


void -[UARPDeploymentRule calculateDeploymentDay](void)
{
    long v0 = 0;
    if (!self->_serialNumber || !self->_rampPeriod) {
        return;
    }
    unsigned int unsignedIntValue = [self->_rampPeriod unsignedIntValue];
    const char *UTF8String = [self->_serialNumber UTF8String];
    NSUInteger length = [self->_serialNumber length];
    for (int v4 = 0; (unsigned int)v4 < length; v4++) {
        v0 += UTF8String[v4];
    }
    int v5 = v0 % unsignedIntValue;
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: deployDay = %d", "-[UARPDeploymentRule calculateDeploymentDay]", v5);
    }
    self->_deploymentDay = [NSNumber numberWithUnsignedInt:v5];
}


void -[UARPDeploymentRule calculateDeploymentPercent](void)
{
    long v0 = 0;
    long v1 = 3;
    if (!self->_serialNumber) {
        return;
    }
    const char *UTF8String = [self->_serialNumber UTF8String];
    NSUInteger length = [self->_serialNumber length];
    for (int v4 = 0; (unsigned int)v4 < length; v4++) {
        v0 += UTF8String[v4];
        v1 *= UTF8String[v4];
    }
    int v5 = v0 % 10 * 10 + v1 % 10;
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: deployPercent = %d", "-[UARPDeploymentRule calculateDeploymentPercent]", v5);
    }
    self->_deploymentPercent = [NSNumber numberWithUnsignedInt:v5];
}


void -[UARPDeploymentRule createSerialNumber](void)
{
    if (!self->_testSerialNumber) {
        self->_serialNumber = MGCopyAnswer(@"SerialNumber", 0);
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog, OS_LOG_TYPE_INFO, "%s: Using device serial number as seed", "-[UARPDeploymentRule createSerialNumber]");
        }
    } else {
        self->_serialNumber = self->_testSerialNumber;
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            NSString *v3 = self->_serialNumber;
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Using %@ provided by user as seed", "-[UARPDeploymentRule createSerialNumber]", v3);
        }
    }
}


void -[UARPDeploymentRule addDeploymentLimit:withGoLiveDate:error:](id a1, id<NSCopying> a2, NSError **a3)
{
    if (self->_isFullyDeployedDeploymentLimits) {
        NSMutableDictionary *v13 = [NSMutableDictionary new];
        NSString *obj = [NSString stringWithFormat:@"Invalid Deployment Rule: Deployment already scheduled for full deployment for %@", self->_currentISOCountryCode];
        [v13 setObject:obj forKeyedSubscript:NSLocalizedDescriptionKey];
        *(a3) = [NSError errorWithDomain:kUARPErrorDomain code:6 userInfo:v13];
    } else if (![self->_deploymentLimits objectForKey:a2]) {
        if (a2 != nil) {
            [self->_deploymentLimits setObject:a1 forKeyedSubscript:a2];
        }
        [self validateDeploymentLimits:a3];
    } else {
        NSMutableDictionary *v5 = [NSMutableDictionary new];
        NSString *description = [self->_goLiveDate description];
        NSString *obj2 = [NSString stringWithFormat:@"Invalid Deployment Rule: Deployment Limit already set on Go Live Date %@ for %@", description, self->_currentISOCountryCode];
        [v5 setObject:obj2 forKeyedSubscript:NSLocalizedDescriptionKey];
        *(a3) = [NSError errorWithDomain:kUARPErrorDomain code:6 userInfo:v5];
    }
}


bool -[UARPDeploymentRule validateDeploymentLimits:](NSError **a1)
{
    NSArray *allKeys = [self->_deploymentLimits allKeys];
    NSArray *v1 = [allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSUInteger v2 = 1;
    while (v2 < [v1 count]) {
        id v4 = [v1 objectAtIndexedSubscript:v2 - 1];
        id v5 = [self->_deploymentLimits objectForKeyedSubscript:v4];
        unsigned int unsignedIntValue2 = [v5 unsignedIntValue];
        id v7 = [v1 objectAtIndexedSubscript:v2];
        id v8 = [self->_deploymentLimits objectForKeyedSubscript:v7];
        unsigned int unsignedIntValue3 = [v8 unsignedIntValue];
        if (unsignedIntValue2 >= unsignedIntValue3) {
            NSMutableDictionary *v11 = [NSMutableDictionary new];
            id v14 = [v1 objectAtIndexedSubscript:v2];
            id description = [v14 description];
            NSString *obj = [NSString stringWithFormat:@"Invalid Deployment Rule: Deployment Limit %lu for %@ with Go Live Date %@ is invalid, must be strictly increasing", unsignedIntValue3, self->_currentISOCountryCode, description];
            [v11 setObject:obj forKeyedSubscript:NSLocalizedDescriptionKey];
            *(a1) = [NSError errorWithDomain:kUARPErrorDomain code:6 userInfo:v11];
            id v20 = [v1 objectAtIndexedSubscript:v2];
            [self->_deploymentLimits removeObjectForKey:v20];
            return false;
        }
        v2++;
    }
    id lastObject = [v1 lastObject];
    id v23 = [self->_deploymentLimits objectForKeyedSubscript:lastObject];
    unsigned int unsignedIntValue = [v23 unsignedIntValue];
    if (unsignedIntValue == 100) {
        self->_isFullyDeployedDeploymentLimits = YES;
    }
    return true;
}


void -[UARPDeploymentRule dumpWithTabDepth:dumpString:](unsigned long a1, id a2)
{
    [a2 appendWithTabDepth:a1 format:@"Deployment Rule:\n"];
    if (self->_currentISOCountryCode != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Current Country Code: %@\n", self->_currentISOCountryCode];
    }
    if (self->_goLiveDate != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Go-Live Date: %@\n", self->_goLiveDate];
    }
    if ([self->_countryList count] != 0) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Country List:"];
        for (id v8 in self->_countryList) {
            [a2 appendFormat:@" %@", v8];
        }
        [a2 appendString:@"\n"];
    }
    if (self->_rampPeriod != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Ramp Period: %@\n", self->_rampPeriod];
    }
    if (self->_deploymentLimit != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Deployment Limit: %@\n", self->_deploymentLimit];
    }
    if (self->_deploymentPercent != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Deployment Percent: %@\n", self->_deploymentPercent];
    }
    if (self->_deploymentDay != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Deployment Day: %@\n", self->_deploymentDay];
    }
    if (self->_serialNumber != nil) {
        [a2 appendWithTabDepth:a1 + 1 format:@"Serial Number: %@\n", self->_serialNumber];
    }
}


BOOL -[UARPDeploymentRule isEqual:](id a1)
{
    BOOL v4;
    if (a1 == nil) {
        return NO;
    }
    if ([a1 isKindOfClass:[UARPDeploymentRule class]]) {
        if (a1 != self) {
            NSString *currentISOCountryCode = [self currentISOCountryCode];
            NSString *currentISOCountryCode2 = [a1 currentISOCountryCode];
            v4 = [currentISOCountryCode isEqualToString:currentISOCountryCode2];
        } else {
            v4 = YES;
        }
    } else {
        v4 = NO;
    }
    return v4;
}


NSUInteger -[UARPDeploymentRule hash](void)
{
    return [self->_currentISOCountryCode hash];
}


NSString *-[UARPDeploymentRule currentISOCountryCode](void)
{
    return objc_getProperty(self, _cmd, 72, 1);
}


void -[UARPDeploymentRule setCurrentISOCountryCode:](NSString *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 72);
}


NSDate *-[UARPDeploymentRule goLiveDate](void)
{
    return objc_getProperty(self, _cmd, 80, 1);
}


void -[UARPDeploymentRule setGoLiveDate:](NSDate *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 80);
}


NSArray *-[UARPDeploymentRule countryList](void)
{
    return objc_getProperty(self, _cmd, 88, 1);
}


void -[UARPDeploymentRule setCountryList:](NSArray *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 88);
}


NSNumber *-[UARPDeploymentRule rampPeriod](void)
{
    return objc_getProperty(self, _cmd, 96, 1);
}


void -[UARPDeploymentRule setRampPeriod:](NSNumber *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 96);
}


NSNumber *-[UARPDeploymentRule deploymentLimit](void)
{
    return objc_getProperty(self, _cmd, 104, 1);
}


void -[UARPDeploymentRule setDeploymentLimit:](NSNumber *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 104);
}


NSMutableDictionary *-[UARPDeploymentRule deploymentLimits](void)
{
    return objc_getProperty(self, _cmd, 112, 1);
}


void -[UARPDeploymentRule setDeploymentLimits:](NSMutableDictionary *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, 112);
}


bool -[UARPDeploymentRule isFullyDeployedDeploymentLimits](void)
{
    return self->_isFullyDeployedDeploymentLimits;
}


void -[UARPDeploymentRule setIsFullyDeployedDeploymentLimits:](bool a1)
{
    self->_isFullyDeployedDeploymentLimits = a1;
}


void -[UARPDeploymentRule .cxx_destruct](void)
{
    self->_deploymentLimits = nil;
    self->_deploymentLimit = nil;
    self->_rampPeriod = nil;
    self->_countryList = nil;
    self->_goLiveDate = nil;
    self->_currentISOCountryCode = nil;
    self->_maxOSVersion = nil;
    self->_minOSVersion = nil;
    self->_serialNumber = nil;
    self->_deploymentDay = nil;
    self->_deploymentPercent = nil;
    self->_testSerialNumber = nil;
    self->_log = nil;
}
