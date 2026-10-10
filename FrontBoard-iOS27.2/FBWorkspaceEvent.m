long -[FBWorkspaceEvent execute](void)
{
    os_log_t oslog = FBLogCommon();
    if (os_log_type_enabled(oslog, OS_LOG_TYPE_DEFAULT)) {
        os_log_with_type(oslog, OS_LOG_TYPE_DEFAULT, "[FBWorkspaceEvent] Executing: %{public}@", self);
    }
    return [super execute];
}
