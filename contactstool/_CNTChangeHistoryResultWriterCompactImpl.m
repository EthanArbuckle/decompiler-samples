void -[_CNTChangeHistoryResultWriterCompactImpl processTruncatedResult:](id a1)
{
    id<CNTLogger> logger = [self logger];
    [logger log:@"⇤  Full sync required"];
}


bool -[_CNTChangeHistoryResultWriterCompactImpl processDeltaResult:](id a1)
{
    id<CNKeyDescriptor> v0 = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
    NSArray<id<CNKeyDescriptor>> *v2 = @[v0];
    CNContactStore *contactStore = [self contactStore];
    return [a1 enumerateContactChangesWithKeysToFetch:v2 fromContactStore:contactStore error:0 usingBlock:^void(CNChangeHistoryContactChange *arg1, bool *arg2) {
        Class v9 = [self class];
        long changeType = [arg1 changeType];
        id v10 = [v9 verbForChangeType:changeType];
        CNContact *contact = [arg1 contact];
        NSString *v12 = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        id<CNTLogger> logger = [self logger];
        NSString *contactIdentifier = [arg1 contactIdentifier];
        const char *UTF8String = [contactIdentifier UTF8String];
        NSString *v8 = [NSString stringWithFormat:@"%@ %-50s %@", v10, UTF8String, v12];
        [logger log:v8];
    }];
}


NSString *+[_CNTChangeHistoryResultWriterCompactImpl verbForChangeType:](long a1)
{
    NSString *v1;
    switch (a1) {
        case 0:
            v1 = @"+ ";
            break;
        case 1:
            v1 = @"∆ ";
            break;
        case 2:
            v1 = @"- ";
            break;
        case 3:
            v1 = @"++";
            break;
        case 4:
            v1 = @"∆∆";
            break;
        case 5:
            v1 = @"--";
            break;
        default:
            NSNumber *v2 = [NSNumber numberWithInteger:a1];
            v1 = [NSString stringWithFormat:@"Unknown (%@)", v2];
            break;
    }
    return v1;
}
