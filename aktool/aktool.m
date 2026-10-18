static Class qword_10000c538;
static Class qword_10000c548;
static long qword_10000c528;
static long qword_10000c530;
static void *qword_10000c540;

int sub_10000200c(void)
{
    NSString *v13;
    dispatch_semaphore_t v56;
    AKAnisetteProvisioningController *v58;
    dispatch_semaphore_t v61;
    AKAnisetteProvisioningController *v258;
    AKAnisetteProvisioningController *v71;
    AKAnisetteProvisioningController *v259;
    void (^v48)(AKAuthorization *, NSError *);
    NSInteger v36;
    id v261;
    id v264;
    id v81;
    id v91;
    AKCredentialRequestContext *v247;
    AKAuthorizationRequest *v249;
    id v262;
    id v175;
    NSUInteger count2;
    uint8_t v130[48];
    @autoreleasepool {
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSArray<NSString *> *arguments = [processInfo arguments];
        if ([arguments count] < 2 || [arguments containsObject:@"--help"] || [arguments containsObject:@"-h"]) {
            AKPrintLine(@"Usage:\nauthenticate [-u <username>] [-p <password>] -c [securityupgradecontext] [-d altDSID] [-t <service-type>] [--forceUI | --noUI] [-r <reason>] [-a <proxied-app-id>] [-s <gs-service-token-id>] [--persistGSTokens] [--skipAlert] [--recoveryPET] [--forceInteractiveTest]\nrequest <url> [--paired]\nanisette (--display | --provision | --erase | --sync <sim-data>) [--paired]\neligibility <altDSID> -c [securityupgradecontext]\ncode\nreadCode\nverify -c <code> -u <username>\nping -u <username> [--liveness | --signout <service-type>]\naccountNames -a <altDSID>\nfollowup ([-i <item identifier>] [-urlKey <urlKey>] [-url <URL>] [-a <ak-action>] [-d <altDSID>] [-p <priority (0/1)>] [-f <frequency (s)> ] | --notify | --teardown | --sync <altDSID>)\nuserInfo -a <altDSID>\ndeviceList -a <altDSID> [--includeFamily]\nconfigInfo -a <altDSID> -i <identifier> [ -v <value> ]\nauthorize [-u <userIdentifier>] [-r <requested-scopes>] [-a <altDSID>] [--forceUI] [--skipBiometrics] [--requirePassword] [--iconAsBase64] [--iconScale=2.0] [--forceAppSignInDiscovery]\nappinfo -a <altDSID>\ncredentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]\nclearAuthorizationDatabase\nlocaluseruuid");
            return 0;
        }
        NSMutableDictionary *v4 = [[NSMutableDictionary alloc] init];
        if ([arguments count] != 0) {
            NSUInteger v6 = 1;
            do {
                NSString *key = [arguments objectAtIndexedSubscript:v6 - 1];
                if ([key hasPrefix:@"-"]) {
                    NSUInteger count = [arguments count];
                    if (v6 < count) {
                        NSString *v12 = [arguments objectAtIndexedSubscript:v6];
                        if ([v12 hasPrefix:@"-"]) {
                            v13 = @"";
                        } else {
                            v13 = v12;
                        }
                    } else {
                        [v4 setObject:@"" forKeyedSubscript:key];
                        goto blk_100002254;
                    }
                    [v4 setObject:v13 forKeyedSubscript:key];
                }
blk_100002254:
                count2 = [arguments count];
                v6++;
            } while (v6 < count2);
        }
        NSString *v14 = [arguments objectAtIndexedSubscript:1];
        NSString *lowercaseString = [v14 lowercaseString];
        if ([lowercaseString isEqual:@"authenticate"]) {
            id v17 = [v4 objectForKeyedSubscript:@"--persistGSTokens"];
            id v18 = [v4 objectForKeyedSubscript:@"-f"];
            id v19 = [v4 objectForKeyedSubscript:@"--forceUI"];
            id v20 = [v4 objectForKeyedSubscript:@"--noUI"];
            id v21 = [v4 objectForKeyedSubscript:@"--skipAlert"];
            id v22 = [v4 objectForKeyedSubscript:@"--recoveryPET"];
            id v24 = [v4 objectForKeyedSubscript:@"-u"];
            id v25 = [v4 objectForKeyedSubscript:@"-p"];
            id v26 = [v4 objectForKeyedSubscript:@"-s"];
            id v27 = [v4 objectForKeyedSubscript:@"-t"];
            id v28 = [v4 objectForKeyedSubscript:@"-a"];
            id v29 = [v4 objectForKeyedSubscript:@"-d"];
            id v30 = [v4 objectForKeyedSubscript:@"-r"];
            id v31 = [v4 objectForKeyedSubscript:@"-c"];
            id v32 = [v4 objectForKeyedSubscript:@"--forceInteractiveTest"];
            id v35 = [[(!v32) ? AKAppleIDAuthenticationCommandLineContext : AKAppleIDAuthenticationContext alloc] init];
            if (v24 != nil) {
                [v35 setUsername:v24];
                [v35 setIsUsernameEditable:0];
            }
            if (v31 != nil) {
                [v35 setShouldOfferSecurityUpgrade:1];
                [v35 setSecurityUpgradeContext:v31];
            }
            if (v29 != nil) {
                [v35 setAltDSID:v29];
            }
            if (v25 != nil) {
                [v35 _setPassword:v25];
            }
            if (v26 != nil) {
                [v35 setServiceIdentifier:v26];
            }
            if (v17 != nil) {
                [v35 setShouldUpdatePersistentServiceTokens:1];
            }
            if (v27) {
                v36 = [v27 integerValue];
            } else {
                v36 = 1;
            }
            [v35 setServiceType:v36];
            if (v30 != nil) {
                [v35 setReason:v30];
            }
            if (!v28) {
                if (v18 != nil) {
                    [v35 setNeedsCredentialRecovery:1];
                }
                if (v21 != nil) {
                    [v35 setShouldSkipSettingsLaunchAlert:1];
                }
                if (v22 != nil) {
                    [v35 setShouldRequestRecoveryPET:1];
                }
                if (v19) {
                    [v35 setAuthenticationType:2];
                } else if (v20 != nil) {
                    [v35 setAuthenticationType:1];
                }
                [[[AKAppleIDAuthenticationController alloc] init] authenticateWithContext:v35 completion:^void(NSDictionary *arg1, NSError *arg2) {
                    if (arg2 != nil) {
                        NSString *localizedDescription = [arg2 localizedDescription];
                        AKPrintLine(@"Error! %@", localizedDescription);
                        exit([arg2 code]);
                    }
                    AKPrintLine(@"Results: %@", arg1);
                    exit(0);
                }];
                CFRunLoopRun();
                return 0;
            }
            [v35 _setProxyingForApp:1];
            if ([v28 length] != 0) {
                [v35 _setProxiedAppBundleID:v28];
            }
            if (v18 != nil) {
                [v35 setNeedsCredentialRecovery:1];
            }
            if (v21 != nil) {
                [v35 setShouldSkipSettingsLaunchAlert:1];
            }
            if (v22 != nil) {
                [v35 setShouldRequestRecoveryPET:1];
            }
            if (v19) {
                [v35 setAuthenticationType:2];
            } else if (v20 != nil) {
                [v35 setAuthenticationType:1];
            }
            [[[AKAppleIDAuthenticationController alloc] init] authenticateWithContext:v35 completion:^void(NSDictionary *arg1, NSError *arg2) {
                if (arg2 != nil) {
                    NSString *localizedDescription = [arg2 localizedDescription];
                    AKPrintLine(@"Error! %@", localizedDescription);
                    exit([arg2 code]);
                }
                AKPrintLine(@"Results: %@", arg1);
                exit(0);
            }];
            CFRunLoopRun();
            return 0;
blk_100002be0:
            if (![lowercaseString isEqualToString:@"eligibility"]) {
                if ([lowercaseString isEqualToString:@"code"]) {
                    dispatch_semaphore_t dsema6 = dispatch_semaphore_create(0);
                    [[[AKAppleIDAuthenticationController alloc] init] generateLoginCodeWithCompletion:^void(NSNumber *arg1, NSError *arg2) {
                        if (!arg2) {
                            AKPrintLine(@"%06lu", [arg1 unsignedIntegerValue]);
                        } else {
                            AKPrintLine(@"Unable to generate code. %@", arg2);
                        }
                        dispatch_semaphore_signal(dsema6);
                    }];
                    dispatch_semaphore_wait(dsema6, DISPATCH_TIME_FOREVER);
                } else if ([lowercaseString isEqualToString:@"readcode"]) {
                    id v192 = [[[AKAppleIDAuthenticationController alloc] init] activeLoginCode:0];
                    if (v192 != nil) {
                        AKPrintLine(@"%@", v192);
                    }
                } else if ([lowercaseString isEqualToString:@"verify"]) {
                    if ([arguments count] > 3) {
                        id v188 = [v4 objectForKeyedSubscript:@"-c"];
                        id v189 = [v4 objectForKeyedSubscript:@"-u"];
                        if (![v188 length] || ![v189 length]) {
                            AKPrintLine(@"Usage: aktool verify -c <code> -u <username>");
                            return 0;
                        }
                        NSInteger integerValue2 = [v188 integerValue];
                        if (integerValue2 <= 0) {
                            AKPrintLine(@"%@ is not a valid code.", v188);
                        } else {
                            dispatch_semaphore_t dsema8 = dispatch_semaphore_create(0);
                            [[[AKAppleIDAuthenticationController alloc] init] validateLoginCode:integerValue2 forAppleID:v189 completion:^void(bool arg1, NSError *arg2) {
                                if (!arg2) {
                                    if (!arg1) {
                                        AKPrintLine(@"Your login code is invalid.");
                                    } else {
                                        AKPrintLine(@"Your login code is valid.");
                                    }
                                } else {
                                    AKPrintLine(@"Unable to validate code. %@", arg2);
                                }
                                dispatch_semaphore_signal(dsema8);
                            }];
                            dispatch_semaphore_wait(dsema8, DISPATCH_TIME_FOREVER);
                        }
                        return 0;
                    }
                    AKPrintLine(@"Usage: aktool verify -c <code> -u <username>");
                } else if ([lowercaseString isEqualToString:@"ping"]) {
                    if ([arguments count] > 2) {
                        v175 = [v4 objectForKeyedSubscript:@"-u"];
                        id v178 = [v4 objectForKeyedSubscript:@"--liveness"];
                        id v180 = [v4 objectForKeyedSubscript:@"--signout"];
                        if (![v175 length]) {
                            AKPrintLine(@"Usage: aktool ping -u <username> [--liveness | --signout <service-type>]");
                        } else if (!v178 || !v180) {
                            id v181 = v175;
                            dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
                            AKAppleIDAuthenticationController *v185 = [[AKAppleIDAuthenticationController alloc] init];
                            if (!v180) {
                                [v185 checkInWithAuthenticationServerForAppleID:v181 completion:^void(bool arg1, NSError *arg2) {
                                    if (!arg2) {
                                        AKPrintLine(@"Successfuly checked in!");
                                    } else {
                                        AKPrintLine(@"Unable to check in. %@", arg2);
                                    }
                                    dispatch_semaphore_signal(dsema);
                                }];
                            } else {
                                NSInteger integerValue = [v180 integerValue];
                                [v185 reportSignOutForAppleID:v181 service:integerValue completion:^void(bool arg1, NSError *arg2) {
                                    if (!arg2) {
                                        AKPrintLine(@"Successfuly reported signout!");
                                    } else {
                                        AKPrintLine(@"Unable to report signout. %@", arg2);
                                    }
                                    dispatch_semaphore_signal(dsema);
                                }];
                            }
                            dispatch_semaphore_wait(dsema, DISPATCH_TIME_FOREVER);
                        } else {
                            AKPrintLine(@"Only one of --liveness or --signout can be specified for a ping.");
                        }
                    } else {
                        AKPrintLine(@"Usage: aktool ping -u <username> [--liveness | --signout <service-type>]");
                    }
                } else if ([lowercaseString isEqualToString:@"accountnames"]) {
                    if ([arguments count] > 2) {
                        v175 = [v4 objectForKeyedSubscript:@"-a"];
                        if (![v175 length]) {
                            AKPrintLine(@"Usage: aktool accountNames -a <altDSID>");
                        } else {
                            id v176 = v175;
                            id v179 = [[[AKAppleIDAuthenticationController alloc] init] accountNamesForAltDSID:v176];
                            AKPrintLine(@"Account names associated with %@: \n%@", v176, v179);
                        }
                    } else {
                        AKPrintLine(@"Usage: aktool accountNames -a <altDSID>");
                    }
                } else if ([lowercaseString isEqualToString:@"followup"]) {
                    id v121 = [v4 objectForKeyedSubscript:@"--sync"];
                    if (!v121) {
                        id v122 = [v4 objectForKeyedSubscript:@"-i"];
                        id v123 = [v4 objectForKeyedSubscript:@"-a"];
                        id v124 = [v4 objectForKeyedSubscript:@"-urlKey"];
                        id v125 = [v4 objectForKeyedSubscript:@"-url"];
                        id v126 = [v4 objectForKeyedSubscript:@"-d"];
                        id v127 = [v4 objectForKeyedSubscript:@"-f"];
                        [v4 objectForKeyedSubscript:@"-p"];
                        bool v141 = !v122 || !v126;
                        if (!v141) {
                            id v171 = [v4 objectForKeyedSubscript:@"--teardown"];
                            v141 = !v171;
                        }
                        if (v141) {
                            if (!v122 || !v124) {
                                AKPrintLine(@"Usage:\nauthenticate [-u <username>] [-p <password>] -c [securityupgradecontext] [-d altDSID] [-t <service-type>] [--forceUI | --noUI] [-r <reason>] [-a <proxied-app-id>] [-s <gs-service-token-id>] [--persistGSTokens] [--skipAlert] [--recoveryPET] [--forceInteractiveTest]\nrequest <url> [--paired]\nanisette (--display | --provision | --erase | --sync <sim-data>) [--paired]\neligibility <altDSID> -c [securityupgradecontext]\ncode\nreadCode\nverify -c <code> -u <username>\nping -u <username> [--liveness | --signout <service-type>]\naccountNames -a <altDSID>\nfollowup ([-i <item identifier>] [-urlKey <urlKey>] [-url <URL>] [-a <ak-action>] [-d <altDSID>] [-p <priority (0/1)>] [-f <frequency (s)> ] | --notify | --teardown | --sync <altDSID>)\nuserInfo -a <altDSID>\ndeviceList -a <altDSID> [--includeFamily]\nconfigInfo -a <altDSID> -i <identifier> [ -v <value> ]\nauthorize [-u <userIdentifier>] [-r <requested-scopes>] [-a <altDSID>] [--forceUI] [--skipBiometrics] [--requirePassword] [--iconAsBase64] [--iconScale=2.0] [--forceAppSignInDiscovery]\nappinfo -a <altDSID>\ncredentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]\nclearAuthorizationDatabase\nlocaluseruuid");
                            } else {
                                void *v129 = &v130;
                                AKFollowUpFactoryImpl *v132 = [[AKFollowUpFactoryImpl alloc] init];
                                v48 = v122;
                                v129->field_56 = @"aktool follow up";
                                v129->field_64 = @"aktool follow up message";
                                *(v129) = @"id";
                                v129->field_8 = @"title";
                                v129->field_16 = @"body";
                                v129->field_24 = @"priority";
                                *(uint64_t *)&v130[32] = @"actions";
                                v91 = @"title";
                                v91.field_8 = 0;
                                NSDictionary<NSString *, id> *v135 = @{@"title": @"Extension Action", @"urlKey": v124};
                                NSDictionary *v140 = @{v91 & 0xffffffffffffffff: @"Extension URL Action", @"url": (!v125) ? @"http://www.apple.com" : v125};
                                NSDictionary *v145 = @{v91 & 0xffffffffffffffff: @"AK Action", @"AKAction": (!v123) ? AKActionDelete : v123};
                                NSDictionary *v148 = [NSDictionary dictionaryWithObjects:&v48 forKeys:(id<NSCopying> *)v130 count:5];
                                v91 = @selector(arrayWithObjects:count:);
                                NSArray<NSDictionary *> *v150 = @[v148];
                                id v151 = [v132 itemsForAltDSID:v126 fromIDMSPayload:v150];
                                id firstObject = [v151 firstObject];
                                id v154 = [v4 objectForKeyedSubscript:@"--notify"];
                                if (v154 != nil) {
                                    id v155 = qword_10000c528(v154);
                                    id v156 = [v155 alloc];
                                    [firstObject setNotification:[v156 init]];
                                    UNNotification *notification = [firstObject notification];
                                    [notification setTitle:@"aktool notification"];
                                    UNNotification *notification2 = [firstObject notification];
                                    [notification2 setInformativeText:@"aktool notification body"];
                                    double doubleValue = [v127 doubleValue];
                                    UNNotification *notification3 = [firstObject notification];
                                    [notification3 setFrequency:doubleValue];
                                    id v162 = [[qword_10000c530(notification3) alloc] init];
                                    UNNotification *notification4 = [firstObject notification];
                                    [notification4 setClearAction:v162];
                                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                                    [dictionary setObject:AKFollowUpActionClear forKeyedSubscript:AKActionKey];
                                    UNNotification *notification5 = [firstObject notification];
                                    id clearAction = [notification5 clearAction];
                                    [clearAction setUserInfo:dictionary];
                                }
                                AKFollowUpProviderImpl *v168 = [[AKFollowUpProviderImpl alloc] init];
                                NSArray *v170 = @[firstObject];
                                [v168 addFollowUpItems:v170 error:0];
                            }
                        } else {
                            AKAppleIDAuthenticationController *v212 = [[AKAppleIDAuthenticationController alloc] init];
                            AKFollowUpTearDownContext *v213 = [[AKFollowUpTearDownContext alloc] init];
                            [v213 setItemIdentifier:v122];
                            [v213 setAkAction:AKActionDelete];
                            [v213 setAltDSID:v126];
                            dispatch_semaphore_t dsema2 = dispatch_semaphore_create(0);
                            [v212 teardownFollowUpWithContext:v213 completion:^void(bool arg1, NSError *arg2) {
                                dispatch_semaphore_signal(dsema2);
                            }];
                            dispatch_semaphore_wait(dsema2, DISPATCH_TIME_FOREVER);
                            return 0;
                        }
                    } else if (![v121 length]) {
                        AKPrintLine(@"Usage: aktool followup --sync <altDSID>");
                    } else {
                        AKAppleIDAuthenticationController *v173 = [[AKAppleIDAuthenticationController alloc] init];
                        AKAppleIDAuthenticationContext *v174 = [[AKAppleIDAuthenticationContext alloc] init];
                        [v174 setAltDSID:v121];
                        [v173 synchronizeFollowUpItemsForContext:v174 error:0];
                    }
                } else if ([lowercaseString isEqualToString:@"userinfo"]) {
                    v262 = [v4 objectForKeyedSubscript:@"-a"];
                    if (![v262 length]) {
                        AKPrintLine(@"Usage: aktool userInfo -a <altDSID>");
                        return 0;
                    }
                    id v116 = v262;
                    dispatch_semaphore_t dsema5 = dispatch_semaphore_create(0);
                    [[[AKAppleIDAuthenticationController alloc] init] fetchUserInformationForAltDSID:v116 completion:^void(NSDictionary *arg1, NSError *arg2) {
                        if (!arg2) {
                            AKPrintLine(@"Successfully fetched user information: %@", arg1);
                        } else {
                            AKPrintLine(@"Failed to fetch user information, error: %@", arg2);
                        }
                        dispatch_semaphore_signal(dsema5);
                    }];
                    dispatch_semaphore_wait(dsema5, DISPATCH_TIME_FOREVER);
                } else if (![lowercaseString isEqualToString:@"appinfo"]) {
                    if (![lowercaseString isEqualToString:@"devicelist"]) {
                        if (![lowercaseString isEqualToString:@"configinfo"]) {
                            if ([lowercaseString isEqualToString:@"authorize"]) {
                                id v82 = [v4 objectForKeyedSubscript:@"-a"];
                                id v83 = [v4 objectForKeyedSubscript:@"-r"];
                                NSArray<NSString *> *v84 = [v83 componentsSeparatedByString:@","];
                                id v85 = [v4 objectForKeyedSubscript:@"-u"];
                                id v86 = [v4 objectForKeyedSubscript:@"--localizedAppName"];
                                id v87 = [v4 objectForKeyedSubscript:@"--iconName"];
                                id v88 = [v4 objectForKeyedSubscript:@"--informativeText"];
                                if (![v4 objectForKeyedSubscript:@"--forceAppSignInDiscovery"]) {
                                    id v90 = [v4 objectForKeyedSubscript:@"--forceUI"];
                                    v91 = [v4 objectForKeyedSubscript:@"--skipBiometrics"];
                                    id v92 = [v4 objectForKeyedSubscript:@"--requirePassword"];
                                    id v93 = [v4 objectForKeyedSubscript:@"--isFirstPartyLogin"];
                                    if (![AKAuthorizationController canPerformAuthorization]) {
                                        return 0;
                                    }
                                    v247 = [[AKCredentialRequestContext alloc] init];
                                    [v247 set_shouldForceUI:v90 != nil];
                                    [v247 set_shouldSkipBiometrics:v91 != nil];
                                    [v247 set_requirePassword:v92 != nil];
                                    [v247 set_isFirstPartyLogin:v93 != nil];
                                    if ([v86 length] != 0) {
                                        [v247 set_proxiedClientAppName:v86];
                                    }
                                    if ([v87 length] != 0) {
                                        [v247 set_iconName:v87];
                                    }
                                    if ([v88 length] != 0) {
                                        [v247 set_informativeText:v88];
                                    }
                                    v249 = [[AKAuthorizationRequest alloc] init];
                                    [v249 setRequestedScopes:v84];
                                    if (!v85) {
                                        if (v82 != nil) {
                                            id sharedInstance = [AKAccountManager sharedInstance];
                                            id v251 = [sharedInstance authKitAccountWithAltDSID:v82];
                                            [v249 setAuthkitAccount:v251];
                                            goto blk_100004f28;
                                        } else {
                                            goto blk_100004f28;
                                        }
                                    }
                                    [v249 setUserIdentifier:v85];
                                    goto blk_100004f28;
                                }
                                dispatch_semaphore_t dsema4 = dispatch_semaphore_create(0);
                                AKPrintLine(@"Starting AppSignIn discovery...");
                                [[[AKAuthorizationAppSignInDiscovery alloc] init] startDiscoveryWithCompletion:^void(bool arg1, NSError *arg2) {
                                    if (!arg1) {
                                        AKPrintLine(@"AppSignIn failed. %@", arg2);
                                    } else {
                                        AKPrintLine(@"AppSignIn discovery completed.");
                                    }
                                    dispatch_semaphore_signal(dsema4);
                                }];
                                dispatch_semaphore_wait(dsema4, DISPATCH_TIME_FOREVER);
                            } else if ([lowercaseString isEqualToString:@"credentialstate"]) {
                                v261 = [v4 objectForKeyedSubscript:@"-u"];
                                v264 = [v4 objectForKeyedSubscript:@"-t"];
                                v81 = [v4 objectForKeyedSubscript:@"-c"];
                                if (!v261) {
                                    AKPrintLine(@"Cannot fetch credential status for nil User identifier");
                                    if (v264 != nil) {
                                        goto blk_100004798;
                                    }
                                    goto blk_100004d04;
                                }
                                if (!v264) {
                                    goto blk_100004d04;
                                }
                                goto blk_100004798;
                            } else if ([lowercaseString isEqualToString:@"clearauthorizationdatabase"]) {
                                AKAppleIDAuthenticationController *v260 = [[AKAppleIDAuthenticationController alloc] init];
                                v48 = nil;
                                long v80 = [v260 deleteAuthorizationDatabase:&v48];
                                void (^v263)(NSData *, NSURLResponse *, NSError *) = v48;
                                if (!v80) {
                                    AKPrintLine(@"Authorization Database deletion failed with error:", v263);
                                    return 0;
                                }
                                AKPrintLine(@"Authorization Database successfully deleted");
                            } else if (![lowercaseString isEqualToString:@"localuseruuid"]) {
                                AKPrintLine(@"Usage:\nauthenticate [-u <username>] [-p <password>] -c [securityupgradecontext] [-d altDSID] [-t <service-type>] [--forceUI | --noUI] [-r <reason>] [-a <proxied-app-id>] [-s <gs-service-token-id>] [--persistGSTokens] [--skipAlert] [--recoveryPET] [--forceInteractiveTest]\nrequest <url> [--paired]\nanisette (--display | --provision | --erase | --sync <sim-data>) [--paired]\neligibility <altDSID> -c [securityupgradecontext]\ncode\nreadCode\nverify -c <code> -u <username>\nping -u <username> [--liveness | --signout <service-type>]\naccountNames -a <altDSID>\nfollowup ([-i <item identifier>] [-urlKey <urlKey>] [-url <URL>] [-a <ak-action>] [-d <altDSID>] [-p <priority (0/1)>] [-f <frequency (s)> ] | --notify | --teardown | --sync <altDSID>)\nuserInfo -a <altDSID>\ndeviceList -a <altDSID> [--includeFamily]\nconfigInfo -a <altDSID> -i <identifier> [ -v <value> ]\nauthorize [-u <userIdentifier>] [-r <requested-scopes>] [-a <altDSID>] [--forceUI] [--skipBiometrics] [--requirePassword] [--iconAsBase64] [--iconScale=2.0] [--forceAppSignInDiscovery]\nappinfo -a <altDSID>\ncredentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]\nclearAuthorizationDatabase\nlocaluseruuid");
                            } else {
                                id currentDevice = [AKDevice currentDevice];
                                id localUserUUID = [currentDevice localUserUUID];
                                AKPrintLine(@"localUserUUID %@", localUserUUID);
                            }
                            return 0;
                        }
                        v261 = [v4 objectForKeyedSubscript:@"-a"];
                        v264 = [v4 objectForKeyedSubscript:@"-i"];
                        v81 = [v4 objectForKeyedSubscript:@"-v"];
                        if (![v261 length]) {
blk_1000046fc:
                            AKPrintLine(@"Usage: aktool configInfo -a <altDSID> -i <identifier> [ -v <value> ]");
                            return 0;
                        }
                        if (![v264 length]) {
                            goto blk_1000046fc;
                        }
                        if (![v81 length]) {
                            id v216 = v261;
                            id v217 = v264;
                            dispatch_semaphore_t dsema9 = dispatch_semaphore_create(0);
                            AKAppleIDAuthenticationController *v220 = [[AKAppleIDAuthenticationController alloc] init];
                            NSArray *v221 = @[v217];
                            [v220 configurationInfoWithIdentifiers:v221 forAltDSID:v216 completion:^void(NSDictionary *arg1, NSError *arg2) {
                                if (!arg2) {
                                    AKPrintLine(@"Successfully fetched configuration information: %@", arg1);
                                } else {
                                    AKPrintLine(@"Failed to fetch configuration information, error: %@", arg2);
                                }
                                dispatch_semaphore_signal(dsema9);
                            }];
                            dispatch_semaphore_wait(dsema9, DISPATCH_TIME_FOREVER);
                            return 0;
                        }
                        NSData *v223 = [v81 dataUsingEncoding:NSUTF8StringEncoding];
                        NSError *v224 = nil;
                        id v225 = [NSJSONSerialization JSONObjectWithData:v223 options:NSJSONReadingFragmentsAllowed error:&v224];
                        if (!v224) {
                            id v227 = v261;
                            id v228 = v264;
                            id v229 = v225;
                            dispatch_semaphore_t dsema10 = dispatch_semaphore_create(0);
                            AKAppleIDAuthenticationController *v232 = [[AKAppleIDAuthenticationController alloc] init];
                            id v233 = v229;
                            [v232 setConfigurationInfo:v233 forIdentifier:v228 forAltDSID:v227 completion:^void(bool arg1, NSError *arg2) {
                                if (!arg2) {
                                    AKPrintLine(@"Successfully set configuration information: %@ forIdentifier: %@", v229, v228);
                                } else {
                                    AKPrintLine(@"Failed to set configuration information, error: %@", arg2);
                                }
                                dispatch_semaphore_signal(dsema10);
                            }];
                            dispatch_semaphore_wait(dsema10, DISPATCH_TIME_FOREVER);
                        } else {
                            AKPrintLine(@"Failed to process value, error: %@", v224);
                        }
                        return 0;
                    }
                    v262 = [v4 objectForKeyedSubscript:@"-a"];
                    id v105 = [v4 objectForKeyedSubscript:@"--includeFamily"];
                    if (!v262) {
                        AKPrintLine(@"Usage: aktool devicelist -a <altDSID> [--includeFamily] ");
                    } else {
                        AKAppleIDAuthenticationController *v108 = [[AKAppleIDAuthenticationController alloc] init];
                        AKDeviceListRequestContext *v109 = [[AKDeviceListRequestContext alloc] init];
                        [v109 setAltDSID:v262];
                        [v109 setIncludeFamilyDevices:v105 != nil];
                        v48 = nil;
                        id v110 = [v108 fetchDeviceListWithContext:v109 error:&v48];
                        AKAppleIDAuthenticationController *v111 = v48;
                        if (!v110) {
                            AKPrintLine(@"Failed to fetch user information, error: %@", v111);
                        } else {
                            AKPrintLine(@"Successfully fetched user information: %@", v110);
                        }
                    }
                } else {
                    v262 = [v4 objectForKeyedSubscript:@"-a"];
                    if (![v262 length]) {
                        AKPrintLine(@"Usage: aktool appinfo -a <altDSID>");
                        return 0;
                    }
                    id v112 = v262;
                    AKAppleIDAuthenticationController *v265 = [[AKAppleIDAuthenticationController alloc] init];
                    v48 = nil;
                    id v114 = [v265 fetchAuthorizedAppListWithContext:v112 error:&v48];
                    void (^v115)(NSData *, NSURLResponse *, NSError *) = v48;
                    if (!v114) {
                        AKPrintLine(@"Failed to fetch app information, error: %@", v115);
                    } else {
                        AKPrintLine(@"Successfully fetched app information: %@", v114);
                    }
                }
                return 0;
            }
            if ([arguments count] > 2) {
                NSString *v195 = [arguments objectAtIndexedSubscript:2];
                dispatch_semaphore_t dsema7 = dispatch_semaphore_create(0);
                AKAppleIDAuthenticationContext *v199 = [[AKAppleIDAuthenticationContext alloc] init];
                [v199 setAltDSID:v195];
                id v200 = [v4 objectForKeyedSubscript:@"-c"];
                if (v200 != nil) {
                    id v201 = [v4 objectForKeyedSubscript:@"-c"];
                    [v199 setSecurityUpgradeContext:v201];
                }
                [[[AKAppleIDAuthenticationController alloc] init] checkSecurityUpgradeEligibilityForContext:v199 completion:^void(bool arg1, NSError *arg2) {
                    if (!arg2) {
                        if (!arg1) {
                            AKPrintLine(@"%@ is not eligible for HSA 2.0", v195);
                        } else {
                            AKPrintLine(@"%@ is eligible for HSA 2.0.", v195);
                        }
                    } else {
                        AKPrintLine(@"Unable to check eligibility. %@", arg2);
                    }
                    dispatch_semaphore_signal(dsema7);
                }];
                dispatch_semaphore_wait(dsema7, DISPATCH_TIME_FOREVER);
                return 0;
            }
            AKPrintLine(@"Usage: aktool eligibility <altDSID>");
            return 0;
blk_100004798:
            if (v81 != nil) {
blk_10000479c:
                if (!v261 || !v264) {
                    goto blk_100004d20;
                }
                id v236 = v81;
                if (([AKAuthorizationController canPerformAuthorization] & 1) == 0) {
                    AKPrintLine(@"Cannot Perform Authorization operations on the current device");
                    return 0;
                }
                AKAuthorizationCredentialStateRequest *v238 = [[AKAuthorizationCredentialStateRequest alloc] init];
                [v238 setUserID:v261];
                [v238 setTeamID:v264];
                [v238 setClientID:v236];
                AKAuthorizationController *v239 = [[AKAuthorizationController alloc] init];
                dispatch_semaphore_t dsema11 = dispatch_semaphore_create(0);
                [v239 getCredentialStateForRequest:v238 completion:^void(long arg1, NSError *arg2) {
                    dispatch_semaphore_signal(dsema11);
                }];
                dispatch_semaphore_wait(dsema11, DISPATCH_TIME_FOREVER);
                return 0;
blk_100004d04:
                AKPrintLine(@"Cannot fetch credential status for nil Team identifier");
                if (v81 != nil) {
                    goto blk_10000479c;
                }
            }
            AKPrintLine(@"Cannot fetch credential status for nil Client identifier");
blk_100004d20:
            AKPrintLine(@"credentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]");
            return 0;
blk_100004f28:
            AKPasswordRequest *v252 = [AKPasswordRequest alloc];
            AKPasswordRequest *v253 = [v252 init];
            [v247 setAuthorizationRequest:v249];
            [v247 setPasswordRequest:v253];
            AKAuthorizationController *v254 = [[AKAuthorizationController alloc] init];
            dispatch_semaphore_t dsema3 = dispatch_semaphore_create(0);
            v48 = ^void(AKAuthorization *arg1, NSError *arg2) {
                if (!arg1) {
                    AKPrintLine(@"Authorization failed with error: %@", arg2);
                } else {
                    id credential = [arg1 credential];
                    BOOL v282 = [credential isKindOfClass:[AKPasswordCredential class]];
                    if (!v282) {
                        AKPrintLine(@"Authorization succeeded with credential: %@", arg1);
                    } else {
                        id credential2 = [arg1 credential];
                        id userIdentifier = [credential2 userIdentifier];
                        id credential3 = [arg1 credential];
                        NSString *password = [credential3 password];
                        AKPrintLine(@"Authorization succeeded with username %@ and password: %@", userIdentifier, (!password) ? nil : @"******");
                    }
                }
                dispatch_semaphore_signal(dsema3);
            };
            [v254 performAuthorizationWithContext:v247 completion:v48];
            dispatch_semaphore_wait(dsema3, DISPATCH_TIME_FOREVER);
        } else if ([lowercaseString isEqual:@"request"]) {
            id v16 = [v4 objectForKeyedSubscript:@"--paired"];
            if ([arguments count] >= 3 && [arguments count] < 5) {
                NSString *v39 = [arguments objectAtIndexedSubscript:2];
                NSURL *v40 = [NSURL URLWithString:v39];
                if (!v40) {
                    AKPrintLine(@"Error ! Not a valid URL: %@", v39);
                    return 0;
                }
                NSURLRequest *request = [NSURLRequest requestWithURL:v40];
                NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AKAppleIDSession *v44 = [[AKAppleIDSession alloc] init];
                if (v16 != nil) {
                    AKPrintLine(@"Will append paired device Anisette headers.");
                    id activeIDSPeerDevice = [AKDevice activeIDSPeerDevice];
                    [v44 setPairedDevice:activeIDSPeerDevice];
                }
                [defaultSessionConfiguration set_appleIDContext:v44];
                NSURLSession *v46 = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
                dispatch_semaphore_t dsema12 = dispatch_semaphore_create(0);
                AKPrintLine(@"Requesting %@...", v39);
                v48 = ^void(NSData *arg1, NSURLResponse *arg2, NSError *arg3) {
                    if (!arg3) {
                        NSInteger statusCode = [arg2 statusCode];
                        NSNumber *v3 = [NSNumber numberWithInteger:statusCode];
                        NSDictionary *allHeaderFields = [arg2 allHeaderFields];
                        AKPrintLine(@"Response code: %@\nResponse headers: %@", v3, allHeaderFields);
                    } else {
                        NSString *localizedDescription = [arg3 localizedDescription];
                        NSInteger statusCode2 = [arg2 statusCode];
                        NSNumber *v8 = [NSNumber numberWithInteger:statusCode2];
                        AKPrintLine(@"Request failed! Error: %@. Response code: %@", localizedDescription, v8);
                    }
                    dispatch_semaphore_signal(dsema12);
                };
                NSURLSessionDataTask *v50 = [v46 dataTaskWithRequest:request completionHandler:v48];
                [v50 resume];
                dispatch_semaphore_wait(dsema12, DISPATCH_TIME_FOREVER);
                return 0;
            }
            AKPrintLine(@"Usage: aktool request <url> [--paired]");
        } else if (![lowercaseString isEqual:@"anisette"]) {
            if ([lowercaseString isEqualToString:@"environment"]) {
                AKPrintLine(@"This command is no longer supported. Please use switchcl for all your environment switching needs.");
                return 0;
            }
            if (![lowercaseString isEqualToString:@"env"]) {
                goto blk_100002be0;
            }
            AKPrintLine(@"This command is no longer supported. Please use switchcl for all your environment switching needs.");
        } else {
            if ([arguments count] < 3) {
                AKPrintLine(@"Usage: aktool anisette (--provision | --sync <srm-data> | --display | --erase) [--paired]");
                return 0;
            }
            if ([arguments count] < 7) {
                id v51 = [v4 objectForKeyedSubscript:@"--provision"];
                id v52 = [v4 objectForKeyedSubscript:@"--display"];
                id v53 = [v4 objectForKeyedSubscript:@"--erase"];
                NSString *v54 = [v4 objectForKeyedSubscript:@"--sync"];
                id v55 = [v4 objectForKeyedSubscript:@"--paired"];
                if (!v51) {
                    if (v54) {
                        if (![v54 length]) {
                            AKPrintLine(@"Usage: aktool anisette --sync <srm-data>");
                            return 0;
                        }
                        AKPrintLine(@"Syncing Anisette...");
                        NSData *v68 = [[NSData alloc] initWithBase64EncodedString:v54 options:0];
                        dispatch_semaphore_t dsema13 = dispatch_semaphore_create(0);
                        AKAnisetteProvisioningController *v70 = [AKAnisetteProvisioningController alloc];
                        if (v55) {
                            v71 = [v70 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                        } else {
                            v71 = [v70 init];
                        }
                        [v71 syncWithSIMData:v68 completion:^void(bool arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Sync failed! %@", arg2);
                            } else {
                                AKPrintLine(@"Sync succeeded!");
                            }
                            dispatch_semaphore_signal(dsema13);
                        }];
                        dispatch_semaphore_wait(dsema13, DISPATCH_TIME_FOREVER);
                    } else if (v52) {
                        dispatch_semaphore_t v62 = dispatch_semaphore_create(0);
                        if (!v55) {
                            v258 = [[AKAnisetteProvisioningController alloc] init];
                        } else {
                            id activeIDSPeerDevice2 = [AKDevice activeIDSPeerDevice];
                            AKPrintLine(@"Pulling data from %@...", activeIDSPeerDevice2);
                            v258 = [[AKAnisetteProvisioningController alloc] initForDevice:activeIDSPeerDevice2 provider:0];
                        }
                        v61 = v62;
                        [v258 fetchAnisetteDataAndProvisionIfNecessary:0 withCompletion:^void(AKAnisetteData *arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Fetch failed! %@", arg2);
                            } else {
                                AKPrintLine(@"%@", arg1);
                            }
                            dispatch_semaphore_signal(v62);
                        }];
                        dispatch_semaphore_wait(v61, DISPATCH_TIME_FOREVER);
                    } else if (!v53) {
                        AKPrintLine(@"Usage: aktool anisette (--provision | --sync <srm-data> | --display | --erase) [--paired]");
                    } else {
                        AKPrintLine(@"Erasing Anisette provisioning data...");
                        v56 = dispatch_semaphore_create(0);
                        AKAnisetteProvisioningController *v57 = [AKAnisetteProvisioningController alloc];
                        if (v55) {
                            v58 = [v57 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                        } else {
                            v58 = [v57 init];
                        }
                        v61 = v56;
                        [v58 eraseWithCompletion:^void(bool arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Failed! %@", arg2);
                            } else {
                                AKPrintLine(@"Erased successfully!");
                            }
                            dispatch_semaphore_signal(v56);
                        }];
                        dispatch_semaphore_wait(v61, DISPATCH_TIME_FOREVER);
                    }
                    return 0;
                }
                AKPrintLine(@"Kicking off Anisette provisioning...");
                v56 = dispatch_semaphore_create(0);
                AKAnisetteProvisioningController *v74 = [AKAnisetteProvisioningController alloc];
                if (v55) {
                    v259 = [v74 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                } else {
                    v259 = [v74 init];
                }
                v61 = v56;
                v48 = ^void(bool arg1, NSError *arg2) {
                    if (!arg1) {
                        AKPrintLine(@"Provisioning failed! %@", arg2);
                    } else {
                        AKPrintLine(@"Provisioning succeeded!");
                    }
                    dispatch_semaphore_signal(v56);
                };
                [v259 provisionWithCompletion:v48];
                dispatch_semaphore_wait(v61, DISPATCH_TIME_FOREVER);
                return 0;
            }
            AKPrintLine(@"Usage: aktool anisette (--provision | --sync <srm-data> | --display | --erase) [--paired]");
        }
        return 0;
    }
}


Class sub_100005094(void)
{
    if (!qword_10000c540) {
        qword_10000c540 = dlopen("/System/Library/PrivateFrameworks/CoreFollowUp.framework/CoreFollowUp", 2);
    }
    qword_10000c538 = objc_getClass("FLFollowUpNotification");
    qword_10000c528 = &sub_1000050f0;
    return qword_10000c538;
}


Class sub_1000050f0(void)
{
    return qword_10000c538;
}


Class sub_1000050fc(void)
{
    if (!qword_10000c540) {
        qword_10000c540 = dlopen("/System/Library/PrivateFrameworks/CoreFollowUp.framework/CoreFollowUp", 2);
    }
    qword_10000c548 = objc_getClass("FLFollowUpAction");
    qword_10000c530 = &sub_100005158;
    return qword_10000c548;
}


Class sub_100005158(void)
{
    return qword_10000c548;
}
