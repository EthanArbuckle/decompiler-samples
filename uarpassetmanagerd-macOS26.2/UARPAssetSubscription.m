struct UARPAssetSubscription {
    NSString *_identifier; // +0x8
    NSString *_domain; // +0x10
};

bool +[UARPAssetSubscription supportsSecureCoding](void)
{
    return true;
}


UARPAssetSubscription *-[UARPAssetSubscription initWithIdentifier:domain:](id a1, id a2)
{
    UARPAssetSubscription *v0 = [super init];
    if (v0 != nil) {
        v0->_identifier = [a1 copy];
        v0->_domain = [a2 copy];
    }
    return v0;
}


void -[UARPAssetSubscription encodeWithCoder:](NSCoder *a1)
{
    [a1 encodeObject:self->_identifier forKey:@"identifier"];
    [a1 encodeObject:self->_domain forKey:@"domain"];
}


UARPAssetSubscription *-[UARPAssetSubscription initWithCoder:](NSCoder *a1)
{
    UARPAssetSubscription *v0 = [super init];
    if (v0 != nil) {
        v0->_identifier = [a1 decodeObjectOfClass:[NSString class] forKey:@"identifier"];
        v0->_domain = [a1 decodeObjectOfClass:[NSString class] forKey:@"domain"];
    }
    return v0;
}


UARPAssetSubscription *-[UARPAssetSubscription copyWithZone:](struct _NSZone *a1)
{
    return [[UARPAssetSubscription alloc] initWithIdentifier:self->_identifier domain:self->_domain];
}


bool -[UARPAssetSubscription isEqual:](id a1)
{
    bool v9;
    Class v2 = [UARPAssetSubscription class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        UARPAssetSubscription *v3 = a1;
        NSString *identifier = [v3 identifier];
        BOOL v5 = [self->_identifier isEqualToString:identifier];
        bool v7 = false;
        if (v5 == 1) {
            NSString *domain = [v3 domain];
            v7 = [self->_domain isEqualToString:domain] == 1;
        }
        v9 = v7;
    } else {
        v9 = true;
    }
    return v9;
}


bool -[UARPAssetSubscription isEqualForAnyDomain:](id a1)
{
    bool v8;
    Class v2 = [UARPAssetSubscription class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        UARPAssetSubscription *v5 = a1;
        NSString *identifier = [v5 identifier];
        v8 = [self->_identifier isEqualToString:identifier] == 1;
    } else {
        v8 = true;
    }
    return v8;
}


NSUInteger -[UARPAssetSubscription hash](void)
{
    NSString *description = [self description];
    return [description hash];
}


NSString *-[UARPAssetSubscription description](void)
{
    NSString *v0 = NSStringFromClass([self class]);
    NSString *identifier = [self identifier];
    NSString *domain = [self domain];
    return [NSString stringWithFormat:@"<%@: id=%@ domain=%@>", v0, identifier, domain];
}


NSString *-[UARPAssetSubscription identifier](void)
{
    return objc_getProperty(self, _cmd, 8, 1);
}


NSString *-[UARPAssetSubscription domain](void)
{
    return objc_getProperty(self, _cmd, 16, 1);
}


void -[UARPAssetSubscription .cxx_destruct](void)
{
    self->_domain = nil;
    self->_identifier = nil;
}
