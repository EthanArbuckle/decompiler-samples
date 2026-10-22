struct FBSceneSnapshot {
    FBScene *_scene; // +0x8
    id<FBSceneSnapshotInternalConfiguration> _config; // +0x10
    FBSceneSnapshotContext *_context; // +0x18
    _FBSSnapshot *_snapshot; // +0x20
};

NSMutableOrderedSet *-[FBSceneSnapshot _collectLayersToSnapshotFromScene:withSnapshotConfig:rootConfig:](id a1, id a2, id a3)
{
    CATransform3D v5;
    long v4;
    if (!self) {
        return nil;
    }
    NSMutableOrderedSet *orderedSet = [NSMutableOrderedSet orderedSet];
    [self _baseTransformForSnapshotConfig:a2 rootConfig:a3, &v4];
    _memset(&v5, 0, 128);
    CGAffineTransform v6 = v4;
    v5 = CATransform3DMakeAffineTransform(v6);
    FBSceneLayer *backgroundLayer = [a2 backgroundLayer];
    if (backgroundLayer) {
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
    for (FBSceneLayer *v22 in v14) {
        unsigned int contextID = [v22 contextID];
        if (contextID != 0) {
            _FBSSnapshotLayer *v24 = [_FBSSnapshotLayer alloc];
            memmove(&v6, &v5, 128);
            _FBSSnapshotLayer *v25 = [v24 initWithContextID:contextID baseTransform:&v6];
            if (v25 != nil) {
                [orderedSet addObject:v25];
            }
        } else if ([v22 isKeyboardLayer]) {
            if (a1 == keyboardScene) {
                NSOrderedSet *other = [self _collectLayersToSnapshotFromScene:keyboardScene withSnapshotConfig:[[FBSceneSnapshotContext alloc] initWithScene:keyboardScene configurator:nil] rootConfig:a3];
                [orderedSet unionOrderedSet:other];
            }
        } else if ([v22 isKeyboardProxyLayer]) {
            FBSSceneIdentityToken *identityToken = [keyboardScene identityToken];
            FBSSceneIdentityToken *proxiedKeyboardOwner = [v22 proxiedKeyboardOwner];
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
    long v12 = frame.size.height;
    if (![a2 orientation]) {
        FBSSceneSettings *settings = [a2 settings];
        long v14 = BSInterfaceOrientationIsLandscape([settings interfaceOrientation]);
        long v15 = (v14 != 0) ? v11 : v12;
        if (v14 != 0) {
            v11 = v12;
        }
        v12 = v15;
    }
    [v6 setSnapshotSize:v11, v12];
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
    long v20;
    CGAffineTransform v31;
    CGAffineTransform v33;
    CGAffineTransform v32;
    CGFloat v42;
    CGAffineTransform v38;
    CGFloat v35;
    double v39;
    CGAffineTransform v37;
    if (!self) {
        a3->field_16 = 0;
        a3->field_32 = 0;
        *(a3) = 0;
        return;
    }
    __uint128_t v3 = *(__uint128_t *)&CGAffineTransformIdentity;
    *(a3) = v3;
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
    CGRect bounds = [displayConfiguration bounds];
    CGFloat sizewidth = bounds.size.width;
    CGFloat sizeheight = bounds.size.height;
    CGRect frame = [a2 frame];
    CGFloat v18 = frame.origin.x;
    CGFloat v19 = frame.origin.y;
    if (![a2 orientation]) {
        v20 = (v11 != 0) ? interfaceOrientation : 1;
        long v21 = BSInterfaceOrientationIsLandscape(v20);
        CGFloat v22 = (v21 != 0) ? v18 : v19;
        if (v21 != 0) {
            v18 = v19;
        }
        v19 = v22;
    } else {
        v20 = 1;
    }
    if (v8 == v20) {
        v31 = CGAffineTransformMakeTranslation(-v18, -v19);
        v33.a = *(a3);
        *(__uint128_t *)(&v33 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v33 + 32) = *(__uint128_t *)(a3 + 32);
        v32 = CGAffineTransformConcat(v33, v31);
        *(__uint128_t *)a3 = *(__uint128_t *)&v32;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v32 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v32 + 32);
        v42 = [a2 scale];
        _memset(&v32, 0, 48);
        v32 = CGAffineTransformMakeScale(v42);
        *(__uint128_t *)&v37 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v37 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v37 + 32) = *(__uint128_t *)(a3 + 32);
        v38 = v32;
        v33 = CGAffineTransformConcat(v37, v38);
        *(__uint128_t *)a3 = *(__uint128_t *)&v33;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v33 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v33 + 32);
        return;
    }
    FBSSceneSettings *settings2 = [a1 settings];
    CGRect frame2 = [settings2 frame];
    CGFloat originx = frame2.origin.x;
    CGFloat originy = frame2.origin.y;
    CGFloat sizewidth2 = frame2.size.width;
    CGFloat sizeheight2 = frame2.size.height;
    if (v8 != 1) {
        BSConvertRectFromOrientationToOrientation(1, v8, originx, originy, sizewidth2, sizeheight2, sizewidth, sizeheight);
    }
    BSRectGetCenter();
    v31 = CGAffineTransformMakeTranslation(originx, originy);
    v32 = CGAffineTransformIdentity;
    v33 = v31;
    int *v34 = &v32;
    CGAffineTransformConcat(v32, v33, a3);
    if (v8 != 1) {
        switch (v8) {
            case 3:
                v35 = 1.5707963267948966;
                break;
            case 4:
                v35 = -1.5707963267948966;
                break;
            default:
                v35 = (v8 == 2) ? 3.141592653589793 : 0.0;
                break;
        }
        _memset(&v32, 0, 48);
        v33 = CGAffineTransformMakeRotation(v35);
        BSIntegralTransform(&v33, &v32);
        *(__uint128_t *)&v37 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v37 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v37 + 32) = *(__uint128_t *)(a3 + 32);
        v38 = v32;
        v34 = &v37;
        v33 = CGAffineTransformConcat(v37, v38);
        *(__uint128_t *)a3 = *(__uint128_t *)&v33;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v33 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v33 + 32);
    }
    if (v20 != 1) {
        switch (v20) {
            case 3:
                v39 = 1.5707963267948966;
                break;
            case 4:
                v39 = -1.5707963267948966;
                break;
            default:
                v39 = (v20 == 2) ? 3.141592653589793 : 0.0;
                break;
        }
        _memset(&v32, 0, 48);
        v33 = CGAffineTransformMakeRotation(-v39);
        BSIntegralTransform(&v33, &v32);
        *(__uint128_t *)&v37 = *(__uint128_t *)a3;
        *(__uint128_t *)(&v37 + 16) = *(__uint128_t *)(a3 + 16);
        *(__uint128_t *)(&v37 + 32) = *(__uint128_t *)(a3 + 32);
        v38 = v32;
        v33 = CGAffineTransformConcat(v37, v38);
        *(__uint128_t *)a3 = *(__uint128_t *)&v33;
        *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v33 + 16);
        *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v33 + 32);
        v34 = BSConvertRectFromOrientationToOrientation(1, v20, originx, originy, sizewidth2, sizeheight2, sizewidth, sizeheight);
    }
    CGFloat tx = BSRectGetCenter(v34);
    v32 = (CGAffineTransform){0};
    v32 = CGAffineTransformMakeTranslation(tx);
    *(__uint128_t *)&v37 = *(__uint128_t *)a3;
    *(__uint128_t *)(&v37 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v37 + 32) = *(__uint128_t *)(a3 + 32);
    v38 = v32;
    v33 = CGAffineTransformConcat(v37, v38);
    *(__uint128_t *)a3 = *(__uint128_t *)&v33;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v33 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v33 + 32);
    v31 = CGAffineTransformMakeTranslation(-v18, -v19);
    v33.a = *(a3);
    *(__uint128_t *)(&v33 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v33 + 32) = *(__uint128_t *)(a3 + 32);
    v32 = CGAffineTransformConcat(v33, v31);
    *(__uint128_t *)a3 = *(__uint128_t *)&v32;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v32 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v32 + 32);
    v42 = [a2 scale];
    v32 = (CGAffineTransform){0};
    v32 = CGAffineTransformMakeScale(v42);
    *(__uint128_t *)&v37 = *(__uint128_t *)a3;
    *(__uint128_t *)(&v37 + 16) = *(__uint128_t *)(a3 + 16);
    *(__uint128_t *)(&v37 + 32) = *(__uint128_t *)(a3 + 32);
    v38 = v32;
    v33 = CGAffineTransformConcat(v37, v38);
    *(__uint128_t *)a3 = *(__uint128_t *)&v33;
    *(__uint128_t *)(a3 + 16) = *(__uint128_t *)(&v33 + 16);
    *(__uint128_t *)(a3 + 32) = *(__uint128_t *)(&v33 + 32);
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
