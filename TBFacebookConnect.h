//
//  TBFacebookConnect.h
//  https://github.com/tirupati17/TBFacebookConnect
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

@interface TBFacebookConnect : UIResponder {
    
}
typedef void (^FacebookCallbackBlock)(BOOL status, NSString *messageBody, NSString *messageTitle, NSString *accessToken);
@property (copy) FacebookCallbackBlock facebookCallbackBlock;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *facebookId;

- (void)loginWithBlock:(FacebookCallbackBlock)block;

//Using Native
@property (strong, nonatomic) IBOutlet ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
- (void)facebookNativeLoginWithCallback:(FacebookCallbackBlock)block;

//Using SDK
- (void)facebookSDKLoginWithCallback:(FacebookCallbackBlock)block;

//Default Initialization
+ (TBFacebookConnect *)initializeObjectWithFacebookId:(NSString *)idString;
extern TBFacebookConnect *appDelegateFacebookConnect;

@end

