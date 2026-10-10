struct FBApplicationDataStoreRepositoryServerClientContext {
    id<FBApplicationDataStoreRepository> _dataStore; // +0x8
    NSSet *_prefetchedKeys; // +0x10
    NSObject<OS_dispatch_queue> *_queue; // +0x18
    bool _interestedInAllChanges; // +0x20
    bool _observingChanges; // +0x21
    __weak id<FBSServiceFacilityClientHandle> _client; // +0x28
    __weak id<FBApplicationDataStoreRepositoryServerClientContextDelegate> _delegate; // +0x30
};

static long FBApplicationStoreRepositoryChangeApp;
static long FBApplicationStoreRepositoryChangeKey;
static long FBApplicationStoreRepositoryChangeNotification;
static long FBApplicationStoreRepositoryChangeValue;
static long FBApplicationStoreRepositoryInvalidatedNotification;

FBApplicationDataStoreRepositoryServerClientContext *-[FBApplicationDataStoreRepositoryServerClientContext initWithDataStore:](id<FBApplicationDataStoreRepository> a1)
{
    FBApplicationDataStoreRepositoryServerClientContext *observer = [super init];
    if (observer != nil) {
        observer->_dataStore = a1;
        observer->_queue = BSDispatchQueueCreateSerial(@"com.apple.frontboard.FBApplicationDataStoreRepositoryServerClient");
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:observer selector:@selector(_repositoryInvalidated:) name:FBApplicationStoreRepositoryInvalidatedNotification object:nil];
    }
    return observer;
}


void -[FBApplicationDataStoreRepositoryServerClientContext dealloc](void)
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self];
    [super dealloc];
}


void -[FBApplicationDataStoreRepositoryServerClientContext setInterestedInAllChanges:](bool a1)
{
    dispatch_sync(self->_queue, ^void(void) {
        if (self->_interestedInAllChanges == a1) {
            return;
        }
        self->_interestedInAllChanges = a1;
        [self _queue_updateObservers];
    });
}


void -[FBApplicationDataStoreRepositoryServerClientContext setPrefetchedKeys:](id a1)
{
    dispatch_sync(self->_queue, ^void(void) {
        self->_prefetchedKeys = [a1 copy];
        [self _queue_updateObservers];
    });
}


long -[FBApplicationDataStoreRepositoryServerClientContext _queue_updateObservers](void)
{
    NSUInteger count = [self->_prefetchedKeys count];
    bool v1 = ((!count) ? self->_interestedInAllChanges : 1) & 1;
    if (self->_observingChanges != v1) {
        self->_observingChanges = v1;
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        if (self->_observingChanges != 1) {
            [defaultCenter removeObserver:self name:FBApplicationStoreRepositoryChangeNotification object:nil];
        } else {
            [defaultCenter addObserver:self selector:@selector(_valueChanged:) name:FBApplicationStoreRepositoryChangeNotification object:nil];
        }
        return defaultCenter;
    } else {
        return count;
    }
}


void -[FBApplicationDataStoreRepositoryServerClientContext _valueChanged:](id a1)
{
    id userInfo = [a1 userInfo];
    id v2 = [userInfo objectForKey:FBApplicationStoreRepositoryChangeApp];
    id userInfo2 = [a1 userInfo];
    id v4 = [userInfo2 objectForKey:FBApplicationStoreRepositoryChangeKey];
    id userInfo3 = [a1 userInfo];
    id v6 = [userInfo3 objectForKey:FBApplicationStoreRepositoryChangeValue];
    id<FBApplicationDataStoreRepositoryServerClientContextDelegate> v7 = self->_delegate;
    [v7 applicationDataStoreRepositoryClientContext:self valueChangedForObject:v6 key:v4 appID:v2];
}


void -[FBApplicationDataStoreRepositoryServerClientContext _repositoryInvalidated:](id a1)
{
    id userInfo = [a1 userInfo];
    id v1 = [userInfo objectForKey:FBApplicationStoreRepositoryChangeApp];
    id<FBApplicationDataStoreRepositoryServerClientContextDelegate> v2 = self->_delegate;
    [v2 applicationDataStoreRepositoryClientContext:self repositoryInvalidatedForAppID:v1];
}


id<FBApplicationDataStoreRepositoryServerClientContextDelegate> -[FBApplicationDataStoreRepositoryServerClientContext delegate](void)
{
    return self->_delegate;
}


id -[FBApplicationDataStoreRepositoryServerClientContext setDelegate:](id a1)
{
    return objc_storeWeak(&self->_delegate, a1);
}


id<FBSServiceFacilityClientHandle> -[FBApplicationDataStoreRepositoryServerClientContext clientHandle](void)
{
    return self->_client;
}


id -[FBApplicationDataStoreRepositoryServerClientContext setClientHandle:](id a1)
{
    return objc_storeWeak(&self->_client, a1);
}


NSSet *-[FBApplicationDataStoreRepositoryServerClientContext prefetchedKeys](void)
{
    return self->_prefetchedKeys;
}


bool -[FBApplicationDataStoreRepositoryServerClientContext interestedInAllChanges](void)
{
    return self->_interestedInAllChanges;
}


void -[FBApplicationDataStoreRepositoryServerClientContext .cxx_destruct](void)
{
    self->_delegate = nil;
    self->_client = nil;
    self->_queue = nil;
    self->_prefetchedKeys = nil;
    self->_dataStore = nil;
}
