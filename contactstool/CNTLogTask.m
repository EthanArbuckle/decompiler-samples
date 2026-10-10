struct CNTLogTask {
    NSArray *_logs; // +0x18
    id<CNTLogger> _logger; // +0x20
};

CNTLogTask *-[CNTLogTask initWithLogs:logger:](NSArray *a1, id<CNTLogger> a2)
{
    CNTLogTask *v2 = [super initWithName:@""];
    if (v2 != nil) {
        v2->_logs = a1;
        v2->_logger = a2;
    }
    return v2;
}


NSNull *-[CNTLogTask run:](id *a1)
{
    NSArray *logs = [self logs];
    [logs _cn_each:^void(NSString *arg1) {
        id<CNTLogger> logger = [self logger];
        [logger log:arg1];
    }];
    return [NSNull null];
}


NSArray *-[CNTLogTask logs](void)
{
    return self->_logs;
}


id<CNTLogger> -[CNTLogTask logger](void)
{
    return self->_logger;
}


void -[CNTLogTask .cxx_destruct](void)
{
    self->_logger = nil;
    self->_logs = nil;
}
