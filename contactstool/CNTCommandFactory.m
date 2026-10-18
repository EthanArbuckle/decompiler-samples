CNTLogTask *+[CNTCommandFactory commandForArguments:factory:logger:](id a1, id a2, id a3)
{
    CNTLogTask *v4;
    CNTChangeHistoryCommand *v24;
    CNTWhoAmICommand *v25;
    if (![a1 count]) {
        v4 = [a2 showHelpTaskWithLogger:a3];
    } else {
        Class v6 = [self class];
        id v7 = a1;
        id v8 = [v6 parseOptionsInArgs:&v7];
        long v15 = 0;
        for (id v32 in v8) {
            v15 |= [v32 options];
        }
        bool v14 = v15 & 1;
        id v18 = [v7 objectAtIndexedSubscript:0];
        NSArray<NSString *> *v19 = [v18 componentsSeparatedByString:@"="];
        if ([v19 count] != 1) {
            [v19 count];
blk_1000081d0:
            id v20 = [v7 objectAtIndexedSubscript:0];
            NSString *v21 = [NSString stringWithFormat:@"Unrecognized command: %@", v20];
            v4 = [a2 showHelpTaskWithMessage:v21 logger:a3];
        } else {
            id v22 = [v7 objectAtIndexedSubscript:0];
            if (![@"whoami" _cn_caseInsensitiveIsEqual:v22]) {
                if ([@"history" _cn_caseInsensitiveIsEqual:v22] != 0) {
                    id v31 = [v7 _cn_skip:1];
                    v24 = [a2 historyTaskWithArguments:v31 logger:a3];
                } else {
                    if (([@"benchmark" _cn_caseInsensitiveIsEqual:v22] & 1) == 0) {
                        goto blk_1000081d0;
                    }
                    id v23 = [v7 _cn_skip:1];
                    v24 = [a2 benchmarkTaskWithArguments:v23 logger:a3];
                }
                v25 = v24;
            } else {
                v25 = [a2 whoAmITaskWithLogger:a3];
            }
            if (!v25) {
                goto blk_1000081d0;
            }
            NSMutableArray *v26 = [NSMutableArray arrayWithCapacity:5];
            Class v27 = [self class];
            id immediateScheduler = [CNScheduler immediateScheduler];
            id v29 = [v27 performanceTaskWithTask:v25 scheduler:immediateScheduler logger:a3];
            [v26 addObject:v29];
            if (v14) {
                id v30 = [a2 keepAliveTaskWithLogger:a3];
                [v26 addObject:v30];
            }
            v4 = [CNTask taskWithName:@"com.apple.contacts.tool" subtasks:v26];
        }
    }
    return v4;
}


id +[CNTCommandFactory parseOptionsInArgs:](id *a1)
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSMutableArray *array = [NSMutableArray array];
    NSArray *supportedOptions = [self supportedOptions];
    for (id v9 in supportedOptions) {
        NSString *name = [v9 name];
        NSString *v11 = [@"--" stringByAppendingString:name];
        NSUInteger value = [*(a1) indexOfObject:v11];
        if (value != NSNotFound) {
            [array addObject:v9];
            [indexSet addIndex:value];
        }
    }
    id v13 = [*(a1) mutableCopy];
    [v13 removeObjectsAtIndexes:indexSet];
    *(a1) = [v13 copy];
    return [array copy];
}


CNTWhoAmICommand *-[CNTCommandFactory whoAmITaskWithLogger:](id a1)
{
    return [[CNTWhoAmICommand alloc] initWithLogger:a1];
}


CNTChangeHistoryCommand *-[CNTCommandFactory historyTaskWithArguments:logger:](id a1, id a2)
{
    return [[CNTChangeHistoryCommand alloc] initWithArguments:a1 logger:a2];
}


id -[CNTCommandFactory benchmarkTaskWithArguments:logger:](id a1, id a2)
{
    NSError *v3 = nil;
    id v4 = [CNTBenchmarkCommand commandWithArguments:a1 logger:a2 error:&v3];
    if (!v4) {
        NSDictionary<NSErrorUserInfoKey, id> *userInfo = [v3 userInfo];
        id v7 = [userInfo objectForKeyedSubscript:NSLocalizedFailureReasonErrorKey];
        v4 = [self showHelpTaskWithMessage:v7 logger:a2];
    }
    return v4;
}


id +[CNTCommandFactory performanceTaskWithTask:scheduler:logger:](id a1, id a2, id a3)
{
    return [CNTask taskWithBlock:^id(id *arg1) {
        double timestamp = [a2 timestamp];
        id v1 = [a1 run:arg1];
        double timestamp2 = [a2 timestamp];
        CNTElapsedTimeFormatter *sharedFormatter = [CNTElapsedTimeFormatter sharedFormatter];
        NSString *v7 = [sharedFormatter stringForTimeInterval:timestamp2 - timestamp];
        NSString *v5 = [NSString stringWithFormat:@"Time to execute command: %@", v7];
        [a3 log:v5];
        return v1;
    }];
}


NSArray *+[CNTCommandFactory supportedCommands](void)
{
    return @[[CNTBenchmarkCommand class]];
}


NSArray *+[CNTCommandFactory supportedOptions](void)
{
    return @[[CNTKeepAliveOption class]];
}


CNTLogTask *-[CNTCommandFactory showHelpTaskWithLogger:](id a1)
{
    return [self showHelpTaskWithMessage:nil logger:a1];
}


CNTLogTask *-[CNTCommandFactory showHelpTaskWithMessage:logger:](id a1, id a2)
{
    NSMutableArray *array = [NSMutableArray array];
    [array _cn_addNonNilObject:a1];
    Class v2 = [self class];
    NSArray *usageText = [v2 usageText];
    [array addObjectsFromArray:usageText];
    return [[CNTLogTask alloc] initWithLogs:array logger:a2];
}


id +[CNTCommandFactory usageText](void)
{
    NSArray *supportedCommands = [self supportedCommands];
    NSArray *supportedOptions = [self supportedOptions];
    return [self usageTextWithCommandClasses:supportedCommands optionClasses:supportedOptions];
}


id +[CNTCommandFactory usageTextWithCommandClasses:optionClasses:](NSArray *a1, NSArray *a2)
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:@"Usage (as mobile):"];
    [a1 _cn_each:^void(Class arg1) {
        id usage = [arg1 usage];
        NSString *v1 = [NSString stringWithFormat:@"%@ %@", @"contactstool", usage];
        [array addObject:v1];
    }];
    [array addObject:@"Common options:"];
    [a2 _cn_each:^void(Class arg1) {
        id name = [arg1 name];
        id help = [arg1 help];
        NSString *v8 = [NSString stringWithFormat:@"\t%@%@: %@", @"--", name, help];
        [array addObject:v8];
    }];
    return [array copy];
}


id -[CNTCommandFactory keepAliveTaskWithLogger:](id a1)
{
    return [CNTask taskWithBlock:^id(id *arg1) {
        [a1 log:@"Execution complete. Press ^C to exit."];
        NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
        NSDate *limitDate = [NSDate distantFuture];
        [currentRunLoop runUntilDate:limitDate];
        return [NSNull null];
    }];
}
