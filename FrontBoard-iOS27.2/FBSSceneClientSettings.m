id -[FBSSceneClientSettings(UIKitShimming) _uiApplicationSceneClientSettingsShim](void)
{
    return (![self _uikitShimming_isUISubclass]) ? nil : self;
}


long -[FBSSceneClientSettings(UIKitShimming) _uikitShimming_isUISubclass](void)
{
    if (![self respondsToSelector:@selector(isUISubclass)]) {
        return 0;
    }
    return [self isUISubclass];
}
