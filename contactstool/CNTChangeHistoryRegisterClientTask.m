NSString *+[CNTChangeHistoryRegisterClientTask taskName](void)
{
    return @"com.apple.contacts.tool.history.show";
}


NSNull *-[CNTChangeHistoryRegisterClientTask onRun:](id *a1)
{
    NSNull *v6;
    CNContactStore *contactStore = [self contactStore];
    NSString *clientIdentifier = [self clientIdentifier];
    id v3 = nil;
    long v4 = [contactStore registerChangeHistoryClientIdentifier:clientIdentifier error:&v3];
    if ((v4 & 1) == 0) {
        v6 = nil;
        if (a1) {
            *(a1) = v3;
        }
    } else {
        id<CNTLogger> logger = [self logger];
        NSString *clientIdentifier2 = [self clientIdentifier];
        NSString *v9 = [NSString stringWithFormat:@"Registered client “%@” for change history.", clientIdentifier2];
        [logger log:v9];
        v6 = [NSNull null];
    }
    return v6;
}
