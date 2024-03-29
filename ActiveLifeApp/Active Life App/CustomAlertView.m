//
//  Customself.m
//  Active Life App
//
//  Created by sdnmacmini10 on 27/08/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "CustomAlertView.h"

@implementation CustomAlertView
AppDelegate *appDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        frame = CGRectMake(0, 0, 320, 568);
       }
    return self;
}

-(void)btnOkPressed:(UIButton *)sender{
    [self removeFromSuperview];
}

-(void)btnCrossPressed:(UIButton *)sender{
    [self removeFromSuperview];
}

-(id)initWithTitle: (NSString *)title message : (NSString *)message{
    appDelegate = [[UIApplication sharedApplication] delegate];

    NSLog(@"appDelegate.window.subviews...%@",appDelegate.window.subviews);
    
    for (UIView *alertView in appDelegate.window.subviews) {
        if ([alertView isKindOfClass:[CustomAlertView class]]) {
            [alertView removeFromSuperview];
        }
    }
    
    self = [super initWithFrame:CGRectMake(0, 0, 320, 568)];

    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    UIImageView *whiteBoxImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whitebox"]];
    whiteBoxImage.frame  = CGRectMake(20, 160, 280, 144);
    [self addSubview:whiteBoxImage];
    
    UIButton *buttonCross = [[UIButton alloc] initWithFrame:CGRectMake(130, 130, 60, 60)];
    [buttonCross setImage:[UIImage imageNamed:@"failure_icon"] forState:UIControlStateNormal];
    [buttonCross addTarget:self action:@selector(btnCrossPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonCross];
    
    UIButton *buttonOk = [[UIButton alloc] initWithFrame:CGRectMake(20, 304, 280, 34)];
    [buttonOk setImage:[UIImage imageNamed:@"btn_ok"] forState:UIControlStateNormal];
    [buttonOk addTarget:self action:@selector(btnOkPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buttonOk];
    
    UILabel *greyStrip = [[UILabel alloc] initWithFrame:CGRectMake(85, 240, 150, 1)];
    greyStrip.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [self addSubview:greyStrip];
    
    _lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, 200, 270, 30)];
    _lblTitle.textColor = [UIColor darkGrayColor];
    _lblTitle.font = [UIFont fontWithName:@"Helvetica Light" size:22.0];
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    _lblTitle.text = title;
    [self addSubview:_lblTitle];
    
    _lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(25, 250, 270, 40)];
    _lblMessage.textColor = [UIColor darkGrayColor];
    _lblMessage.font = [UIFont fontWithName:@"Helvetica Light" size:16.0];
    _lblMessage.textAlignment = NSTextAlignmentCenter;
    _lblMessage.text = message;
    _lblMessage.adjustsFontSizeToFitWidth = YES;
    _lblMessage.numberOfLines = 2;
    [self addSubview:_lblMessage];
    [appDelegate.window addSubview:self];

    return nil;
}

//-(void)show{
//    appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate.window addSubview:self];
////    return nil;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
