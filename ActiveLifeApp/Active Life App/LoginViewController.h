//
//  LoginViewController.h
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBRequestConnection.h>

@interface LoginViewController : UIViewController
{
    AppDelegate *appDelegate;
    NSMutableDictionary *userDescription;
    
}
@end
