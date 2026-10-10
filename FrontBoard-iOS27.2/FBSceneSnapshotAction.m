struct FBSceneSnapshotAction {
    NSString *_sceneID; // +0x68
    RBSAssertion *_assertion; // +0x70
    NSString *_description; // +0x78
};

struct objc_super {
    id receiver; // +0x0
    Class super_class; // +0x8
};

static long FBAssertionDomain;

void -[FBSceneSnapshotAction .cxx_destruct](void)
{
    self->_description = nil;
    self->_assertion = nil;
    self->_sceneID = nil;
}


void -[FBSceneSnapshotAction dealloc](void)
{
    [self->_assertion invalidate];
    [super dealloc];
}


FBSceneSnapshotAction *-[FBSceneSnapshotAction initWithScene:requests:expirationInterval:responseHandler:](id a1, id a2, id a3, long a4)
{
    long v19;
    struct objc_super v26;
    id identifier2 = [a1 identifier];
    NSString *v3 = NSStringFromClass([self class]);
    NSString *v4 = [NSString stringWithFormat:@"<%@: %p; %@>", v3, self, identifier2];
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Created: %{public}@", v4);
    }
    id clientHandle = [a1 clientHandle];
    id processHandle = [clientHandle processHandle];
    int pid = [processHandle pid];
    BOOL isValid = [a1 isValid];
    RBSAssertion *v11 = nil;
    if (isValid && pid >= 1) {
        RBSAssertion *v12 = [RBSAssertion alloc];
        id identifier = [a1 identifier];
        NSString *v14 = [NSString stringWithFormat:@"FBSceneSnapshotAction:%@", identifier];
        id v15 = [RBSTarget targetWithPid:pid];
        id v16 = [RBSDomainAttribute attributeWithDomain:FBAssertionDomain name:@"SceneSnapshotAction"];
        id v18 = [RBSDurationAttribute invalidateAfterInterval:v19];
        NSArray *v20 = @[v16, v18];
        v11 = [v12 initWithExplanation:v14 target:v15 attributes:v20];
        [v11 setInvalidationHandler:^void(RBSAssertion *arg1, NSError *arg2) {
            os_log_t oslog = FBLogCommon();
            if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
                id succinctDescription = [arg2 succinctDescription];
                os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Assertion invalidated for %{public}@: %{public}@", v4, succinctDescription);
            }
        }];
    }
    RBSAssertion *v24 = v11;
    v26.receiver = self;
    v26.super_class = FBSceneSnapshotAction;
    FBSceneSnapshotAction *v27 = objc_msgSendSuper2(&v26, @selector(initWithRequests:expirationInterval:responseHandler:), a2, ^void(BSActionResponse *arg1) {
        NSError *error = [arg1 error];
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
            NSString *v37 = (!error) ? @"success" : [error succinctDescription];
            os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Got response for %{public}@: %{public}@", v4, v37);
        }
        [v11 invalidate];
        if (a3 != nil) {
            a3->field_16(a3, arg1);
        }
    }, v19);
    if (v27 != nil) {
        id identifier3 = [a1 identifier];
        id v29 = [identifier3 copy];
        long *v30 = &v27->_sceneID;
        *(v30) = v29;
        v27->_assertion = v11;
        v27->_description = v4;
        [v24 acquireWithError:0];
    }
    return v27;
}


void -[FBSceneSnapshotAction invalidate](void)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        NSString *v2 = self->_description;
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Invalidating: %{public}@", v2);
    }
    [self->_assertion invalidate];
    [super invalidate];
}


NSString *-[FBSceneSnapshotAction sceneID](void)
{
    return self->_sceneID;
}
