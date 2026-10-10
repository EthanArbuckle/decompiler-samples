struct CRPreferences {
    NSDictionary *_cachedPreferences; // +0x8
};

CRPreferences *+[CRPreferences sharedInstance](void)
{
    if (+[CRPreferences sharedInstance]::onceToken == -1) {
        return +[CRPreferences sharedInstance]::sharedInstance;
    }
    dispatch_once(&+[CRPreferences sharedInstance]::onceToken, ^void(void) {
        +[CRPreferences sharedInstance]::sharedInstance = [[CRPreferences alloc] init];
    });
    return +[CRPreferences sharedInstance]::sharedInstance;
}


CRPreferences *-[CRPreferences init](void)
{
    CRPreferences *v1 = [super init];
    if (!v1) {
        return v1;
    }
    [v1 reloadPreferences];
    return v1;
}


void -[CRPreferences reloadPreferences](void)
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:@"/var/jb/Library/Preferences/com.carplayenable.preferences.plist"]) {
        self->_cachedPreferences = [[NSDictionary alloc] initWithContentsOfFile:@"/var/jb/Library/Preferences/com.carplayenable.preferences.plist"];
    } else {
        self->_cachedPreferences = @{};
    }
}


void -[CRPreferences writePreferences](void)
{
    [self->_cachedPreferences writeToFile:@"/var/jb/Library/Preferences/com.carplayenable.preferences.plist" atomically:NO];
}


void -[CRPreferences updateValue:forPreferenceKey:](id a1, id a2)
{
    NSDictionary *v0 = [self->_cachedPreferences mutableCopy];
    [v0 setObject:a1 forKeyedSubscript:a2];
    self->_cachedPreferences = v0;
    [self writePreferences];
}


id -[CRPreferences excludedApplications](void)
{
    if (!self->_cachedPreferences || ![self->_cachedPreferences valueForKey:@"excludedApps"]) {
        return @[@"com.netflix.Netflix", @"com.hulu.plus", @"com.amazon.aiv.AIVApp"];
    }
    return [self->_cachedPreferences valueForKey:@"excludedApps"];
}


long -[CRPreferences dockAlignment](void)
{
    if (!self->_cachedPreferences || ![self->_cachedPreferences valueForKey:@"dockAlignment"]) {
        return 2;
    }
    id v3 = [self->_cachedPreferences valueForKey:@"dockAlignment"];
    return [v3 intValue];
}


BOOL -[CRPreferences fiveColumnIconLayout](void)
{
    if (!self->_cachedPreferences || ![self->_cachedPreferences valueForKey:@"fiveColumnIconLayout"]) {
        return YES;
    }
    id v3 = [self->_cachedPreferences valueForKey:@"fiveColumnIconLayout"];
    return [v3 boolValue];
}


NSDictionary *-[CRPreferences cachedPreferences](void)
{
    return self->_cachedPreferences;
}


void -[CRPreferences setCachedPreferences:](NSDictionary *a1)
{
    objc_setProperty_nonatomic(self, _cmd, a1, 8);
}
