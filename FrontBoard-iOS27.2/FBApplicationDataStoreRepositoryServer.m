struct FBApplicationDataStoreRepositoryServer {
    id<FBApplicationDataStoreRepository> _dataStore; // +0x38
    FBServiceClientAuthenticator *_connectionAuthenticator; // +0x40
};

FBApplicationDataStoreRepositoryServer *+[FBApplicationDataStoreRepositoryServer sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        if (![FBSApplicationDataStore isServerProcess]) {
            return;
        }
        sharedInstance.__shared = [[FBApplicationDataStoreRepositoryServer alloc] _init];
    });
    return sharedInstance.__shared;
}


FBApplicationDataStoreRepositoryServer *-[FBApplicationDataStoreRepositoryServer _init](void)
{
    const char *label = [@"FBApplicationDataStoreRepositoryServer" UTF8String];
    dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_autorelease_frequency(nil, DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM);
    dispatch_queue_t v2 = dispatch_queue_create(label, attr);
    id userInitiated = [BSServiceQuality userInitiated];
    FBApplicationDataStoreRepositoryServer *v6 = [super initWithIdentifier:FBApplicationDataStoreServiceIdentifier queue:[BSServiceDispatchQueue queueWithName:@"FBApplicationDataStoreRepositoryServer" serviceQuality:userInitiated targetQueue:v2]];
    if (v6 != nil) {
        id sharedInstance = [FBApplicationDataStoreRepositoryManager sharedInstance];
        v6->_dataStore = [sharedInstance dataStore];
        v6->_connectionAuthenticator = [FBServiceClientAuthenticator sharedSystemClientAuthenticator];
    }
    return v6;
}


long -[FBApplicationDataStoreRepositoryServer _prerequisiteMilestones](void)
{
    return 0;
}


long -[FBApplicationDataStoreRepositoryServer shouldAllowClientConnection:withMessage:](long a1, long a2)
{
    return [self->_connectionAuthenticator authenticateClient:a1];
}


void -[FBApplicationDataStoreRepositoryServer noteClientDidConnect:withMessage:](id a1, long a2)
{
    FBApplicationDataStoreRepositoryServerClientContext *v1 = [[FBApplicationDataStoreRepositoryServerClientContext alloc] initWithDataStore:self->_dataStore];
    [v1 setDelegate:self];
    [a1 setContext:v1];
}


void -[FBApplicationDataStoreRepositoryServer noteClientDidDisconnect:](id a1)
{
    id context = [a1 context];
    [context setDelegate:nil];
}


void -[FBApplicationDataStoreRepositoryServer noteDidReceiveMessage:withType:fromClient:](id a1, long a2, id a3)
{
    id context = [a3 context];
    if (a2 <= 3) {
        if (a2 > 1) {
            if (a2 == 2) {
                [self _handleMigrateIdentifier:a1];
            } else if (a2 == 3) {
                [self _handleGetObjectForKey:a1];
            }
        } else if (!a2) {
            [self _handleSynchronize:a1];
        } else if (a2 == 1) {
            [self _handleGetAvailableDataStores:a1];
        }
    } else if (a2 <= 5) {
        if (a2 == 4) {
            [self _handleSetObjectForKey:a1 context:context];
        } else if (a2 == 5) {
            [self _handleRemoveObjectForKey:a1 context:context];
        }
    } else {
        switch (a2) {
            case 6:
                [self _handleRemoveAllObjects:a1];
                break;
            case 8:
                [self _handleSetChangesInterest:a1 context:context];
                break;
            case 7:
                [self _handleSetPrefetchedKeys:a1 context:context];
                break;
        }
    }
}


void -[FBApplicationDataStoreRepositoryServer _handleSetPrefetchedKeys:context:](id a1, id a2)
{
    id payload = [a1 payload];
    id v3 = BSDeserializeCFValueFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyPrefetchedKeys);
    NSSet *v4 = (![v3 isKindOfClass:[NSArray class]]) ? nil : [NSSet setWithArray:v3];
    [a2 setPrefetchedKeys:v4];
    [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        NSArray *allObjects = [v4 allObjects];
        id v6 = [self->_dataStore allObjectsForKeys:allObjects];
        if (v6 != 0) {
            BSSerializeCFValueToXPCDictionaryWithKey(v6, arg1, FBSApplicationDataStoreMessageKeyPrefetchedKeys);
        }
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleSetChangesInterest:context:](id a1, id a2)
{
    xpc_object_t xdict = [a1 payload];
    bool v3 = xpc_dictionary_get_bool(xdict, FBSApplicationDataStoreMessageKeyAllChangesInterest);
    [a2 setInterestedInAllChanges:v3];
    [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleSynchronize:](id a1)
{
    [self->_dataStore flushSynchronously];
    [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
    }];
}


long -[FBApplicationDataStoreRepositoryServer _handleGetAvailableDataStores:](id a1)
{
    return [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        NSArray *v1 = [self->_dataStore applicationIdentifiersWithState];
        if (!v1) {
            v1 = [NSArray array];
        }
        BSSerializeCFValueToXPCDictionaryWithKey(v1, arg1, FBSApplicationDataStoreMessageKeyAppIDs);
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleMigrateIdentifier:](id a1)
{
    NSError *v4;
    id payload = [a1 payload];
    id v2 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID);
    id v3 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID2);
    if (v2 != nil && v3 != nil) {
        v4 = [self->_dataStore migrateIdentifier:v2 toIdentifier:v3];
    } else {
        NSDictionary *v7 = @{NSLocalizedFailureReasonErrorKey: @"Invalid parameters "};
        v4 = [NSError errorWithDomain:@"FBApplicationDataStore" code:1 userInfo:v7];
    }
    [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        BSSerializeNSSecureEncodableObjectToXPCDictionaryWithKey(v4);
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleGetObjectForKey:](id a1)
{
    id payload = [a1 payload];
    id v2 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyKey);
    id v3 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID);
    [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        if (v2 != nil && v3 != nil) {
            id v5 = [self->_dataStore objectForKey:v2 forApplication:v3];
            if (v5 != 0) {
                BSSerializeCFValueToXPCDictionaryWithKey(v5, arg1, FBSApplicationDataStoreMessageKeyObject);
            }
        }
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleSetObjectForKey:context:](id a1, long a2)
{
    id v0 = a1;
    [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        id payload2 = [v0 payload];
        id v6 = BSCreateDeserializedCFValueFromXPCDictionaryWithKey(payload2, FBSApplicationDataStoreMessageKeyObject);
        if (v6 != 0) {
            id payload = [v0 payload];
            id v3 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyKey);
            id v4 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID);
            [self->_dataStore setObject:v6 forKey:v3 forApplication:v4];
        }
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleRemoveObjectForKey:context:](id a1, long a2)
{
    id v0 = a1;
    [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        id payload = [v0 payload];
        id v4 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyKey);
        id v2 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID);
        [self->_dataStore removeObjectForKey:v4 forApplication:v2];
    }];
}


void -[FBApplicationDataStoreRepositoryServer _handleRemoveAllObjects:](id a1)
{
    id v0 = a1;
    [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        id payload = [v0 payload];
        id v3 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSApplicationDataStoreMessageKeyAppID);
        [self->_dataStore removeAllObjectsForApplication:v3];
    }];
}


void -[FBApplicationDataStoreRepositoryServer applicationDataStoreRepositoryClientContext:valueChangedForObject:key:appID:](id a1, id a2, id a3, id a4)
{
    id v0 = a2;
    id v1 = a3;
    id v2 = a4;
    id clientHandle = [a1 clientHandle];
    if (clientHandle != nil) {
        id v5 = [FBSXPCMessage messageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
            const char *string = [v1 UTF8String];
            xpc_dictionary_set_string(arg1, FBSApplicationDataStoreMessageKeyKey, string);
            const char *string2 = [v2 UTF8String];
            xpc_dictionary_set_string(arg1, FBSApplicationDataStoreMessageKeyAppID, string2);
            NSNull *null = [NSNull null];
            BOOL v11 = [v0 isEqual:null];
            if (!v11) {
                BSSerializeCFValueToXPCDictionaryWithKey(v0, arg1, FBSApplicationDataStoreMessageKeyObject);
            }
        }];
        NSSet<id> *v6 = [NSSet setWithObject:clientHandle];
        [self sendMessage:v5 withType:9 toClients:v6];
    }
}


void -[FBApplicationDataStoreRepositoryServer applicationDataStoreRepositoryClientContext:repositoryInvalidatedForAppID:](id a1, id a2)
{
    id v0 = a2;
    id clientHandle = [a1 clientHandle];
    if (clientHandle != nil) {
        id v3 = [FBSXPCMessage messageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
            const char *string = [v0 UTF8String];
            xpc_dictionary_set_string(arg1, FBSApplicationDataStoreMessageKeyAppID, string);
        }];
        NSSet<id> *v4 = [NSSet setWithObject:clientHandle];
        [self sendMessage:v3 withType:10 toClients:v4];
    }
}


id<FBApplicationDataStoreRepository> -[FBApplicationDataStoreRepositoryServer dataStore](void)
{
    return self->_dataStore;
}


void -[FBApplicationDataStoreRepositoryServer setDataStore:](id<FBApplicationDataStoreRepository> a1)
{
    self->_dataStore = a1;
}


void -[FBApplicationDataStoreRepositoryServer .cxx_destruct](void)
{
    self->_connectionAuthenticator = nil;
    self->_dataStore = nil;
}
