FBTransaction *-[FBTransaction init](void)
{
    FBTransaction *v1 = [super init];
    if (v1 != nil) {
        os_log_t v2 = FBLogTransaction();
        [v1 _addDebugLogCategory:v2];
    }
    return v1;
}
