struct FBInterfaceOrientationServiceServer {
    struct os_unfair_lock_s _lock; // +0x8
    BSServiceDispatchQueue *_queue; // +0x10
    BSServiceConnectionListener *_listener; // +0x18
    NSMutableSet *_lock_pendingConnections; // +0x20
    NSMutableSet *_lock_interestedConnections; // +0x28
    NSMutableSet *_lock_connections; // +0x30
    bool _lock_serviceSuspended; // +0x38
    FBSActiveInterfaceOrientationStateUpdate *_lock_latestUpdate; // +0x40
};

void -[FBInterfaceOrientationServiceServer activeInterfaceOrientationStateUpdateWithCompletion:](void (^a1)(long, long))
{
    id activeInterfaceOrientationStateUpdate = [self activeInterfaceOrientationStateUpdate];
    a1(activeInterfaceOrientationStateUpdate, 0);
}


void -[FBInterfaceOrientationServiceServer registerInterestWithCompletion:](void (^a1)(id, long))
{
    os_unfair_lock_lock(&self->_lock);
    id _currentConnection = [self _currentConnection];
    [self _lock_registerInterestForConnection:_currentConnection];
    id v2 = [self->_lock_latestUpdate copy];
    os_unfair_lock_unlock(&self->_lock);
    a1(v2, 0);
}


void -[FBInterfaceOrientationServiceServer _connectionInvalidated:](id a1)
{
    os_log_t oslog = FBLogInterfaceOrientationObserver();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Connection invalidated %{public}@", a1);
    }
    os_unfair_lock_lock(&self->_lock);
    [self->_lock_pendingConnections removeObject:a1];
    [self->_lock_interestedConnections removeObject:a1];
    [self->_lock_connections removeObject:a1];
    os_unfair_lock_unlock(&self->_lock);
    [a1 invalidate];
}


FBSActiveInterfaceOrientationStateUpdate *-[FBInterfaceOrientationServiceServer activeInterfaceOrientationStateUpdate](void)
{
    os_unfair_lock_lock(&self->_lock);
    FBSActiveInterfaceOrientationStateUpdate *v0 = self->_lock_latestUpdate;
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


FBInterfaceOrientationServiceServer *-[FBInterfaceOrientationServiceServer init](void)
{
    FBInterfaceOrientationServiceServer *v6;
    id bootstrapConfiguration = [BSServicesConfiguration bootstrapConfiguration];
    id v1 = [bootstrapConfiguration domainForMachName:@"com.apple.frontboard.systemappservices"];
    id identifier = [FBSOrientationServiceSpecification identifier];
    if (![v1 serviceForIdentifier:identifier]) {
        os_log_t oslog = FBLogInterfaceOrientationObserver();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Domain is missing %@ service, not creating interface orientation server.", identifier);
        }
        v6 = nil;
    } else {
        v6 = [self _initWithDomain:[v1 identifier] service:identifier];
    }
    return v6;
}


FBInterfaceOrientationServiceServer *-[FBInterfaceOrientationServiceServer _initWithDomain:service:](id a1, id a2)
{
    FBInterfaceOrientationServiceServer *v3 = [super init];
    if (v3 != nil) {
        v3->_lock._os_unfair_lock_opaque = 0;
        id serviceQuality = [FBSOrientationServiceSpecification serviceQuality];
        v3->_queue = [BSServiceDispatchQueue queueWithName:@"FBInterfaceOrientationServiceServer" serviceQuality:serviceQuality];
        v3->_lock_pendingConnections = [NSMutableSet set];
        v3->_lock_interestedConnections = [NSMutableSet set];
        v3->_lock_connections = [NSMutableSet set];
        v3->_lock_serviceSuspended = YES;
        id v13 = [BSServiceConnectionListenerConfiguration configurationWithDomain:a1 service:a2];
        __weak FBInterfaceOrientationServiceServer *v14 = v3;
        v3->_listener = [BSServiceConnectionListener listenerWithConfiguration:v13 handler:^void(BSServiceListenerConnection *arg1) {
            [v14 _didReceiveConnection:arg1];
        }];
    }
    return v3;
}


void -[FBInterfaceOrientationServiceServer noteActiveInterfaceOrientationStateDidChange:animationSettings:rotationDirection:](id a1, id a2, long a3)
{
    os_unfair_lock_lock(&self->_lock);
    [self _lock_noteActiveInterfaceOrientationStateDidChange:a1 animationSettings:a2 rotationDirection:a3];
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBInterfaceOrientationServiceServer initialize](void)
{
    [self->_listener activate];
}


void -[FBInterfaceOrientationServiceServer invalidate](void)
{
    os_unfair_lock_lock(&self->_lock);
    [self->_listener invalidate];
    for (id v1 in self->_lock_connections) {
        [v1 invalidate];
    }
    [self->_lock_connections removeAllObjects];
    [self->_lock_pendingConnections removeAllObjects];
    [self->_lock_interestedConnections removeAllObjects];
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBInterfaceOrientationServiceServer startService](void)
{
    os_unfair_lock_lock(&self->_lock);
    if (!self->_lock_serviceSuspended) {
        os_unfair_lock_unlock(&self->_lock);
        return;
    }
    self->_lock_serviceSuspended = NO;
    os_log_t oslog = FBLogInterfaceOrientationObserver();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Service has been started.");
    }
    id v5 = [self->_lock_pendingConnections copy];
    [self->_lock_pendingConnections removeAllObjects];
    os_unfair_lock_unlock(&self->_lock);
    for (id v1 in v5) {
        [v1 activate];
    }
}


NSXPCListenerEndpoint *-[FBInterfaceOrientationServiceServer _endpoint](void)
{
    return [self->_listener endpoint];
}


id -[FBInterfaceOrientationServiceServer _pendingConnections](void)
{
    os_unfair_lock_lock(&self->_lock);
    id v0 = [self->_lock_pendingConnections copy];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


id -[FBInterfaceOrientationServiceServer _interestedConnections](void)
{
    os_unfair_lock_lock(&self->_lock);
    id v0 = [self->_lock_interestedConnections copy];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


id -[FBInterfaceOrientationServiceServer _connections](void)
{
    os_unfair_lock_lock(&self->_lock);
    id v0 = [self->_lock_connections copy];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


id -[FBInterfaceOrientationServiceServer _latestUpdate](void)
{
    os_unfair_lock_lock(&self->_lock);
    id v0 = [self->_lock_latestUpdate copy];
    os_unfair_lock_unlock(&self->_lock);
    return v0;
}


void -[FBInterfaceOrientationServiceServer unregisterInterest](void)
{
    os_unfair_lock_lock(&self->_lock);
    id _currentConnection = [self _currentConnection];
    [self _lock_unregisterInterestForConnection:_currentConnection];
    os_unfair_lock_unlock(&self->_lock);
}


void -[FBInterfaceOrientationServiceServer _didReceiveConnection:](id a1)
{
    TECSubTextEncodingRec v2;
    os_log_t oslog = FBLogInterfaceOrientationObserver();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Received connection: %@", a1);
    }
    id sharedInstance = [FBProcessManager sharedInstance];
    id remoteToken = [a1 remoteToken];
    if (!remoteToken) {
        v2 = (TECSubTextEncodingRec){0};
    } else {
        [remoteToken realToken];
    }
    [sharedInstance registerProcessForAuditToken:&v2];
    os_unfair_lock_lock(&self->_lock);
    [a1 configure:^void(id<BSServiceListenerConnectionConfiguring> arg1) {
        [arg1 setQueue:self->_queue];
        id interface = [FBSOrientationServiceSpecification interface];
        [arg1 setInterface:interface];
        [arg1 setLocalTarget:self];
        __weak void *v8 = self;
        void (^v9)(BSServiceListenerConnection<BSServiceConnectionContext> *) = ^void(BSServiceListenerConnection<BSServiceConnectionContext> *arg1) {
            [v8 _connectionInvalidated:arg1];
        };
        [arg1 setInvalidationHandler:v9];
    }];
    [self->_lock_connections addObject:a1];
    if (self->_lock_serviceSuspended != 1) {
        [a1 activate];
    } else {
        [self->_lock_pendingConnections addObject:a1];
    }
    os_unfair_lock_unlock(&self->_lock);
}


long -[FBInterfaceOrientationServiceServer _currentConnection](void)
{
    return [BSServiceListenerConnection currentContext];
}


void -[FBInterfaceOrientationServiceServer _lock_noteActiveInterfaceOrientationStateDidChange:animationSettings:rotationDirection:](id a1, id a2, long a3)
{
    double duration = [a2 duration];
    id v2 = [self->_lock_latestUpdate copy];
    id state = [v2 state];
    long sequenceNumber = [v2 sequenceNumber];
    BOOL v5 = [state isEqual:a1];
    long v6 = sequenceNumber + !v5;
    os_log_t log = FBLogInterfaceOrientationObserver();
    bool v8 = os_log_type_enabled(log, OS_LOG_TYPE_DEFAULT);
    if (v2) {
        if (v8) {
            id v13 = BSInterfaceOrientationDescription([state interfaceOrientation]);
            id v14 = BSInterfaceOrientationDescription([a1 interfaceOrientation]);
            id displayIdentity2 = [state displayIdentity];
            id displayIdentity3 = [a1 displayIdentity];
            id v17 = BSOrientationRotationDirectionDescription(a3);
            os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Received active interface orientation (%{public}@->%{public}@) on display (%{public}@->%{public}@) with duration %.1f and direction %{public}@", v13, v14, displayIdentity2, displayIdentity3, duration, v17);
        }
    } else if (v8) {
        id v9 = BSInterfaceOrientationDescription([a1 interfaceOrientation]);
        id displayIdentity = [a1 displayIdentity];
        id v11 = BSOrientationRotationDirectionDescription(a3);
        os_log_with_type(log, OS_LOG_TYPE_DEFAULT, "Received initial active interface orientation (%{public}@) on display (%{public}@) with duration %.1f and direction %{public}@", v9, displayIdentity, duration, v11);
    }
    FBSActiveInterfaceOrientationStateUpdate *v18 = objc_msgSend$_initWithState:animationDuration:rotationDirection:sequenceNumber:([FBSActiveInterfaceOrientationStateUpdate alloc], a1, a3, v6, duration);
    self->_lock_latestUpdate = [v18 copy];
    if ([self->_lock_interestedConnections count] != 0) {
        os_log_t oslog = FBLogInterfaceOrientationObserver();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Broadcasting active interface orientation state update %{public}@ to registered clients with sequence #: %lu.", v18, v6);
        }
        [self _lock_sendMessageToInterestedClients:^void(id<FBSOrientationServiceClientInterface> arg1) {
            [arg1 activeInterfaceOrientationStateDidChange:v18];
        }];
    }
}


void -[FBInterfaceOrientationServiceServer _lock_registerInterestForConnection:](id a1)
{
    os_log_t oslog = FBLogInterfaceOrientationObserver();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Registering orientation interest for %@ ", a1);
    }
    [self->_lock_interestedConnections addObject:a1];
}


void -[FBInterfaceOrientationServiceServer _lock_unregisterInterestForConnection:](id a1)
{
    os_log_t oslog = FBLogInterfaceOrientationObserver();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Unregistering orientation interest for %@ ", a1);
    }
    [self->_lock_interestedConnections removeObject:a1];
}


void -[FBInterfaceOrientationServiceServer _lock_sendMessageToInterestedClients:](void (^a1)(id<FBSOrientationServiceClientInterface>))
{
    for (id v2 in self->_lock_interestedConnections) {
        id<FBSOrientationServiceClientInterface> remoteTarget = [v2 remoteTarget];
        a1(remoteTarget);
    }
}


void -[FBInterfaceOrientationServiceServer .cxx_destruct](void)
{
    self->_lock_latestUpdate = nil;
    self->_lock_connections = nil;
    self->_lock_interestedConnections = nil;
    self->_lock_pendingConnections = nil;
    self->_listener = nil;
    self->_queue = nil;
}
