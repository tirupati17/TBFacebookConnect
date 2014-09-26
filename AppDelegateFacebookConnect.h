//
//  AppDelegateFacebookConnect.h
//  https://github.com/tirupati17/AppDelegateFacebookConnect
//
//  Created by Tirupati Balan on 26/09/14.
//  Copyright (c) 2014 CelerApps. All rights reserved.
//

#import <Foundation/Foundation.h>

//Using Native
#import <Social/Social.h>
#import <Accounts/Accounts.h>
//Using SDK
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegateFacebookConnect : UIResponder {
    
}
typedef void (^FacebookCallbackBlock)(BOOL status, NSString *messageBody, NSString *messageTitle, NSString *accessToken);
@property (copy) FacebookCallbackBlock facebookCallbackBlock;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *facebookId;

- (void)facebookLoginWithBlock:(FacebookCallbackBlock)block;

//Using Native
@property (strong, nonatomic) IBOutlet ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
- (void)facebookNativeLoginWithCallback:(FacebookCallbackBlock)block;

//Using SDK
- (void)facebookSDKLoginWithCallback:(FacebookCallbackBlock)block;

//Default Initialization
+ (AppDelegateFacebookConnect *)initalizeAppDelegateFacebookConnectWithFacebookId:(NSString *)idString;
extern AppDelegateFacebookConnect *appDelegateFacebookConnect;

@end

