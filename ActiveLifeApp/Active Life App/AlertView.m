//
//  AlertView.m
//  Active Life
//
//  Created by sdnmacmini10 on 20/02/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import "AlertView.h"
#import "CustomAlertView.h"

@implementation AlertView
UIView *alertView;
AppDelegate *appDelegate;
CustomAlertView *alert;

+(id)showAlertwithTitle: (NSString *)title message : (NSString *)message{
    
    alert = [[CustomAlertView alloc] initWithTitle:title message:message];
    return nil;
}

-(void)btnOkPressed:(UIButton *)sender{
  [alertView removeFromSuperview];
}

-(void)btnCrossPressed:(UIButton *)sender{
  [alertView removeFromSuperview];
}

@end
