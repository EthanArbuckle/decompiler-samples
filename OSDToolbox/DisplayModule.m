void +[DisplayModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[DisplayModule moduleName](void)
{
    return @"display";
}


NSString *-[DisplayModule moduleOverview](void)
{
    return @"Commands for interacting with the display in NonUI";
}


void -[DisplayModule addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"power" shortOption:112 argumentType:0 defaultValue:0 description:@"Print current display power state"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"setPower" shortOption:115 argumentType:1 defaultValue:0 description:@"Set display power state. ON=1 and OFF=0"];
    FTOptions *options3 = [self options];
    [options3 addOption:@"watchdogInfo" shortOption:105 argumentType:0 defaultValue:0 description:@"Print display watchdog information"];
    FTOptions *options4 = [self options];
    [options4 addOption:@"watchdogSuspend" shortOption:119 argumentType:0 defaultValue:0 description:@"Suspend the display watchdog"];
    FTOptions *options5 = [self options];
    [options5 addOption:@"ontime" shortOption:111 argumentType:1 defaultValue:0 description:@"Returns the current ontime for a given environment [nonui, efi, all]"];
    FTOptions *options6 = [self options];
    [options6 addOption:@"dumpFactoryData" shortOption:100 argumentType:0 defaultValue:0 description:@"Will dump the FACTORY_DATA if it is available"];
}


int -[DisplayModule moduleMain](void)
{
    id v10;
    os_log_t v24;
    NSString *v17;
    NSString *v18;
    os_log_t v19;
    id v78;
    BOOL v79;
    id v80;
    NSString *v81;
    os_log_t v82;
    id v64;
    int v69;
    id sharedInstance = [OSDNonUIHidd sharedInstance];
    FTOptions *options = [self options];
    id dictionary = [options dictionary];
    if (![dictionary count] || [dictionary count] >= 2) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Please pass one option per call."];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog7 = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog7, OS_LOG_TYPE_ERROR)) {
            sub_10000c04c(oslog7);
        }
        return 2;
    }
    id v9 = [dictionary objectForKeyedSubscript:@"setPower"];
    if (v9 != nil) {
        FTOptions *options2 = [self options];
        id v37 = [options2 objectForKeyedSubscript:@"setPower"];
        BOOL boolValue = [v37 boolValue];
        id v39 = nil;
        long v40 = [sharedInstance requestLCDPowerStateChange:boolValue error:&v39];
        v10 = v39;
        FILE *v41 = stderr;
        if (!v40) {
            NSString *v43 = [NSString stringWithFormat:@"[ERROR] Error setting the display power: %@", v10];
            fprintf(v41, "%s\n", [v43 UTF8String]);
            os_log_t oslog3 = osd_shared_log_handle(v43);
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                sub_10000c1b0(v10, oslog3);
            }
            return 1;
        }
        FTOptions *options3 = [self options];
        id v46 = [options3 objectForKeyedSubscript:@"setPower"];
        BOOL boolValue2 = [v46 boolValue];
        NSString *v49 = (boolValue2) ? @"ON" : @"OFF";
        NSString *v50 = [NSString stringWithFormat:@"Successfully set the display power %@!", v49];
        fprintf(v41, "%s\n", [v50 UTF8String]);
        os_log_t oslog4 = osd_shared_log_handle(options3);
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
            FTOptions *options4 = [self options];
            id v53 = [options4 objectForKeyedSubscript:@"setPower"];
            NSString *v54 = ([v53 boolValue]) ? @"ON" : @"OFF";
            os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Successfully set the display power %@!", v54);
        }
    } else {
        v10 = nil;
    }
    id v11 = [dictionary objectForKeyedSubscript:@"power"];
    if (v11 != nil) {
        id v28 = nil;
        long v29 = [sharedInstance currentLCDPowerState:&v28];
        v10 = v28;
        FILE *v30 = stderr;
        if (!v29) {
            NSString *v32 = [NSString stringWithFormat:@"[ERROR] Error reading the current the display power state: %@", v10];
            fprintf(v30, "%s\n", [v32 UTF8String]);
            v24 = osd_shared_log_handle(v32);
            if (os_log_type_enabled(v24, OS_LOG_TYPE_ERROR)) {
                sub_10000c15c(v10, v24);
            }
            return 1;
        }
        NSString *v33 = (v29 == 2) ? @"ON" : @"OFF";
        NSString *v34 = [NSString stringWithFormat:@"Display is %@", v33];
        fprintf(v30, "%s\n", [v34 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(v34);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Display is %@", v33);
        }
    }
    id v12 = [dictionary objectForKeyedSubscript:@"watchdogInfo"];
    if (v12 != nil) {
        id v20 = nil;
        id v13 = [sharedInstance requestDisplayWatchdogInfo:&v20];
        v10 = v20;
        FILE *v21 = stderr;
        if (!v13) {
            NSString *v23 = [NSString stringWithFormat:@"[ERROR] Error reading the display watchdog info: %@", v10];
            fprintf(v21, "%s\n", [v23 UTF8String]);
            v24 = osd_shared_log_handle(v23);
            if (os_log_type_enabled(v24, OS_LOG_TYPE_ERROR)) {
                sub_10000c108(v10, v24);
            }
            return 1;
        }
        NSString *v25 = [NSString stringWithFormat:@"WatchdogInfo: %@", v13];
        fprintf(v21, "%s\n", [v25 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v25);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "WatchdogInfo: %@", v13);
        }
    }
    if ([dictionary objectForKeyedSubscript:@"watchdogSuspend"]) {
        if (!isatty(0)) {
            v17 = [NSString stringWithFormat:@"[ERROR] This must be launched from a tty (shell) with no redirections! Not suspending the display watchdog!"];
            v18 = v17;
            fprintf(stderr, "%s\n", [v17 UTF8String]);
            v19 = osd_shared_log_handle(v18);
            if (os_log_type_enabled(v19, OS_LOG_TYPE_ERROR)) {
                sub_10000c080(v19);
            }
            return 1;
        } else if (!isatty(1)) {
            v17 = [NSString stringWithFormat:@"[ERROR] This must be launched from a tty (shell) with no redirections! Not suspending the display watchdog!"];
            v18 = v17;
            fprintf(stderr, "%s\n", [v17 UTF8String]);
            v19 = osd_shared_log_handle(v18);
            if (os_log_type_enabled(v19, OS_LOG_TYPE_ERROR)) {
                sub_10000c080(v19);
            }
            return 1;
        }
        if (!isatty(2)) {
            v17 = [NSString stringWithFormat:@"[ERROR] This must be launched from a tty (shell) with no redirections! Not suspending the display watchdog!"];
            v18 = v17;
            fprintf(stderr, "%s\n", [v17 UTF8String]);
            v19 = osd_shared_log_handle(v18);
            if (os_log_type_enabled(v19, OS_LOG_TYPE_ERROR)) {
                sub_10000c080(v19);
            }
            return 1;
        }
        id v55 = nil;
        long v56 = [sharedInstance requestDisplayWatchdogSuspend:1 error:&v55];
        v10 = v55;
        FILE *v57 = stderr;
        if (!v56) {
            NSString *v59 = [NSString stringWithFormat:@"[ERROR] Error suspending the display watchdog: %@", v10];
            fprintf(v57, "%s\n", [v59 UTF8String]);
            v19 = osd_shared_log_handle(v59);
            if (os_log_type_enabled(v19, OS_LOG_TYPE_ERROR)) {
                sub_10000c0b4(v10, v19);
            }
            return 1;
        }
        NSString *v60 = [NSString stringWithFormat:@"Successfully suspended display watchdog. Process will hang here. Press ctrl+c to quit"];
        fprintf(v57, "%s\n", [v60 UTF8String]);
        os_log_t oslog5 = osd_shared_log_handle(v60);
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "Successfully suspended display watchdog. Process will hang here. Press ctrl+c to quit");
        }
        CFRunLoopRun();
    }
    id v16 = [dictionary objectForKeyedSubscript:@"ontime"];
    if (!v16) {
        v78 = [dictionary objectForKeyedSubscript:@"dumpFactoryData"];
        v79 = [v78 boolValue];
        if (v79) {
            id sharedInstance2 = [OSDHiloFactoryDataAccess sharedInstance];
            v80 = [sharedInstance2 copyHiloFactoryData:0];
            v81 = [NSString stringWithFormat:@"FACTORY_DATA: %@", v80];
            fprintf(stdout, "%s\n", [v81 UTF8String]);
            v82 = osd_shared_log_handle(v81);
            if (os_log_type_enabled(v82, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(v82, OS_LOG_TYPE_DEFAULT, "FACTORY_DATA: %@", v80);
            }
        }
        return 0;
    }
    if ([v16 isEqualToString:@"nonui"] || [v16 isEqualToString:@"all"]) {
        id v62 = v10;
        id v63 = [sharedInstance currentNonUIDisplayOnTime:&v62];
        v64 = v62;
        NSString *v65 = [NSString stringWithFormat:@"nonui: %@", v63];
        fprintf(stdout, "%s\n", [v65 UTF8String]);
        os_log_t oslog6 = osd_shared_log_handle(v63);
        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
            id v67 = v64;
            id v68 = [sharedInstance currentNonUIDisplayOnTime:&v67];
            os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "nonui: %@", v68);
            v64 = v67;
        }
        v69 = 1;
    } else {
        v69 = 0;
        v64 = v10;
    }
    BOOL v71 = [v16 isEqualToString:@"efi"];
    if (!v71 && ![v16 isEqualToString:@"all"]) {
        if (!v69) {
            NSString *v83 = [NSString stringWithFormat:@"Invalid environment: %@", v16];
            fprintf(stdout, "%s\n", [v83 UTF8String]);
            os_log_t oslog9 = osd_shared_log_handle(v83);
            if (os_log_type_enabled(oslog9, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog9, OS_LOG_TYPE_DEFAULT, "Invalid environment: %@", v16);
            }
        }
    } else {
        id v72 = v64;
        id v73 = [sharedInstance currentEFIDisplayOnTime:&v72];
        v10 = v72;
        NSString *v74 = [NSString stringWithFormat:@"efi: %@", v73];
        fprintf(stdout, "%s\n", [v74 UTF8String]);
        os_log_t oslog8 = osd_shared_log_handle(v73);
        if (os_log_type_enabled(oslog8, OS_LOG_TYPE_DEFAULT)) {
            id v76 = v10;
            id v77 = [sharedInstance currentEFIDisplayOnTime:&v76];
            os_log_with_type(oslog8, OS_LOG_TYPE_DEFAULT, "efi: %@", v77);
        }
    }
    v78 = [dictionary objectForKeyedSubscript:@"dumpFactoryData"];
    v79 = [v78 boolValue];
    if (v79) {
        id sharedInstance3 = [OSDHiloFactoryDataAccess sharedInstance];
        v80 = [sharedInstance3 copyHiloFactoryData:0];
        v81 = [NSString stringWithFormat:@"FACTORY_DATA: %@", v80];
        fprintf(stdout, "%s\n", [v81 UTF8String]);
        v82 = osd_shared_log_handle(v81);
        if (os_log_type_enabled(v82, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(v82, OS_LOG_TYPE_DEFAULT, "FACTORY_DATA: %@", v80);
        }
    }
    return 0;
}
