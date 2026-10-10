struct CNTWhoAmICommand {
    id<CNTLogger> _logger; // +0x18
};

CNTWhoAmICommand *-[CNTWhoAmICommand initWithLogger:](id<CNTLogger> a1)
{
    CNTWhoAmICommand *v2 = [super initWithName:@"com.apple.contacts.tool.whoami"];
    if (v2 != nil) {
        v2->_logger = a1;
    }
    return v2;
}


NSNull *-[CNTWhoAmICommand run:](id *a1)
{
    id<CNTLogger> logger = [self logger];
    [logger log:@"Good question."];
    return [NSNull null];
}


id<CNTLogger> -[CNTWhoAmICommand logger](void)
{
    return self->_logger;
}


void -[CNTWhoAmICommand setLogger:](id<CNTLogger> a1)
{
    self->_logger = a1;
}


void -[CNTWhoAmICommand .cxx_destruct](void)
{
    self->_logger = nil;
}
