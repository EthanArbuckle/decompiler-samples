struct CNBAddressBookLegacyImplementation {
    void *_addressBook; // +0x8
};

NSString *+[CNBAddressBookLegacyImplementation name](void)
{
    return @"AddressBookLegacy";
}


NSMutableArray *+[CNBAddressBookLegacyImplementation ABPropertiesForCNBProperties:](unsigned long a1)
{
    NSMutableArray *array = [NSMutableArray array];
    if ((a1 & 4) != 0) {
        NSNumber *v2 = [NSNumber numberWithInt:kABPersonFirstNameProperty];
        [array addObject:v2];
        NSNumber *v3 = [NSNumber numberWithInt:kABPersonMiddleNameProperty];
        [array addObject:v3];
        NSNumber *v4 = [NSNumber numberWithInt:kABPersonLastNameProperty];
        [array addObject:v4];
    }
    if ((a1 & 1) != 0) {
        NSNumber *v8 = [NSNumber numberWithInt:kABPersonEmailProperty];
        [array addObject:v8];
        if ((a1 & 2) == 0) {
            goto blk_100005300;
        } else {
            goto blk_100005484;
        }
    }
    if ((a1 & 2) == 0) {
blk_100005300:
        if ((a1 & 8) != 0) {
            goto blk_1000054d0;
        } else {
            goto blk_100005304;
        }
    }
blk_100005484:
    NSNumber *v5 = [NSNumber numberWithInt:kABPersonPhoneProperty];
    [array addObject:v5];
    if ((a1 & 8) != 0) {
blk_1000054d0:
        NSNumber *v7 = [NSNumber numberWithInt:kABPersonAddressProperty];
        [array addObject:v7];
    }
blk_100005304:
    if ((a1 & 16) != 0) {
        NSNumber *v6 = [NSNumber numberWithInt:kABPersonInstantMessageProperty];
        [array addObject:v6];
    }
    return array;
}


instancetype -[CNBAddressBookLegacyImplementation init](void)
{
    CFErrorRef v1 = 0;
    CFTypeRef v2 = ABAddressBookCreateWithOptions(NULL, &v1);
    if (!v2) {
        NSLog(@"Can't create address book %@", v1);
    } else {
        CNBAddressBookLegacyImplementation *v3 = [self initWithAddressBook:v2];
        CFRelease(v2);
        self = v3;
        v2 = self;
    }
    return v2;
}


CNBAddressBookLegacyImplementation *-[CNBAddressBookLegacyImplementation initWithAddressBook:](void *a1)
{
    CNBAddressBookLegacyImplementation *v1 = [super init];
    if (v1 != nil) {
        v1->_addressBook = (!a1) ? 0 : CFRetain(a1);
    }
    return v1;
}


void -[CNBAddressBookLegacyImplementation dealloc](void)
{
    if (self->_addressBook != 0) {
        CFRelease(self->_addressBook);
    }
    [super dealloc];
}


id -[CNBAddressBookLegacyImplementation fetchEverybodyConsideringProperties:](unsigned long a1)
{
    void *addressBook = [self addressBook];
    CFTypeRef v1 = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, NULL, 1);
    if (v1 != 0) {
        v1 = CFAutorelease(v1);
    }
    return v1;
}


id -[CNBAddressBookLegacyImplementation fetchPeopleMatchingName:consideringProperties:](id a1, unsigned long a2)
{
    CFArrayRef arg = ABAddressBookCopyPeopleWithName([self addressBook], a1);
    if (!arg) {
        return nil;
    } else {
        return CFAutorelease(arg);
    }
}


NSMutableArray *-[CNBAddressBookLegacyImplementation properties:forContact:](unsigned long a1, id a2)
{
    CFTypeRef v15;
    CFIndex v18;
    NSMutableArray *array = [NSMutableArray array];
    Class v3 = [self class];
    id v4 = [v3 ABPropertiesForCNBProperties:a1];
    for (id v8 in v4) {
        ABPropertyID intValue = [v8 intValue];
        ABPropertyType v11 = ABPersonGetTypeOfProperty(intValue);
        CFTypeRef arg = ABRecordCopyValue(a2, intValue);
        if ((v11 & 0x100) == 0) {
            id v14 = (!arg) ? @"" : arg;
            [array addObject:v14];
        } else {
            if (arg != 0) {
                v15 = CFAutorelease(arg);
            } else {
                v15 = 0;
            }
            if (ABMultiValueGetCount(v15) >= 1) {
                CFIndex v17 = 0;
                do {
                    CFTypeRef v19 = ABMultiValueCopyValueAtIndex(v15, v17);
                    CFStringRef cf = ABMultiValueCopyLabelAtIndex(v15, v17);
                    if (cf != 0) {
                        CFRelease(cf);
                    }
                    CFTypeRef cf2 = ABMultiValueCopyUUIDAtIndex(v15, v17);
                    if (cf2 != 0) {
                        CFRelease(cf2);
                    }
                    ABMultiValueGetIdentifierAtIndex(v15, v17);
                    if ((ABMultiValueGetPropertyType(v15) & 0xfffffeff) == 5) {
                        NSMutableString *v22 = [CNBUtilities stringForDictionary:v19];
                        v19 = v22;
                    }
                    id v24 = (!v19) ? @"" : v19;
                    [array addObject:v24];
                    v17++;
                    v18 = ABMultiValueGetCount(v15);
                } while (v17 < v18);
            }
        }
    }
    return array;
}


NSNumber *-[CNBAddressBookLegacyImplementation identifierForContact:](id a1)
{
    ABRecordID v0 = ABRecordGetRecordID(a1);
    return [NSNumber numberWithInt:v0];
}


id -[CNBAddressBookLegacyImplementation contactForIdentifier:consideringProperties:](id a1, unsigned long a2)
{
    if (![a1 isKindOfClass:[NSNumber class]]) {
        sub_10000c2ec();
    }
    NSInteger integerValue = [a1 integerValue];
    return ABAddressBookGetPersonWithRecordID([self addressBook], integerValue);
}


void *-[CNBAddressBookLegacyImplementation addressBook](void)
{
    return self->_addressBook;
}
