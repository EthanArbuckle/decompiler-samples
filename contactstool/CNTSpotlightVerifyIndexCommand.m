struct CNTSpotlightVerifyIndexCommand {
    id<CNTLogger> _logger; // +0x18
    CNContactStore *_contactStore; // +0x20
};

NSString *+[CNTSpotlightVerifyIndexCommand name](void)
{
    return @"verifyIndex";
}


CNTSpotlightVerifyIndexCommand *+[CNTSpotlightVerifyIndexCommand commandWithArguments:logger:error:](id a1, id a2, id *a3)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *v3 = [NSNumber numberWithBool:YES];
    NSDictionary<NSString *, NSNumber *> *registrationDictionary = @{@"SUDO_OOP": v3};
    [standardUserDefaults registerDefaults:registrationDictionary];
    CNContactStore *v7 = [[CNContactStore alloc] init];
    CNTSpotlightVerifyIndexCommand *v8 = [self alloc];
    return [v8 initWithContactStore:v7 logger:a2];
}


CNTSpotlightVerifyIndexCommand *-[CNTSpotlightVerifyIndexCommand initWithContactStore:logger:](CNContactStore *a1, id<CNTLogger> a2)
{
    Class v1 = [self class];
    CNTSpotlightVerifyIndexCommand *v4 = [super initWithName:[v1 name]];
    if (v4 != nil) {
        v4->_contactStore = a1;
        v4->_logger = a2;
    }
    return v4;
}


id -[CNTSpotlightVerifyIndexCommand run:](id *a1)
{
    id v20;
    CNContactStore *contactStore = [self contactStore];
    id v2 = nil;
    id v3 = [contactStore verifyIndexWithError:&v2];
    if (!CNIsStringEmpty(v3)) {
        NSInteger code = [v2 code];
        id<CNTLogger> logger8 = [self logger];
        NSString *v8 = [NSString stringWithFormat:@"\nindex is %@\n", (code != 1004) ? @"ok" : @"not ok"];
        [logger8 log:v8];
        id<CNTLogger> logger9 = [self logger];
        [logger9 log:@"\nVerification Summary:\n"];
        id<CNTLogger> logger = [self logger];
        [logger log:v3];
        if (code == 1004) {
            id<CNTLogger> logger2 = [self logger];
            [logger2 log:@"\nSpotlight Client State:\n"];
            id<CNTLogger> logger3 = [self logger];
            NSString *v13 = [self runShellCommand:@"searchutil -p C -c clientstate:com.apple.MobileAddressBook:contacts"];
            [logger3 log:v13];
            id<CNTLogger> logger4 = [self logger];
            [logger4 log:@"\nSpotlight Database Info:\n"];
            id<CNTLogger> logger5 = [self logger];
            NSString *v16 = [self runShellCommand:@"search -b com.apple.MobileAddressBook -C C -a _kMDItemExternalID -a _kMDItemOID -a kMDItemAttributeChangeDate -a kMDItemDisplayName -T -l '_kMDItemUserActivityType!=* && kMDItemRole ==\"*\"'"];
            [logger5 log:v16];
            id<CNTLogger> logger6 = [self logger];
            [logger6 log:@"\nSpotlight Journal Info:\n"];
            id<CNTLogger> logger7 = [self logger];
            NSString *v19 = [self runShellCommand:@"searchutil -J /var/mobile/Library/Spotlight/CoreSpotlight/NSFileProtectionCompleteUntilFirstUserAuthentication/index.spotlightV2/activityJournal.1 | egrep '(0xeecc5b2|MobileAddress|pid|time:)'"];
            [logger7 log:v19];
        }
        v20 = [NSNull null];
    } else {
        v20 = [NSString stringWithFormat:@"no results, error: %@", v2];
    }
    return v20;
}


NSString *-[CNTSpotlightVerifyIndexCommand runShellCommand:](NSString *a1)
{
    uint8_t v1[1000001];
    bzero(v1, 1000001);
    const char *UTF8String = [a1 UTF8String];
    FILE *v3 = popen(UTF8String, "r");
    if (!v3) {
        return nil;
    }
    NSString *v4 = (!fread(v1, 1, 1000000, v3)) ? nil : [NSString stringWithUTF8String:(const char *)v1];
    pclose(v3);
    return v4;
}


id<CNTLogger> -[CNTSpotlightVerifyIndexCommand logger](void)
{
    return self->_logger;
}


CNContactStore *-[CNTSpotlightVerifyIndexCommand contactStore](void)
{
    return self->_contactStore;
}


void -[CNTSpotlightVerifyIndexCommand .cxx_destruct](void)
{
    self->_contactStore = nil;
    self->_logger = nil;
}
