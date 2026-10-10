struct CNTChangeHistoryTask {
    NSString *_clientIdentifier; // +0x18
    id<CNTLogger> _logger; // +0x20
    CNContactStore *_contactStore; // +0x28
};

CNTChangeHistoryTask *-[CNTChangeHistoryTask initWithClientIdentifier:logger:](id a1, id<CNTLogger> a2)
{
    Class v2 = [self class];
    CNTChangeHistoryTask *v5 = [super initWithName:[v2 taskName]];
    if (v5 != nil) {
        v5->_clientIdentifier = [a1 copy];
        v5->_logger = a2;
    }
    return v5;
}


NSString *+[CNTChangeHistoryTask taskName](void)
{
    return @"com.apple.contacts.tool.history";
}


id -[CNTChangeHistoryTask run:](id *a1)
{
    [self makeContactStore];
    return [self onRun:a1];
}


void -[CNTChangeHistoryTask makeContactStore](void)
{
    self->_contactStore = [[CNContactStore alloc] init];
}


id -[CNTChangeHistoryTask onRun:](id *a1)
{
    objc_exception_throw(CNAbstractMethodException(self, _cmd));
}


NSString *-[CNTChangeHistoryTask clientIdentifier](void)
{
    return objc_getProperty(self, _cmd, 24, 0);
}


id<CNTLogger> -[CNTChangeHistoryTask logger](void)
{
    return self->_logger;
}


CNContactStore *-[CNTChangeHistoryTask contactStore](void)
{
    return self->_contactStore;
}


void -[CNTChangeHistoryTask .cxx_destruct](void)
{
    self->_contactStore = nil;
    self->_logger = nil;
    self->_clientIdentifier = nil;
}
