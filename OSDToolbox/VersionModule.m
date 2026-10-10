void +[VersionModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[VersionModule moduleName](void)
{
    return @"version";
}


NSString *-[VersionModule moduleOverview](void)
{
    return @"Retrieves version and config information from the device.";
}


void -[VersionModule addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"BuildVersion" shortOption:98 argumentType:0 defaultValue:0 description:@"BuildVersion"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"CommonPlatformName" shortOption:99 argumentType:0 defaultValue:0 description:@"CommonPlatformName"];
    FTOptions *options3 = [self options];
    [options3 addOption:@"RootVersionOSD" shortOption:111 argumentType:0 defaultValue:0 description:@"RootVersionOSD"];
    FTOptions *options4 = [self options];
    [options4 addOption:@"RootVersionLLD" shortOption:108 argumentType:0 defaultValue:0 description:@"RootVersionLLD"];
    FTOptions *options5 = [self options];
    [options5 addOption:@"FactoryLLDiagsVersion" shortOption:102 argumentType:0 defaultValue:0 description:@"FactoryLLDiagsVersion"];
    FTOptions *options6 = [self options];
    [options6 addOption:@"FactoryLLScriptsPlatformsVersion" shortOption:112 argumentType:0 defaultValue:0 description:@"FactoryLLScriptsPlatformsVersion"];
    FTOptions *options7 = [self options];
    [options7 addOption:@"FactoryLLDiagsExtrasVersion" shortOption:101 argumentType:0 defaultValue:0 description:@"FactoryLLDiagsExtrasVersion"];
    FTOptions *options8 = [self options];
    [options8 addOption:@"FactoryLLScriptsCommonVersion" shortOption:115 argumentType:0 defaultValue:0 description:@"FactoryLLScriptsCommonVersion"];
}


int -[VersionModule moduleMain](void)
{
    id v10;
    id v11;
    int v9;
    int v22;
    int v58;
    int v31;
    int v40;
    int v49;
    int v67;
    long continuationRoute7 = 0;
    id v1 = [OSDDevice sharedInstance];
    id v2 = [OSDVersion sharedInstance];
    NSArray<NSString *> *v6 = @[@"BuildVersion", @"CommonPlatformName", @"RootVersionOSD", @"RootVersionLLD", @"FactoryLLDiagsVersion", @"FactoryLLScriptsPlatformsVersion", @"FactoryLLDiagsExtrasVersion", @"FactoryLLScriptsCommonVersion"];
    int v73 = 1;
    for (NSString *v4 in v6) {
        FTOptions *options7 = [self options];
        id v76 = [options7 valueForKey:v4];
        BOOL boolValue = [v76 boolValue];
        v73 &= !boolValue;
    }
    if ((v73 & 1) == 0) {
        FTOptions *options8 = [self options];
        id v79 = [options8 valueForKey:@"BuildVersion"];
        if (![v79 boolValue]) {
            v10 = v1;
            v11 = v2;
            goto blk_100003304;
        }
        v9 = 0;
    } else {
        v9 = 1;
    }
    v10 = v1;
    v11 = v2;
    id buildVersion = [v10 buildVersion];
    NSString *v14 = [NSString stringWithFormat:@"%@\t%@", @"BuildVersion", buildVersion];
    fprintf(stderr, "%s\n", [v14 UTF8String]);
    os_log_t oslog = osd_shared_log_handle(buildVersion);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id buildVersion2 = [v10 buildVersion];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"BuildVersion", buildVersion2);
    }
    if (!v9) {
blk_100003304:
        FTOptions *options = [self options];
        id v20 = [options valueForKey:@"CommonPlatformName"];
        if (![v20 boolValue]) {
            goto blk_1000034b4;
        }
        v22 = 0;
        goto blk_10000336c;
blk_100003a1c:
        v58 = 0;
        v2 = v11;
    } else {
        v22 = 1;
blk_10000336c:
        id commonPlatformName = [v10 commonPlatformName];
        NSString *v25 = [NSString stringWithFormat:@"%@\t%@", @"CommonPlatformName", commonPlatformName];
        fprintf(stderr, "%s\n", [v25 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(commonPlatformName);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            id commonPlatformName2 = [v10 commonPlatformName];
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"CommonPlatformName", commonPlatformName2);
        }
        if (!v22) {
            v11 = v2;
blk_1000034b4:
            FTOptions *options2 = [self options];
            id v29 = [options2 valueForKey:@"RootVersionOSD"];
            if (![v29 boolValue]) {
                goto blk_100003660;
            }
            v31 = 0;
            v2 = v11;
        } else {
            v31 = 1;
        }
        id rootVersionOSD = [v2 rootVersionOSD];
        NSString *v34 = [NSString stringWithFormat:@"%@\t%@", @"RootVersionOSD", rootVersionOSD];
        fprintf(stderr, "%s\n", [v34 UTF8String]);
        os_log_t oslog3 = osd_shared_log_handle(rootVersionOSD);
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
            id rootVersionOSD2 = [v2 rootVersionOSD];
            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"RootVersionOSD", rootVersionOSD2);
        }
        if (!v31) {
            v11 = v2;
blk_100003660:
            FTOptions *options3 = [self options];
            id v38 = [options3 valueForKey:@"RootVersionLLD"];
            if (![v38 boolValue]) {
                goto blk_10000381c;
            }
            v40 = 0;
            v2 = v11;
        } else {
            v40 = 1;
        }
        id rootVersionLLD = [v2 rootVersionLLD];
        NSString *v43 = [NSString stringWithFormat:@"%@\t%@", @"RootVersionLLD", rootVersionLLD];
        fprintf(stderr, "%s\n", [v43 UTF8String]);
        os_log_t oslog4 = osd_shared_log_handle(rootVersionLLD);
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
            id rootVersionLLD2 = [v2 rootVersionLLD];
            os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"RootVersionLLD", rootVersionLLD2);
        }
        if (!v40) {
            v11 = v2;
            v10 = v1;
blk_10000381c:
            FTOptions *options4 = [self options];
            id v47 = [options4 valueForKey:@"FactoryLLDiagsVersion"];
            if (![v47 boolValue]) {
                goto blk_1000039c8;
            }
            v49 = 0;
            v2 = v11;
        } else {
            v49 = 1;
            v10 = v1;
        }
        id factoryLLDiagsVersion = [v2 factoryLLDiagsVersion];
        NSString *v52 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLDiagsVersion", factoryLLDiagsVersion];
        fprintf(stderr, "%s\n", [v52 UTF8String]);
        os_log_t oslog5 = osd_shared_log_handle(factoryLLDiagsVersion);
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLDiagsVersion2 = [v2 factoryLLDiagsVersion];
            os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLDiagsVersion", factoryLLDiagsVersion2);
        }
        if (!v49) {
            v11 = v2;
blk_1000039c8:
            FTOptions *options5 = [self options];
            id v56 = [options5 valueForKey:@"FactoryLLScriptsPlatformsVersion"];
            if (![v56 boolValue]) {
                goto blk_100003b84;
            }
            goto blk_100003a1c;
        }
        v58 = 1;
    }
    id factoryLLScriptsPlatformsVersion = [v2 factoryLLScriptsPlatformsVersion];
    NSString *v61 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLScriptsPlatformsVersion", factoryLLScriptsPlatformsVersion];
    fprintf(stderr, "%s\n", [v61 UTF8String]);
    os_log_t oslog6 = osd_shared_log_handle(factoryLLScriptsPlatformsVersion);
    if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
        id factoryLLScriptsPlatformsVersion2 = [v2 factoryLLScriptsPlatformsVersion];
        os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLScriptsPlatformsVersion", factoryLLScriptsPlatformsVersion2);
    }
    if (!v58) {
        v11 = v2;
        v10 = v1;
blk_100003b84:
        FTOptions *options6 = [self options];
        id v65 = [options6 valueForKey:@"FactoryLLDiagsExtrasVersion"];
        if (![v65 boolValue]) {
            goto blk_100003d10;
        }
        v67 = 0;
        v2 = v11;
        v1 = v10;
    } else {
        v67 = 1;
    }
    id factoryLLDiagsExtrasVersion = [v2 factoryLLDiagsExtrasVersion];
    NSString *v69 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLDiagsExtrasVersion", factoryLLDiagsExtrasVersion];
    fprintf(stderr, "%s\n", [v69 UTF8String]);
    os_log_t oslog7 = osd_shared_log_handle(factoryLLDiagsExtrasVersion);
    if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
        id factoryLLDiagsExtrasVersion2 = [v2 factoryLLDiagsExtrasVersion];
        os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLDiagsExtrasVersion", factoryLLDiagsExtrasVersion2);
    }
    if (v67) {
        continuationRoute7 = 1;
    }
    if (!continuationRoute7) {
        v11 = v2;
        v10 = v1;
blk_100003d10:
        FTOptions *options9 = [self options];
        id v82 = [options9 valueForKey:@"FactoryLLScriptsCommonVersion"];
        if ([v82 boolValue]) {
            v2 = v11;
            continuationRoute7 = 1;
        }
    }
    if (continuationRoute7) {
        id factoryLLScriptsCommonVersion = [v2 factoryLLScriptsCommonVersion];
        NSString *v85 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLScriptsCommonVersion", factoryLLScriptsCommonVersion];
        fprintf(stderr, "%s\n", [v85 UTF8String]);
        os_log_t oslog8 = osd_shared_log_handle(factoryLLScriptsCommonVersion);
        if (os_log_type_enabled(oslog8, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLScriptsCommonVersion2 = [v2 factoryLLScriptsCommonVersion];
            os_log_with_type(oslog8, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLScriptsCommonVersion", factoryLLScriptsCommonVersion2);
        }
    }
    return 0;
}
