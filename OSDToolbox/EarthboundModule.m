bool -[EarthboundModule suspendEarthbound](void)
{
    id sharedInstance = [EBDiagstool sharedInstance];
    id v2 = nil;
    long v3 = [sharedInstance suspend:&v2];
    if ((v3 & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Error suspending Earthbound: %@\n", v2];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bbd4(v2, oslog);
        }
    }
    return v3;
}


bool -[EarthboundModule resumeEarthbound](void)
{
    id sharedInstance = [EBDiagstool sharedInstance];
    id v2 = nil;
    long v3 = [sharedInstance resume:&v2];
    if ((v3 & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Error resuming Earthbound: %@\n", v2];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bc28(v2, oslog);
        }
    }
    return v3;
}


bool -[EarthboundModule stopEarthbound](void)
{
    id sharedInstance = [EBDiagstool sharedInstance];
    id v2 = nil;
    long v3 = [sharedInstance stop:&v2];
    if ((v3 & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Error stopping Earthbound: %@\n", v2];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bc7c(v2, oslog);
        }
    }
    return v3;
}


bool -[EarthboundModule setEarthboundStopOnFail:](bool a1)
{
    id sharedInstance = [EBDiagstool sharedInstance];
    id v2 = nil;
    long v3 = [sharedInstance setStopOnFail:a1 error:&v2];
    if ((v3 & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Error setting stop on fail Earthbound: %@\n", v2];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bcd0(v2, oslog);
        }
    }
    return v3;
}


bool -[EarthboundModule unclampEarthbound](void)
{
    id sharedInstance = [EBDiagstool sharedInstance];
    id v2 = nil;
    long v3 = [sharedInstance unclamp:&v2];
    if ((v3 & 1) == 0) {
        NSString *v5 = [NSString stringWithFormat:@"[ERROR] Error unclamping Earthbound: %@\n", v2];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bd24(v2, oslog);
        }
    }
    return v3;
}


bool -[EarthboundModule displayImageEarthbound:](id a1)
{
    NSString *v2 = [NSString stringWithFormat:@"Setting Ness to use image %@", a1];
    fprintf(stderr, "%s\n", [v2 UTF8String]);
    os_log_t oslog2 = osd_shared_log_handle(v2);
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Setting Ness to use image %@", a1);
    }
    id sharedInstance = [EBDiagstool sharedInstance];
    id v6 = nil;
    long v7 = [sharedInstance overrideUIWithImage:a1 error:&v6];
    if ((v7 & 1) == 0) {
        NSString *v9 = [NSString stringWithFormat:@"[ERROR] Error displaying image: %@", v6];
        fprintf(stderr, "%s\n", [v9 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v9);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bd78(v6, oslog);
        }
    }
    return v7;
}


bool -[EarthboundModule displayRGBEarthbound:](id a1)
{
    id v0 = a1;
    NSArray<NSString *> *v1 = [a1 componentsSeparatedByString:@","];
    if ([v1 count] != 3) {
        v0 = nil;
    }
    NSString *v3 = [NSString stringWithFormat:@"Setting Ness to use RGB %@", v0];
    fprintf(stderr, "%s\n", [v3 UTF8String]);
    os_log_t oslog2 = osd_shared_log_handle(v3);
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Setting Ness to use RGB %@", v0);
    }
    id sharedInstance = [EBDiagstool sharedInstance];
    id v7 = nil;
    long v8 = [sharedInstance overrideUIWithRGB:v0 error:&v7];
    if ((v8 & 1) == 0) {
        NSString *v10 = [NSString stringWithFormat:@"[ERROR] Error displaying rgb: %@", v7];
        fprintf(stderr, "%s\n", [v10 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v10);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000bdcc(v7, oslog);
        }
    }
    return v8;
}


void -[EarthboundModule removeFileAtPath:error:](NSString *a1, NSError **a2)
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager fileExistsAtPath:a1]) {
        NSString *v3 = [NSString stringWithFormat:@"Removing files at path: %@", a1];
        fprintf(stderr, "%s\n", [v3 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v3);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Removing files at path: %@", a1);
        }
        [defaultManager removeItemAtPath:a1 error:a2];
    }
}


bool -[EarthboundModule resetEarthbound:](bool a1)
{
    OSDEFIBootArgParser *v12;
    NSString *v16;
    int v30;
    NSError *v32;
    glob_t v52;
    @autoreleasepool {
        NSString *v2 = [NSString stringWithFormat:@"Stopping Earthbound"];
        fprintf(stderr, "%s\n", [v2 UTF8String]);
        os_log_t oslog3 = osd_shared_log_handle(v2);
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Stopping Earthbound");
        }
        [self stopEarthbound];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        id sharedInstance = [OSDDeviceModelInfo sharedInstance];
        NSString *name = [sharedInstance name];
        NSString *v8 = [kEarthboundDefaultSequenceName stringByAppendingPathExtension:@"sqlite"];
        NSString *v11 = [[[OSDBootArgs alloc] init] bootArgWithName:@"burnin"];
        if (v11) {
            v12 = [[OSDEFIBootArgParser alloc] initWithString:v11];
        } else {
            v12 = nil;
        }
        NSArray *values = [v12 values];
        if (![values count]) {
            v16 = v8;
        } else {
            NSArray *values2 = [v12 values];
            id firstObject = [values2 firstObject];
            v16 = [NSString stringWithFormat:@"%@.sqlite", firstObject];
        }
        id v20 = kEarthboundDefaultDBDirectory;
        NSString *v22 = [v20 stringByAppendingPathComponent:v16];
        NSString *v23 = [v20 stringByAppendingPathComponent:name];
        NSString *v24 = [v23 stringByAppendingPathComponent:v16];
        NSString *v25 = [v24 stringByAppendingPathExtension:@"backup"];
        NSString *v26 = [v22 stringByAppendingString:@"-wal"];
        NSString *v27 = [v22 stringByAppendingString:@"-shm"];
        NSString *v28 = [NSString stringWithFormat:@"Unloading Earthbound"];
        fprintf(stderr, "%s\n", [v28 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(v28);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Unloading Earthbound");
        }
        v30 = [OSDLaunch unload:@"/AppleInternal/Diags/Earthbound/com.apple.osdiags.Earthbound.plist"];
        if ((v30 & 1) == 0) {
            NSString *v31 = [NSString stringWithFormat:@"[ERROR] Error unloading Earthbound"];
            fprintf(stderr, "%s\n", [v31 UTF8String]);
            os_log_t oslog = osd_shared_log_handle(v31);
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                sub_10000be54(oslog);
            }
        }
        if (!a1) {
            v32 = nil;
        } else if (![defaultManager fileExistsAtPath:v25]) {
            v32 = nil;
        } else {
            NSError *error = nil;
            [defaultManager removeItemAtPath:v24 error:&error];
            NSError *v35 = error;
            [defaultManager copyItemAtPath:v25 toPath:v24 error:&v35];
            v32 = v35;
        }
        NSString *v21 = [@"/private/var/mobile/Media/FactoryLogs/LogCollector/Earthbound/" stringByAppendingPathComponent:@".FactoryLogsWaitingToBeCollected"];
        NSArray<NSString *> *v37 = @[v22, v26, v27, v21];
        NSMutableArray<NSString *> *v38 = [NSMutableArray arrayWithArray:v37];
        if (a1) {
            NSSet *v43 = [NSSet setWithObjects:kEarthboundDefaultStagingLogsPath, @"/private/var/mobile/Media/FactoryLogs/LogCollector/Earthbound*", kEarthboundDefaultWorkingDirectory, @"/AppleInternal/Diags/Logs/Bonfire/NAND.log", @"/AppleInternal/Diags/Logs/Bonfire/result.txt", @"/AppleInternal/Diags/Logs/Smokey/*/Smokey.log", @"/AppleInternal/Diags/Logs/Smokey/*/Earthbound.sig", @"/AppleInternal/Diags/Logs/Smokey/*/PDCA.plist", nil];
            NSMutableOrderedSet *v44 = [NSMutableOrderedSet new];
            for (NSString *v1 in v43) {
                const char *UTF8String = [v1 UTF8String];
                int v51 = glob(UTF8String, 2184, NULL, &v52);
                if (!v51 && v52.field_8 >= 1) {
                    long v53 = 0;
                    do {
                        NSString *v54 = [NSString stringWithUTF8String:v52.field_32[v53]];
                        [v44 addObject:v54];
                        v53++;
                    } while (v53 < v52.field_8);
                }
                globfree(&v52);
            }
            id v55 = [v44 copy];
            NSArray<NSString *> *array = [v55 array];
            [v38 addObjectsFromArray:array];
        }
        for (NSString *v9 in v38) {
            NSError *v62 = v32;
            NSError *v63 = v62;
            [self removeFileAtPath:v9 error:&v63];
            v32 = v63;
        }
        if (a1) {
            [defaultManager createDirectoryAtPath:kEarthboundDefaultWorkingDirectory withIntermediateDirectories:YES attributes:nil error:&v32];
        }
        if (!v32) {
            long v67 = [[[OSDBootArgs alloc] init] hasBootArg:@"burnin"];
            FILE *v68 = stderr;
            if (!v67) {
                NSString *v70 = [NSString stringWithFormat:@"Not loading Earthbound because there is no burnin bootarg!"];
                fprintf(v68, "%s\n", [v70 UTF8String]);
                os_log_t oslog4 = osd_shared_log_handle(v70);
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Not loading Earthbound because there is no burnin bootarg!");
                }
            } else {
                NSString *v72 = [NSString stringWithFormat:@"Loading Earthbound"];
                fprintf(v68, "%s\n", [v72 UTF8String]);
                os_log_t oslog5 = osd_shared_log_handle(v72);
                if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "Loading Earthbound");
                }
                v30 = [OSDLaunch load:@"/AppleInternal/Diags/Earthbound/com.apple.osdiags.Earthbound.plist"];
            }
        } else {
            NSString *v74 = [NSString stringWithFormat:@"[ERROR] Erroring deleting Sequences\n"];
            fprintf(stderr, "%s\n", [v74 UTF8String]);
            os_log_t oslog6 = osd_shared_log_handle(v74);
            if (os_log_type_enabled(oslog6, OS_LOG_TYPE_ERROR)) {
                sub_10000be20(oslog6);
            }
            v30 = 0;
        }
    }
    return v30;
}


void -[EarthboundModule toggleEarthboundBootArg](void)
{
    OSDBootArgs *v2 = [[OSDBootArgs alloc] init];
    if (([v2 hasBootArg:@"burnin"] & 1) == 0) {
        [v2 addBootArg:@"burnin"];
    } else {
        [v2 removeBootArg:@"burnin"];
    }
    id bootArgsString = [v2 bootArgsString];
    NSString *v4 = [NSString stringWithFormat:@"Bootargs: %@", bootArgsString];
    fprintf(stderr, "%s\n", [v4 UTF8String]);
    os_log_t oslog = osd_shared_log_handle(bootArgsString);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        id bootArgsString2 = [v2 bootArgsString];
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Bootargs: %@", bootArgsString2);
    }
}


void -[EarthboundModule setEarthboundSequence:](id a1)
{
    OSDBootArgs *v2 = [[OSDBootArgs alloc] init];
    NSString *v3 = [NSString stringWithFormat:@"burnin=%@", a1];
    [v2 addBootArg:v3];
}


void +[EarthboundModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[EarthboundModule moduleName](void)
{
    return @"earthbound";
}


NSString *-[EarthboundModule moduleOverview](void)
{
    return @"Earthbound control commands. This program cannot be run in DOS mode";
}


void -[EarthboundModule addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"reset" shortOption:114 argumentType:0 defaultValue:0 description:@"Resets Earthbound's run state, keeping sequence modifications done by OSDToolbox."];
    FTOptions *options2 = [self options];
    [options2 addOption:@"fullreset" shortOption:102 argumentType:0 defaultValue:0 description:@"Resets Earthbound's run state and clears any sequence modifications done by OSDToolbox."];
    FTOptions *options4 = [self options];
    [options4 addOption:@"stop" shortOption:115 argumentType:0 defaultValue:0 description:@"Stop Earthbound."];
    FTOptions *options5 = [self options];
    [options5 addOption:@"suspend" shortOption:112 argumentType:0 defaultValue:0 description:@"Suspends Earthbound."];
    FTOptions *options6 = [self options];
    [options6 addOption:@"resume" shortOption:122 argumentType:0 defaultValue:0 description:@"Resume Earthbound."];
    FTOptions *options7 = [self options];
    [options7 addOption:@"setstoponfail" shortOption:111 argumentType:1 defaultValue:0 description:@"Set stop-on-fail behavior: argument of 1 sets it, 0 disables it"];
    FTOptions *options8 = [self options];
    [options8 addOption:@"unclamp" shortOption:117 argumentType:0 defaultValue:0 description:@"Unclamp Earthbound clamp screen"];
    FTOptions *options9 = [self options];
    [options9 addOption:@"bootarg" shortOption:98 argumentType:0 defaultValue:0 description:@"Toggles the Earthbound bootarg"];
    FTOptions *options10 = [self options];
    [options10 addOption:@"setsequence" shortOption:113 argumentType:1 defaultValue:0 description:@"Set earthbound to run the specified test sequence."];
    FTOptions *options11 = [self options];
    [options11 addOption:@"displayimage" shortOption:105 argumentType:1 defaultValue:0 description:@"Pass path for Ness to display the image during a supported sequence. Pass NO to disable"];
    FTOptions *options3 = [self options];
    [options3 addOption:@"displayrgb" shortOption:103 argumentType:1 defaultValue:0 description:@"RGB value to display in Earthbound in format red,green,blue"];
}


int -[EarthboundModule moduleMain](void)
{
    SEL v39;
    id v25;
    bool v23;
    FTOptions *options = [self options];
    if (![options objectForKeyedSubscript:@"reset"]) {
        FTOptions *options9 = [self options];
        if (![options9 objectForKeyedSubscript:@"fullreset"]) {
            FTOptions *options11 = [self options];
            id v6 = [options11 objectForKeyedSubscript:@"stop"];
            if (v6 != nil) {
                NSString *v49 = [NSString stringWithFormat:@"Stopping Earthbound"];
                fprintf(stderr, "%s\n", [v49 UTF8String]);
                os_log_t oslog9 = osd_shared_log_handle(v49);
                if (os_log_type_enabled(oslog9, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog9, OS_LOG_TYPE_DEFAULT, "Stopping Earthbound");
                }
                v39 = @selector(stopEarthbound);
                goto blk_100006244;
            }
            FTOptions *options12 = [self options];
            id v8 = [options12 objectForKeyedSubscript:@"suspend"];
            if (v8 != nil) {
                NSString *v47 = [NSString stringWithFormat:@"Suspending Earthbound"];
                fprintf(stderr, "%s\n", [v47 UTF8String]);
                os_log_t oslog8 = osd_shared_log_handle(v47);
                if (os_log_type_enabled(oslog8, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog8, OS_LOG_TYPE_DEFAULT, "Suspending Earthbound");
                }
                v39 = @selector(suspendEarthbound);
                goto blk_100006244;
            }
            FTOptions *options13 = [self options];
            id v10 = [options13 objectForKeyedSubscript:@"resume"];
            if (v10 != nil) {
                NSString *v45 = [NSString stringWithFormat:@"Resuming Earthbound"];
                fprintf(stderr, "%s\n", [v45 UTF8String]);
                os_log_t oslog7 = osd_shared_log_handle(v45);
                if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "Resuming Earthbound");
                }
                v39 = @selector(resumeEarthbound);
                goto blk_100006244;
            }
            FTOptions *options2 = [self options];
            if (![options2 objectForKeyedSubscript:@"setstoponfail"]) {
                FTOptions *options3 = [self options];
                if (![options3 objectForKeyedSubscript:@"unclamp"]) {
                    FTOptions *options4 = [self options];
                    id v16 = [options4 objectForKeyedSubscript:@"bootarg"];
                    if (v16 != nil) {
                        NSString *v35 = [NSString stringWithFormat:@"Setting Earthbound bootarg"];
                        fprintf(stderr, "%s\n", [v35 UTF8String]);
                        os_log_t oslog4 = osd_shared_log_handle(v35);
                        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Setting Earthbound bootarg");
                        }
                        [self toggleEarthboundBootArg];
                        return 0;
                    }
                    FTOptions *options5 = [self options];
                    id v18 = [options5 objectForKeyedSubscript:@"setsequence"];
                    FTOptions *options6 = [self options];
                    if (!v18) {
                        id v20 = [options6 objectForKeyedSubscript:@"displayimage"];
                        FTOptions *options7 = [self options];
                        if (!v20) {
                            if (![options7 objectForKeyedSubscript:@"displayrgb"]) {
                                return 1;
                            }
                            FTOptions *options8 = [self options];
                            v25 = [options8 objectForKeyedSubscript:@"displayrgb"];
                            NSString *v26 = [NSString stringWithFormat:@"Setting RGB Value: %@", v25];
                            fprintf(stderr, "%s\n", [v26 UTF8String]);
                            os_log_t oslog = osd_shared_log_handle(v26);
                            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Setting RGB Value: %@", v25);
                            }
                            v23 = [self displayRGBEarthbound:v25];
                        } else {
                            v25 = [options7 objectForKeyedSubscript:@"displayimage"];
                            NSString *v30 = [NSString stringWithFormat:@"Setting image to %@", v25];
                            fprintf(stderr, "%s\n", [v30 UTF8String]);
                            os_log_t oslog2 = osd_shared_log_handle(v30);
                            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Setting image to %@", v25);
                            }
                            v23 = [self displayImageEarthbound:v25];
                        }
                    } else {
                        id v32 = [options6 objectForKeyedSubscript:@"setsequence"];
                        NSString *v33 = [NSString stringWithFormat:@"Setting sequence to %@", v32];
                        fprintf(stderr, "%s\n", [v33 UTF8String]);
                        os_log_t oslog3 = osd_shared_log_handle(v33);
                        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Setting sequence to %@", v32);
                        }
                        [self setEarthboundSequence:v32];
                        v23 = true;
                    }
                } else {
                    NSString *v37 = [NSString stringWithFormat:@"Unclamping!"];
                    fprintf(stderr, "%s\n", [v37 UTF8String]);
                    os_log_t oslog5 = osd_shared_log_handle(v37);
                    if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
                        os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "Unclamping!");
                    }
                    v39 = @selector(unclampEarthbound);
blk_100006244:
                    v23 = objc_msgSend(self, v39);
                }
            } else {
                NSString *v40 = [NSString stringWithFormat:@"Setting stop on fail"];
                fprintf(stderr, "%s\n", [v40 UTF8String]);
                os_log_t oslog6 = osd_shared_log_handle(v40);
                if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "Setting stop on fail");
                }
                FTOptions *options10 = [self options];
                id v43 = [options10 objectForKeyedSubscript:@"setstoponfail"];
                BOOL boolValue = [v43 boolValue];
                v23 = [self setEarthboundStopOnFail:boolValue];
            }
        } else {
            NSString *v51 = [NSString stringWithFormat:@"Full resetting Earthbound"];
            fprintf(stderr, "%s\n", [v51 UTF8String]);
            os_log_t oslog10 = osd_shared_log_handle(v51);
            if (os_log_type_enabled(oslog10, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog10, OS_LOG_TYPE_DEFAULT, "Full resetting Earthbound");
            }
            v23 = [self resetEarthbound:YES];
        }
    } else {
        NSString *v53 = [NSString stringWithFormat:@"Resetting Earthbound"];
        fprintf(stderr, "%s\n", [v53 UTF8String]);
        os_log_t oslog11 = osd_shared_log_handle(v53);
        if (os_log_type_enabled(oslog11, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog11, OS_LOG_TYPE_DEFAULT, "Resetting Earthbound");
        }
        v23 = [self resetEarthbound:NO];
    }
    return !v23;
}
