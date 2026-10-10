struct FBWorkspaceAssertionAttributes {
    RBSAttribute *_maintainSelfForBGHosting; // +0x8
    RBSAttribute *_maintainSelfForFGHosting; // +0x10
    RBSAttribute *_activityLimitPreserveNonUI; // +0x18
    RBSAttribute *_activityLimitActiveUI; // +0x20
    RBSAttribute *_activityRunReasonSuspend; // +0x28
    RBSAttribute *_activityRunReasonResume; // +0x30
    RBSAttribute *_roleOpportunistic; // +0x38
    RBSAttribute *_roleUtility; // +0x40
    RBSAttribute *_roleNonUI; // +0x48
    RBSAttribute *_roleUINonFocal; // +0x50
    RBSAttribute *_roleUIFocal; // +0x58
    RBSAttribute *_jetsamPriorityOpportunistic; // +0x60
    RBSAttribute *_jetsamPriorityBackground; // +0x68
    RBSAttribute *_jetsamPriorityUtility3; // +0x70
    RBSAttribute *_jetsamPriorityUtility2; // +0x78
    RBSAttribute *_jetsamPriorityUtility; // +0x80
    RBSAttribute *_jetsamPriorityActive; // +0x88
    RBSAttribute *_jetsamPriorityUISupport; // +0x90
    RBSAttribute *_jetsamPriorityForegroundSupport; // +0x98
    RBSAttribute *_jetsamPriorityForeground; // +0xa0
    RBSAttribute *_jetsamPriorityForegroundFocal; // +0xa8
    RBSAttribute *_visibility; // +0xb0
    RBSAttribute *_bootstrap; // +0xb8
    RBSAttribute *_fixedMinute; // +0xc0
    RBSAttribute *_prefetch; // +0xc8
    NSArray *_injectorAttributes; // +0xd0
};

FBWorkspaceAssertionAttributes *+[FBWorkspaceAssertionAttributes sharedAttributes](void)
{
    objc_opt_self(self);
    dispatch_once(&sharedAttributes.onceToken, ^void(void) {
        sharedAttributes.attrs = [FBWorkspaceAssertionAttributes new];
        sharedAttributes.attrs->field_8 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"MaintainSelfForBGHosting"];
        sharedAttributes.attrs->field_16 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"MaintainSelfForFGHosting"];
        sharedAttributes.attrs->field_24 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamLimit-PreserveNonUI"];
        sharedAttributes.attrs->field_32 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamLimit-ActiveUI"];
        sharedAttributes.attrs->field_40 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableLPRunReason-Suspend"];
        sharedAttributes.attrs->field_48 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableLPRunReason-Resume"];
        sharedAttributes.attrs->field_56 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableRole-Opportunistic"];
        sharedAttributes.attrs->field_64 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableRole-Utility"];
        sharedAttributes.attrs->field_72 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableRole-NonUI"];
        sharedAttributes.attrs->field_80 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableRole-UINonFocal"];
        sharedAttributes.attrs->field_88 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableRole-UIFocal"];
        sharedAttributes.attrs->field_96 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Opportunistic"];
        sharedAttributes.attrs->field_104 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Background"];
        sharedAttributes.attrs->field_112 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Utility3"];
        sharedAttributes.attrs->field_120 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Utility2"];
        sharedAttributes.attrs->field_128 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Utility"];
        sharedAttributes.attrs->field_136 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Active"];
        sharedAttributes.attrs->field_144 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-UISupport"];
        sharedAttributes.attrs->field_152 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-ForegroundSupport"];
        sharedAttributes.attrs->field_160 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-Foreground"];
        sharedAttributes.attrs->field_168 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableJetsamPriority-ForegroundFocal"];
        sharedAttributes.attrs->field_176 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"Visibility"];
        sharedAttributes.attrs->field_184 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"SuspendableBootstrapping"];
        sharedAttributes.attrs->field_192 = [RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"Duration-Fixed-60-1-Invalidate"];
        if (BSSelfTaskHasEntitlement(@"com.apple.runningboard.pagein-prefetching") != 0) {
            sharedAttributes.attrs->field_200 = [RBSDomainAttribute attributeWithDomain:@"com.apple.pagein-prefetching" name:@"LaunchPrefetch"];
        }
        sharedAttributes.attrs->field_208 = @[[RBSDomainAttribute attributeWithDomain:@"com.apple.frontboard" name:@"WorkspaceEndpointInjection"]];
    });
    return sharedAttributes.attrs;
}


id -[FBWorkspaceAssertionAttributes assertionAttributesForLaunchIntent:assertsVisibility:outWorkspaceState:outProcessVisibility:](long a1, long a2, int *a3, long *a4)
{
    unsigned long v1;
    unsigned long v2;
    unsigned long v3;
    long v4;
    id self;
    if (self != nil) {
        if (!a3) {
            NSString *v7 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outWorkspaceState != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v8 = NSStringFromSelector(@selector(assertionAttributesForLaunchIntent:assertsVisibility:outWorkspaceState:outProcessVisibility:));
                NSString *v9 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v8, v9, self, @"FBWorkspaceDomain.m", 885, v7);
            }
            _bs_set_crash_log_message([v7 UTF8String]);
            __break(0);
        }
        if (!a4) {
            NSString *v11 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outProcessVisibility != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v12 = NSStringFromSelector(@selector(assertionAttributesForLaunchIntent:assertsVisibility:outWorkspaceState:outProcessVisibility:));
                NSString *v13 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v12, v13, self, @"FBWorkspaceDomain.m", 886, v11);
            }
            _bs_set_crash_log_message([v11 UTF8String]);
            __break(0);
        }
        if ((unsigned long)(a1 - 1) > 4) {
            v1 = 0;
            v2 = 0;
            v3 = 0;
            v4 = 0;
        } else {
            long v5 = ((a1 - 1) & 0x1fffffffff) * 8;
            v1 = 0x103030101 >> v5;
            v2 = 0x405040301 >> v5;
            v3 = 0x50645a2814 >> v5;
            v4 = (&qword_1c4f5d248)[a1 - 1];
        }
        int v6 = FBWorkspaceStateCreate(v1 & 255, v2 & 255, v3 & 255);
        *(a3) = v6;
        *(a4) = v4;
        self = [self assertionAttributesForWorkspaceState:v6 assertsVisibility:a2 isBootstrapping:1];
    }
    return self;
}


NSArray *-[FBWorkspaceAssertionAttributes assertionAttributesForWorkspaceState:assertsVisibility:isBootstrapping:](int a1, int a2, int a3)
{
    RBSAttribute *v7;
    long *v9;
    RBSAttribute *v12;
    uint8_t v6[48];
    NSArray *self;
    if (self != nil) {
        if ((FBWorkspaceStateEqual(a1, &FBWorkspaceStateNone) & 1) == 0) {
            int v1 = FBWorkspaceStateGetActivity(a1);
            int v3 = (((v1 == 3) ? a2 : 1) != 0) ? v1 : 2;
            int v4 = FBWorkspaceStateGetProcessRole(a1);
            int v5 = FBWorkspaceStateGetJetsamBand(a1);
            if (!FBWorkspaceActivityIsValid(v3) || !FBWorkspaceProcessRoleIsValid(v4) || (FBWorkspaceJetsamBandIsValid(v5) & 1) == 0) {
                NSString *v13 = NSStringFromFBWorkspaceState(a1);
                NSString *v2 = [NSString stringWithFormat:@"requesting assertions for invalid state %@", v13];
                if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                    NSString *v14 = NSStringFromSelector(@selector(assertionAttributesForWorkspaceState:assertsVisibility:isBootstrapping:));
                    NSString *v15 = NSStringFromClass([self class]);
                    os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v14, v15, self, @"FBWorkspaceDomain.m", 945, v2);
                }
                _bs_set_crash_log_message([v2 UTF8String]);
                __break(0);
            }
            _memset(v6, 0, 48);
            if (!v3) {
blk_1c4ed7ed4:
                if (v4 <= 2) {
                    if (v4 == 1) {
                        v7 = self->_roleOpportunistic;
blk_1c4ed7f28:
                        sp[v3] = v7;
                        v3++;
                    } else if (v4 == 2) {
                        v7 = self->_roleUtility;
                        goto blk_1c4ed7f28;
                    }
                } else {
                    switch (v4) {
                        case 3:
                            v7 = self->_roleNonUI;
                            goto blk_1c4ed7f28;
                        case 4:
                            v7 = self->_roleUINonFocal;
                            goto blk_1c4ed7f28;
                        case 5:
                            v7 = self->_roleUIFocal;
                            goto blk_1c4ed7f28;
                    }
                }
            } else {
                if (v3 != 1) {
                    *(uint64_t *)&v6[0] = *((!v4) ? &self->_activityLimitActiveUI : &self->_activityRunReasonResume);
                    if (v3 != 3) {
blk_1c4ed7ed0:
                        v3 = 1;
                        goto blk_1c4ed7ed4;
                    }
                    *(uint64_t *)&v6[8] = self->_visibility;
                    v3 = 2;
                    goto blk_1c4ed7ed4;
                }
                if (v4 != 0) {
                    *(uint64_t *)&v6[0] = self->_activityRunReasonSuspend;
                    goto blk_1c4ed7ed0;
                }
                *(uint64_t *)&v6[0] = self->_activityLimitPreserveNonUI;
                v3 = 1;
            }
            if (v5 > 39) {
                if (v5 <= 89) {
                    if (v5 == 40) {
                        v9 = &self->_jetsamPriorityActive;
blk_1c4ed7ffc:
                        long v10 = v3 & 255;
                        v3++;
                        sp[v10] = *(v9);
blk_1c4ed8014:
                        if (a3 != 0) {
                            int v11 = v3 + 1;
                            sp[v3 & 255] = self->_bootstrap;
                            if (v4 == 1) {
                                v12 = self->_fixedMinute;
                                goto blk_1c4ed805c;
                            }
                            v3 = v11;
                            if ((v4 & 254) == 4) {
                                v12 = self->_prefetch;
                                v3 = v11;
                                if (v12 != nil) {
blk_1c4ed805c:
                                    v3 += 2;
                                    sp[v11 & 255] = v12;
                                }
                            }
                        }
                        self = [NSArray arrayWithObjects:(id *)v6 count:v3 & 255];
                        return self;
                    }
                    if (v5 != 80) {
blk_1c4ed80c8:
                        if ((v3 & 255) == 0) {
                            return nil;
                        } else {
                            goto blk_1c4ed8014;
                        }
                    }
                    v9 = &self->_jetsamPriorityUISupport;
                    goto blk_1c4ed7ffc;
                }
                if (v5 == 90) {
                    v9 = &self->_jetsamPriorityForegroundSupport;
                    goto blk_1c4ed7ffc;
                }
                if (v5 == 100) {
                    v9 = &self->_jetsamPriorityForeground;
                    goto blk_1c4ed7ffc;
                }
                if (v5 != 101) {
                    goto blk_1c4ed80c8;
                }
                v9 = &self->_jetsamPriorityForegroundFocal;
                goto blk_1c4ed7ffc;
            }
            if (v5 <= 32) {
                if (v5 == 20) {
                    v9 = &self->_jetsamPriorityOpportunistic;
                    goto blk_1c4ed7ffc;
                }
                if (v5 != 30) {
                    goto blk_1c4ed80c8;
                }
                v9 = &self->_jetsamPriorityBackground;
                goto blk_1c4ed7ffc;
            }
            if (v5 == 33) {
                v9 = &self->_jetsamPriorityUtility3;
                goto blk_1c4ed7ffc;
            }
            if (v5 == 34) {
                v9 = &self->_jetsamPriorityUtility2;
                goto blk_1c4ed7ffc;
            }
            if (v5 != 35) {
                goto blk_1c4ed80c8;
            }
            v9 = &self->_jetsamPriorityUtility;
            goto blk_1c4ed7ffc;
        }
        self = nil;
    }
    return self;
}


NSArray *-[FBWorkspaceAssertionAttributes selfAssertionAttributesWithForeground:outWorkspaceState:](long a1, int *a2)
{
    int v5;
    int v6;
    NSArray *self;
    if (self != nil) {
        if (!a2) {
            NSString *v1 = [NSString stringWithFormat:@"Invalid condition not satisfying: %@", @"outWorkspaceState != ((void *)0)"];
            if (os_log_type_enabled(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR)) {
                NSString *v2 = NSStringFromSelector(@selector(selfAssertionAttributesWithForeground:outWorkspaceState:));
                NSString *v3 = NSStringFromClass([self class]);
                os_log_with_type(OS_LOG_DEFAULT, OS_LOG_TYPE_ERROR, "failure in %{public}@ of <%{public}@:%p> (%{public}@:%i) : %{public}@", v2, v3, self, @"FBWorkspaceDomain.m", 1016, v1);
            }
            _bs_set_crash_log_message([v1 UTF8String]);
            __break(0);
        }
        if ((a1 & 1) == 0) {
            v5 = FBWorkspaceStateCreate(1, 3, 40);
            v6 = &self->_maintainSelfForBGHosting;
        } else {
            v5 = FBWorkspaceStateCreate(2, 4, 100);
            v6 = &self->_maintainSelfForFGHosting;
        }
        *(a2) = v5;
        NSArray *v0 = [NSArray arrayWithObject:*(v6)];
        self = v0;
    }
    return self;
}


void -[FBWorkspaceAssertionAttributes .cxx_destruct](void)
{
    self->_injectorAttributes = nil;
    self->_prefetch = nil;
    self->_fixedMinute = nil;
    self->_bootstrap = nil;
    self->_visibility = nil;
    self->_jetsamPriorityForegroundFocal = nil;
    self->_jetsamPriorityForeground = nil;
    self->_jetsamPriorityForegroundSupport = nil;
    self->_jetsamPriorityUISupport = nil;
    self->_jetsamPriorityActive = nil;
    self->_jetsamPriorityUtility = nil;
    self->_jetsamPriorityUtility2 = nil;
    self->_jetsamPriorityUtility3 = nil;
    self->_jetsamPriorityBackground = nil;
    self->_jetsamPriorityOpportunistic = nil;
    self->_roleUIFocal = nil;
    self->_roleUINonFocal = nil;
    self->_roleNonUI = nil;
    self->_roleUtility = nil;
    self->_roleOpportunistic = nil;
    self->_activityRunReasonResume = nil;
    self->_activityRunReasonSuspend = nil;
    self->_activityLimitActiveUI = nil;
    self->_activityLimitPreserveNonUI = nil;
    self->_maintainSelfForFGHosting = nil;
    self->_maintainSelfForBGHosting = nil;
}
