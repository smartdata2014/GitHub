//
//  AlertView.h
//  Active Life
//
//  Created by sdnmacmini10 on 20/02/14.
//  Copyright (c) 2014 test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertView : UIView<SWRevealViewControllerDelegate>

+(id)showAlertwithTitle: (NSString *)title message : (NSString *)message;

@end
