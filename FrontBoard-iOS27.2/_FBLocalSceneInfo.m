struct _FBLocalSceneInfo {
    bool hasHandledSceneCreate; // +0x8
    bool hasSentFBSWorkspaceDelegateSceneCreate; // +0x9
    FBSScene *_scene; // +0x10
    FBSSceneTransitionContext *pendingTransitionContext; // +0x18
};

_FBLocalSceneInfo *-[_FBLocalSceneInfo initWithScene:](FBSScene *a1)
{
    _FBLocalSceneInfo *self;
    if (self != nil) {
        if (!a1) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(initWithScene:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBLocalSynchronousSceneClientProvider.m", 43, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        self = [super init];
        if (self != nil) {
            self->_scene = a1;
        }
    }
    return self;
}


void -[_FBLocalSceneInfo setPendingTransitionContext:](FBSSceneTransitionContext *a1)
{
    if (!self) {
        return;
    }
    self->pendingTransitionContext = a1;
}


void -[_FBLocalSceneInfo .cxx_destruct](void)
{
    self->pendingTransitionContext = nil;
    self->_scene = nil;
}
