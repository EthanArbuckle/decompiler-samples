struct FBSystemServiceOpenApplicationRequest {
    NSString *_bundleIdentifier; // +0x8
    FBSOpenApplicationOptions *_options; // +0x10
    FBProcess *_clientProcess; // +0x18
    bool _trusted; // +0x20
};

void -[FBSystemServiceOpenApplicationRequest .cxx_destruct](void)
{
    self->_clientProcess = nil;
    self->_options = nil;
    self->_bundleIdentifier = nil;
}


FBSystemServiceOpenApplicationRequest *-[FBSystemServiceOpenApplicationRequest initWithBundleId:](NSString *a1)
{
    FBSystemServiceOpenApplicationRequest *v2 = [super init];
    if (v2 != nil) {
        [v2 setBundleIdentifier:a1];
    }
    return v2;
}


FBSOpenApplicationOptions *-[FBSystemServiceOpenApplicationRequest options](void)
{
    return self->_options;
}


long -[FBSystemServiceOpenApplicationRequest setOptions:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 16);
}


void -[FBSystemServiceOpenApplicationRequest setTrusted:](bool a1)
{
    self->_trusted = a1;
}


void -[FBSystemServiceOpenApplicationRequest setClientProcess:](FBProcess *a1)
{
    self->_clientProcess = a1;
}


id -[FBSystemServiceOpenApplicationRequest description](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendBool:self->_trusted withName:@"trusted"];
    [v0 appendObject:self->_bundleIdentifier withName:@"bundleID"];
    NSURL *url = [self->_options url];
    NSString *scheme = [url scheme];
    [v0 appendObject:scheme withName:@"urlScheme" skipIfNil:1];
    id v3 = FBSProcessPrettyDescription(self->_clientProcess);
    [v0 appendObject:v3 withName:@"client"];
    return [v0 build];
}


NSString *-[FBSystemServiceOpenApplicationRequest bundleIdentifier](void)
{
    return self->_bundleIdentifier;
}


FBProcess *-[FBSystemServiceOpenApplicationRequest clientProcess](void)
{
    return self->_clientProcess;
}


long -[FBSystemServiceOpenApplicationRequest setBundleIdentifier:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 8);
}


bool -[FBSystemServiceOpenApplicationRequest isTrusted](void)
{
    return self->_trusted;
}
