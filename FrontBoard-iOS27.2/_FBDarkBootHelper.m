int -[_FBDarkBootHelper isBootingDark](void)
{
    os_log_t v3;
    int v6;
    int v0 = 0;
    size_t oldlenp = 4;
    int v2 = sysctlbyname("kern.darkboot", &v0, &oldlenp, NULL, 0);
    if (v2 != 0) {
        v3 = FBLogCommon();
        if (os_log_type_enabled(v3, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(v3, OS_LOG_TYPE_ERROR, "failed to read darkboot state ->  %{darwin.errno}i", v2);
            return 0;
        }
        return 0;
    }
    v3 = FBLogCommon();
    if (!v0) {
        if (os_log_type_enabled(v3, OS_LOG_TYPE_INFO)) {
            NSNumber *v4 = [NSNumber numberWithBool:NO];
            os_log_with_type(v3, OS_LOG_TYPE_INFO, "read darkboot flag = %{public}@ (%i)", v4, v0);
        }
        v6 = 0;
    } else {
        v6 = 1;
        if (os_log_type_enabled(v3, OS_LOG_TYPE_DEFAULT)) {
            NSNumber *v7 = [NSNumber numberWithBool:YES];
            os_log_with_type(v3, OS_LOG_TYPE_DEFAULT, "read darkboot flag = %{public}@ (%i)", v7, v0);
        }
    }
    return v6;
}


long -[_FBDarkBootHelper setNextBootDark](void)
{
    return [self _setDarkBootEnabled:1];
}


long -[_FBDarkBootHelper clearBootedDark](void)
{
    return [self _setDarkBootEnabled:0];
}


void -[_FBDarkBootHelper _setDarkBootEnabled:](int a1)
{
    int v1 = (a1 != 0) ? 2 : 0;
    int v2 = sysctlbyname("kern.darkboot", NULL, NULL, &v1, 4);
    os_log_t oslog = FBLogCommon();
    if (v2) {
        if (os_log_type_enabled(oslog, OS_LOG_TYPE_ERROR)) {
            os_log_with_type(oslog, OS_LOG_TYPE_ERROR, "Failed to set darkboot state ->  %{darwin.errno}i : do you have the entitlement (com.apple.private.kernel.darkboot)?", v2);
        }
    } else if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "Set darkBoot = %{public}s", (a1 != 0) ? "YES" : "NO");
    }
}
