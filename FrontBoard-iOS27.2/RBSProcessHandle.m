long -[RBSProcessHandle(FBProcess) fb_canTaskSuspend](void)
{
    long isManaged = [self isManaged];
    if (isManaged != 0) {
        return [self isDaemon] ^ 1;
    }
    return isManaged;
}
