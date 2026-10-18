struct FBWorkspaceConnectionsState {
    NSMutableIndexSet *_pidSet; // +0x8
};

void -[FBWorkspaceConnectionsState .cxx_destruct](void)
{
    self->_pidSet = nil;
}


long -[FBWorkspaceConnectionsState serializeToWriter:](id a1)
{
    long v3;
    char v7[256];
    id v0 = a1;
    __block long v1 = 0;
    if ([self->_pidSet count] < 0) {
        os_log_t oslog = FBLogCommon();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "data section is too large");
        }
        v3 = -1;
    } else {
        NSUInteger count = [self->_pidSet count];
        long v5 = v0->field_16(v0, &count, 4);
        if (v5 < 0) {
            int *v6 = __error();
            strerror_r(*(v6), v7, 0x100);
            os_log_t oslog2 = FBLogCommon();
            if (os_log_type_enabled(oslog2, OS_LOG_TYPE_ERROR)) {
                int *v9 = __error();
                int v2 = *(v9);
                os_log_with_type(oslog2, OS_LOG_TYPE_ERROR, "failed to write count (%i) : errno=%i (%s)", count, v2, &v7);
            }
            v1 = -1;
        } else {
            v1 += v5;
            [self->_pidSet enumerateIndexesUsingBlock:^void(unsigned long arg1, bool *arg2) {
                unsigned long v14 = arg1;
                long v16 = v0->field_16(v0, &v14, 4);
                if (v16 < 0) {
                    int *v17 = __error();
                    strerror_r(*(v17), &count, 0x100);
                    os_log_t v21 = FBLogCommon();
                    if (os_log_type_enabled(v21, OS_LOG_TYPE_ERROR)) {
                        int *v20 = __error();
                        int v22 = *(v20);
                        os_log_with_type(v21, OS_LOG_TYPE_ERROR, "failed to write pid (%i) : errno=%i (%s)", v14, v22, &count);
                    }
                    v1 = -1;
                    *(arg2) = 1;
                } else {
                    v1 += v16;
                }
            }];
        }
        v3 = v1;
    }
    return v3;
}


BOOL -[FBWorkspaceConnectionsState isEqual:](id a1)
{
    BOOL v1;
    if (self == a1) {
        return YES;
    }
    Class v2 = [a1 class];
    Class v3 = [FBWorkspaceConnectionsState class];
    if (v2 == v3) {
        v1 = [self->_pidSet isEqualToIndexSet:a1->field_8];
    } else {
        Class v4 = [a1 class];
        Class v5 = [FBMutableWorkspaceConnectionsState class];
        if (v4 == v5) {
            v1 = [self->_pidSet isEqualToIndexSet:a1->field_8];
        } else {
            v1 = NO;
        }
    }
    return v1;
}


id -[FBWorkspaceConnectionsState copy](void)
{
    return [super copy];
}


long -[FBWorkspaceConnectionsState serializedDataLength](void)
{
    return [self->_pidSet count] * 4 + 4;
}


FBWorkspaceConnectionsState *-[FBWorkspaceConnectionsState init](void)
{
    return [self _initWithIndexSet:0];
}


FBWorkspaceConnectionsState *-[FBWorkspaceConnectionsState _initWithIndexSet:](id a1)
{
    FBWorkspaceConnectionsState *v2 = [super init];
    if (v2 != nil) {
        v2->_pidSet = (!a1) ? [NSMutableIndexSet indexSet] : [a1 mutableCopy];
    }
    return v2;
}


id -[FBWorkspaceConnectionsState processIdentifiers](void)
{
    if (![self->_pidSet count]) {
        return [NSSet set];
    }
    NSUInteger count = [self->_pidSet count];
    NSMutableSet *v2 = [NSMutableSet setWithCapacity:count];
    [self->_pidSet enumerateIndexesUsingBlock:^void(unsigned long arg1, bool *arg2) {
        NSNumber *v0 = [NSNumber numberWithInt:arg1];
        [v2 addObject:v0];
    }];
    return v2;
}


id -[FBWorkspaceConnectionsState mutableCopy](void)
{
    return [super mutableCopy];
}


int +[FBWorkspaceConnectionsState minimumSerializedDataLength](void)
{
    return 4;
}


FBWorkspaceConnectionsState *+[FBWorkspaceConnectionsState deserializeLength:fromReader:](long *a1, long (^a2)(void *, unsigned long))
{
    os_log_t v6;
    FBWorkspaceConnectionsState *v7;
    os_log_t v14;
    char v5[256];
    FBWorkspaceConnectionsState *v1 = [FBWorkspaceConnectionsState new];
    int v2 = 0;
    long v3 = a2(&v2, 4);
    if (v3 < 0) {
        int *v4 = __error();
        strerror_r(*(v4), v5, 0x100);
        v6 = FBLogCommon();
        if (os_log_type_enabled(v6, OS_LOG_TYPE_ERROR)) {
            int *v15 = __error();
            int v9 = *(v15);
            os_log_with_type(v6, OS_LOG_TYPE_ERROR, "failed to read count : errno=%i (%s)", v9, &v5);
        }
        v7 = nil;
    } else {
        long continuationRoute1 = 0;
        if (v2 > 0) {
            int v8 = 0;
            while (v3 >= -4) {
                NSUInteger v10 = -1;
                long v11 = a2(&v10, 4);
                if (v11 < 0) {
                    int *v13 = __error();
                    strerror_r(*(v13), v5, 0x100);
                    v14 = FBLogCommon();
                    if (!os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
                        return nil;
                    }
                    int *v17 = __error();
                    int v12 = *(v17);
                    os_log_with_type(v14, OS_LOG_TYPE_ERROR, "failed to read pid %i : errno=%i (%s)", v8 + 1, v12, &v5);
                    return nil;
                }
                if ((int)(uint32_t)v10 <= 0) {
                    v14 = FBLogCommon();
                    if (!os_log_type_enabled(v14, OS_LOG_TYPE_ERROR)) {
                        return nil;
                    }
                    os_log_with_type(v14, OS_LOG_TYPE_ERROR, "pid %i is invalid (%i)", v8 + 1, v10);
                    return nil;
                }
                v3 += v11;
                [v1->field_8 addIndex:(uint32_t)v10];
                v8++;
                if (v8 < v2) {
                    continue;
                }
                continuationRoute1 = 1;
                break;
            }
            if (!continuationRoute1) {
                v6 = FBLogCommon();
                if (os_log_type_enabled(v6, OS_LOG_TYPE_ERROR)) {
                    os_log_with_type(v6, OS_LOG_TYPE_ERROR, "data section is too large");
                    return nil;
                }
                return nil;
            }
        }
        if (a1 != 0) {
            *(a1) = v3;
        }
        v7 = v1;
    }
    return v7;
}


NSUInteger -[FBWorkspaceConnectionsState hash](void)
{
    return [self->_pidSet hash];
}


NSString *-[FBWorkspaceConnectionsState description](void)
{
    NSMutableString *string = [NSMutableString string];
    [self->_pidSet enumerateRangesUsingBlock:^void(struct _NSRange arg1, bool *arg2) {
        if ([string length] != 0) {
            [string appendString:@","];
        }
        NSNumber *v5 = [NSNumber numberWithUnsignedInteger:arg1.location];
        NSString *stringValue2 = [v5 stringValue];
        [string appendString:stringValue2];
        if (arg2 < 2) {
            return;
        }
        [string appendString:@"-"];
        NSNumber *v3 = [NSNumber numberWithUnsignedInteger:arg1.location + arg2];
        NSString *stringValue = [v3 stringValue];
        [string appendString:stringValue];
    }];
    return [NSString stringWithFormat:@"<%@:%p pids=%@>", [self class], self, string];
}


long -[FBWorkspaceConnectionsState copyWithZone:](long a1)
{
    return self;
}


FBMutableWorkspaceConnectionsState *-[FBWorkspaceConnectionsState mutableCopyWithZone:](long a1)
{
    return [[FBMutableWorkspaceConnectionsState alloc] _initWithIndexSet:self->_pidSet];
}
