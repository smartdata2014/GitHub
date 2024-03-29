//
//  SettingsViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 25/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()<SWRevealViewControllerDelegate>

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

-(IBAction)btnLogOutPressed:(id)sender{
    [FBSession.activeSession closeAndClearTokenInformation];
    SWRevealViewController *revealController = [self revealViewController];
    UINavigationController *navController = revealController.navigationController;
    LoginViewController *loginViewController = [navController.viewControllers objectAtIndex:1];
    [navController popToViewController:loginViewController animated:YES];
}

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
