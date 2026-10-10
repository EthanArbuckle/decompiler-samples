void +[FactoryDataRecovery load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[FactoryDataRecovery moduleName](void)
{
    return @"FDR";
}


NSString *-[FactoryDataRecovery moduleOverview](void)
{
    return @"Interacts with the FDR library";
}


void -[FactoryDataRecovery addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"key" shortOption:107 argumentType:1 defaultValue:0 description:@"Key to be looked up"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"moduleSN" shortOption:0 argumentType:1 defaultValue:0 description:@"ModuleSN of key to be looked up. Required for AMFDRDataCopy"];
    FTOptions *options3 = [self options];
    [options3 addOption:@"AMFDROptionStripImg4" shortOption:0 argumentType:1 defaultValue:0 description:@"Set kAMFDROptionStripImg4 in the options dict"];
    FTOptions *options4 = [self options];
    [options4 addOption:@"AMFDROptionVerifyData" shortOption:0 argumentType:1 defaultValue:0 description:@"Set kAMFDROptionVerifyData in the options dict"];
    FTOptions *options5 = [self options];
    [options5 addOption:@"AMFDRDataCopy" shortOption:0 argumentType:0 defaultValue:0 description:@"Use AMFDRDataCopy"];
    FTOptions *options6 = [self options];
    [options6 addOption:@"AMFDRSealingMapCopyLocalDataForClass" shortOption:0 argumentType:0 defaultValue:0 description:@"Use AMFDRSealingMapCopyLocalDataForClass"];
    FTOptions *options7 = [self options];
    [options7 addOption:@"outputPath" shortOption:0 argumentType:1 defaultValue:0 description:@"Output to file, if applicable"];
}


int -[FactoryDataRecovery moduleMain](void)
{
    int v20;
    CFTypeRef v1 = 0;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    FTOptions *options5 = [self options];
    id v4 = [options5 objectForKeyedSubscript:@"AMFDROptionStripImg4"];
    if ([v4 boolValue]) {
        FTOptions *options11 = [self options];
        id v7 = [options11 objectForKeyedSubscript:@"AMFDROptionStripImg4"];
        BOOL boolValue2 = [v7 boolValue];
        NSNumber *obj2 = [NSNumber numberWithBool:boolValue2];
        [dictionary setObject:obj2 forKeyedSubscript:@"StripImg4"];
    }
    FTOptions *options = [self options];
    id v11 = [options objectForKeyedSubscript:@"AMFDROptionVerifyData"];
    if ([v11 boolValue]) {
        FTOptions *options2 = [self options];
        id v14 = [options2 objectForKeyedSubscript:@"AMFDROptionVerifyData"];
        BOOL boolValue = [v14 boolValue];
        NSNumber *obj = [NSNumber numberWithBool:boolValue];
        [dictionary setObject:obj forKeyedSubscript:@"VerifyData"];
    }
    FTOptions *options3 = [self options];
    id v18 = [options3 objectForKeyedSubscript:@"AMFDRSealingMapCopyLocalDataForClass"];
    if (![v18 boolValue]) {
        v20 = 0;
    } else {
        FTOptions *options4 = [self options];
        id v22 = [options4 objectForKeyedSubscript:@"key"];
        CFTypeRef cf = AMFDRSealingMapCopyLocalDataForClass(v22, dictionary, &v1);
        FILE *v24 = stderr;
        if (!cf) {
            NSString *v26 = [NSString stringWithFormat:@"[ERROR] AMFDRSealingMapCopyLocalDataForClass error: %@", v1];
            fprintf(v24, "%s\n", [v26 UTF8String]);
            os_log_t oslog = osd_shared_log_handle(v26);
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                sub_10000c298(&v1, oslog);
            }
            if (v1 != 0) {
                CFRelease(v1);
                v1 = 0;
            }
            v20 = 1;
        } else {
            NSString *v28 = [NSString stringWithFormat:@"Data: %@", cf];
            fprintf(v24, "%s\n", [v28 UTF8String]);
            os_log_t oslog2 = osd_shared_log_handle(v28);
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Data: %@", cf);
            }
            FTOptions *options6 = [self options];
            NSString *v32 = [options6 objectForKeyedSubscript:@"outputPath"];
            if (v32) {
                v20 = ([self writeDataToFile:v32 data:cf]) ? 0 : 2;
            } else {
                v20 = 0;
            }
            CFRelease(cf);
        }
    }
    FTOptions *options7 = [self options];
    id v34 = [options7 objectForKeyedSubscript:@"AMFDRDataCopy"];
    if ([v34 boolValue]) {
        long v36 = AMFDRCreateWithOptions(kCFAllocatorDefault, dictionary);
        FTOptions *options8 = [self options];
        id v38 = [options8 objectForKeyedSubscript:@"key"];
        FTOptions *options9 = [self options];
        id v40 = [options9 objectForKeyedSubscript:@"moduleSN"];
        CFTypeRef cf2 = AMFDRDataCopy(v36, v38, v40, &v1);
        FILE *v42 = stderr;
        if (!cf2) {
            NSString *v44 = [NSString stringWithFormat:@"[ERROR] AMFDRDataCopy error: %@", v1];
            fprintf(v42, "%s\n", [v44 UTF8String]);
            os_log_t oslog3 = osd_shared_log_handle(v44);
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_ERROR)) {
                sub_10000c244(&v1, oslog3);
            }
            if (v1 != 0) {
                CFRelease(v1);
                v1 = 0;
            }
            v20 = 1;
        } else {
            NSString *v46 = [NSString stringWithFormat:@"Data: %@", cf2];
            fprintf(v42, "%s\n", [v46 UTF8String]);
            os_log_t oslog4 = osd_shared_log_handle(v46);
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Data: %@", cf2);
            }
            FTOptions *options10 = [self options];
            NSString *v49 = [options10 objectForKeyedSubscript:@"outputPath"];
            if (v49 != nil && ![self writeDataToFile:v49 data:cf2]) {
                v20 = 2;
            }
            CFRelease(cf2);
        }
    }
    return v20;
}


bool -[FactoryDataRecovery writeDataToFile:data:](NSString *a1, struct __CFData *a2)
{
    NSString *v2 = [NSString stringWithFormat:@"Saving data to %@", a1];
    fprintf(stderr, "%s\n", [v2 UTF8String]);
    os_log_t oslog2 = osd_shared_log_handle(v2);
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Saving data to %@", a1);
    }
    NSError *v5 = nil;
    int v6 = 1;
    if (![a2 writeToFile:a1 options:NSDataWritingAtomic error:&v5]) {
        NSString *v9 = [NSString stringWithFormat:@"[ERROR] Error writing to file due to %@", v5];
        fprintf(stderr, "%s\n", [v9 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v9);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            sub_10000c2ec(v5, oslog);
        }
        v6 = 0;
    }
    return v6;
}
