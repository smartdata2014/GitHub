//
//  AppDelegate.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize session;
@synthesize navController;
@synthesize aAnimationView;
@synthesize alodingLbl;
NSMutableDictionary *GloabalInfo;
NSMutableArray *NotificationsArray;
//NSMutableArray *FriendshipReqArray;

#pragma mark- UIApplication Delegate Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //    // Override point for customization after application launch.
    //    self.window.backgroundColor = [UIColor whiteColor];
    //    [self.window makeKeyAndVisible];
//    sleep(10);

    GloabalInfo = [[NSMutableDictionary alloc] init];
    NotificationsArray = [[NSMutableArray alloc] init];
//    FriendshipReqArray = [[NSMutableArray alloc] init];

//    for (int i=1; i<=8; i++) {
//    NSMutableDictionary *notifDict = [[NSMutableDictionary alloc] init];
//    [notifDict setObject:[NSDate date] forKey:@"RecievedDate"];
//    [notifDict setObject:@"Demo - Activity has been changed to Swimming" forKey:@"alert"];
//    [notifDict setObject:@"badge" forKey:@"badge"];
//    [notifDict setObject:@"default" forKey:@"sound"];
//    [notifDict setObject:@"1" forKey:@"status"];
//    [notifDict setObject:@"0" forKey:@"type"];
//    [NotificationsArray addObject:notifDict];
//    
////    notifDict = [[NSMutableDictionary alloc] init];
////    [notifDict setObject:[NSDate date] forKey:@"RecievedDate"];
////    [notifDict setObject:@"Adam wants to add you as a friend" forKey:@"alert"];
////    [notifDict setObject:@"badge" forKey:@"badge"];
////    [notifDict setObject:@"default" forKey:@"sound"];
////    [notifDict setObject:@"1" forKey:@"status"];
////    [notifDict setObject:@"1" forKey:@"type"];
////
////    [FriendshipReqArray addObject:notifDict];
//
////    if ([[notifDict valueForKey:@"type"] isEqualToString:@"0"]) {
//        [NotificationsArray addObject:notifDict];
//    }
//    else
//        [FriendshipReqArray addObject:notifDict];

    
    [GMSServices provideAPIKey:@"AIzaSyBxVeWUBHLXhcgswHHj_TrL16sOLVKdtn0"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"facebook_id"];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"topbar_blue.png"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    [FBLoginView class];
//    [FBProfilePictureView class];

    // Loader Allocation
    aAnimationView =[[UIView alloc]initWithFrame:self.window.frame];
    result = self.window.screen.bounds.size;
    alodingLbl=[[UILabel alloc]initWithFrame:CGRectMake((result.width/2)-35,result.height/2,100,40)];
    //alodingLbl=[[UILabel alloc]init];
    //alodingLbl.center=aAnimationView.center;
    alodingLbl.textAlignment = NSTextAlignmentCenter;
    [self prepareChargementLoader];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:self.session];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppEvents activateApp];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // FBSample logic
    // We need to properly handle activation of the application with regards to SSO
    //  (e.g., returning from iOS 6.0 authorization dialog or from fast app switching).
    [FBAppCall handleDidBecomeActiveWithSession:self.session];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.session close];
}

#pragma mark - Push Notification Delegate Methods

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString *tokenStr = [deviceToken description];
    
    [[AppDelegate GloabalInfo] setObject:tokenStr forKey:@"deviceToken"];
    
    NSString *pushToken = [[[tokenStr
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults]setValue:pushToken forKey:@"deviceTocken"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSLog(@"Did register for remote notifications deviceToken ==: %@", pushToken);
    [[AppDelegate GloabalInfo] setObject:pushToken forKey:@"deviceToken"];
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"Registered"]){
        
    }
    else{
        /*if([DELEGATE internetAvailabel]){
         NSString *appNameAndVersion = @"ThinkMath_v1.0";
         NSString *stringUrl = [[NSString alloc]initWithFormat:THINK_MATH_APP_REGISTERED_DEVICE_TOCKEN,pushToken,appNameAndVersion];
         NSURL *url = [NSURL URLWithString:stringUrl];
         NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
         NSURLConnection *connnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
         [connnection start];
         
         }
         else {
         [self alertViewInitWithTitle:NETWORK_NOT_AVAILABLE_TITLE message:NETWORK_NOT_AVAILABLE_MESSAGE cancelButtonTitle:OK_BUTTON firstOtherButtonTitle:nil secondOtherButtonTitle:nil thirdOtherButtonTitle:nil tag:NETWORK_NOT_AVAILABLE_TAG];
         }*/
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSString *str1 = [[NSString alloc]initWithFormat:@"%@",[userInfo allValues]];
    NSLog(@"Str==%@",str1);
    
    
    NSMutableDictionary *notifDict = [[NSMutableDictionary alloc] init];
    [notifDict addEntriesFromDictionary:[userInfo valueForKey:@"aps"]];
    [notifDict setObject:[NSDate date] forKey:@"RecievedDate"];

//    [notifDict setObject:@"Demo - Activity has been changed to Swimming" forKey:@"alert"];
//    [notifDict setObject:@"badge" forKey:@"badge"];
//    [notifDict setObject:@"default" forKey:@"sound"];
//    [notifDict setObject:@"1" forKey:@"status"];
//    [notifDict setObject:@"0" forKey:@"type"];

    
    if ([[notifDict valueForKey:@"type"] isEqualToString:@"0"]) {
        [NotificationsArray addObject:notifDict];
    }
//    else
//        [FriendshipReqArray addObject:notifDict];

    
    if ([[[userInfo valueForKey:@"aps"]valueForKey:@"status"] integerValue] == 1) {
        
//        application.applicationIconBadgeNumber = [NotificationsArray count]+[FriendshipReqArray count];
        NSLog(@"userInfo==%@",userInfo);
        
        if (application.applicationState == UIApplicationStateActive) {
            // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[[userInfo valueForKey:@"aps"] valueForKey:@"alert"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
  }


#pragma mark - Loader
-(void)addChargementLoader
{
    [self.window addSubview:self.aAnimationView];
    //    [self.viewController.navigationController.topViewController.view addSubview:self.aAnimationView];
}

-(void)prepareChargementLoader
{
    UIActivityIndicatorView	*progressInd;
    aAnimationView.backgroundColor =[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.50];
	progressInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [progressInd hidesWhenStopped];
    progressInd.frame = CGRectMake((result.width/2)-10, (result.height/2)-20, progressInd.frame.size.width, progressInd.frame.size.height);
	[progressInd startAnimating];
    progressInd.tag =10;
    
    alodingLbl.text=@"Loading...";
	alodingLbl.textAlignment=NSTextAlignmentLeft;
	alodingLbl.font=[UIFont fontWithName:@"Knockout-HTF31-JuniorMiddlewt" size:16.0];
	alodingLbl.backgroundColor=[UIColor clearColor];
	alodingLbl.textColor= [UIColor whiteColor];
    alodingLbl.tag = 11;
	[self.aAnimationView addSubview:alodingLbl];
	[self.aAnimationView addSubview:progressInd];
}

-(void)setChargementFramesForViewMode:(UIInterfaceOrientation)interfaceOrientation {
    
    UIActivityIndicatorView *progressInd = (UIActivityIndicatorView *)[aAnimationView viewWithTag:10];
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait ||
        (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)){
        
        progressInd.frame = CGRectMake(40, 230, progressInd.frame.size.width, progressInd.frame.size.height);
        alodingLbl.frame = CGRectMake(70, 280, 250, 20);
    }
    else if ((interfaceOrientation == UIDeviceOrientationLandscapeLeft) ||
             (interfaceOrientation == UIDeviceOrientationLandscapeRight)) {
        
        progressInd.frame = CGRectMake(120, 120, progressInd.frame.size.width, progressInd.frame.size.height);
        alodingLbl.frame = CGRectMake(150, 120, 250, 20);
    }
}

-(void)removeChargementLoader  // for remove loader
{
    [self.aAnimationView removeFromSuperview];
}

#pragma mark - Storyboard

+(id)storyBoard{
    UIStoryboard *storyboard;
//        if (IS_IPHONE5) {
            storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        }
//        else{
//            storyboard = [UIStoryboard storyboardWithName:@"Main_3.5" bundle: nil];
//        }
    return storyboard;
}

#pragma mark - Notifications

+(NSMutableArray *)NotificationsArray{
    return NotificationsArray;
}

//+(NSMutableArray *)FriendshipReqArray{
//    return FriendshipReqArray;
//}
//

#pragma mark - Global Dictionary

+(NSMutableDictionary *)GloabalInfo{
    return GloabalInfo;
}

#pragma mark - Current Timestamp

+(NSString *)getCurrentTimeStamp
{
    NSInteger currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timestamp =[NSString stringWithFormat:@"%d",currentTimeInterval];
    
    return timestamp;
}

#pragma mark - Current DeviceID

+(NSString *)getDeviceID
{
    NSString *strDeviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];;
    // NSString *strDeviceType=[[UIDevice currentDevice] name];
    return strDeviceID;
}

#pragma mark - Current DeviceType

+(NSString *)getDeviceType
{
    NSString *strDeviceType=[[UIDevice currentDevice] name];
    return strDeviceType;
}

#pragma mark - Signature Generation

+(NSString *)hmacSHA256:(NSString *)key forKeyValue:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *result = [NSMutableString string];
    
    for (int i = 0; i < sizeof cHMAC; i++)
    {
        [result appendFormat:@"%02hhx", cHMAC[i]];
    }
    
    // NSLog(@"%@",result);
    return result;
}


@end
