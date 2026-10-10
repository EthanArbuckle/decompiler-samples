FBPreferences *+[FBPreferences sharedInstance](void)
{
    dispatch_once(&sharedInstance.__once, ^void(void) {
        sharedInstance.__prefs = [[FBPreferences alloc] _init];
    });
    return sharedInstance.__prefs;
}


FBPreferences *-[FBPreferences _init](void)
{
    return [super _initWithDomain:@"com.apple.frontboard"];
}


void -[FBPreferences _bindAndRegisterDefaults](void)
{
    NSString *v0 = [NSString stringWithUTF8String:"disableXPCServicesEndpointHack"];
    [self _bindProperty:v0 withDefaultKey:@"disableXPCServicesEndpointHack" toDefaultValue:@NO options:1];
}
