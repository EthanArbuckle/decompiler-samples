id -[FBSSceneSettings(UIKitShimming) _uiApplicationSceneSettingsShim](void)
{
    return (![self _uikitShimming_isUISubclass]) ? nil : self;
}


long -[FBSSceneSettings(UIKitShimming) _uikitShimming_isUISubclass](void)
{
    if (![self respondsToSelector:@selector(isUISubclass)]) {
        return 0;
    }
    return [self isUISubclass];
}


FBSSceneSpecification *-[FBSSceneSettings(FBUIApplicationSceneSettings) fb_fallbackSpecification](void)
{
    if (![self _uikitShimming_isUISubclass] || !UIKitLibraryCore(0) || !getUIApplicationSceneSpecificationClass()) {
        return [FBSSceneSpecification specification];
    }
    long v1 = UIKitLibraryCore(0);
    if (v1 != 0) {
        v1 = getUIApplicationSceneSpecificationClass();
    }
    id v0 = v1;
    return [v0 specification];
}
