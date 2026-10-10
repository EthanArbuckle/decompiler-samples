struct CNTSpotlightCommand {
    NSString *_commandName; // +0x18
    id<CNTLogger> _logger; // +0x20
};

NSString *+[CNTSpotlightCommand name](void)
{
    return @"spotlight";
}


NSArray *+[CNTSpotlightCommand supportedSubCommands](void)
{
    return @[[CNTSpotlightVerifyIndexCommand class], [CNTSpotlightReindexCommand class]];
}


id +[CNTSpotlightCommand subCommandClassesByName](void)
{
    NSArray *supportedSubCommands = [self supportedSubCommands];
    return [supportedSubCommands _cn_indexBy:qword_10001a6b8];
}


id +[CNTSpotlightCommand subCommandNames](void)
{
    NSArray *supportedSubCommands = [self supportedSubCommands];
    return [supportedSubCommands _cn_map:qword_10001a6b8];
}


NSString *+[CNTSpotlightCommand usage](void)
{
    id subCommandNames = [self subCommandNames];
    NSString *v1 = [subCommandNames componentsJoinedByString:@"|"];
    NSString *name = [self name];
    return [NSString stringWithFormat:@"%@ <%@>", name, v1];
}


id +[CNTSpotlightCommand commandWithArguments:logger:error:](id a1, id a2, NSError **a3)
{
    id v8;
    if (![a1 count]) {
        NSDictionary *v5 = @{NSLocalizedFailureReasonErrorKey: @"Not enough arguments"};
        NSError *v6 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v5];
        v8 = nil;
        if (a3) {
            *(a3) = v6;
        }
    } else {
        id v9 = [a1 objectAtIndexedSubscript:0];
        id subCommandNames = [self subCommandNames];
        if (![subCommandNames containsObject:v9]) {
            NSString *v12 = [NSString stringWithFormat:@"Unrecognized sub command %@", v9];
            NSDictionary *v13 = @{NSLocalizedFailureReasonErrorKey: v12};
            NSError *v14 = [NSError errorWithDomain:@"CNTErrorDomain" code:1 userInfo:v13];
            if (a3 != 0) {
                *(a3) = v14;
            }
            v8 = nil;
        } else {
            id subCommandClassesByName = [self subCommandClassesByName];
            id v17 = [subCommandClassesByName objectForKeyedSubscript:v9];
            id v18 = [a1 _cn_skip:1];
            v8 = [v17 commandWithArguments:v18 logger:a2 error:a3];
        }
    }
    return v8;
}


NSString *-[CNTSpotlightCommand commandName](void)
{
    return self->_commandName;
}


id<CNTLogger> -[CNTSpotlightCommand logger](void)
{
    return self->_logger;
}


void -[CNTSpotlightCommand .cxx_destruct](void)
{
    self->_logger = nil;
    self->_commandName = nil;
}
