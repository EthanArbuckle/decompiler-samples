struct FBApplicationProcess {
    FBProcessCPUStatistics *_cpuStatistics; // +0x170
    bool _recordingAudio; // +0x178
    bool _nowPlayingWithAudio; // +0x179
    bool _connectedToExternalAccessory; // +0x17a
};

static long FBPreferenceDomain;

long -[FBApplicationProcess _finishInit](void)
{
    long v1 = [self->_executionContext launchIntent];
    if (!v1) {
        v1 = __getpid(v1);
        if (self->_pid != v1) {
            id v3 = (!self->_executionContext) ? [[FBMutableProcessExecutionContext alloc] init] : [self->_executionContext mutableCopy];
            [v3 setLaunchIntent:2];
            self->_executionContext = [v3 copy];
        }
    }
    return [super _finishInit];
}


id -[FBApplicationProcess _createBootstrapContext](void)
{
    id v1;
    if (![self isCurrentProcess]) {
        v1 = [super _createBootstrapContext];
        FBProcessExecutionContext *executionContext = [self executionContext];
        if (!self->_rbsHandle) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            id environmentAliases = [BSMachServiceAliases environmentAliases];
            NSDictionary *environmentRepresentation = [environmentAliases environmentRepresentation];
            [dictionary addEntriesFromDictionary:environmentRepresentation];
            NSDictionary *environment = [executionContext environment];
            [dictionary addEntriesFromDictionary:environment];
            NSDictionary *_internalDebugEnvironmentVariables = [FBApplicationProcess _internalDebugEnvironmentVariables];
            [dictionary addEntriesFromDictionary:_internalDebugEnvironmentVariables];
            NSArray *arguments = [executionContext arguments];
            NSURL *standardOutputURL = [executionContext standardOutputURL];
            NSString *path = [standardOutputURL path];
            NSURL *standardErrorURL = [executionContext standardErrorURL];
            NSString *path2 = [standardErrorURL path];
            bool waitForDebugger = [executionContext waitForDebugger];
            bool disableASLR = [executionContext disableASLR];
            [v1 setArguments:arguments];
            if ([dictionary count] != 0) {
                [v1 _setAdditionalEnvironment:dictionary];
            }
            [v1 setStandardOutputPath:path];
            [v1 setStandardErrorPath:path2];
            bool v17 = (disableASLR) ? waitForDebugger | 2 : waitForDebugger;
            bool enableMTE = [executionContext enableMTE];
            [v1 setExecutionOptions:(enableMTE) ? v17 | 128 : v17];
        }
    } else {
        return [super _createBootstrapContext];
    }
    return v1;
}


void -[FBApplicationProcess _bootstrapDidComplete](void)
{
    RBSProcessHandle *rbsHandle = [self rbsHandle];
    if (rbsHandle != nil) {
        self->_cpuStatistics = [[FBProcessCPUStatistics alloc] initWithProcessHandle:rbsHandle];
    }
    [super _bootstrapDidComplete];
}


int -[FBApplicationProcess isApplicationProcess](void)
{
    return 1;
}


NSMutableDictionary *+[FBApplicationProcess _internalDebugEnvironmentVariables](void)
{
    int v2;
    CFTypeRef v6;
    NSMutableDictionary *v0 = [[NSMutableDictionary alloc] init];
    CFStringRef v1 = FBPreferenceDomain;
    if (CFPreferencesGetAppBooleanValue(@"FBMallocStackLogging", FBPreferenceDomain, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocStackLogging"];
        CFPreferencesSetAppValue(@"FBMallocStackLogging", NULL, v1);
        v2 = 1;
    } else if (!CFPreferencesGetAppBooleanValue(@"FBMallocStackLoggingAlways", v1, NULL)) {
        v2 = 0;
    } else {
        [v0 setObject:@"1" forKey:@"MallocStackLogging"];
        CFPreferencesSetAppValue(@"FBMallocStackLogging", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBMallocScribble", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocScribble"];
        CFPreferencesSetAppValue(@"FBMallocScribble", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBMallocScribbleAlways", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocScribble"];
        CFPreferencesSetAppValue(@"FBMallocScribble", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBMallocGuardEdges", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocGuardEdges"];
        CFPreferencesSetAppValue(@"FBMallocGuardEdges", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBMallocGuardEdgesAlways", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocGuardEdges"];
        CFPreferencesSetAppValue(@"FBMallocGuardEdges", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBMallocCheckHeap", v1, NULL) || CFPreferencesGetAppBooleanValue(@"FBMallocCheckHeapAlways", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"MallocCheckHeapStart"];
        [v0 setObject:@"1" forKey:@"MallocCheckHeapAbort"];
        [v0 setObject:@"1" forKey:@"MallocErrorAbort"];
        [v0 setObject:@"1" forKey:@"MallocScribble"];
        CFPreferencesSetAppValue(@"FBMallocCheckHeap", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBGuardMalloc", v1, NULL)) {
        [v0 setObject:@"/usr/lib/libgmalloc.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
        CFPreferencesSetAppValue(@"FBGuardMalloc", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBGuardMallocAlways", v1, NULL)) {
        [v0 setObject:@"/usr/lib/libgmalloc.dylib" forKey:@"DYLD_INSERT_LIBRARIES"];
        CFPreferencesSetAppValue(@"FBGuardMalloc", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBZombieEnabled", v1, NULL)) {
        [v0 setObject:@"YES" forKey:@"NSZombieEnabled"];
        CFPreferencesSetAppValue(@"FBZombieEnabled", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBZombieEnabledAlways", v1, NULL)) {
        [v0 setObject:@"YES" forKey:@"NSZombieEnabled"];
        CFPreferencesSetAppValue(@"FBZombieEnabled", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBDeallocateZombies", v1, NULL)) {
        [v0 setObject:@"YES" forKey:@"NSDeallocateZombies"];
        CFPreferencesSetAppValue(@"FBDeallocateZombies", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBDeallocateZombiesAlways", v1, NULL)) {
        [v0 setObject:@"YES" forKey:@"NSDeallocateZombies"];
        CFPreferencesSetAppValue(@"FBDeallocateZombies", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBSQLiteAutoTrace", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"SQLITE_AUTO_TRACE"];
        CFPreferencesSetAppValue(@"FBSQLiteAutoTrace", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBSQLiteAutoTraceAlways", v1, NULL)) {
        [v0 setObject:@"1" forKey:@"SQLITE_AUTO_TRACE"];
        CFPreferencesSetAppValue(@"FBSQLiteAutoTrace", NULL, v1);
        v2 = 1;
    }
    if (CFPreferencesGetAppBooleanValue(@"FBDYLDRegionPrivate", v1, NULL)) {
        [v0 setObject:@"private" forKey:@"DYLD_SHARED_REGION"];
        CFPreferencesSetAppValue(@"FBDYLDRegionPrivate", NULL, v1);
        v2 = 1;
    } else if (CFPreferencesGetAppBooleanValue(@"FBDYLDRegionPrivateAlways", v1, NULL)) {
        [v0 setObject:@"private" forKey:@"DYLD_SHARED_REGION"];
        CFPreferencesSetAppValue(@"FBDYLDRegionPrivate", NULL, v1);
        v2 = 1;
    }
    CFPropertyListRef v5 = CFPreferencesCopyAppValue(@"FBDYLDAlternateSharedCacheDir", v1);
    if (!v5) {
        v6 = CFPreferencesCopyAppValue(@"FBDYLDAlternateSharedCacheDirAlways", v1);
        v5 = v6;
        if (v6 != 0) {
blk_1c4eedc14:
            CFTypeID v7 = CFGetTypeID(v6);
            CFTypeID v8 = CFStringGetTypeID();
            if (v7 == v8) {
                [v0 setObject:v5 forKey:@"DYLD_SHARED_CACHE_DIR"];
                [v0 setObject:@"private" forKey:@"DYLD_SHARED_REGION"];
            }
        }
    } else {
        CFPreferencesSetAppValue(@"FBDYLDAlternateSharedCacheDir", NULL, v1);
        v2 = 1;
        v6 = v5;
        if (v5 != 0) {
            goto blk_1c4eedc14;
        }
    }
    if (v2) {
        CFPreferencesSynchronize(v1, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    }
    fbs_release(&v5);
    return v0;
}


void -[FBApplicationProcess .cxx_destruct](void)
{
    self->_cpuStatistics = nil;
}


long -[FBApplicationProcess killForReason:andReport:withDescription:](long a1, long a2, long a3)
{
    return [self killForReason:a1 andReport:a2 withDescription:a3 completion:0];
}


long -[FBApplicationProcess killForReason:andReport:withDescription:completion:](long a1, long a2, long a3, long a4)
{
    return [self _killForReason:a1 andReport:a2 withDescription:a3 completion:a4];
}


double -[FBApplicationProcess elapsedCPUTime](void)
{
    return [self->_cpuStatistics totalElapsedTime];
}


bool -[FBApplicationProcess isRecordingAudio](void)
{
    return self->_recordingAudio;
}


void -[FBApplicationProcess setRecordingAudio:](bool a1)
{
    self->_recordingAudio = a1;
}


bool -[FBApplicationProcess isNowPlayingWithAudio](void)
{
    return self->_nowPlayingWithAudio;
}


void -[FBApplicationProcess setNowPlayingWithAudio:](bool a1)
{
    self->_nowPlayingWithAudio = a1;
}


bool -[FBApplicationProcess isConnectedToExternalAccessory](void)
{
    return self->_connectedToExternalAccessory;
}


void -[FBApplicationProcess setConnectedToExternalAccessory:](bool a1)
{
    self->_connectedToExternalAccessory = a1;
}
