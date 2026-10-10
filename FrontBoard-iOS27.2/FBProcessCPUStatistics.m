struct FBProcessCPUStatistics {
    RBSProcessHandle *_handle; // +0x8
    struct FBProcessTimes _times; // +0x10
    struct os_unfair_lock_s _lock; // +0x30
};

void -[FBProcessCPUStatistics .cxx_destruct](void)
{
    self->_handle = nil;
}


void -[FBProcessCPUStatistics reset](void)
{
    os_unfair_lock_lock(&self->_lock);
    [self _hostwideUserElapsedCPUTime:&self->_times systemElapsedCPUTime:&self->_times.beginSystemCPUElapsedTime idleElapsedCPUTime:&self->_times.beginIdleCPUElapsedTime];
    self->_times.beginApplicationCPUElapsedTime = [self->_handle elapsedCPUTimeForFrontBoard];
    os_unfair_lock_unlock(&self->_lock);
}


FBProcessCPUStatistics *-[FBProcessCPUStatistics initWithProcessHandle:](RBSProcessHandle *a1)
{
    FBProcessCPUStatistics *v5;
    FBProcessCPUStatistics *v6;
    void *dso;
    FBProcessCPUStatistics *self;
    Class v1 = NSClassFromString(@"RBSProcessHandle");
    if (!a1) {
        NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"_bs_assert_object != nil"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSStringFromSelector(_cmd);
            NSString *v9 = NSStringFromClass([self class]);
            dso = OUTLINED_FUNCTION_0(v9, 6.8450148e-316);
            _os_log_error_impl(dso, dso.word1, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", &v5, 58);
        }
        _bs_set_crash_log_message([v7 UTF8String]);
        __break(0);
    }
    if (![a1 isKindOfClass:v1]) {
        NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"[_bs_assert_object isKindOfClass:RBSProcessHandleClass]"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSStringFromSelector(_cmd);
            NSString *v13 = NSStringFromClass([self class]);
            void *v10 = OUTLINED_FUNCTION_0(v13, 6.8450148e-316);
            _os_log_error_impl(v10, dso.word1, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", &v5, 58);
        }
        _bs_set_crash_log_message([v11 UTF8String]);
        __break(0);
    }
    int pid = [a1 pid];
    long v3 = __getpid(pid);
    if (pid == v3) {
blk_1c4ef2f64:
        v5 = [super init];
        if (v5 != nil) {
            v5->_lock._os_unfair_lock_opaque = 0;
            v5->_handle = a1;
            [v5 reset];
        }
        self = v5;
        v6 = self;
    } else {
        dispatch_once(&initWithProcessHandle:.onceToken, ^void(void) {
            initWithProcessHandle:.entitled = BSSelfTaskHasEntitlement(@"com.apple.runningboard.process-state");
        });
        if (initWithProcessHandle:.entitled != 1) {
            v6 = nil;
        } else {
            goto blk_1c4ef2f64;
        }
    }
    return v6;
}


int -[FBProcessCPUStatistics _hostwideUserElapsedCPUTime:systemElapsedCPUTime:idleElapsedCPUTime:](long *a1, long *a2, long *a3)
{
    long v13;
    long v18;
    long v15;
    long v19;
    uint8_t v10[32];
    long host_info_out = 0;
    host_info_out.field_8 = 0;
    mach_msg_type_number_t host_info_outCnt = 4;
    host_t host_priv = host_self_trap(self);
    int v3 = host_statistics(host_priv, 3, &host_info_out, &host_info_outCnt);
    double v4 = 0.0;
    double v5 = 0.0;
    double v6 = 0.0;
    if (!v3) {
        int v7 = host_info_out.field_12 + host_info_out;
        int v8 = _cpuTicksToTimeInterval.microsecondsPerTick;
        if (_cpuTicksToTimeInterval.microsecondsPerTick < 1) {
            _memset(v10, 0, 20);
            size_t v11 = 20;
            int v12 = 0xc00000001;
            v3 = sysctl(&v12, 2, v10, &v11, NULL, 0);
            if (!v3) {
                v13 = *(uint64_t *)&v10[4];
                _cpuTicksToTimeInterval.microsecondsPerTick = *(uint64_t *)&v10[4];
            } else {
                v13 = _cpuTicksToTimeInterval.microsecondsPerTick;
            }
            v8 = (int32_t)v13;
            v4 = (double)(long)((int32_t)v13 * v7) / 1000000.0;
            long v14 = host_info_out.field_4;
            if (v13 <= 0) {
                *(uint64_t *)&v10[0] = 0;
                *(uint64_t *)&v10[8] = 0;
                *(uint32_t *)&v10[16] = 0;
                v11 = 20;
                v12 = 0xc00000001;
                v3 = sysctl(&v12, 2, v10, &v11, NULL, 0);
                if (!v3) {
                    v18 = *(uint64_t *)&v10[4];
                    _cpuTicksToTimeInterval.microsecondsPerTick = *(uint64_t *)&v10[4];
                } else {
                    v18 = _cpuTicksToTimeInterval.microsecondsPerTick;
                }
                v8 = (int32_t)v18;
                v15 = v8 * v14;
                if (v18 > 0) {
                    goto blk_1c4f0b4b0;
                }
                *(uint64_t *)&v10[0] = 0;
                *(uint64_t *)&v10[8] = 0;
                *(uint32_t *)&v10[16] = 0;
                v11 = 20;
                v12 = 0xc00000001;
                v3 = sysctl(&v12, 2, v10, &v11, NULL, 0);
                if (!v3) {
                    v19 = *(uint64_t *)&v10[4];
                    _cpuTicksToTimeInterval.microsecondsPerTick = *(uint64_t *)&v10[4];
                } else {
                    v19 = _cpuTicksToTimeInterval.microsecondsPerTick;
                }
                v8 = (int32_t)v19;
                goto blk_1c4f0b4b0;
            }
        } else {
            v4 = (double)(unsigned long)(v8 * v7) / 1000000.0;
        }
        v15 = v8 * host_info_out.field_4;
blk_1c4f0b4b0:
        v5 = (double)v15 / 1000000.0;
        v6 = (double)(long)(v8 * (uint32_t)host_info_out.field_8) / 1000000.0;
    }
    if (a1 != 0) {
        *(a1) = v4;
    }
    if (a2 != 0) {
        *(a2) = v5;
    }
    if (a3 != 0) {
        *(a3) = v6;
    }
    return v3;
}


long -[FBProcessCPUStatistics totalElapsedTime](void)
{
    return [self->_handle elapsedCPUTimeForFrontBoard];
}


double -[FBProcessCPUStatistics totalElapsedUserTime](void)
{
    long v0 = 0;
    os_unfair_lock_lock(&self->_lock);
    [self _lock_getApplicationCPUTimesForUser:&v0 system:0 idle:0];
    os_unfair_lock_unlock(&self->_lock);
}


double -[FBProcessCPUStatistics totalElapsedSystemTime](void)
{
    long v0 = 0;
    os_unfair_lock_lock(&self->_lock);
    [self _lock_getApplicationCPUTimesForUser:0 system:&v0 idle:0];
    os_unfair_lock_unlock(&self->_lock);
}


double -[FBProcessCPUStatistics totalElapsedIdleTime](void)
{
    long v0 = 0;
    os_unfair_lock_lock(&self->_lock);
    [self _lock_getApplicationCPUTimesForUser:0 system:0 idle:&v0];
    os_unfair_lock_unlock(&self->_lock);
}


NSArray<NSString *> *-[FBProcessCPUStatistics descriptionForCrashReport](void)
{
    os_unfair_lock_lock(&self->_lock);
    double v0 = 0;
    double v1 = 0;
    long v2 = 0;
    [self _lock_getApplicationCPUTimesForUser:&v1 system:&v0 idle:&v2];
    double v3 = v0 + v1;
    double v4 = v2 + v3;
    long v5 = (long)round(v3 * 100.0 / v4);
    double elapsedCPUTimeForFrontBoard = [self->_handle elapsedCPUTimeForFrontBoard];
    double v7 = elapsedCPUTimeForFrontBoard - self->_times.beginApplicationCPUElapsedTime;
    long v8 = (long)round(v7 * 100.0 / v4);
    os_unfair_lock_unlock(&self->_lock);
    NSString *v11 = [NSString stringWithFormat:@"Elapsed total CPU time (seconds): %.3f (user %.3f, system %.3f), %i%% CPU", v1 + v0, v1, v0, v5];
    NSString *v13 = [NSString stringWithFormat:@"Elapsed application CPU time (seconds): %.3f, %i%% CPU", v7, v8];
    return @[v11, v13];
}


long -[FBProcessCPUStatistics _lock_getApplicationCPUTimesForUser:system:idle:](long *a1, long *a2, long *a3)
{
    os_unfair_lock_assert_owner(&self->_lock);
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = [self _hostwideUserElapsedCPUTime:&v1 systemElapsedCPUTime:&v0 idleElapsedCPUTime:&v2];
    if (a1 != 0) {
        *(a1) = v1 - self->_times.beginUserCPUElapsedTime;
    }
    if (a2 != 0) {
        *(a2) = v0 - self->_times.beginSystemCPUElapsedTime;
    }
    if (a3 != 0) {
        *(a3) = v2 - self->_times.beginIdleCPUElapsedTime;
    }
    return v3;
}
