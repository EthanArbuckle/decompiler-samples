FBWorkspaceEventQueueLock *-[FBWorkspaceEventQueueLock initWithReason:](id a1)
{
    return [self initWithEventQueue:[FBWorkspaceEventQueue sharedInstance] reason:a1];
}
