void sub_10000699c(long a1, long a2)
{
    *(x29 - 8) = a2;
}


void sub_1000069b4(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[12];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 12);
}


void sub_1000069c4(long a1)
{
}


void sub_1000069cc(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 2);
}


void sub_100007b20(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_debug_impl(a1, a2, OS_LOG_TYPE_DEBUG, a3, v0, 2);
}


void sub_100007b30(long a1)
{
}


void sub_100007b38(long a1)
{
}


void sub_100007b44(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_fault_impl(a1, a2, OS_LOG_TYPE_FAULT, a3, v0, 2);
}


void sub_1000086a0(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 2);
}


void sub_1000086b0(long a1)
{
}


void sub_1000086b8(long a1)
{
}


int sub_100008acc(void)
{
    __block int v1;
    @autoreleasepool {
        v1 = 1;
        _os_activity_initiate(&_mh_execute_header, "OSDToolbox", 0, ^void(void) {
            v1 = [FTModuleManager startToolWithToolOverview:@"OSD generic tool"];
        });
    }
    return v1;
}


void sub_10000a478(long a1, long a2)
{
    *(x29 - 8) = a2;
}


void sub_10000a490(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[12];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 12);
}


void sub_10000a4a0(long a1)
{
}


void sub_10000a4a8(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[2];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 2);
}


void sub_10000bba0(void *a1, os_log_t a2, char *a3)
{
    unsigned char v0[12];
    _os_log_error_impl(a1, a2, OS_LOG_TYPE_ERROR, a3, v0, 12);
}


void sub_10000bbb0(long a1, long a2)
{
    *(x29 - 8) = a2;
}


void sub_10000bbcc(long a1)
{
}


void sub_10000bbd4(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error suspending Earthbound: %@\n", a1);
    sub_1000069c4();
}


void sub_10000bc28(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error resuming Earthbound: %@\n", a1);
    sub_1000069c4();
}


void sub_10000bc7c(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error stopping Earthbound: %@\n", a1);
    sub_1000069c4();
}


void sub_10000bcd0(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error setting stop on fail Earthbound: %@\n", a1);
    sub_1000069c4();
}


void sub_10000bd24(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error unclamping Earthbound: %@\n", a1);
    sub_1000069c4();
}


void sub_10000bd78(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error displaying image: %@", a1);
    sub_1000069c4();
}


void sub_10000bdcc(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error displaying rgb: %@", a1);
    sub_1000069c4();
}


void sub_10000be20(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Erroring deleting Sequences\n");
}


void sub_10000be54(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Error unloading Earthbound");
}


void sub_10000be88(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_FAULT, "Trigger a state dump!");
    sub_100007b30();
}


void sub_10000beb4(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_DEBUG, "Use the os_log_*_enabled SPI when you need to spend time creating a detailed message, or when you need to hold a crucial lock.");
    sub_100007b30();
}


void sub_10000bee0(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_DEBUG, "This will only run with debug logging enabled");
    sub_100007b30();
}


void sub_10000bf0c(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_FAULT, "This is a fault log. It will contain statedumps across all processes as well, so performance will suck");
    sub_100007b30();
}


void sub_10000bf38(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "This is an error log, it will also get flushed to disk (with no state information)");
    sub_100007b30();
}


void sub_10000bf70(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_DEBUG, "This is a debug log, it is off by default");
    sub_100007b30();
}


void sub_10000bf9c(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Sorry, I did not understand your request.  Please use \"-h\" to see the help.");
    sub_1000086b0();
}


void sub_10000bfc8(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Task unload was a failure");
    sub_1000086b0();
}


void sub_10000bff4(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Task switch was a failure");
    sub_1000086b0();
}


void sub_10000c020(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Task switch was a failure");
    sub_1000086b0();
}


void sub_10000c04c(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "Please pass one option per call.");
}


void sub_10000c080(os_log_t a1)
{
    os_log_with_type(a1, OS_LOG_TYPE_ERROR, "This must be launched from a tty (shell) with no redirections! Not suspending the display watchdog!");
}


void sub_10000c0b4(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error suspending the display watchdog: %@", a1);
    sub_10000a4a0();
}


void sub_10000c108(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error reading the display watchdog info: %@", a1);
    sub_10000a4a0();
}


void sub_10000c15c(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error reading the current the display power state: %@", a1);
    sub_10000a4a0();
}


void sub_10000c1b0(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error setting the display power: %@", a1);
    sub_10000a4a0();
}


void sub_10000c204(uint8_t *a1, char *a2, os_log_t a3)
{
    *(a1) = 0;
    *(a2) = 0;
    _os_log_error_impl(&_mh_execute_header, a3, OS_LOG_TYPE_ERROR, "MoPED was a failure", a1, 2);
}


void sub_10000c244(long *a1, os_log_t a2)
{
    id v1 = *(a1);
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "AMFDRDataCopy error: %@", v1);
    sub_10000bbcc();
}


void sub_10000c298(long *a1, os_log_t a2)
{
    id v1 = *(a1);
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "AMFDRSealingMapCopyLocalDataForClass error: %@", v1);
    sub_10000bbcc();
}


void sub_10000c2ec(id a1, os_log_t a2)
{
    os_log_with_type(a2, OS_LOG_TYPE_ERROR, "Error writing to file due to %@", a1);
    sub_10000bbcc();
}
