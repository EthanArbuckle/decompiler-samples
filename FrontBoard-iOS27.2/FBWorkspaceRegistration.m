struct FBWorkspaceRegistration {
    bool _acceptsClientScenes; // +0x8
    NSString *_identifier; // +0x10
};

id +[FBWorkspaceRegistration registrationWithIdentifier:options:](id a1, id a2)
{
    id v3;
    id v6;
    Class v1 = [NSString class];
    if (v1) {
        v3 = ([a1 isKindOfClass:v1]) ? a1 : nil;
    } else {
        v3 = nil;
    }
    Class v4 = [NSDictionary class];
    if (v4) {
        v6 = ([a2 isKindOfClass:v4]) ? a2 : nil;
    } else {
        v6 = nil;
    }
    if (!v3) {
        return nil;
    }
    id v7 = [self new];
    if (v7 != nil) {
        v7->field_16 = [v3 copy];
        v7->field_8 = [v6 bs_boolForKey:@"AcceptClientScenes"];
    }
    return v7;
}


id -[FBWorkspaceRegistration description](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendObject:self->_identifier withName:0];
    [v0 appendBool:self->_acceptsClientScenes withName:@"acceptsClientScenes" ifEqualTo:1];
    return [v0 build];
}


void -[FBWorkspaceRegistration .cxx_destruct](void)
{
    self->_identifier = nil;
}


bool -[FBWorkspaceRegistration acceptsClientScenes](void)
{
    if (!self) {
        return false;
    } else {
        return self->_acceptsClientScenes;
    }
}
