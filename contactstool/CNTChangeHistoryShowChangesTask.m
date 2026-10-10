NSString *+[CNTChangeHistoryShowChangesTask taskName](void)
{
    return @"com.apple.contacts.tool.history.show";
}


NSNull *-[CNTChangeHistoryShowChangesTask onRun:](id *a1)
{
    NSNull *v8;
    CNChangeHistoryFetchRequest *v3 = [[CNChangeHistoryFetchRequest alloc] initWithClientIdentifier:[self clientIdentifier]];
    CNContactStore *contactStore2 = [self contactStore];
    id v5 = nil;
    id v6 = [contactStore2 changeHistoryWithFetchRequest:v3 error:&v5];
    if (!v6) {
        v8 = nil;
        if (a1) {
            *(a1) = v5;
        }
    } else {
        id<CNTLogger> logger = [self logger];
        CNContactStore *contactStore = [self contactStore];
        _CNTChangeHistoryResultWriterCompactImpl *v11 = [CNTChangeHistoryResultWriter compactWriterWithLogger:logger contactStore:contactStore];
        [v11 logResult:v6];
        id latestChangeAnchor = [v6 latestChangeAnchor];
        [self logAnchor:latestChangeAnchor];
        v8 = [NSNull null];
    }
    return v8;
}


void -[CNTChangeHistoryShowChangesTask logAnchor:](id a1)
{
    Class v1 = [self class];
    NSError *v2 = nil;
    id v3 = [v1 stringWithChangeAnchor:a1 error:&v2];
    id<CNTLogger> logger = [self logger];
    [logger log:@""];
    id<CNTLogger> logger2 = [self logger];
    NSString *v6 = [NSString stringWithFormat:@"Anchor: %@", v3];
    [logger2 log:v6];
}


NSString *+[CNTChangeHistoryShowChangesTask stringWithChangeAnchor:error:](id a1, NSError **a2)
{
    NSString *v9;
    id obj = nil;
    id v2 = [CNArchiver encodeObject:a1 error:&obj];
    if (!v2) {
        NSMutableDictionary *v6 = [[NSMutableDictionary alloc] init];
        [v6 setObject:obj forKeyedSubscript:NSUnderlyingErrorKey];
        NSMutableDictionary *v7 = (![v6 count]) ? nil : v6;
        NSError *v8 = [NSError errorWithDomain:@"CNTErrorDomain" code:5 userInfo:v7];
        if (a2 != 0) {
            *(a2) = v8;
        }
        v9 = nil;
    } else {
        v9 = [v2 base64EncodedStringWithOptions:0];
    }
    return v9;
}
