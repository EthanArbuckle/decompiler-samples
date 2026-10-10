struct _CNTArrayLogger {
    NSMutableArray *_logs; // +0x8
};

_CNTArrayLogger *-[_CNTArrayLogger init](void)
{
    _CNTArrayLogger *v2 = [super init];
    if (v2 != nil) {
        v2->_logs = [NSMutableArray array];
    }
    return v2;
}


void -[_CNTArrayLogger log:](id a1)
{
    NSCharacterSet *newlineCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSArray<NSString *> *otherArray = [a1 componentsSeparatedByCharactersInSet:newlineCharacterSet];
    NSMutableArray *logs = [self logs];
    [logs addObjectsFromArray:otherArray];
}


NSMutableArray *-[_CNTArrayLogger logs](void)
{
    return self->_logs;
}


void -[_CNTArrayLogger .cxx_destruct](void)
{
    self->_logs = nil;
}
