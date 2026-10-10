id -[RBSProcessIdentity(FBProcess) fb_processClass](void)
{
    id v0 = nil;
    long v1 = [self treatedAsAnAppByFrontBoard:&v0];
    if (v0 != nil) {
        os_log_t oslog = FBLogProcess();
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "treatedAsAnAppByFrontBoard for %@ returned error %@", self, v0);
        }
    }
    if ((v1 & 1) != 0) {
        return [FBApplicationProcess class];
    }
    id v4 = ([self isXPCService] != 0) ? FBExtensionProcess : FBProcess;
    return [v4 class];
}
