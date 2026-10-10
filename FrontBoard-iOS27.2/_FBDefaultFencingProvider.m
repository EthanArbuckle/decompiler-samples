void -[_FBDefaultFencingProvider synchronizeDrawingWithFence:](id a1)
{
    if (UIKitLibraryCore(0) != 0) {
        long v1 = getUIWindowClass();
        if (v1 != 0) {
            [v1 _synchronizeDrawingWithFence:a1];
        }
    }
}


id +[_FBDefaultFencingProvider sharedInstance](void)
{
    dispatch_once(&sharedInstance.__once, ^void(void) {
        sharedInstance.__instance = [[_FBDefaultFencingProvider alloc] init];
    });
    return sharedInstance.__instance;
}
