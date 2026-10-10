NSString *+[CNBSearchByName name](void)
{
    return @"searchByName";
}


id -[CNBSearchByName run:](NSError **a1)
{
    NSArray<NSString *> *v2 = @[@"cynthia", @"johnny", @"lucinda", @"lucy", @"jon", @"pelzl", @"jack", @"johnnie", @"ivan", @"jonathan"];
    __block id v3 = nil;
    [v2 _cn_each:^void(NSString *arg1) {
        id<CNBImplementation> implementation = [self implementation];
        id v18 = [implementation fetchPeopleMatchingName:arg1 consideringProperties:31];
        for (id v14 in v18) {
            id<CNBImplementation> implementation2 = [self implementation];
            id v15 = [implementation2 properties:31 forContact:v14];
            if (v15 != nil) {
                NSNull *null = [NSNull null];
                v3 = null;
            }
        }
    }];
    if (!v3) {
        NSDictionary *v9 = @{NSLocalizedFailureReasonErrorKey: @"Did not get any contact!"};
        NSError *v10 = [NSError errorWithDomain:@"CNBErrorDomain" code:1 userInfo:v9];
        if (a1 != 0) {
            *(a1) = v10;
        }
    }
    return v3;
}
