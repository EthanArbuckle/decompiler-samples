struct FBPlistApplicationDataStoreRepository {
    NSURL *_storeURL; // +0x8
    NSMutableDictionary *_state; // +0x10
    bool _dirty; // +0x18
    unsigned long _batchCount; // +0x20
    int _autoFlushDuration; // +0x28
    __weak id<FBApplicationDataStoreRepositoryDelegate> _delegate; // +0x30
    NSObject<OS_dispatch_queue> *_stateQueue; // +0x38
    NSObject<OS_dispatch_queue> *_writeQueue; // +0x40
    NSObject<OS_dispatch_queue> *_calloutQueue; // +0x48
};

FBPlistApplicationDataStoreRepository *-[FBPlistApplicationDataStoreRepository initWithStorePath:](NSURL *a1)
{
    FBPlistApplicationDataStoreRepository *v2 = [super init];
    if (v2 != nil) {
        if (!a1) {
            NSString *v1 = [NSString stringWithFormat:@"The application store must have a valid URL path."];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v9 = NSStringFromSelector(_cmd);
                NSString *v10 = NSStringFromClass([v2 class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v9, v10, v2, @"FBPlistApplicationDataStoreRepository.m", 37, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        v2->_storeURL = a1;
        v2->_stateQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.applicationstore.default");
        v2->_writeQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.applicationstore.write");
        v2->_calloutQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.applicationstore.callout");
        [v2 _load];
    }
    return v2;
}


void -[FBPlistApplicationDataStoreRepository dealloc](void)
{
    if (self->_stateQueue != nil) {
        __block NSMutableDictionary *v0 = self->_state;
        self->_state = nil;
        dispatch_async(self->_stateQueue, ^void(void) {
            v0 = nil;
        });
    }
    [super dealloc];
}


NSURL *-[FBPlistApplicationDataStoreRepository location](void)
{
    return self->_storeURL;
}


bool -[FBPlistApplicationDataStoreRepository isDirty](void)
{
    __block bool v0 = false;
    dispatch_sync(self->_stateQueue, ^void(void) {
        v0 = self->_dirty;
    });
    return v0;
}


NSMutableArray *-[FBPlistApplicationDataStoreRepository applicationIdentifiersWithState](void)
{
    __block NSMutableArray *array = [NSMutableArray array];
    dispatch_sync(self->_stateQueue, ^void(void) {
        NSArray *allKeys = [self->_state allKeys];
        if (allKeys != nil) {
            [array addObjectsFromArray:allKeys];
        }
    });
    return array;
}


id -[FBPlistApplicationDataStoreRepository keysForApplication:](id a1)
{
    id v0 = a1;
    if (!a1) {
        return nil;
    }
    __block id v2 = nil;
    dispatch_sync(self->_stateQueue, ^void(void) {
        id v5 = [self _stateQueue_storeForIdentifier:v0];
        if (v5 != nil) {
            NSArray *allKeys = [v5 allKeys];
            v2 = allKeys;
        }
    });
    return v2;
}


long -[FBPlistApplicationDataStoreRepository containsKey:forApplication:](long a1, long a2)
{
    id v0 = [self objectForKey:a1 forApplication:a2];
    if (v0 != nil) {
        return 1;
    }
    return 0;
}


id -[FBPlistApplicationDataStoreRepository objectForKey:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    id v2 = nil;
    if (v0 != nil && v1 != nil) {
        __block id v3 = nil;
        dispatch_sync(self->_stateQueue, ^void(void) {
            id v6 = [self _stateQueue_objectForKey:v0 forIdentifier:v1];
            v3 = v6;
        });
        v2 = v3;
    }
    return v2;
}


id -[FBPlistApplicationDataStoreRepository allObjectsForKeys:](id a1)
{
    id v0 = a1;
    if (![a1 count]) {
        return nil;
    }
    __block id v2 = nil;
    dispatch_sync(self->_stateQueue, ^void(void) {
        id v5 = [self _stateQueue_objectsForKeys:v0];
        v2 = v5;
    });
    return v2;
}


void -[FBPlistApplicationDataStoreRepository setObject:forKey:forApplication:](id a1, id a2, id a3)
{
    id v0 = a1;
    id v1 = a2;
    id v2 = a3;
    if (!v0) {
        [self removeObjectForKey:v1 forApplication:v2];
    } else if (v1 != nil && v2 != nil && [self _isEligibleForSaving:v0] != 0) {
        id v3 = [v0 copy];
        dispatch_async(self->_stateQueue, ^void(void) {
            id v10;
            id v12;
            id v9 = [self _stateQueue_storeForIdentifier:v2];
            if (!v9) {
                if (v0 != nil) {
                    v10 = nil;
                } else {
                    return;
                }
            } else {
                v10 = [v9 objectForKey:v1];
            }
            if (v0 != v10) {
                if ([v0 isEqual:v10] == 0) {
                    if (!v3) {
                        [v9 removeObjectForKey:v1];
                        v12 = v9;
                    } else {
                        id v13 = [self _stateQueue_addStoreForIdentifierIfNecessary:v2];
                        v12 = v13;
                        [v13 setObject:v3 forKey:v1];
                    }
                    [self _stateQueue_markDirty];
                    if (![v12 count]) {
                        [self _stateQueue_removeStoreForIdentifier:v2];
                    } else {
                        NSArray *v8 = @[v1];
                        [self _notifyDelegateOfChangeForKeys:v8 application:v2];
                    }
                }
            }
        });
    }
}


id -[FBPlistApplicationDataStoreRepository removeObjectForKey:forApplication:](id a1, id a2)
{
    if (!a1 || !a2) {
        return self;
    }
    NSArray<id> *v2 = [NSArray arrayWithObject:a1];
    [self removeObjectsForKeys:v2 forApplication:a2];
    return v2;
}


void -[FBPlistApplicationDataStoreRepository removeObjectsForKeys:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    if (v0 != nil) {
        long count = [v0 count];
        if (v1 != nil && count != 0) {
            dispatch_async(self->_stateQueue, ^void(void) {
                id v4 = [self _stateQueue_storeForIdentifier:v1];
                if (v4 != nil) {
                    NSSet *v5 = [v4 keysOfEntriesPassingTest:^bool(id arg1, id arg2, bool *arg3) {
                        return [v0 containsObject:arg1];
                    }];
                    NSArray *allObjects = [v5 allObjects];
                    if ([allObjects count] != 0) {
                        [v4 removeObjectsForKeys:allObjects];
                        [self _stateQueue_markDirty];
                        if (![v4 count]) {
                            [self _stateQueue_removeStoreForIdentifier:v1];
                        } else {
                            [self _notifyDelegateOfChangeForKeys:allObjects application:v1];
                        }
                    }
                }
            });
        }
    }
}


void -[FBPlistApplicationDataStoreRepository removeAllObjectsForApplication:](id a1)
{
    id v0 = a1;
    if (a1 != nil) {
        dispatch_async(self->_stateQueue, ^void(void) {
            [self _stateQueue_removeStoreForIdentifier:v0];
        });
    }
}


void -[FBPlistApplicationDataStoreRepository flushSynchronously](void)
{
    dispatch_sync(self->_writeQueue, ^void(void) {
        [self _writeQueue_flushSynchronously];
    });
}


void -[FBPlistApplicationDataStoreRepository beginBatchedUpdate](void)
{
    dispatch_sync(self->_stateQueue, ^void(void) {
        self->_batchCount = self->_batchCount + 1;
    });
}


void -[FBPlistApplicationDataStoreRepository endBatchedUpdate](void)
{
    dispatch_sync(self->_stateQueue, ^void(void) {
        if (!self->_batchCount) {
            return;
        }
        self->_batchCount = self->_batchCount - 1;
        if (self->_dirty != 1 || self->_batchCount != 0) {
            return;
        }
        dispatch_async(self->_writeQueue, ^void(void) {
            [self _writeQueue_flushSynchronously];
        });
    });
}


long -[FBPlistApplicationDataStoreRepository close](void)
{
    return [self flushSynchronously];
}


id -[FBPlistApplicationDataStoreRepository migrateIdentifier:toIdentifier:](id a1, id a2)
{
    __block id v2 = nil;
    dispatch_sync(self->_stateQueue, ^void(void) {
        NSDictionary *v0 = [self _stateQueue_storeForIdentifier:a1];
        if (!v0) {
            id v13 = [NSError bs_errorWithDomain:@"FBApplicationDataStore" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureReason:@"No store exists for identifier \"%@\"", a1];
            }];
            v2 = v13;
        } else {
            id v6 = [self _stateQueue_storeForIdentifier:a2];
            if (!v6) {
                id v7 = [self _stateQueue_addStoreForIdentifierIfNecessary:a2];
                [v7 addEntriesFromDictionary:v0];
                [self _stateQueue_removeStoreForIdentifier:a1];
                NSArray *allKeys = [v7 allKeys];
                [self _notifyDelegateOfChangeForKeys:allKeys application:a2];
                [self _stateQueue_markDirty];
            } else {
                id v10 = [NSError bs_errorWithDomain:@"FBApplicationDataStore" code:1 configuration:^void(id<BSErrorConfiguring> arg1) {
                    [arg1 setFailureReason:@"Store already exists with identifier \"%@\"", a2];
                }];
                v2 = v10;
            }
        }
    });
    return v2;
}


int -[FBPlistApplicationDataStoreRepository _isEligibleForSaving:](id a1)
{
    dispatch_once(&_isEligibleForSaving:.onceToken, ^void(void) {
        NSArray *v8 = [NSArray alloc];
        Class v9 = [NSString class];
        Class v10 = [NSData class];
        Class v11 = [NSNumber class];
        Class v4 = [NSArray class];
        Class v5 = [NSDictionary class];
        _isEligibleForSaving:.__eligibleClassTypes = [v8 initWithObjects:v9, v10, v11, v4, v5, [NSDate class], 0];
    });
    int v3 = 0;
    for (Class v7 in _isEligibleForSaving:.__eligibleClassTypes) {
        if ([a1 isKindOfClass:v7]) {
            return 1;
        }
    }
    return v3;
}


void -[FBPlistApplicationDataStoreRepository _load](void)
{
    dispatch_async(self->_stateQueue, ^void(void) {
        @autoreleasepool {
            NSData *v1 = [[NSData alloc] initWithContentsOfURL:self->_storeURL options:NSDataReadingMappedIfSafe error:nil];
            if (v1 != nil) {
                self->_state = [NSPropertyListSerialization propertyListWithData:v1 options:1 format:NULL error:nil];
            }
            if (!self->_state || ![self->_state isKindOfClass:[NSDictionary class]]) {
                self->_state = [[NSMutableDictionary alloc] init];
            }
        }
    });
}


id -[FBPlistApplicationDataStoreRepository _stateQueue_objectForKey:forIdentifier:](id a1, id a2)
{
    dispatch_assert_queue(self->_stateQueue);
    id v2 = [self _stateQueue_storeForIdentifier:a2];
    return (!v2) ? nil : [v2 objectForKey:a1];
}


NSMutableDictionary *-[FBPlistApplicationDataStoreRepository _stateQueue_objectsForKeys:](NSArray<NSString *> *a1)
{
    dispatch_assert_queue(self->_stateQueue);
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *allKeys = [self->_state allKeys];
    for (id<NSCopying> v8 in allKeys) {
        id v10 = [self _stateQueue_storeForIdentifier:v8];
        if (v10 != nil) {
            NSDictionary<NSString *, id> *v11 = [v10 dictionaryWithValuesForKeys:a1];
            id v12 = [v11 mutableCopy];
            NSNull *null = [NSNull null];
            NSArray *v14 = [v12 allKeysForObject:null];
            [v12 removeObjectsForKeys:v14];
            [dictionary setObject:v12 forKey:v8];
        }
    }
    return dictionary;
}


id -[FBPlistApplicationDataStoreRepository _stateQueue_storeForIdentifier:](id a1)
{
    dispatch_assert_queue(self->_stateQueue);
    return [self->_state bs_safeObjectForKey:a1 ofType:[NSMutableDictionary class]];
}


NSMutableDictionary *-[FBPlistApplicationDataStoreRepository _stateQueue_addStoreForIdentifierIfNecessary:](id<NSCopying> a1)
{
    dispatch_assert_queue(self->_stateQueue);
    NSMutableDictionary *v1 = [self _stateQueue_storeForIdentifier:a1];
    if (!v1) {
        v1 = [[NSMutableDictionary alloc] init];
        [self->_state setObject:v1 forKey:a1];
        [self _stateQueue_markDirty];
    }
    return v1;
}


void -[FBPlistApplicationDataStoreRepository _stateQueue_removeStoreForIdentifier:](id a1)
{
    dispatch_assert_queue(self->_stateQueue);
    id v1 = [self->_state objectForKey:a1];
    if (v1 != nil) {
        [self->_state removeObjectForKey:a1];
        [self _stateQueue_markDirty];
        [self _notifyDelegateOfStoreInvalidationForIdentifier:a1];
    }
}


void -[FBPlistApplicationDataStoreRepository _stateQueue_markDirty](void)
{
    dispatch_assert_queue(self->_stateQueue);
    if (self->_dirty) {
        return;
    }
    self->_dirty = YES;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    dispatch_after(when, self->_writeQueue, ^void(void) {
        @autoreleasepool {
            [self _writeQueue_flushSynchronously];
        }
    });
}


void -[FBPlistApplicationDataStoreRepository _writeQueue_flushSynchronously](void)
{
    long v3;
    dispatch_assert_queue(self->_writeQueue);
    if (self->_batchCount) {
        return;
    }
    __block id v0 = nil;
    dispatch_sync(self->_stateQueue, ^void(void) {
        if (self->_dirty != 1) {
            return;
        }
        NSError *v10 = nil;
        NSData *v11 = [NSPropertyListSerialization dataWithPropertyList:self->_state format:NSPropertyListBinaryFormat_v1_0 options:0 error:&v10];
        v0 = v11;
        if (!v0) {
            NSString *v15 = [NSString stringWithFormat:@"Unable to serialize application state: %@", v10];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v16 = NSStringFromSelector(v3);
                NSString *v7 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v7, self, @"FBPlistApplicationDataStoreRepository.m", 389, v15);
            }
            _bs_set_crash_log_message([v15 UTF8String]);
            __break(0);
        }
        self->_dirty = NO;
    });
    if (v0) {
        NSString *path = [self->_storeURL path];
        NSString *stringByDeletingLastPathComponent = [path stringByDeletingLastPathComponent];
        NSFileManager *v6 = [[NSFileManager alloc] init];
        if (![v6 fileExistsAtPath:stringByDeletingLastPathComponent]) {
            [v6 createDirectoryAtPath:stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil];
            NSDictionary *attributes = @{NSFileProtectionKey: NSFileProtectionNone};
            [v6 setAttributes:attributes ofItemAtPath:stringByDeletingLastPathComponent error:nil];
        }
        [v0 writeToFile:path options:NSDataWritingAtomic | NSDataWritingFileProtectionNone error:nil];
    }
}


void -[FBPlistApplicationDataStoreRepository _notifyDelegateOfChangeForKeys:application:](id a1, id a2)
{
    dispatch_async(self->_calloutQueue, ^void(void) {
        id<FBApplicationDataStoreRepositoryDelegate> delegate = [self delegate];
        [delegate objectChangedForKeys:a1 application:a2];
    });
}


void -[FBPlistApplicationDataStoreRepository _notifyDelegateOfStoreInvalidationForIdentifier:](id a1)
{
    dispatch_async(self->_calloutQueue, ^void(void) {
        id<FBApplicationDataStoreRepositoryDelegate> delegate = [self delegate];
        if ([delegate respondsToSelector:@selector(storeInvalidatedForIdentifier:)]) {
            [delegate storeInvalidatedForIdentifier:a1];
        }
    });
}


id<FBApplicationDataStoreRepositoryDelegate> -[FBPlistApplicationDataStoreRepository delegate](void)
{
    return self->_delegate;
}


id -[FBPlistApplicationDataStoreRepository setDelegate:](id a1)
{
    return objc_storeWeak(&self->_delegate, a1);
}


void -[FBPlistApplicationDataStoreRepository .cxx_destruct](void)
{
    self->_calloutQueue = nil;
    self->_writeQueue = nil;
    self->_stateQueue = nil;
    self->_delegate = nil;
    self->_state = nil;
    self->_storeURL = nil;
}
