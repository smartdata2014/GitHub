//
//  LoginViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<SWRevealViewControllerDelegate,FBLoginViewDelegate,WebServiceDelegate>
{
    IBOutlet UIView *forgotPasswordView;
    IBOutlet UITextField *txtUsername, *txtPassword, *txtEmail;
    UIView *statusBar;
}

@property (strong, nonatomic)IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) NSMutableDictionary *userInfoDict;
-(IBAction)btnLoginPressed:(id)sender;
-(IBAction)btnSignUpPressed:(id)sender;
-(IBAction)btnForgotPasswordPressed:(id)sender;
-(IBAction)forgotPasswordViewBtnActions:(id)sender;

@end

@implementation LoginViewController

#pragma mark Loading the View

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
//  Do any additional setup after loading the view.
    NSLog(@"Login");
//    txtUsername.text = @"adamsmith";
//    txtPassword.text = @"12345";
//    txtUsername.text = @"demo";
//    txtPassword.text = @"12345";
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 190, 45)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"Log In";
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;
    self.navigationController.navigationBarHidden = YES;
    
    //FBLogin View Customization
    _fbLoginView.frame = CGRectMake(60, 460, 78, 78);
    for (id obj in _fbLoginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            loginButton.frame = CGRectMake(0, 0, 78, 78);
            UIImage *loginImage = [UIImage imageNamed:@"facebook_icon"];
            [loginButton setImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:loginImage forState:UIControlStateNormal];
            [loginButton setBackgroundImage:nil forState:UIControlStateSelected];
            [loginButton setBackgroundImage:nil forState:UIControlStateHighlighted];
            loginButton.imageView.contentMode = UIViewContentModeScaleToFill;
            
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.text = @"Log in to facebook";
            loginLabel.hidden = YES;
            loginLabel.textAlignment = NSTextAlignmentCenter;
            loginLabel.backgroundColor = [UIColor clearColor];
            loginLabel.frame = CGRectMake(0, 0, 78, 78);
        }
    }
    [_fbLoginView setReadPermissions:@[@"basic_info",@"email"]];
    [_fbLoginView setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [statusBar removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBar.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_background.png"]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:statusBar];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

#pragma mark- FBLogin View Delegate Methods

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

    _userInfoDict = [[NSMutableDictionary alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:[user objectForKey:@"id"] forKey:@"facebook_id"];

    [_userInfoDict addEntriesFromDictionary:user];
    NSLog(@"_userInfoDict..%@",_userInfoDict);
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[_userInfoDict valueForKey:@"email"] forKey:@"email"];
    [postDict setObject:KSECRET_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[_userInfoDict valueForKey:@"email"],KSECRET_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 203;
    [webserviceCall callWebserviceWithIdentifier:@"FBLogin" andArguments:postDict];
}

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"User logged in");
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"User logged out");
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark- Memory Warning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Genaral Button Actions

-(IBAction)btnLoginPressed:(id)sender
{
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    
    [postDict setObject:txtUsername.text forKey:@"username"];
    [postDict setObject:txtPassword.text forKey:@"password"];
    NSString *signature = [AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",txtUsername.text,txtPassword.text,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]];
    
    #if TARGET_IPHONE_SIMULATOR
    [postDict setObject:[AppDelegate getDeviceID]
                      forKey:@"device_id"];
    
    #else
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"deviceToken"] forKey:@"deviceToken"];
    // Device
    
    #endif
    
    [postDict setObject:[AppDelegate getDeviceType] forKey:@"device_type"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:signature forKey:@"signature"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:   @"timestamp"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 201;
    [webserviceCall callWebserviceWithIdentifier:@"login" andArguments:postDict];
}

-(IBAction)btnSignUpPressed:(id)sender{
    SignUpViewController *signUpViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

-(IBAction)btnForgotPasswordPressed:(id)sender{
    forgotPasswordView.hidden = NO;
    [txtEmail becomeFirstResponder];
}

-(IBAction)forgotPasswordViewBtnActions:(UIButton *)sender{
    
    if ([sender tag]==10) {
        [forgotPasswordView setHidden:YES];
        [txtEmail resignFirstResponder];
   }
    else{
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        [postDict setObject:txtEmail.text forKey:@"email"];
        [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
        [postDict setObject:KAPI_KEY forKey:@"api_key"];
        [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",txtEmail.text,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
        WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
        webserviceCall.delegate = self;
        webserviceCall.tag = 202;
        [webserviceCall callWebserviceWithIdentifier:@"forgotpassword" andArguments:postDict];
        NSLog(@"Email the password");
    }
}

#pragma mark- Textfield Delagate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self btnLoginPressed:nil];
    return YES;
}

#pragma mark- Handling Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Fetching country name from the Facebook User Location

-(NSString *)getCountryCodeForCountry:(NSString*)country
{
    NSMutableArray *countries = [self getCountries];
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    
    NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
    
    return [codeForCountryDictionary objectForKey:country];
}

-(NSMutableArray *)getCountries
{
    NSMutableArray *countries = [NSMutableArray array];
    
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *country = [[NSLocale currentLocale] displayNameForKey: NSLocaleIdentifier value: identifier];
        [countries addObject: country];
    }
    
    return countries;
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
    if (Tag == 201) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            
            [AlertView showAlertwithTitle:@"Active Life App" message:@"Login is successful."];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[sender valueForKey:@"user_id"] forKey:@"user_id"];
            [[AppDelegate GloabalInfo]setObject:[sender valueForKey:@"user_id"] forKey:@"user_id" ];
            [userDefaults synchronize];
            [self pushToNextViewController];
        }
    }
    else if (Tag == 202){
      if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [txtEmail resignFirstResponder];
            forgotPasswordView.hidden = YES;
      }
   }
    else if(Tag == 203){
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[sender valueForKey:@"user_id"] forKey:@"user_id"];
            [[AppDelegate GloabalInfo]setObject:[sender valueForKey:@"user_id"] forKey:@"user_id" ];
            [userDefaults synchronize];
            
            [self pushToNextViewController];
        }
        else{
            FacebookSignUpViewController *facebookSignUpViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"FacebookSignUpViewController"];
            facebookSignUpViewController.userInfoDict = _userInfoDict;
            [self.navigationController pushViewController:facebookSignUpViewController animated:YES];
        }
    }
    else{
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[sender valueForKey:@"user_id"] forKey:@"user_id"];
            [[AppDelegate GloabalInfo]setObject:[sender valueForKey:@"user_id"] forKey:@"user_id" ];
            [userDefaults synchronize];
            
            [AlertView showAlertwithTitle:@"Active Life App" message:@"Login is successful."];
        }
    }
}

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");
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
