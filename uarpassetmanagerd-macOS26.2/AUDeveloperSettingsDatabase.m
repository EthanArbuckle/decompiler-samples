struct AUDeveloperSettingsDatabase {
    NSObject<OS_os_log> *_log; // +0x8
};

AUDeveloperSettingsDatabase *+[AUDeveloperSettingsDatabase sharedDatabase](void)
{
    dispatch_once(&sharedDatabase.onceToken, ^void(void) {
        sharedDatabase.sharedDatabase = [[AUDeveloperSettingsDatabase alloc] init];
    });
    return sharedDatabase.sharedDatabase;
}


AUDeveloperSettingsDatabase *-[AUDeveloperSettingsDatabase init](void)
{
    AUDeveloperSettingsDatabase *v0 = [super init];
    if (v0 != nil) {
        const char *dso = [@"com.apple.AUDeveloperSettings" UTF8String];
        v0->_log = os_log_create(dso, "default");
    }
    return v0;
}


NSArray *-[AUDeveloperSettingsDatabase accessoryList](void)
{
    NSMutableArray *v0 = [NSMutableArray new];
    NSMutableArray *v2 = v0;
    NSDictionary *accessoriesDictionary = [self accessoriesDictionary];
    [accessoriesDictionary enumerateKeysAndObjectsUsingBlock:^void(id arg1, id arg2, bool *arg3) {
        Class v19 = [NSString class];
        if (![arg1 isKindOfClass:v19] || ![arg2 isKindOfClass:[NSDictionary class]]) {
            NSObject<OS_os_log> *oslog = self->_log;
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: unknown key/value pair %@/%@", "-[AUDeveloperSettingsDatabase accessoryList]_block_invoke", arg1, arg2);
            }
        } else {
            id v21 = [arg2 mutableCopy];
            id v17 = [arg1 copy];
            [v21 setObject:v17 forKeyedSubscript:@"serialNumber"];
            [v2 addObject:[[UARPSettingsAccessory alloc] initWithDictionary:v21]];
        }
    }];
    return [NSArray arrayWithArray:v2];
}


void -[AUDeveloperSettingsDatabase removeAccessory:](id a1)
{
    NSString *serialNumber = [a1 serialNumber];
    [self removeAccessoryWithSerialNumber:serialNumber];
}


void -[AUDeveloperSettingsDatabase updateAccessory:](id a1)
{
    NSMutableDictionary *encodeAsChangedDictionary = [a1 encodeAsChangedDictionary];
    if (encodeAsChangedDictionary != nil) {
        NSString *serialNumber = [a1 serialNumber];
        [self updateAccessoryWithSerialNumber:serialNumber info:encodeAsChangedDictionary];
    }
}


id -[AUDeveloperSettingsDatabase copyAccessoryWithSerialNumber:](NSString *a1)
{
    id v2 = nil;
    NSArray *accessoryList = [self accessoryList];
    for (UARPSettingsAccessory *v10 in accessoryList) {
        NSString *serialNumber = [v10 serialNumber];
        BOOL v12 = [serialNumber isEqualToString:a1];
        if (v12 == 1) {
            id v15 = [v10 copy];
            v2 = v15;
            [v2 setSerialNumber:a1];
            return v2;
        }
        NSArray *partnerSerialNumbers = [v10 partnerSerialNumbers];
        BOOL v14 = [partnerSerialNumbers containsObject:a1];
        if (v14 == 1) {
            return [v10 copy];
        }
    }
    return v2;
}


id -[AUDeveloperSettingsDatabase copyAccessoryForSignature:modelNumber:fusingType:partnerSerialNumbers:](id a1, id a2, id a3, id a4)
{
    NSString *v8 = getAccessoryDatabaseKeyForAccessory(a1, a2, a3, a4);
    return (v8 != nil) ? [self copyAccessoryWithSerialNumber:v8] : nil;
}


void -[AUDeveloperSettingsDatabase setAccessoriesDictionary:](id a1)
{
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "%s: setting %@", "-[AUDeveloperSettingsDatabase setAccessoriesDictionary:]", a1);
    }
    [NSUserDefaults AUDeveloperSettingsSetObject:a1 withKey:@"accessories"];
}


NSDictionary *-[AUDeveloperSettingsDatabase accessoriesDictionary](void)
{
    id v0 = [NSUserDefaults AUDeveloperSettingsObjectWithKey:@"accessories"];
    Class v1 = [NSDictionary class];
    if (![v0 isKindOfClass:v1]) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: received unknown object = %@", "-[AUDeveloperSettingsDatabase accessoriesDictionary]", v0);
        }
        v0 = nil;
    }
    if (!v0) {
        NSDictionary *v5 = [[NSDictionary alloc] init];
        v0 = v5;
    }
    return v0;
}


bool -[AUDeveloperSettingsDatabase isSeedParticipationEnabled:](id a1)
{
    if ([self urlLocationTypeForAccessory:a1] == 3) {
        return true;
    }
    return [self urlLocationTypeForAccessory:a1] == 8;
}


unsigned long -[AUDeveloperSettingsDatabase urlLocationTypeForAccessory:](id a1)
{
    NSDictionary *accessoriesDictionary = [self accessoriesDictionary];
    id v6 = [accessoriesDictionary objectForKeyedSubscript:a1];
    return AUDeveloperSettingsURLStringToType([v6 objectForKeyedSubscript:@"assetLocation"]);
}


void -[AUDeveloperSettingsDatabase updateAccessory:locationType:](id a1, unsigned long a2)
{
    if ([self isValidLocationType:a2]) {
        NSDictionary *accessoriesDictionary = [self accessoriesDictionary];
        id v3 = [accessoriesDictionary objectForKeyedSubscript:a1];
        NSDictionary *v4 = [v3 mutableCopy];
        NSString *v5 = [NSString stringWithUTF8String:AUDeveloperSettingsURLTypeToString(a2)];
        [v4 setObject:v5 forKeyedSubscript:@"assetLocation"];
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            char *v8 = AUDeveloperSettingsURLTypeToString(a2);
            id v9 = [v4 objectForKeyedSubscript:@"name"];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%s: Updating location = %s for accessoryName = %@", "-[AUDeveloperSettingsDatabase updateAccessory:locationType:]", v8, v9);
        }
        NSDictionary *v12 = [NSDictionary dictionaryWithDictionary:v4];
        [self addAccessoryWithSerialNumber:a1 info:v12];
    }
}


void -[AUDeveloperSettingsDatabase addAccessoryWithSerialNumber:info:](id a1, NSDictionary *a2)
{
    if ([a1 length] != 0) {
        NSDictionary *accessoriesDictionary = [self accessoriesDictionary];
        id v5 = [accessoriesDictionary mutableCopy];
        [v5 setObject:a2 forKeyedSubscript:a1];
        [self setAccessoriesDictionary:v5];
    } else {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%s: Not adding empty serial number with info = %@", "-[AUDeveloperSettingsDatabase addAccessoryWithSerialNumber:info:]", a2);
        }
    }
}


void -[AUDeveloperSettingsDatabase removeAccessoryWithSerialNumber:](NSString *a1)
{
    NSDictionary *accessoriesDictionary = [self accessoriesDictionary];
    id v3 = [accessoriesDictionary mutableCopy];
    [v3 removeObjectForKey:a1];
    NSObject<OS_os_log> *oslog = self->_log;
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "Removing accessory from database %@", a1);
    }
    [self setAccessoriesDictionary:v3];
}


void -[AUDeveloperSettingsDatabase updateAccessoryWithSerialNumber:info:](NSString *a1, NSMutableDictionary *a2)
{
    if (![a1 length] || ![a2 count]) {
        NSObject<OS_os_log> *oslog = self->_log;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%s: Invalid key value / pair = %@ / %@", "-[AUDeveloperSettingsDatabase updateAccessoryWithSerialNumber:info:]", a1, a2);
        }
    } else {
        NSObject<OS_os_log> *oslog2 = self->_log;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "Updating database with %@ / %@", a1, a2);
        }
        [NSUserDefaults AUDeveloperSettingsUpdateAccessory:a2 withKey:a1];
    }
}


bool -[AUDeveloperSettingsDatabase isValidLocationType:](unsigned long a1)
{
    return !a1 || a1 == 1 || a1 == 2 || a1 == 4 || a1 == 5 || a1 == 6 || a1 == 3 || a1 == 7 || a1 == 8;
}


void -[AUDeveloperSettingsDatabase accessoryNameForIdentifier:name:serialNumber:fusingType:](id a1, id *a2, id *a3, unsigned long *a4)
{
}


void -[AUDeveloperSettingsDatabase .cxx_destruct](void)
{
    self->_log = nil;
}
