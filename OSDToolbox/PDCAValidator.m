void +[PDCAValidator load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[PDCAValidator moduleName](void)
{
    return @"pdcavalidator";
}


NSString *-[PDCAValidator moduleOverview](void)
{
    return @"Can be used to validate PDCA format";
}


void -[PDCAValidator addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"path" shortOption:112 argumentType:3 defaultValue:0 description:@"File Path of pdca plist"];
}


int -[PDCAValidator moduleMain](void)
{
    int v8;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    FTOptions *options = [self options];
    NSString *path = [options objectForKeyedSubscript:@"path"];
    NSTimeZone *v4 = [NSTimeZone timeZoneWithName:@"GMT"];
    if (![defaultManager fileExistsAtPath:path]) {
        NSString *v5 = [NSString stringWithFormat:@"Could not find pdca file at path %@", path];
        fprintf(stderr, "%s\n", [v5 UTF8String]);
        os_log_t oslog6 = osd_shared_log_handle(v5);
        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "Could not find pdca file at path %@", path);
        }
        v8 = 1;
    } else {
        NSDictionary *v9 = [NSDictionary dictionaryWithContentsOfFile:path];
        FILE *v11 = stderr;
        if (!v9) {
            NSString *v13 = [NSString stringWithFormat:@"Could not parse plist format! Plist/xml invalid!"];
            fprintf(v11, "%s\n", [v13 UTF8String]);
            os_log_t oslog = osd_shared_log_handle(v13);
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Could not parse plist format! Plist/xml invalid!");
            }
            v8 = 2;
        } else {
            NSString *v15 = [NSString stringWithFormat:@"Validating PDCA data from %@ using time zone %@", path, v4];
            fprintf(v11, "%s\n", [v15 UTF8String]);
            os_log_t oslog2 = osd_shared_log_handle(v15);
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Validating PDCA data from %@ using time zone %@", path, v4);
            }
            OSDPDCAObject *v18 = [[OSDPDCAObject alloc] initWithDictionary:v9 timeZone:v4];
            FILE *v19 = stderr;
            if (!v18) {
                NSString *v21 = [NSString stringWithFormat:@"Could not parse the PDCA object. Check the the OS logs for more details"];
                fprintf(v19, "%s\n", [v21 UTF8String]);
                os_log_t oslog3 = osd_shared_log_handle(v21);
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Could not parse the PDCA object. Check the the OS logs for more details");
                }
                v8 = 3;
            } else {
                id dictionary = [v18 dictionary];
                NSString *v24 = [NSString stringWithFormat:@"%@", dictionary];
                fprintf(v19, "%s\n", [v24 UTF8String]);
                os_log_t oslog4 = osd_shared_log_handle(dictionary);
                if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                    id dictionary2 = [v18 dictionary];
                    os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "%@", dictionary2);
                }
                NSString *v27 = [NSString stringWithFormat:@"Successfully read in PDCA data!"];
                fprintf(stderr, "%s\n", [v27 UTF8String]);
                os_log_t oslog5 = osd_shared_log_handle(v27);
                if (os_log_type_enabled(oslog5, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog5, OS_LOG_TYPE_DEFAULT, "Successfully read in PDCA data!");
                }
                v8 = 0;
            }
        }
    }
    return v8;
}
