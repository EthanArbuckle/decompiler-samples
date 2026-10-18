struct UARPAssetSubscriptionMobileAsset {
    bool _softwareUpdateAsset; // +0x8
    bool _internalAsset; // +0x9
    NSString *_hwFusing; // +0x10
    NSURL *_assetURL; // +0x18
    NSString *_assetAudience; // +0x20
};

bool +[UARPAssetSubscriptionMobileAsset supportsSecureCoding](void)
{
    return true;
}


UARPAssetSubscriptionMobileAsset *-[UARPAssetSubscriptionMobileAsset initWithAppleModelNumber:hwFusing:domain:](id a1, id a2, id a3)
{
    UARPAssetSubscriptionMobileAsset *v0 = [super initWithIdentifier:a1 domain:a3];
    if (v0 != nil) {
        v0->_hwFusing = [a2 copy];
    }
    return v0;
}


UARPAssetSubscriptionMobileAsset *-[UARPAssetSubscriptionMobileAsset initWithCoder:](id a1)
{
    UARPAssetSubscriptionMobileAsset *v0 = [super initWithCoder:a1];
    if (v0 != nil) {
        v0->_hwFusing = [a1 decodeObjectOfClass:[NSString class] forKey:@"hwFusing"];
        v0->_assetURL = [a1 decodeObjectOfClass:[NSURL class] forKey:@"assetURL"];
        v0->_assetAudience = [a1 decodeObjectOfClass:[NSString class] forKey:@"assetAudience"];
        v0->_internalAsset = [a1 decodeBoolForKey:@"internalAsset"];
        v0->_softwareUpdateAsset = [a1 decodeBoolForKey:@"suAsset"];
    }
    return v0;
}


void -[UARPAssetSubscriptionMobileAsset encodeWithCoder:](id a1)
{
    [super encodeWithCoder:a1];
    [a1 encodeObject:self->_hwFusing forKey:@"hwFusing"];
    [a1 encodeObject:self->_assetURL forKey:@"assetURL"];
    [a1 encodeObject:self->_assetAudience forKey:@"assetAudience"];
    [a1 encodeBool:self->_internalAsset forKey:@"internalAsset"];
    [a1 encodeBool:self->_softwareUpdateAsset forKey:@"suAsset"];
}


UARPAssetSubscriptionMobileAsset *-[UARPAssetSubscriptionMobileAsset copyWithZone:](struct _NSZone *a1)
{
    UARPAssetSubscriptionMobileAsset *v0 = [UARPAssetSubscriptionMobileAsset alloc];
    NSString *identifier = [self identifier];
    NSString *hwFusing = [self hwFusing];
    UARPAssetSubscriptionMobileAsset *v6 = [v0 initWithAppleModelNumber:identifier hwFusing:hwFusing domain:[self domain]];
    NSURL *assetURL = [self assetURL];
    [v6 setAssetURL:assetURL];
    NSString *assetAudience = [self assetAudience];
    [v6 setAssetAudience:assetAudience];
    bool internalAsset = [self internalAsset];
    [v6 setInternalAsset:internalAsset];
    bool softwareUpdateAsset = [self softwareUpdateAsset];
    [v6 setSoftwareUpdateAsset:softwareUpdateAsset];
    return v6;
}


NSString *-[UARPAssetSubscriptionMobileAsset appleModelNumber](void)
{
    return [self identifier];
}


bool -[UARPAssetSubscriptionMobileAsset isEqual:](id a1)
{
    bool v18;
    Class v2 = [UARPAssetSubscriptionMobileAsset class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        UARPAssetSubscriptionMobileAsset *v3 = a1;
        bool v5 = [super isEqual:a1];
        bool v9 = false;
        if (v5 == 1) {
            NSString *hwFusing = [v3 hwFusing];
            if (nullableObjectsAreEqual(self->_hwFusing, hwFusing) == 1) {
                NSURL *assetURL = [v3 assetURL];
                if (nullableObjectsAreEqual(self->_assetURL, assetURL) == 1) {
                    NSString *assetAudience = [v3 assetAudience];
                    if (nullableObjectsAreEqual(self->_assetAudience, assetAudience) == 1) {
                        bool softwareUpdateAsset = [v3 softwareUpdateAsset];
                        if (self->_softwareUpdateAsset == softwareUpdateAsset) {
                            bool internalAsset = [v3 internalAsset];
                            v9 = self->_internalAsset == internalAsset;
                        }
                    }
                }
            }
        }
        v18 = v9;
    } else {
        v18 = true;
    }
    return v18;
}


bool -[UARPAssetSubscriptionMobileAsset isEqualForAnyDomain:](id a1)
{
    bool v18;
    Class v2 = [UARPAssetSubscriptionMobileAsset class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        UARPAssetSubscriptionMobileAsset *v3 = a1;
        bool v5 = [super isEqualForAnyDomain:a1];
        bool v9 = false;
        if (v5 == 1) {
            NSString *hwFusing = [v3 hwFusing];
            if (nullableObjectsAreEqual(self->_hwFusing, hwFusing) == 1) {
                NSURL *assetURL = [v3 assetURL];
                if (nullableObjectsAreEqual(self->_assetURL, assetURL) == 1) {
                    NSString *assetAudience = [v3 assetAudience];
                    if (nullableObjectsAreEqual(self->_assetAudience, assetAudience) == 1) {
                        bool softwareUpdateAsset = [v3 softwareUpdateAsset];
                        if (self->_softwareUpdateAsset == softwareUpdateAsset) {
                            bool internalAsset = [v3 internalAsset];
                            v9 = self->_internalAsset == internalAsset;
                        }
                    }
                }
            }
        }
        v18 = v9;
    } else {
        v18 = true;
    }
    return v18;
}


NSUInteger -[UARPAssetSubscriptionMobileAsset hash](void)
{
    NSString *description = [self description];
    return [description hash];
}


NSString *-[UARPAssetSubscriptionMobileAsset description](void)
{
    NSString *v8;
    NSString *v0 = NSStringFromClass([self class]);
    NSString *identifier = [self identifier];
    NSString *hwFusing = [self hwFusing];
    if (![self assetAudience]) {
        NSURL *assetURL = [self assetURL];
        v8 = [assetURL absoluteString];
    } else {
        v8 = [self assetAudience];
    }
    bool internalAsset = [self internalAsset];
    bool softwareUpdateAsset = [self softwareUpdateAsset];
    NSString *domain = [self domain];
    return [NSString stringWithFormat:@"<%@: modelNumber=%@, hwFusing=%@ assetLocation=%@ internal/su=%u/%u domain=%@>", v0, identifier, hwFusing, v8, internalAsset, softwareUpdateAsset, domain];
}


NSString *-[UARPAssetSubscriptionMobileAsset hwFusing](void)
{
    return objc_getProperty(self, _cmd, OBJC_IVAR_$_UARPAssetSubscriptionMobileAsset._hwFusing, 1);
}


NSURL *-[UARPAssetSubscriptionMobileAsset assetURL](void)
{
    return objc_getProperty(self, _cmd, OBJC_IVAR_$_UARPAssetSubscriptionMobileAsset._assetURL, 1);
}


void -[UARPAssetSubscriptionMobileAsset setAssetURL:](NSURL *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, OBJC_IVAR_$_UARPAssetSubscriptionMobileAsset._assetURL);
}


NSString *-[UARPAssetSubscriptionMobileAsset assetAudience](void)
{
    return objc_getProperty(self, _cmd, OBJC_IVAR_$_UARPAssetSubscriptionMobileAsset._assetAudience, 1);
}


void -[UARPAssetSubscriptionMobileAsset setAssetAudience:](NSString *a1)
{
    objc_setProperty_atomic_copy(self, _cmd, a1, OBJC_IVAR_$_UARPAssetSubscriptionMobileAsset._assetAudience);
}


bool -[UARPAssetSubscriptionMobileAsset softwareUpdateAsset](void)
{
    return self->_softwareUpdateAsset;
}


void -[UARPAssetSubscriptionMobileAsset setSoftwareUpdateAsset:](bool a1)
{
    self->_softwareUpdateAsset = a1;
}


bool -[UARPAssetSubscriptionMobileAsset internalAsset](void)
{
    return self->_internalAsset;
}


void -[UARPAssetSubscriptionMobileAsset setInternalAsset:](bool a1)
{
    self->_internalAsset = a1;
}


void -[UARPAssetSubscriptionMobileAsset .cxx_destruct](void)
{
    self->_assetAudience = nil;
    self->_assetURL = nil;
    self->_hwFusing = nil;
}
