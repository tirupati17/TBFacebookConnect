AppDelegateFacebookConnect
==========================

Integrate facebook login into existing project with minimum effort.

Getting Started
===================

Git submodule
-------------------

- Add the AppDelegateFacebookConnect code into your project.
- If your project doesn't use ARC, add the -fobjc-arc compiler flag to AppDelegateCoreData.m in your target's Build Phases » Compile    Sources section.
- Add the `#import <Social/Social.h>` and `#import <Accounts/Accounts.h>` frameworks into your project.
- Download and add the `#import <FacebookSDK/FacebookSDK.h>` from here https://github.com/facebook/facebook-ios-sdk

Configuration
-------------------

- AppDelegateFacebookConnect provides class methods to configure its behavior. 
- Call `[AppDelegateCoreData initalizeAppDelegateFacebookConnectWithFacebookId:YOUR_FACEBOOK_APP_ID]`. A good place to do this is at the beginning of your app delegate's application:didFinishLaunchingWithOptions: method.

#### Example: ####
```
[appDelegateFacebookConnect facebookLoginWithBlock:^(BOOL status, NSString *messageBody, NSString *messageTitle, NSString *accessToken) {
    if (status) {
        //Use access_token variable here and perform other facebook graph request using any network client
    } else {
        if (messageBody != nil)
            ALERT_APPDELEGATE(messageTitle, messageBody);
    }
}];
```
