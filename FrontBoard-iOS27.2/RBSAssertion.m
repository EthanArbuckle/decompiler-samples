void -[RBSAssertion(FBWorkspace) fb_setWorkspaceState:](int a1)
{
    NSNumber *value = ((FBWorkspaceStateEqual(a1, &FBWorkspaceStateNone) & 1) == 0) ? [NSNumber numberWithUnsignedInt:a1] : nil;
    objc_setAssociatedObject(self, &__FBWorkspaceState, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


unsigned int -[RBSAssertion(FBWorkspace) fb_workspaceState](void)
{
    id v0 = objc_getAssociatedObject(self, &__FBWorkspaceState);
    return (!v0) ? &FBWorkspaceStateNone : [v0 unsignedIntValue];
}
