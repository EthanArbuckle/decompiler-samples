static CFTimeInterval qword_1dd78;
static CFTimeInterval qword_1dd80;
static bool byte_1dd38;
static bool byte_1dd70;
static bool byte_1dd71;
static long qword_1de00;
static void (*qword_1ddb0)(int, int, NSDictionary<NSString *, id> *);

__attribute__((constructor))
void sub_4000(void)
{
    bool v3;
    @autoreleasepool {
        [JWRPreferences shared];
        Class cls = objc_getClass("SpringBoard");
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        if (!processInfo) {
            v3 = false;
        } else {
            NSOperatingSystemVersion operatingSystemVersion = [processInfo operatingSystemVersion];
            if (operatingSystemVersion.majorVersion < 18) {
                v3 = false;
            } else {
                v3 = class_getInstanceMethod(cls, @selector(_handlePhysicalButtonEvent:)) != 0;
            }
        }
        byte_1dd38 = v3;
        JWRLog(@"iOS 18 physical button event hook available=%d", byte_1dd38);
    }
}


__attribute__((constructor))
void sub_40f8(void)
{
    Class v0 = objc_getClass("SBVolumeControl");
    MSHookMessageEx(v0, @selector(increaseVolume), &sub_41f4, &qword_1dd40);
    MSHookMessageEx(v0, @selector(decreaseVolume), &sub_427c, &qword_1dd48);
    Class v1 = objc_getClass("SBLiftToWakeManager");
    MSHookMessageEx(v1, @selector(liftToWakeController:didObserveTransition:deviceOrientation:), &sub_4304, &qword_1dd50);
    Class v2 = objc_getClass("SBLockScreenManager");
    MSHookMessageEx(v2, @selector(_wakeScreenForTapToWake), &sub_4414, &qword_1dd58);
    Class v3 = objc_getClass("SpringBoard");
    MSHookMessageEx(v3, @selector(_handlePhysicalButtonEvent:), &sub_44f0, &qword_1dd60);
    MSHookMessageEx(v3, @selector(applicationDidFinishLaunching:), &sub_46d4, &qword_1dd68);
}


void sub_41f4(id a1, SEL a2)
{
    if (!byte_1dd38) {
        sub_49e4(1);
    }
    qword_1dd40(a1, a2);
    if (byte_1dd38) {
        return;
    }
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 20) * 3);
    dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
        byte_1dd70 = false;
    });
}


void sub_427c(id a1, SEL a2)
{
    if (!byte_1dd38) {
        sub_49e4(0);
    }
    qword_1dd48(a1, a2);
    if (byte_1dd38) {
        return;
    }
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 20) * 3);
    dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
        byte_1dd71 = false;
    });
}


void sub_4304(id a1, SEL a2, id a3, long a4, long a5)
{
    JWRPreferences *shared = [JWRPreferences shared];
    if (![shared preventWakeWhileRecording]) {
        qword_1dd50(a1, a2, a3, a4, a5);
    } else {
        JWRRecorderManager *shared2 = [JWRRecorderManager shared];
        if (![shared2 videoRecording]) {
            qword_1dd50(a1, a2, a3, a4, a5);
        } else {
            JWRLog(@"suppressed raise-to-wake during video recording");
        }
    }
}


void sub_4414(id a1, SEL a2)
{
    JWRPreferences *shared = [JWRPreferences shared];
    if ([shared preventWakeWhileRecording]) {
        JWRRecorderManager *shared2 = [JWRRecorderManager shared];
        if ([shared2 videoRecording]) {
            JWRLog(@"suppressed tap-to-wake during video recording");
            return;
        }
        qword_1dd58(a1, a2);
        return;
    }
    qword_1dd58(a1, a2);
}


int sub_44f0(id a1, SEL a2, id a3)
{
    if (byte_1dd38 == 1) {
        NSSet<UIPress *> *allPresses = [a3 allPresses];
        for (UIPress *v9 in allPresses) {
            UIPressType type = [v9 type];
            if ((unsigned long)(type - 102) < 2) {
                if ([v9 force] > 0.0) {
                    sub_49e4(type == 102);
                } else {
                    *((type == 102) ? &qword_1dd70 : &qword_1dd71) = 0;
                }
            }
        }
    }
    return qword_1dd60(a1, a2, a3);
}


void sub_46d4(id a1, SEL a2, id a3)
{
    qword_1dd68(a1, a2, a3);
    JWRLog(@"SpringBoard trigger component loaded");
    JWRLog(@"volume trigger source=%@", (byte_1dd38) ? @"physical button events" : @"SBVolumeControl");
    JWRRecorderManager *shared = [JWRRecorderManager shared];
    [shared recoverPendingRecordings];
    const char *name4 = [@"com.jimwas.recorder/toggleVideo" UTF8String];
    notify_register_dispatch(name4, &qword_1dd88, dispatch_get_main_queue(), ^void(int arg1) {
        JWRLog(@"SpringBoard received video toggle");
        JWRRecorderManager *shared = [JWRRecorderManager shared];
        [shared toggleVideo];
    });
    const char *name5 = [@"com.jimwas.recorder/takePhoto" UTF8String];
    notify_register_dispatch(name5, &qword_1dd8c, dispatch_get_main_queue(), ^void(int arg1) {
        JWRLog(@"SpringBoard received photo request");
        JWRRecorderManager *shared = [JWRRecorderManager shared];
        [shared takePhoto];
    });
    const char *name6 = [@"com.jimwas.recorder/hapticStarted" UTF8String];
    notify_register_dispatch(name6, &qword_1dd90, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        AudioServicesPlaySystemSound(1520);
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 25) * 4);
        dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
            AudioServicesPlaySystemSound(1520);
        });
        JWRLog(@"played recording-started double haptic");
    });
    const char *name7 = [@"com.jimwas.recorder/hapticStopped" UTF8String];
    notify_register_dispatch(name7, &qword_1dd94, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        AudioServicesPlaySystemSound(1520);
        JWRLog(@"played recording-stopped haptic");
    });
    const char *name8 = [@"com.jimwas.recorder/hapticPhoto" UTF8String];
    notify_register_dispatch(name8, &qword_1dd98, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        AudioServicesPlaySystemSound(1519);
        JWRLog(@"played photo-captured haptic");
    });
    const char *name9 = [@"com.jimwas.recorder/hapticHeartbeat" UTF8String];
    notify_register_dispatch(name9, &qword_1dd9c, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        AudioServicesPlaySystemSound(1519);
        JWRLog(@"played recording heartbeat haptic");
    });
    const char *name10 = [@"com.jimwas.recorder/hapticFailure" UTF8String];
    notify_register_dispatch(name10, &qword_1dda0, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        AudioServicesPlaySystemSound(1521);
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 50) * 7);
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_after(when, queue, ^void(void) {
            AudioServicesPlaySystemSound(1521);
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 25) * 7), queue, ^void(void) {
            AudioServicesPlaySystemSound(1521);
        });
        JWRLog(@"played recording-failure triple haptic");
    });
    const char *name = [@"com.jimwas.recorder/hapticVideoStarted" UTF8String];
    notify_register_dispatch(name, &qword_1dda4, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        sub_51a4(1);
        JWRLog(@"played video-started SE2-compatible strong vibration pattern");
    });
    const char *name2 = [@"com.jimwas.recorder/hapticVideoStopped" UTF8String];
    notify_register_dispatch(name2, &qword_1dda8, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        if (![shared haptics]) {
            return;
        }
        sub_51a4(0);
        JWRLog(@"played video-stopped SE2-compatible strong vibration pattern");
    });
    const char *name3 = [@"com.jimwas.recorder/reload" UTF8String];
    notify_register_dispatch(name3, &qword_1ddac, dispatch_get_main_queue(), ^void(int arg1) {
        JWRPreferences *shared = [JWRPreferences shared];
        [shared reload];
        JWRRecorderManager *shared2 = [JWRRecorderManager shared];
        [shared2 refreshHealthMonitoring];
    });
}


void sub_49e4(int a1)
{
    JWRPreferences *shared = [JWRPreferences shared];
    CFTimeInterval v1 = CACurrentMediaTime();
    if (a1) {
        if (byte_1dd71 != 1) {
            byte_1dd70 = true;
            if (v1 - qword_1dd78 < 0.38) {
                sub_4bf4([shared doubleVolumeUpAction]);
            }
            qword_1dd78 = v1;
            dispatch_time_t when2 = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 10) * 7);
            dispatch_after(when2, dispatch_get_main_queue(), ^void(void) {
                if (byte_1dd70 != 1) {
                    return;
                }
                byte_1dd70 = false;
                sub_4bf4([shared longVolumeUpAction]);
            });
        } else {
            sub_4bf4([shared bothVolumesAction]);
            byte_1dd71 = false;
            byte_1dd70 = false;
        }
    } else if (byte_1dd70 != 1) {
        byte_1dd71 = true;
        if (v1 - qword_1dd80 < 0.38) {
            sub_4bf4([shared doubleVolumeDownAction]);
        }
        qword_1dd80 = v1;
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 10) * 7);
        dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
            if (byte_1dd71 != 1) {
                return;
            }
            byte_1dd71 = false;
            sub_4bf4([shared longVolumeDownAction]);
        });
    } else {
        sub_4bf4([shared bothVolumesAction]);
        byte_1dd71 = false;
        byte_1dd70 = false;
    }
}


void sub_4bf4(long a1)
{
    JWRPreferences *shared = [JWRPreferences shared];
    if (![shared enabled]) {
        JWRLog(@"trigger ignored action=%ld", a1);
    } else {
        long v2 = 0;
        if ([shared triggersWhileLocked]) {
            v2 = 1;
        } else {
            Class v1 = NSClassFromString(@"SBLockScreenManager");
            if (![v1 respondsToSelector:@selector(sharedInstance)]) {
blk_4cc0:
                v2 = 1;
            }
            if (!v2) {
                id v3 = [v1 performSelector:@selector(sharedInstance)];
                if (!v3 || ![v3 respondsToSelector:@selector(isUILocked)]) {
                    goto blk_4cc0;
                }
                if (![v3 isUILocked]) {
                    v2 = 1;
                } else {
                    JWRLog(@"trigger ignored action=%ld", a1);
                }
            }
        }
        if (v2) {
            JWRLog(@"sending trigger action=%ld", a1);
            if ((unsigned long)(a1 - 1) <= 2) {
                notify_post([(&qword_183e0)[a1 - 1] UTF8String]);
            }
        }
    }
}


void sub_51a4(int a1)
{
    if (qword_1ddb8 != -1) {
        sub_d7b8();
    }
    if (qword_1ddb0 != 0) {
        qword_1ddb0(0xfff, 0, @{@"VibePattern": (a1 != 0) ? @[@YES, @360, @NO, @180, @YES, @360] : @[@YES, @650], @"Intensity": @1.0});
        return;
    }
    UIImpactFeedbackGenerator *v6 = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [v6 prepare];
    if (![v6 respondsToSelector:@selector(impactOccurredWithIntensity:)]) {
        [v6 impactOccurred];
    } else {
        [v6 impactOccurredWithIntensity:1.0];
    }
    AudioServicesPlaySystemSound(1520);
    if (a1 != 0) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 25) * 9);
        dispatch_after(when, dispatch_get_main_queue(), ^void(void) {
            UIImpactFeedbackGenerator *v0 = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
            [v0 prepare];
            [v0 impactOccurred];
            AudioServicesPlaySystemSound(1520);
        });
    }
}


void JWRLog(NSString *a1, ...)
{
    va_list v3;
    va_start(v3, a1);
    NSString *v2 = [[NSString alloc] initWithFormat:a1 arguments:v3];
    NSDateFormatter *v4 = [NSDateFormatter new];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [v4 setLocale:locale];
    [v4 setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSDate *date = [NSDate date];
    NSString *v7 = [v4 stringFromDate:date];
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *processName = [processInfo processName];
    NSString *v10 = [NSString stringWithFormat:@"%@ [%@:%d] %@\n", v7, processName, getpid(), v2];
    NSLog(@"[JWR] %@", v2);
    @try {
        NSData *data = [v10 dataUsingEncoding:NSUTF8StringEncoding];
        for (NSString *v18 in @[@"/var/mobile/Library/Logs/JimWasRecorder", @"/var/mobile/Documents/JimWasRecorder", @"/tmp/JimWasRecorder"]) {
            NSFileManager *defaultManager = [NSFileManager defaultManager];
            NSError *error = nil;
            if ([defaultManager createDirectoryAtPath:v18 withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSString *path = [v18 stringByAppendingPathComponent:@"debug.log"];
                NSFileManager *defaultManager2 = [NSFileManager defaultManager];
                if (![defaultManager2 fileExistsAtPath:path]) {
                    NSData *data2 = [NSData data];
                    if (![data2 writeToFile:path options:NSDataWritingAtomic error:nil]) {
                        continue;
                    }
                }
                NSFileHandle *v28 = [NSFileHandle fileHandleForWritingAtPath:path];
                if (v28 != nil) {
                    [v28 seekToEndOfFile];
                    [v28 writeData:data];
                    [v28 closeFile];
                    va_end(v3);
                    return;
                }
            }
        }
    } @catch (id v27) {
        NSLog(@"[JWR] Logger exception: %@", v27);
    }
    va_end(v3);
}


bool JWRTrialCanBeginCapture(void)
{
    double v0 = sub_d01c(1);
    NSDate *date = [NSDate date];
    NSTimeInterval timeIntervalSince1970 = [date timeIntervalSince1970];
    if (timeIntervalSince1970 >= v0) {
        return timeIntervalSince1970 < v0 + 604800.0;
    } else {
        return false;
    }
}


double sub_d01c(int a1)
{
    struct stat v2;
    if (a1 != 0) {
        int v0 = open("/var/mobile/Library/Preferences/com.jimwas.recorder.trial-start", O_WRONLY | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
        if (v0 >= 0) {
            close(v0);
        }
    }
    int v1 = stat("/var/mobile/Library/Preferences/com.jimwas.recorder.trial-start", &v2);
    return (!v1) ? (double)v2.st_birthtimespec.tv_sec : 0.0;
}


double JWRTrialRemainingSeconds(void)
{
    struct stat v1;
    int v0 = stat("/var/mobile/Library/Preferences/com.jimwas.recorder.trial-start", &v1);
    double v3 = (!v0) ? (double)v1.st_birthtimespec.tv_sec : 0.0;
    if (((!v0) ? (double)v1.st_birthtimespec.tv_sec : 0.0) <= 0.0) {
        return 604800.0;
    }
    NSDate *date = [NSDate date];
    NSTimeInterval timeIntervalSince1970 = [date timeIntervalSince1970];
    double v6 = fmax(v3 + 604800.0 - timeIntervalSince1970, 0.0);
    return (timeIntervalSince1970 < v3) ? 0.0 : v6;
}


NSString *JWRTrialStatusText(void)
{
    struct stat v1;
    int v0 = stat("/var/mobile/Library/Preferences/com.jimwas.recorder.trial-start", &v1);
    if (((!v0) ? (double)v1.st_birthtimespec.tv_sec : 0.0) <= 0.0) {
        return @"Trial: 7 days from your first capture.";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:((!v0) ? (double)v1.st_birthtimespec.tv_sec : 0.0) + 604800.0];
    NSDateFormatter *v4 = [NSDateFormatter new];
    [v4 setDateStyle:NSDateFormatterMediumStyle];
    [v4 setTimeStyle:NSDateFormatterShortStyle];
    double v5 = JWRTrialRemainingSeconds();
    NSString *v6 = [v4 stringFromDate:date];
    return [NSString stringWithFormat:(v5 > 0.0) ? @"Trial ends %@." : @"Trial expired %@. Install the full package to continue recording.", v6];
}


bool sub_d248(int a1, int a2, int a3)
{
    if (qword_1ddf0 != -1) {
        dispatch_once_f(&qword_1ddf0, NULL, &sub_d2f8);
    }
    if (dword_1dde0 > a1) {
        return true;
    }
    if (dword_1dde0 >= a1) {
        if (dword_1dde4 > a2) {
            return true;
        } else if (dword_1dde4 >= a2) {
            return dword_1dde8 >= a3;
        } else {
            return false;
        }
    } else {
        return false;
    }
}


void sub_d2f8(void *a1)
{
    sub_d490(1);
}


long sub_d300(int a1, int a2, int a3, int a4)
{
    uint8_t v3[16];
    if (qword_1ddf8 != -1) {
        dispatch_once_f(&qword_1ddf8, NULL, &sub_d488);
    }
    if (qword_1de00 != 0) {
        int v1 = a2 << 16;
        int v2 = (v1 & 0xffff00ff) | ((a3 & 255) << 8);
        *(uint32_t *)&v3[0] = a1;
        *(uint32_t *)&v3[4] = (v2 & 0xffffff00) | (a4 & 255);
        return _availability_version_check(1, &v3);
    }
    if (qword_1ddf0 != -1) {
        dispatch_once_f(&qword_1ddf0, NULL, &sub_d2f8);
    }
    if (dword_1dde0 > a2) {
        return 1;
    }
    if (dword_1dde0 < a2) {
        return 0;
    }
    if (dword_1dde4 > a3) {
        return 1;
    }
    if (dword_1dde4 < a3) {
        return 0;
    }
    return dword_1dde8 >= a4;
}


void sub_d488(void *a1)
{
    sub_d490(0);
}


void sub_d490(int a1)
{
    void *v14;
    char v22[32];
    void *v10;
    void *v23;
    void *v6;
    void *v8;
    int *v1 = qword_1de00;
    if (qword_1de00 != 0 && !a1) {
        return;
    }
    if (&_availability_version_check != 0) {
        qword_1de00 = &_availability_version_check;
        v1 = &_availability_version_check;
    }
    if ((v1 != 0 && !a1) || !(v23 = dlsym(-2, "kCFAllocatorNull"))) {
        return;
    }
    CFAllocatorRef v3 = *(v23);
    if (!dlsym(-2, "CFDataCreateWithBytesNoCopy")) {
        return;
    }
    void *v4 = dlsym(-2, "CFPropertyListCreateWithData");
    void *v5 = dlsym(-2, "CFPropertyListCreateFromXMLData");
    if ((!v4 && !v5) || !(v6 = dlsym(-2, "CFStringCreateWithCStringNoCopy"))) {
        return;
    }
    void *v7 = dlsym(-2, "CFDictionaryGetValue");
    if (!v7 || !(v8 = dlsym(-2, "CFGetTypeID"))) {
        return;
    }
    void *v9 = dlsym(-2, "CFStringGetTypeID");
    if (!v9 || !(v10 = dlsym(-2, "CFStringGetCString"))) {
        return;
    }
    if (!dlsym(-2, "CFRelease")) {
        return;
    }
    FILE *v12 = fopen("/System/Library/CoreServices/SystemVersion.plist", "r");
    if (!v12) {
        return;
    }
    fseek(v12, 0, 2);
    long length = ftell(v12);
    if (length < 0) {
        v14 = 0;
    } else {
        rewind(v12);
        v14 = malloc(length);
        if (v14 != 0) {
            size_t v15 = fread(v14, 1, length, v12);
            if (v15 == length) {
                CFDataRef v16 = CFDataCreateWithBytesNoCopy(NULL, v14, length, v3);
                if (v16 != 0) {
                    CFDictionaryRef v17 = (!v4) ? CFPropertyListCreateFromXMLData(NULL, v16, 0, NULL) : CFPropertyListCreateWithData(NULL, v16, 0, NULL, NULL);
                    if (v17 != 0) {
                        CFStringRef v18 = CFStringCreateWithCStringNoCopy(NULL, "ProductVersion", kCFStringEncodingASCII, v3);
                        if (v18 != 0) {
                            const void *v19 = CFDictionaryGetValue(v17, v18);
                            CFRelease(v18);
                            if (v19 != 0) {
                                CFTypeID v20 = CFGetTypeID(v19);
                                CFTypeID v21 = CFStringGetTypeID();
                                if (v20 == v21 && CFStringGetCString(v19, v22, 32, kCFStringEncodingUTF8)) {
                                    sscanf(v22, "%d.%d.%d", &qword_1dde0, &qword_1dde4, &qword_1dde8);
                                }
                            }
                        }
                        CFRelease(v17);
                    }
                    CFRelease(v16);
                }
            }
        }
    }
    free(v14);
    fclose(v12);
}


void sub_d7b0(dispatch_once_t *a1, dispatch_function_t a2)
{
    dispatch_once_f(a1, NULL, a2);
}


void sub_d7b8(void)
{
    dispatch_once(&qword_1ddb8, ^void(void) {
        void *v0 = dlsym(-2, "AudioServicesPlaySystemSoundWithVibration");
        qword_1ddb0 = v0;
        if (v0 != 0) {
            JWRLog(@"strong vibration API available=%d", 1);
            return;
        } else {
            JWRLog(@"strong vibration API available=%d", 0);
            return;
        }
    });
}


void sub_d7cc(void)
{
    sub_d7b0(&qword_1ddf0, &sub_d2f8);
}


void sub_d7e0(void)
{
    sub_d7b0(&qword_1ddf8, &sub_d488);
}


void sub_d7f4(void)
{
    sub_d7b0(&qword_1ddf0, &sub_d2f8);
}
