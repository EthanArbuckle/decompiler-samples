struct CNBAddressBookShimImplementation {
    void *_addressBook; // +0x8
};

NSString *+[CNBAddressBookShimImplementation name](void)
{
    return @"AddressBookShim";
}


NSMutableArray *+[CNBAddressBookShimImplementation ABPropertiesForCNBProperties:](unsigned long a1)
{
    id v6;
    NSMutableArray *array = [NSMutableArray array];
    if ((a1 & 4) == 0) {
        v6 = array;
    } else {
        int v2 = qword_10001a5d0(array);
        NSNumber *v3 = [NSNumber numberWithInt:v2];
        [array addObject:v3];
        NSNumber *v4 = [NSNumber numberWithInt:qword_10001a5d8(v3)];
        [array addObject:v4];
        NSNumber *v5 = [NSNumber numberWithInt:qword_10001a5e0(v4)];
        [array addObject:v5];
        v6 = v5;
    }
    if ((a1 & 1) != 0) {
        int v13 = qword_10001a5e8(v6);
        NSNumber *v14 = [NSNumber numberWithInt:v13];
        [array addObject:v14];
        v6 = v14;
        if ((a1 & 2) == 0) {
            goto blk_100005bd8;
        } else {
            goto blk_100005d84;
        }
    }
    if ((a1 & 2) == 0) {
blk_100005bd8:
        if ((a1 & 8) != 0) {
            goto blk_100005dd8;
        } else {
            goto blk_100005bdc;
        }
    }
blk_100005d84:
    int v7 = qword_10001a5f0(v6);
    NSNumber *v8 = [NSNumber numberWithInt:v7];
    [array addObject:v8];
    v6 = v8;
    if ((a1 & 8) != 0) {
blk_100005dd8:
        int v11 = qword_10001a5f8(v6);
        NSNumber *v12 = [NSNumber numberWithInt:v11];
        [array addObject:v12];
        v6 = v12;
    }
blk_100005bdc:
    if ((a1 & 16) != 0) {
        int v9 = qword_10001a600(v6);
        NSNumber *v10 = [NSNumber numberWithInt:v9];
        [array addObject:v10];
    }
    return array;
}


instancetype -[CNBAddressBookShimImplementation init](void)
{
    id v1 = nil;
    id v2 = qword_10001a608(0, &v1);
    if (!v2) {
        NSLog(@"Can't create address book %@", v1);
    } else {
        CNBAddressBookShimImplementation *v3 = [self initWithAddressBook:v2];
        CFRelease(v2);
        v2 = v3;
    }
    return v2;
}


CNBAddressBookShimImplementation *-[CNBAddressBookShimImplementation initWithAddressBook:](void *a1)
{
    CNBAddressBookShimImplementation *v1 = [super init];
    if (v1 != nil) {
        v1->_addressBook = (!a1) ? 0 : CFRetain(a1);
    }
    return v1;
}


void -[CNBAddressBookShimImplementation dealloc](void)
{
    if (self->_addressBook != 0) {
        CFRelease(self->_addressBook);
    }
    [super dealloc];
}


id -[CNBAddressBookShimImplementation fetchEverybodyConsideringProperties:](unsigned long a1)
{
    void *addressBook = [self addressBook];
    CFTypeRef v1 = qword_10001a610(addressBook, 0, 1);
    if (v1 != 0) {
        v1 = CFAutorelease(v1);
    }
    return v1;
}


id -[CNBAddressBookShimImplementation fetchPeopleMatchingName:consideringProperties:](id a1, unsigned long a2)
{
    CFTypeRef arg = qword_10001a618([self addressBook], a1);
    if (!arg) {
        return nil;
    } else {
        return CFAutorelease(arg);
    }
}


NSMutableArray *-[CNBAddressBookShimImplementation properties:forContact:](unsigned long a1, id a2)
{
    CFTypeRef v16;
    long v18;
    NSMutableArray *array = [NSMutableArray array];
    Class v4 = [self class];
    id v5 = [v4 ABPropertiesForCNBProperties:a1];
    for (id v9 in v5) {
        int intValue = [v9 intValue];
        int v12 = qword_10001a620(intValue);
        CFTypeRef arg = qword_10001a628(a2, intValue);
        if ((v12 & 0x100) == 0) {
            id v15 = (!arg) ? @"" : arg;
            [array addObject:v15];
        } else {
            if (arg != 0) {
                v16 = CFAutorelease(arg);
            } else {
                v16 = 0;
            }
            if (qword_10001a630(v16) >= 1) {
                long v17 = 0;
                do {
                    id v19 = qword_10001a638(v16, v17);
                    if ((qword_10001a640(v16) & 0xfffffeff) == 5) {
                        NSMutableString *v20 = [CNBUtilities stringForDictionary:v19];
                        v19 = v20;
                    }
                    id v22 = (!v19) ? @"" : v19;
                    [array addObject:v22];
                    v17++;
                    v18 = qword_10001a630(v16);
                } while (v17 < v18);
            }
        }
    }
    return array;
}


NSNumber *-[CNBAddressBookShimImplementation identifierForContact:](id a1)
{
    long v0 = qword_10001a648(a1);
    return [NSNumber numberWithInt:v0];
}


id -[CNBAddressBookShimImplementation contactForIdentifier:consideringProperties:](id a1, unsigned long a2)
{
    if (![a1 isKindOfClass:[NSNumber class]]) {
        sub_10000c314();
    }
    NSInteger integerValue = [a1 integerValue];
    return qword_10001a650([self addressBook], integerValue);
}


void *-[CNBAddressBookShimImplementation addressBook](void)
{
    return self->_addressBook;
}
