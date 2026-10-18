static Class _logos_superclass$_ungrouped$CCSModuleRepository;
static long _logos_orig$_ungrouped$CCSModuleRepository$_queue_loadAllModuleMetadata;

__attribute__((constructor))
void _logosLocalCtor_aa7b085b(void)
{
    NSLog(@"[CCUnlock] Loaded!");
}


__attribute__((constructor))
void _logosLocalInit(void)
{
    Class cls = objc_getClass("CCSModuleRepository");
    _logos_superclass$_ungrouped$CCSModuleRepository = class_getSuperclass(cls);
    _logos_register_hook(cls, @selector(_queue_loadAllModuleMetadata), &_logos_method$_ungrouped$CCSModuleRepository$_queue_loadAllModuleMetadata, &_logos_orig$_ungrouped$CCSModuleRepository$_queue_loadAllModuleMetadata);
}


void _logos_register_hook(Class a1, SEL a2, IMP a3, IMP *a4)
{
    unsigned int v2;
    Class v0 = a1;
    while (1) {
        if (!v0) {
            return;
        }
        Method *v5 = class_copyMethodList(v0, &v2);
        for (int v3 = 0; (unsigned int)v3 < v2; v3++) {
            SEL v4 = method_getName(v5[v3]);
            if (v4 == a2) {
                if (a1 != v0) {
                    *(a4) = method_getImplementation(v5[v3]);
                    class_addMethod(a1, a2, a3, method_getTypeEncoding(v5[v3]));
                } else {
                    *(a4) = method_setImplementation(v5[v3], a3);
                }
                free(v5);
                return;
            }
        }
        free(v5);
        v0 = class_getSuperclass(v0);
    }
}


id _logos_method$_ungrouped$CCSModuleRepository$_queue_loadAllModuleMetadata(id a1, SEL a2)
{
    dispatch_queue_t queue = [a1 safeValueForKey:@"_queue"];
    dispatch_assert_queue(queue);
    id v1 = [a1 safeValueForKey:@"_directoryURLs"];
    id v4 = [v1 bs_mapNoNulls:^id(NSURL *arg1) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        return [defaultManager contentsOfDirectoryAtURL:arg1 includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    }];
    id bs_flatten = [v4 bs_flatten];
    id v10 = [bs_flatten bs_filter:^bool(NSURL *arg1) {
        NSString *pathExtension = [arg1 pathExtension];
        NSComparisonResult v21 = [pathExtension caseInsensitiveCompare:@"bundle"];
        if (v21 == NSOrderedSame) {
            return true;
        }
        return false;
    }];
    return [v10 bs_mapNoNulls:^id(NSURL *arg1) {
        id v5;
        int v25;
        Class v2 = NSClassFromString(@"CCSModuleMetadata");
        id v26 = [v2 metadataForBundleAtURL:arg1];
        NSString *path = [arg1 path];
        if ([path containsString:@"Focus"] || [path containsString:@"Mirror"] || [path containsString:@"Hearing"]) {
            v5 = nil;
        } else {
            id v28 = [a1 safeValueForKey:@"_allowedModuleIdentifiers"];
            id moduleIdentifier = [v26 moduleIdentifier];
            BOOL v8 = [v28 containsObject:moduleIdentifier];
            if (!v8) {
                v5 = v26;
            } else {
                id supportedDeviceFamilies = [v26 supportedDeviceFamilies];
                id _deviceFamily = [NSClassFromString(@"CCSModuleRepository") _deviceFamily];
                BOOL v24 = [supportedDeviceFamilies containsObject:_deviceFamily];
                if (!v24) {
                    v25 = 0;
                } else {
                    v5 = v26;
                    v25 = 1;
                }
                if (!v25) {
                    v5 = v26;
                }
            }
        }
        return v5;
    }];
}
