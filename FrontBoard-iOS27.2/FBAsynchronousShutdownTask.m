struct FBAsynchronousShutdownTask {
    NSString *_name; // +0x8
    double _interval; // +0x10
};

static NSMutableArray *__lock_tasks;
static dispatch_group_t __lock_group;
static long __lock;

void +[FBAsynchronousShutdownTask waitForTasks](void)
{
    os_unfair_lock_lock(&__lock);
    dispatch_group_t v0 = __lock_group;
    NSUInteger count = [__lock_tasks count];
    double v6 = 0.0;
    for (id v15 in __lock_tasks) {
        long v9 = v15->field_16;
        v6 = (v6 < v9) ? v9 : v6;
    }
    os_unfair_lock_unlock(&__lock);
    if (v0 != nil) {
        os_log_t oslog = FBLogShutdown();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Waiting up to %.1fs for %u shutdown tasks to complete.", v6, count);
        }
        if (!dispatch_group_wait(v0, dispatch_time(DISPATCH_TIME_NOW, (long)(v6 * 1000000000.0)))) {
            os_log_t oslog3 = FBLogShutdown();
            if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Shutdown tasks complete.");
            }
        } else {
            os_unfair_lock_lock(&__lock);
            id v17 = [__lock_tasks copy];
            os_unfair_lock_unlock(&__lock);
            id v13 = [v17 bs_map:^id(FBAsynchronousShutdownTask *arg1) {
                return arg1->field_8;
            }];
            os_log_t oslog2 = FBLogShutdown();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                NSString *v16 = [v13 componentsJoinedByString:@", "];
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Shutdown tasks timed out: %{public}@. Shutting down now.", v16);
            }
        }
    }
}


void +[FBAsynchronousShutdownTask startTaskWithName:timeout:workItem:](id a1, void (^a2)(NSObject<OS_dispatch_queue> *, void (^)(NSError *)), long a3)
{
    double v3;
    id v1 = [a1 copy];
    FBAsynchronousShutdownTask *v2 = [[FBAsynchronousShutdownTask alloc] init];
    objc_storeStrong(v2 + 8, v1);
    v2->field_16 = v3;
    os_log_t oslog = FBLogShutdown();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *v4 = v2->field_8;
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Starting shutdown task \"%{public}@\" with %.1fs timeout.", v4, v3);
    }
    os_unfair_lock_lock(&__lock);
    if (!__lock_group) {
        __lock_group = dispatch_group_create();
        __lock_tasks = [[NSMutableArray alloc] init];
    }
    [__lock_tasks addObject:v2];
    dispatch_group_t v7 = __lock_group;
    os_unfair_lock_unlock(&__lock);
    dispatch_group_enter(v7);
    id v10 = [BSBlockSentinel sentinelWithCompletion:^void(id<BSBlockSentinelSignalContext> arg1) {
        if ([arg1 isFailed] != 0) {
            os_log_t oslog = FBLogShutdown();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                NSString *v1 = v2->_name;
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Shutdown task \"%{public}@\" dropped completion handler on the floor.", v1);
            }
        }
        dispatch_group_leave(v7);
    }];
    NSString *v11 = [NSString stringWithFormat:@"FBSShutdownTask:%@", v1];
    dispatch_queue_t queue = BSDispatchQueueCreateSerialWithQoS(v11, 33);
    NSDate *date = [NSDate date];
    dispatch_async(queue, ^void(void) {
        a2(queue, ^void(NSError *arg1) {
            os_unfair_lock_lock(&__lock);
            [__lock_tasks removeObject:v2];
            os_unfair_lock_unlock(&__lock);
            os_log_t v20 = FBLogShutdown();
            if (!arg1) {
                if (os_log_type_enabled(v20, OS_LOG_TYPE_DEFAULT)) {
                    NSTimeInterval timeIntervalSinceNow = [date timeIntervalSinceNow];
                    os_log_with_type(v20, OS_LOG_TYPE_DEFAULT, "Shutdown task \"%{public}@\" complete after %.2fs", v1, -timeIntervalSinceNow);
                }
            } else if (os_log_type_enabled(v20, OS_LOG_TYPE_ERROR)) {
                NSTimeInterval timeIntervalSinceNow2 = [date timeIntervalSinceNow];
                id v19 = [arg1 descriptionWithMultilinePrefix:0];
                os_log_with_type(v20, OS_LOG_TYPE_ERROR, "Shutdown task \"%{public}@\" failed after %.2fs with error: %{public}@", v1, -timeIntervalSinceNow2, v19);
            }
            [v10 signal];
        });
    });
}


void -[FBAsynchronousShutdownTask .cxx_destruct](void)
{
    self->_name = nil;
}
