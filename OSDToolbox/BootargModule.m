void +[BootargModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[BootargModule moduleName](void)
{
    return @"bootargs";
}


NSString *-[BootargModule moduleOverview](void)
{
    return @"Use this module to modify the bootargs";
}


void -[BootargModule addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"add" shortOption:97 argumentType:1 defaultValue:0 description:@"add boot-arg"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"remove" shortOption:114 argumentType:1 defaultValue:0 description:@"remove boot-arg"];
}


int -[BootargModule moduleMain](void)
{
    FTOptions *options = [self options];
    id v2 = [options valueForKey:@"remove"];
    FTOptions *options2 = [self options];
    id v4 = [options2 valueForKey:@"add"];
    OSDBootArgs *v5 = [OSDBootArgs new];
    if (v2 != nil) {
        [v5 removeBootArg:v2];
    }
    if (v4 != nil) {
        NSRange v6 = [v4 rangeOfString:@"="];
        NSString *v8 = v4;
        if (v6.location != NSNotFound) {
            v8 = [v4 substringToIndex:v6.location];
        }
        if ([v5 hasBootArg:v8] != 0) {
            [v5 removeBootArg:v8];
        }
        [v5 addBootArg:v4];
    }
    id bootArgsString2 = [v5 bootArgsString];
    NSString *v10 = [NSString stringWithFormat:@"boot-args=\"%@\"\n", bootArgsString2];
    fprintf(stderr, "%s\n", [v10 UTF8String]);
    os_log_t oslog = osd_shared_log_handle(bootArgsString2);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id bootArgsString = [v5 bootArgsString];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "boot-args=\"%@\"\n", bootArgsString);
    }
    return 0;
}
