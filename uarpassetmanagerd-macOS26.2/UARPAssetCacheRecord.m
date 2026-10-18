struct UARPAssetCacheRecord {
    UARPAssetVersionBase *_assetVersion; // +0x8
    NSURL *_assetURL; // +0x10
    NSArray *_deploymentRules; // +0x18
};

bool +[UARPAssetCacheRecord supportsSecureCoding](void)
{
    return true;
}


UARPAssetCacheRecord *-[UARPAssetCacheRecord initWithAssetVersion:assetURL:deploymentRules:](id a1, id a2, id a3)
{
    UARPAssetCacheRecord *v0 = [super init];
    if (v0 != nil) {
        v0->_assetVersion = [a1 copy];
        v0->_assetURL = [a2 copy];
        v0->_deploymentRules = [a3 copy];
    }
    return v0;
}


UARPAssetCacheRecord *-[UARPAssetCacheRecord initWithCoder:](NSCoder *a1)
{
    UARPAssetCacheRecord *v0 = [super init];
    if (v0 != nil) {
        v0->_assetVersion = [a1 decodeObjectOfClass:[UARPAssetVersionBase class] forKey:@"assetVersion"];
        v0->_assetURL = [a1 decodeObjectOfClass:[NSURL class] forKey:@"assetURL"];
        NSArray *v14 = @[[NSArray class], [NSString class], [NSNumber class], [NSDate class], [NSDictionary class]];
        NSSet *classes = [NSSet setWithArray:v14];
        v0->_deploymentRules = [a1 decodeObjectOfClasses:classes forKey:@"deploymentRules"];
    }
    return v0;
}


void -[UARPAssetCacheRecord encodeWithCoder:](NSCoder *a1)
{
    [a1 encodeObject:self->_assetVersion forKey:@"assetVersion"];
    [a1 encodeObject:self->_assetURL forKey:@"assetURL"];
    [a1 encodeObject:self->_deploymentRules forKey:@"deploymentRules"];
}


UARPAssetCacheRecord *-[UARPAssetCacheRecord copyWithZone:](struct _NSZone *a1)
{
    return [[UARPAssetCacheRecord alloc] initWithAssetVersion:self->_assetVersion assetURL:self->_assetURL deploymentRules:self->_deploymentRules];
}


bool -[UARPAssetCacheRecord isEqual:](id a1)
{
    bool v12;
    Class v2 = [UARPAssetCacheRecord class];
    if (![a1 isKindOfClass:v2]) {
        return false;
    }
    if (a1 != self) {
        UARPAssetCacheRecord *v3 = a1;
        UARPAssetVersionBase *assetVersion = [v3 assetVersion];
        BOOL v5 = [self->_assetVersion isEqual:assetVersion];
        bool v8 = false;
        if (v5 == 1) {
            NSURL *assetURL = [v3 assetURL];
            if ([self->_assetURL isEqual:assetURL] == 1) {
                NSArray *deploymentRules = [v3 deploymentRules];
                v8 = nullableObjectsAreEqual(self->_deploymentRules, deploymentRules) == 1;
            }
        }
        v12 = v8;
    } else {
        v12 = true;
    }
    return v12;
}


NSUInteger -[UARPAssetCacheRecord hash](void)
{
    NSString *description = [self description];
    return [description hash];
}


NSString *-[UARPAssetCacheRecord description](void)
{
    NSString *v0 = NSStringFromClass([self class]);
    id assetVersion = [self->_assetVersion assetVersion];
    NSString *path = [self->_assetURL path];
    return [NSString stringWithFormat:@"<%@: %@ %@>", v0, assetVersion, path];
}


UARPAssetVersionBase *-[UARPAssetCacheRecord assetVersion](void)
{
    return objc_getProperty(self, _cmd, 8, 1);
}


NSURL *-[UARPAssetCacheRecord assetURL](void)
{
    return objc_getProperty(self, _cmd, 16, 1);
}


NSArray *-[UARPAssetCacheRecord deploymentRules](void)
{
    return objc_getProperty(self, _cmd, 24, 1);
}


void -[UARPAssetCacheRecord .cxx_destruct](void)
{
    self->_deploymentRules = nil;
    self->_assetURL = nil;
    self->_assetVersion = nil;
}
