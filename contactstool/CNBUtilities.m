NSMutableString *+[CNBUtilities stringForDictionary:](id a1)
{
    NSMutableString *string = [NSMutableString string];
    [a1 enumerateKeysAndObjectsWithOptions:0 usingBlock:^void(id arg1, id arg2, bool *arg3) {
        if ([string length] != 0) {
            [string appendString:@","];
        }
        [string appendString:arg1];
        [string appendString:@":"];
        [string appendString:arg2];
    }];
    return string;
}
