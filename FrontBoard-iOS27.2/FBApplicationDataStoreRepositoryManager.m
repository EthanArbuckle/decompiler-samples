struct FBApplicationDataStoreRepositoryManager {
    NSURL *_dataStoreURL; // +0x8
    id<FBApplicationDataStoreRepository> _dataStore; // +0x10
    LSEnumerator *_lsEnumerator; // +0x18
    NSObject<OS_dispatch_queue> *_deferredWorkQueue; // +0x20
};

void -[FBApplicationDataStoreRepositoryManager objectChangedForKeys:application:](id a1, id a2)
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    for (id v8 in a1) {
        @autoreleasepool {
            NSNull *v13 = [self->_dataStore objectForKey:v8 forApplication:a2];
            if (!v13) {
                v13 = [NSNull null];
            }
            NSDictionary *aUserInfo = @{@"FBApplicationStoreRepositoryChangeKey": v8, @"FBApplicationStoreRepositoryChangeApp": a2, @"FBApplicationStoreRepositoryChangeValue": v13};
            [defaultCenter postNotificationName:@"FBApplicationStoreRepositoryChangeNotification" object:nil userInfo:aUserInfo];
        }
    }
}


FBApplicationDataStoreRepositoryManager *+[FBApplicationDataStoreRepositoryManager sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        sharedInstance.sharedInstance = [[self alloc] init];
    });
    return sharedInstance.sharedInstance;
}


FBApplicationDataStoreRepositoryManager *-[FBApplicationDataStoreRepositoryManager init](void)
{
    return [self _initWithDataStore:0 lsEnumerator:0];
}


FBApplicationDataStoreRepositoryManager *-[FBApplicationDataStoreRepositoryManager _initWithDataStore:lsEnumerator:](id a1, LSEnumerator *a2)
{
    FBApplicationDataStoreRepositoryManager *observer = [super init];
    if (observer != nil) {
        NSString *stringByExpandingTildeInPath = [@"~/Library/FrontBoard/applicationState.db" stringByExpandingTildeInPath];
        observer->_dataStoreURL = [NSURL fileURLWithPath:stringByExpandingTildeInPath];
        observer->_lsEnumerator = a2;
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), observer, &_handleApplicationsRegisteredNotification, @"com.apple.LaunchServices.applicationRegistered", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        [observer migrateApplicationStorePathIfNecessary];
        observer->_dataStore = (!a1) ? [[FBSqliteApplicationDataStoreRepository alloc] initWithStorePath:observer->_dataStoreURL] : a1;
        [observer->_dataStore setDelegate:observer];
        observer->_deferredWorkQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.repositorymanager.init");
        dispatch_async(observer->_deferredWorkQueue, ^void(void) {
            [observer clearExpiredUninstalledApplicationsFromStoreIfNecessary];
        });
    }
    return observer;
}


void -[FBApplicationDataStoreRepositoryManager dealloc](void)
{
    [self->_dataStore flushSynchronously];
    [self->_dataStore close];
    [super dealloc];
}


NSURL *-[FBApplicationDataStoreRepositoryManager urlByAppendingString:toURL:](NSString *a1, id a2)
{
    NSString *lastPathComponent = [a2 lastPathComponent];
    NSURL *URLByDeletingLastPathComponent = [a2 URLByDeletingLastPathComponent];
    NSString *pathComponent = [lastPathComponent stringByAppendingString:a1];
    return [URLByDeletingLastPathComponent URLByAppendingPathComponent:pathComponent];
}


int -[FBApplicationDataStoreRepositoryManager removeStoreAtURL:error:](id a1, NSError **a2)
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (![defaultManager removeItemAtURL:self->_dataStoreURL error:a2]) {
        return 0;
    }
    NSURL *URL = [self urlByAppendingString:@"-shm" toURL:a1];
    NSString *path = [URL path];
    BOOL v5 = [defaultManager fileExistsAtPath:path];
    if (!v5 || [defaultManager removeItemAtURL:URL error:a2]) {
        NSURL *URL2 = [self urlByAppendingString:@"-wal" toURL:a1];
        NSString *path2 = [URL2 path];
        if (![defaultManager fileExistsAtPath:path2]) {
            return 1;
        }
        if (![defaultManager removeItemAtURL:URL2 error:a2]) {
            return 0;
        }
        return 1;
    }
    return 0;
}


void -[FBApplicationDataStoreRepositoryManager migrateApplicationStorePathIfNecessary](void)
{
    id v23;
    NSFileManager *v0 = [[NSFileManager alloc] init];
    NSString *path = [self->_dataStoreURL path];
    BOOL v2 = [v0 fileExistsAtPath:path];
    if (!v2) {
        NSURL *URLByDeletingLastPathComponent = [self->_dataStoreURL URLByDeletingLastPathComponent];
        [v0 createDirectoryAtURL:URLByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *stringByExpandingTildeInPath = [@"~/Library/FrontBoard/applicationState.plist" stringByExpandingTildeInPath];
    NSURL *v5 = [NSURL fileURLWithPath:stringByExpandingTildeInPath];
    NSString *stringByExpandingTildeInPath2 = [@"~/Library/BackBoard/applicationState.plist" stringByExpandingTildeInPath];
    NSURL *v8 = [NSURL fileURLWithPath:stringByExpandingTildeInPath2];
    NSString *stringByExpandingTildeInPath3 = [@"~/Library/SpringBoard/applicationstate.plist" stringByExpandingTildeInPath];
    NSURL *v10 = [NSURL fileURLWithPath:stringByExpandingTildeInPath3];
    NSArray<NSURL *> *v11 = @[v5, v8, v10];
    for (NSURL *v18 in v11) {
        NSString *path2 = [v18 path];
        if ([v0 fileExistsAtPath:path2]) {
            if (v2) {
                id v21 = nil;
                long v22 = [self removeStoreAtURL:self->_dataStoreURL error:&v21];
                v23 = v21;
                if ((v22 & 1) == 0) {
                    os_log_t oslog = FBLogAppDataStore();
                    if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                        NSURL *v13 = self->_dataStoreURL;
                        os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Unable to migrate application state store from %{public}@ to %{public}@ due to error: %{public}@", v18, v13, v23);
                    }
                }
            } else {
                v23 = nil;
            }
            id v25 = v23;
            long v26 = [self migrateFromPlistStoreAtURL:v18 toSqliteStoreAtURL:self->_dataStoreURL error:&v25];
            if (v26) {
                os_log_t oslog3 = FBLogAppDataStore();
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_INFO)) {
                    NSURL *v6 = self->_dataStoreURL;
                    os_log_with_type(oslog3, OS_LOG_TYPE_INFO, "Successfully migrated application state store from %{public}@ to %{public}@.", v18, v6);
                }
                break;
            } else if (v25 != nil) {
                os_log_t oslog2 = FBLogAppDataStore();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                    NSURL *v12 = self->_dataStoreURL;
                    os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "Unable to migrate application state store from %{public}@ to %{public}@ due to error: %{public}@", v18, v12, v25);
                    continue;
                }
            }
        }
    }
    NSMutableSet<NSURL *> *v31 = [NSMutableSet setWithArray:v11];
    for (NSURL *v37 in v31) {
        NSString *path3 = [v37 path];
        if ([v0 fileExistsAtPath:path3]) {
            [v0 removeItemAtURL:v37 error:nil];
        }
    }
}


int -[FBApplicationDataStoreRepositoryManager migrateFromApplicationStore:toApplicationStore:error:](id a1, id a2, long a3)
{
    [a2 beginBatchedUpdate];
    id applicationIdentifiersWithState = [a2 applicationIdentifiersWithState];
    for (id v22 in applicationIdentifiersWithState) {
        [a2 removeAllObjectsForApplication:v22];
    }
    id applicationIdentifiersWithState2 = [a1 applicationIdentifiersWithState];
    for (id v14 in applicationIdentifiersWithState2) {
        id v16 = [a1 keysForApplication:v14];
        for (id v21 in v16) {
            id v23 = [a1 objectForKey:v21 forApplication:v14];
            if (v23 != nil) {
                [a2 setObject:v23 forKey:v21 forApplication:v14];
            }
        }
    }
    [a2 endBatchedUpdate];
    [a2 flushSynchronously];
    return 1;
}


int -[FBApplicationDataStoreRepositoryManager migrateFromPlistStoreAtURL:toSqliteStoreAtURL:error:](id a1, id a2, long a3)
{
    FBPlistApplicationDataStoreRepository *v2 = [[FBPlistApplicationDataStoreRepository alloc] initWithStorePath:a1];
    FBSqliteApplicationDataStoreRepository *v3 = [[FBSqliteApplicationDataStoreRepository alloc] initWithStorePath:a2];
    if (v2 == nil || v3 == nil) {
        return 0;
    }
    return [self migrateFromApplicationStore:v2 toApplicationStore:v3 error:a3];
}


void -[FBApplicationDataStoreRepositoryManager clearExpiredUninstalledApplicationsFromStoreIfNecessary](void)
{
    [self->_dataStore beginBatchedUpdate];
    LSEnumerator *v1 = (!self->_lsEnumerator) ? [LSApplicationRecord enumeratorWithOptions:0] : self->_lsEnumerator;
    self->_lsEnumerator = nil;
    NSArray *allObjects = [v1 allObjects];
    if (![allObjects count]) {
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "LSEnumerator returned zero apps");
        }
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
        dispatch_after(when, self->_deferredWorkQueue, ^void(void) {
            [self clearExpiredUninstalledApplicationsFromStoreIfNecessary];
        });
    } else {
        NSMutableSet *v7 = [[NSMutableSet alloc] init];
        for (id v24 in allObjects) {
            NSString *bundleIdentifier = [v24 bundleIdentifier];
            if (bundleIdentifier != nil) {
                [v7 addObject:bundleIdentifier];
            }
        }
        id applicationIdentifiersWithState = [self->_dataStore applicationIdentifiersWithState];
        NSMutableArray *v17 = [[NSMutableArray alloc] init];
        NSArray *v18 = [NSArray arrayWithObjects:@"_SBUninstalledDate", @"__SBUninstalledDate", nil];
        for (id v31 in applicationIdentifiersWithState) {
            id fbs_bundleIDFromAppID = [v31 fbs_bundleIDFromAppID];
            BOOL v33 = [v7 containsObject:fbs_bundleIDFromAppID];
            long v34 = [self _safeObjectForKey:@"__UninstallDate" forApplication:v31 ofType:[NSDate class]];
            id v35 = v34;
            if (!v34) {
                NSArray *v37 = v18;
                v35 = nil;
                for (id v14 in v37) {
                    v35 = [self _safeObjectForKey:v14 forApplication:v31 ofType:[NSDate class]];
                    if (v35) {
                        break;
                    }
                }
            }
            [self->_dataStore removeObjectsForKeys:v18 forApplication:v31];
            bool v43 = !v33;
            if ((((v35 != nil) ? v43 : 1) & 1) == 0) {
                os_log_t oslog2 = FBLogAppDataStore();
                if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Application has been re-installed: %{public}@", v31);
                }
blk_1c4f2f2cc:
                [self->_dataStore removeObjectForKey:@"__UninstallDate" forApplication:v31];
            } else if ((((!v35) ? v33 : 1) & 1) != 0) {
                if (!v35 || v33) {
                    goto blk_1c4f2f2cc;
                }
                NSTimeInterval timeIntervalSinceNow = [v35 timeIntervalSinceNow];
                if (timeIntervalSinceNow >= -86400.0) {
                    if (!v34) {
                        [self->_dataStore setObject:v35 forKey:@"__UninstallDate" forApplication:v31];
                    }
                } else {
                    [v17 addObject:v31];
                }
            } else {
                os_log_t oslog3 = FBLogAppDataStore();
                if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog3, OS_LOG_TYPE_DEFAULT, "Flagging application as uninstalled: %{public}@", v31);
                }
                NSDate *date = [NSDate date];
                [self->_dataStore setObject:date forKey:@"__UninstallDate" forApplication:v31];
                continue;
            }
        }
        for (id v60 in v17) {
            os_log_t oslog4 = FBLogAppDataStore();
            if (os_log_type_enabled(oslog4, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(oslog4, OS_LOG_TYPE_DEFAULT, "Purging application state of expired identifier: %{public}@", v60);
            }
            [self->_dataStore removeAllObjectsForApplication:v60];
        }
        [self->_dataStore endBatchedUpdate];
        dispatch_time_t when2 = dispatch_time(DISPATCH_TIME_NOW, 86400 * NSEC_PER_SEC);
        dispatch_after(when2, self->_deferredWorkQueue, ^void(void) {
            [self clearExpiredUninstalledApplicationsFromStoreIfNecessary];
        });
    }
}


id -[FBApplicationDataStoreRepositoryManager _safeObjectForKey:forApplication:ofType:](long a1, long a2, Class a3)
{
    id v1;
    id v0 = [self->_dataStore objectForKey:a1 forApplication:a2];
    if (!v0) {
        return nil;
    }
    if ([v0 isKindOfClass:a3]) {
        v1 = v0;
    } else {
        v1 = nil;
    }
    return v1;
}


void -[FBApplicationDataStoreRepositoryManager _handleApplicationInstalled:](id a1)
{
    for (id v5 in a1) {
        [self->_dataStore removeObjectForKey:@"__UninstallDate" forApplication:v5];
    }
    id applicationIdentifiersWithState = [self->_dataStore applicationIdentifiersWithState];
    for (id v14 in applicationIdentifiersWithState) {
        id fbs_bundleIDFromAppID = [v14 fbs_bundleIDFromAppID];
        if ([a1 containsObject:fbs_bundleIDFromAppID]) {
            [self->_dataStore removeObjectForKey:@"__UninstallDate" forApplication:v14];
        }
    }
}


void -[FBApplicationDataStoreRepositoryManager _performAfterDeferredWork:](dispatch_block_t a1)
{
    dispatch_async(self->_deferredWorkQueue, a1);
}


void -[FBApplicationDataStoreRepositoryManager storeInvalidatedForIdentifier:](id a1)
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    NSDictionary<NSString *, id> *aUserInfo = @{@"FBApplicationStoreRepositoryChangeApp": a1};
    [defaultCenter postNotificationName:@"FBApplicationStoreRepositoryInvalidatedNotification" object:nil userInfo:aUserInfo];
}


id<FBApplicationDataStoreRepository> -[FBApplicationDataStoreRepositoryManager dataStore](void)
{
    return self->_dataStore;
}


void -[FBApplicationDataStoreRepositoryManager setDataStore:](id<FBApplicationDataStoreRepository> a1)
{
    self->_dataStore = a1;
}


void -[FBApplicationDataStoreRepositoryManager .cxx_destruct](void)
{
    self->_deferredWorkQueue = nil;
    self->_lsEnumerator = nil;
    self->_dataStore = nil;
    self->_dataStoreURL = nil;
}
