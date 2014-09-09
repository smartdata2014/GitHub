//
//  AppDelegate.h
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    CGSize result;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) UIView *aAnimationView;
@property (strong, nonatomic) UILabel *alodingLbl;
-(void)addChargementLoader;
-(void)removeChargementLoader;

+(id)storyBoard;
+(NSMutableDictionary *)GloabalInfo;
+(NSMutableArray *)NotificationsArray;
+(NSMutableArray *)FriendshipReqArray;
+(NSString *)getCurrentTimeStamp;
+(NSString *)getDeviceID;
+(NSString *)getDeviceType;
+(NSString *)hmacSHA256:(NSString *)key forKeyValue:(NSString *)data;
@end
