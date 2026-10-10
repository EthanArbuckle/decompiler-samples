NSString *+[CNBFetchEverything name](void)
{
    return @"fetchAll";
}


NSNull *-[CNBFetchEverything run:](NSError **a1)
{
    NSNull *v19;
    id<CNBImplementation> implementation = [self implementation];
    id v1 = [implementation fetchEverybodyConsideringProperties:3];
    for (id v14 in v1) {
        id<CNBImplementation> implementation3 = [self implementation];
        [implementation3 properties:1 forContact:v14];
    }
    for (id v15 in v1) {
        id<CNBImplementation> implementation2 = [self implementation];
        [implementation2 properties:2 forContact:v15];
    }
    if (![v1 count]) {
        NSDictionary *v16 = @{NSLocalizedFailureReasonErrorKey: @"Did not get any contact!"};
        NSError *v17 = [NSError errorWithDomain:@"CNBErrorDomain" code:1 userInfo:v16];
        v19 = nil;
        if (a1) {
            *(a1) = v17;
        }
    } else {
        v19 = [NSNull null];
    }
    return v19;
}
