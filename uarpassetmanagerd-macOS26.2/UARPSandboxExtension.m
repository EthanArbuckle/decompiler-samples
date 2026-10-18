struct UARPSandboxExtension {
    long _sandboxExtensionHandle; // +0x8
};

NSString *+[UARPSandboxExtension readTokenStringWithURL:](id a1)
{
    NSString *v15;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *path = [a1 path];
    if ([defaultManager fileExistsAtPath:path]) {
        id path2 = [a1 path];
        const char *UTF8String = [path2 UTF8String];
        void *v8 = sandbox_extension_issue_file("com.apple.app-sandbox.read", UTF8String, 0);
        os_log_t oslog2 = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Generating Read Sandbox Extension Token for %@ ", "+[UARPSandboxExtension readTokenStringWithURL:]", a1);
        }
        if (v8 != 0) {
            NSString *v12 = [NSString stringWithUTF8String:v8];
            free(v8);
            v15 = v12;
        } else {
            v15 = nil;
        }
    } else {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: Cannot Generate Sandbox Extension Token for %@ ", "+[UARPSandboxExtension readTokenStringWithURL:]", a1);
        }
        v15 = nil;
    }
    return v15;
}


NSString *+[UARPSandboxExtension readWriteTokenStringWithURL:](id a1)
{
    NSString *v15;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *path = [a1 path];
    if ([defaultManager fileExistsAtPath:path]) {
        id path2 = [a1 path];
        const char *UTF8String = [path2 UTF8String];
        void *v8 = sandbox_extension_issue_file("com.apple.app-sandbox.read-write", UTF8String, 0);
        os_log_t oslog2 = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog2, OS_LOG_TYPE_INFO)) {
            os_log_with_type(oslog2, OS_LOG_TYPE_INFO, "%s: Generating Read-Write Sandbox Extension Token for %@ ", "+[UARPSandboxExtension readWriteTokenStringWithURL:]", a1);
        }
        if (v8 != 0) {
            NSString *v12 = [NSString stringWithUTF8String:v8];
            free(v8);
            v15 = v12;
        } else {
            v15 = nil;
        }
    } else {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: Cannot Generate Sandbox Extension Token for %@ ", "+[UARPSandboxExtension readWriteTokenStringWithURL:]", a1);
        }
        v15 = nil;
    }
    return v15;
}


UARPSandboxExtension *-[UARPSandboxExtension initWithTokenString:](id a1)
{
    UARPSandboxExtension *v7;
    UARPSandboxExtension *v0 = [super init];
    if (!v0) {
        return v0;
    }
    v0->_sandboxExtensionHandle = sandbox_extension_consume([a1 UTF8String]);
    if (v0->_sandboxExtensionHandle == -1) {
        os_log_t oslog = OS_LOG_DEFAULT;
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "%s: failed to consume sandbox token", "-[UARPSandboxExtension initWithTokenString:]");
        }
        v7 = nil;
    } else {
        v7 = v0;
    }
    return v7;
}


void -[UARPSandboxExtension dealloc](void)
{
    if (self->_sandboxExtensionHandle != -1) {
        sandbox_extension_release(self->_sandboxExtensionHandle);
        self->_sandboxExtensionHandle = -1;
    }
    [super dealloc];
}
