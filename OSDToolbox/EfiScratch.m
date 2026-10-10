void +[EfiScratch load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[EfiScratch moduleName](void)
{
    return @"efiscratch";
}


NSString *-[EfiScratch moduleOverview](void)
{
    return @"Prints the contents of the EFI PMU scratch space";
}


void -[EfiScratch addOptions](void)
{
}


int -[EfiScratch moduleMain](void)
{
    id sharedInstance = [OSDPMU sharedInstance];
    id EFIScratchData = [sharedInstance EFIScratchData];
    id sharedInstance2 = [OSDPMU sharedInstance];
    id EFIScratchDictionary = [sharedInstance2 EFIScratchDictionary];
    NSString *v5 = [NSString stringWithFormat:@"EFI PMU Scratch raw data: %@", EFIScratchData];
    fprintf(stderr, "%s\n", [v5 UTF8String]);
    os_log_t oslog = osd_shared_log_handle(v5);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "EFI PMU Scratch raw data: %@", EFIScratchData);
    }
    NSString *v8 = [NSString stringWithFormat:@"EFI PMU Scratch dictionary: %@", EFIScratchDictionary];
    fprintf(stderr, "%s\n", [v8 UTF8String]);
    os_log_t oslog2 = osd_shared_log_handle(v8);
    if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "EFI PMU Scratch dictionary: %@", EFIScratchDictionary);
    }
    bool v10 = !EFIScratchData;
    int v11 = v10 | 2;
    if (EFIScratchDictionary != nil) {
        v11 = v10;
    }
    return v11;
}
