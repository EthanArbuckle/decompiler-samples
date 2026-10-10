struct CNTElapsedTimeFormatter {
    NSNumberFormatter *_numberFormatter; // +0x8
};

static CNTElapsedTimeFormatter *qword_10001a6f8;

CNTElapsedTimeFormatter *+[CNTElapsedTimeFormatter sharedFormatter](void)
{
    dispatch_once(&qword_10001a6f0, ^void(void) {
        qword_10001a6f8 = [[CNTElapsedTimeFormatter alloc] init];
    });
    return qword_10001a6f8;
}


CNTElapsedTimeFormatter *-[CNTElapsedTimeFormatter init](void)
{
    CNTElapsedTimeFormatter *v2 = [super init];
    if (v2 != nil) {
        v2->_numberFormatter = [[NSNumberFormatter alloc] init];
        [v2->_numberFormatter setUsesSignificantDigits:YES];
        [v2->_numberFormatter setMaximumSignificantDigits:3];
        [v2->_numberFormatter setMinimumSignificantDigits:3];
    }
    return v2;
}


NSString *-[CNTElapsedTimeFormatter stringForTimeInterval:](double a1)
{
    NSString *v14;
    long v1 = 0;
    if (a1 < 2.0) {
        do {
            a1 *= 1000.0;
            v1--;
        } while (a1 < 2.0);
    }
    if (v1 <= 7 && a1 >= 2000.0) {
        while (1) {
            v1++;
            a1 /= 1000.0;
            if (v1 > 7) {
                break;
            }
            if (a1 >= 2000.0) {
                continue;
            }
            break;
        }
    }
    Class v5 = [self class];
    id v6 = [v5 suffixForOrder:v1];
    NSNumberFormatter *obj = [self numberFormatter];
    @synchronized (obj) {
        NSUInteger v8 = (a1 >= 1000.0) ? 4 : 3;
        NSNumberFormatter *numberFormatter3 = [self numberFormatter];
        [numberFormatter3 setMinimumSignificantDigits:v8];
        NSNumberFormatter *numberFormatter = [self numberFormatter];
        [numberFormatter setMaximumSignificantDigits:v8];
        NSNumberFormatter *numberFormatter2 = [self numberFormatter];
        NSNumber *number = [NSNumber numberWithDouble:a1];
        NSString *v13 = [numberFormatter2 stringFromNumber:number];
        v14 = [v13 stringByAppendingFormat:@" %@s", v6];
    }
    return v14;
}


NSString *+[CNTElapsedTimeFormatter suffixForOrder:](long a1)
{
    NSString *v1;
    if (a1 >= 9) {
        return @"Y";
    }
    if (a1 <= -9) {
        return @"y";
    }
    if ((unsigned long)(a1 + 8) > 16) {
        v1 = @"";
    } else {
        switch (a1 + 8) {
            case 0:
                return @"y";
            case 1:
                return @"z";
            case 2:
                return @"a";
            case 3:
                return @"f";
            case 4:
                return @"p";
            case 5:
                return @"n";
            case 6:
                return @"µ";
            case 7:
                return @"m";
            case 8:
                return @"";
            case 9:
                return @"k";
            case 10:
                return @"M";
            case 11:
                return @"G";
            case 12:
                return @"T";
            case 13:
                return @"P";
            case 14:
                return @"E";
            case 15:
                return @"Z";
            case 16:
                return @"Y";
            default:
                return @"";
        }
    }
    return v1;
}


NSNumberFormatter *-[CNTElapsedTimeFormatter numberFormatter](void)
{
    return self->_numberFormatter;
}


void -[CNTElapsedTimeFormatter .cxx_destruct](void)
{
    self->_numberFormatter = nil;
}
