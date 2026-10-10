struct CNTSpotlightReindexCommand {
    id<CNTLogger> _logger; // +0x18
    CNContactStore *_contactStore; // +0x20
};

NSString *+[CNTSpotlightReindexCommand name](void)
{
    return @"reindex";
}


CNTSpotlightReindexCommand *+[CNTSpotlightReindexCommand commandWithArguments:logger:error:](id a1, id a2, id *a3)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *v3 = [NSNumber numberWithBool:YES];
    NSDictionary<NSString *, NSNumber *> *registrationDictionary = @{@"SUDO_OOP": v3};
    [standardUserDefaults registerDefaults:registrationDictionary];
    CNContactStore *v7 = [[CNContactStore alloc] init];
    CNTSpotlightReindexCommand *v8 = [self alloc];
    return [v8 initWithContactStore:v7 logger:a2];
}


CNTSpotlightReindexCommand *-[CNTSpotlightReindexCommand initWithContactStore:logger:](CNContactStore *a1, id<CNTLogger> a2)
{
    Class v1 = [self class];
    CNTSpotlightReindexCommand *v4 = [super initWithName:[v1 name]];
    if (v4 != nil) {
        v4->_contactStore = a1;
        v4->_logger = a2;
    }
    return v4;
}


NSNull *-[CNTSpotlightReindexCommand run:](id *a1)
{
    CNContactStore *contactStore = [self contactStore];
    [contactStore reindexSearchableItemsWithIdentifiers:0];
    id<CNTLogger> logger = [self logger];
    [logger log:@"Reindexed all contacts"];
    return [NSNull null];
}


id<CNTLogger> -[CNTSpotlightReindexCommand logger](void)
{
    return self->_logger;
}


CNContactStore *-[CNTSpotlightReindexCommand contactStore](void)
{
    return self->_contactStore;
}


void -[CNTSpotlightReindexCommand .cxx_destruct](void)
{
    self->_contactStore = nil;
    self->_logger = nil;
}
