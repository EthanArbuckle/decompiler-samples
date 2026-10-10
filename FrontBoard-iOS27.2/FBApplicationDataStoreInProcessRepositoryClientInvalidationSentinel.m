FBApplicationDataStoreInProcessRepositoryClientInvalidationSentinel *+[FBApplicationDataStoreInProcessRepositoryClientInvalidationSentinel sentinel](void)
{
    dispatch_once(&sentinel.onceToken, ^void(void) {
        sentinel.sentinel = [[self alloc] init];
    });
    return sentinel.sentinel;
}
