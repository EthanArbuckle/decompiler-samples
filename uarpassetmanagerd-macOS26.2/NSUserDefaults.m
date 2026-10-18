void +[NSUserDefaults(AUHelperExtend) AUDeveloperSettingsSetObject:withKey:](id a1, NSString *a2)
{
    if (278 != getuid()) {
        AUHelperInstance *sharedInstance = [AUHelperInstance sharedInstance];
        id<AUHelperServiceProtocol> remoteObject = [sharedInstance remoteObject];
        [remoteObject userPreferenceSetObject:a1 forSuite:1 withKey:a2];
    } else {
        [[[NSUserDefaults alloc] initWithSuiteName:MapPreferenceSuiteToString(1)] setObject:a1 forKey:a2];
    }
}


void +[NSUserDefaults(AUHelperExtend) AUDeveloperSettingsUpdateAccessory:withKey:](id a1, id a2)
{
    AUHelperInstance *sharedInstance = [AUHelperInstance sharedInstance];
    id<AUHelperServiceProtocol> remoteObject = [sharedInstance remoteObject];
    [remoteObject userPreferenceUpdateAccessorySettings:a1 withKey:a2];
}


id +[NSUserDefaults(AUHelperExtend) AUDeveloperSettingsObjectWithKey:](NSString *a1)
{
    id v10;
    long v1;
    void *v0 = &v1;
    v0->field_8 = self;
    *(v0) = _cmd;
    if (278 != getuid()) {
        AUHelperInstance *sharedInstance = [AUHelperInstance sharedInstance];
        id<AUHelperServiceProtocol> remoteObject = [sharedInstance remoteObject];
        __block id v6 = nil;
        [remoteObject userPreferenceObjectForSuite:1 withKey:a1 withReply:^void(id arg1) {
            v6 = arg1;
        }];
        v10 = v6;
    } else {
        v10 = [[[NSUserDefaults alloc] initWithSuiteName:MapPreferenceSuiteToString(1)] objectForKey:a1];
    }
    return v10;
}
