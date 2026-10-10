struct FBSystemAppProxyServiceServer {
    FBServiceClientAuthenticator *_shutdownAuthenticator; // +0x38
};

static long FBApplicationProcessHandleEntitlement;
static long FBApplicationTerminationEntitlement;
static long FBShutdownEntitlement;

BSServiceDispatchQueue *+[FBSystemAppProxyServiceServer targetQueue](void)
{
    id sharedInstance = [FBSystemAppProxyServiceServer sharedInstance];
    return [sharedInstance queue];
}


id +[FBSystemAppProxyServiceServer sharedInstance](void)
{
    dispatch_once(&sharedInstance.onceToken, ^void(void) {
        id userInitiated = [BSServiceQuality userInitiated];
        id v1 = [BSServiceDispatchQueue queueWithName:FBSSystemAppProxyServiceIdentifier serviceQuality:userInitiated];
        sharedInstance.__SharedInstance = [[FBSystemAppProxyServiceServer alloc] _initWithQueue:v1];
    });
    return sharedInstance.__SharedInstance;
}


FBSystemAppProxyServiceServer *-[FBSystemAppProxyServiceServer _initWithQueue:](long a1)
{
    FBSystemAppProxyServiceServer *v1 = [super initWithIdentifier:FBSSystemAppProxyServiceIdentifier queue:a1];
    if (v1 != nil) {
        v1->_shutdownAuthenticator = [[FBServiceClientAuthenticator alloc] initWithEntitlement:FBShutdownEntitlement];
    }
    return v1;
}


long -[FBSystemAppProxyServiceServer _handleSystemApplicationBundleIdentifier:forClient:](id a1, long a2)
{
    return [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        id v1 = FBSystemAppBundleID();
        const char *string = [v1 UTF8String];
        xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyBundleIDResult, string);
    }];
}


void -[FBSystemAppProxyServiceServer _handleGetPasscodeLockedOrBlockedStatus:forClient:](id a1, long a2)
{
    id sharedInstance = [FBSystemService sharedInstance];
    BSServiceDispatchQueue *queue = [sharedInstance queue];
    [queue performAsync:^void(void) {
        [sharedInstance isPasscodeLockedOrBlockedWithResult:^void(bool arg1) {
            [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
                xpc_dictionary_set_bool(arg1, FBSSystemServiceMessageKeyBoolResult, arg1);
            }];
        }];
    }];
}


void -[FBSystemAppProxyServiceServer _handleGetProcessHandle:forClient:](id a1, id a2)
{
    os_log_t v4;
    id v9;
    long v7;
    id processHandle = [a2 processHandle];
    long v3 = [processHandle hasEntitlement:FBApplicationProcessHandleEntitlement];
    if ((v3 & 1) == 0) {
        v4 = FBLogCommon();
        if (os_log_type_enabled(v4, OS_LOG_TYPE_DEFAULT)) {
            id processHandle2 = [a2 processHandle];
            id v6 = FBSProcessPrettyDescription(processHandle2);
            os_log_with_type(v4, OS_LOG_TYPE_DEFAULT, "[FBSystemService] %{public}@ is not permitted to acquire application process handles.", v6);
        }
    } else {
        id payload = [a1 payload];
        v4 = BSDeserializeStringFromXPCDictionaryWithKey(payload, FBSSystemServiceMessageKeyBundleID);
        if (!v4) {
            v9 = nil;
        } else {
            id sharedInstance = [FBProcessManager sharedInstance];
            id v11 = [sharedInstance processesForBundleIdentifier:v4];
            v9 = [v11 firstObject];
            if (!v9) {
                id v13 = [RBSProcessPredicate predicateMatchingBundleIdentifier:v4];
                id v14 = [RBSProcessHandle handleForPredicate:v13 error:0];
                if (!v14) {
                    v9 = nil;
                } else {
                    id sharedInstance2 = [FBProcessManager sharedInstance];
                    [v14 auditToken:&v7];
                    v9 = [sharedInstance2 registerProcessForAuditToken:&v7];
                }
            }
        }
        [a1 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
            id handle = [v9 handle];
            BSSerializeBSXPCEncodableObjectToXPCDictionaryWithKey(handle, arg1, FBSSystemServiceMessageKeyProcessHandle);
        }];
    }
}


void -[FBSystemAppProxyServiceServer _handleActions:forClient:](id a1, id a2)
{
    id v0 = a1;
    id payload = [v0 payload];
    NSArray *v3 = BSDeserializeArrayOfBSXPCEncodableObjectsFromXPCDictionaryWithKey(payload, FBSSystemServiceMessageKeyActions);
    id processHandle = [a2 processHandle];
    BSAuditToken *auditToken = [processHandle auditToken];
    id sharedInstance = [FBSystemService sharedInstance];
    BSServiceDispatchQueue *queue = [sharedInstance queue];
    [queue performAsync:^void(void) {
        NSSet *v9 = [NSSet setWithArray:v3];
        [sharedInstance handleActions:v9 source:auditToken withResult:^void(long arg1) {
            [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
                if (!arg1) {
                    return;
                } else {
                    xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, arg1);
                    return;
                }
            }];
        }];
    }];
}


void -[FBSystemAppProxyServiceServer _handleTerminateApplication:forClient:](id a1, id a2)
{
    id v0 = a1;
    id processHandle = [a2 processHandle];
    BSAuditToken *auditToken = [processHandle auditToken];
    id v3 = FBApplicationTerminationEntitlement;
    if (([auditToken hasEntitlement:FBApplicationTerminationEntitlement] & 1) == 0) {
        os_log_t oslog2 = FBLogCommon();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Entitlement %@ required to kill applications.", v3);
        }
        [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
            xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, 1);
            xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyReason, "client not entitled");
        }];
    } else {
        xpc_object_t xdict = [v0 payload];
        id v7 = BSDeserializeStringFromXPCDictionaryWithKey(xdict, FBSSystemServiceMessageKeyBundleID);
        if (!v7) {
            [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
                xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, 22);
                xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyReason, "invalid bundle identifier");
            }];
        } else {
            int64_t v8 = xpc_dictionary_get_int64(xdict, FBSSystemServiceMessageKeyTerminateReason);
            bool v9 = xpc_dictionary_get_bool(xdict, FBSSystemServiceMessageKeyTerminateReport);
            id v10 = BSDeserializeStringFromXPCDictionaryWithKey(xdict, FBSSystemServiceMessageKeyTerminateDesc);
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
                id v12 = BSProcessDescriptionForPID([auditToken pid]);
                os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Request received from %{public}@ to terminate application %{public}@: \"%{public}@\"", v12, v7, v10);
            }
            id sharedInstance = [FBSystemService sharedInstance];
            [sharedInstance terminateApplication:v7 forReason:(int32_t)v8 andReport:v9 withDescription:v10 completion:^void(bool arg1) {
                [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
                    xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, (arg1 != 0) ? 0 : 3);
                    if ((arg1 & 1) == 0) {
                        xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyReason, "found nothing to terminate");
                    }
                }];
            }];
        }
    }
}


void -[FBSystemAppProxyServiceServer _handleTerminateApplicationGroup:forClient:](id a1, id a2)
{
    int v12;
    id v0 = a1;
    id processHandle = [a2 processHandle];
    BSAuditToken *auditToken = [processHandle auditToken];
    id v3 = FBApplicationTerminationEntitlement;
    if (([auditToken hasEntitlement:FBApplicationTerminationEntitlement] & 1) == 0) {
        os_log_t oslog2 = FBLogCommon();
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_DEFAULT, "Entitlement %@ required to kill applications.", v3);
        }
        [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
            xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, 1);
            xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyReason, "client not entitled");
        }];
    } else {
        xpc_object_t xdict = [v0 payload];
        int64_t v7 = xpc_dictionary_get_int64(xdict, FBSSystemServiceMessageKeyTerminateGroup);
        int64_t v8 = xpc_dictionary_get_int64(xdict, FBSSystemServiceMessageKeyTerminateReason);
        bool v9 = xpc_dictionary_get_bool(xdict, FBSSystemServiceMessageKeyTerminateReport);
        id v10 = BSDeserializeStringFromXPCDictionaryWithKey(xdict, FBSSystemServiceMessageKeyTerminateDesc);
        os_log_t oslog = FBLogCommon();
        if (!os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            v12 = (int32_t)v7;
        } else {
            id v13 = BSProcessDescriptionForPID([auditToken pid]);
            v12 = (int32_t)v7;
            id v14 = FBSApplicationTerminationGroupDescription((int32_t)v7);
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Request received from %{public}@ to terminate %{public}@: \"%{public}@\"", v13, v14, v10);
        }
        id sharedInstance = [FBSystemService sharedInstance];
        [sharedInstance terminateApplicationGroup:v12 forReason:(int32_t)v8 andReport:v9 withDescription:v10 completion:^void(bool arg1) {
            [v0 sendReplyMessageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
                xpc_dictionary_set_int64(arg1, FBSSystemServiceMessageKeyIntResult, (arg1 != 0) ? 0 : 3);
                if ((arg1 & 1) == 0) {
                    xpc_dictionary_set_string(arg1, FBSSystemServiceMessageKeyReason, "found nothing to terminate");
                }
            }];
        }];
    }
}


void -[FBSystemAppProxyServiceServer _handleShutdown:forClient:](id a1, id a2)
{
    id v0 = a1;
    id v1 = a2;
    id v2 = nil;
    if (![self->_shutdownAuthenticator authenticateClient:v1 error:&v2]) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            id processHandle = [v1 processHandle];
            id v7 = FBSProcessPrettyDescription(processHandle);
            id userInfo = [v2 userInfo];
            id v9 = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBSystemService] %{public}@ is not permitted to initate system shutdown: %{public}@", v7, v9);
        }
    } else {
        id sharedInstance = [FBSystemService sharedInstance];
        BSServiceDispatchQueue *queue = [sharedInstance queue];
        [queue performAsync:^void(void) {
            id payload = [v0 payload];
            id v15 = BSDeserializeBSXPCEncodableObjectFromXPCDictionary(payload);
            os_log_t v16 = FBLogCommon();
            if (os_log_type_enabled(v16, OS_LOG_TYPE_DEFAULT)) {
                os_log_with_type(v16, OS_LOG_TYPE_DEFAULT, "[FBSystemService] Request received to shutdown system from client: %{public}@ with options: %{public}@", v1, v15);
            }
            id v17 = [v1 processHandle];
            [sharedInstance shutdownWithOptions:v15 origin:v17];
        }];
    }
}


void -[FBSystemAppProxyServiceServer noteClientDidConnect:withMessage:](id a1, long a2)
{
    id v1 = [FBSXPCMessage messageWithPacker:^void(NSObject<OS_xpc_object> *arg1) {
        id processHandle = [BSProcessHandle processHandle];
        BSSerializeBSXPCEncodableObjectToXPCDictionaryWithKey(processHandle, arg1, FBSSystemServiceMessageKeyProcessHandle);
    }];
    NSSet<id> *v2 = [NSSet setWithObject:a1];
    [self sendMessage:v1 withType:0 toClients:v2];
}


long -[FBSystemAppProxyServiceServer noteClientDidDisconnect:](long a1)
{
    return self;
}


void -[FBSystemAppProxyServiceServer noteDidReceiveMessage:withType:fromClient:](id a1, long a2, id a3)
{
    if (!a3) {
        NSString *v5 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"client"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBSystemAppProxyServiceServer.m", 254, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    if (a2 <= 2) {
        if (!a2) {
            [self _handleSystemApplicationBundleIdentifier:a1 forClient:a3];
        } else if (a2 == 1) {
            [self _handleGetPasscodeLockedOrBlockedStatus:a1 forClient:a3];
        } else if (a2 == 2) {
            [self _handleGetProcessHandle:a1 forClient:a3];
        }
    } else if (a2 > 4) {
        if (a2 == 5) {
            [self _handleTerminateApplicationGroup:a1 forClient:a3];
        } else if (a2 == 6) {
            [self _handleShutdown:a1 forClient:a3];
        }
    } else if (a2 == 3) {
        [self _handleActions:a1 forClient:a3];
    } else if (a2 == 4) {
        [self _handleTerminateApplication:a1 forClient:a3];
    }
}


void -[FBSystemAppProxyServiceServer .cxx_destruct](void)
{
    self->_shutdownAuthenticator = nil;
}
