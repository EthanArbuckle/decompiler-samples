struct FBSqliteApplicationDataStoreRepository {
    NSURL *_storeURL; // +0x8
    __weak id<FBApplicationDataStoreRepositoryDelegate> _delegate; // +0x10
    NSObject<OS_dispatch_queue> *_dbQueue; // +0x18
    BSSqliteDatabaseConnection *_dbQueue_dbConnection; // +0x20
    unsigned long _dbQueue_batchDepth; // +0x28
    int _dbQueue_firstUnlockToken; // +0x30
    NSObject<OS_dispatch_queue> *_calloutQueue; // +0x38
};

void -[FBSqliteApplicationDataStoreRepository _dbQueue_performWithSavepoint:handler:](NSString *a1, bool (^a2)(void))
{
    NSString *v2 = [NSString stringWithFormat:@"SAVEPOINT %@", a1];
    [self _dbQueue_executeStatement:v2 bindings:0 resultRowHandler:0];
    bool v3 = a2();
    NSString *v5 = (v3) ? @"RELEASE SAVEPOINT %@" : @"ROLLBACK TO SAVEPOINT %@";
    NSString *v4 = [NSString stringWithFormat:v5, a1];
    [self _dbQueue_executeStatement:v4 bindings:0 resultRowHandler:0];
}


void -[FBSqliteApplicationDataStoreRepository setObject:forKey:forApplication:](id a1, id a2, id a3)
{
    id v1 = a2;
    id v2 = a3;
    if (!a1) {
        [self removeObjectForKey:v1 forApplication:v2];
    } else if (v1 != nil && v2 != nil && [self _isEligibleForSaving:a1] != 0) {
        id v3 = a1;
        if ([[self class] _objectRequiresSerialization:a1] != 0) {
            NSData *v4 = [NSPropertyListSerialization dataWithPropertyList:v3 format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
            v3 = v4;
            if (!v4) {
                NSString *v6 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"objectToStore != nil"];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v7 = NSStringFromSelector(_cmd);
                    NSString *v8 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v7, v8, self, @"FBSqliteApplicationDataStoreRepository.m", 0x100, v6);
                }
                _bs_set_crash_log_message([v6 UTF8String]);
                __break(0);
            }
        }
        dispatch_async(self->_dbQueue, ^void(void) {
            [self _dbQueue_performWithSavepoint:@"setObject" handler:^bool(void) {
                NSString *v10 = ([self _dbQueue_containsKey:v1 forApplication:v2] != 0) ? @"UPDATE kvs SET value = :value WHERE     application_identifier IN (SELECT id FROM application_identifier_tab WHERE application_identifier = :application_identifier)     AND key IN (SELECT id FROM key_tab WHERE key = :key);" : @"INSERT OR IGNORE INTO application_identifier_tab (application_identifier) VALUES (:application_identifier);INSERT OR IGNORE INTO key_tab (key) VALUES (:key);INSERT INTO kvs (application_identifier, key, value)    SELECT application_identifier_tab.id, key_tab.id, :value FROM application_identifier_tab, key_tab WHERE         application_identifier_tab.application_identifier = :application_identifier        AND key_tab.key = :key;";
                NSDictionary<NSString *, id> *v11 = @{@":application_identifier": v2, @":key": v1, @":value": v3};
                [self _dbQueue_executeStatement:v10 bindings:v11 resultRowHandler:0];
                NSArray *v12 = @[v1];
                [self _dbQueue_notifyDelegateOfChangeForKeys:v12 application:v2];
                return 1;
            }];
        });
    }
}


id +[FBSqliteApplicationDataStoreRepository _objectForResultRow:index:](id a1, NSUInteger a2)
{
    id v0 = [a1 objectAtIndex:a2];
    id v1 = (![v0 isKindOfClass:[NSData class]]) ? v0 : [NSPropertyListSerialization propertyListWithData:v0 options:0 format:NULL error:nil];
    return v1;
}


long -[FBSqliteApplicationDataStoreRepository _dbQueue_executeStatement:bindings:resultRowHandler:](id a1, id a2, long a3)
{
    id v2 = nil;
    long v3 = [self _dbQueue_executeStatement:a1 bindings:a2 resultRowHandler:a3 error:&v2];
    if ((v3 & 1) == 0) {
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Received unexpected query error %{public}@ for query %{public}@ bindings %@", v2, a1, a2);
        }
    }
    return v3;
}


bool +[FBSqliteApplicationDataStoreRepository _objectRequiresSerialization:](id a1)
{
    bool v1 = (![a1 isKindOfClass:[NSNumber class]]) ? ![a1 isKindOfClass:[NSString class]] : false;
    return v1;
}


id -[FBSqliteApplicationDataStoreRepository objectForKey:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    id v2 = nil;
    if (v0 != nil && v1 != nil) {
        __block id v3 = nil;
        dispatch_sync(self->_dbQueue, ^void(void) {
            id v6 = [self _dbQueue_objectForKey:v0 forApplication:v1];
            v3 = v6;
        });
        v2 = v3;
    }
    return v2;
}


long -[FBSqliteApplicationDataStoreRepository _dbQueue_executeStatement:bindings:resultRowHandler:error:](long a1, id a2, id a3, long a4)
{
    id v2 = [self->_dbQueue_dbConnection prepareStatement:a1];
    long v3 = (!v2) ? 0 : [v2 executeWithBindings:a2 resultRowHandler:a3 error:a4];
    return v3;
}


void -[FBSqliteApplicationDataStoreRepository removeObjectForKey:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    if (v0 != nil && a2 != nil) {
        dispatch_async(self->_dbQueue, ^void(void) {
            NSDictionary<NSString *, id> *v5 = @{@":application_identifier": v1, @":key": v0};
            [self _dbQueue_executeStatement:@"DELETE FROM kvs WHERE     application_identifier IN (SELECT id FROM application_identifier_tab WHERE application_identifier = :application_identifier)     AND key IN (SELECT id FROM key_tab WHERE key = :key);" bindings:v5 resultRowHandler:0];
            NSArray *v4 = @[v0];
            [self _dbQueue_notifyDelegateOfChangeForKeys:v4 application:v1];
        });
    }
}


int -[FBSqliteApplicationDataStoreRepository _isEligibleForSaving:](id a1)
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


id -[FBSqliteApplicationDataStoreRepository _dbQueue_objectForKey:forApplication:](id a1, id a2)
{
    dispatch_assert_queue(self->_dbQueue);
    if (!a1) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"key"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBSqliteApplicationDataStoreRepository.m", 636, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"identifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBSqliteApplicationDataStoreRepository.m", 637, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    __block id v2 = nil;
    NSDictionary<NSString *, id> *v6 = @{@":application_identifier": a2, @":key": a1};
    [self _dbQueue_executeStatement:@"SELECT value FROM kvs, application_identifier_tab, key_tab WHERE    application_identifier_tab.application_identifier = :application_identifier    AND key_tab.key = :key    AND kvs.application_identifier = application_identifier_tab.id    AND kvs.key = key_tab.id;" bindings:v6 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        id v16 = [[self class] _objectForResultRow:arg1 index:0];
        v2 = v16;
    }];
    return v2;
}


bool -[FBSqliteApplicationDataStoreRepository _dbQueue_containsKey:forApplication:](id a1, id a2)
{
    dispatch_assert_queue(self->_dbQueue);
    if (!a1) {
        NSString *v9 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"key"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v10 = NSStringFromSelector(_cmd);
            NSString *v11 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v10, v11, self, @"FBSqliteApplicationDataStoreRepository.m", 650, v9);
        }
        _bs_set_crash_log_message([v9 UTF8String]);
        __break(0);
    }
    if (!a2) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"identifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBSqliteApplicationDataStoreRepository.m", 651, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    __block bool v2 = false;
    NSDictionary<NSString *, id> *v6 = @{@":application_identifier": a2, @":key": a1};
    [self _dbQueue_executeStatement:@"SELECT 1 FROM kvs, application_identifier_tab, key_tab WHERE    application_identifier_tab.application_identifier = :application_identifier    AND key_tab.key = :key    AND kvs.application_identifier = application_identifier_tab.id    AND kvs.key = key_tab.id;" bindings:v6 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        v2 = true;
    }];
    return v2;
}


FBSqliteApplicationDataStoreRepository *-[FBSqliteApplicationDataStoreRepository initWithStorePath:](NSURL *a1)
{
    FBSqliteApplicationDataStoreRepository *v1 = [super init];
    if (v1 != nil) {
        v1->_storeURL = a1;
        v1->_dbQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.applicationdatastore.database");
        v1->_calloutQueue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.applicationdatastore.callout");
        v1->_dbQueue_firstUnlockToken = -1;
        dispatch_async(v1->_dbQueue, ^void(void) {
            [v1 _dbQueue_load];
        });
    }
    return v1;
}


void -[FBSqliteApplicationDataStoreRepository dealloc](void)
{
    notify_cancel(self->_dbQueue_firstUnlockToken);
    dispatch_async(self->_dbQueue, ^void(void) {
        [self->_dbQueue_dbConnection close];
    });
    [super dealloc];
}


id -[FBSqliteApplicationDataStoreRepository delegate](void)
{
    __block id v0 = nil;
    dispatch_sync(self->_dbQueue, ^void(void) {
        id<FBApplicationDataStoreRepositoryDelegate> v4 = self->_delegate;
        v0 = v4;
    });
    return v0;
}


void -[FBSqliteApplicationDataStoreRepository setDelegate:](id<FBApplicationDataStoreRepositoryDelegate> a1)
{
    dispatch_async(self->_dbQueue, ^void(void) {
        self->_delegate = a1;
    });
}


id -[FBSqliteApplicationDataStoreRepository applicationIdentifiersWithState](void)
{
    __block id v0 = nil;
    dispatch_sync(self->_dbQueue, ^void(void) {
        id _dbQueue_applicationIdentifiersWithState = [self _dbQueue_applicationIdentifiersWithState];
        v0 = _dbQueue_applicationIdentifiersWithState;
    });
    return v0;
}


NSArray *-[FBSqliteApplicationDataStoreRepository keysForApplication:](id a1)
{
    id v0 = a1;
    if (!a1) {
        return @[];
    }
    __block id v2 = nil;
    dispatch_sync(self->_dbQueue, ^void(void) {
        id v5 = [self _dbQueue_keysForApplication:v0];
        v2 = v5;
    });
    NSArray *v1 = v2;
    return v1;
}


bool -[FBSqliteApplicationDataStoreRepository containsKey:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    unsigned char v2 = 0;
    if (v0 != nil && v1 != nil) {
        __block unsigned char v3 = 0;
        dispatch_sync(self->_dbQueue, ^void(void) {
            v3 = [self _dbQueue_containsKey:v0 forApplication:v1];
        });
        v2 = v3;
    }
    return v2;
}


id -[FBSqliteApplicationDataStoreRepository allObjectsForKeys:](id a1)
{
    id v0 = a1;
    if (![a1 count]) {
        return nil;
    }
    __block id v2 = nil;
    dispatch_sync(self->_dbQueue, ^void(void) {
        id v5 = [self _dbQueue_objectsForKeys:v0];
        v2 = v5;
    });
    id v1 = v2;
    return v1;
}


void -[FBSqliteApplicationDataStoreRepository close](void)
{
    dispatch_sync(self->_dbQueue, ^void(void) {
        [self->_dbQueue_dbConnection close];
        self->_dbQueue_dbConnection = nil;
    });
}


void -[FBSqliteApplicationDataStoreRepository removeObjectsForKeys:forApplication:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    long count = [v0 count];
    if (v1 != nil && count != 0) {
        dispatch_async(self->_dbQueue, ^void(void) {
            Class v4 = [self class];
            id v5 = nil;
            id v6 = [v4 _generateParameterizedQuery:@"DELETE FROM kvs WHERE     application_identifier IN (SELECT id FROM application_identifier_tab WHERE application_identifier = :application_identifier)     AND key IN (SELECT id FROM key_tab WHERE key IN (%@));" forKeyList:v0 outBindings:&v5];
            [v5 setObject:v1 forKeyedSubscript:@":application_identifier"];
            [self _dbQueue_executeStatement:v6 bindings:v5 resultRowHandler:0];
            [self _dbQueue_notifyDelegateOfChangeForKeys:v0 application:v1];
        });
    }
}


void -[FBSqliteApplicationDataStoreRepository removeAllObjectsForApplication:](id a1)
{
    id v0 = a1;
    if (a1 != nil) {
        dispatch_async(self->_dbQueue, ^void(void) {
            NSDictionary<NSString *, id> *v2 = @{@":application_identifier": v0};
            [self _dbQueue_executeStatement:@"DELETE FROM kvs WHERE     application_identifier IN (SELECT id FROM application_identifier_tab WHERE application_identifier = :application_identifier);" bindings:v2 resultRowHandler:0];
            [self _dbQueue_notifyDelegateOfStoreInvalidationForIdentifier:v0];
        });
    }
}


void -[FBSqliteApplicationDataStoreRepository flushSynchronously](void)
{
    dispatch_sync(self->_dbQueue, ^void(void) {
        [self _dbQueue_executeStatement:@"PRAGMA wal_checkpoint(FULL);" bindings:0 resultRowHandler:0];
    });
}


void -[FBSqliteApplicationDataStoreRepository beginBatchedUpdate](void)
{
    dispatch_async(self->_dbQueue, ^void(void) {
        id v2 = self;
        long v1 = v2->_dbQueue_batchDepth;
        if (!v2->_dbQueue_batchDepth) {
            [v2 _dbQueue_executeStatement:@"PRAGMA cache_size=2000;BEGIN TRANSACTION;" bindings:0 resultRowHandler:0];
            v2 = self;
            v1 = v2->_dbQueue_batchDepth;
        }
        v2->_dbQueue_batchDepth = v1 + 1;
    });
}


void -[FBSqliteApplicationDataStoreRepository endBatchedUpdate](void)
{
    dispatch_async(self->_dbQueue, ^void(void) {
        if (!self->_dbQueue_batchDepth) {
            return;
        }
        self->_dbQueue_batchDepth = self->_dbQueue_batchDepth - 1;
        id v1 = self;
        if (!self->_dbQueue_batchDepth) {
            [v1 _dbQueue_executeStatement:@"COMMIT;PRAGMA cache_size=10;" bindings:0 resultRowHandler:0];
            return;
        }
    });
}


id -[FBSqliteApplicationDataStoreRepository migrateIdentifier:toIdentifier:](id a1, id a2)
{
    [self beginBatchedUpdate];
    __block id v0 = nil;
    dispatch_sync(self->_dbQueue, ^void(void) {
        id v39 = [self _dbQueue_keysForApplication:a1];
        if (![v39 count]) {
            void (^v40)(id<BSErrorConfiguring>) = ^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureReason:@"No store exists for identifier \"%@\"", a1];
            };
            id v3 = [NSError bs_errorWithDomain:@"FBApplicationDataStore" code:1 configuration:v40];
            v0 = v3;
            return;
        }
        id v7 = [self _dbQueue_keysForApplication:a2];
        if ([v7 count] != 0) {
            void (^v14)(id<BSErrorConfiguring>) = ^void(id<BSErrorConfiguring> arg1) {
                [arg1 setFailureReason:@"Store already exists with identifier \"%@\"", a2];
            };
            id v15 = [NSError bs_errorWithDomain:@"FBApplicationDataStore" code:1 configuration:v14];
            v0 = v15;
            return;
        }
        for (id v25 in v39) {
            __block id byref1 = nil;
            NSDictionary<NSString *, id> *v28 = @{@":application_identifier": a1, @":key": v25};
            [self _dbQueue_executeStatement:@"SELECT value FROM kvs, application_identifier_tab, key_tab WHERE    application_identifier_tab.application_identifier = :application_identifier    AND key_tab.key = :key    AND kvs.application_identifier = application_identifier_tab.id    AND kvs.key = key_tab.id;" bindings:v28 resultRowHandler:^void(BSSqliteResultRow *arg1) {
                id v42 = [arg1 objectAtIndex:0];
                byref1 = v42;
            }];
            NSDictionary<NSString *, id> *v32 = @{@":application_identifier": a2, @":key": v25, @":value": byref1};
            [self _dbQueue_executeStatement:@"INSERT OR IGNORE INTO application_identifier_tab (application_identifier) VALUES (:application_identifier);INSERT OR IGNORE INTO key_tab (key) VALUES (:key);INSERT INTO kvs (application_identifier, key, value)    SELECT application_identifier_tab.id, key_tab.id, :value FROM application_identifier_tab, key_tab WHERE         application_identifier_tab.application_identifier = :application_identifier        AND key_tab.key = :key;" bindings:v32 resultRowHandler:0];
        }
        NSDictionary<NSString *, id> *v36 = @{@":application_identifier": a1};
        [self _dbQueue_executeStatement:@"DELETE FROM kvs WHERE     application_identifier IN (SELECT id FROM application_identifier_tab WHERE application_identifier = :application_identifier);" bindings:v36 resultRowHandler:0];
        NSArray *v38 = @[v39];
        [self _dbQueue_notifyDelegateOfChangeForKeys:v38 application:a2];
        [self _dbQueue_notifyDelegateOfStoreInvalidationForIdentifier:a1];
    });
    [self endBatchedUpdate];
    return v0;
}


void -[FBSqliteApplicationDataStoreRepository _dbQueue_load](void)
{
    long _dbQueue_loadDatabase = [self _dbQueue_loadDatabase];
    os_log_t log = FBLogAppDataStore();
    bool v2 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (!_dbQueue_loadDatabase) {
        if (v2) {
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Waiting to load application data store for first unlock.");
        }
        __weak id v3 = self;
        notify_register_dispatch("com.apple.mobile.keybagd.first_unlock", &self->_dbQueue_firstUnlockToken, self->_dbQueue, ^void(int arg1) {
            long _dbQueue_loadDatabase = [v3 _dbQueue_loadDatabase];
            os_log_t oslog = FBLogAppDataStore();
            if (!_dbQueue_loadDatabase) {
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_FAULT)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_FAULT, "Attempt to open database after first unlock failed.");
                }
            } else {
                if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                    os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Successfully loaded application data store after first unlock.");
                }
                [self _dbQueue_notifyDelegateOfLateLoad];
            }
            v3->_dbQueue_firstUnlockToken = -1;
            notify_cancel(arg1);
        });
    } else if (v2) {
        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Successfully loaded application data store.");
    }
}


int -[FBSqliteApplicationDataStoreRepository _dbQueue_databaseIntegrityCheck](void)
{
    os_log_t v5;
    int v6;
    dispatch_assert_queue(self->_dbQueue);
    NSMutableArray *v0 = [[NSMutableArray alloc] init];
    id v2 = nil;
    long v3 = [self _dbQueue_executeStatement:@"PRAGMA quick_check;" bindings:0 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        id v9 = [arg1 stringAtIndex:0];
        [v0 addObject:v9];
    } error:&v2];
    if (!v3) {
        v5 = FBLogAppDataStore();
        if (os_log_type_enabled(v5, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v5, OS_LOG_TYPE_ERROR, "Database failed to perform integrity check with error: %{public}@", v2);
        }
        v6 = v3 ^ 1;
    } else {
        if (![v0 isEqualToArray:@[@"ok"]]) {
            v5 = FBLogAppDataStore();
            if (os_log_type_enabled(v5, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(v5, OS_LOG_TYPE_ERROR, "Database failed integrity check with errors: %{public}@", v0);
                return v3 ^ 1;
            }
            return v3 ^ 1;
        }
        v6 = 1;
    }
    return v6;
}


BSSqliteDatabaseConnection *-[FBSqliteApplicationDataStoreRepository _dbQueue_openDatabase](void)
{
    dispatch_assert_queue(self->_dbQueue);
    BSSqliteDatabaseConnection *v0 = [BSSqliteDatabaseConnection alloc];
    BSSqliteDatabaseConnection *v1 = (!self->_storeURL) ? [v0 initWithInMemoryDatabase] : [v0 initWithFileURL:self->_storeURL dataProtectionClass:1];
    if (!v1) {
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            NSURL *v2 = self->_storeURL;
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Failed to open application data store %{public}@", v2);
        }
    }
    return v1;
}


NSURL *-[FBSqliteApplicationDataStoreRepository urlByAppendingString:toURL:](NSString *a1, id a2)
{
    NSString *lastPathComponent = [a2 lastPathComponent];
    NSURL *URLByDeletingLastPathComponent = [a2 URLByDeletingLastPathComponent];
    NSString *pathComponent = [lastPathComponent stringByAppendingString:a1];
    return [URLByDeletingLastPathComponent URLByAppendingPathComponent:pathComponent];
}


BOOL -[FBSqliteApplicationDataStoreRepository _preserveFileAtURL:](NSURL *a1)
{
    os_log_t v6;
    if (!os_variant_has_internal_content("-[FBSqliteApplicationDataStoreRepository _preserveFileAtURL:]")) {
        return YES;
    }
    NSURL *v2 = [a1 URLByAppendingPathExtension:@"damaged"];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtURL:v2 error:nil];
    NSError *error = nil;
    BOOL v1 = [defaultManager copyItemAtURL:a1 toURL:v2 error:&error];
    if (!v1) {
        v6 = FBLogAppDataStore();
        if (os_log_type_enabled(v6, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v6, OS_LOG_TYPE_ERROR, "Error copying damaged database file from URL %{public}@ to URL %{public}@: %{public}@", a1, v2, error);
        }
    } else {
        NSError *v9 = error;
        if (![v2 setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&v9]) {
            v6 = FBLogAppDataStore();
            if (os_log_type_enabled(v6, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(v6, OS_LOG_TYPE_ERROR, "Error marking URL %{public}@ as excluded from backup %{public}@", v2, v9);
            }
        }
    }
    return v1;
}


int -[FBSqliteApplicationDataStoreRepository _dbQueue_tryPreserveDamagedDatabase](void)
{
    if (!self->_storeURL) {
        return 1;
    }
    id v1 = [self urlByAppendingString:@"-wal" toURL:self->_storeURL];
    id v2 = [self urlByAppendingString:@"-shm" toURL:self->_storeURL];
    long v3 = [self _preserveFileAtURL:self->_storeURL];
    long v4 = [self _preserveFileAtURL:v1];
    long v5 = [self _preserveFileAtURL:v2];
    return v4 & v5 & v3;
}


long -[FBSqliteApplicationDataStoreRepository _dbQueue_truncateDamagedDatabase](void)
{
    id v0 = nil;
    long v1 = [self->_dbQueue_dbConnection truncateDatabaseAndReturnError:&v0];
    if ((v1 & 1) == 0) {
        os_log_t oslog = FBLogAppDataStore();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Error truncating databse file: %{public}@", v0);
        }
    }
    return v1;
}


long -[FBSqliteApplicationDataStoreRepository _dbQueue_loadDatabase](void)
{
    dispatch_assert_queue(self->_dbQueue);
    self->_dbQueue_dbConnection = [self _dbQueue_openDatabase];
    if (!self->_dbQueue_dbConnection) {
        return 0;
    }
    if (([self _inAlternateSystemApp] & 1) == 0 && ([self _dbQueue_databaseIntegrityCheck] & 1) == 0) {
        ADClientAddValueForScalarKey(@"com.apple.frontboard.appsdatastore.database.corrupted");
        [self->_dbQueue_dbConnection close];
        self->_dbQueue_dbConnection = nil;
        [self _dbQueue_tryPreserveDamagedDatabase];
        self->_dbQueue_dbConnection = [self _dbQueue_openDatabase];
        if (!self->_dbQueue_dbConnection) {
            return 0;
        }
        long _dbQueue_truncateDamagedDatabase = [self _dbQueue_truncateDamagedDatabase];
        if (!_dbQueue_truncateDamagedDatabase) {
            return _dbQueue_truncateDamagedDatabase;
        }
        long _dbQueue_databaseIntegrityCheck = [self _dbQueue_databaseIntegrityCheck];
        os_log_t oslog = FBLogAppDataStore();
        if ((_dbQueue_databaseIntegrityCheck & 1) == 0) {
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Database integrity check failed after starting fresh");
            }
            return 0;
        }
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Successfully truncated damaged database");
        }
        ADClientAddValueForScalarKey(@"com.apple.frontboard.appsdatastore.database.set-aside");
    }
    [self _dbQueue_executeStatement:@"PRAGMA busy_timeout=1000000" bindings:0 resultRowHandler:0];
    [self _dbQueue_executeStatement:@"PRAGMA journal_mode=WAL;" bindings:0 resultRowHandler:0];
    [self _dbQueue_executeStatement:@"PRAGMA synchronous=NORMAL;" bindings:0 resultRowHandler:0];
    [self _dbQueue_executeStatement:@"PRAGMA cache_size=10;" bindings:0 resultRowHandler:0];
    [self _dbQueue_performWithSavepoint:@"schema" handler:^bool(void) {
        if ([self _dbQueue_databaseVersion] <= 0) {
            [self _dbQueue_createTables];
        }
        return true;
    }];
    [self _dbQueue_executeStatement:@"PRAGMA foreign_keys=ON;" bindings:0 resultRowHandler:0];
    [self _dbQueue_executeStatement:@"DELETE FROM application_identifier_tab WHERE application_identifier_tab.id NOT IN (SELECT DISTINCT application_identifier FROM kvs);DELETE FROM key_tab WHERE key_tab.id NOT IN (SELECT DISTINCT key FROM kvs);" bindings:0 resultRowHandler:0];
    return 1;
}


id -[FBSqliteApplicationDataStoreRepository _dbQueue_applicationIdentifiersWithState](void)
{
    dispatch_assert_queue(self->_dbQueue);
    NSMutableArray *v0 = [[NSMutableArray alloc] init];
    [self _dbQueue_executeStatement:@"SELECT application_identifier_tab.application_identifier FROM application_identifier_tab WHERE    application_identifier_tab.id IN (SELECT DISTINCT application_identifier FROM kvs)" bindings:0 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        id v3 = [arg1 stringAtIndex:0];
        [v0 addObject:v3];
    }];
    return [v0 copy];
}


id -[FBSqliteApplicationDataStoreRepository _dbQueue_keysForApplication:](id a1)
{
    dispatch_assert_queue(self->_dbQueue);
    if (!a1) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"identifier"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSqliteApplicationDataStoreRepository.m", 676, v7);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    NSMutableArray *v1 = [[NSMutableArray alloc] init];
    NSDictionary<NSString *, id> *v4 = @{@":application_identifier": a1};
    [self _dbQueue_executeStatement:@"SELECT key_tab.key FROM kvs,key_tab,application_identifier_tab WHERE    application_identifier_tab.application_identifier = :application_identifier    AND kvs.application_identifier = application_identifier_tab.id    AND kvs.key = key_tab.id;" bindings:v4 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        id v9 = [arg1 stringAtIndex:0];
        [v1 addObject:v9];
    }];
    return [v1 copy];
}


NSString *+[FBSqliteApplicationDataStoreRepository _generateParameterizedQuery:forKeyList:outBindings:](id a1, id a2, NSMutableDictionary **a3)
{
    if (!a3) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outBindings"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v16 = NSStringFromSelector(_cmd);
            NSString *v17 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v16, v17, self, @"FBSqliteApplicationDataStoreRepository.m", 691, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    if (![a2 count]) {
        NSString *v18 = [NSString stringWithFormat:@"key list must contain at least one key"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v19 = NSStringFromSelector(_cmd);
            NSString *v20 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v19, v20, self, @"FBSqliteApplicationDataStoreRepository.m", 692, v18);
        }
        _bs_set_crash_log_message([v18 UTF8String]);
        __break(0);
    }
    long count = [a2 count];
    NSMutableDictionary *v3 = [[NSMutableDictionary alloc] initWithCapacity:count];
    long v7 = 0;
    for (id v9 in a2) {
        NSString *key = [NSString stringWithFormat:@":k%lu", v7];
        v7++;
        [v3 setObject:v9 forKeyedSubscript:key];
    }
    NSArray *allKeys = [v3 allKeys];
    NSString *v13 = [allKeys componentsJoinedByString:@","];
    NSString *v14 = [a1 stringByReplacingOccurrencesOfString:@"%@" withString:v13];
    *(a3) = v3;
    return v14;
}


id -[FBSqliteApplicationDataStoreRepository _dbQueue_objectsForKeys:](NSArray<id<NSCopying>> *a1)
{
    dispatch_assert_queue(self->_dbQueue);
    if (!a1) {
        NSString *v10 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"keys"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v11 = NSStringFromSelector(_cmd);
            NSString *v12 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v11, v12, self, @"FBSqliteApplicationDataStoreRepository.m", 714, v10);
        }
        _bs_set_crash_log_message([v10 UTF8String]);
        __break(0);
    }
    id v1 = [NSMutableDictionary sharedKeySetForKeys:a1];
    Class v2 = [self class];
    id v3 = nil;
    id v4 = [v2 _generateParameterizedQuery:@"SELECT application_identifier_tab.application_identifier, key_tab.key, kvs.value FROM kvs, application_identifier_tab, key_tab WHERE    key_tab.key IN (%@)    AND kvs.application_identifier = application_identifier_tab.id    AND kvs.key = key_tab.id;" forKeyList:a1 outBindings:&v3];
    NSMutableDictionary *v6 = [[NSMutableDictionary alloc] init];
    [self _dbQueue_executeStatement:v4 bindings:v3 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        id<NSCopying> key = [arg1 stringAtIndex:0];
        id v16 = [arg1 stringAtIndex:1];
        id v17 = [[self class] _objectForResultRow:arg1 index:2];
        if (v17 != nil && v16 != nil && key != nil) {
            id v18 = [v6 objectForKeyedSubscript:key];
            if (!v18) {
                NSMutableDictionary *obj = [NSMutableDictionary dictionaryWithSharedKeySet:v1];
                v18 = obj;
                [v6 setObject:obj forKeyedSubscript:key];
            }
            [v18 setObject:v17 forKeyedSubscript:v16];
        }
    }];
    return [v6 copy];
}


void -[FBSqliteApplicationDataStoreRepository _dbQueue_notifyDelegateOfChangeForKeys:application:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    id<FBApplicationDataStoreRepositoryDelegate> v2 = self->_delegate;
    if (v2 != nil) {
        dispatch_async(self->_calloutQueue, ^void(void) {
            [v2 objectChangedForKeys:v0 application:v1];
        });
    }
}


void -[FBSqliteApplicationDataStoreRepository _dbQueue_notifyDelegateOfStoreInvalidationForIdentifier:](id a1)
{
    id v0 = a1;
    id<FBApplicationDataStoreRepositoryDelegate> v1 = self->_delegate;
    if (v1 != nil) {
        dispatch_async(self->_calloutQueue, ^void(void) {
            [v1 storeInvalidatedForIdentifier:v0];
        });
    }
}


void -[FBSqliteApplicationDataStoreRepository _dbQueue_notifyDelegateOfLateLoad](void)
{
    id<FBApplicationDataStoreRepositoryDelegate> v0 = self->_delegate;
    if (v0 != nil) {
        id _dbQueue_applicationIdentifiersWithState = [self _dbQueue_applicationIdentifiersWithState];
        for (id v9 in _dbQueue_applicationIdentifiersWithState) {
            id v10 = [self _dbQueue_keysForApplication:v9];
            dispatch_async(self->_calloutQueue, ^void(void) {
                [v0 objectChangedForKeys:v10 application:v9];
            });
        }
    }
}


long -[FBSqliteApplicationDataStoreRepository _dbQueue_databaseVersion](void)
{
    __block long v0 = -1;
    [self _dbQueue_executeStatement:@"SELECT version FROM schema" bindings:0 resultRowHandler:^void(BSSqliteResultRow *arg1) {
        v0 = [arg1 integerAtIndex:0];
    } error:0];
    return v0;
}


void -[FBSqliteApplicationDataStoreRepository _dbQueue_createTables](void)
{
    os_log_t oslog = FBLogAppDataStore();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Creating new database tables.");
    }
    [self _dbQueue_performWithSavepoint:@"createTables" handler:^bool(void) {
        id v5 = nil;
        long v6 = [self _dbQueue_executeStatement:@"CREATE TABLE schema(version INT NOT NULL);INSERT INTO schema (version) VALUES (1);CREATE TABLE key_tab (id INTEGER PRIMARY KEY, key TEXT NOT NULL, UNIQUE(key));CREATE TABLE application_identifier_tab (id INTEGER PRIMARY KEY, application_identifier TEXT NOT NULL, UNIQUE(application_identifier));CREATE TABLE kvs (    id INTEGER PRIMARY KEY,    application_identifier INT REFERENCES application_identifier_tab(id),    key INT REFERENCES key_tab(id),    value BLOB,    UNIQUE(application_identifier, key));CREATE INDEX kvs_keys ON kvs(key);CREATE INDEX kvs_application_identifiers ON kvs(application_identifier);CREATE VIEW kvs_debug AS     SELECT application_identifier_tab.application_identifier, key_tab.key, value FROM application_identifier_tab, key_tab, kvs WHERE         kvs.application_identifier=application_identifier_tab.id         AND kvs.key=key_tab.id;" bindings:0 resultRowHandler:0 error:&v5];
        if ((v6 & 1) == 0) {
            os_log_t oslog = FBLogAppDataStore();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: received error %{public}@ creating tables (query = %{public}@)", "-[FBSqliteApplicationDataStoreRepository _dbQueue_createTables]_block_invoke", v5, @"CREATE TABLE schema(version INT NOT NULL);INSERT INTO schema (version) VALUES (1);CREATE TABLE key_tab (id INTEGER PRIMARY KEY, key TEXT NOT NULL, UNIQUE(key));CREATE TABLE application_identifier_tab (id INTEGER PRIMARY KEY, application_identifier TEXT NOT NULL, UNIQUE(application_identifier));CREATE TABLE kvs (    id INTEGER PRIMARY KEY,    application_identifier INT REFERENCES application_identifier_tab(id),    key INT REFERENCES key_tab(id),    value BLOB,    UNIQUE(application_identifier, key));CREATE INDEX kvs_keys ON kvs(key);CREATE INDEX kvs_application_identifiers ON kvs(application_identifier);CREATE VIEW kvs_debug AS     SELECT application_identifier_tab.application_identifier, key_tab.key, value FROM application_identifier_tab, key_tab, kvs WHERE         kvs.application_identifier=application_identifier_tab.id         AND kvs.key=key_tab.id;");
            }
        }
        return v6;
    }];
}


bool -[FBSqliteApplicationDataStoreRepository _inAlternateSystemApp](void)
{
    dispatch_once(&_inAlternateSystemApp.onceToken, ^void(void) {
        id defaultShellMachName = [BSServiceConnectionEndpoint defaultShellMachName];
        id environmentAliases = [BSMachServiceAliases environmentAliases];
        NSString *v2 = [environmentAliases resolveMachService:defaultShellMachName];
        _inAlternateSystemApp.inAlternateSystemApp = ![defaultShellMachName isEqualToString:v2];
    });
    return _inAlternateSystemApp.inAlternateSystemApp;
}


void -[FBSqliteApplicationDataStoreRepository .cxx_destruct](void)
{
    self->_calloutQueue = nil;
    self->_dbQueue_dbConnection = nil;
    self->_dbQueue = nil;
    self->_delegate = nil;
    self->_storeURL = nil;
}
