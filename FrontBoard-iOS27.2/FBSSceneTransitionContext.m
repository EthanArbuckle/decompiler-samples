id -[FBSSceneTransitionContext(UIKitShimming) _uiApplicationSceneTransitionContextShim](void)
{
    return (![self _uikitShimming_isUISubclass]) ? nil : self;
}


long -[FBSSceneTransitionContext(UIKitShimming) _uikitShimming_isUISubclass](void)
{
    if (![self respondsToSelector:@selector(isUISubclass)]) {
        return 0;
    }
    return [self isUISubclass];
}
