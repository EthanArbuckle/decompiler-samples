static int (*qword_10001a5d0)(NSMutableArray *);
static int (*qword_10001a5d8)(NSNumber *);
static int (*qword_10001a5e0)(NSNumber *);
static int (*qword_10001a5e8)(id);
static int (*qword_10001a5f0)(id);
static int (*qword_10001a5f8)(id);
static int (*qword_10001a600)(id);
static int (*qword_10001a608)(int, int);
static int (*qword_10001a620)(int);
static int dword_10001a6c0;
static int dword_10001a6d8;
static int dword_10001a6dc;
static int dword_10001a6e0;
static int dword_10001a6e4;
static int dword_10001a6e8;
static int dword_10001a6ec;
static long qword_10001a610;
static long qword_10001a618;
static long qword_10001a628;
static long qword_10001a630;
static long qword_10001a638;
static long qword_10001a640;
static long qword_10001a648;
static long qword_10001a650;
static long qword_10001a6c8;

id sub_100001af8(id a1)
{
    return [a1 name];
}


id sub_100001cf8(id a1)
{
    return [a1 name];
}


int sub_100004ab4(void)
{
    int v5;
    @autoreleasepool {
        if (getuid() != 501) {
            puts("You're not mobile. Running as mobile…");
            if (setuid(501) != 0) {
                puts("Can't switch you to mobile, expect things to fail!");
            }
        }
        CNTContactsTool *v2 = [[CNTContactsTool alloc] init];
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSArray<NSString *> *arguments = [processInfo arguments];
        v5 = [v2 mainWithArguments:arguments];
    }
    return v5;
}


int sub_1000063fc(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonFirstNameProperty"));
    dword_10001a6c0 = v0;
    qword_10001a5d0 = &sub_1000064ac;
    return v0;
}


int sub_1000064ac(void)
{
    return dword_10001a6c0;
}


int sub_1000064b8(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonMiddleNameProperty"));
    dword_10001a6d8 = v0;
    qword_10001a5d8 = &sub_100006520;
    return v0;
}


int sub_100006520(void)
{
    return dword_10001a6d8;
}


int sub_10000652c(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonLastNameProperty"));
    dword_10001a6dc = v0;
    qword_10001a5e0 = &sub_100006594;
    return v0;
}


int sub_100006594(void)
{
    return dword_10001a6dc;
}


int sub_1000065a0(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonEmailProperty"));
    dword_10001a6e0 = v0;
    qword_10001a5e8 = &sub_100006608;
    return v0;
}


int sub_100006608(void)
{
    return dword_10001a6e0;
}


int sub_100006614(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonPhoneProperty"));
    dword_10001a6e4 = v0;
    qword_10001a5f0 = &sub_10000667c;
    return v0;
}


int sub_10000667c(void)
{
    return dword_10001a6e4;
}


int sub_100006688(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonAddressProperty"));
    dword_10001a6e8 = v0;
    qword_10001a5f8 = &sub_1000066f0;
    return v0;
}


int sub_1000066f0(void)
{
    return dword_10001a6e8;
}


int sub_1000066fc(void)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v1 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v1;
        if (v1 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    int v0 = *(dlsym(qword_10001a6c8, "kABPersonInstantMessageProperty"));
    dword_10001a6ec = v0;
    qword_10001a600 = &sub_100006764;
    return v0;
}


int sub_100006764(void)
{
    return dword_10001a6ec;
}


int sub_100006770(long a1, long a2)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a608 = dlsym(qword_10001a6c8, "ABAddressBookCreateWithOptions");
    return qword_10001a608(a1, a2);
}


int sub_1000067e0(long a1, long a2, long a3)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a610 = dlsym(qword_10001a6c8, "ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering");
    return qword_10001a610(a1, a2, a3);
}


int sub_100006860(long a1, long a2)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a618 = dlsym(qword_10001a6c8, "ABAddressBookCopyPeopleWithName");
    return qword_10001a618(a1, a2);
}


int sub_1000068d0(long a1)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a620 = dlsym(qword_10001a6c8, "ABPersonGetTypeOfProperty");
    return qword_10001a620(a1);
}


int sub_100006938(long a1, long a2)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a628 = dlsym(qword_10001a6c8, "ABRecordCopyValue");
    return qword_10001a628(a1, a2);
}


int sub_1000069a8(long a1)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a630 = dlsym(qword_10001a6c8, "ABMultiValueGetCount");
    return qword_10001a630(a1);
}


int sub_100006a10(long a1, long a2)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a638 = dlsym(qword_10001a6c8, "ABMultiValueCopyValueAtIndex");
    return qword_10001a638(a1, a2);
}


int sub_100006a80(long a1)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a640 = dlsym(qword_10001a6c8, "ABMultiValueGetPropertyType");
    return qword_10001a640(a1);
}


int sub_100006ae8(long a1)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a648 = dlsym(qword_10001a6c8, "ABRecordGetRecordID");
    return qword_10001a648(a1);
}


int sub_100006b50(long a1, long a2)
{
    dispatch_once(&qword_10001a6d0, ^void(void) {
        void *v0 = dlopen("/System/Library/Frameworks/AddressBook.framework/AddressBook", 2);
        qword_10001a6c8 = v0;
        if (v0 != 0) {
            return;
        }
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            sub_10000c33c();
        }
    });
    qword_10001a650 = dlsym(qword_10001a6c8, "ABAddressBookGetPersonWithRecordID");
    return qword_10001a650(a1, a2);
}


id sub_100007834(id a1)
{
    return [a1 name];
}


void sub_10000c1fc(void)
{
    __assert_rtn("-[CNBContactsNativeImplementation properties:forContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNativeImplementation.m", 57, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c224(void)
{
    __assert_rtn("-[CNBContactsNativeImplementation identifierForContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNativeImplementation.m", 63, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c24c(void)
{
    __assert_rtn("-[CNBContactsNativeImplementation contactForIdentifier:consideringProperties:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNativeImplementation.m", 70, "[cnbIdentifer isKindOfClass:[NSString class]]");
}


void sub_10000c274(void)
{
    __assert_rtn("-[CNBContactsFaultingImplementation properties:forContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsFaultingImplementation.m", 56, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c29c(void)
{
    __assert_rtn("-[CNBContactsFaultingImplementation identifierForContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsFaultingImplementation.m", 69, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c2c4(void)
{
    __assert_rtn("-[CNBContactsFaultingImplementation contactForIdentifier:consideringProperties:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsFaultingImplementation.m", 75, "[cnbIdentifer isKindOfClass:[NSString class]]");
}


void sub_10000c2ec(void)
{
    __assert_rtn("-[CNBAddressBookLegacyImplementation contactForIdentifier:consideringProperties:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBAddressBookLegacyImplementation.m", 125, "[identifer isKindOfClass:[NSNumber class]]");
}


void sub_10000c314(void)
{
    __assert_rtn("-[CNBAddressBookShimImplementation contactForIdentifier:consideringProperties:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBAddressBookShimImplementation.m", 113, "[identifer isKindOfClass:[NSNumber class]]");
}


void sub_10000c33c(void)
{
    int *v0 = __error();
    int v2 = *(v0);
    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "Failed to Soft Link: /System/Library/Frameworks/AddressBook.framework/AddressBook (%d)", v2);
}


void sub_10000c3bc(void)
{
    __assert_rtn("-[CNBContactsNonUnifyingImplementation properties:forContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNonUnifyingImplementation.m", 57, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c3e4(void)
{
    __assert_rtn("-[CNBContactsNonUnifyingImplementation identifierForContact:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNonUnifyingImplementation.m", 63, "[cnbContact isKindOfClass:[CNContact class]]");
}


void sub_10000c40c(void)
{
    __assert_rtn("-[CNBContactsNonUnifyingImplementation contactForIdentifier:consideringProperties:]", "/BuildRoot/Library/Caches/com.apple.xbs/Sources/ContactsTool/ContactsTool-1010/ContactsBenchmark/Implementations/CNBContactsNonUnifyingImplementation.m", 72, "[cnbIdentifer isKindOfClass:[NSString class]]");
}
