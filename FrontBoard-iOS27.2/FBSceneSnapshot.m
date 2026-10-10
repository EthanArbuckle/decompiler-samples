struct FBSceneSnapshot {
    FBScene *_scene; // +0x8
    id<FBSceneSnapshotInternalConfiguration> _config; // +0x10
    FBSceneSnapshotContext *_context; // +0x18
    _FBSSnapshot *_snapshot; // +0x20
};

NSMutableOrderedSet *-[FBSceneSnapshot _collectLayersToSnapshotFromScene:withSnapshotConfig:rootConfig:](id a1, id a2, id a3)
{
    CATransform3D v5;
    CGFloat v4;
    CGAffineTransform v6;
    if (!self) {
        return nil;
    }
    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    [self _baseTransformForSnapshotConfig:a2 rootConfig:a3, &v4];
    _memset(&v5, 0, 128);
    v6.a = v4;
    v6.c = v4.field_16;
    v6.tx = v4.field_32;
    v5 = CATransform3DMakeAffineTransform(v6);
    FBSceneLayer *backgroundLayer = [a2 backgroundLayer];
    if (backgroundLayer != nil) {
        unsigned int contextID2 = [backgroundLayer contextID];
        if (contextID2 != 0) {
            _FBSSnapshotLayer *v10 = [_FBSSnapshotLayer alloc];
            memmove(&v6, &v5, 128);
            _FBSSnapshotLayer *v11 = [v10 initWithContextID:contextID2 baseTransform:&v6];
            if (v11 != nil) {
                [orderedSet addObject:v11];
            }
        }
    }
    FBSceneLayerManager *layerManager = [a1 layerManager];
    NSOrderedSet *layers = [layerManager layers];
    NSMutableOrderedSet *v14 = [NSMutableOrderedSet orderedSetWithOrderedSet:layers];
    NSSet *layersToExclude = [a2 layersToExclude];
    [v14 minusSet:layersToExclude];
    id keyboardScene = [FBSceneManager keyboardScene];
    for (FBSceneLayer *v23 in v14) {
        unsigned int contextID = [v23 contextID];
        if (contextID != 0) {
            _FBSSnapshotLayer *v25 = [_FBSSnapshotLayer alloc];
            memmove(&v6, &v5, 128);
            _FBSSnapshotLayer *v26 = [v25 initWithContextID:contextID baseTransform:&v6];
            if (v26 != nil) {
                [orderedSet addObject:v26];
            }
        } else if ([v23 isKeyboardLayer]) {
            if (a1 == keyboardScene) {
                NSOrderedSet *other = [self _collectLayersToSnapshotFromScene:keyboardScene withSnapshotConfig:[[FBSceneSnapshotContext alloc] initWithScene:keyboardScene configurator:nil] rootConfig:a3];
                [orderedSet unionOrderedSet:other];
            }
        } else if ([v23 isKeyboardProxyLayer]) {
            FBSSceneIdentityToken *identityToken = [keyboardScene identityToken];
            FBSSceneIdentityToken *proxiedKeyboardOwner = [v23 proxiedKeyboardOwner];
            if ([identityToken isEqual:proxiedKeyboardOwner]) {
                NSOrderedSet *other2 = [self _collectLayersToSnapshotFromScene:keyboardScene withSnapshotConfig:[[FBSceneSnapshotContext alloc] initWithScene:keyboardScene configurator:nil] rootConfig:a3];
                [orderedSet unionOrderedSet:other2];
            }
        }
    }
    return orderedSet;
}


FBSceneSnapshot *-[FBSceneSnapshot _initWithScene:configuration:](FBScene *a1, id<FBSceneSnapshotInternalConfiguration> a2)
{
    if (!self) {
        return self;
    }
    if (![NSThread isMainThread]) {
        __FB_REPORT_MAIN_THREAD_VIOLATION__(0, "-[FBSceneSnapshot _initWithScene:configuration:]");
    }
    self = [super init];
    if (!self) {
        return self;
    }
    self->_scene = a1;
    self->_config = a2;
    id v3 = [self _collectLayersToSnapshotFromScene:self->_scene withSnapshotConfig:a2 rootConfig:a2];
    _FBSSnapshotContext *v4 = [_FBSSnapshotContext alloc];
    FBSSceneSettings *settings2 = [a1 settings];
    _FBSSnapshotContext *v6 = [v4 initWithDisplayConfiguration:[settings2 displayConfiguration] layers:v3];
    double scale = [a2 scale];
    [v6 setScale:scale];
    BOOL isOpaque = [a2 isOpaque];
    [v6 setOpaque:isOpaque];
    bool clientAllowsProtectedContent = [a2 clientAllowsProtectedContent];
    [v6 setAllowsProtectedContent:clientAllowsProtectedContent];
    CGRect frame = [a2 frame];
    long v11 = frame.size.width;
    CGFloat sizeheight = frame.size.height;
    if (![a2 orientation]) {
        FBSSceneSettings *settings = [a2 settings];
        long v14 = BSInterfaceOrientationIsLandscape([settings interfaceOrientation]);
        if (v14 != 0) {
            v11 = sizeheight;
        }
    }
    [v6 setSnapshotSize:v11, sizeheight];
    self->_snapshot = [[_FBSSnapshot alloc] initWithSnapshotContext:v6];
    return self;
}


FBSceneSnapshot *-[FBSceneSnapshot initWithScene:context:](long a1, FBSceneSnapshotContext *a2)
{
    FBSceneSnapshot *v1 = [self _initWithScene:a1 configuration:a2];
    if (v1 != nil) {
        v1->_context = a2;
    }
    return v1;
}


void -[FBSceneSnapshot _baseTransformForSnapshotConfig:rootConfig:](id a1, id a2, void *a3)
{
    long v17;
    CGFloat v19;
    CGFloat v20;
    CGAffineTransform v22;
    CGAffineTransform v24;
    CGAffineTransform v23;
    CGFloat v33;
    CGFloat v26;
    double v30;
    CGAffineTransform v28;
    if (!self) {
        a3->field_16 = 0;
        a3->field_32 = 0;
        *(a3) = 0;
        return;
    }
    *(__uint128_t *)a3 = *(__uint128_t *)&CGAffineTransformIdentity;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&CGAffineTransformIdentity + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&CGAffineTransformIdentity + 32);
    FBSSceneSettings *settings3 = [a1 settings];
    long interfaceOrientation2 = [settings3 interfaceOrientation];
    long v8 = (BSInterfaceOrientationIsValid(interfaceOrientation2) != 0) ? interfaceOrientation2 : 1;
    FBSSceneSettings *settings4 = [a2 settings];
    long interfaceOrientation = [settings4 interfaceOrientation];
    long v11 = BSInterfaceOrientationIsValid(interfaceOrientation);
    FBSSceneSettings *settings = [self->_scene settings];
    id displayConfiguration = [settings displayConfiguration];
    [displayConfiguration bounds];
    CGRect frame = [a2 frame];
    CGFloat v15 = frame.origin.x;
    CGFloat originy = frame.origin.y;
    if (![a2 orientation]) {
        v17 = (v11 != 0) ? interfaceOrientation : 1;
        long v18 = BSInterfaceOrientationIsLandscape((v11 != 0) ? interfaceOrientation : 1);
        v19 = (v18 != 0) ? v15 : originy;
        v20 = (v18 != 0) ? originy : v15;
        v15 = (v18 != 0) ? v15 : originy;
    } else {
        v17 = 1;
        v20 = v15;
        v19 = originy;
    }
    if (v8 == v17) {
        _memset(v22 + 16, 0, 32);
        v22 = CGAffineTransformMakeTranslation(-v20, -v19);
        v24.a = *(a3);
        *(__uint128_t *)(&v24 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v24 + 32) = *(__uint128_t *)(a3 + 32);
        v23 = CGAffineTransformConcat(v24, v22);
        *(a3) = v23.a;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v23 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v23 + 32);
        v33 = [a2 scale];
        _memset(&v23, 0, 48);
        v23 = CGAffineTransformMakeScale(v33);
        *(__uint128_t *)&v28 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v28 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v28 + 32) = *(__uint128_t *)(a3 + 32);
        v24 = CGAffineTransformConcat(v28, v23);
        *(a3) = v24.a;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v24 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v24 + 32);
        return;
    }
    FBSSceneSettings *settings2 = [a1 settings];
    [settings2 frame];
    if (v8 != 1) {
        BSConvertRectFromOrientationToOrientation(1, v8);
    }
    BSRectGetCenter();
    v22.c = 0;
    v22.tx = 0;
    v22 = CGAffineTransformMakeTranslation(v15, originy);
    v23 = CGAffineTransformIdentity;
    v24 = v22;
    int *v25 = &v23;
    CGAffineTransformConcat(v23, v24, a3);
    if (v8 != 1) {
        switch (v8) {
            case 3:
                v26 = 1.5707963267948966;
                break;
            case 4:
                v26 = -1.5707963267948966;
                break;
            default:
                v26 = (v8 == 2) ? 3.141592653589793 : 0.0;
                break;
        }
        _memset(&v23, 0, 48);
        v24 = CGAffineTransformMakeRotation(v26);
        BSIntegralTransform(&v24, &v23);
        *(__uint128_t *)&v28 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v28 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v28 + 32) = *(__uint128_t *)(a3 + 32);
        v25 = &v28;
        v24 = CGAffineTransformConcat(v28, v23);
        *(a3) = v24.a;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v24 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v24 + 32);
    }
    if (v17 != 1) {
        switch (v17) {
            case 3:
                v30 = 1.5707963267948966;
                break;
            case 4:
                v30 = -1.5707963267948966;
                break;
            default:
                v30 = (v17 == 2) ? 3.141592653589793 : 0.0;
                break;
        }
        _memset(&v23, 0, 48);
        v24 = CGAffineTransformMakeRotation(-v30);
        BSIntegralTransform(&v24, &v23);
        *(__uint128_t *)&v28 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v28 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v28 + 32) = *(__uint128_t *)(a3 + 32);
        v24 = CGAffineTransformConcat(v28, v23);
        *(a3) = v24.a;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v24 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v24 + 32);
        v25 = BSConvertRectFromOrientationToOrientation(1, v17);
    }
    CGFloat tx = BSRectGetCenter(v25);
    v23.c = 0;
    v23.tx = 0;
    v23.a = 0;
    v23 = CGAffineTransformMakeTranslation(tx);
    *(__uint128_t *)&v28 = *(__uint128_t *)a3;
    *(__uint128_t *)(&v28 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v28 + 32) = *(__uint128_t *)(a3 + 32);
    v24 = CGAffineTransformConcat(v28, v23);
    *(a3) = v24.a;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v24 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v24 + 32);
    v22.c = 0;
    v22.tx = 0;
    v22 = CGAffineTransformMakeTranslation(-v20, -v19);
    v24.a = *(a3);
    *(__uint128_t *)(&v24 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v24 + 32) = *(__uint128_t *)(a3 + 32);
    v23 = CGAffineTransformConcat(v24, v22);
    *(a3) = v23.a;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v23 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v23 + 32);
    v33 = [a2 scale];
    v23.c = 0;
    v23.tx = 0;
    v23.a = 0;
    v23 = CGAffineTransformMakeScale(v33);
    *(__uint128_t *)&v28 = *(__uint128_t *)a3;
    *(__uint128_t *)(&v28 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v28 + 32) = *(__uint128_t *)(a3 + 32);
    v24 = CGAffineTransformConcat(v28, v23);
    *(a3) = v24.a;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v24 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v24 + 32);
}


void -[FBSceneSnapshot .cxx_destruct](void)
{
    self->_snapshot = nil;
    self->_context = nil;
    self->_config = nil;
    self->_scene = nil;
}


long -[FBSceneSnapshot hasProtectedContent](void)
{
    IOSurface *fallbackIOSurface = [self fallbackIOSurface];
    if (fallbackIOSurface != nil) {
        return 1;
    }
    return 0;
}


long -[FBSceneSnapshot IOSurface](void)
{
    return [self->_snapshot IOSurface];
}


long -[FBSceneSnapshot CGImage](void)
{
    return [self->_snapshot CGImage];
}


long -[FBSceneSnapshot capture](void)
{
    return [self->_snapshot capture];
}


long -[FBSceneSnapshot fallbackIOSurface](void)
{
    return [self->_snapshot fallbackIOSurface];
}


FBScene *-[FBSceneSnapshot scene](void)
{
    return self->_scene;
}


id<FBSceneSnapshotInternalConfiguration> -[FBSceneSnapshot configuration](void)
{
    return self->_config;
}


FBSceneSnapshotContext *-[FBSceneSnapshot context](void)
{
    return self->_context;
}
