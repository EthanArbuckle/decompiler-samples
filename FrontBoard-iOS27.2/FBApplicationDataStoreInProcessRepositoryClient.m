struct FBApplicationDataStoreInProcessRepositoryClient {
    id<FBApplicationDataStoreRepository> _dataStore; // +0x8
    NSCountedSet *_prefetchedKeys; // +0x10
    NSMutableDictionary *_prefetchedKeyValues; // +0x18
    NSObject<OS_dispatch_queue> *_prefetchQueue; // +0x20
    NSObject<OS_dispatch_queue> *_clientCalloutQueue; // +0x28
    struct os_unfair_lock_s _observersLock; // +0x30
    NSHashTable *_observersLock_observers; // +0x38
};

static long FBApplicationStoreRepositoryChangeApp;
static long FBApplicationStoreRepositoryChangeKey;
static long FBApplicationStoreRepositoryChangeNotification;
static long FBApplicationStoreRepositoryChangeValue;
static long FBApplicationStoreRepositoryInvalidatedNotification;

id -[FBApplicationDataStoreInProcessRepositoryClient objectForKey:forApplication:](id a1, id a2)
{
    os_log_t v7;
    os_log_t oslog = FBLogAppDataStore();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "fetching object for key=%{public}@ appID=%@ (synchronously)", a1, a2);
    }
    id v3 = nil;
    long v4 = [self prefetchedObjectIfAvailableForKey:a1 application:a2 outObject:&v3];
    id v5 = v3;
    if ((v4 & 1) != 0) {
        v7 = FBLogAppDataStore();
        if (os_log_type_enabled(v7, OS_LOG_TYPE_DEBUG)) {
            NSString *v10 = _descriptionForObject(v5);
            os_log_with_type(v7, OS_LOG_TYPE_DEBUG, "found prefetched object: %@", v10);
        }
        return v5;
    }
    id v6 = [self->_dataStore objectForKey:a1 forApplication:a2];
    if (v6 != nil) {
        v7 = FBLogAppDataStore();
        bool v8 = os_log_type_enabled(v7, OS_LOG_TYPE_DEBUG);
        v5 = v6;
        if (v8) {
            NSString *v12 = _descriptionForObject(v6);
            os_log_with_type(v7, OS_LOG_TYPE_DEBUG, "retrieved object from store: %@", v12);
            v5 = v6;
        }
        v6 = v5;
    }
    return v6;
}


void -[FBApplicationDataStoreInProcessRepositoryClient setObject:forKey:forApplication:withCompletion:](id a1, id a2, id a3, void (^a4)(long))
{
    void (^v3)(long) = a4;
    os_log_t oslog = FBLogAppDataStore();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_INFO)) {
        NSString *v5 = _descriptionForObject(a1);
        os_log_with_type(oslog, OS_LOG_TYPE_INFO, "setting object for key=%{public}@ appID=%@ object=%@", a2, a3, v5);
    }
    [self _updateCacheIfNecessaryWithObject:a1 forKey:a2 forApplication:a3];
    [self->_dataStore setObject:a1 forKey:a2 forApplication:a3];
    if (v3 != nil) {
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v3(0);
        });
    }
}


void -[FBApplicationDataStoreInProcessRepositoryClient _valueChanged:](id a1)
{
    id userInfo = [a1 userInfo];
    id v2 = [userInfo objectForKey:FBApplicationStoreRepositoryChangeApp];
    id userInfo2 = [a1 userInfo];
    id v4 = [userInfo2 objectForKey:FBApplicationStoreRepositoryChangeKey];
    id userInfo3 = [a1 userInfo];
    id v6 = [userInfo3 objectForKey:FBApplicationStoreRepositoryChangeValue];
    [self _invalidateCacheIfObjectIsNotEqual:v6 forKey:v4 forApplication:v2];
    dispatch_async(self->_clientCalloutQueue, ^void(void) {
        id _observers = [self _observers];
        for (id v9 in _observers) {
            if ([v9 respondsToSelector:@selector(applicationDataStoreRepositoryClient:application:changedObject:forKey:)]) {
                [v9 applicationDataStoreRepositoryClient:self application:v2 changedObject:v6 forKey:v4];
            }
        }
    });
}


bool -[FBApplicationDataStoreInProcessRepositoryClient prefetchedObjectIfAvailableForKey:application:outObject:](id a1, id a2, id *a3)
{
    id v0 = a1;
    id v1 = a2;
    __block id v2 = nil;
    __block bool v3 = false;
    os_log_t oslog = FBLogAppDataStore();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "checking for prefetched object for key=%{public}@ appID=%@", v0, v1);
    }
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        id v15 = [self->_prefetchedKeyValues objectForKey:v1];
        if (v15 != nil) {
            id v16 = [v15 objectForKey:v0];
            v2 = v16;
            if (!v2) {
                if ([self->_prefetchedKeys containsObject:v0]) {
                    v3 = true;
                }
            } else {
                v3 = true;
            }
        }
        id sentinel = [FBApplicationDataStoreInProcessRepositoryClientInvalidationSentinel sentinel];
        if (v2 == sentinel) {
            os_log_t oslog = FBLogAppDataStore();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
                os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "found invalidation sentinel for key=%{public}@ appID=%@, refreshing cache", v0, v1);
            }
            id v23 = [self->_dataStore objectForKey:v0 forApplication:v1];
            v2 = v23;
            id v10 = v2;
            if (!v2) {
                [v15 removeObjectForKey:v0];
            } else {
                [v15 setObject:v10 forKey:v0];
            }
        }
        NSNull *null = [NSNull null];
        BOOL v18 = [v2 isEqual:null];
    });
    if (v3 != 1) {
        os_log_t oslog2 = FBLogAppDataStore();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "no object found");
        }
        if (a3 != 0) {
            *(a3) = nil;
        }
    } else {
        os_log_t oslog3 = FBLogAppDataStore();
        if (os_log_type_enabled(oslog3, OS_LOG_TYPE_DEBUG)) {
            NSString *v8 = _descriptionForObject(v2);
            os_log_with_type(oslog3, OS_LOG_TYPE_DEBUG, "found object %@", v8);
        }
        if (a3 != 0) {
            *(a3) = v2;
        }
    }
    return v3;
}


NSArray *-[FBApplicationDataStoreInProcessRepositoryClient _observers](void)
{
    os_unfair_lock_assert_not_owner(&self->_observersLock);
    os_unfair_lock_lock(&self->_observersLock);
    NSArray *allObjects = [self->_observersLock_observers allObjects];
    os_unfair_lock_unlock(&self->_observersLock);
    return allObjects;
}


void -[FBApplicationDataStoreInProcessRepositoryClient _invalidateCacheIfObjectIsNotEqual:forKey:forApplication:](id a1, id a2, id a3)
{
    dispatch_async(self->_prefetchQueue, ^void(void) {
        if (![self->_prefetchedKeys containsObject:a2]) {
            return;
        }
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            NSString *v8 = _descriptionForObject(a1);
            os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "conditionally invalidating cache key=%{public}@ appID=%@ object=%@", a2, a3, v8);
        }
        id v10 = [self _prefetchQueue_prefetchedKeysForApplication:a3];
        id v4 = [v10 objectForKey:a2];
        long v5 = BSEqualObjects(a1, v4);
        os_log_t oslog2 = FBLogAppDataStore();
        bool v7 = os_log_type_enabled(oslog2, OS_LOG_TYPE_DEBUG);
        if ((v5 & 1) == 0) {
            if (v7) {
                os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "objects don't match, invalidating");
            }
            id sentinel = [FBApplicationDataStoreInProcessRepositoryClientInvalidationSentinel sentinel];
            [v10 setObject:sentinel forKey:a2];
        } else if (v7) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEBUG, "objects match");
        }
    });
}


void -[FBApplicationDataStoreInProcessRepositoryClient removeObjectForKey:forApplication:withCompletion:](id a1, id a2, void (^a3)(long))
{
    void (^v0)(long) = a3;
    [self _updateCacheIfNecessaryWithObject:0 forKey:a1 forApplication:a2];
    [self->_dataStore removeObjectForKey:a1 forApplication:a2];
    if (v0 != nil) {
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v0(0);
        });
    }
}


void -[FBApplicationDataStoreInProcessRepositoryClient _updateCacheIfNecessaryWithObject:forKey:forApplication:](id a1, id a2, id a3)
{
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        if (![self->_prefetchedKeys containsObject:a2]) {
            return;
        }
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            NSString *v0 = _descriptionForObject(a1);
            os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "updating cache key=%{public}@ appID=%@ object=%@", a2, a3, v0);
        }
        id v2 = [self _prefetchQueue_prefetchedKeysForApplication:a3];
        if (!a1) {
            [v2 removeObjectForKey:a2];
        } else {
            [v2 setObject:a1 forKey:a2];
        }
    });
}


void -[FBApplicationDataStoreInProcessRepositoryClient synchronizeWithCompletion:](void (^a1)(long))
{
    void (^v0)(long) = a1;
    [self->_dataStore flushSynchronously];
    if (v0 != nil) {
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v0(0);
        });
    }
}


FBApplicationDataStoreInProcessRepositoryClient *-[FBApplicationDataStoreInProcessRepositoryClient init](void)
{
    id sharedInstance = [FBApplicationDataStoreRepositoryManager sharedInstance];
    return [self initWithDataStore:[sharedInstance dataStore]];
}


FBApplicationDataStoreInProcessRepositoryClient *-[FBApplicationDataStoreInProcessRepositoryClient initWithDataStore:](id<FBApplicationDataStoreRepository> a1)
{
    FBApplicationDataStoreInProcessRepositoryClient *v1 = [super init];
    if (v1 != nil) {
        v1->_dataStore = a1;
        v1->_clientCalloutQueue = BSDispatchQueueCreateSerial(@"FBApplicationDataStoreInProcessRepositoryClient");
        v1->_prefetchedKeys = [[NSCountedSet alloc] init];
        v1->_prefetchedKeyValues = [[NSMutableDictionary alloc] init];
        v1->_prefetchQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.inprocessdataclient.prefetchqueue");
        v1->_observersLock._os_unfair_lock_opaque = 0;
        v1->_observersLock_observers = [NSHashTable weakObjectsHashTable];
    }
    return v1;
}


void -[FBApplicationDataStoreInProcessRepositoryClient addPrefetchedKeys:](id a1)
{
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        NSMutableArray *array = [NSMutableArray array];
        for (id v7 in a1) {
            [self->_prefetchedKeys addObject:v7];
            if ([self->_prefetchedKeys countForObject:v7] == 1) {
                [array addObject:v7];
            }
        }
        if ([array count] != 0) {
            id v9 = [self->_dataStore allObjectsForKeys:array];
            [v9 enumerateKeysAndObjectsUsingBlock:^void(NSString *arg1, NSDictionary *arg2, bool *arg3) {
                id v2 = [self->_prefetchedKeyValues objectForKey:arg1];
                if (!v2) {
                    id v3 = [arg2 mutableCopy];
                    [self->_prefetchedKeyValues setObject:v3 forKey:arg1];
                } else {
                    [v2 addEntriesFromDictionary:arg2];
                }
            }];
            [self _prefetchQueue_updateNotificationListeners];
        }
    });
}


void -[FBApplicationDataStoreInProcessRepositoryClient removePrefetchedKeys:withCompletion:](id a1, void (^a2)(long))
{
    void (^v0)(long) = a2;
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        NSMutableArray *array = [NSMutableArray array];
        for (id v7 in a1) {
            [self->_prefetchedKeys removeObject:v7];
            if (![self->_prefetchedKeys countForObject:v7]) {
                [array addObject:v7];
            }
        }
        [self->_prefetchedKeyValues enumerateKeysAndObjectsUsingBlock:^void(NSString *arg1, NSMutableDictionary *arg2, bool *arg3) {
            [arg2 removeObjectsForKeys:array];
        }];
        [self _prefetchQueue_updateNotificationListeners];
    });
    if (v0 != nil) {
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v0(0);
        });
    }
}


void -[FBApplicationDataStoreInProcessRepositoryClient _updateNotificationListeners](void)
{
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        [self _prefetchQueue_updateNotificationListeners];
    });
}


void -[FBApplicationDataStoreInProcessRepositoryClient _prefetchQueue_updateNotificationListeners](void)
{
    BSDispatchQueueAssert(self->_prefetchQueue);
    NSUInteger count = [self->_prefetchedKeys count];
    id _observers = [self _observers];
    long count2 = [_observers count];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    if (!count && !count2) {
        [defaultCenter removeObserver:self name:FBApplicationStoreRepositoryChangeNotification object:nil];
        [defaultCenter removeObserver:self name:FBApplicationStoreRepositoryInvalidatedNotification object:nil];
    } else {
        [defaultCenter addObserver:self selector:@selector(_valueChanged:) name:FBApplicationStoreRepositoryChangeNotification object:nil];
        [defaultCenter addObserver:self selector:@selector(_repositoryInvalidated:) name:FBApplicationStoreRepositoryInvalidatedNotification object:nil];
    }
}


id -[FBApplicationDataStoreInProcessRepositoryClient _prefetchQueue_prefetchedKeysForApplication:](id<NSCopying> a1)
{
    dispatch_assert_queue(self->_prefetchQueue);
    id v1 = [self->_prefetchedKeyValues objectForKeyedSubscript:a1];
    if (!v1) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        v1 = dictionary;
        [self->_prefetchedKeyValues setObject:dictionary forKey:a1];
    }
    return v1;
}


void -[FBApplicationDataStoreInProcessRepositoryClient _invalidateCacheForApplication:](id a1)
{
    dispatch_sync(self->_prefetchQueue, ^void(void) {
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "invalidating cache for appID=%@", a1);
        }
        id v3 = [self _prefetchQueue_prefetchedKeysForApplication:a1];
        [v3 removeAllObjects];
    });
}


void -[FBApplicationDataStoreInProcessRepositoryClient _repositoryInvalidated:](id a1)
{
    id userInfo = [a1 userInfo];
    id v1 = [userInfo objectForKey:FBApplicationStoreRepositoryChangeApp];
    dispatch_async(self->_prefetchQueue, ^void(void) {
        [self->_prefetchedKeyValues removeObjectForKey:v1];
    });
    dispatch_async(self->_clientCalloutQueue, ^void(void) {
        id _observers = [self _observers];
        for (id v6 in _observers) {
            if ([v6 respondsToSelector:@selector(applicationDataStoreRepositoryClient:storeInvalidatedForApplication:)]) {
                [v6 applicationDataStoreRepositoryClient:self storeInvalidatedForApplication:v1];
            }
        }
    });
}


long -[FBApplicationDataStoreInProcessRepositoryClient invalidate](void)
{
    return self;
}


NSArray *-[FBApplicationDataStoreInProcessRepositoryClient availableDataStores](void)
{
    NSArray *v0 = [self->_dataStore applicationIdentifiersWithState];
    if (!v0) {
        v0 = [NSArray array];
    }
    return v0;
}


id -[FBApplicationDataStoreInProcessRepositoryClient migrateIdentifier:toIdentifier:](id a1, id a2)
{
    Class v1 = NSClassFromString(@"NSString");
    if (!a1) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v6 = NSStringFromSelector(_cmd);
            NSString *v7 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v6, v7, self, @"FBApplicationDataStoreInProcessRepositoryClient.m", 291, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBApplicationDataStoreInProcessRepositoryClient.m", 291, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    Class v3 = NSClassFromString(@"NSString");
    if (!a2) {
        NSString *v13 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v14 = NSStringFromSelector(_cmd);
            NSString *v15 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBApplicationDataStoreInProcessRepositoryClient.m", 292, v13);
        }
        _bs_set_crash_log_message([v13 UTF8String]);
        __break(0);
    }
    if (![a2 isKindOfClass:v3]) {
        NSString *v17 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:NSStringClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v18 = NSStringFromSelector(_cmd);
            NSString *v19 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v18, v19, self, @"FBApplicationDataStoreInProcessRepositoryClient.m", 292, v17);
        }
        _bs_set_crash_log_message([v17 UTF8String]);
        __break(0);
    }
    return [self->_dataStore migrateIdentifier:a1 toIdentifier:a2];
}


void -[FBApplicationDataStoreInProcessRepositoryClient removeAllObjectsForApplication:withCompletion:](id a1, void (^a2)(long))
{
    void (^v0)(long) = a2;
    [self _invalidateCacheForApplication:a1];
    [self->_dataStore removeAllObjectsForApplication:a1];
    if (v0 != nil) {
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v0(0);
        });
    }
}


void -[FBApplicationDataStoreInProcessRepositoryClient objectForKey:forApplication:withResult:](id a1, id a2, void (^a3)(id, long))
{
    os_log_t v8;
    void (^v2)(id, long) = a3;
    os_log_t oslog = FBLogAppDataStore();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEBUG)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEBUG, "fetching object for key=%{public}@ appID=%@", a1, a2);
    }
    if (v2 != nil) {
        id v4 = nil;
        long v5 = [self prefetchedObjectIfAvailableForKey:a1 application:a2 outObject:&v4];
        id v6 = v4;
        if ((v5 & 1) == 0) {
            id v7 = [self->_dataStore objectForKey:a1 forApplication:a2];
            v8 = FBLogAppDataStore();
            bool v9 = os_log_type_enabled(v8, OS_LOG_TYPE_INFO);
            v6 = v7;
            if (v9) {
                NSString *v10 = _descriptionForObject(v7);
                os_log_with_type(v8, OS_LOG_TYPE_INFO, "retrieved object from store: %@", v10);
                v6 = v7;
            }
        } else {
            v8 = FBLogAppDataStore();
            if (os_log_type_enabled(v8, OS_LOG_TYPE_DEBUG)) {
                NSString *v14 = _descriptionForObject(v6);
                os_log_with_type(v8, OS_LOG_TYPE_DEBUG, "found prefetched object: %@", v14);
            }
        }
        dispatch_async(self->_clientCalloutQueue, ^void(void) {
            v2(v6, 0);
        });
    }
}


long -[FBApplicationDataStoreInProcessRepositoryClient addObserver:](id a1)
{
    os_unfair_lock_assert_not_owner(&self->_observersLock);
    os_unfair_lock_lock(&self->_observersLock);
    [self->_observersLock_observers addObject:a1];
    os_unfair_lock_unlock(&self->_observersLock);
    return [self _updateNotificationListeners];
}


long -[FBApplicationDataStoreInProcessRepositoryClient removeObserver:](id a1)
{
    os_unfair_lock_assert_not_owner(&self->_observersLock);
    os_unfair_lock_lock(&self->_observersLock);
    [self->_observersLock_observers removeObject:a1];
    os_unfair_lock_unlock(&self->_observersLock);
    return [self _updateNotificationListeners];
}


void -[FBApplicationDataStoreInProcessRepositoryClient .cxx_destruct](void)
{
    self->_observersLock_observers = nil;
    self->_clientCalloutQueue = nil;
    self->_prefetchQueue = nil;
    self->_prefetchedKeyValues = nil;
    self->_prefetchedKeys = nil;
    self->_dataStore = nil;
}
