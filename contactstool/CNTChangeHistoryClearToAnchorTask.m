struct CNTChangeHistoryClearToAnchorTask {
    NSString *_anchorString; // +0x18
};

CNTChangeHistoryClearToAnchorTask *-[CNTChangeHistoryClearToAnchorTask initWithAnchorString:clientIdentifier:logger:](id a1, id a2, id a3)
{
    CNTChangeHistoryClearToAnchorTask *v4 = [super initWithClientIdentifier:a2 logger:a3];
    if (v4 != nil) {
        v4->_anchorString = [a1 copy];
    }
    return v4;
}


NSString *+[CNTChangeHistoryClearToAnchorTask taskName](void)
{
    return @"com.apple.contacts.tool.history.clear";
}


NSNull *-[CNTChangeHistoryClearToAnchorTask onRun:](id *a1)
{
    NSNull *v8;
    Class v1 = [self class];
    NSString *anchorString = [self anchorString];
    NSError *v3 = nil;
    id v4 = [v1 anchorWithString:anchorString error:&v3];
    if (!v4) {
        id<CNTLogger> logger2 = [self logger];
        NSString *v7 = [NSString stringWithFormat:@"Anchor error: %@", v3];
        [logger2 log:v7];
        v8 = nil;
        if (a1) {
            *(a1) = v3;
        }
    } else {
        CNChangeHistoryClearRequest *v11 = [[CNChangeHistoryClearRequest alloc] initWithClientIdentifier:[self clientIdentifier]];
        [v11 setToChangeAnchor:v4];
        CNContactStore *contactStore = [self contactStore];
        id v13 = nil;
        long v14 = [contactStore executeChangeHistoryClearRequest:v11 error:&v13];
        id<CNTLogger> logger = [self logger];
        if ((v14 & 1) == 0) {
            NSString *v17 = [NSString stringWithFormat:@"Could not clear anchor: %@", v13];
            [logger log:v17];
            v8 = nil;
            if (a1) {
                *(a1) = v13;
            }
        } else {
            [logger log:@"Cleared history to anchor."];
            v8 = [NSNull null];
        }
    }
    return v8;
}


id +[CNTChangeHistoryClearToAnchorTask anchorWithString:error:](NSString *a1, NSError **a2)
{
    id v8;
    NSData *v3 = [[NSData alloc] initWithBase64EncodedString:a1 options:0];
    if (!v3) {
        NSMutableDictionary *v5 = [[NSMutableDictionary alloc] init];
        [v5 setObject:nil forKeyedSubscript:NSUnderlyingErrorKey];
        NSMutableDictionary *v6 = (![v5 count]) ? nil : v5;
        NSError *v7 = [NSError errorWithDomain:@"CNTErrorDomain" code:4 userInfo:v6];
        if (a2 != 0) {
            *(a2) = v7;
        }
        v8 = nil;
    } else {
        Class v9 = [CNChangeHistoryAnchor class];
        id obj = nil;
        id v11 = [CNArchiver decodeObjectOfClass:v9 data:v3 error:&obj];
        if (!v11) {
            NSMutableDictionary *v15 = [[NSMutableDictionary alloc] init];
            [v15 setObject:obj forKeyedSubscript:NSUnderlyingErrorKey];
            NSMutableDictionary *v16 = (![v15 count]) ? nil : v15;
            NSError *v17 = [NSError errorWithDomain:@"CNTErrorDomain" code:6 userInfo:v16];
            if (a2 != 0) {
                *(a2) = v17;
            }
            v8 = nil;
        } else {
            v8 = v11;
        }
    }
    return v8;
}


NSString *-[CNTChangeHistoryClearToAnchorTask anchorString](void)
{
    return objc_getProperty(self, _cmd, 24, 0);
}


void -[CNTChangeHistoryClearToAnchorTask .cxx_destruct](void)
{
    self->_anchorString = nil;
}
