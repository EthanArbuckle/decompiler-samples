int -[FBWorkspaceEventQueue _shouldProcessEvent:enqueuedDuringExecutionOfEvent:](id a1, id a2)
{
    int v2;
    if (!a2) {
        return 1;
    }
    NSString *name = [a2 name];
    NSString *name2 = [a1 name];
    if (![name isEqualToString:name2]) {
        v2 = 1;
    } else {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            NSString *name3 = [a2 name];
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Event \"%{public}@\" queued an identically named event while still executing. Dropping it.", name3);
        }
        v2 = 0;
    }
    return v2;
}


void -[FBWorkspaceEventQueue executeOrAppendEvent:](id a1)
{
    NSArray *v1 = @[a1];
    [self executeOrInsertEvents:v1 atPosition:1];
}


id +[FBWorkspaceEventQueue sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        sharedInstance.__instance = [[FBWorkspaceEventQueue alloc] initWithName:@"FBWorkspaceEventQueue" onQueue:dispatch_get_main_queue()];
    });
    return sharedInstance.__instance;
}


void -[FBWorkspaceEventQueue _noteWillPendEvents:atPosition:](id a1, long a2)
{
    id v0 = a1;
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        long count = [v0 count];
        if (count == 1) {
            v0 = [v0 lastObject];
        }
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "Pending: %{public}@; queue position: %@", v0, (a2 == 1) ? @"back" : @"front");
    }
}


void -[FBWorkspaceEventQueue _noteQueueDidLock](void)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "Queue locked.");
    }
}


void -[FBWorkspaceEventQueue _noteWillExecuteEvent:](id a1)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "Executing: %{public}@", a1);
    }
}


void -[FBWorkspaceEventQueue _noteQueueDidUnlock](void)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "Queue unlocked.");
    }
}


void -[FBWorkspaceEventQueue executeOrPrependEvent:](id a1)
{
    NSArray *v1 = @[a1];
    [self executeOrPrependEvents:v1];
}


long -[FBWorkspaceEventQueue executeOrPrependEvents:](long a1)
{
    return [self executeOrInsertEvents:a1 atPosition:0];
}


void -[FBWorkspaceEventQueue _noteWillCancelEventsWithName:count:](id a1, long a2)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "Removing %lu event(s) named \"%{public}@\"", a2, a1);
    }
}
