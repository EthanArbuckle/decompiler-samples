struct CNTContactsTool {
    CNTCommandFactory *_factory; // +0x8
    id<CNTLogger> _logger; // +0x10
};

CNTContactsTool *-[CNTContactsTool init](void)
{
    return [self initWithCommandFactory:[[CNTCommandFactory alloc] init] logger:[[_CNTPrintingLogger alloc] init]];
}


CNTContactsTool *-[CNTContactsTool initWithCommandFactory:logger:](CNTCommandFactory *a1, id<CNTLogger> a2)
{
    CNTContactsTool *v1 = [super init];
    if (v1 != nil) {
        v1->_factory = a1;
        v1->_logger = a2;
    }
    return v1;
}


NSInteger -[CNTContactsTool mainWithArguments:](id a1)
{
    id v0 = [a1 _cn_skip:1];
    CNTCommandFactory *factory = [self factory];
    id<CNTLogger> logger2 = [self logger];
    CNTLogTask *v3 = [CNTCommandFactory commandForArguments:v0 factory:factory logger:logger2];
    int (^v4)(id) = CNIsStringEmpty;
    id name = [v3 name];
    int v6 = v4(name);
    if ((v6 & 1) == 0) {
        id<CNTLogger> logger3 = [self logger];
        id name2 = [v3 name];
        NSString *v9 = [NSString stringWithFormat:@"Performing %@…", name2];
        [logger3 log:v9];
    }
    id v10 = nil;
    NSNull *v11 = [v3 run:&v10];
    NSNull *null = [NSNull null];
    if (v11 == null) {
        return 0;
    }
    id<CNTLogger> logger = [self logger];
    NSString *localizedDescription = [v10 localizedDescription];
    [logger log:localizedDescription];
    return [v10 code];
}


CNTCommandFactory *-[CNTContactsTool factory](void)
{
    return self->_factory;
}


id<CNTLogger> -[CNTContactsTool logger](void)
{
    return self->_logger;
}


void -[CNTContactsTool .cxx_destruct](void)
{
    self->_logger = nil;
    self->_factory = nil;
}
