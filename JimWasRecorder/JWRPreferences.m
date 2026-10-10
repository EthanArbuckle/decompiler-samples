struct JWRPreferences {
    bool _enabled; // +0x8
    bool _triggersWhileLocked; // +0x9
    bool _triggersWhileAudioPlaying; // +0xa
    bool _haptics; // +0xb
    bool _savePhotoToPhotos; // +0xc
    bool _saveAudioAsVideo; // +0xd
    bool _splitVideoEveryTwoMinutes; // +0xe
    bool _embedLocationMetadata; // +0xf
    bool _preventWakeWhileRecording; // +0x10
    long _recordingHeartbeatInterval; // +0x18
    long _videoStorageMode; // +0x20
    long _videoSegmentDurationSeconds; // +0x28
    long _cameraPosition; // +0x30
    double _zoom; // +0x38
    long _fps; // +0x40
    long _videoQuality; // +0x48
    double _photoQuality; // +0x50
    NSString *_filenamePrefix; // +0x58
    NSString *_videoOutputDirectory; // +0x60
    long _doubleVolumeUpAction; // +0x68
    long _doubleVolumeDownAction; // +0x70
    long _longVolumeUpAction; // +0x78
    long _longVolumeDownAction; // +0x80
    long _bothVolumesAction; // +0x88
    long _powerAction; // +0x90
};

static JWRPreferences *qword_1ddd0;

JWRPreferences *+[JWRPreferences shared](void)
{
    dispatch_once(&qword_1ddd8, ^void(void) {
        qword_1ddd0 = [self new];
        [qword_1ddd0 reload];
    });
    return qword_1ddd0;
}


void -[JWRPreferences reload](void)
{
    long v22;
    CFPreferencesAppSynchronize(@"com.jimwas.recorder");
    CFDictionaryRef v0 = CFPreferencesCopyMultiple(NULL, @"com.jimwas.recorder", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    id (^v2)(NSString *, id) = ^id(NSString *arg1, id arg2) {
        id v46 = [v0 objectForKeyedSubscript:arg1];
        return (!v46) ? arg2 : v46;
    };
    id v4 = v2(@"enabled", @YES);
    self->_enabled = [v4 boolValue];
    id v6 = v2(@"triggersWhileLocked", @NO);
    self->_triggersWhileLocked = [v6 boolValue];
    id v7 = v2(@"triggersWhileAudioPlaying", @NO);
    self->_triggersWhileAudioPlaying = [v7 boolValue];
    id v8 = v2(@"haptics", @YES);
    self->_haptics = [v8 boolValue];
    id v9 = v2(@"recordingHeartbeatInterval", @0);
    NSInteger integerValue = [v9 integerValue];
    self->_recordingHeartbeatInterval = integerValue & ~(integerValue >> 63);
    id v11 = [v0 objectForKeyedSubscript:@"videoStorageMode"];
    if (!v11) {
        id v12 = v2(@"saveVideoToPhotos", @YES);
        self->_videoStorageMode = ([v12 boolValue]) ? 2 : 0;
    } else {
        NSInteger integerValue2 = [v11 integerValue];
        self->_videoStorageMode = ((integerValue2 & ~(integerValue2 >> 63)) < 2) ? integerValue2 & ~(integerValue2 >> 63) : 2;
    }
    id v17 = v2(@"savePhotoToPhotos", @YES);
    self->_savePhotoToPhotos = [v17 boolValue];
    id v19 = v2(@"saveAudioAsVideo", @NO);
    self->_saveAudioAsVideo = [v19 boolValue];
    id v20 = v2(@"splitVideoEveryTwoMinutes", @NO);
    self->_splitVideoEveryTwoMinutes = [v20 boolValue];
    id v21 = [v0 objectForKeyedSubscript:@"videoSegmentDurationSeconds"];
    if (!v21) {
        v22 = (self->_splitVideoEveryTwoMinutes) ? 120 : 0;
    } else {
        NSInteger integerValue3 = [v21 integerValue];
        v22 = integerValue3 & ~(integerValue3 >> 63);
    }
    self->_videoSegmentDurationSeconds = v22;
    id v24 = v2(@"embedLocationMetadata", @NO);
    self->_embedLocationMetadata = [v24 boolValue];
    id v25 = v2(@"preventWakeWhileRecording", @YES);
    self->_preventWakeWhileRecording = [v25 boolValue];
    id v26 = v2(@"cameraPosition", @0);
    self->_cameraPosition = [v26 integerValue];
    id v27 = v2(@"zoom", @1.0);
    self->_zoom = [v27 doubleValue];
    id v28 = v2(@"fps", @30);
    self->_fps = [v28 integerValue];
    id v29 = v2(@"videoQuality", @1);
    self->_videoQuality = [v29 integerValue];
    id v30 = v2(@"photoQuality", @0.92);
    self->_photoQuality = [v30 doubleValue];
    self->_filenamePrefix = v2(@"filenamePrefix", @"JWR");
    id v33 = v2(@"videoOutputDirectory", @"/var/mobile/Documents/JimWasRecorder");
    NSString *v34 = (![v33 isKindOfClass:[NSString class]]) ? @"" : [v33 stringByStandardizingPath];
    BOOL v35 = [v34 hasPrefix:@"/var/mobile/"];
    NSString *v36 = @"/var/mobile/Documents/JimWasRecorder";
    if (v35) {
        NSUInteger length = [v34 length];
        NSUInteger length2 = [@"/var/mobile/" length];
        if (length > length2) {
            v36 = v34;
        }
    }
    self->_videoOutputDirectory = v36;
    id v39 = v2(@"doubleVolumeUpAction", @1);
    self->_doubleVolumeUpAction = [v39 integerValue];
    id v40 = v2(@"doubleVolumeDownAction", @2);
    self->_doubleVolumeDownAction = [v40 integerValue];
    id v42 = v2(@"longVolumeUpAction", @0);
    self->_longVolumeUpAction = [v42 integerValue];
    id v43 = v2(@"longVolumeDownAction", @0);
    self->_longVolumeDownAction = [v43 integerValue];
    id v44 = v2(@"bothVolumesAction", @3);
    self->_bothVolumesAction = [v44 integerValue];
    id v45 = v2(@"powerAction", @0);
    self->_powerAction = [v45 integerValue];
}


bool -[JWRPreferences enabled](void)
{
    return self->_enabled;
}


void -[JWRPreferences setEnabled:](bool a1)
{
    self->_enabled = a1;
}


bool -[JWRPreferences triggersWhileLocked](void)
{
    return self->_triggersWhileLocked;
}


void -[JWRPreferences setTriggersWhileLocked:](bool a1)
{
    self->_triggersWhileLocked = a1;
}


bool -[JWRPreferences triggersWhileAudioPlaying](void)
{
    return self->_triggersWhileAudioPlaying;
}


void -[JWRPreferences setTriggersWhileAudioPlaying:](bool a1)
{
    self->_triggersWhileAudioPlaying = a1;
}


bool -[JWRPreferences haptics](void)
{
    return self->_haptics;
}


void -[JWRPreferences setHaptics:](bool a1)
{
    self->_haptics = a1;
}


long -[JWRPreferences recordingHeartbeatInterval](void)
{
    return self->_recordingHeartbeatInterval;
}


void -[JWRPreferences setRecordingHeartbeatInterval:](long a1)
{
    self->_recordingHeartbeatInterval = a1;
}


long -[JWRPreferences videoStorageMode](void)
{
    return self->_videoStorageMode;
}


void -[JWRPreferences setVideoStorageMode:](long a1)
{
    self->_videoStorageMode = a1;
}


bool -[JWRPreferences savePhotoToPhotos](void)
{
    return self->_savePhotoToPhotos;
}


void -[JWRPreferences setSavePhotoToPhotos:](bool a1)
{
    self->_savePhotoToPhotos = a1;
}


bool -[JWRPreferences saveAudioAsVideo](void)
{
    return self->_saveAudioAsVideo;
}


void -[JWRPreferences setSaveAudioAsVideo:](bool a1)
{
    self->_saveAudioAsVideo = a1;
}


bool -[JWRPreferences splitVideoEveryTwoMinutes](void)
{
    return self->_splitVideoEveryTwoMinutes;
}


void -[JWRPreferences setSplitVideoEveryTwoMinutes:](bool a1)
{
    self->_splitVideoEveryTwoMinutes = a1;
}


long -[JWRPreferences videoSegmentDurationSeconds](void)
{
    return self->_videoSegmentDurationSeconds;
}


void -[JWRPreferences setVideoSegmentDurationSeconds:](long a1)
{
    self->_videoSegmentDurationSeconds = a1;
}


bool -[JWRPreferences embedLocationMetadata](void)
{
    return self->_embedLocationMetadata;
}


void -[JWRPreferences setEmbedLocationMetadata:](bool a1)
{
    self->_embedLocationMetadata = a1;
}


bool -[JWRPreferences preventWakeWhileRecording](void)
{
    return self->_preventWakeWhileRecording;
}


void -[JWRPreferences setPreventWakeWhileRecording:](bool a1)
{
    self->_preventWakeWhileRecording = a1;
}


long -[JWRPreferences cameraPosition](void)
{
    return self->_cameraPosition;
}


void -[JWRPreferences setCameraPosition:](long a1)
{
    self->_cameraPosition = a1;
}


double -[JWRPreferences zoom](void)
{
    return self->_zoom;
}


void -[JWRPreferences setZoom:](double a1)
{
    self->_zoom = a1;
}


long -[JWRPreferences fps](void)
{
    return self->_fps;
}


void -[JWRPreferences setFps:](long a1)
{
    self->_fps = a1;
}


long -[JWRPreferences videoQuality](void)
{
    return self->_videoQuality;
}


void -[JWRPreferences setVideoQuality:](long a1)
{
    self->_videoQuality = a1;
}


double -[JWRPreferences photoQuality](void)
{
    return self->_photoQuality;
}


void -[JWRPreferences setPhotoQuality:](double a1)
{
    self->_photoQuality = a1;
}


NSString *-[JWRPreferences filenamePrefix](void)
{
    return self->_filenamePrefix;
}


void -[JWRPreferences setFilenamePrefix:](NSString *a1)
{
    self->_filenamePrefix = [a1 copy];
}


NSString *-[JWRPreferences videoOutputDirectory](void)
{
    return self->_videoOutputDirectory;
}


void -[JWRPreferences setVideoOutputDirectory:](NSString *a1)
{
    self->_videoOutputDirectory = [a1 copy];
}


long -[JWRPreferences doubleVolumeUpAction](void)
{
    return self->_doubleVolumeUpAction;
}


void -[JWRPreferences setDoubleVolumeUpAction:](long a1)
{
    self->_doubleVolumeUpAction = a1;
}


long -[JWRPreferences doubleVolumeDownAction](void)
{
    return self->_doubleVolumeDownAction;
}


void -[JWRPreferences setDoubleVolumeDownAction:](long a1)
{
    self->_doubleVolumeDownAction = a1;
}


long -[JWRPreferences longVolumeUpAction](void)
{
    return self->_longVolumeUpAction;
}


void -[JWRPreferences setLongVolumeUpAction:](long a1)
{
    self->_longVolumeUpAction = a1;
}


long -[JWRPreferences longVolumeDownAction](void)
{
    return self->_longVolumeDownAction;
}


void -[JWRPreferences setLongVolumeDownAction:](long a1)
{
    self->_longVolumeDownAction = a1;
}


long -[JWRPreferences bothVolumesAction](void)
{
    return self->_bothVolumesAction;
}


void -[JWRPreferences setBothVolumesAction:](long a1)
{
    self->_bothVolumesAction = a1;
}


long -[JWRPreferences powerAction](void)
{
    return self->_powerAction;
}


void -[JWRPreferences setPowerAction:](long a1)
{
    self->_powerAction = a1;
}


void -[JWRPreferences .cxx_destruct](void)
{
    self->_videoOutputDirectory = nil;
    self->_filenamePrefix = nil;
}
