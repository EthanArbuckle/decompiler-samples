struct CNTChangeHistoryCommand {
    NSArray *_arguments; // +0x18
    id<CNTLogger> _logger; // +0x20
};

CNTChangeHistoryCommand *-[CNTChangeHistoryCommand initWithArguments:logger:](id a1, id<CNTLogger> a2)
{
    CNTChangeHistoryCommand *v3 = [super init];
    if (v3 != nil) {
        v3->_arguments = [a1 copy];
        v3->_logger = a2;
    }
    return v3;
}


id -[CNTChangeHistoryCommand run:](id *a1)
{
    CNTChangeHistoryClearToAnchorTask *implementationTask = [self implementationTask];
    id v1 = nil;
    id v2 = [implementationTask run:&v1];
    if (a1 != 0 && !v2) {
        *(a1) = v1;
    }
    return v2;
}


CNTChangeHistoryClearToAnchorTask *-[CNTChangeHistoryCommand implementationTask](void)
{
    id v7;
    CNTChangeHistoryClearToAnchorTask *v10;
    id<CNTLogger> logger;
    NSArray *arguments = [self arguments];
    id firstObject = [arguments firstObject];
    NSArray *arguments2 = [self arguments];
    id v4 = [arguments2 _cn_skip:1];
    id firstObject2 = [v4 firstObject];
    id v6 = (!firstObject2) ? @"contacts-tool" : firstObject2;
    if (([@"show-changes" _cn_caseInsensitiveIsEqual:firstObject] & 1) != 0 || [@"list" _cn_caseInsensitiveIsEqual:firstObject] != 0) {
        v7 = [CNTChangeHistoryShowChangesTask alloc];
        logger = [self logger];
        return [v7 initWithClientIdentifier:v6 logger:logger];
    }
    if ([@"monitor" _cn_caseInsensitiveIsEqual:firstObject] != 0) {
        v7 = [CNTChangeHistoryMonitorTask alloc];
        logger = [self logger];
        return [v7 initWithClientIdentifier:v6 logger:logger];
    }
    if (([@"register-client" _cn_caseInsensitiveIsEqual:firstObject] & 1) != 0 || [@"register" _cn_caseInsensitiveIsEqual:firstObject] != 0) {
        v7 = [CNTChangeHistoryRegisterClientTask alloc];
        logger = [self logger];
        return [v7 initWithClientIdentifier:v6 logger:logger];
    }
    long v12 = [@"unregister-client" _cn_caseInsensitiveIsEqual:firstObject];
    if ((v12 & 1) != 0 || [@"unregister" _cn_caseInsensitiveIsEqual:firstObject] != 0) {
        v7 = [CNTChangeHistoryUnregisterClientTask alloc];
        logger = [self logger];
        return [v7 initWithClientIdentifier:v6 logger:logger];
    }
    long v13 = [@"clear-history" _cn_caseInsensitiveIsEqual:firstObject];
    if ((v13 & 1) != 0 || [@"clear" _cn_caseInsensitiveIsEqual:firstObject] != 0) {
        if ([v4 count] <= 1) {
            NSDictionary *v16 = @{NSLocalizedFailureReasonErrorKey: @"Invalid syntax"};
            NSError *v17 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v16];
            v10 = [CNTask taskWithError:v17];
        } else {
            id v19 = [v4 objectAtIndexedSubscript:2];
            v10 = [[CNTChangeHistoryClearToAnchorTask alloc] initWithAnchorString:v19 clientIdentifier:v6 logger:[self logger]];
        }
        return v10;
    }
    NSDictionary *v22 = @{NSLocalizedFailureReasonErrorKey: @"Invalid syntax"};
    NSError *v23 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v22];
    v10 = [CNTask taskWithError:v23];
    return v10;
}


NSArray *-[CNTChangeHistoryCommand arguments](void)
{
    return objc_getProperty(self, _cmd, 24, 0);
}


id<CNTLogger> -[CNTChangeHistoryCommand logger](void)
{
    return self->_logger;
}


void -[CNTChangeHistoryCommand .cxx_destruct](void)
{
    self->_logger = nil;
    self->_arguments = nil;
}
