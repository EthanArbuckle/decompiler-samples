struct _FBSceneClientProcess {
    RBSProcessHandle *_handle; // +0x8
};

void -[_FBSceneClientProcess .cxx_destruct](void)
{
    self->_handle = nil;
}


_FBSceneClientProcess *-[_FBSceneClientProcess _initWithHandle:](RBSProcessHandle *a1)
{
    _FBSceneClientProcess *v1 = [super init];
    if (v1 != nil) {
        v1->_handle = a1;
    }
    return v1;
}


RBSProcessHandle *-[_FBSceneClientProcess handle](void)
{
    return self->_handle;
}


NSString *-[_FBSceneClientProcess description](void)
{
    return [self->_handle description];
}
