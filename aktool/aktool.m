static Class qword_10000c538;
static Class qword_10000c548;
static long qword_10000c528;
static long qword_10000c530;
static void *qword_10000c540;

int sub_10000200c(void)
{
    NSString *v14;
    void (^v50)(AKAuthorization *, NSError *);
    id v268;
    id v271;
    id v83;
    id v93;
    AKCredentialRequestContext *v254;
    AKAuthorizationRequest *v256;
    id v269;
    id v178;
    dispatch_semaphore_t v58;
    AKAnisetteProvisioningController *v60;
    dispatch_semaphore_t v63;
    AKAnisetteProvisioningController *v265;
    AKAnisetteProvisioningController *v73;
    AKAnisetteProvisioningController *v266;
    NSInteger v38;
    NSUInteger count2;
    uint8_t v133[48];
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
                    if (v6 >= count) {
                        [v4 setObject:@"" forKeyedSubscript:key];
                    } else {
                        NSString *v13 = [arguments objectAtIndexedSubscript:v6];
                        if ([v13 hasPrefix:@"-"]) {
                            v14 = @"";
                        } else {
                            v14 = v13;
                        }
                        [v4 setObject:v14 forKeyedSubscript:key];
                    }
                }
                count2 = [arguments count];
                v6++;
            } while (v6 < count2);
        }
        NSString *v15 = [arguments objectAtIndexedSubscript:1];
        NSString *lowercaseString = [v15 lowercaseString];
        if ([lowercaseString isEqual:@"authenticate"]) {
            id v18 = [v4 objectForKeyedSubscript:@"--persistGSTokens"];
            id v19 = [v4 objectForKeyedSubscript:@"-f"];
            id v20 = [v4 objectForKeyedSubscript:@"--forceUI"];
            id v21 = [v4 objectForKeyedSubscript:@"--noUI"];
            id v22 = [v4 objectForKeyedSubscript:@"--skipAlert"];
            id v23 = [v4 objectForKeyedSubscript:@"--recoveryPET"];
            id v25 = [v4 objectForKeyedSubscript:@"-u"];
            id v26 = [v4 objectForKeyedSubscript:@"-p"];
            id v27 = [v4 objectForKeyedSubscript:@"-s"];
            id v28 = [v4 objectForKeyedSubscript:@"-t"];
            id v29 = [v4 objectForKeyedSubscript:@"-a"];
            id v31 = [v4 objectForKeyedSubscript:@"-d"];
            id v32 = [v4 objectForKeyedSubscript:@"-r"];
            id v33 = [v4 objectForKeyedSubscript:@"-c"];
            id v34 = [v4 objectForKeyedSubscript:@"--forceInteractiveTest"];
            id v37 = [[(!v34) ? AKAppleIDAuthenticationCommandLineContext : AKAppleIDAuthenticationContext alloc] init];
            if (v25 != nil) {
                [v37 setUsername:v25];
                [v37 setIsUsernameEditable:0];
            }
            if (v33 != nil) {
                [v37 setShouldOfferSecurityUpgrade:1];
                [v37 setSecurityUpgradeContext:v33];
            }
            if (v31 != nil) {
                [v37 setAltDSID:v31];
            }
            if (v26 != nil) {
                [v37 _setPassword:v26];
            }
            if (v27 != nil) {
                [v37 setServiceIdentifier:v27];
            }
            if (v18 != nil) {
                [v37 setShouldUpdatePersistentServiceTokens:1];
            }
            if (v28) {
                v38 = [v28 integerValue];
            } else {
                v38 = 1;
            }
            [v37 setServiceType:v38];
            if (v32 != nil) {
                [v37 setReason:v32];
            }
            if (!v29) {
                if (v19 != nil) {
                    [v37 setNeedsCredentialRecovery:1];
                }
                if (v22 != nil) {
                    [v37 setShouldSkipSettingsLaunchAlert:1];
                }
                if (v23 != nil) {
                    [v37 setShouldRequestRecoveryPET:1];
                }
                if (v20) {
                    [v37 setAuthenticationType:2];
                } else if (v21 != nil) {
                    [v37 setAuthenticationType:1];
                }
                [[[AKAppleIDAuthenticationController alloc] init] authenticateWithContext:v37 completion:^void(NSDictionary *arg1, NSError *arg2) {
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
            [v37 _setProxyingForApp:1];
            if ([v29 length] != 0) {
                [v37 _setProxiedAppBundleID:v29];
            }
            if (v19 != nil) {
                [v37 setNeedsCredentialRecovery:1];
            }
            if (v22 != nil) {
                [v37 setShouldSkipSettingsLaunchAlert:1];
            }
            if (v23 != nil) {
                [v37 setShouldRequestRecoveryPET:1];
            }
            if (v20) {
                [v37 setAuthenticationType:2];
            } else if (v21 != nil) {
                [v37 setAuthenticationType:1];
            }
            [[[AKAppleIDAuthenticationController alloc] init] authenticateWithContext:v37 completion:^void(NSDictionary *arg1, NSError *arg2) {
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
blk_100004798:
            if (v83 != nil) {
blk_10000479c:
                if (!v268 || !v271) {
                    AKPrintLine(@"credentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]");
                    return 0;
                }
                if (([AKAuthorizationController canPerformAuthorization] & 1) == 0) {
                    AKPrintLine(@"Cannot Perform Authorization operations on the current device");
                    return 0;
                }
                AKAuthorizationCredentialStateRequest *v245 = [[AKAuthorizationCredentialStateRequest alloc] init];
                [v245 setUserID:v268];
                [v245 setTeamID:v271];
                [v245 setClientID:v83];
                AKAuthorizationController *v246 = [[AKAuthorizationController alloc] init];
                dispatch_semaphore_t dsema11 = dispatch_semaphore_create(0);
                [v246 getCredentialStateForRequest:v245 completion:^void(long arg1, NSError *arg2) {
                    dispatch_semaphore_signal(dsema11);
                }];
                dispatch_semaphore_wait(dsema11, DISPATCH_TIME_FOREVER);
                return 0;
blk_100004d04:
                AKPrintLine(@"Cannot fetch credential status for nil Team identifier");
                if (v83 != nil) {
                    goto blk_10000479c;
                }
            }
            AKPrintLine(@"Cannot fetch credential status for nil Client identifier");
            AKPrintLine(@"credentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]");
            return 0;
blk_100004f28:
            AKPasswordRequest *v259 = [AKPasswordRequest alloc];
            AKPasswordRequest *v260 = [v259 init];
            [v254 setAuthorizationRequest:v256];
            [v254 setPasswordRequest:v260];
            AKAuthorizationController *v261 = [[AKAuthorizationController alloc] init];
            dispatch_semaphore_t dsema3 = dispatch_semaphore_create(0);
            v50 = ^void(AKAuthorization *arg1, NSError *arg2) {
                if (!arg1) {
                    AKPrintLine(@"Authorization failed with error: %@", arg2);
                } else {
                    id credential = [arg1 credential];
                    BOOL v289 = [credential isKindOfClass:[AKPasswordCredential class]];
                    if (!v289) {
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
            [v261 performAuthorizationWithContext:v254 completion:v50];
            dispatch_semaphore_wait(dsema3, DISPATCH_TIME_FOREVER);
        } else if ([lowercaseString isEqual:@"request"]) {
            id v17 = [v4 objectForKeyedSubscript:@"--paired"];
            if ([arguments count] >= 3 && [arguments count] < 5) {
                NSString *v41 = [arguments objectAtIndexedSubscript:2];
                NSURL *v42 = [NSURL URLWithString:v41];
                if (!v42) {
                    AKPrintLine(@"Error ! Not a valid URL: %@", v41);
                    return 0;
                }
                NSURLRequest *request = [NSURLRequest requestWithURL:v42];
                NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AKAppleIDSession *v46 = [[AKAppleIDSession alloc] init];
                if (v17 != nil) {
                    AKPrintLine(@"Will append paired device Anisette headers.");
                    id activeIDSPeerDevice = [AKDevice activeIDSPeerDevice];
                    [v46 setPairedDevice:activeIDSPeerDevice];
                }
                [defaultSessionConfiguration set_appleIDContext:v46];
                NSURLSession *v48 = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
                dispatch_semaphore_t dsema12 = dispatch_semaphore_create(0);
                AKPrintLine(@"Requesting %@...", v41);
                v50 = ^void(NSData *arg1, NSURLResponse *arg2, NSError *arg3) {
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
                NSURLSessionDataTask *v52 = [v48 dataTaskWithRequest:request completionHandler:v50];
                [v52 resume];
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
                        id v195 = [[[AKAppleIDAuthenticationController alloc] init] activeLoginCode:0];
                        if (v195 != nil) {
                            AKPrintLine(@"%@", v195);
                        }
                    } else if ([lowercaseString isEqualToString:@"verify"]) {
                        if ([arguments count] > 3) {
                            id v191 = [v4 objectForKeyedSubscript:@"-c"];
                            id v192 = [v4 objectForKeyedSubscript:@"-u"];
                            if (![v191 length] || ![v192 length]) {
                                AKPrintLine(@"Usage: aktool verify -c <code> -u <username>");
                                return 0;
                            }
                            NSInteger integerValue2 = [v191 integerValue];
                            if (integerValue2 <= 0) {
                                AKPrintLine(@"%@ is not a valid code.", v191);
                            } else {
                                dispatch_semaphore_t dsema8 = dispatch_semaphore_create(0);
                                [[[AKAppleIDAuthenticationController alloc] init] validateLoginCode:integerValue2 forAppleID:v192 completion:^void(bool arg1, NSError *arg2) {
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
                            v178 = [v4 objectForKeyedSubscript:@"-u"];
                            id v181 = [v4 objectForKeyedSubscript:@"--liveness"];
                            id v183 = [v4 objectForKeyedSubscript:@"--signout"];
                            if (![v178 length]) {
                                AKPrintLine(@"Usage: aktool ping -u <username> [--liveness | --signout <service-type>]");
                            } else if (!v181 || !v183) {
                                id v184 = v178;
                                dispatch_semaphore_t dsema = dispatch_semaphore_create(0);
                                AKAppleIDAuthenticationController *v188 = [[AKAppleIDAuthenticationController alloc] init];
                                if (!v183) {
                                    [v188 checkInWithAuthenticationServerForAppleID:v184 completion:^void(bool arg1, NSError *arg2) {
                                        if (!arg2) {
                                            AKPrintLine(@"Successfuly checked in!");
                                        } else {
                                            AKPrintLine(@"Unable to check in. %@", arg2);
                                        }
                                        dispatch_semaphore_signal(dsema);
                                    }];
                                } else {
                                    NSInteger integerValue = [v183 integerValue];
                                    [v188 reportSignOutForAppleID:v184 service:integerValue completion:^void(bool arg1, NSError *arg2) {
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
                            v178 = [v4 objectForKeyedSubscript:@"-a"];
                            if (![v178 length]) {
                                AKPrintLine(@"Usage: aktool accountNames -a <altDSID>");
                            } else {
                                id v179 = v178;
                                id v182 = [[[AKAppleIDAuthenticationController alloc] init] accountNamesForAltDSID:v179];
                                AKPrintLine(@"Account names associated with %@: \n%@", v179, v182);
                            }
                        } else {
                            AKPrintLine(@"Usage: aktool accountNames -a <altDSID>");
                        }
                    } else if ([lowercaseString isEqualToString:@"followup"]) {
                        id v124 = [v4 objectForKeyedSubscript:@"--sync"];
                        if (!v124) {
                            id v125 = [v4 objectForKeyedSubscript:@"-i"];
                            id v126 = [v4 objectForKeyedSubscript:@"-a"];
                            id v127 = [v4 objectForKeyedSubscript:@"-urlKey"];
                            id v128 = [v4 objectForKeyedSubscript:@"-url"];
                            id v129 = [v4 objectForKeyedSubscript:@"-d"];
                            id v130 = [v4 objectForKeyedSubscript:@"-f"];
                            [v4 objectForKeyedSubscript:@"-p"];
                            bool v12 = !v125 || !v129;
                            if (!v12) {
                                id v174 = [v4 objectForKeyedSubscript:@"--teardown"];
                                v12 = !v174;
                            }
                            if (v12) {
                                if (!v125 || !v127) {
                                    AKPrintLine(@"Usage:\nauthenticate [-u <username>] [-p <password>] -c [securityupgradecontext] [-d altDSID] [-t <service-type>] [--forceUI | --noUI] [-r <reason>] [-a <proxied-app-id>] [-s <gs-service-token-id>] [--persistGSTokens] [--skipAlert] [--recoveryPET] [--forceInteractiveTest]\nrequest <url> [--paired]\nanisette (--display | --provision | --erase | --sync <sim-data>) [--paired]\neligibility <altDSID> -c [securityupgradecontext]\ncode\nreadCode\nverify -c <code> -u <username>\nping -u <username> [--liveness | --signout <service-type>]\naccountNames -a <altDSID>\nfollowup ([-i <item identifier>] [-urlKey <urlKey>] [-url <URL>] [-a <ak-action>] [-d <altDSID>] [-p <priority (0/1)>] [-f <frequency (s)> ] | --notify | --teardown | --sync <altDSID>)\nuserInfo -a <altDSID>\ndeviceList -a <altDSID> [--includeFamily]\nconfigInfo -a <altDSID> -i <identifier> [ -v <value> ]\nauthorize [-u <userIdentifier>] [-r <requested-scopes>] [-a <altDSID>] [--forceUI] [--skipBiometrics] [--requirePassword] [--iconAsBase64] [--iconScale=2.0] [--forceAppSignInDiscovery]\nappinfo -a <altDSID>\ncredentialState -u <userIdentifier> -c <clientID> -t <TeamID> [-d altDSID]\nclearAuthorizationDatabase\nlocaluseruuid");
                                } else {
                                    void *v132 = &v133;
                                    AKFollowUpFactoryImpl *v135 = [[AKFollowUpFactoryImpl alloc] init];
                                    v50 = v125;
                                    v132->field_56 = @"aktool follow up";
                                    v132->field_64 = @"aktool follow up message";
                                    *(v132) = @"id";
                                    v132->field_8 = @"title";
                                    v132->field_16 = @"body";
                                    v132->field_24 = @"priority";
                                    *(uint64_t *)&v133[32] = @"actions";
                                    v93 = @"title";
                                    v93.field_8 = 0;
                                    NSDictionary<NSString *, id> *v138 = @{@"title": @"Extension Action", @"urlKey": v127};
                                    NSDictionary *v143 = @{v93 & 0xffffffffffffffff: @"Extension URL Action", @"url": (!v128) ? @"http://www.apple.com" : v128};
                                    NSDictionary *v148 = @{v93 & 0xffffffffffffffff: @"AK Action", @"AKAction": (!v126) ? AKActionDelete : v126};
                                    NSDictionary *v151 = [NSDictionary dictionaryWithObjects:&v50 forKeys:(id<NSCopying> *)v133 count:5];
                                    v93 = @selector(arrayWithObjects:count:);
                                    NSArray<NSDictionary *> *v153 = @[v151];
                                    id v154 = [v135 itemsForAltDSID:v129 fromIDMSPayload:v153];
                                    id firstObject = [v154 firstObject];
                                    id v157 = [v4 objectForKeyedSubscript:@"--notify"];
                                    if (v157 != nil) {
                                        id v158 = qword_10000c528(v157);
                                        id v159 = [v158 alloc];
                                        [firstObject setNotification:[v159 init]];
                                        UNNotification *notification = [firstObject notification];
                                        [notification setTitle:@"aktool notification"];
                                        UNNotification *notification2 = [firstObject notification];
                                        [notification2 setInformativeText:@"aktool notification body"];
                                        double doubleValue = [v130 doubleValue];
                                        UNNotification *notification3 = [firstObject notification];
                                        [notification3 setFrequency:doubleValue];
                                        id v165 = [[qword_10000c530(notification3) alloc] init];
                                        UNNotification *notification4 = [firstObject notification];
                                        [notification4 setClearAction:v165];
                                        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                                        [dictionary setObject:AKFollowUpActionClear forKeyedSubscript:AKActionKey];
                                        UNNotification *notification5 = [firstObject notification];
                                        id clearAction = [notification5 clearAction];
                                        [clearAction setUserInfo:dictionary];
                                    }
                                    AKFollowUpProviderImpl *v171 = [[AKFollowUpProviderImpl alloc] init];
                                    NSArray *v173 = @[firstObject];
                                    [v171 addFollowUpItems:v173 error:0];
                                }
                            } else {
                                AKAppleIDAuthenticationController *v217 = [[AKAppleIDAuthenticationController alloc] init];
                                AKFollowUpTearDownContext *v218 = [[AKFollowUpTearDownContext alloc] init];
                                [v218 setItemIdentifier:v125];
                                [v218 setAkAction:AKActionDelete];
                                [v218 setAltDSID:v129];
                                dispatch_semaphore_t dsema2 = dispatch_semaphore_create(0);
                                [v217 teardownFollowUpWithContext:v218 completion:^void(bool arg1, NSError *arg2) {
                                    dispatch_semaphore_signal(dsema2);
                                }];
                                dispatch_semaphore_wait(dsema2, DISPATCH_TIME_FOREVER);
                                return 0;
                            }
                        } else if (![v124 length]) {
                            AKPrintLine(@"Usage: aktool followup --sync <altDSID>");
                        } else {
                            AKAppleIDAuthenticationController *v176 = [[AKAppleIDAuthenticationController alloc] init];
                            AKAppleIDAuthenticationContext *v177 = [[AKAppleIDAuthenticationContext alloc] init];
                            [v177 setAltDSID:v124];
                            [v176 synchronizeFollowUpItemsForContext:v177 error:0];
                        }
                    } else if ([lowercaseString isEqualToString:@"userinfo"]) {
                        v269 = [v4 objectForKeyedSubscript:@"-a"];
                        if (![v269 length]) {
                            AKPrintLine(@"Usage: aktool userInfo -a <altDSID>");
                            return 0;
                        }
                        id v119 = v269;
                        dispatch_semaphore_t dsema5 = dispatch_semaphore_create(0);
                        [[[AKAppleIDAuthenticationController alloc] init] fetchUserInformationForAltDSID:v119 completion:^void(NSDictionary *arg1, NSError *arg2) {
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
                                    id v84 = [v4 objectForKeyedSubscript:@"-a"];
                                    id v85 = [v4 objectForKeyedSubscript:@"-r"];
                                    NSArray<NSString *> *v86 = [v85 componentsSeparatedByString:@","];
                                    id v87 = [v4 objectForKeyedSubscript:@"-u"];
                                    id v88 = [v4 objectForKeyedSubscript:@"--localizedAppName"];
                                    id v89 = [v4 objectForKeyedSubscript:@"--iconName"];
                                    id v90 = [v4 objectForKeyedSubscript:@"--informativeText"];
                                    if (![v4 objectForKeyedSubscript:@"--forceAppSignInDiscovery"]) {
                                        id v92 = [v4 objectForKeyedSubscript:@"--forceUI"];
                                        v93 = [v4 objectForKeyedSubscript:@"--skipBiometrics"];
                                        id v94 = [v4 objectForKeyedSubscript:@"--requirePassword"];
                                        id v95 = [v4 objectForKeyedSubscript:@"--isFirstPartyLogin"];
                                        if (![AKAuthorizationController canPerformAuthorization]) {
                                            return 0;
                                        }
                                        v254 = [[AKCredentialRequestContext alloc] init];
                                        [v254 set_shouldForceUI:v92 != nil];
                                        [v254 set_shouldSkipBiometrics:v93 != nil];
                                        [v254 set_requirePassword:v94 != nil];
                                        [v254 set_isFirstPartyLogin:v95 != nil];
                                        if ([v88 length] != 0) {
                                            [v254 set_proxiedClientAppName:v88];
                                        }
                                        if ([v89 length] != 0) {
                                            [v254 set_iconName:v89];
                                        }
                                        if ([v90 length] != 0) {
                                            [v254 set_informativeText:v90];
                                        }
                                        v256 = [[AKAuthorizationRequest alloc] init];
                                        [v256 setRequestedScopes:v86];
                                        if (!v87) {
                                            if (v84 != nil) {
                                                id sharedInstance = [AKAccountManager sharedInstance];
                                                id v258 = [sharedInstance authKitAccountWithAltDSID:v84];
                                                [v256 setAuthkitAccount:v258];
                                                goto blk_100004f28;
                                            } else {
                                                goto blk_100004f28;
                                            }
                                        }
                                        [v256 setUserIdentifier:v87];
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
                                    v268 = [v4 objectForKeyedSubscript:@"-u"];
                                    v271 = [v4 objectForKeyedSubscript:@"-t"];
                                    v83 = [v4 objectForKeyedSubscript:@"-c"];
                                    if (!v268) {
                                        AKPrintLine(@"Cannot fetch credential status for nil User identifier");
                                        if (v271 != nil) {
                                            goto blk_100004798;
                                        }
                                        goto blk_100004d04;
                                    }
                                    if (!v271) {
                                        goto blk_100004d04;
                                    }
                                    goto blk_100004798;
                                } else if ([lowercaseString isEqualToString:@"clearauthorizationdatabase"]) {
                                    AKAppleIDAuthenticationController *v267 = [[AKAppleIDAuthenticationController alloc] init];
                                    v50 = nil;
                                    long v82 = [v267 deleteAuthorizationDatabase:&v50];
                                    void (^v270)(NSData *, NSURLResponse *, NSError *) = v50;
                                    if (!v82) {
                                        AKPrintLine(@"Authorization Database deletion failed with error:", v270);
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
                            id v106 = [v4 objectForKeyedSubscript:@"-a"];
                            v268 = v106;
                            v271 = [v4 objectForKeyedSubscript:@"-i"];
                            v83 = [v4 objectForKeyedSubscript:@"-v"];
                            if (![v106 length]) {
                                AKPrintLine(@"Usage: aktool configInfo -a <altDSID> -i <identifier> [ -v <value> ]");
                                return 0;
                            }
                            if (![v271 length]) {
                                AKPrintLine(@"Usage: aktool configInfo -a <altDSID> -i <identifier> [ -v <value> ]");
                                return 0;
                            }
                            if (![v83 length]) {
                                id v221 = v268;
                                id v222 = v271;
                                dispatch_semaphore_t dsema9 = dispatch_semaphore_create(0);
                                AKAppleIDAuthenticationController *v225 = [[AKAppleIDAuthenticationController alloc] init];
                                NSArray *v226 = @[v222];
                                [v225 configurationInfoWithIdentifiers:v226 forAltDSID:v221 completion:^void(NSDictionary *arg1, NSError *arg2) {
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
                            NSData *v228 = [v83 dataUsingEncoding:NSUTF8StringEncoding];
                            NSError *v229 = nil;
                            id v230 = [NSJSONSerialization JSONObjectWithData:v228 options:NSJSONReadingFragmentsAllowed error:&v229];
                            if (!v229) {
                                id v232 = v268;
                                id v233 = v271;
                                id v234 = v230;
                                dispatch_semaphore_t dsema10 = dispatch_semaphore_create(0);
                                AKAppleIDAuthenticationController *v237 = [[AKAppleIDAuthenticationController alloc] init];
                                id v238 = v234;
                                [v237 setConfigurationInfo:v238 forIdentifier:v233 forAltDSID:v232 completion:^void(bool arg1, NSError *arg2) {
                                    if (!arg2) {
                                        AKPrintLine(@"Successfully set configuration information: %@ forIdentifier: %@", v234, v233);
                                    } else {
                                        AKPrintLine(@"Failed to set configuration information, error: %@", arg2);
                                    }
                                    dispatch_semaphore_signal(dsema10);
                                }];
                                dispatch_semaphore_wait(dsema10, DISPATCH_TIME_FOREVER);
                            } else {
                                AKPrintLine(@"Failed to process value, error: %@", v229);
                            }
                            return 0;
                        }
                        v269 = [v4 objectForKeyedSubscript:@"-a"];
                        id v108 = [v4 objectForKeyedSubscript:@"--includeFamily"];
                        if (!v269) {
                            AKPrintLine(@"Usage: aktool devicelist -a <altDSID> [--includeFamily] ");
                        } else {
                            AKAppleIDAuthenticationController *v111 = [[AKAppleIDAuthenticationController alloc] init];
                            AKDeviceListRequestContext *v112 = [[AKDeviceListRequestContext alloc] init];
                            [v112 setAltDSID:v269];
                            [v112 setIncludeFamilyDevices:v108 != nil];
                            v50 = nil;
                            id v113 = [v111 fetchDeviceListWithContext:v112 error:&v50];
                            AKAppleIDAuthenticationController *v114 = v50;
                            if (!v113) {
                                AKPrintLine(@"Failed to fetch user information, error: %@", v114);
                            } else {
                                AKPrintLine(@"Successfully fetched user information: %@", v113);
                            }
                        }
                    } else {
                        v269 = [v4 objectForKeyedSubscript:@"-a"];
                        if (![v269 length]) {
                            AKPrintLine(@"Usage: aktool appinfo -a <altDSID>");
                            return 0;
                        }
                        id v115 = v269;
                        AKAppleIDAuthenticationController *v272 = [[AKAppleIDAuthenticationController alloc] init];
                        v50 = nil;
                        id v117 = [v272 fetchAuthorizedAppListWithContext:v115 error:&v50];
                        void (^v118)(NSData *, NSURLResponse *, NSError *) = v50;
                        if (!v117) {
                            AKPrintLine(@"Failed to fetch app information, error: %@", v118);
                        } else {
                            AKPrintLine(@"Successfully fetched app information: %@", v117);
                        }
                    }
                    return 0;
                }
                if ([arguments count] > 2) {
                    NSString *v198 = [arguments objectAtIndexedSubscript:2];
                    dispatch_semaphore_t dsema7 = dispatch_semaphore_create(0);
                    AKAppleIDAuthenticationContext *v202 = [[AKAppleIDAuthenticationContext alloc] init];
                    [v202 setAltDSID:v198];
                    id v203 = [v4 objectForKeyedSubscript:@"-c"];
                    if (v203 != nil) {
                        id v204 = [v4 objectForKeyedSubscript:@"-c"];
                        [v202 setSecurityUpgradeContext:v204];
                    }
                    [[[AKAppleIDAuthenticationController alloc] init] checkSecurityUpgradeEligibilityForContext:v202 completion:^void(bool arg1, NSError *arg2) {
                        if (!arg2) {
                            if (!arg1) {
                                AKPrintLine(@"%@ is not eligible for HSA 2.0", v198);
                            } else {
                                AKPrintLine(@"%@ is eligible for HSA 2.0.", v198);
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
            }
            AKPrintLine(@"This command is no longer supported. Please use switchcl for all your environment switching needs.");
        } else {
            if ([arguments count] < 3) {
                AKPrintLine(@"Usage: aktool anisette (--provision | --sync <srm-data> | --display | --erase) [--paired]");
                return 0;
            }
            if ([arguments count] < 7) {
                id v53 = [v4 objectForKeyedSubscript:@"--provision"];
                id v54 = [v4 objectForKeyedSubscript:@"--display"];
                id v55 = [v4 objectForKeyedSubscript:@"--erase"];
                NSString *v56 = [v4 objectForKeyedSubscript:@"--sync"];
                id v57 = [v4 objectForKeyedSubscript:@"--paired"];
                if (!v53) {
                    if (v56) {
                        if (![v56 length]) {
                            AKPrintLine(@"Usage: aktool anisette --sync <srm-data>");
                            return 0;
                        }
                        AKPrintLine(@"Syncing Anisette...");
                        NSData *v70 = [[NSData alloc] initWithBase64EncodedString:v56 options:0];
                        dispatch_semaphore_t dsema13 = dispatch_semaphore_create(0);
                        AKAnisetteProvisioningController *v72 = [AKAnisetteProvisioningController alloc];
                        if (v57) {
                            v73 = [v72 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                        } else {
                            v73 = [v72 init];
                        }
                        [v73 syncWithSIMData:v70 completion:^void(bool arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Sync failed! %@", arg2);
                            } else {
                                AKPrintLine(@"Sync succeeded!");
                            }
                            dispatch_semaphore_signal(dsema13);
                        }];
                        dispatch_semaphore_wait(dsema13, DISPATCH_TIME_FOREVER);
                    } else if (v54) {
                        dispatch_semaphore_t v64 = dispatch_semaphore_create(0);
                        if (!v57) {
                            v265 = [[AKAnisetteProvisioningController alloc] init];
                        } else {
                            id activeIDSPeerDevice2 = [AKDevice activeIDSPeerDevice];
                            AKPrintLine(@"Pulling data from %@...", activeIDSPeerDevice2);
                            v265 = [[AKAnisetteProvisioningController alloc] initForDevice:activeIDSPeerDevice2 provider:0];
                        }
                        v63 = v64;
                        [v265 fetchAnisetteDataAndProvisionIfNecessary:0 withCompletion:^void(AKAnisetteData *arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Fetch failed! %@", arg2);
                            } else {
                                AKPrintLine(@"%@", arg1);
                            }
                            dispatch_semaphore_signal(v64);
                        }];
                        dispatch_semaphore_wait(v63, DISPATCH_TIME_FOREVER);
                    } else if (!v55) {
                        AKPrintLine(@"Usage: aktool anisette (--provision | --sync <srm-data> | --display | --erase) [--paired]");
                    } else {
                        AKPrintLine(@"Erasing Anisette provisioning data...");
                        v58 = dispatch_semaphore_create(0);
                        AKAnisetteProvisioningController *v59 = [AKAnisetteProvisioningController alloc];
                        if (v57) {
                            v60 = [v59 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                        } else {
                            v60 = [v59 init];
                        }
                        v63 = v58;
                        [v60 eraseWithCompletion:^void(bool arg1, NSError *arg2) {
                            if (!arg1) {
                                AKPrintLine(@"Failed! %@", arg2);
                            } else {
                                AKPrintLine(@"Erased successfully!");
                            }
                            dispatch_semaphore_signal(v58);
                        }];
                        dispatch_semaphore_wait(v63, DISPATCH_TIME_FOREVER);
                    }
                    return 0;
                }
                AKPrintLine(@"Kicking off Anisette provisioning...");
                v58 = dispatch_semaphore_create(0);
                AKAnisetteProvisioningController *v76 = [AKAnisetteProvisioningController alloc];
                if (v57) {
                    v266 = [v76 initForDevice:[AKDevice activeIDSPeerDevice] provider:0];
                } else {
                    v266 = [v76 init];
                }
                v63 = v58;
                v50 = ^void(bool arg1, NSError *arg2) {
                    if (!arg1) {
                        AKPrintLine(@"Provisioning failed! %@", arg2);
                    } else {
                        AKPrintLine(@"Provisioning succeeded!");
                    }
                    dispatch_semaphore_signal(v58);
                };
                [v266 provisionWithCompletion:v50];
                dispatch_semaphore_wait(v63, DISPATCH_TIME_FOREVER);
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
