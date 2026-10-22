struct AnonymousStruct_1 {
    double field_0; // +0x0
    double field_8; // +0x8
    double field_16; // +0x10
    double field_24; // +0x18
};

struct CGRect {
    CGPoint origin; // +0x0
    CGSize size; // +0x10
};

struct FBSceneSnapshotContext {
    bool _clientAllowsProtectedContent; // +0x8
    bool _opaque; // +0x9
    NSString *_sceneID; // +0x10
    FBSSceneClientSettings *_clientSettings; // +0x18
    BSSettings *_clientExtendedData; // +0x20
    FBSSceneSettings *_settings; // +0x28
    NSDate *_expirationDate; // +0x30
    id _userInfo; // +0x38
    long _orientation; // +0x40
    NSSet *_layersToExclude; // +0x48
    FBSceneLayer *_backgroundLayer; // +0x50
    struct CGRect _frame; // +0x58
};

void -[FBSceneSnapshotContext .cxx_destruct](void)
{
    self->_backgroundLayer = nil;
    self->_layersToExclude = nil;
    self->_userInfo = nil;
    self->_expirationDate = nil;
    self->_settings = nil;
    self->_clientExtendedData = nil;
    self->_clientSettings = nil;
    self->_sceneID = nil;
}


FBSceneSnapshotContext *-[FBSceneSnapshotContext initWithScene:configurator:](id a1, void (^a2)(FBSceneSnapshotContext *))
{
    if (!a1) {
        NSString *v15 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"scene"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v16 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v16, self, @"FBSceneSnapshotContext.m", 33, v15);
        }
        _bs_set_crash_log_message([v15 UTF8String]);
        __break(0);
    }
    FBSceneSnapshotContext *v3 = [super init];
    if (v3 != nil) {
        id identifier = [a1 identifier];
        v3->_sceneID = [identifier copy];
        FBSSceneSettings *settings = [a1 settings];
        v3->_settings = [settings copy];
        CGRect frame = [v3->_settings frame];
        struct AnonymousStruct_1 v11 = BSRectWithSize(frame.size.width, frame.size.height);
        v3->_frame.origin.x = v11.field_0;
        v3->_frame.origin.y = v11.field_8;
        v3->_frame.size.width = v11.field_16;
        v3->_frame.size.height = v11.field_24;
        FBSSceneClientSettings *clientSettings = [a1 clientSettings];
        v3->_clientSettings = [clientSettings copy];
        v3->_opaque = YES;
        v3->_orientation = 0;
        if (a2 != nil) {
            a2(v3);
        }
    }
    return v3;
}


id +[FBSceneSnapshotContext contextWithFBSContext:](id a1)
{
    return [[self alloc] initWithFBSContext:a1];
}


FBSceneSnapshotContext *-[FBSceneSnapshotContext initWithFBSContext:](id a1)
{
    FBSceneSnapshotContext *v2 = [super init];
    if (v2 != nil) {
        NSString *sceneID = [a1 sceneID];
        v2->_sceneID = [sceneID copy];
        FBSSceneSettings *settings = [a1 settings];
        v2->_settings = [settings copy];
        v2->_orientation = 0;
        CGRect frame2 = [v2->_settings frame];
        CGRect frame = [a1 frame];
        CGRect r1 = BSRectWithSize(frame2.size.width, frame2.size.height);
        CGRect r2 = [a1 frame];
        CGRect v13 = CGRectIntersection(r1, r2);
        v2->_frame.origin.x = frame.origin.x;
        v2->_frame.origin.y = frame.origin.y;
        v2->_frame.size.width = v13.size.width;
        v2->_frame.size.height = v13.size.height;
        NSSet *layersToExclude = [a1 layersToExclude];
        if (layersToExclude != nil) {
            NSMutableSet *set = [NSMutableSet set];
            NSSet *layersToExclude2 = [a1 layersToExclude];
            for (id v1 in layersToExclude2) {
                id v23 = [FBSceneLayer layerWithFBSSceneLayer:v1];
                if (v23 != nil) {
                    [set addObject:v23];
                }
            }
            v2->_layersToExclude = set;
        }
        BSSettings *clientExtendedData = [a1 clientExtendedData];
        v2->_clientAllowsProtectedContent = [clientExtendedData boolForSetting:0x10c4c470];
        double expirationInterval = [a1 expirationInterval];
        if (expirationInterval > 0.0) {
            NSDate *distantFuture = [NSDate distantFuture];
            NSTimeInterval timeIntervalSinceReferenceDate = [distantFuture timeIntervalSinceReferenceDate];
            if (expirationInterval < timeIntervalSinceReferenceDate) {
                v2->_expirationDate = [[NSDate alloc] initWithTimeIntervalSinceNow:expirationInterval];
            }
        }
        BSSettings *clientExtendedData2 = [a1 clientExtendedData];
        if (clientExtendedData2 != nil) {
            v2->_clientExtendedData = [clientExtendedData2 copy];
        }
    }
    return v2;
}


void -[FBSceneSnapshotContext scale](void)
{
    id displayConfiguration = [self->_settings displayConfiguration];
    if (displayConfiguration != nil) {
        [displayConfiguration pointScale];
    }
}


void -[FBSceneSnapshotContext applyContext:](id a1)
{
    NSString *sceneID = [a1 sceneID];
    if (![self->_sceneID isEqualToString:sceneID]) {
        NSString *sceneID2 = [a1 sceneID];
        NSString *v5 = [NSString stringWithFormat:@"attempt to `applyContext:` for id='%@' to scene with id='%@'", sceneID2, self->_sceneID];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v0 = NSStringFromSelector(_cmd);
            NSString *v31 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v0, v31, self, @"FBSceneSnapshotContext.m", 122, v5);
        }
        _bs_set_crash_log_message([v5 UTF8String]);
        __break(0);
    }
    FBSSceneSettings *settings = [a1 settings];
    self->_settings = [settings copy];
    CGRect frame2 = [self->_settings frame];
    CGRect frame = [a1 frame];
    CGRect r1 = BSRectWithSize(frame2.size.width, frame2.size.height);
    CGRect r2 = [a1 frame];
    CGRect v13 = CGRectIntersection(r1, r2);
    self->_frame.origin.x = frame.origin.x;
    self->_frame.origin.y = frame.origin.y;
    self->_frame.size.width = v13.size.width;
    self->_frame.size.height = v13.size.height;
    NSSet *layersToExclude = [a1 layersToExclude];
    if (layersToExclude != nil) {
        NSMutableSet *set = [NSMutableSet set];
        NSSet *layersToExclude2 = [a1 layersToExclude];
        for (id v22 in layersToExclude2) {
            id v23 = [FBSceneLayer layerWithFBSSceneLayer:v22];
            if (v23 != nil) {
                [set addObject:v23];
            }
        }
        self->_layersToExclude = set;
    }
    BSSettings *clientExtendedData = [a1 clientExtendedData];
    self->_clientAllowsProtectedContent = [clientExtendedData boolForSetting:0x10c4c470];
    double expirationInterval = [a1 expirationInterval];
    if (expirationInterval > 0.0) {
        NSDate *distantFuture = [NSDate distantFuture];
        NSTimeInterval timeIntervalSinceReferenceDate = [distantFuture timeIntervalSinceReferenceDate];
        if (expirationInterval < timeIntervalSinceReferenceDate) {
            self->_expirationDate = [[NSDate alloc] initWithTimeIntervalSinceNow:expirationInterval];
        }
    }
}


long -[FBSceneSnapshotContext description](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBSceneSnapshotContext succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBSceneSnapshotContext succinctDescriptionBuilder](void)
{
    id v0 = [BSDescriptionBuilder builderWithObject:self];
    [v0 appendString:self->_sceneID withName:@"sceneID"];
    return v0;
}


id -[FBSceneSnapshotContext descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBSceneSnapshotContext descriptionBuilderWithMultilinePrefix:](id a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:a1 block:^void(void) {
        [succinctDescriptionBuilder appendObject:self->_settings withName:@"settings"];
        objc_msgSend$appendRect:withName:(succinctDescriptionBuilder, @"frame", self->_frame);
        [succinctDescriptionBuilder appendBool:self->_opaque withName:@"opaque"];
        long v5 = self->_orientation;
        if (!self->_orientation) {
            [succinctDescriptionBuilder appendObject:@"Natural" withName:@"orientation"];
        } else if (v5 != 1) {
            NSString *v3 = [NSString stringWithFormat:@"(unknown:%ld)", v5];
            [succinctDescriptionBuilder appendObject:v3 withName:@"orientation"];
        } else {
            [succinctDescriptionBuilder appendObject:@"Reference" withName:@"orientation"];
        }
        NSArray *allObjects = [self->_layersToExclude allObjects];
        [succinctDescriptionBuilder appendArraySection:allObjects withName:@"layersToExclude" skipIfEmpty:1];
        [succinctDescriptionBuilder appendObject:self->_expirationDate withName:@"expirationDate" skipIfNil:1];
        [succinctDescriptionBuilder appendBool:self->_clientAllowsProtectedContent withName:@"clientAllowsProtectedContent"];
    }];
    return succinctDescriptionBuilder;
}


NSString *-[FBSceneSnapshotContext sceneID](void)
{
    return self->_sceneID;
}


FBSSceneClientSettings *-[FBSceneSnapshotContext clientSettings](void)
{
    return self->_clientSettings;
}


long -[FBSceneSnapshotContext setClientSettings:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 24);
}


BSSettings *-[FBSceneSnapshotContext clientExtendedData](void)
{
    return self->_clientExtendedData;
}


FBSSceneSettings *-[FBSceneSnapshotContext settings](void)
{
    return self->_settings;
}


bool -[FBSceneSnapshotContext clientAllowsProtectedContent](void)
{
    return self->_clientAllowsProtectedContent;
}


NSDate *-[FBSceneSnapshotContext expirationDate](void)
{
    return self->_expirationDate;
}


id -[FBSceneSnapshotContext userInfo](void)
{
    return self->_userInfo;
}


void -[FBSceneSnapshotContext setUserInfo:](id a1)
{
    self->_userInfo = a1;
}


double -[FBSceneSnapshotContext frame](void)
{
    return self->_frame.origin.x;
}


void -[FBSceneSnapshotContext setFrame:](long a1)
{
    struct CGRect v0;
    long v1;
    long v2;
    long v3;
    self->_frame.origin.x = v0;
    self->_frame.origin.y = v1;
    self->_frame.size.width = v2;
    self->_frame.size.height = v3;
}


bool -[FBSceneSnapshotContext isOpaque](void)
{
    return self->_opaque;
}


void -[FBSceneSnapshotContext setOpaque:](bool a1)
{
    self->_opaque = a1;
}


long -[FBSceneSnapshotContext orientation](void)
{
    return self->_orientation;
}


NSSet *-[FBSceneSnapshotContext layersToExclude](void)
{
    return self->_layersToExclude;
}


long -[FBSceneSnapshotContext setLayersToExclude:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 72);
}


FBSceneLayer *-[FBSceneSnapshotContext backgroundLayer](void)
{
    return self->_backgroundLayer;
}


long -[FBSceneSnapshotContext setBackgroundLayer:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 80);
}
