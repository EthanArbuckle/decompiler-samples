struct CNTChangeHistoryMonitorTask {
    NSError *_fetchHistoryError; // +0x18
};

NSString *+[CNTChangeHistoryMonitorTask taskName](void)
{
    return @"com.apple.contacts.tool.history.monitor";
}


NSNull *-[CNTChangeHistoryMonitorTask onRun:](NSError **a1)
{
    NSNull *v13;
    NSError *fetchHistoryError;
    id<CNTLogger> logger = [self logger];
    [logger log:@"Monitoring for database changes. Press ^C to stop."];
    Class v2 = [self class];
    id databaseChangeObservable = [v2 databaseChangeObservable];
    id v4 = [CNObserver observerWithWeakTarget:self resultSelector:@selector(onDatabaseChanged:)];
    id v5 = [databaseChangeObservable subscribe:v4];
    if (![self fetchHistoryError]) {
        NSString *v7 = NSDefaultRunLoopMode;
        do {
            NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];
            NSDate *distantFuture = [NSDate distantFuture];
            [currentRunLoop runMode:v7 beforeDate:distantFuture];
            fetchHistoryError = [self fetchHistoryError];
        } while (!fetchHistoryError);
    }
    [v5 cancel];
    if (![self fetchHistoryError]) {
        v13 = [NSNull null];
    } else {
        NSError *fetchHistoryError2 = [self fetchHistoryError];
        if (a1 != 0) {
            *(a1) = fetchHistoryError2;
        }
        v13 = nil;
    }
    return v13;
}


id +[CNTChangeHistoryMonitorTask databaseChangeObservable](void)
{
    id v0 = [CNObservable observableOnDefaultNotificationCenterWithName:CNContactStoreDidChangeNotification object:0];
    id defaultProvider = [CNSchedulerProvider defaultProvider];
    id backgroundScheduler = [defaultProvider backgroundScheduler];
    return [v0 throttleFirst:1.0 scheduler:backgroundScheduler];
}


void -[CNTChangeHistoryMonitorTask onDatabaseChanged:](id a1)
{
    CNChangeHistoryFetchRequest *v3 = [[CNChangeHistoryFetchRequest alloc] initWithClientIdentifier:[self clientIdentifier]];
    [v3 setUnifyResults:YES];
    CNContactStore *contactStore = [self contactStore];
    NSError *v5 = nil;
    id v6 = [contactStore changeHistoryWithFetchRequest:v3 error:&v5];
    if (!v6) {
        [self setFetchHistoryError:v5];
    } else {
        id<CNTLogger> logger = [self logger];
        CNContactStore *contactStore2 = [self contactStore];
        _CNTChangeHistoryResultWriterCompactImpl *v10 = [CNTChangeHistoryResultWriter compactWriterWithLogger:logger contactStore:contactStore2];
        [v10 logResult:v6];
        id latestChangeAnchor = [v6 latestChangeAnchor];
        [self clearHistoryToAnchor:latestChangeAnchor];
    }
}


void -[CNTChangeHistoryMonitorTask clearHistoryToAnchor:](id a1)
{
    CNChangeHistoryClearRequest *v4 = [[CNChangeHistoryClearRequest alloc] initWithClientIdentifier:[self clientIdentifier]];
    [v4 setToChangeAnchor:a1];
    CNContactStore *contactStore = [self contactStore];
    id v6 = nil;
    long v7 = [contactStore executeChangeHistoryClearRequest:v4 error:&v6];
    if ((v7 & 1) == 0) {
        id<CNTLogger> logger = [self logger];
        NSString *v10 = [NSString stringWithFormat:@"Error clearing to change anchor: %@", v6];
        [logger log:v10];
    }
}


NSError *-[CNTChangeHistoryMonitorTask fetchHistoryError](void)
{
    return objc_getProperty(self, _cmd, 24, 0);
}


void -[CNTChangeHistoryMonitorTask setFetchHistoryError:](NSError *a1)
{
    self->_fetchHistoryError = [a1 copy];
}


void -[CNTChangeHistoryMonitorTask .cxx_destruct](void)
{
    self->_fetchHistoryError = nil;
}
