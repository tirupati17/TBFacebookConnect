//
//  TBFacebookConnect.m
//  https://github.com/tirupati17/TBFacebookConnect
//
//  Created by Tirupati Balan on 26/09/14.
//  Copyright (c) 2014 CelerApps. All rights reserved.
//

#import "TBFacebookConnect.h"

@implementation TBFacebookConnect

@synthesize facebookCallbackBlock;
@synthesize responseData;

TBFacebookConnect *appDelegateFacebookConnect = nil;

+ (TBFacebookConnect *)initializeObjectWithFacebookId:(NSString *)idString {
    if (appDelegateFacebookConnect)
        return appDelegateFacebookConnect;
    
    appDelegateFacebookConnect = [[TBFacebookConnect alloc] initWithFacebookId:idString];
    return appDelegateFacebookConnect;
}

- (id)initWithFacebookId:(NSString *)idString {
    if (self = [super init]) {
        self.facebookId = [[NSString alloc] initWithString:idString];
    }
    return self;
}

- (void)loginWithBlock:(FacebookCallbackBlock)block {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        [self facebookNativeLoginWithCallback:block];
    } else {
        [self facebookSDKLoginWithCallback:block];
    }
}

#pragma mark - NativeFacebookConnect Method

- (void)facebookNativeLoginWithCallback:(FacebookCallbackBlock)block;
{
    self.facebookCallbackBlock = block;
    
    self.accountStore = [[ACAccountStore alloc] init];
    ACAccountType *fbAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSString *key = self.facebookId;
    NSDictionary *dictFB = [NSDictionary dictionaryWithObjectsAndKeys:key, ACFacebookAppIdKey, [[NSArray alloc] initWithObjects:@"email", @"user_friends", nil], ACFacebookPermissionsKey, nil];
    
    [self.accountStore requestAccessToAccountsWithType:fbAccountType options:dictFB completion:
     ^(BOOL granted, NSError *e)
     {
         if (granted)
         {
             NSArray *accounts = [self.accountStore accountsWithAccountType:fbAccountType];
             self.facebookAccount = [accounts lastObject];
             
             ACAccountCredential *facebookCredential = [self.facebookAccount credential];
             NSString *accessToken = [facebookCredential oauthToken];
             
             [self facebookLoginWithStatus:YES
                             atMessageBody:nil
                            atMessageTitle:nil
                             atAccessToken:accessToken];
         }
         else
         {
             NSLog(@"error getting permission yupe %@", e);
             dispatch_async(dispatch_get_main_queue(),^{
                 [self facebookLoginWithStatus:NO
                                 atMessageBody:@"Facebook setting error."
                                atMessageTitle:@"Please check your facebook account login in Setting/Facebook."
                                 atAccessToken:nil];
             });
         }
     }];
}

- (void)accountChanged:(NSNotification *)notification
{
    [self attemptRenewCredentials];
}

- (void)attemptRenewCredentials
{
    // Show the user an error message
    NSString *alertTitle = @"Something went wrong";
    NSString *alertText = [NSString stringWithFormat:@"Please retry your facebook login. \n\n "];
    
    [self.accountStore renewCredentialsForAccount:(ACAccount *)self.facebookAccount completion:^(ACAccountCredentialRenewResult renewResult, NSError *error){
        if(!error)
        {
            switch (renewResult) {
                case ACAccountCredentialRenewResultRenewed: {
                    [self facebookLoginWithStatus:YES
                                    atMessageBody:nil
                                   atMessageTitle:nil
                                    atAccessToken:nil];
                }
                    break;
                case ACAccountCredentialRenewResultRejected: {
                    NSLog(@"User declined permission");
                    [self facebookLoginWithStatus:NO
                                    atMessageBody:alertText
                                   atMessageTitle:alertTitle
                                    atAccessToken:nil];
                }
                    break;
                case ACAccountCredentialRenewResultFailed: {
                    NSLog(@"non-user-initiated cancel, you may attempt to retry");
                    [self facebookLoginWithStatus:NO
                                    atMessageBody:alertText
                                   atMessageTitle:alertTitle
                                    atAccessToken:nil];
                }
                    break;
                default:
                    break;
            }
        } else {
            NSLog(@"error from renew credentials%@", error);
            [self facebookLoginWithStatus:NO
                            atMessageBody:alertText
                           atMessageTitle:alertTitle
                            atAccessToken:nil];
        }
    }];
}

#pragma mark - FacebookSDK Methods

- (void)facebookSDKLoginWithCallback:(FacebookCallbackBlock)block {
    self.facebookCallbackBlock = block;

    // Open a session showing the user the login UI
    // You must ALWAYS ask for public_profile permissions when opening a session
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",
                                                      @"email",
                                                      @"user_friends"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [self sessionStateChanged:session state:state error:error];
     }];
}

- (void)facebookSDKSignOutWithCallback:(FacebookCallbackBlock)block {
    self.facebookCallbackBlock = block;

    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        //Log out action
        [FBSession.activeSession closeAndClearTokenInformation];
        [self facebookLoginWithStatus:NO
                        atMessageBody:@"You are log out from facebook."
                       atMessageTitle:@"Alert"
                        atAccessToken:nil];
    }
}

- (void)checkCachedSession { //Call in didFinish
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",
                                                          @"email",
                                                          @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen) {
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self facebookLoginWithStatus:YES
                        atMessageBody:nil
                       atMessageTitle:nil
                        atAccessToken:session.accessTokenData.accessToken];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self facebookLoginWithStatus:NO
                        atMessageBody:nil
                       atMessageTitle:nil
                        atAccessToken:nil];
    }
    
    // Handle errors
    if (error) {
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self facebookLoginWithStatus:NO
                            atMessageBody:alertText
                           atMessageTitle:alertTitle
                            atAccessToken:nil];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                [self facebookLoginWithStatus:NO
                                atMessageBody:@"You cancelled login."
                               atMessageTitle:@"Cancelled"
                                atAccessToken:nil];
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self facebookLoginWithStatus:NO
                                atMessageBody:alertText
                               atMessageTitle:alertTitle
                                atAccessToken:nil];
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self facebookLoginWithStatus:NO
                                atMessageBody:alertText
                               atMessageTitle:alertTitle
                                atAccessToken:nil];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)facebookLoginWithStatus:(BOOL)status
                  atMessageBody:(NSString *)messageBody
                 atMessageTitle:(NSString *)messageTitle
                  atAccessToken:(NSString *)accessToken
{
    self.facebookCallbackBlock(status, messageBody, messageTitle,accessToken);
}


@end
