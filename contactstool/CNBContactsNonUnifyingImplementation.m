struct CNBContactsNonUnifyingImplementation {
    CNContactStore *_contactStore; // +0x8
};

CNBContactsNonUnifyingImplementation *-[CNBContactsNonUnifyingImplementation init](void)
{
    return [self initWithContactStore:[[CNContactStore alloc] init]];
}


CNBContactsNonUnifyingImplementation *-[CNBContactsNonUnifyingImplementation initWithContactStore:](CNContactStore *a1)
{
    CNBContactsNonUnifyingImplementation *v1 = [super init];
    if (v1 != nil) {
        v1->_contactStore = a1;
    }
    return v1;
}


NSString *+[CNBContactsNonUnifyingImplementation name](void)
{
    return @"ContactsNonUnifying";
}


NSMutableArray *-[CNBContactsNonUnifyingImplementation fetchEverybodyConsideringProperties:](unsigned long a1)
{
    NSMutableArray *v0 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a1];
    CNContactFetchRequest *v2 = [[CNContactFetchRequest alloc] initWithKeysToFetch:v0];
    [v2 setUnifyResults:NO];
    [v2 setSortOrder:CNContactSortOrderFamilyName];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v2 inStore:contactStore];
}


NSMutableArray *-[CNBContactsNonUnifyingImplementation fetchPeopleMatchingName:consideringProperties:](NSString *a1, unsigned long a2)
{
    NSMutableArray *v1 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a2];
    CNContactFetchRequest *v3 = [[CNContactFetchRequest alloc] initWithKeysToFetch:v1];
    [v3 setUnifyResults:NO];
    [v3 setSortOrder:CNContactSortOrderNone];
    NSPredicate *v4 = [CNContact predicateForContactsMatchingName:a1];
    [v3 setPredicate:v4];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v3 inStore:contactStore];
}


id -[CNBContactsNonUnifyingImplementation properties:forContact:](unsigned long a1, id a2)
{
    if (![a2 isKindOfClass:[CNContact class]]) {
        sub_10000c3bc();
    }
    return [CNBContactsImplementationSupport stringValuesForProperties:a1 inContact:a2];
}


NSString *-[CNBContactsNonUnifyingImplementation identifierForContact:](id a1)
{
    if (![a1 isKindOfClass:[CNContact class]]) {
        sub_10000c3e4();
    }
    return [a1 identifier];
}


id -[CNBContactsNonUnifyingImplementation contactForIdentifier:consideringProperties:](id a1, unsigned long a2)
{
    NSMutableArray *v1 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a2];
    CNContactFetchRequest *v3 = [[CNContactFetchRequest alloc] initWithKeysToFetch:v1];
    [v3 setUnifyResults:NO];
    if (![a1 isKindOfClass:[NSString class]]) {
        long v4 = sub_10000c40c();
        _Unwind_Resume(v4);
        __builtin_trap();
    }
    NSArray<NSString *> *v7 = @[a1];
    NSPredicate *v8 = [CNContact predicateForContactsWithIdentifiers:v7];
    [v3 setPredicate:v8];
    __block id v9 = nil;
    CNContactStore *contactStore = [self contactStore];
    NSError *v11 = nil;
    if ([contactStore enumerateContactsWithFetchRequest:v3 error:&v11 usingBlock:^void(CNContact *arg1, bool *arg2) {
        v9 = arg1;
    }]) {
        return v9;
    }
    NSLog(@"Error fetching contact: %@", v11);
    return nil;
}


CNContactStore *-[CNBContactsNonUnifyingImplementation contactStore](void)
{
    return self->_contactStore;
}


void -[CNBContactsNonUnifyingImplementation .cxx_destruct](void)
{
    self->_contactStore = nil;
}
