struct CNBContactsNativeImplementation {
    CNContactStore *_contactStore; // +0x8
};

CNBContactsNativeImplementation *-[CNBContactsNativeImplementation init](void)
{
    return [self initWithContactStore:[[CNContactStore alloc] init]];
}


CNBContactsNativeImplementation *-[CNBContactsNativeImplementation initWithContactStore:](CNContactStore *a1)
{
    CNBContactsNativeImplementation *v1 = [super init];
    if (v1 != nil) {
        v1->_contactStore = a1;
    }
    return v1;
}


NSString *+[CNBContactsNativeImplementation name](void)
{
    return @"ContactsNative";
}


NSMutableArray *-[CNBContactsNativeImplementation fetchEverybodyConsideringProperties:](unsigned long a1)
{
    NSMutableArray *v0 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a1];
    CNContactFetchRequest *v2 = [[CNContactFetchRequest alloc] initWithKeysToFetch:v0];
    [v2 setUnifyResults:YES];
    [v2 setSortOrder:CNContactSortOrderFamilyName];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v2 inStore:contactStore];
}


NSMutableArray *-[CNBContactsNativeImplementation fetchPeopleMatchingName:consideringProperties:](NSString *a1, unsigned long a2)
{
    NSMutableArray *v1 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a2];
    CNContactFetchRequest *v3 = [[CNContactFetchRequest alloc] initWithKeysToFetch:v1];
    [v3 setUnifyResults:YES];
    [v3 setSortOrder:CNContactSortOrderNone];
    NSPredicate *v4 = [CNContact predicateForContactsMatchingName:a1];
    [v3 setPredicate:v4];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v3 inStore:contactStore];
}


id -[CNBContactsNativeImplementation properties:forContact:](unsigned long a1, id a2)
{
    if (![a2 isKindOfClass:[CNContact class]]) {
        sub_10000c1fc();
    }
    return [CNBContactsImplementationSupport stringValuesForProperties:a1 inContact:a2];
}


NSString *-[CNBContactsNativeImplementation identifierForContact:](id a1)
{
    if (![a1 isKindOfClass:[CNContact class]]) {
        sub_10000c224();
    }
    return [a1 identifier];
}


CNContact *-[CNBContactsNativeImplementation contactForIdentifier:consideringProperties:](NSString *a1, unsigned long a2)
{
    NSMutableArray *v1 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a2];
    CNContactStore *contactStore = [self contactStore];
    if (![a1 isKindOfClass:[NSString class]]) {
        sub_10000c24c();
    }
    NSError *v3 = nil;
    CNContact *v4 = [contactStore unifiedContactWithIdentifier:a1 keysToFetch:v1 error:&v3];
    if (v4) {
        return v4;
    }
    NSLog(@"Error fetching contact: %@", v3);
    CNContact *v6 = nil;
    return v6;
}


CNContactStore *-[CNBContactsNativeImplementation contactStore](void)
{
    return self->_contactStore;
}


void -[CNBContactsNativeImplementation .cxx_destruct](void)
{
    self->_contactStore = nil;
}
