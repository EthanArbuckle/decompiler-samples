struct FBProcessExitContext {
    unsigned long _exitReason; // +0x8
    RBSProcessExitContext *_underlyingContext; // +0x10
    NSError *_launchError; // +0x18
    NSError *_terminationError; // +0x20
    FBSProcessTerminationRequest *_terminationRequest; // +0x28
    FBProcessWatchdogEventContext *_watchdogContext; // +0x30
    FBProcessState *_stateBeforeExiting; // +0x38
    long _terminationReason; // +0x40
};

void -[FBProcessExitContext .cxx_destruct](void)
{
    self->_stateBeforeExiting = nil;
    self->_watchdogContext = nil;
    self->_terminationRequest = nil;
    self->_terminationError = nil;
    self->_launchError = nil;
    self->_underlyingContext = nil;
}


FBProcessExitContext *-[FBProcessExitContext initWithUnderlyingContext:](RBSProcessExitContext *a1)
{
    unsigned long v6;
    FBProcessExitContext *v2 = [super init];
    if (v2 != nil) {
        v2->_underlyingContext = a1;
        long type = [a1 type];
        if (type == 1) {
            v2->_exitReason = 1;
        } else if (type == 2) {
            id status = [a1 status];
            if (![status isValid]) {
                v2->_exitReason = 0;
            } else {
                if ([status domain] != 10 || [status code] != 0x8badf00d) {
                    if ([status isCrash]) {
                        v6 = 4;
                    } else if ([status isJetsam]) {
                        v6 = 16;
                    } else if ([status isSignal]) {
                        v6 = 8;
                    } else {
                        v6 = (![status isFairPlayFailure]) ? 128 : 32;
                    }
                } else {
                    v6 = 2;
                }
                v2->_exitReason = v6;
            }
        } else {
            v2->_exitReason = 0;
        }
    }
    return v2;
}


NSError *-[FBProcessExitContext createError](void)
{
    NSString *v8;
    NSMutableDictionary *v0 = [[NSMutableDictionary alloc] init];
    NSString *v1 = NSStringFromFBProcessExitReason(self->_exitReason);
    [v0 setObject:v1 forKey:BSErrorCodeDescriptionKey];
    id status = [self->_underlyingContext status];
    NSError *v3 = self->_launchError;
    if (self->_launchError != nil) {
        [v0 setObject:v3 forKey:NSUnderlyingErrorKey];
    } else {
        v3 = self->_terminationError;
        if (self->_terminationError) {
            [v0 setObject:v3 forKey:NSUnderlyingErrorKey];
        } else if ([status isValid]) {
            NSError *error = [status error];
            if (error != nil) {
                [v0 setObject:error forKey:NSUnderlyingErrorKey];
            }
        }
    }
    if (self->_exitReason <= 7) {
        if (self->_exitReason > 1) {
            switch (self->_exitReason) {
                case 2:
                    if (!self->_watchdogContext) {
                        v8 = @"The process was watchdogged.";
                    } else {
                        id v9 = NSStringFromProcessWatchdogEvent([self->_watchdogContext event]);
                        v8 = [NSString stringWithFormat:@"The process was watchdogged during a %@ event.", v9];
                        if (!v8) {
blk_1c4f08720:
                            v8 = @"The process exited.";
                        }
                    }
                    break;
                case 4:
                    v8 = @"The process crashed.";
                    break;
                default:
                    goto blk_1c4f08720;
            }
        } else if (!self->_exitReason || self->_exitReason != 1) {
            goto blk_1c4f08720;
        } else {
            v8 = @"The process exited voluntarily.";
        }
    } else if (self->_exitReason <= 31) {
        switch (self->_exitReason) {
            case 8:
                NSInteger code = [status code];
                v8 = [NSString stringWithFormat:@"The process exited with signal %llu.", code];
                if (!v8) {
                    goto blk_1c4f08720;
                }
                break;
            case 16:
                v8 = @"The process was jettisoned.";
                break;
            default:
                goto blk_1c4f08720;
        }
    } else {
        switch (self->_exitReason) {
            case 32:
                v8 = @"The process was unable to launch due to a FairPlay failure.";
                break;
            case 64:
                v8 = @"The process failed to launch.";
                break;
            case 128:
                if (!self->_terminationError) {
                    NSInteger code2 = [status code];
                    if (code2 <= 0xdead10cb) {
                        switch (code2) {
                            case 732775916:
                                v8 = (self->_terminationReason == 8) ? @"The process was terminated for rendering insecurely." : @"The process was terminated due to a security violation.";
                                break;
                            case 3221229823:
                                v8 = @"The process exited due to thermal pressure.";
                                break;
                            default:
                                goto blk_1c4f08720;
                        }
                    } else {
                        switch (code2) {
                            case 3735883980:
                                v8 = @"The process suspended while holding a shared file lock.";
                                break;
                            case 3735943697:
                                v8 = @"The process was quit by the user.";
                                break;
                            case 4227595259:
                                v8 = (((self->_terminationReason != 9) ? self->_terminationReason == 6 : 1) == 1) ? @"The process was quit because the system is shutting down or logging out." : @"The process was force quit by the system.";
                                break;
                            default:
                                goto blk_1c4f08720;
                        }
                    }
                } else {
                    v8 = @"The process failed to terminate as expected.";
                }
                break;
            default:
                goto blk_1c4f08720;
        }
    }
    [v0 setObject:v8 forKey:NSLocalizedFailureReasonErrorKey];
    return [NSError errorWithDomain:@"FBProcessExit" code:self->_exitReason userInfo:v0];
}


void -[FBProcessExitContext setTerminationRequest:](FBSProcessTerminationRequest *a1)
{
    self->_terminationRequest = a1;
}


void -[FBProcessExitContext setWatchdogContext:](FBProcessWatchdogEventContext *a1)
{
    self->_watchdogContext = a1;
}


long -[FBProcessExitContext setStateBeforeExiting:](long a1)
{
    return objc_setProperty_nonatomic_copy(self, _cmd, a1, 56);
}


void -[FBProcessExitContext setTerminationReason:](long a1)
{
    self->_terminationReason = a1;
}


id -[FBProcessExitContext description](void)
{
    if (self->_exitReason != 2 || !self->_terminationRequest) {
        return [self->_underlyingContext description];
    }
    id v1 = [BSDescriptionBuilder builderWithObject:[self class]];
    NSString *v2 = NSStringFromFBProcessExitReason(self->_exitReason);
    NSString *label = [self->_terminationRequest label];
    NSString *v4 = [v2 stringByAppendingFormat:@" (\"%@\")", label];
    [v1 appendObject:v4 withName:0];
    return [v1 build];
}


unsigned long -[FBProcessExitContext exitReason](void)
{
    return self->_exitReason;
}


long -[FBProcessExitContext terminationReason](void)
{
    return self->_terminationReason;
}


FBProcessExitContext *-[FBProcessExitContext initWithLaunchError:](NSError *a1)
{
    if (!a1) {
        NSString *v12 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"error != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v13 = NSStringFromSelector(_cmd);
            NSString *v14 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v13, v14, self, @"FBProcessExitContext.m", 68, v12);
        }
        _bs_set_crash_log_message([v12 UTF8String]);
        __break(0);
    }
    FBProcessExitContext *v1 = [self initWithUnderlyingContext:0];
    if (v1 != nil) {
        v1->_launchError = a1;
        v1->_exitReason = 64;
        NSArray<NSError *> *underlyingErrors = [a1 underlyingErrors];
        NSErrorDomain v7 = NSPOSIXErrorDomain;
        for (NSError *v9 in underlyingErrors) {
            NSErrorDomain domain = [v9 domain];
            if ([domain isEqual:v7]) {
                NSInteger code = [v9 code];
                if (code == 80) {
                    v1->_exitReason = 32;
                    break;
                }
            }
        }
    }
    return v1;
}


FBProcessExitContext *-[FBProcessExitContext initWithTerminationError:](NSError *a1)
{
    if (!a1) {
        NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"error != ((void *)0)"];
        if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
            NSString *v2 = NSStringFromSelector(_cmd);
            NSString *v3 = NSStringFromClass([self class]);
            os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBProcessExitContext.m", 87, v1);
        }
        _bs_set_crash_log_message([v1 UTF8String]);
        __break(0);
    }
    FBProcessExitContext *v0 = [self initWithUnderlyingContext:0];
    if (v0 != nil) {
        v0->_terminationError = a1;
        v0->_exitReason = 128;
    }
    return v0;
}


long -[FBProcessExitContext debugDescription](void)
{
    return [self descriptionWithMultilinePrefix:0];
}


id -[FBProcessExitContext succinctDescription](void)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    return [succinctDescriptionBuilder build];
}


id -[FBProcessExitContext succinctDescriptionBuilder](void)
{
    Class v0 = [self class];
    id v1 = [BSDescriptionBuilder builderWithObject:v0];
    NSString *v2 = NSStringFromFBProcessExitReason(self->_exitReason);
    [v1 appendObject:v2 withName:@"exitReason"];
    return v1;
}


id -[FBProcessExitContext descriptionWithMultilinePrefix:](long a1)
{
    id v0 = [self descriptionBuilderWithMultilinePrefix:a1];
    return [v0 build];
}


id -[FBProcessExitContext descriptionBuilderWithMultilinePrefix:](long a1)
{
    id succinctDescriptionBuilder = [self succinctDescriptionBuilder];
    [succinctDescriptionBuilder appendBodySectionWithName:0 multilinePrefix:0 block:^void(void) {
        [succinctDescriptionBuilder appendObject:self->_underlyingContext withName:@"underlying" skipIfNil:1];
        if (self->_terminationReason >= 1) {
            id v2 = FBSApplicationTerminationReasonDescription(self->_terminationReason);
            [succinctDescriptionBuilder appendObject:v2 withName:@"terminationReason"];
        }
        id v3 = [self->_launchError descriptionWithMultilinePrefix:0];
        [succinctDescriptionBuilder appendObject:v3 withName:@"launchError" skipIfNil:1];
        id v4 = [self->_terminationError descriptionWithMultilinePrefix:0];
        [succinctDescriptionBuilder appendObject:v4 withName:@"launchError" skipIfNil:1];
        [succinctDescriptionBuilder appendObject:self->_stateBeforeExiting withName:@"stateAtExit" skipIfNil:1];
        [succinctDescriptionBuilder appendObject:self->_terminationRequest withName:@"terminationRequest" skipIfNil:1];
        [succinctDescriptionBuilder appendObject:self->_watchdogContext withName:@"watchdogContext" skipIfNil:1];
    }];
    return succinctDescriptionBuilder;
}


RBSProcessExitContext *-[FBProcessExitContext underlyingContext](void)
{
    return self->_underlyingContext;
}


NSError *-[FBProcessExitContext launchError](void)
{
    return self->_launchError;
}


NSError *-[FBProcessExitContext terminationError](void)
{
    return self->_terminationError;
}


FBSProcessTerminationRequest *-[FBProcessExitContext terminationRequest](void)
{
    return self->_terminationRequest;
}


FBProcessWatchdogEventContext *-[FBProcessExitContext watchdogContext](void)
{
    return self->_watchdogContext;
}


FBProcessState *-[FBProcessExitContext stateBeforeExiting](void)
{
    return self->_stateBeforeExiting;
}


long -[FBProcessExitContext(Deprecated) exitStatus](void)
{
    return 0;
}


bool -[FBProcessExitContext(Deprecated) exitedNormally](void)
{
    return self->_exitReason == 1;
}


int -[FBProcessExitContext(Deprecated) exitCode](void)
{
    return [self exitedNormally] ^ 1;
}


NSInteger -[FBProcessExitContext(Deprecated) terminationSignal](void)
{
    if (self->_exitReason != 8) {
        return 0;
    }
    id status = [self->_underlyingContext status];
    return [status code];
}


bool -[FBProcessExitContext(Deprecated) consideredJetsam](void)
{
    return self->_exitReason == 16;
}


bool -[FBProcessExitContext(Deprecated) fairPlayFailure](void)
{
    return self->_exitReason == 32;
}


NSString *+[FBProcessExitContext(Deprecated) descriptionForExitReason:](long a1)
{
    return NSStringFromFBProcessExitReason(a1);
}
