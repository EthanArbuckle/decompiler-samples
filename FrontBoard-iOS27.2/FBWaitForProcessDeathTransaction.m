struct FBWaitForProcessDeathTransaction {
    FBProcess *_process; // +0x98
    double _timeout; // +0xa0
    BSAbsoluteMachTimer *_timer; // +0xa8
};

FBWaitForProcessDeathTransaction *-[FBWaitForProcessDeathTransaction initWithProcess:](long a1, long a2)
{
    return [self initWithProcess:a1 timeout:a2];
}


FBWaitForProcessDeathTransaction *-[FBWaitForProcessDeathTransaction initWithProcess:timeout:](FBProcess *a1, long a2)
{
    double v2;
    FBWaitForProcessDeathTransaction *v1 = [super init];
    if (v1 != nil) {
        v1->_process = a1;
        v1->_timeout = v2;
    }
    return v1;
}


struct FBWaitForProcessDeathTransaction *-[FBWaitForProcessDeathTransaction _begin](void)
{
    struct FBWaitForProcessDeathTransaction *v9;
    if (!self->_process) {
        return self;
    }
    id sharedInstance = [FBProcessManager sharedInstance];
    [sharedInstance addObserver:self];
    int pid = [self->_process pid];
    id v3 = [sharedInstance processForPID:pid];
    if (v3 == self->_process) {
        [self addMilestone:@"FBProcessDidExitMilestone"];
        if (self->_timeout > 0.0) {
            self->_timer = [[BSAbsoluteMachTimer alloc] initWithIdentifier:@"FBWaitForProcessDeathTransaction-watchdog"];
            id queue = [self queue];
            objc_msgSend$scheduleWithFireInterval:leewayInterval:queue:handler:(self->_timer, queue, ^void(BSAbsoluteMachTimer *arg1) {
                [self _failForTimeoutWithDescription:@"process didn't exit in time"];
            }, self->_timeout, 1.0);
        }
        self = [super _begin];
        v9 = self;
    } else {
        v9 = [sharedInstance removeObserver:self];
    }
    return v9;
}


int -[FBWaitForProcessDeathTransaction _canBeInterrupted](void)
{
    return 1;
}


long -[FBWaitForProcessDeathTransaction _didComplete](void)
{
    id sharedInstance = [FBProcessManager sharedInstance];
    [sharedInstance removeObserver:self];
    [self->_timer invalidate];
    return [super _didComplete];
}


NSMutableDictionary *-[FBWaitForProcessDeathTransaction _customizedDescriptionProperties](void)
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    FBProcess *v1 = self->_process;
    if (!self->_process) {
        v1 = @"(none)";
    }
    [dictionary setObject:v1 forKey:@"Process"];
    return dictionary;
}


long -[FBWaitForProcessDeathTransaction processManager:didAddProcess:](long a1, long a2)
{
    return self;
}


void -[FBWaitForProcessDeathTransaction processManager:didRemoveProcess:](long a1, id a2)
{
    dispatch_queue_t queue = [self queue];
    dispatch_async(queue, ^void(void) {
        [self evaluateMilestone:@"FBProcessDidExitMilestone" withEvaluator:^bool(void) {
            return a2 == self->_process;
        }];
    });
}


FBProcess *-[FBWaitForProcessDeathTransaction process](void)
{
    return self->_process;
}


double -[FBWaitForProcessDeathTransaction timeout](void)
{
    return self->_timeout;
}


void -[FBWaitForProcessDeathTransaction .cxx_destruct](void)
{
    self->_timer = nil;
    self->_process = nil;
}
