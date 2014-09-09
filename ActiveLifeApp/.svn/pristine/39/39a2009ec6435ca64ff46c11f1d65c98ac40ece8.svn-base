//
//  PeopleCustomCell.h
//  SbScribe
//
//  Created by Ramesh on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBFriendlistBO.h"

@interface PeopleCustomCell : UITableViewCell
{
    UILabel *lblName;
//    UILabel *lblBirthday;
    UIImageView *imgUser;
    NSThread *_thread;
	UIActivityIndicatorView *loaderView;
    FBFriendlistBO *objFriends;
    
 }
@property(nonatomic,retain) UIImageView *fbprofileImag;
@property(nonatomic,retain)UIImageView *checkmarkImage;
@property(nonatomic, retain) UILabel *lblName;
//@property(nonatomic, retain)  UILabel *lblBirthday;
@property(nonatomic, retain) UIImageView *imgUser;
@property(nonatomic,retain) NSThread *_thread;
@property(nonatomic,retain) UIActivityIndicatorView *loaderView;
@property(nonatomic,retain)   FBFriendlistBO *objFriends;
 
-(void)setCellParametersForFaceBook:(FBFriendlistBO *)objFriend;
-(void)showFriendImage;
- (void)downloadFriendImage;

@end
