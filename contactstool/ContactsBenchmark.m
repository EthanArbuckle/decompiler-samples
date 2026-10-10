id +[ContactsBenchmark testCaseClassesByName](void)
{
    NSArray *testCaseClasses = [self testCaseClasses];
    return [testCaseClasses _cn_indexBy:qword_10001a440];
}


id +[ContactsBenchmark testCaseNames](void)
{
    NSArray *testCaseClasses = [self testCaseClasses];
    return [testCaseClasses _cn_map:qword_10001a440];
}


NSArray *+[ContactsBenchmark testCaseClasses](void)
{
    return @[[CNBFetchEverything class], [CNBSearchByName class]];
}


id +[ContactsBenchmark testCaseWithName:implementation:](id a1, id a2)
{
    id testCaseClassesByName = [self testCaseClassesByName];
    id v3 = [testCaseClassesByName objectForKeyedSubscript:a1];
    if (v3 != nil) {
        id v4 = [v3 alloc];
        v3 = [v4 initWithImplementation:a2];
    }
    return v3;
}


NSArray *+[ContactsBenchmark implementationClasses](void)
{
    return @[[CNBAddressBookLegacyImplementation class], [CNBAddressBookShimImplementation class], [CNBContactsFaultingImplementation class], [CNBContactsNativeImplementation class], [CNBContactsNonUnifyingImplementation class]];
}


id +[ContactsBenchmark implementationClassesByName](void)
{
    NSArray *implementationClasses = [self implementationClasses];
    return [implementationClasses _cn_indexBy:qword_10001a448];
}


id +[ContactsBenchmark implementationNames](void)
{
    NSArray *implementationClasses = [self implementationClasses];
    return [implementationClasses _cn_map:qword_10001a448];
}


id +[ContactsBenchmark implementationWithName:](id a1)
{
    id implementationClassesByName = [self implementationClassesByName];
    id v2 = [implementationClassesByName objectForKeyedSubscript:a1];
    if (!v2) {
        return nil;
    }
    id v3 = [v2 alloc];
    return [v3 init];
}


void +[ContactsBenchmark performBlock:usingContactsOutOfProcess:](void (^a1)(void), bool a2)
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *v3 = [NSNumber numberWithBool:a2];
    NSDictionary<NSString *, NSNumber *> *registrationDictionary = @{@"SUDO_OOP": v3};
    [standardUserDefaults registerDefaults:registrationDictionary];
    a1();
}
