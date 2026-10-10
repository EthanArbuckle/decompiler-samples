NSString *(^+[CNBContactsImplementationSupport stringValueTransformForProperty:](NSString *a1))(id)
{
    NSString *(^v2)(NSString *) = [^NSString *(NSString *arg1) {
        return arg1;
    } copy];
    NSString *(^v4)(CNPhoneNumber *) = [^NSString *(CNPhoneNumber *arg1) {
        return [arg1 stringValue];
    } copy];
    NSString *(^v5)(CNPostalAddress *) = [^NSString *(CNPostalAddress *arg1) {
        NSDictionary *dictionaryRepresentation = [arg1 dictionaryRepresentation];
        NSMutableString *v1 = [CNBUtilities stringForDictionary:dictionaryRepresentation];
        return v1;
    } copy];
    NSString *(^v6)(CNInstantMessageAddress *) = [^NSString *(CNInstantMessageAddress *arg1) {
        NSDictionary *dictionaryRepresentation = [arg1 dictionaryRepresentation];
        NSMutableString *v1 = [CNBUtilities stringForDictionary:dictionaryRepresentation];
        return v1;
    } copy];
    NSDictionary<id, NSString *(^)(id)> *v7 = @{CNContactEmailAddressesKey: v2, CNContactPhoneNumbersKey: v4, CNContactPostalAddressesKey: v5, CNContactInstantMessageAddressesKey: v6};
    NSString *(^v8)(id) = [v7 objectForKeyedSubscript:a1];
    if (!v8) {
        v8 = ^NSString *(NSString *arg1) {
            return arg1;
        };
    }
    return v8;
}


id +[CNBContactsImplementationSupport stringValuesForProperties:inContact:](unsigned long a1, id a2)
{
    NSMutableArray *v1 = [self CNPropertiesForCNBProperties:a1];
    id v3 = [v1 _cn_map:^NSArray *(NSString *arg1) {
        NSArray *(^v7)(id);
        id v10 = [a2 valueForKey:arg1];
        NSString *(^v11)(id) = [self stringValueTransformForProperty:arg1];
        if (![v10 isKindOfClass:[NSArray class]]) {
            v7 = ^NSArray *(id arg1) {
                NSString *v12 = v11();
                return @[v12];
            };
        } else {
            v7 = ^NSArray *(NSArray *arg1) {
                NSArray *v13 = [arg1 _cn_map:^NSString *(CNLabeledValue *arg1) {
                    id<NSCopying, NSSecureCoding> value = [arg1 value];
                    NSString *v14 = v11(value);
                    return v14;
                }];
                return v13;
            };
        }
        NSArray *v9 = v7(v10);
        return v9;
    }];
    return [v3 _cn_flatten];
}


NSMutableArray *+[CNBContactsImplementationSupport CNPropertiesForCNBProperties:](unsigned long a1)
{
    NSMutableArray *array = [NSMutableArray array];
    if ((a1 & 4) != 0) {
        [array addObject:CNContactGivenNameKey];
        [array addObject:CNContactMiddleNameKey];
        [array addObject:CNContactFamilyNameKey];
    }
    if ((a1 & 1) != 0) {
        [array addObject:CNContactEmailAddressesKey];
        if ((a1 & 2) == 0) {
            if ((a1 & 8) != 0) {
                goto blk_100003734;
            }
            if ((a1 & 16) != 0) {
                [array addObject:CNContactInstantMessageAddressesKey];
            }
            return array;
        } else {
            goto blk_100003714;
        }
    }
    if ((a1 & 2) == 0) {
        if ((a1 & 8) != 0) {
            goto blk_100003734;
        }
        if ((a1 & 16) != 0) {
            [array addObject:CNContactInstantMessageAddressesKey];
        }
        return array;
    }
blk_100003714:
    [array addObject:CNContactPhoneNumbersKey];
    if ((a1 & 8) != 0) {
blk_100003734:
        [array addObject:CNContactPostalAddressesKey];
    }
    if ((a1 & 16) != 0) {
        [array addObject:CNContactInstantMessageAddressesKey];
    }
    return array;
}


NSMutableArray *+[CNBContactsImplementationSupport contactsForFetchRequest:inStore:](CNContactFetchRequest *a1, id a2)
{
    NSMutableArray *array = [NSMutableArray array];
    NSError *v2 = nil;
    if ([a2 enumerateContactsWithFetchRequest:a1 error:&v2 usingBlock:^void(CNContact *arg1, bool *arg2) {
        [array addObject:arg1];
    }]) {
        return array;
    }
    NSLog(@"Error fetching contacts: %@", v2);
    NSMutableArray *v6 = nil;
    return v6;
}
