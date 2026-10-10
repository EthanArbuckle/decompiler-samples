void +[LoggingExample load](void)
{
    [FTModuleManager registerModuleClass:self];
}


NSString *-[LoggingExample moduleName](void)
{
    return @"LoggingExample";
}


NSString *-[LoggingExample moduleOverview](void)
{
    return @"An example for OS Diags Logging adoption";
}


void -[LoggingExample addOptions](void)
{
}


int -[LoggingExample moduleMain](void)
{
    NSLog(@"Welcome to the OSD LoggingExample");
    os_log_t oslog = os_log_create("com.apple.osdiags", "OSDToolbox");
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%@ I am logging to os_log", @"Hello,");
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "%@ even though os_log takes a CString, NSObjects are allowed.", @"Hello,");
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        sub_10000bf70(oslog);
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "This is an info log, it only goes to memory and gets dumped when requested. ");
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "This is the most common logging function. It gets flushed to disk when the memory buffers fill");
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
        sub_10000bf38(oslog);
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_FAULT)) {
        sub_10000bf0c(oslog);
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Use a hashtag to make tracing of logs easier #helpful");
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Looks like debug logging is enabled!");
        }
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            sub_10000bee0(oslog);
        }
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            sub_10000beb4(oslog);
        }
    }
    _os_activity_initiate(&_mh_execute_header, "Bluetooth Scan", 0, ^void(void) {
        NSLog(@"We are about to call a bluetooth scan");
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Starting bluetooth scan");
        }
        dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
        id sharedInstance = [OSDBluetooth sharedInstance];
        dispatch_queue_global_t v4 = dispatch_get_global_queue(21, 0);
        objc_msgSend(sharedInstance, @selector(performScanOnQueue:timeout:gracePeriod:completionBlock:), v4, ^void(NSArray *arg1, NSError *arg2) {
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Bluetooth scan completion block!");
            }
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                NSUInteger count = [arg1 count];
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Found %lu bluetooth devices: %@", count, arg1);
            }
            dispatch_semaphore_signal(dsema);
        }, 10.0, 10.0);
        dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Bluetooth scan finished");
        }
    });
    struct os_state_data_s *(^v8)(struct os_state_hints_s *) = ^struct os_state_data_s *(struct os_state_hints_s *arg1) {
        NSLog(@"State dump triggered");
        FTOptions *options = [self options];
        NSString *description = [options description];
        NSData *v14 = [description dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger length = [v14 length];
        void *v4 = calloc(1, length + 200);
        *(v4) = 1;
        __strlcpy_chk(v4 + 136, "OptionsDict", 64, 64);
        memmove(v4 + 200, [v14 bytes], [v14 length]);
        v4->field_4 = [v14 length];
        return v4;
    };
    dispatch_queue_global_t v9 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    os_state_add_handler(v9, v8);
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_FAULT)) {
        sub_10000be88(oslog);
    }
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Funny thing is I have no idea where this data goes! But it goes somewhere!");
    }
    NSLog(@"To see the results on your computer, run log collect and copy the resulting logarchive onto your computer");
    NSLog(@"If you are running Gala you will need to copy logdump");
    NSLog(@"The command to do that is:");
    NSLog(@"sudo cp /SWE/release/Software/Fuji/Updates/NewestFuji/Roots/libtrace_host/usr/local/bin/logdump /usr/local/bin/");
    return 0;
}
