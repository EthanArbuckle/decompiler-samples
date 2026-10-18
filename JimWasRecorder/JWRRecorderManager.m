struct JWRRecorderManager {
    bool _videoRecording; // +0x8
    bool _audioRecording; // +0x9
    bool _rollingSegment; // +0xa
    bool _recoveryInProgress; // +0xb
    bool _desiredVideoRecording; // +0xc
    bool _desiredAudioRecording; // +0xd
    bool _recoveryScanned; // +0xe
    NSObject<OS_dispatch_queue> *_queue; // +0x10
    AVCaptureSession *_session; // +0x18
    AVCaptureMovieFileOutput *_movieOutput; // +0x20
    AVCapturePhotoOutput *_photoOutput; // +0x28
    AVAudioRecorder *_audioRecorder; // +0x30
    NSURL *_videoURL; // +0x38
    id _sessionErrorObserver; // +0x40
    id _sessionInterruptedObserver; // +0x48
    id _sessionInterruptionEndedObserver; // +0x50
    long _recoveryAttempts; // +0x58
    unsigned long _recordingGeneration; // +0x60
    NSObject<OS_dispatch_source> *_segmentTimer; // +0x68
    NSObject<OS_dispatch_source> *_heartbeatTimer; // +0x70
    NSObject<OS_dispatch_source> *_watchdogTimer; // +0x78
    NSObject<OS_dispatch_source> *_trialTimer; // +0x80
};

static JWRRecorderManager *qword_1ddc0;

JWRRecorderManager *+[JWRRecorderManager shared](void)
{
    dispatch_once(&qword_1ddc8, ^void(void) {
        qword_1ddc0 = [self new];
        dispatch_queue_t v1 = dispatch_queue_create("com.jimwas.recorder.capture", nil);
        [qword_1ddc0 setQueue:v1];
    });
    return qword_1ddc0;
}


NSString *-[JWRRecorderManager outputDirectory](void)
{
    return @"/var/mobile/Documents/JimWasRecorder";
}


NSString *-[JWRRecorderManager videoOutputDirectory](void)
{
    JWRPreferences *shared = [JWRPreferences shared];
    return [shared videoOutputDirectory];
}


NSString *-[JWRRecorderManager inProgressDirectory](void)
{
    NSString *videoOutputDirectory = [self videoOutputDirectory];
    return [videoOutputDirectory stringByAppendingPathComponent:@".inprogress"];
}


NSURL *-[JWRRecorderManager outputURLWithExtension:directory:](NSString *a1, NSString *a2)
{
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [defaultManager createDirectoryAtPath:a2 withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        JWRLog(@"output directory creation failed path=%@ error=%@", a2, error);
    }
    NSDateFormatter *v5 = [NSDateFormatter new];
    [v5 setDateFormat:@"yyyy-MM-dd_HH-mm-ss-SSS"];
    JWRPreferences *shared = [JWRPreferences shared];
    NSString *filenamePrefix = [shared filenamePrefix];
    NSDate *date = [NSDate date];
    NSString *v9 = [v5 stringFromDate:date];
    NSString *str = [NSString stringWithFormat:@"%@_%@.%@", filenamePrefix, v9, a1];
    NSString *v11 = [a2 stringByAppendingPathComponent:str];
    return [NSURL fileURLWithPath:v11];
}


NSURL *-[JWRRecorderManager outputURLWithExtension:](NSString *a1)
{
    NSString *outputDirectory = [self outputDirectory];
    return [self outputURLWithExtension:a1 directory:outputDirectory];
}


void -[JWRRecorderManager prepareVideoURLs](void)
{
    NSString *videoOutputDirectory = [self videoOutputDirectory];
    NSURL *v1 = [self outputURLWithExtension:@"mov" directory:videoOutputDirectory];
    NSString *inProgressDirectory = [self inProgressDirectory];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [defaultManager createDirectoryAtPath:inProgressDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        JWRLog(@"video staging directory creation failed path=%@ error=%@", inProgressDirectory, error);
    }
    NSString *lastPathComponent = [v1 lastPathComponent];
    NSString *v7 = [inProgressDirectory stringByAppendingPathComponent:lastPathComponent];
    NSURL *v8 = [NSURL fileURLWithPath:v7];
    [self setVideoURL:v8];
}


NSURL *-[JWRRecorderManager finalURLForStagedURL:recovered:](NSURL *a1, bool a2)
{
    NSString *v1 = [a1 lastPathComponent];
    if (a2) {
        NSString *v2 = [@"Recovered_" stringByAppendingString:v1];
        v1 = v2;
    }
    NSURL *URLByDeletingLastPathComponent = [a1 URLByDeletingLastPathComponent];
    NSURL *URLByDeletingLastPathComponent2 = [URLByDeletingLastPathComponent URLByDeletingLastPathComponent];
    NSString *path = [URLByDeletingLastPathComponent2 path];
    NSString *v6 = [path stringByAppendingPathComponent:v1];
    return [NSURL fileURLWithPath:v6];
}


bool -[JWRRecorderManager validateMovieAtURL:reason:](NSURL *a1, NSString **a2)
{
    int v1;
    Float64 v16;
    bool v13 = !a1;
    if (!v13) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSString *path = [a1 path];
        BOOL v4 = [defaultManager fileExistsAtPath:path];
        v13 = !v4;
    }
    if (v13) {
        v1 = 0;
        if (a2 != 0) {
            *(a2) = @"file does not exist";
        }
    } else {
        NSFileManager *defaultManager2 = [NSFileManager defaultManager];
        NSString *path2 = [a1 path];
        NSError *error = nil;
        NSDictionary<NSFileAttributeKey, id> *v8 = [defaultManager2 attributesOfItemAtPath:path2 error:&error];
        id v10 = [v8 objectForKeyedSubscript:NSFileSize];
        unsigned long unsignedLongLongValue = [v10 unsignedLongLongValue];
        if (error != nil || unsignedLongLongValue >> 14 == 0) {
            if (!a2) {
                v1 = 0;
            } else {
                NSString *v12 = [NSString stringWithFormat:@"file is too small (%llu bytes; error=%@)", unsignedLongLongValue, error];
                v1 = 0;
                *(a2) = v12;
            }
        } else {
            AVURLAsset *v14 = [AVURLAsset URLAssetWithURL:a1 options:nil];
            if (!v14) {
                v16 = 0.0;
            } else {
                CMTime duration = [v14 duration];
                v16 = 0.0;
                if ((duration.flags & (kCMTimeFlags_Valid | kCMTimeFlags_PositiveInfinity | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite)) == kCMTimeFlags_Valid) {
                    v16 = CMTimeGetSeconds([v14 duration]);
                }
            }
            NSArray<AVAssetTrack *> *v18 = [v14 tracksWithMediaType:AVMediaTypeVideo];
            NSUInteger count = [v18 count];
            if (!count || !isfinite(v16) || v16 < 0.1) {
                if (!a2) {
                    v1 = 0;
                } else {
                    NSString *v21 = [NSString stringWithFormat:@"missing video frames (hasVideo=%d duration=%.3f)", count != 0, v16];
                    v1 = 0;
                    *(a2) = v21;
                }
            } else {
                v1 = 1;
            }
        }
    }
    return v1;
}


BOOL -[JWRRecorderManager finalizeStagedVideoAtURL:recovered:finalURL:](NSURL *a1, bool a2, NSURL **a3)
{
    BOOL v1;
    if (!a1) {
        return NO;
    }
    NSFileManager *defaultManager3 = [NSFileManager defaultManager];
    NSString *path4 = [a1 path];
    if (![defaultManager3 fileExistsAtPath:path4]) {
        v1 = NO;
    } else {
        NSString *v5 = nil;
        if (![self validateMovieAtURL:a1 reason:&v5]) {
            NSFileManager *defaultManager5 = [NSFileManager defaultManager];
            NSString *path7 = [a1 path];
            NSDictionary<NSFileAttributeKey, id> *v10 = [defaultManager5 attributesOfItemAtPath:path7 error:nil];
            id v11 = [v10 objectForKey:NSFileSize];
            unsigned long unsignedLongLongValue = [v11 unsignedLongLongValue];
            if (unsignedLongLongValue >> 14 != 0) {
                NSString *path = [a1 path];
                JWRLog(@"retained nontrivial invalid staged movie for manual recovery path=%@ bytes=%llu reason=%@", path, unsignedLongLongValue, v5);
            } else {
                NSFileManager *defaultManager = [NSFileManager defaultManager];
                NSError *error = nil;
                [defaultManager removeItemAtURL:a1 error:&error];
                NSString *path2 = [a1 path];
                JWRLog(@"discarded header-only staged movie path=%@ bytes=%llu reason=%@ removeError=%@", path2, unsignedLongLongValue, v5, error);
            }
            v1 = NO;
        } else {
            NSURL *v14 = [self finalURLForStagedURL:a1 recovered:a2];
            NSFileManager *defaultManager2 = [NSFileManager defaultManager];
            NSString *path3 = [v14 path];
            if ([defaultManager2 fileExistsAtPath:path3]) {
                NSURL *URLByDeletingPathExtension = [v14 URLByDeletingPathExtension];
                NSString *lastPathComponent = [URLByDeletingPathExtension lastPathComponent];
                NSURL *URLByDeletingLastPathComponent = [v14 URLByDeletingLastPathComponent];
                NSUUID *UUID = [NSUUID UUID];
                NSString *UUIDString = [UUID UUIDString];
                NSString *pathComponent = [NSString stringWithFormat:@"%@_%@.mov", lastPathComponent, UUIDString];
                NSURL *v28 = [URLByDeletingLastPathComponent URLByAppendingPathComponent:pathComponent];
                v14 = v28;
            }
            NSFileManager *defaultManager4 = [NSFileManager defaultManager];
            NSError *error2 = nil;
            v1 = [defaultManager4 moveItemAtURL:a1 toURL:v14 error:&error2];
            NSString *path5 = [a1 path];
            NSString *path6 = [v14 path];
            JWRLog(@"video finalize staged=%@ final=%@ moved=%d error=%@", path5, path6, v1, error2);
            if (a3 != 0 && v1) {
                *(a3) = v14;
            }
        }
    }
    return v1;
}


void -[JWRRecorderManager recoverStagedVideosIfNeeded](void)
{
    CMTime v46;
    if ([self recoveryScanned]) {
        return;
    }
    [self setRecoveryScanned:YES];
    NSString *outputDirectory = [self outputDirectory];
    NSString *object = [outputDirectory stringByAppendingPathComponent:@".inprogress"];
    NSString *inProgressDirectory = [self inProgressDirectory];
    NSMutableOrderedSet<NSString *> *v4 = [NSMutableOrderedSet orderedSetWithObject:inProgressDirectory];
    [v4 addObject:object];
    NSString *v9 = NSFileSize;
    for (NSString *v13 in v4) {
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSArray<NSString *> *v15 = [defaultManager contentsOfDirectoryAtPath:v13 error:nil];
        for (NSString *v22 in v15) {
            NSString *pathExtension = [v22 pathExtension];
            NSString *lowercaseString = [pathExtension lowercaseString];
            if ([lowercaseString isEqualToString:@"mov"]) {
                NSString *v26 = [v13 stringByAppendingPathComponent:v22];
                NSURL *URL = [NSURL fileURLWithPath:v26];
                AVURLAsset *v28 = [AVURLAsset URLAssetWithURL:URL options:nil];
                bool v32 = false;
                if ([v28 isPlayable]) {
                    if (!v28) {
                        v32 = false;
                    } else {
                        CMTime duration = [v28 duration];
                        if ((duration.flags & (kCMTimeFlags_Valid | kCMTimeFlags_PositiveInfinity | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite)) == kCMTimeFlags_Valid) {
                            CMTime duration2 = [v28 duration];
                            Float64 v31 = CMTimeGetSeconds(duration2);
                            v32 = v31 > 0.05;
                        }
                    }
                }
                NSFileManager *defaultManager2 = [NSFileManager defaultManager];
                NSString *path = [URL path];
                NSDictionary<NSFileAttributeKey, id> *v35 = [defaultManager2 attributesOfItemAtPath:path error:nil];
                id v36 = [v35 objectForKeyedSubscript:v9];
                if (v28 != nil) {
                    v46 = [v28 duration];
                } else {
                    v46 = (CMTime){0};
                }
                JWRLog(@"recovery scan directory=%@ file=%@ bytes=%@ playable=%d duration=%.3f", v13, v22, v36, v32, CMTimeGetSeconds(v46));
                if (v32) {
                    NSURL *v37 = nil;
                    [self finalizeStagedVideoAtURL:URL recovered:YES finalURL:&v37];
                } else {
                    id v38 = [v35 objectForKeyedSubscript:v9];
                    unsigned long unsignedLongLongValue = [v38 unsignedLongLongValue];
                    if (unsignedLongLongValue >> 14 == 0) {
                        NSFileManager *defaultManager3 = [NSFileManager defaultManager];
                        NSError *error = nil;
                        [defaultManager3 removeItemAtURL:URL error:&error];
                        NSString *path2 = [URL path];
                        JWRLog(@"removed header-only staged movie path=%@ bytes=%llu error=%@", path2, unsignedLongLongValue, error);
                    } else {
                        NSString *path3 = [URL path];
                        JWRLog(@"retained nontrivial staged movie for manual recovery path=%@ bytes=%llu", path3, unsignedLongLongValue);
                    }
                }
            }
        }
    }
}


void -[JWRRecorderManager recoverPendingRecordings](void)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        [self recoverStagedVideosIfNeeded];
    });
}


AVCaptureDevice *-[JWRRecorderManager camera](void)
{
    JWRPreferences *shared = [JWRPreferences shared];
    long v1 = [shared cameraPosition];
    double zoom = [shared zoom];
    v1 = (v1 == 1) ? 2 : 1;
    NSString *v3 = AVCaptureDeviceTypeBuiltInUltraWideCamera;
    NSString *v4 = AVCaptureDeviceTypeBuiltInWideAngleCamera;
    NSString *v5 = (zoom < 1.0) ? v3 : AVCaptureDeviceTypeBuiltInWideAngleCamera;
    NSString *v6 = AVMediaTypeVideo;
    AVCaptureDevice *v7 = [AVCaptureDevice defaultDeviceWithDeviceType:v5 mediaType:AVMediaTypeVideo position:v1];
    if (!v7) {
        if (v5 == v3) {
            JWRLog(@"requested 0.5x camera is unsupported; falling back to the 1x camera");
            v7 = [AVCaptureDevice defaultDeviceWithDeviceType:v4 mediaType:v6 position:v1];
        }
        if (v5 != v3 || (v5 == v3 && !v7)) {
            v7 = [AVCaptureDevice defaultDeviceWithMediaType:v6];
        }
    }
    return v7;
}


CMVideoDimensions -[JWRRecorderManager requestedVideoDimensions](void)
{
    JWRPreferences *shared = [JWRPreferences shared];
    long videoQuality = [shared videoQuality];
    if ((unsigned long)(videoQuality + 1) > 3) {
        return (CMVideoDimensions){1920, 1080};
    }
    long v2 = (&qword_10d18)[videoQuality + 1];
    unsigned long packed_result1 = (&qword_10d38)[videoQuality + 1] | v2;
    return (CMVideoDimensions){(int32_t)packed_result1, (int32_t)(packed_result1 >> 32)};
}


void -[JWRRecorderManager configureFormatForCamera:error:](AVCaptureDevice *a1, NSError **a2)
{
    long v34;
    CMVideoDimensions requestedVideoDimensions = [self requestedVideoDimensions];
    JWRPreferences *shared = [JWRPreferences shared];
    long v3 = [shared fps];
    if (v3 <= 1) {
        v3 = 1;
    }
    NSArray<AVCaptureDeviceFormat *> *obj = [a1 formats];
    AVFrameRateRange *v9 = nil;
    AVCaptureDeviceFormat *v8 = nil;
    int32_t v10 = requestedVideoDimensions.height;
    double v11 = (double)(unsigned long)v3;
    long v13 = requestedVideoDimensions.width * requestedVideoDimensions.height;
    long v14 = -9223372036854775808;
    for (AVCaptureDeviceFormat *v19 in obj) {
        CMVideoDimensions v20 = CMVideoFormatDescriptionGetDimensions([v19 formatDescription]);
        NSArray<AVFrameRateRange *> *videoSupportedFrameRateRanges = [v19 videoSupportedFrameRateRanges];
        long v25 = v20.width * v20.height;
        long v26 = v25 - v13;
        long v30 = ((((v20.height == v10) ? v20.width == requestedVideoDimensions.width && v20.height == requestedVideoDimensions.height : 0) == 1) ? 1000000000000 : 0) - ((v25 < v13) ? -v26 : v26);
        for (AVFrameRateRange *v32 in videoSupportedFrameRateRanges) {
            Float64 minFrameRate = [v32 minFrameRate];
            if (minFrameRate + -0.01 > v11) {
                v34 = 0;
            } else {
                Float64 maxFrameRate = [v32 maxFrameRate];
                v34 = (0.01 + maxFrameRate >= v11) ? 100000000000 : 0;
            }
            Float64 maxFrameRate2 = [v32 maxFrameRate];
            long v37 = v30 + v34 + (long)(maxFrameRate2 * 1000.0);
            if (v37 > v14) {
                v14 = v37;
                v8 = v19;
                v9 = v32;
            }
        }
    }
    if (v8 && v9) {
        [a1 setActiveFormat:v8];
        Float64 minFrameRate2 = [v9 minFrameRate];
        double v39 = (minFrameRate2 > v11) ? minFrameRate2 : v11;
        Float64 maxFrameRate3 = [v9 maxFrameRate];
        double v41 = (v39 < maxFrameRate3) ? v39 : maxFrameRate3;
        CMTime v42 = CMTimeMake(1000, (long)round(v41 * 1000.0));
        [a1 setActiveVideoMinFrameDuration:v42];
        [a1 setActiveVideoMaxFrameDuration:v42];
        CMVideoDimensions v44 = CMVideoFormatDescriptionGetDimensions([v8 formatDescription]);
        Float64 minFrameRate3 = [v9 minFrameRate];
        Float64 maxFrameRate4 = [v9 maxFrameRate];
        JWRLog(@"camera format requested=%dx%d@%.0f actual=%dx%d@%.2f supportedRange=%.2f-%.2f", requestedVideoDimensions.width, v10, v11, v44.width, v44.height, v41, minFrameRate3, maxFrameRate4);
        return;
    }
    JWRLog(@"no camera format available");
}


bool -[JWRRecorderManager prepareSession:](bool a1)
{
    int v11;
    uint32_t v12;
    int v18;
    int v7;
    if (![self session]) {
        [self recoverStagedVideosIfNeeded];
        JWRLog(@"preparing capture session withAudio=%d", a1);
        if (a1) {
            NSProcessInfo *processInfo = [NSProcessInfo processInfo];
            NSString *processName = [processInfo processName];
            if ([processName isEqualToString:@"SpringBoard"]) {
                NSProcessInfo *processInfo2 = [NSProcessInfo processInfo];
                if (processInfo2) {
                    NSOperatingSystemVersion operatingSystemVersion = [processInfo2 operatingSystemVersion];
                    if (operatingSystemVersion.majorVersion >= 18) {
                        int token = 0;
                        if (notify_register_check("com.jimwas.recorder.camera-trace/arm-once", &v7) != 0 || notify_register_check("com.jimwas.recorder.camera-trace/armed", &token) != 0) {
                            if (v7 != 0) {
                                notify_cancel(v7);
                            }
                            if (token != 0) {
                                notify_cancel(token);
                            }
                            JWRLog(@"camera service arm notification registration failed");
                        } else {
                            int check = 0;
                            notify_check(token, &check);
                            pid_t v9 = getpid();
                            notify_set_state(v7, v9);
                            notify_post("com.jimwas.recorder.camera-trace/arm-once");
                            int v10 = 0;
                            long v3 = 0;
                            if (!notify_check(token, &v10) && v10 != 0) {
                                v3 = 1;
                            }
                            if (!v3) {
                                v11 = 50;
                                do {
                                    usleep(10000);
                                    v11--;
                                    if (!v11) {
                                        v3 = 2;
                                        break;
                                    }
                                    v10 = 0;
                                    v12 = notify_check(token, &v10);
                                } while (v12 != 0 || !v10);
                            }
                            if (v3 != 2) {
                                v11 = 1;
                            }
                            notify_cancel(v7);
                            notify_cancel(token);
                            JWRLog(@"camera service arm acknowledged=%d pid=%d", v11, getpid());
                        }
                    }
                }
            }
        }
        AVCaptureSession *obj = [AVCaptureSession new];
        [obj setSessionPreset:AVCaptureSessionPresetInputPriority];
        AVCaptureDevice *camera = [self camera];
        NSError *v15 = nil;
        AVCaptureDeviceInput *v16 = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&v15];
        if (!v16) {
            JWRLog(@"camera input failed error=%@", v15);
            v18 = 0;
        } else if (![obj canAddInput:v16]) {
            JWRLog(@"camera input failed error=%@", v15);
            v18 = 0;
        } else {
            [obj addInput:v16];
            NSError *v19 = v15;
            if (![camera lockForConfiguration:&v19]) {
                JWRLog(@"camera configuration lock failed error=%@", v19);
            } else {
                NSError *v25 = v19;
                [self configureFormatForCamera:camera error:&v25];
                AVCaptureDeviceType deviceType = [camera deviceType];
                if (deviceType == AVCaptureDeviceTypeBuiltInWideAngleCamera) {
                    AVCaptureDeviceFormat *activeFormat = [camera activeFormat];
                    CGFloat videoMaxZoomFactor = [activeFormat videoMaxZoomFactor];
                    JWRPreferences *shared = [JWRPreferences shared];
                    double zoom = [shared zoom];
                    [camera setVideoZoomFactor:fmax((videoMaxZoomFactor < zoom) ? videoMaxZoomFactor : zoom, 1.0)];
                }
                [camera unlockForConfiguration];
            }
            if (a1) {
                AVCaptureDevice *v22 = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
                AVCaptureDeviceInput *v24 = [AVCaptureDeviceInput deviceInputWithDevice:v22 error:nil];
                if (!v24) {
                    JWRLog(@"microphone input unavailable");
                } else if (![obj canAddInput:v24]) {
                    JWRLog(@"microphone input unavailable");
                } else {
                    [obj addInput:v24];
                }
            }
            AVCaptureMovieFileOutput *v32 = [AVCaptureMovieFileOutput new];
            [self setMovieOutput:v32];
            CMTime v33 = CMTimeMakeWithSeconds(2.0, 600);
            AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
            [movieOutput setMovieFragmentInterval:v33];
            AVCaptureMovieFileOutput *movieOutput2 = [self movieOutput];
            if ([obj canAddOutput:movieOutput2]) {
                AVCaptureMovieFileOutput *movieOutput3 = [self movieOutput];
                [obj addOutput:movieOutput3];
            }
            AVCapturePhotoOutput *v38 = [AVCapturePhotoOutput new];
            [self setPhotoOutput:v38];
            AVCapturePhotoOutput *photoOutput = [self photoOutput];
            if ([obj canAddOutput:photoOutput]) {
                AVCapturePhotoOutput *photoOutput2 = [self photoOutput];
                [obj addOutput:photoOutput2];
            }
            [self setSession:obj];
            __weak JWRRecorderManager *v5 = self;
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
            id<NSObject> v46 = [defaultCenter addObserverForName:AVCaptureSessionRuntimeErrorNotification object:obj queue:nil usingBlock:^void(NSNotification *arg1) {
                NSDictionary *userInfo = [arg1 userInfo];
                id v60 = [userInfo objectForKeyedSubscript:AVCaptureSessionErrorKey];
                JWRLog(@"capture runtime error=%@", v60);
                NSObject<OS_dispatch_queue> *queue = [v5 queue];
                void (^block)(void) = ^void(void) {
                    bool desiredVideoRecording = [v5 desiredVideoRecording];
                    if (!desiredVideoRecording) {
                        [v5 teardownCaptureSession];
                    } else {
                        NSString *v67 = [NSString stringWithFormat:@"runtime error %@", v60];
                        [v5 requestVideoRecovery:v67];
                    }
                };
                dispatch_async(queue, block);
            }];
            [self setSessionErrorObserver:v46];
            NSNotificationCenter *defaultCenter2 = [NSNotificationCenter defaultCenter];
            id<NSObject> v48 = [defaultCenter2 addObserverForName:AVCaptureSessionWasInterruptedNotification object:obj queue:nil usingBlock:^void(NSNotification *arg1) {
                NSDictionary *userInfo = [arg1 userInfo];
                id v69 = [userInfo objectForKeyedSubscript:AVCaptureSessionInterruptionReasonKey];
                NSDictionary *userInfo2 = [arg1 userInfo];
                JWRLog(@"capture interrupted reason=%@ userInfo=%@", v69, userInfo2);
            }];
            [self setSessionInterruptedObserver:v48];
            NSNotificationCenter *defaultCenter3 = [NSNotificationCenter defaultCenter];
            id<NSObject> v52 = [defaultCenter3 addObserverForName:AVCaptureSessionInterruptionEndedNotification object:obj queue:nil usingBlock:^void(NSNotification *arg1) {
                JWRLog(@"capture interruption ended");
                NSObject<OS_dispatch_queue> *queue = [v5 queue];
                void (^block)(void) = ^void(void) {
                    if ([v5 desiredVideoRecording]) {
                        AVCaptureSession *session = [v5 session];
                        if ([session isRunning]) {
                            AVCaptureMovieFileOutput *movieOutput = [v5 movieOutput];
                            BOOL isRecording = [movieOutput isRecording];
                            if (isRecording) {
                                return;
                            }
                        }
                        [v5 requestVideoRecovery:@"capture interruption ended without active recording"];
                    }
                };
                dispatch_async(queue, block);
            }];
            [self setSessionInterruptionEndedObserver:v52];
            if (sub_d300(2, 16, 0, 0) != 0) {
                BOOL isMultitaskingCameraAccessSupported = [obj isMultitaskingCameraAccessSupported];
                BOOL isMultitaskingCameraAccessEnabled = [obj isMultitaskingCameraAccessEnabled];
                JWRLog(@"multitasking camera supported=%d enabled=%d", isMultitaskingCameraAccessSupported, isMultitaskingCameraAccessEnabled);
                if ([obj isMultitaskingCameraAccessSupported]) {
                    [obj setMultitaskingCameraAccessEnabled:YES];
                    BOOL isMultitaskingCameraAccessEnabled2 = [obj isMultitaskingCameraAccessEnabled];
                    JWRLog(@"multitasking camera enabled now=%d", isMultitaskingCameraAccessEnabled2);
                }
            }
            [obj startRunning];
            BOOL isRunning = [obj isRunning];
            BOOL isInterrupted = [obj isInterrupted];
            JWRLog(@"capture startRunning returned running=%d interrupted=%d", isRunning, isInterrupted);
            v18 = 1;
        }
    } else {
        JWRLog(@"reusing capture session");
        v18 = 1;
    }
    return v18;
}


void -[JWRRecorderManager feedbackNotification:](NSString *a1)
{
    JWRPreferences *shared = [JWRPreferences shared];
    if ([shared haptics]) {
        notify_post([a1 UTF8String]);
    }
    notify_post([@"com.jimwas.recorder/stateChanged" UTF8String]);
}


void -[JWRRecorderManager failureFeedback:](NSString *a1)
{
    JWRLog(@"recording health failure: %@", a1);
    [self feedbackNotification:@"com.jimwas.recorder/hapticFailure"];
}


void -[JWRRecorderManager cancelHeartbeatTimer](void)
{
    if (![self heartbeatTimer]) {
        return;
    }
    NSObject<OS_dispatch_source> *source = [self heartbeatTimer];
    dispatch_source_cancel(source);
    [self setHeartbeatTimer:nil];
}


void -[JWRRecorderManager scheduleHeartbeatTimer](void)
{
    [self cancelHeartbeatTimer];
    JWRPreferences *shared = [JWRPreferences shared];
    long recordingHeartbeatInterval = [shared recordingHeartbeatInterval];
    if (recordingHeartbeatInterval < 1 || (![self desiredVideoRecording] && ![self desiredAudioRecording])) {
        return;
    }
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    uint64_t v5 = recordingHeartbeatInterval * NSEC_PER_SEC;
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, v5), v5, NSEC_PER_SEC);
    __weak JWRRecorderManager *v6 = self;
    dispatch_source_set_event_handler(source, ^void(void) {
        BOOL v10;
        BOOL v12;
        if (![v6 desiredVideoRecording]) {
            v10 = NO;
        } else {
            AVCaptureSession *session = [v6 session];
            if (![session isRunning]) {
                v10 = NO;
            } else {
                AVCaptureMovieFileOutput *movieOutput = [v6 movieOutput];
                v10 = [movieOutput isRecording];
            }
        }
        if (![v6 desiredAudioRecording]) {
            v12 = NO;
        } else {
            AVAudioRecorder *audioRecorder = [v6 audioRecorder];
            v12 = [audioRecorder isRecording];
        }
        if (v12 || v10) {
            JWRLog(@"recording heartbeat healthy video=%d audio=%d", v10, v12);
            [v6 feedbackNotification:@"com.jimwas.recorder/hapticHeartbeat"];
        }
    });
    [self setHeartbeatTimer:source];
    dispatch_resume(source);
    JWRLog(@"scheduled recording heartbeat every %ld seconds", recordingHeartbeatInterval);
}


void -[JWRRecorderManager cancelTrialTimerIfIdle](void)
{
    if ([self desiredVideoRecording] || [self desiredAudioRecording]) {
        return;
    }
    if (![self trialTimer]) {
        return;
    }
    NSObject<OS_dispatch_source> *source = [self trialTimer];
    dispatch_source_cancel(source);
    [self setTrialTimer:nil];
}


void -[JWRRecorderManager scheduleTrialTimerIfNeeded](void)
{
    if (![self trialTimer]) {
        if (![self desiredVideoRecording] && ![self desiredAudioRecording]) {
            return;
        }
        NSObject<OS_dispatch_queue> *queue = [self queue];
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), 5 * NSEC_PER_SEC, NSEC_PER_SEC);
        __weak JWRRecorderManager *v4 = self;
        dispatch_source_set_event_handler(source, ^void(void) {
            if (v4 != nil && JWRTrialRemainingSeconds() <= 0.0) {
                JWRLog(@"trial expired; finalizing active recordings");
                if ([v4 desiredVideoRecording]) {
                    [v4 setDesiredVideoRecording:NO];
                    [v4 setRecoveryInProgress:NO];
                    [v4 setRollingSegment:NO];
                    unsigned long recordingGeneration = [v4 recordingGeneration];
                    [v4 setRecordingGeneration:recordingGeneration + 1];
                    [v4 cancelSegmentTimer];
                    [v4 cancelWatchdogTimer];
                    AVCaptureMovieFileOutput *movieOutput = [v4 movieOutput];
                    BOOL isRecording = [movieOutput isRecording];
                    if (!isRecording) {
                        [v4 teardownCaptureSession];
                    } else {
                        AVCaptureMovieFileOutput *movieOutput2 = [v4 movieOutput];
                        [movieOutput2 stopRecording];
                    }
                }
                if ([v4 desiredAudioRecording]) {
                    [v4 setDesiredAudioRecording:NO];
                    AVAudioRecorder *audioRecorder = [v4 audioRecorder];
                    [audioRecorder stop];
                    [v4 setAudioRecording:NO];
                }
                [v4 cancelHeartbeatTimer];
                [v4 cancelTrialTimerIfIdle];
                [v4 failureFeedback:@"seven-day trial expired; install the full package to continue recording"];
            }
        });
        [self setTrialTimer:source];
        dispatch_resume(source);
        return;
    }
}


void -[JWRRecorderManager refreshHealthMonitoring](void)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        [self scheduleHeartbeatTimer];
        if (![self desiredVideoRecording]) {
            return;
        }
        [self scheduleWatchdogTimer];
        [self scheduleSegmentTimerIfNeeded];
    });
}


void -[JWRRecorderManager cancelWatchdogTimer](void)
{
    if (![self watchdogTimer]) {
        return;
    }
    NSObject<OS_dispatch_source> *source = [self watchdogTimer];
    dispatch_source_cancel(source);
    [self setWatchdogTimer:nil];
}


void -[JWRRecorderManager scheduleWatchdogTimer](void)
{
    [self cancelWatchdogTimer];
    if (![self desiredVideoRecording]) {
        return;
    }
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), 5 * NSEC_PER_SEC, NSEC_PER_SEC / 2);
    __weak JWRRecorderManager *v2 = self;
    dispatch_source_set_event_handler(source, ^void(void) {
        if (v2 != nil && [v2 desiredVideoRecording] && ![v2 rollingSegment] && ![v2 recoveryInProgress]) {
            AVCaptureSession *session = [v2 session];
            if (![session isRunning] || ![[v2 movieOutput] isRecording]) {
                AVCaptureSession *session2 = [v2 session];
                BOOL isRunning = [session2 isRunning];
                AVCaptureMovieFileOutput *movieOutput = [v2 movieOutput];
                BOOL isRecording = [movieOutput isRecording];
                NSString *v6 = [NSString stringWithFormat:@"watchdog detected session=%d output=%d", isRunning, isRecording];
                [v2 requestVideoRecovery:v6];
            }
        }
    });
    [self setWatchdogTimer:source];
    dispatch_resume(source);
    JWRLog(@"video watchdog scheduled every 5 seconds");
}


void -[JWRRecorderManager teardownCaptureSession](void)
{
    [self cancelSegmentTimer];
    AVCaptureSession *session = [self session];
    if ([session isRunning]) {
        AVCaptureSession *session2 = [self session];
        [session2 stopRunning];
    }
    id sessionErrorObserver = [self sessionErrorObserver];
    if (sessionErrorObserver != nil) {
        NSNotificationCenter *defaultCenter2 = [NSNotificationCenter defaultCenter];
        id sessionErrorObserver2 = [self sessionErrorObserver];
        [defaultCenter2 removeObserver:sessionErrorObserver2];
    }
    id sessionInterruptedObserver = [self sessionInterruptedObserver];
    if (sessionInterruptedObserver != nil) {
        NSNotificationCenter *defaultCenter3 = [NSNotificationCenter defaultCenter];
        id sessionInterruptedObserver2 = [self sessionInterruptedObserver];
        [defaultCenter3 removeObserver:sessionInterruptedObserver2];
    }
    id sessionInterruptionEndedObserver2 = [self sessionInterruptionEndedObserver];
    if (sessionInterruptionEndedObserver2 != nil) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        id sessionInterruptionEndedObserver = [self sessionInterruptionEndedObserver];
        [defaultCenter removeObserver:sessionInterruptionEndedObserver];
    }
    [self setSessionErrorObserver:nil];
    [self setSessionInterruptedObserver:nil];
    [self setSessionInterruptionEndedObserver:nil];
    [self setSession:nil];
    [self setMovieOutput:nil];
    [self setPhotoOutput:nil];
    [self setVideoRecording:NO];
}


void -[JWRRecorderManager cancelSegmentTimer](void)
{
    if (![self segmentTimer]) {
        return;
    }
    NSObject<OS_dispatch_source> *source = [self segmentTimer];
    dispatch_source_cancel(source);
    [self setSegmentTimer:nil];
}


void -[JWRRecorderManager scheduleSegmentTimerIfNeeded](void)
{
    [self cancelSegmentTimer];
    JWRPreferences *shared = [JWRPreferences shared];
    long videoSegmentDurationSeconds = [shared videoSegmentDurationSeconds];
    if (videoSegmentDurationSeconds < 1 || ![self videoRecording]) {
        return;
    }
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(source, dispatch_time(DISPATCH_TIME_NOW, videoSegmentDurationSeconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, NSEC_PER_SEC / 10);
    __weak JWRRecorderManager *v4 = self;
    dispatch_source_set_event_handler(source, ^void(void) {
        if (v4 != nil && [v4 videoRecording]) {
            AVCaptureMovieFileOutput *movieOutput2 = [v4 movieOutput];
            BOOL isRecording = [movieOutput2 isRecording];
            if (isRecording) {
                NSURL *videoURL = [v4 videoURL];
                NSString *lastPathComponent = [videoURL lastPathComponent];
                JWRLog(@"custom segment boundary reached after %ld seconds; finalizing %@", videoSegmentDurationSeconds, lastPathComponent);
                [v4 setRollingSegment:YES];
                AVCaptureMovieFileOutput *movieOutput = [v4 movieOutput];
                [movieOutput stopRecording];
            }
        }
    });
    [self setSegmentTimer:source];
    dispatch_resume(source);
    JWRLog(@"scheduled next video segment boundary in %ld seconds", videoSegmentDurationSeconds);
}


AVMutableMetadataItem *-[JWRRecorderManager metadataItem:value:](NSString *a1, NSString *a2)
{
    AVMutableMetadataItem *metadataItem = [AVMutableMetadataItem metadataItem];
    [metadataItem setIdentifier:a1];
    [metadataItem setValue:a2];
    return metadataItem;
}


void -[JWRRecorderManager applyVideoMetadata](void)
{
    NSMutableArray *array = [NSMutableArray array];
    NSISO8601DateFormatter *v1 = [NSISO8601DateFormatter new];
    NSDate *date2 = [NSDate date];
    NSString *v3 = [v1 stringFromDate:date2];
    AVMutableMetadataItem *v4 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataCreationDate value:v3];
    [array addObject:v4];
    AVMutableMetadataItem *v5 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataMake value:@"Apple"];
    [array addObject:v5];
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *model = [currentDevice model];
    AVMutableMetadataItem *v8 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataModel value:model];
    [array addObject:v8];
    AVMutableMetadataItem *v9 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataSoftware value:@"JimWas Recorder 1.9.3"];
    [array addObject:v9];
    JWRPreferences *shared = [JWRPreferences shared];
    if ([shared embedLocationMetadata]) {
        NSDictionary *v12 = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Documents/JimWasRecorder/location.plist"];
        NSDate *date = [NSDate date];
        NSTimeInterval timeIntervalSince1970 = [date timeIntervalSince1970];
        id v15 = [v12 objectForKeyedSubscript:@"timestamp"];
        double doubleValue = [v15 doubleValue];
        double v17 = timeIntervalSince1970 - doubleValue;
        if (!v12 || v17 < 0.0 || v17 >= 900.0) {
            JWRLog(@"GPS metadata enabled but no fresh cached location is available age=%.1fs", v17);
        } else {
            id v18 = [v12 objectForKeyedSubscript:@"latitude"];
            double doubleValue2 = [v18 doubleValue];
            id v20 = [v12 objectForKeyedSubscript:@"longitude"];
            double doubleValue3 = [v20 doubleValue];
            id v22 = [v12 objectForKeyedSubscript:@"altitude"];
            double doubleValue4 = [v22 doubleValue];
            NSString *v24 = [NSString stringWithFormat:@"%+.6f%+.6f%+.1f/", doubleValue2, doubleValue3, doubleValue4];
            AVMutableMetadataItem *v25 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataLocationISO6709 value:v24];
            [array addObject:v25];
            id v26 = [v12 objectForKeyedSubscript:@"horizontalAccuracy"];
            AVMutableMetadataItem *v29 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataLocationHorizontalAccuracyInMeters value:(!v26) ? @0 : v26];
            [array addObject:v29];
            JWRLog(@"embedding video GPS metadata %@ age=%.1fs", v24, v17);
        }
    }
    AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
    [movieOutput setMetadata:array];
}


void -[JWRRecorderManager scheduleHealthyRecordingConfirmationForOutput:](AVCaptureMovieFileOutput *a1)
{
    unsigned long v1 = [self recordingGeneration] + 1;
    [self setRecordingGeneration:v1];
    __weak JWRRecorderManager *v2 = self;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_after(when, queue, ^void(void) {
        CMTime recordedDuration;
        Float64 v20;
        CMTime recordedDuration2;
        if (v2 != nil) {
            unsigned long recordingGeneration = [v2 recordingGeneration];
            if (v1 == recordingGeneration && [v2 desiredVideoRecording]) {
                AVCaptureMovieFileOutput *movieOutput = [v2 movieOutput];
                if (a1 == movieOutput) {
                    if (!a1) {
                        recordedDuration = (CMTime){0};
                        v20 = 0.0;
                    } else {
                        recordedDuration = [a1 recordedDuration];
                        v20 = 0.0;
                        if ((recordedDuration.flags & (kCMTimeFlags_Valid | kCMTimeFlags_PositiveInfinity | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite)) == kCMTimeFlags_Valid) {
                            if (!a1) {
                                recordedDuration2 = (CMTime){0};
                            } else {
                                recordedDuration2 = [a1 recordedDuration];
                            }
                            v20 = CMTimeGetSeconds(recordedDuration2);
                        }
                    }
                    AVCaptureSession *session = [v2 session];
                    if (![session isRunning]) {
blk_9134:
blk_913c:
                        AVCaptureSession *session2 = [v2 session];
                        BOOL isRunning = [session2 isRunning];
                        BOOL isRecording = [a1 isRecording];
                        long recoveryAttempts = [v2 recoveryAttempts];
                        JWRLog(@"video health confirmation pending session=%d output=%d duration=%.3f failures=%ld", isRunning, isRecording, v20, recoveryAttempts);
                    } else {
                        BOOL isRecording2 = [a1 isRecording];
                        bool v15 = isfinite(v20);
                        if (!isRecording2 || !v15) {
                            goto blk_9134;
                        }
                        if (v20 < 1.0) {
                            goto blk_913c;
                        }
                        long recoveryAttempts2 = [v2 recoveryAttempts];
                        [v2 setRecoveryAttempts:0];
                        JWRLog(@"video recording confirmed healthy duration=%.3f previousRecoveryFailures=%ld", v20, recoveryAttempts2);
                    }
                }
            }
        }
    });
}


void -[JWRRecorderManager beginVideoRecording](void)
{
    if (![self desiredVideoRecording]) {
        return;
    }
    if ((JWRTrialCanBeginCapture() & 1) == 0) {
        [self setDesiredVideoRecording:NO];
        [self setRecoveryInProgress:NO];
        [self cancelTrialTimerIfIdle];
        [self failureFeedback:@"seven-day trial expired; install the full package to continue recording"];
        return;
    }
    if (![self prepareSession:YES]) {
        [self failureFeedback:@"video start aborted because the capture session is unavailable"];
        [self retryVideoRecoveryAfterDelay];
        return;
    }
    [self prepareVideoURLs];
    [self applyVideoMetadata];
    bool recoveryInProgress = [self recoveryInProgress];
    void (^block)(void) = ^void(void) {
        if (![self desiredVideoRecording]) {
            return;
        }
        AVCaptureSession *v4 = [self session];
        BOOL isRunning = [v4 isRunning];
        if (!isRunning) {
            [self requestVideoRecovery:@"capture session did not become ready"];
            return;
        }
        AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
        NSURL *videoURL = [self videoURL];
        [movieOutput startRecordingToOutputFileURL:videoURL recordingDelegate:self];
        [self setVideoRecording:YES];
        [self setRecoveryInProgress:NO];
        NSURL *videoURL2 = [self videoURL];
        NSString *path = [videoURL2 path];
        JWRLog(@"video+audio recording started url=%@", path);
        AVCaptureMovieFileOutput *movieOutput2 = [self movieOutput];
        [self scheduleHealthyRecordingConfirmationForOutput:movieOutput2];
        [self scheduleSegmentTimerIfNeeded];
        [self scheduleWatchdogTimer];
        [self scheduleHeartbeatTimer];
        [self scheduleTrialTimerIfNeeded];
        if (!recoveryInProgress) {
            [self feedbackNotification:@"com.jimwas.recorder/hapticVideoStarted"];
            return;
        } else {
            JWRLog(@"video watchdog recovery restarted recording");
            return;
        }
    };
    AVCaptureSession *session = [self session];
    if (![session isRunning]) {
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (NSEC_PER_SEC / 4) * 3);
        NSObject<OS_dispatch_queue> *queue = [self queue];
        dispatch_after(when, queue, block);
    } else {
        block();
    }
}


void -[JWRRecorderManager retryVideoRecoveryAfterDelay](void)
{
    if (![self desiredVideoRecording]) {
        return;
    }
    [self setRecoveryInProgress:YES];
    long recoveryAttempts = [self recoveryAttempts];
    [self setRecoveryAttempts:recoveryAttempts + 1];
    long recoveryAttempts2 = [self recoveryAttempts];
    long recoveryAttempts3 = [self recoveryAttempts];
    if (recoveryAttempts2 < 5) {
        double v3 = exp2((double)recoveryAttempts3);
        double v4 = (v3 > 30.0) ? 30.0 : v3;
        unsigned long v5 = [self recordingGeneration] + 1;
        [self setRecordingGeneration:v5];
        long recoveryAttempts4 = [self recoveryAttempts];
        JWRLog(@"video recovery attempt=%ld scheduled in %.1fs", recoveryAttempts4, v4);
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (long)(v4 * 1000000000.0));
        NSObject<OS_dispatch_queue> *queue = [self queue];
        dispatch_after(when, queue, ^void(void) {
            if (![self desiredVideoRecording]) {
                return;
            }
            unsigned long recordingGeneration = [self recordingGeneration];
            if (v5 != recordingGeneration) {
                return;
            }
            [self teardownCaptureSession];
            [self beginVideoRecording];
        });
        return;
    }
    JWRLog(@"video recovery circuit breaker opened after %ld consecutive failures", recoveryAttempts3);
    [self setDesiredVideoRecording:NO];
    [self setRecoveryInProgress:NO];
    [self setRollingSegment:NO];
    unsigned long recordingGeneration = [self recordingGeneration];
    [self setRecordingGeneration:recordingGeneration + 1];
    [self cancelSegmentTimer];
    [self cancelWatchdogTimer];
    [self cancelHeartbeatTimer];
    [self teardownCaptureSession];
    [self failureFeedback:@"recording disabled after repeated camera failures; check debug.log before trying again"];
}


void -[JWRRecorderManager requestVideoRecovery:](NSString *a1)
{
    if ([self desiredVideoRecording] && ![self recoveryInProgress]) {
        [self setRecoveryInProgress:YES];
        [self failureFeedback:a1];
        [self cancelSegmentTimer];
        AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
        if (![movieOutput isRecording]) {
            [self teardownCaptureSession];
            [self retryVideoRecoveryAfterDelay];
        } else {
            JWRLog(@"stopping current movie before watchdog recovery");
            [movieOutput stopRecording];
        }
        dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, 4 * NSEC_PER_SEC);
        NSObject<OS_dispatch_queue> *queue = [self queue];
        dispatch_after(when, queue, ^void(void) {
            if (![self desiredVideoRecording]) {
                return;
            }
            if (![self recoveryInProgress]) {
                return;
            }
            AVCaptureMovieFileOutput *v2 = [self movieOutput];
            if (v2 == movieOutput) {
                JWRLog(@"watchdog recovery stop timed out; forcing capture-session rebuild");
                [self teardownCaptureSession];
                [self retryVideoRecoveryAfterDelay];
                return;
            }
        });
    }
}


void -[JWRRecorderManager toggleVideo](void)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        bool videoRecording = [self videoRecording];
        bool desiredVideoRecording = [self desiredVideoRecording];
        JWRLog(@"toggleVideo current=%d desired=%d", videoRecording, desiredVideoRecording);
        if ([self desiredVideoRecording]) {
            [self setDesiredVideoRecording:NO];
            [self setRecoveryInProgress:NO];
            [self setRollingSegment:NO];
            unsigned long recordingGeneration = [self recordingGeneration];
            [self setRecordingGeneration:recordingGeneration + 1];
            [self cancelSegmentTimer];
            [self cancelWatchdogTimer];
            [self cancelTrialTimerIfIdle];
            AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
            BOOL isRecording = [movieOutput isRecording];
            if (!isRecording) {
                [self teardownCaptureSession];
                [self cancelHeartbeatTimer];
                [self feedbackNotification:@"com.jimwas.recorder/hapticVideoStopped"];
                return;
            }
            AVCaptureMovieFileOutput *movieOutput2 = [self movieOutput];
            [movieOutput2 stopRecording];
            return;
        }
        if ((JWRTrialCanBeginCapture() & 1) == 0) {
            [self failureFeedback:@"seven-day trial expired; install the full package to continue recording"];
            return;
        }
        [self setDesiredVideoRecording:YES];
        [self setRecoveryAttempts:0];
        [self beginVideoRecording];
    });
}


void -[JWRRecorderManager captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:](AVCaptureFileOutput *a1, NSURL *a2, NSArray<AVCaptureConnection *> *a3, NSError *a4)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        BOOL v25;
        bool v6;
        bool v7;
        int v12;
        AVCaptureMovieFileOutput *movieOutput = [self movieOutput];
        if (!a4) {
            v25 = YES;
        } else {
            NSDictionary<NSErrorUserInfoKey, id> *userInfo = [a4 userInfo];
            id v5 = [userInfo objectForKeyedSubscript:AVErrorRecordingSuccessfullyFinishedKey];
            v25 = [v5 boolValue];
        }
        if (a1 == movieOutput) {
            v6 = [self rollingSegment];
            v7 = [self recoveryInProgress];
            [self setRollingSegment:NO];
        } else {
            v7 = false;
            v6 = false;
        }
        NSString *path2 = [a2 path];
        bool desiredVideoRecording = [self desiredVideoRecording];
        JWRLog(@"video segment finished url=%@ error=%@ successful=%d current=%d rolling=%d recovering=%d desired=%d", path2, a4, v25, a1 == movieOutput, v6, v7, desiredVideoRecording);
        if (!v25) {
            v12 = 1;
        } else {
            NSURL *v13 = nil;
            bool v14 = [self finalizeStagedVideoAtURL:a2 recovered:NO finalURL:&v13];
            if (!v14) {
                v12 = 1;
            } else {
                [self handleFinalizedVideoAtURL:v13 context:@"video segment"];
                v12 = 0;
            }
        }
        if (a1 == movieOutput) {
            bool desiredVideoRecording2 = [self desiredVideoRecording];
            if (desiredVideoRecording2 && (v12 || !v25)) {
                NSString *v16 = [NSString stringWithFormat:@"video segment did not finalize error=%@", a4];
                [self failureFeedback:v16];
            }
            bool desiredVideoRecording3 = [self desiredVideoRecording];
            if (!v12 && desiredVideoRecording3 && v25 && v6) {
                [self prepareVideoURLs];
                [self applyVideoMetadata];
                AVCaptureMovieFileOutput *movieOutput2 = [self movieOutput];
                NSURL *videoURL = [self videoURL];
                [movieOutput2 startRecordingToOutputFileURL:videoURL recordingDelegate:self];
                [self setVideoRecording:YES];
                NSURL *videoURL2 = [self videoURL];
                NSString *path = [videoURL2 path];
                JWRLog(@"next crash-safe video+audio segment started url=%@", path);
                AVCaptureMovieFileOutput *movieOutput3 = [self movieOutput];
                [self scheduleHealthyRecordingConfirmationForOutput:movieOutput3];
                [self scheduleSegmentTimerIfNeeded];
            } else if (![self desiredVideoRecording]) {
                [self teardownCaptureSession];
                [self cancelHeartbeatTimer];
                [self cancelTrialTimerIfIdle];
                [self feedbackNotification:@"com.jimwas.recorder/hapticVideoStopped"];
            } else {
                if (!v7) {
                    [self failureFeedback:@"recording stopped unexpectedly; watchdog will restart it"];
                }
                [self teardownCaptureSession];
                [self retryVideoRecoveryAfterDelay];
            }
        }
    });
}


NSError *-[JWRRecorderManager audioVideoError:](NSString *a1)
{
    NSDictionary *v3 = @{NSLocalizedDescriptionKey: (!a1) ? @"Audio video conversion failed." : a1};
    return [NSError errorWithDomain:@"com.jimwas.recorder.audio-video" code:1 userInfo:v3];
}


void -[JWRRecorderManager handleFinalizedVideoAtURL:context:](NSURL *a1, NSString *a2)
{
    NSURL *v0 = a1;
    NSString *v1 = a2;
    if (v0 != nil) {
        JWRPreferences *shared = [JWRPreferences shared];
        long videoStorageMode = [shared videoStorageMode];
        if (!videoStorageMode) {
            NSString *path = [v0 path];
            JWRLog(@"%@ retained in save folder path=%@", v1, path);
        } else {
            PHPhotoLibrary *sharedPhotoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
            [sharedPhotoLibrary performChanges:^void(void) {
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:v0];
            } completionHandler:^void(bool arg1, NSError *arg2) {
                NSObject<OS_dispatch_queue> *queue = [self queue];
                dispatch_async(queue, ^void(void) {
                    JWRLog(@"%@ Photos import completed success=%d photosOnly=%d error=%@", v1, arg1, videoStorageMode == 1, arg2);
                    if (arg1 == 0) {
                        NSString *v13 = [NSString stringWithFormat:@"%@ could not save to Camera Roll; local fallback retained error=%@", v1, arg2];
                        [self failureFeedback:v13];
                        return;
                    }
                    if (videoStorageMode != 1) {
                        return;
                    }
                    NSFileManager *defaultManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    BOOL v14 = [defaultManager removeItemAtURL:v0 error:&error];
                    NSString *v17 = [v0 path];
                    JWRLog(@"%@ Photos-only local cleanup path=%@ removed=%d error=%@", v1, v17, v14, error);
                    if (!v14 && error != nil) {
                        NSString *v16 = [NSString stringWithFormat:@"%@ saved to Camera Roll but local cleanup failed error=%@", v1, error];
                        [self failureFeedback:v16];
                    }
                });
            }];
        }
    }
}


void -[JWRRecorderManager finishAudioVideoConversionAtURL:audioURL:success:error:](NSURL *a1, NSURL *a2, bool a3, NSError *a4)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        if (!a3) {
            if (a1 != nil) {
                NSFileManager *defaultManager = [NSFileManager defaultManager];
                [defaultManager removeItemAtURL:a1 error:nil];
            }
            NSString *path = [a2 path];
            NSString *path2 = [a1 path];
            JWRLog(@"audio video copy failed audio=%@ staged=%@ error=%@", path, path2, a4);
            NSString *v9 = [NSString stringWithFormat:@"audio video copy failed error=%@", a4];
            [self failureFeedback:v9];
            return;
        }
        NSURL *v10 = nil;
        bool v5 = [self finalizeStagedVideoAtURL:a1 recovered:NO finalURL:&v10];
        if (!v5) {
            [self failureFeedback:@"audio video copy could not be finalized"];
        } else {
            NSString *path3 = [a2 path];
            NSString *path4 = [v10 path];
            JWRLog(@"audio video copy finalized audio=%@ video=%@", path3, path4);
            [self handleFinalizedVideoAtURL:v10 context:@"audio video copy"];
        }
    });
}


void -[JWRRecorderManager createVideoCopyForAudioURL:](NSURL *a1)
{
    CMTime v72;
    AVURLAsset *v24;
    CMTime v71;
    NSURL *v0 = a1;
    if (!a1) {
        return;
    }
    AVURLAsset *v1 = [AVURLAsset URLAssetWithURL:v0 options:nil];
    NSString *v2 = AVMediaTypeAudio;
    NSArray<AVAssetTrack *> *v3 = [v1 tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *firstObject2 = [v3 firstObject];
    if (v1 != nil) {
        v72 = [v1 duration];
    } else {
        v72 = (CMTime){0};
    }
    if (!firstObject2 || (v72.flags & (kCMTimeFlags_Valid | kCMTimeFlags_PositiveInfinity | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite)) != kCMTimeFlags_Valid || CMTimeGetSeconds(v72) <= 0.01) {
        NSError *v6 = [self audioVideoError:@"The audio recording has no readable audio track."];
        [self finishAudioVideoConversionAtURL:nil audioURL:v0 success:NO error:v6];
    } else {
        NSString *inProgressDirectory = [self inProgressDirectory];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [defaultManager createDirectoryAtPath:inProgressDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error != nil) {
            [self finishAudioVideoConversionAtURL:nil audioURL:v0 success:NO error:error];
        } else {
            NSURL *URLByDeletingPathExtension = [v0 URLByDeletingPathExtension];
            NSString *lastPathComponent = [URLByDeletingPathExtension lastPathComponent];
            NSString *str = [lastPathComponent stringByAppendingPathExtension:@"mov"];
            NSString *v17 = [inProgressDirectory stringByAppendingPathComponent:str];
            NSURL *v18 = [NSURL fileURLWithPath:v17];
            NSFileManager *defaultManager2 = [NSFileManager defaultManager];
            NSString *path = [v18 path];
            if ([defaultManager2 fileExistsAtPath:path]) {
                NSUUID *UUID = [NSUUID UUID];
                NSString *UUIDString = [UUID UUIDString];
                NSString *str2 = [NSString stringWithFormat:@"%@_%@.mov", lastPathComponent, UUIDString];
                NSString *v69 = [inProgressDirectory stringByAppendingPathComponent:str2];
                NSURL *v70 = [NSURL fileURLWithPath:v69];
                v18 = v70;
            }
            NSBundle *mainBundle = [NSBundle mainBundle];
            NSURL *v23 = [mainBundle URLForResource:@"JWRBlackVideo" withExtension:@"mov"];
            if (v23 != nil) {
                v24 = [AVURLAsset URLAssetWithURL:v23 options:nil];
            } else {
                v24 = nil;
            }
            NSString *v25 = AVMediaTypeVideo;
            NSArray<AVAssetTrack *> *v26 = [v24 tracksWithMediaType:AVMediaTypeVideo];
            AVAssetTrack *firstObject = [v26 firstObject];
            if (v24 != nil) {
                v71 = [v24 duration];
            } else {
                v71 = (CMTime){0};
            }
            if (firstObject != nil && (v71.flags & (kCMTimeFlags_Valid | kCMTimeFlags_PositiveInfinity | kCMTimeFlags_NegativeInfinity | kCMTimeFlags_Indefinite)) == kCMTimeFlags_Valid) {
                Float64 v32 = CMTimeGetSeconds(v71);
                if (v32 > 0.01) {
                    AVMutableComposition *composition = [AVMutableComposition composition];
                    AVMutableCompositionTrack *v33 = [composition addMutableTrackWithMediaType:v2 preferredTrackID:kCMPersistentTrackID_Invalid];
                    AVMutableCompositionTrack *v34 = [composition addMutableTrackWithMediaType:v25 preferredTrackID:kCMPersistentTrackID_Invalid];
                    CMTime v37 = kCMTimeZero;
                    CMTimeRange v8 = CMTimeRangeMake(v37, v72);
                    NSError *v40 = nil;
                    v37 = kCMTimeZero;
                    BOOL v41 = [v33 insertTimeRange:v8 ofTrack:firstObject2 atTime:v37 error:&v40];
                    v37 = kCMTimeZero;
                    v8 = CMTimeRangeMake(v37, v71);
                    NSError *v43 = v40;
                    v37 = kCMTimeZero;
                    BOOL v44 = [v34 insertTimeRange:v8 ofTrack:firstObject atTime:v37 error:&v43];
                    if ((uint32_t)v41 == 0 || !v44 || v43 != nil) {
                        if (!v43) {
                            NSError *v46 = [self audioVideoError:@"Could not assemble the audio-video composition."];
                            [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:NO error:v46];
                            goto blk_b150;
                        }
                        [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:NO error:v43];
                        goto blk_b150;
                    }
                    v37 = kCMTimeZero;
                    v8 = CMTimeRangeMake(v37, v71);
                    v37 = v72;
                    [v34 scaleTimeRange:v8 toDuration:v37];
                    CGAffineTransform preferredTransform = [firstObject preferredTransform];
                    [v34 setPreferredTransform:preferredTransform];
                    AVAssetExportSession *v48 = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
                    if (!v48) {
blk_b1b4:
                        NSError *v49 = [self audioVideoError:@"QuickTime passthrough export is unavailable."];
                        [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:NO error:v49];
                        goto blk_b150;
                    }
                    NSArray<AVFileType> *supportedFileTypes = [v48 supportedFileTypes];
                    NSString *v52 = AVFileTypeQuickTimeMovie;
                    if (![supportedFileTypes containsObject:AVFileTypeQuickTimeMovie]) {
                        goto blk_b1b4;
                    }
                    [v48 setOutputURL:v18];
                    [v48 setOutputFileType:v52];
                    [v48 setShouldOptimizeForNetworkUse:YES];
                    NSISO8601DateFormatter *v54 = [NSISO8601DateFormatter new];
                    NSDate *date = [NSDate date];
                    NSString *v56 = [v54 stringFromDate:date];
                    AVMutableMetadataItem *v57 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataCreationDate value:v56];
                    AVMutableMetadataItem *v59 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataSoftware value:@"JimWas Recorder 1.9.3"];
                    AVMutableMetadataItem *v60 = [self metadataItem:AVMetadataIdentifierQuickTimeMetadataModel value:@"Audio-only black video"];
                    NSArray<AVMutableMetadataItem *> *v61 = @[v57, v59, v60];
                    [v48 setMetadata:v61];
                    NSString *path2 = [v0 path];
                    NSString *path3 = [v18 path];
                    JWRLog(@"audio video passthrough export started audio=%@ staged=%@ duration=%.3f", path2, path3, CMTimeGetSeconds(v72));
                    void (^v64)(void) = ^void(void) {
                        AVAssetExportSessionStatus status = [v48 status];
                        NSError *error = [v48 error];
                        if (status == AVAssetExportSessionStatusCompleted) {
                            [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:YES error:error];
                            return;
                        }
                        [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:NO error:error];
                    };
                    [v48 exportAsynchronouslyWithCompletionHandler:v64];
                    goto blk_b150;
                }
            }
            NSError *v30 = [self audioVideoError:@"The bundled black-video template is unavailable."];
            [self finishAudioVideoConversionAtURL:v18 audioURL:v0 success:NO error:v30];
        }
    }
blk_b150:
}


void -[JWRRecorderManager toggleAudio](void)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        bool audioRecording2 = [self audioRecording];
        JWRLog(@"toggleAudio current=%d", audioRecording2);
        if ([self desiredAudioRecording]) {
            [self setDesiredAudioRecording:NO];
            AVAudioRecorder *audioRecorder = [self audioRecorder];
            [audioRecorder stop];
            [self setAudioRecording:NO];
            [self cancelHeartbeatTimer];
            [self cancelTrialTimerIfIdle];
            [self feedbackNotification:@"com.jimwas.recorder/hapticStopped"];
            return;
        }
        if (JWRTrialCanBeginCapture() & 1) {
            [self setDesiredAudioRecording:YES];
            AVAudioSession *sharedInstance = [AVAudioSession sharedInstance];
            NSError *v7 = nil;
            [sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker error:&v7];
            if (v7 != nil) {
                JWRLog(@"audio category error=%@", v7);
            }
            NSError *v9 = nil;
            [sharedInstance setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&v9];
            if (v9 != nil) {
                JWRLog(@"audio activation error=%@", v9);
            }
            NSDictionary<id, NSNumber *> *v13 = @{AVFormatIDKey: @1633772320U, AVSampleRateKey: @44100, AVNumberOfChannelsKey: @1, AVEncoderAudioQualityKey: @96LL};
            AVAudioRecorder *v14 = [AVAudioRecorder alloc];
            NSURL *v15 = [self outputURLWithExtension:@"m4a"];
            NSError *v16 = nil;
            [self setAudioRecorder:[v14 initWithURL:v15 settings:v13 error:&v16]];
            if (v16 != nil) {
                JWRLog(@"audio recorder init error=%@", v16);
            }
            AVAudioRecorder *audioRecorder2 = [self audioRecorder];
            [audioRecorder2 setDelegate:self];
            AVAudioRecorder *audioRecorder3 = [self audioRecorder];
            BOOL record = [audioRecorder3 record];
            [self setAudioRecording:record];
            bool audioRecording = [self audioRecording];
            AVAudioRecorder *audioRecorder4 = [self audioRecorder];
            NSURL *url = [audioRecorder4 url];
            NSString *path = [url path];
            JWRLog(@"audio record result=%d url=%@", audioRecording, path);
            if (![self audioRecording]) {
                [self setDesiredAudioRecording:NO];
                [self cancelTrialTimerIfIdle];
                NSString *v29 = [NSString stringWithFormat:@"audio recording failed to start error=%@", v16];
                [self failureFeedback:v29];
            } else {
                [self scheduleHeartbeatTimer];
                [self scheduleTrialTimerIfNeeded];
                [self feedbackNotification:@"com.jimwas.recorder/hapticStarted"];
            }
        } else {
            [self failureFeedback:@"seven-day trial expired; install the full package to continue recording"];
            return;
        }
    });
}


void -[JWRRecorderManager audioRecorderDidFinishRecording:successfully:](AVAudioRecorder *a1, bool a2)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        bool desiredAudioRecording = [self desiredAudioRecording];
        JWRLog(@"audio recorder finished successfully=%d desired=%d", a2, desiredAudioRecording);
        [self setAudioRecording:NO];
        if (a2 == 1) {
            JWRPreferences *shared = [JWRPreferences shared];
            bool saveAudioAsVideo = [shared saveAudioAsVideo];
            if (saveAudioAsVideo) {
                NSURL *url = [a1 url];
                [self createVideoCopyForAudioURL:url];
            }
        }
        if (![self desiredAudioRecording]) {
            return;
        }
        [self setDesiredAudioRecording:NO];
        [self cancelHeartbeatTimer];
        [self cancelTrialTimerIfIdle];
        [self failureFeedback:@"audio recording stopped unexpectedly"];
    });
}


void -[JWRRecorderManager audioRecorderEncodeErrorDidOccur:error:](AVAudioRecorder *a1, NSError *a2)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        JWRLog(@"audio recorder encode error=%@", a2);
        if (![self desiredAudioRecording]) {
            return;
        }
        [self setDesiredAudioRecording:NO];
        [self setAudioRecording:NO];
        [self cancelHeartbeatTimer];
        [self cancelTrialTimerIfIdle];
        NSString *v3 = [NSString stringWithFormat:@"audio encoding failed error=%@", a2];
        [self failureFeedback:v3];
    });
}


void -[JWRRecorderManager takePhoto](void)
{
    NSObject<OS_dispatch_queue> *queue = [self queue];
    dispatch_async(queue, ^void(void) {
        JWRLog(@"takePhoto requested");
        if ((JWRTrialCanBeginCapture() & 1) == 0) {
            [self failureFeedback:@"seven-day trial expired; install the full package to continue recording"];
            return;
        }
        if (![self prepareSession:NO]) {
            JWRLog(@"photo aborted: session unavailable");
            return;
        }
        AVCapturePhotoSettings *photoSettings = [AVCapturePhotoSettings photoSettings];
        [photoSettings setPhotoQualityPrioritization:AVCapturePhotoQualityPrioritizationQuality];
        AVCapturePhotoOutput *photoOutput = [self photoOutput];
        [photoOutput capturePhotoWithSettings:photoSettings delegate:self];
    });
}


void -[JWRRecorderManager captureOutput:didFinishProcessingPhoto:error:](AVCapturePhotoOutput *a1, AVCapturePhoto *a2, NSError *a3)
{
    JWRLog(@"photo processing finished error=%@", a3);
    NSData *fileDataRepresentation = [a2 fileDataRepresentation];
    if (!fileDataRepresentation) {
        JWRLog(@"photo had no data");
    } else {
        NSURL *url = [self outputURLWithExtension:@"jpg"];
        UIImage *v3 = [UIImage imageWithData:fileDataRepresentation];
        JWRPreferences *shared2 = [JWRPreferences shared];
        double photoQuality = [shared2 photoQuality];
        NSData *v6 = UIImageJPEGRepresentation(v3, photoQuality);
        NSError *errorPtr = nil;
        [v6 writeToURL:url options:NSDataWritingAtomic error:&errorPtr];
        NSString *path = [url path];
        NSUInteger length = [v6 length];
        JWRLog(@"photo write url=%@ bytes=%lu error=%@", path, length, errorPtr);
        if (!errorPtr) {
            [self feedbackNotification:@"com.jimwas.recorder/hapticPhoto"];
        }
        JWRPreferences *shared = [JWRPreferences shared];
        if ([shared savePhotoToPhotos]) {
            PHPhotoLibrary *sharedPhotoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
            [sharedPhotoLibrary performChanges:^void(void) {
                [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
            } completionHandler:nil];
        }
        NSObject<OS_dispatch_queue> *queue = [self queue];
        dispatch_async(queue, ^void(void) {
            if ([self videoRecording]) {
                return;
            }
            AVCaptureSession *session = [self session];
            [session stopRunning];
            [self setSession:nil];
        });
    }
}


bool -[JWRRecorderManager videoRecording](void)
{
    return self->_videoRecording;
}


void -[JWRRecorderManager setVideoRecording:](bool a1)
{
    self->_videoRecording = a1;
}


bool -[JWRRecorderManager audioRecording](void)
{
    return self->_audioRecording;
}


void -[JWRRecorderManager setAudioRecording:](bool a1)
{
    self->_audioRecording = a1;
}


NSObject<OS_dispatch_queue> *-[JWRRecorderManager queue](void)
{
    return self->_queue;
}


void -[JWRRecorderManager setQueue:](NSObject<OS_dispatch_queue> *a1)
{
    self->_queue = a1;
}


AVCaptureSession *-[JWRRecorderManager session](void)
{
    return self->_session;
}


void -[JWRRecorderManager setSession:](AVCaptureSession *a1)
{
    self->_session = a1;
}


AVCaptureMovieFileOutput *-[JWRRecorderManager movieOutput](void)
{
    return self->_movieOutput;
}


void -[JWRRecorderManager setMovieOutput:](AVCaptureMovieFileOutput *a1)
{
    self->_movieOutput = a1;
}


AVCapturePhotoOutput *-[JWRRecorderManager photoOutput](void)
{
    return self->_photoOutput;
}


void -[JWRRecorderManager setPhotoOutput:](AVCapturePhotoOutput *a1)
{
    self->_photoOutput = a1;
}


AVAudioRecorder *-[JWRRecorderManager audioRecorder](void)
{
    return self->_audioRecorder;
}


void -[JWRRecorderManager setAudioRecorder:](AVAudioRecorder *a1)
{
    self->_audioRecorder = a1;
}


NSURL *-[JWRRecorderManager videoURL](void)
{
    return self->_videoURL;
}


void -[JWRRecorderManager setVideoURL:](NSURL *a1)
{
    self->_videoURL = a1;
}


id -[JWRRecorderManager sessionErrorObserver](void)
{
    return self->_sessionErrorObserver;
}


void -[JWRRecorderManager setSessionErrorObserver:](id a1)
{
    self->_sessionErrorObserver = a1;
}


id -[JWRRecorderManager sessionInterruptedObserver](void)
{
    return self->_sessionInterruptedObserver;
}


void -[JWRRecorderManager setSessionInterruptedObserver:](id a1)
{
    self->_sessionInterruptedObserver = a1;
}


id -[JWRRecorderManager sessionInterruptionEndedObserver](void)
{
    return self->_sessionInterruptionEndedObserver;
}


void -[JWRRecorderManager setSessionInterruptionEndedObserver:](id a1)
{
    self->_sessionInterruptionEndedObserver = a1;
}


bool -[JWRRecorderManager rollingSegment](void)
{
    return self->_rollingSegment;
}


void -[JWRRecorderManager setRollingSegment:](bool a1)
{
    self->_rollingSegment = a1;
}


bool -[JWRRecorderManager recoveryInProgress](void)
{
    return self->_recoveryInProgress;
}


void -[JWRRecorderManager setRecoveryInProgress:](bool a1)
{
    self->_recoveryInProgress = a1;
}


bool -[JWRRecorderManager desiredVideoRecording](void)
{
    return self->_desiredVideoRecording;
}


void -[JWRRecorderManager setDesiredVideoRecording:](bool a1)
{
    self->_desiredVideoRecording = a1;
}


bool -[JWRRecorderManager desiredAudioRecording](void)
{
    return self->_desiredAudioRecording;
}


void -[JWRRecorderManager setDesiredAudioRecording:](bool a1)
{
    self->_desiredAudioRecording = a1;
}


bool -[JWRRecorderManager recoveryScanned](void)
{
    return self->_recoveryScanned;
}


void -[JWRRecorderManager setRecoveryScanned:](bool a1)
{
    self->_recoveryScanned = a1;
}


long -[JWRRecorderManager recoveryAttempts](void)
{
    return self->_recoveryAttempts;
}


void -[JWRRecorderManager setRecoveryAttempts:](long a1)
{
    self->_recoveryAttempts = a1;
}


unsigned long -[JWRRecorderManager recordingGeneration](void)
{
    return self->_recordingGeneration;
}


void -[JWRRecorderManager setRecordingGeneration:](unsigned long a1)
{
    self->_recordingGeneration = a1;
}


NSObject<OS_dispatch_source> *-[JWRRecorderManager segmentTimer](void)
{
    return self->_segmentTimer;
}


void -[JWRRecorderManager setSegmentTimer:](NSObject<OS_dispatch_source> *a1)
{
    self->_segmentTimer = a1;
}


NSObject<OS_dispatch_source> *-[JWRRecorderManager heartbeatTimer](void)
{
    return self->_heartbeatTimer;
}


void -[JWRRecorderManager setHeartbeatTimer:](NSObject<OS_dispatch_source> *a1)
{
    self->_heartbeatTimer = a1;
}


NSObject<OS_dispatch_source> *-[JWRRecorderManager watchdogTimer](void)
{
    return self->_watchdogTimer;
}


void -[JWRRecorderManager setWatchdogTimer:](NSObject<OS_dispatch_source> *a1)
{
    self->_watchdogTimer = a1;
}


NSObject<OS_dispatch_source> *-[JWRRecorderManager trialTimer](void)
{
    return self->_trialTimer;
}


void -[JWRRecorderManager setTrialTimer:](NSObject<OS_dispatch_source> *a1)
{
    self->_trialTimer = a1;
}


void -[JWRRecorderManager .cxx_destruct](void)
{
    self->_trialTimer = nil;
    self->_watchdogTimer = nil;
    self->_heartbeatTimer = nil;
    self->_segmentTimer = nil;
    self->_sessionInterruptionEndedObserver = nil;
    self->_sessionInterruptedObserver = nil;
    self->_sessionErrorObserver = nil;
    self->_videoURL = nil;
    self->_audioRecorder = nil;
    self->_photoOutput = nil;
    self->_movieOutput = nil;
    self->_session = nil;
    self->_queue = nil;
}
