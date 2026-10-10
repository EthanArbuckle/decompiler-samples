struct CNTBenchmarkCommand {
    bool _outOfProcess; // +0x18
    NSString *_testCaseName; // +0x20
    NSString *_implementationName; // +0x28
    id<CNTLogger> _logger; // +0x30
};

NSString *+[CNTBenchmarkCommand name](void)
{
    return @"benchmark";
}


NSString *+[CNTBenchmarkCommand usage](void)
{
    id testCaseNames = [ContactsBenchmark testCaseNames];
    NSString *v1 = [testCaseNames componentsJoinedByString:@"|"];
    id implementationNames = [ContactsBenchmark implementationNames];
    NSString *v3 = [implementationNames componentsJoinedByString:@"|"];
    NSString *name = [self name];
    return [NSString stringWithFormat:@"%@ <%@> <%@> [--oop]", name, v1, v3];
}


CNTBenchmarkCommand *-[CNTBenchmarkCommand initWithTestCaseName:implementationName:outOfProcess:logger:](NSString *a1, NSString *a2, bool a3, id<CNTLogger> a4)
{
    Class v1 = [self class];
    CNTBenchmarkCommand *v4 = [super initWithName:[v1 name]];
    if (v4 != nil) {
        v4->_testCaseName = a1;
        v4->_implementationName = a2;
        v4->_outOfProcess = a3;
        v4->_logger = a4;
    }
    return v4;
}


CNTBenchmarkCommand *+[CNTBenchmarkCommand commandWithArguments:logger:error:](id a1, id a2, NSError **a3)
{
    CNTBenchmarkCommand *v8;
    CNTBenchmarkCommand *v24;
    if ([a1 count] <= 1) {
        NSDictionary *v5 = @{NSLocalizedFailureReasonErrorKey: @"Not enough arguments"};
        NSError *v6 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v5];
        v8 = nil;
        if (a3) {
            *(a3) = v6;
        }
    } else {
        id v9 = [a1 objectAtIndexedSubscript:0];
        id v10 = [a1 objectAtIndexedSubscript:1];
        id testCaseNames = [ContactsBenchmark testCaseNames];
        if (![testCaseNames containsObject:v9]) {
            NSString *v13 = [NSString stringWithFormat:@"Unrecognized test case %@", v9];
            NSDictionary *v14 = @{NSLocalizedFailureReasonErrorKey: v13};
            NSError *v15 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v14];
            if (a3 != 0) {
                *(a3) = v15;
            }
            v8 = nil;
        } else {
            id implementationNames = [ContactsBenchmark implementationNames];
            if (![implementationNames containsObject:v10]) {
                NSString *v19 = [NSString stringWithFormat:@"Unrecognized implementation %@", v10];
                NSDictionary *v20 = @{NSLocalizedFailureReasonErrorKey: v19};
                NSError *v21 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v20];
                if (a3 != 0) {
                    *(a3) = v21;
                }
                v8 = nil;
            } else if ([a1 count] < 3) {
                v24 = [self alloc];
                v8 = [v24 initWithTestCaseName:v9 implementationName:v10 outOfProcess:NO logger:a2];
            } else {
                id v25 = [a1 objectAtIndexedSubscript:2];
                if (![v25 isEqual:@"--oop"]) {
                    NSString *v26 = [NSString stringWithFormat:@"Unrecognized option %@", v25];
                    NSDictionary *v27 = @{NSLocalizedFailureReasonErrorKey: v26};
                    NSError *v28 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v27];
                    if (a3 != 0) {
                        *(a3) = v28;
                    }
                    v8 = nil;
                } else {
                    v24 = [self alloc];
                    v8 = [v24 initWithTestCaseName:v9 implementationName:v10 outOfProcess:YES logger:a2];
                }
            }
        }
    }
    return v8;
}


NSNull *-[CNTBenchmarkCommand run:](id *a1)
{
    __block id v0 = nil;
    __block id v3 = nil;
    bool outOfProcess = [self outOfProcess];
    [ContactsBenchmark performBlock:^void(void) {
        NSString *implementationName = [self implementationName];
        id v13 = [ContactsBenchmark implementationWithName:implementationName];
        NSString *testCaseName = [self testCaseName];
        id v14 = [ContactsBenchmark testCaseWithName:testCaseName implementation:v13];
        id v17 = [v14 run:&v3];
        v0 = v17;
        if (!v0) {
            id<CNTLogger> logger = [self logger];
            NSString *localizedFailureReason = [v3 localizedFailureReason];
            NSString *v11 = [NSString stringWithFormat:@"Test case failed: %@", localizedFailureReason];
            [logger log:v11];
        }
    } usingContactsOutOfProcess:outOfProcess];
    return [NSNull null];
}


NSString *-[CNTBenchmarkCommand testCaseName](void)
{
    return self->_testCaseName;
}


NSString *-[CNTBenchmarkCommand implementationName](void)
{
    return self->_implementationName;
}


bool -[CNTBenchmarkCommand outOfProcess](void)
{
    return self->_outOfProcess;
}


id<CNTLogger> -[CNTBenchmarkCommand logger](void)
{
    return self->_logger;
}


void -[CNTBenchmarkCommand .cxx_destruct](void)
{
    self->_logger = nil;
    self->_implementationName = nil;
    self->_testCaseName = nil;
}
