void +[MopedModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[MopedModule moduleName](void)
{
    return @"moped";
}


NSString *-[MopedModule moduleOverview](void)
{
    return @"Can be used to verify MoPED";
}


void -[MopedModule addOptions](void)
{
    FTOptions *options = [self options];
    NSNumber *v1 = [NSNumber numberWithInt:1];
    [options addOption:@"attempts" shortOption:99 argumentType:1 defaultValue:v1 description:@"Number of times to check MoPED. Default is once"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"ignoreSysconfig" shortOption:105 argumentType:0 defaultValue:0 description:@"Pass if MoPED is not present in sysconfig"];
}


bool -[MopedModule moduleMain](void)
{
    NSDictionary *v8;
    os_log_t v41;
    long v15;
    FPMoPED *v2 = [[FPMoPED alloc] init];
    FTOptions *options = [self options];
    id v4 = [options objectForKeyedSubscript:@"attempts"];
    int v5 = [v4 intValue];
    FTOptions *options2 = [self options];
    if (![options2 objectForKeyedSubscript:@"ignoreSysconfig"]) {
        v8 = nil;
    } else {
        NSNumber *v10 = [NSNumber numberWithBool:YES];
        v8 = @{FPMoPEDOptionPassIfMoPEDNotPresentInSysConfig: v10};
    }
    if (v5 < 1) {
        return ~1 & 1;
    }
    long v14 = &v15 | 1;
    int v12 = 1;
    do {
        id v17 = nil;
        long v18 = [v2 verifyMoPEDHashWithOptions:v8 error:&v17];
        id cachedMoPEDHash = [v2 cachedMoPEDHash];
        NSString *description = [cachedMoPEDHash description];
        NSString *uppercaseString = [description uppercaseString];
        NSString *v22 = [NSString stringWithFormat:@"Calculated MoPED hash: %@", uppercaseString];
        fprintf(stderr, "%s\n", [v22 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(cachedMoPEDHash);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id cachedMoPEDHash2 = [v2 cachedMoPEDHash];
            NSString *description2 = [cachedMoPEDHash2 description];
            NSString *uppercaseString2 = [description2 uppercaseString];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Calculated MoPED hash: %@", uppercaseString2);
        }
        id cachedMoPEDHashSwapped = [v2 cachedMoPEDHashSwapped];
        NSString *description3 = [cachedMoPEDHashSwapped description];
        NSString *uppercaseString3 = [description3 uppercaseString];
        NSString *v31 = [NSString stringWithFormat:@"Calculated MoPED hash swapped: %@", uppercaseString3];
        fprintf(stderr, "%s\n", [v31 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(cachedMoPEDHashSwapped);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            id cachedMoPEDHashSwapped2 = [v2 cachedMoPEDHashSwapped];
            NSString *description4 = [cachedMoPEDHashSwapped2 description];
            NSString *uppercaseString4 = [description4 uppercaseString];
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Calculated MoPED hash swapped: %@", uppercaseString4);
        }
        v5--;
        if (v18 != 0) {
            FILE *v38 = stderr;
            if (!v17) {
                NSString *v40 = [NSString stringWithFormat:@"MoPED was a success!"];
                fprintf(v38, "%s\n", [v40 UTF8String]);
                v41 = osd_shared_log_handle(v40);
                if (os_log_type_enabled(v41, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(v41, OS_LOG_TYPE_DEFAULT, "MoPED was a success!");
                }
            } else {
                NSInteger code = [v17 code];
                NSString *localizedDescription = [v17 localizedDescription];
                NSString *v44 = [NSString stringWithFormat:@"MoPED was a success but reported an error.  Code %ld and Syscfg -> %@", code, localizedDescription];
                fprintf(v38, "%s\n", [v44 UTF8String]);
                v41 = osd_shared_log_handle(localizedDescription);
                if (os_log_type_enabled(v41, OS_LOG_TYPE_DEFAULT)) {
                    NSInteger code2 = [v17 code];
                    NSString *localizedDescription2 = [v17 localizedDescription];
                    os_log_with_type(v41, OS_LOG_TYPE_DEFAULT, "MoPED was a success but reported an error.  Code %ld and Syscfg -> %@", code2, localizedDescription2);
                }
            }
            continue;
        }
        NSString *v36 = [NSString stringWithFormat:@"[ERROR] MoPED was a failure"];
        fprintf(stderr, "%s\n", [v36 UTF8String]);
        os_log_t oslog3 = osd_shared_log_handle(v36);
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
            sub_10000c204(&v15, v14, oslog3);
        }
        if (!v17) {
            v12 = 0;
            continue;
        }
        NSInteger code3 = [v17 code];
        NSString *localizedDescription3 = [v17 localizedDescription];
        NSString *v49 = [NSString stringWithFormat:@"[ERROR] Could not verify MoPED hash with code %ld and Syscfg -> %@", code3, localizedDescription3];
        fprintf(stderr, "%s\n", [v49 UTF8String]);
        os_log_t oslog4 = osd_shared_log_handle(localizedDescription3);
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_ERROR)) {
            NSInteger code4 = [v17 code];
            NSString *localizedDescription4 = [v17 localizedDescription];
            os_log_with_type(oslog4, OS_LOG_TYPE_ERROR, "Could not verify MoPED hash with code %ld and Syscfg -> %@", code4, localizedDescription4);
        }
        v12 = 0;
    } while (v5 > 0);
    return ~v12 & 1;
}
