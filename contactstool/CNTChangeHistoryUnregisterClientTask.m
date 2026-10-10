NSString *+[CNTChangeHistoryUnregisterClientTask taskName](void)
{
    return @"com.apple.contacts.tool.history.show";
}


NSNull *-[CNTChangeHistoryUnregisterClientTask onRun:](id *a1)
{
    NSNull *v6;
    CNContactStore *contactStore = [self contactStore];
    NSString *clientIdentifier = [self clientIdentifier];
    id v3 = nil;
    long v4 = [contactStore unregisterChangeHistoryClientIdentifier:clientIdentifier error:&v3];
    if ((v4 & 1) == 0) {
        v6 = nil;
        if (a1) {
            *(a1) = v3;
        }
    } else {
        id<CNTLogger> logger2 = [self logger];
        NSString *clientIdentifier2 = [self clientIdentifier];
        NSString *v9 = [NSString stringWithFormat:@"Unregistered client “%@” for change history.", clientIdentifier2];
        [logger2 log:v9];
        id<CNTLogger> logger = [self logger];
        [logger log:@"You should consider re-registering it before you’re finished, or changes may be lost."];
        v6 = [NSNull null];
    }
    return v6;
}
