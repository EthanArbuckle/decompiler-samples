struct FBSynchronizedTransactionGroup {
    bool _commitAllowed; // +0x98
    bool _readyForCommit; // +0x99
    bool _didCommit; // +0x9a
    NSMutableSet *_synchronizedTransactions; // +0xa0
    NSMutableSet *_synchronizedTransactionsAwaitingCommitReadiness; // +0xa8
    NSMutableSet *_synchronizedTransactionsReadyToCommit; // +0xb0
    __weak id<FBSynchronizedTransactionGroupDelegate> _synchronizationDelegate; // +0xb8
};

FBSynchronizedTransactionGroup *-[FBSynchronizedTransactionGroup init](void)
{
    FBSynchronizedTransactionGroup *v1 = [super init];
    if (v1 != nil) {
        v1->_synchronizedTransactions = [[NSMutableSet alloc] init];
        v1->_synchronizedTransactionsAwaitingCommitReadiness = [[NSMutableSet alloc] init];
        v1->_synchronizedTransactionsReadyToCommit = [[NSMutableSet alloc] init];
    }
    return v1;
}


long -[FBSynchronizedTransactionGroup performSynchronizedCommit](void)
{
    self->_commitAllowed = YES;
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    if (synchronizationDelegate != nil && [self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Delegate says we're good to commit."];
    }
    return [self _performSynchronizedCommitIfReady];
}


id -[FBSynchronizedTransactionGroup setSynchronizationDelegate:](id a1)
{
    return objc_storeWeak(&self->_synchronizationDelegate, a1);
}


long -[FBSynchronizedTransactionGroup _didComplete](void)
{
    [self setSynchronizationDelegate:nil];
    [self->_synchronizedTransactions enumerateObjectsUsingBlock:^void(BSTransaction<FBSynchronizedTransaction> *arg1, bool *arg2) {
        [arg1 setSynchronizationDelegate:nil];
    }];
    return [super _didComplete];
}


void -[FBSynchronizedTransactionGroup .cxx_destruct](void)
{
    self->_synchronizationDelegate = nil;
    self->_synchronizedTransactionsReadyToCommit = nil;
    self->_synchronizedTransactionsAwaitingCommitReadiness = nil;
    self->_synchronizedTransactions = nil;
}


id -[FBSynchronizedTransactionGroup addSynchronizedTransaction:](id a1)
{
    if (!a1) {
        return self;
    }
    [self->_synchronizedTransactions addObject:a1];
    [self->_synchronizedTransactionsAwaitingCommitReadiness addObject:a1];
    [a1 setSynchronizationDelegate:self];
    [self addChildTransaction:a1];
    return a1;
}


id<FBSynchronizedTransactionGroupDelegate> -[FBSynchronizedTransactionGroup synchronizationDelegate](void)
{
    return self->_synchronizationDelegate;
}


bool -[FBSynchronizedTransactionGroup isReadyForSynchronizedCommit](void)
{
    if (self->_commitAllowed != 1) {
        bool v0 = false;
        return false;
    } else if (!self->_didCommit) {
        return self->_readyForCommit;
    } else {
        return false;
    }
}


long -[FBSynchronizedTransactionGroup synchronizedTransaction:didCommitSynchronizedTransactions:](long a1, long a2)
{
    return self;
}


NSArray *-[FBSynchronizedTransactionGroup synchronizedTransactions](void)
{
    return [self->_synchronizedTransactions allObjects];
}


int -[FBSynchronizedTransactionGroup _canBeInterrupted](void)
{
    return 1;
}


int -[FBSynchronizedTransactionGroup _shouldFailForChildTransaction:](id a1)
{
    int v1;
    if (![self->_synchronizedTransactions containsObject:a1]) {
        return 1;
    }
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    if (!synchronizationDelegate) {
        v1 = 1;
    } else if ([synchronizationDelegate respondsToSelector:@selector(synchronizedTransactionGroup:shouldFailForSynchronizedTransaction:)]) {
        v1 = [synchronizationDelegate synchronizedTransactionGroup:self shouldFailForSynchronizedTransaction:a1];
    } else {
        v1 = 1;
    }
    return v1;
}


void -[FBSynchronizedTransactionGroup _childTransactionDidComplete:](id a1)
{
    [self->_synchronizedTransactionsAwaitingCommitReadiness removeObject:a1];
    [self->_synchronizedTransactionsReadyToCommit removeObject:a1];
    [self _checkPreconditionsAndCommitIfReady];
    [super _childTransactionDidComplete:a1];
}


void -[FBSynchronizedTransactionGroup _performSynchronizedCommit:](id a1)
{
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    [synchronizationDelegate synchronizedTransaction:self willCommitSynchronizedTransactions:a1];
    for (id v7 in a1) {
        [v7 performSynchronizedCommit];
    }
    [synchronizationDelegate synchronizedTransaction:self didCommitSynchronizedTransactions:a1];
}


void -[FBSynchronizedTransactionGroup _checkPreconditionsAndCommitIfReady](void)
{
    if (self->_readyForCommit || [self->_synchronizedTransactionsAwaitingCommitReadiness count] != 0) {
        [self _performSynchronizedCommitIfReady];
        return;
    }
    self->_readyForCommit = YES;
    if ([self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Commit preconditions satisfied."];
    }
    [self addMilestone:@"synchronizedCommit"];
    id<FBSynchronizedTransactionDelegate> synchronizationDelegate = [self synchronizationDelegate];
    if (!synchronizationDelegate || self->_commitAllowed) {
        self->_commitAllowed = YES;
        [self _performSynchronizedCommitIfReady];
    } else {
        if ([self isAuditHistoryEnabled] != 0) {
            id v4 = [BSDescriptionBuilder descriptionForObject:synchronizationDelegate];
            [self _addAuditHistoryItem:@"Using synchronization delegate: %@", v4];
        }
        [synchronizationDelegate synchronizedTransactionReadyToCommit:self];
    }
}


void -[FBSynchronizedTransactionGroup _performSynchronizedCommitIfReady](void)
{
    if (![self isReadyForSynchronizedCommit]) {
        return;
    }
    self->_didCommit = YES;
    if ([self isAuditHistoryEnabled] != 0) {
        [self _addAuditHistoryItem:@"Committing now!"];
    }
    NSArray *allObjects = [self->_synchronizedTransactionsReadyToCommit allObjects];
    [self->_synchronizedTransactionsReadyToCommit removeAllObjects];
    [self _performSynchronizedCommit:allObjects];
    [self satisfyMilestone:@"synchronizedCommit"];
}


void -[FBSynchronizedTransactionGroup synchronizedTransactionReadyToCommit:](id a1)
{
    if ([self->_synchronizedTransactionsAwaitingCommitReadiness containsObject:a1]) {
        [self->_synchronizedTransactionsAwaitingCommitReadiness removeObject:a1];
        [self->_synchronizedTransactionsReadyToCommit addObject:a1];
        [self _checkPreconditionsAndCommitIfReady];
    }
}


long -[FBSynchronizedTransactionGroup synchronizedTransaction:willCommitSynchronizedTransactions:](long a1, long a2)
{
    return self;
}
