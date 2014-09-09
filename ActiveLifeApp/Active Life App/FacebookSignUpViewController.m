//
//  FacebookSignUpViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 04/09/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "FacebookSignUpViewController.h"

@interface FacebookSignUpViewController ()<SWRevealViewControllerDelegate,WebServiceDelegate>
{
    IBOutlet UITextField *txtUsername, *txtPassword;
    UIView *statusBar;
    IBOutlet UICollectionView *iconsCollectionView;
}

@property (strong, nonatomic) NSArray *iconsArray;
@property (strong, nonatomic) NSMutableArray *selectedIconsArray;

@end

@implementation FacebookSignUpViewController
@synthesize userInfoDict;

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
    // Do any additional setup after loading the view.
    NSLog(@"userInfoDict..%@",userInfoDict);
}

-(void)viewWillAppear:(BOOL)animated{
    
    _selectedIconsArray = [[NSMutableArray alloc] init];
    _iconsArray = [[NSArray alloc] initWithObjects:@"Archery",@"Basketball",@"Camel_Racing",@"Canoeing",@"Car_Rallying",@"Cricket",@"Cycling",@"Diving",@"Football",@"Golf",@"Horseriding",@"Kayaking",@"Polo",@"Running",@"Sailing",@"Rock_Climbing",@"Soccer",@"Swimming",@"Tennis",@"Volleyball",@"Water_Skiing",nil];
    
//    iconsCollectionView.backgroundColor = [UIColor clearColor];
    
//    self.navigationController.navigationBarHidden = NO;
//    statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
//    statusBar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_background.png"]];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:statusBar];
    txtUsername.text = [userInfoDict valueForKey:@"username"];
//    [txtUsername becomeFirstResponder];

}

//- (void)viewWillDisappear:(BOOL)animated{
//    self.navigationController.title = @"SignUp";
//    self.navigationController.navigationBarHidden = YES;
//}

#pragma mark- Memory Warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Textfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark- Handling Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark- Menu Button Action

-(IBAction)btnMenuPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Collection View Delegate Methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = (UICollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.frame = CGRectMake(cell.frame.origin.x-9, cell.frame.origin.y+10, 47, 35);
    UIButton *buttonIcons = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 47, 35)];
    //  buttonIcons.tag = indexPath.section*100 + (indexPath.row+1);
    buttonIcons.tag = 7*(indexPath.section) + (indexPath.row+1);
    [buttonIcons setContentMode:UIViewContentModeScaleAspectFit];
    [buttonIcons setImage:[UIImage imageNamed:[_iconsArray objectAtIndex:(indexPath.section)*7+indexPath.row]] forState:UIControlStateNormal];
    [buttonIcons setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_h",[_iconsArray objectAtIndex:(indexPath.section)*7+indexPath.row]]] forState:UIControlStateSelected];
    [buttonIcons addTarget:self action:@selector(btnIconPressed:) forControlEvents:UIControlEventTouchDown];
    [cell.contentView addSubview:buttonIcons];
    return cell;
}

-(IBAction)btnIconPressed:(UIButton *)sender{
    NSLog(@"[sender tag]..%i",[sender tag]);
    UIButton *buttonIcons = (UIButton *)[iconsCollectionView viewWithTag:[sender tag]];
    buttonIcons.selected ?[buttonIcons setSelected:NO]:[buttonIcons setSelected:YES];
    [_selectedIconsArray addObject:[[_iconsArray objectAtIndex:[sender tag]-1] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
}


#pragma mark - SignUp and Login Button Action Call

-(IBAction)btnSignUpAndLoginCall :(id)sender{
    [self facebookUserSignUpWebserviceCall];
}

#pragma mark - Call Webservice for Facebook User SignUp

-(void)facebookUserSignUpWebserviceCall{
    
//    txtUsername.text = [userInfoDict valueForKey:@"username"];
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[userInfoDict valueForKey:@"name"] forKey:@"name"];
    [postDict setObject:txtUsername.text forKey:@"username"];
    [postDict setObject:txtPassword.text forKey:@"password"];
    [postDict setObject:[userInfoDict valueForKey:@"gender"] forKey:@"gender"];
    [postDict setObject:[userInfoDict valueForKey:@"email"] forKey:@"email"];
    
    //    unsigned int unitFlags = NSYearCalendarUnit;
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateFormat:@"MM/dd/yyyy"];
    NSDate *birthdate = [formatter1 dateFromString:[userInfoDict valueForKey:@"birthday"]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *conversionInfo = [calendar components:NSYearCalendarUnit fromDate:birthdate  toDate:[NSDate date]  options:0];
    
    [postDict setObject:[NSString stringWithFormat:@"%i",conversionInfo.year] forKey:@"age"];
    [postDict setObject:[[userInfoDict valueForKey:@"location"] valueForKey:@"name"] forKey:@"country"];
    [postDict setObject:_selectedIconsArray forKey:@"activities"];
    
    #if TARGET_IPHONE_SIMULATOR
    [postDict setObject:[AppDelegate getDeviceID]
                 forKey:@"device_id"];
    
    #else
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"deviceToken"] forKey:@"deviceToken"];
    // Device
    
    #endif
    
    [postDict setObject:[AppDelegate getDeviceType] forKey:@"device_type"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    
    NSString *signature = [AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",txtUsername.text,txtPassword.text,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]];
    
    [postDict setObject:signature forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 204;
    [webserviceCall callWebserviceWithIdentifier:@"signup" andArguments:postDict];
}

#pragma mark - Push to Next View Controller

-(void)pushToNextViewController{
    MenuViewController *rearViewController;
    HomeViewController *frontViewController;
    frontViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    rearViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"MenuViewController"];
    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    frontNavigationController.navigationBar.translucent = YES;
    frontNavigationController.navigationBarHidden = YES;
    
    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
    rearNavigationController.navigationBar.translucent = YES;
    rearNavigationController.navigationBarHidden = YES;
    SWRevealViewController *mainRevealController = [[SWRevealViewController alloc]
                                                    initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
    
    mainRevealController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:mainRevealController animated:YES];
}


#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            
            [AlertView showAlertwithTitle:@"Active Life App" message:@"Registration and Login Successfull."];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[sender valueForKey:@"user_id"] forKey:@"user_id"];
            [[AppDelegate GloabalInfo]setObject:[sender valueForKey:@"user_id"] forKey:@"user_id" ];
            [userDefaults synchronize];
            [self pushToNextViewController];
        }
}

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");
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
