struct CNTChangeHistoryResultWriterImpl {
    id<CNTLogger> _logger; // +0x8
    CNContactStore *_contactStore; // +0x10
};

CNTChangeHistoryResultWriterImpl *-[CNTChangeHistoryResultWriterImpl initWithLogger:contactStore:](id<CNTLogger> a1, CNContactStore *a2)
{
    CNTChangeHistoryResultWriterImpl *v1 = [super init];
    if (v1 != nil) {
        v1->_logger = a1;
        v1->_contactStore = a2;
    }
    return v1;
}


void -[CNTChangeHistoryResultWriterImpl logResult:](id a1)
{
    if (![a1 changesTruncated]) {
        id contactChanges = [a1 contactChanges];
        long count = [contactChanges count];
        if (count != 0) {
            [self processDeltaResult:a1];
        }
    } else {
        [self processTruncatedResult:a1];
    }
}


void -[CNTChangeHistoryResultWriterImpl processTruncatedResult:](id a1)
{
    objc_exception_throw(CNAbstractMethodException(self, _cmd));
}


bool -[CNTChangeHistoryResultWriterImpl processDeltaResult:](id a1)
{
    objc_exception_throw(CNAbstractMethodException(self, _cmd));
}


id<CNTLogger> -[CNTChangeHistoryResultWriterImpl logger](void)
{
    return self->_logger;
}


CNContactStore *-[CNTChangeHistoryResultWriterImpl contactStore](void)
{
    return self->_contactStore;
}


void -[CNTChangeHistoryResultWriterImpl .cxx_destruct](void)
{
    self->_contactStore = nil;
    self->_logger = nil;
}
