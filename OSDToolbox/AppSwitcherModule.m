void +[AppSwitcherModule load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[AppSwitcherModule moduleName](void)
{
    return @"appswitch";
}


NSString *-[AppSwitcherModule moduleOverview](void)
{
    return @"Use the module to switch apps";
}


void -[AppSwitcherModule addOptions](void)
{
    FTOptions *options = [self options];
    [options addOption:@"list" shortOption:108 argumentType:0 defaultValue:0 description:@"Lists available tasks"];
    FTOptions *options2 = [self options];
    [options2 addOption:@"switch" shortOption:115 argumentType:1 defaultValue:0 description:@"Task name to switch to"];
    FTOptions *options3 = [self options];
    [options3 addOption:@"current" shortOption:99 argumentType:0 defaultValue:0 description:@"Current task name"];
    FTOptions *options4 = [self options];
    [options4 addOption:@"bootarg" shortOption:98 argumentType:0 defaultValue:0 description:@"Switch app based on boot-args"];
    FTOptions *options5 = [self options];
    [options5 addOption:@"taskforbootarg" shortOption:116 argumentType:1 defaultValue:0 description:@"Prints task name for requested boot-arg"];
    FTOptions *options6 = [self options];
    [options6 addOption:@"unload" shortOption:117 argumentType:0 defaultValue:0 description:@"Unload current task"];
}


int -[AppSwitcherModule moduleMain](void)
{
    os_log_t v20;
    FTOptions *options = [self options];
    id v2 = [options objectForKeyedSubscript:@"list"];
    if (v2 != nil) {
        id requestSwitchableTaskList = [RTTaskSwitcher requestSwitchableTaskList];
        NSString *v39 = [NSString stringWithFormat:@"Tasks: %@", requestSwitchableTaskList];
        fprintf(stderr, "%s\n", [v39 UTF8String]);
        os_log_t oslog2 = osd_shared_log_handle(v39);
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Tasks: %@", requestSwitchableTaskList);
            return 0;
        }
        return 0;
    }
    FTOptions *options3 = [self options];
    id v4 = [options3 objectForKeyedSubscript:@"current"];
    if (v4 != nil) {
        id requestCurrentTaskName = [RTTaskSwitcher requestCurrentTaskName];
        NSString *v38 = [NSString stringWithFormat:@"Current task: %@", requestCurrentTaskName];
        fprintf(stderr, "%s\n", [v38 UTF8String]);
        os_log_t oslog7 = osd_shared_log_handle(v38);
        if (os_log_type_enabled(oslog7, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog7, OS_LOG_TYPE_DEFAULT, "Current task: %@", requestCurrentTaskName);
            return 0;
        }
        return 0;
    }
    FTOptions *options5 = [self options];
    id v6 = [options5 objectForKeyedSubscript:@"switch"];
    if (v6 != nil) {
        FTOptions *options4 = [self options];
        id v32 = [options4 objectForKeyedSubscript:@"switch"];
        long v33 = [RTTaskSwitcher requestSwitchToTaskName:v32];
        FILE *v34 = stderr;
        if (!v33) {
            NSString *v36 = [NSString stringWithFormat:@"[ERROR] Task switch was a failure"];
            fprintf(v34, "%s\n", [v36 UTF8String]);
            v20 = osd_shared_log_handle(v36);
            if (os_log_type_enabled(v20, OS_LOG_TYPE_ERROR)) {
                sub_10000c020(v20);
            }
            return 1;
        }
        NSString *v37 = [NSString stringWithFormat:@"Task switch was a success"];
        fprintf(v34, "%s\n", [v37 UTF8String]);
        os_log_t oslog3 = osd_shared_log_handle(v37);
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Task switch was a success");
            return 0;
        }
        return 0;
    }
    FTOptions *options6 = [self options];
    id v8 = [options6 objectForKeyedSubscript:@"taskforbootarg"];
    FTOptions *options7 = [self options];
    if (v8 != nil) {
        id v42 = [options7 objectForKeyedSubscript:@"taskforbootarg"];
        id v47 = [RTTaskSwitcher requestTaskNameForBootarg:v42];
        NSString *v29 = [NSString stringWithFormat:@"Task name for %@=%@", v42, v47];
        fprintf(stderr, "%s\n", [v29 UTF8String]);
        os_log_t oslog = osd_shared_log_handle(v29);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Task name for %@=%@", v42, v47);
        }
        return 0;
    }
    id v10 = [options7 objectForKeyedSubscript:@"bootarg"];
    if (v10 != nil) {
        long requestBootargBasedTaskSwitch = [RTTaskSwitcher requestBootargBasedTaskSwitch];
        FILE *v24 = stderr;
        if (!requestBootargBasedTaskSwitch) {
            NSString *v26 = [NSString stringWithFormat:@"[ERROR] Task switch was a failure"];
            fprintf(v24, "%s\n", [v26 UTF8String]);
            v20 = osd_shared_log_handle(v26);
            if (!os_log_type_enabled(v20, OS_LOG_TYPE_ERROR)) {
                return 1;
            }
            sub_10000bff4(v20);
            return 1;
        }
        NSString *v27 = [NSString stringWithFormat:@"Task switch was a success"];
        fprintf(v24, "%s\n", [v27 UTF8String]);
        os_log_t oslog4 = osd_shared_log_handle(v27);
        if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Task switch was a success");
            return 0;
        }
        return 0;
    }
    FTOptions *options2 = [self options];
    if (![options2 objectForKeyedSubscript:@"unload"]) {
        NSString *v13 = [NSString stringWithFormat:@"[ERROR] Sorry, I did not understand your request.  Please use \"-h\" to see the help."];
        fprintf(stderr, "%s\n", [v13 UTF8String]);
        os_log_t oslog5 = osd_shared_log_handle(v13);
        if (os_log_type_enabled(oslog5, OS_LOG_TYPE_ERROR)) {
            sub_10000bf9c(oslog5);
        }
        return 0;
    }
    long requestUnloadCurrentTask = [RTTaskSwitcher requestUnloadCurrentTask];
    FILE *v17 = stderr;
    if (requestUnloadCurrentTask != 0) {
        NSString *v21 = [NSString stringWithFormat:@"Task unload was a success"];
        fprintf(v17, "%s\n", [v21 UTF8String]);
        os_log_t oslog6 = osd_shared_log_handle(v21);
        if (os_log_type_enabled(oslog6, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog6, OS_LOG_TYPE_DEFAULT, "Task unload was a success");
            return 0;
        }
        return 0;
    }
    NSString *v19 = [NSString stringWithFormat:@"[ERROR] Task unload was a failure"];
    fprintf(v17, "%s\n", [v19 UTF8String]);
    v20 = osd_shared_log_handle(v19);
    if (os_log_type_enabled(v20, OS_LOG_TYPE_ERROR)) {
        sub_10000bfc8(v20);
    }
    return 1;
}
