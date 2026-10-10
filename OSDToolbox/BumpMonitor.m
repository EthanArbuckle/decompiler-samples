void +[BumpMonitor load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[BumpMonitor moduleName](void)
{
    return @"bumpmonitor";
}


NSString *-[BumpMonitor moduleOverview](void)
{
    return @"Use test out bump monitor configs";
}


void -[BumpMonitor addOptions](void)
{
    FTOptions *options = [self options];
    [options addOptionWithName:@"sampleInternval" shortName:@"i" type:1 defaultValue:@"0.005" description:@"sample interval of sensor"];
    FTOptions *options2 = [self options];
    [options2 addOptionWithName:@"varianceThreshold" shortName:@"v" type:1 defaultValue:@"1.0" description:@"Variable filter threshold before a bump is triggered"];
    FTOptions *options3 = [self options];
    [options3 addOptionWithName:@"varianceBufferSize" shortName:@"s" type:1 defaultValue:@"100" description:@"sample interval of sensor"];
}


int -[BumpMonitor moduleMain](void)
{
    NSOperationQueue *v1 = [[NSOperationQueue alloc] init];
    [v1 setQualityOfService:NSQualityOfServiceUserInteractive];
    OSDBumpMonitor *v2 = [OSDBumpMonitor alloc];
    FTOptions *options = [self options];
    id v4 = [options objectForKeyedSubscript:@"sampleInternval"];
    double doubleValue = [v4 doubleValue];
    FTOptions *options2 = [self options];
    id v7 = [options2 objectForKeyedSubscript:@"varianceThreshold"];
    double doubleValue2 = [v7 doubleValue];
    FTOptions *options3 = [self options];
    id v10 = [options3 objectForKeyedSubscript:@"varianceBufferSize"];
    int intValue = [v10 intValue];
    id v12 = objc_msgSend(v2, @selector(initWithSampleInterval:varianceThreshold:varianceBufferSize:), intValue, (float)doubleValue, (float)doubleValue2);
    id v13 = nil;
    [v12 startMonitorOnQueue:v1 withHandler:^void(bool arg1, NSDate *arg2, float arg3, float arg4) {
        NSString *v17 = (arg1) ? @"YES" : @"NO";
        double v18 = (double)arg3;
        double v19 = (double)arg4;
        NSString *v20 = [NSString stringWithFormat:@"Time: %@, Active: %@, variance: %f, varianceThreshold: %f", arg2, v17, v18, v19];
        fprintf(stdout, "%s\n", [v20 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v20);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Time: %@, Active: %@, variance: %f, varianceThreshold: %f", arg2, v17, v18, v19);
        }
    } error:&v13];
    NSString *v14 = [NSString stringWithFormat:@"ctrl+c to exit..."];
    fprintf(stdout, "%s\n", [v14 UTF8String]);
    os_log_t oslog = osd_shared_log_handle(v14);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "ctrl+c to exit...");
    }
    CFRunLoopRun();
    return 0;
}
