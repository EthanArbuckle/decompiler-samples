struct CNBContactsFaultingImplementation {
    CNContactStore *_contactStore; // +0x8
};

CNBContactsFaultingImplementation *-[CNBContactsFaultingImplementation init](void)
{
    return [self initWithContactStore:[[CNContactStore alloc] init]];
}


CNBContactsFaultingImplementation *-[CNBContactsFaultingImplementation initWithContactStore:](CNContactStore *a1)
{
    CNBContactsFaultingImplementation *v1 = [super init];
    if (v1 != nil) {
        v1->_contactStore = a1;
    }
    return v1;
}


NSString *+[CNBContactsFaultingImplementation name](void)
{
    return @"ContactsFaulting";
}


NSMutableArray *-[CNBContactsFaultingImplementation fetchEverybodyConsideringProperties:](unsigned long a1)
{
    CNContactFetchRequest *v0 = [CNContactFetchRequest alloc];
    NSArray *v2 = @[CNContactIdentifierKey];
    CNContactFetchRequest *v3 = [v0 initWithKeysToFetch:v2];
    [v3 setSortOrder:CNContactSortOrderFamilyName];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v3 inStore:contactStore];
}


NSMutableArray *-[CNBContactsFaultingImplementation fetchPeopleMatchingName:consideringProperties:](NSString *a1, unsigned long a2)
{
    CNContactFetchRequest *v1 = [CNContactFetchRequest alloc];
    NSArray *v3 = @[CNContactIdentifierKey];
    CNContactFetchRequest *v4 = [v1 initWithKeysToFetch:v3];
    [v4 setUnifyResults:NO];
    [v4 setSortOrder:CNContactSortOrderNone];
    NSPredicate *v5 = [CNContact predicateForContactsMatchingName:a1];
    [v4 setPredicate:v5];
    CNContactStore *contactStore = [self contactStore];
    return [CNBContactsImplementationSupport contactsForFetchRequest:v4 inStore:contactStore];
}


id -[CNBContactsFaultingImplementation properties:forContact:](unsigned long a1, id a2)
{
    id v7;
    if (![a2 isKindOfClass:[CNContact class]]) {
        sub_10000c274();
    }
    NSMutableArray *v1 = [CNBContactsImplementationSupport CNPropertiesForCNBProperties:a1];
    CNContactStore *contactStore = [self contactStore];
    NSString *identifier = [a2 identifier];
    NSError *v4 = nil;
    CNContact *v5 = [contactStore unifiedContactWithIdentifier:identifier keysToFetch:v1 error:&v4];
    if (!v5) {
        NSLog(@"Error fetching contact: %@", v4);
        v7 = nil;
    } else {
        v7 = [CNBContactsImplementationSupport stringValuesForProperties:a1 inContact:v5];
    }
    return v7;
}


NSString *-[CNBContactsFaultingImplementation identifierForContact:](id a1)
{
    if (![a1 isKindOfClass:[CNContact class]]) {
        sub_10000c29c();
    }
    return [a1 identifier];
}


CNContact *-[CNBContactsFaultingImplementation contactForIdentifier:consideringProperties:](NSString *a1, unsigned long a2)
{
    CNContactStore *contactStore = [self contactStore];
    if (![a1 isKindOfClass:[NSString class]]) {
        sub_10000c2c4();
    }
    NSError *v3 = nil;
    CNContact *v4 = [contactStore unifiedContactWithIdentifier:a1 keysToFetch:@[] error:&v3];
    if (v4) {
        return v4;
    }
    NSLog(@"Error fetching contact: %@", v3);
    return nil;
}


CNContactStore *-[CNBContactsFaultingImplementation contactStore](void)
{
    return self->_contactStore;
}


void -[CNBContactsFaultingImplementation .cxx_destruct](void)
{
    self->_contactStore = nil;
}
