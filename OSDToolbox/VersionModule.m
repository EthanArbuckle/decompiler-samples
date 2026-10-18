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
    int v73;
    BOOL v21;
    int v67;
    BOOL v24;
    int v61;
    BOOL v27;
    int v55;
    BOOL v30;
    int v49;
    BOOL v33;
    int v44;
    BOOL v36;
    BOOL v39;
    BOOL boolValue2;
    id v1 = [OSDDevice sharedInstance];
    id v2 = [OSDVersion sharedInstance];
    NSArray<NSString *> *v6 = @[@"BuildVersion", @"CommonPlatformName", @"RootVersionOSD", @"RootVersionLLD", @"FactoryLLDiagsVersion", @"FactoryLLScriptsPlatformsVersion", @"FactoryLLDiagsExtrasVersion", @"FactoryLLScriptsCommonVersion"];
    int v80 = 1;
    for (NSString *v4 in v6) {
        FTOptions *options8 = [self options];
        id v83 = [options8 valueForKey:v4];
        BOOL boolValue = [v83 boolValue];
        v80 &= !boolValue;
    }
    if ((v80 & 1) == 0) {
        FTOptions *options9 = [self options];
        id v86 = [options9 valueForKey:@"BuildVersion"];
        boolValue2 = [v86 boolValue];
        if (!boolValue2) {
            v10 = v1;
            v11 = v2;
        }
        if (boolValue2) {
            v9 = 0;
        }
    } else {
        v9 = 1;
    }
    if ((v80 & 1) != 0 || boolValue2) {
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
        if (v9) {
            v73 = 1;
            v21 = YES;
        }
    }
    if (((v80 & 1) == 0 && !boolValue2) || (((v80 & 1) != 0 || boolValue2) && !v9)) {
        FTOptions *options = [self options];
        id v20 = [options valueForKey:@"CommonPlatformName"];
        v21 = [v20 boolValue];
        v73 = 0;
    }
    if (v21) {
        id commonPlatformName = [v10 commonPlatformName];
        NSString *v76 = [NSString stringWithFormat:@"%@\t%@", @"CommonPlatformName", commonPlatformName];
        fprintf(stderr, "%s\n", [v76 UTF8String]);
        os_log_t oslog8 = osd_shared_log_handle(commonPlatformName);
        if (os_log_type_enabled(oslog8, OS_LOG_TYPE_DEFAULT)) {
            id commonPlatformName2 = [v10 commonPlatformName];
            os_log_with_type(oslog8, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"CommonPlatformName", commonPlatformName2);
        }
        if (!v73) {
            v11 = v2;
        }
    }
    if (v21 && v73) {
        v67 = 1;
        v24 = YES;
    } else {
        FTOptions *options2 = [self options];
        id v23 = [options2 valueForKey:@"RootVersionOSD"];
        v24 = [v23 boolValue];
        v67 = 0;
        if (v24) {
            v2 = v11;
        }
    }
    if (v24) {
        id rootVersionOSD = [v2 rootVersionOSD];
        NSString *v70 = [NSString stringWithFormat:@"%@\t%@", @"RootVersionOSD", rootVersionOSD];
        fprintf(stderr, "%s\n", [v70 UTF8String]);
        os_log_t oslog7 = osd_shared_log_handle(rootVersionOSD);
        if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
            id rootVersionOSD2 = [v2 rootVersionOSD];
            os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"RootVersionOSD", rootVersionOSD2);
        }
        if (!v67) {
            v11 = v2;
        }
    }
    if (v24 && v67) {
        v61 = 1;
        v27 = YES;
    } else {
        FTOptions *options3 = [self options];
        id v26 = [options3 valueForKey:@"RootVersionLLD"];
        v27 = [v26 boolValue];
        v61 = 0;
        if (v27) {
            v2 = v11;
        }
    }
    if (v27) {
        id rootVersionLLD = [v2 rootVersionLLD];
        NSString *v64 = [NSString stringWithFormat:@"%@\t%@", @"RootVersionLLD", rootVersionLLD];
        fprintf(stderr, "%s\n", [v64 UTF8String]);
        os_log_t oslog6 = osd_shared_log_handle(rootVersionLLD);
        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
            id rootVersionLLD2 = [v2 rootVersionLLD];
            os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"RootVersionLLD", rootVersionLLD2);
        }
        if (!v61) {
            v11 = v2;
            v10 = v1;
        }
    }
    if (v27 && v61) {
        v55 = 1;
        v10 = v1;
        v30 = YES;
    } else {
        FTOptions *options4 = [self options];
        id v29 = [options4 valueForKey:@"FactoryLLDiagsVersion"];
        v30 = [v29 boolValue];
        v55 = 0;
        if (v30) {
            v2 = v11;
        }
    }
    if (v30) {
        id factoryLLDiagsVersion = [v2 factoryLLDiagsVersion];
        NSString *v58 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLDiagsVersion", factoryLLDiagsVersion];
        fprintf(stderr, "%s\n", [v58 UTF8String]);
        os_log_t oslog5 = osd_shared_log_handle(factoryLLDiagsVersion);
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLDiagsVersion2 = [v2 factoryLLDiagsVersion];
            os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLDiagsVersion", factoryLLDiagsVersion2);
        }
        if (!v55) {
            v11 = v2;
        }
    }
    if (v30 && v55) {
        v49 = 1;
        v33 = YES;
    } else {
        FTOptions *options5 = [self options];
        id v32 = [options5 valueForKey:@"FactoryLLScriptsPlatformsVersion"];
        v33 = [v32 boolValue];
        v49 = 0;
        if (v33) {
            v2 = v11;
        }
    }
    if (v33) {
        id factoryLLScriptsPlatformsVersion = [v2 factoryLLScriptsPlatformsVersion];
        NSString *v52 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLScriptsPlatformsVersion", factoryLLScriptsPlatformsVersion];
        fprintf(stderr, "%s\n", [v52 UTF8String]);
        os_log_t oslog4 = osd_shared_log_handle(factoryLLScriptsPlatformsVersion);
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLScriptsPlatformsVersion2 = [v2 factoryLLScriptsPlatformsVersion];
            os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLScriptsPlatformsVersion", factoryLLScriptsPlatformsVersion2);
        }
        if (!v49) {
            v11 = v2;
            v10 = v1;
        }
    }
    if (v33 && v49) {
        v44 = 1;
        v36 = YES;
    } else {
        FTOptions *options6 = [self options];
        id v35 = [options6 valueForKey:@"FactoryLLDiagsExtrasVersion"];
        v36 = [v35 boolValue];
        v44 = 0;
        if (v36) {
            v2 = v11;
            v1 = v10;
        }
    }
    if (v36) {
        id factoryLLDiagsExtrasVersion = [v2 factoryLLDiagsExtrasVersion];
        NSString *v46 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLDiagsExtrasVersion", factoryLLDiagsExtrasVersion];
        fprintf(stderr, "%s\n", [v46 UTF8String]);
        os_log_t oslog3 = osd_shared_log_handle(factoryLLDiagsExtrasVersion);
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLDiagsExtrasVersion2 = [v2 factoryLLDiagsExtrasVersion];
            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLDiagsExtrasVersion", factoryLLDiagsExtrasVersion2);
        }
        if (!v44) {
            v11 = v2;
            v10 = v1;
        }
    }
    if (v36 && v44) {
        v39 = YES;
    } else {
        FTOptions *options7 = [self options];
        id v38 = [options7 valueForKey:@"FactoryLLScriptsCommonVersion"];
        v39 = [v38 boolValue];
        if (v39) {
            v2 = v11;
        }
    }
    if (v39) {
        id factoryLLScriptsCommonVersion = [v2 factoryLLScriptsCommonVersion];
        NSString *v41 = [NSString stringWithFormat:@"%@\t%@", @"FactoryLLScriptsCommonVersion", factoryLLScriptsCommonVersion];
        fprintf(stderr, "%s\n", [v41 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(factoryLLScriptsCommonVersion);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            id factoryLLScriptsCommonVersion2 = [v2 factoryLLScriptsCommonVersion];
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "%@\t%@", @"FactoryLLScriptsCommonVersion", factoryLLScriptsCommonVersion2);
        }
    }
    return 0;
}
