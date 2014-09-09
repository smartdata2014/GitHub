//
//  SignUpViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()<UICollectionViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIActionSheetDelegate,WebServiceDelegate>
{
    IBOutlet UICollectionView *iconsCollectionView;
    IBOutlet UITextField *txtUsername,*txtName, *txtPassword, *txtConfirmPassword, *txtEmail, *txtAge, *txtCountry;
    IBOutlet UISwitch *maleSwitch, *femaleSwitch;
    UIImageView *checkCrossImage;
    UIActionSheet *actionSheet;
    UIPickerView *agePickerView;
    UIToolbar *toolbar;
}
@property (strong, nonatomic) NSMutableDictionary *responseDict;
@property (strong, nonatomic) NSArray *iconsArray;
@property (strong, nonatomic) NSMutableArray *selectedIconsArray;
@property (nonatomic, nonatomic) NSMutableArray *pickerArr;
-(IBAction)btnSignUpPressed:(id)sender;
-(IBAction)switchControlPressed:(id)sender;
-(BOOL)CheckValidationForTextfield:(UITextField *)textfield;
-(void)selectValues : (UITextField *)textField;
@end

@implementation SignUpViewController
NSUserDefaults *userDefaults;

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
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 190, 45)];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text = @"SignUp";
    lblTitle.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = lblTitle;
    
    _responseDict = [[NSMutableDictionary alloc] init];
    _selectedIconsArray = [[NSMutableArray alloc] init];
    _iconsArray = [[NSArray alloc] initWithObjects:@"Archery",@"Basketball",@"Camel_Racing",@"Canoeing",@"Car_Rallying",@"Cricket",@"Cycling",@"Diving",@"Football",@"Golf",@"Horseriding",@"Kayaking",@"Polo",@"Running",@"Sailing",@"Rock_Climbing",@"Soccer",@"Swimming",@"Tennis",@"Volleyball",@"Water_Skiing",nil];
    
    _pickerArr = [[NSMutableArray alloc] init];
    
    for (int i=0; i<5; i++) {
        checkCrossImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_icon.png"] highlightedImage:[UIImage imageNamed:@"crossmark_icon.png"]];
        checkCrossImage.frame = CGRectMake(286, 70 + i*30, 26, 26);
        checkCrossImage.hidden = YES;
        checkCrossImage.tag = 300+i+1;
        [self.view addSubview:checkCrossImage];
    }
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (![userDefaults valueForKey:@"countries"]) {
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        [postDict setObject:KAPI_KEY forKey:@"api_key"];
        [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
        [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@",KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
 
        WebserviceCall  *webserviceCall = [[WebserviceCall alloc] init];
        webserviceCall.delegate = self;
        webserviceCall.tag = 601;
        [webserviceCall callWebserviceWithIdentifier:@"CountryList" andArguments:postDict];
    }
      [self switchControlPressed:nil];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Register Button Action

-(IBAction)btnSignUpPressed:(id)sender{
    
    NSString *signature = [AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",txtUsername.text,txtPassword.text,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]];

    [_responseDict setObject:txtName.text forKey:@"name"];
    [_responseDict setObject:txtUsername.text forKey:@"username"];
    [_responseDict setObject:txtPassword.text forKey:@"password"];
    [_responseDict setObject:txtEmail.text forKey:@"email"];
    [_responseDict setObject:txtAge.text forKey:@"age"];
    [_responseDict setObject:txtCountry.text forKey:@"country"];
    [_responseDict setObject:_selectedIconsArray forKey:@"activities"];
    
    #if TARGET_IPHONE_SIMULATOR
    [_responseDict setObject:[AppDelegate getDeviceID]
                      forKey:@"device_id"];

    #else
    [_responseDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"deviceToken"] forKey:@"deviceToken"];
    // Device
    
    #endif
    
    [_responseDict setObject:[AppDelegate getDeviceType] forKey:@"device_type"];
    [_responseDict setObject:KAPI_KEY forKey:@"api_key"];
    [_responseDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [_responseDict setObject:signature forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 602;
    [webserviceCall callWebserviceWithIdentifier:@"signup" andArguments:_responseDict];
}

#pragma mark Male Female Selection

-(IBAction)switchControlPressed:(UIButton *)sender{
    if ([sender tag]==101) {
        if (maleSwitch.isOn == 1) {
            [maleSwitch setOn:YES animated:YES];
            [femaleSwitch setOn:NO animated:YES];
        }
        else {
            [maleSwitch setOn:NO animated:YES];
            [femaleSwitch setOn:YES animated:YES];
        }
    }
    else{
        if (femaleSwitch.isOn == 1) {
            [maleSwitch setOn:NO animated:YES];
            [femaleSwitch setOn:YES animated:YES];
        }
        else{
            [maleSwitch setOn:YES animated:YES];
            [femaleSwitch setOn:NO animated:YES];
        }
    }
    maleSwitch.isOn?[_responseDict setObject:@"Male" forKey:@"gender"]:[_responseDict setObject:@"Female" forKey:@"gender"];
    NSLog(@"_responseDict..%@",_responseDict);
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
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

#pragma mark - Activity Icons Selection 

-(IBAction)btnIconPressed:(UIButton *)sender{
    NSLog(@"[sender tag]..%i",[sender tag]);
    UIButton *buttonIcons = (UIButton *)[iconsCollectionView viewWithTag:[sender tag]];
    buttonIcons.selected ?[buttonIcons setSelected:NO]:[buttonIcons setSelected:YES];
    [_selectedIconsArray addObject:[[_iconsArray objectAtIndex:[sender tag]-1] stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
}

#pragma mark - Texfield Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"string..%@%@",textField.text,string);
    if ([textField isEqual:txtUsername]) {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
    return YES;
}

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if ([textField isEqual:txtAge]) {
//        [self selectValues];
//    }
//    return YES;
//}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    UIImageView *imageView1 = (UIImageView *)[self.view viewWithTag:300+(textField.tag-200)];
    BOOL editing=1;
    if ([textField.text isEqualToString:@""]) {
        [imageView1 setHidden:YES];
    }
    else{
        [imageView1 setHidden:NO];
        editing = [self CheckValidationForTextfield:textField];
        editing?[imageView1 setHighlighted:NO]:[imageView1 setHighlighted:YES];
    }
    return editing;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{

     if ([textField isEqual:txtAge]) {
         if ([_pickerArr count]>0) {
             [_pickerArr removeAllObjects];
         }
        for (int j=18; j<=100; j++) {
            [_pickerArr addObject:[NSString stringWithFormat:@"%i",j]];
        }
        [self selectValues:txtAge];
        [textField resignFirstResponder];
        
    }
    else if ([textField isEqual:txtCountry]){
        if ([_pickerArr count]>0) {
            [_pickerArr removeAllObjects];
        }
        NSLog(@"Countries...%@",[userDefaults valueForKey:@"countries"]);
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [_pickerArr addObjectsFromArray:[userDefaults valueForKey:@"countries"]];
        [self selectValues:txtCountry];
        [textField resignFirstResponder];
    }
}

#pragma mark - Checking Validation Method

-(BOOL)CheckValidationForTextfield:(UITextField *)textfield{
    
    if ([textfield isEqual:txtUsername]) {
        if ([txtUsername.text length] < 6) {
            [AlertView showAlertwithTitle:@"Error" message:@"Username must contain atleast 6 fields."];
            return NO;
        }
        return YES;
    }
    else if ([textfield isEqual:txtName]) {
        if ([txtName.text length] < 6) {
            [AlertView showAlertwithTitle:@"Error" message:@"Name must contain atleast 6 fields."];
            return NO;
        }
        return YES;
    }
    else if ([textfield isEqual:txtPassword])
    {
        NSLog(@"txtUsername..%@",txtPassword.text);
        
        BOOL letter=0, digit=0, specialCharacter=0;
        if([txtPassword.text length] >= 6)
        {
            for (int i = 0; i < [txtPassword.text length]; i++)
            {
                unichar c = [txtPassword.text characterAtIndex:i];
                if(!letter)
                {
                    letter = [[NSCharacterSet letterCharacterSet] characterIsMember:c];
                }
                if(!digit)
                {
                    digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
                }
                if(!specialCharacter)
                {
                    specialCharacter = [[NSCharacterSet symbolCharacterSet] characterIsMember:c]||[[NSCharacterSet nonBaseCharacterSet] characterIsMember:c]||[[NSCharacterSet punctuationCharacterSet] characterIsMember:c];
                }
            }
            
            if(letter && digit && specialCharacter)
            {
                return YES;
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Please ensure that you have at least one letter, one digit and one special character."
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return NO;
            }
            
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Password must contain atleast 10 characters."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
        
    }
    else if ([textfield isEqual:txtConfirmPassword])
    {
        NSLog(@"txtUsername..%@",txtConfirmPassword.text);
        if (![txtPassword.text isEqualToString:txtConfirmPassword.text]) {
            [AlertView showAlertwithTitle:@"Error" message:@"Passwords not matched.Please re-enter the password."];
            return NO;
        }
    }
    else if ([textfield isEqual:txtEmail])
    {
        NSLog(@"txtUsername..%@",txtEmail.text);
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if ([emailTest evaluateWithObject:textfield.text]==YES) {
            return YES;
        }
        else{
            [AlertView showAlertwithTitle:@"Error" message:@"Please enter the correct email."];
            return NO;
        }
    }    else if ([textfield isEqual:txtAge])
    {
        NSLog(@"txtUsername..%@",txtAge.text);
    }
    return YES;
}

#pragma mark - Picker View Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_pickerArr count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_pickerArr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)	pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    txtAge.text = [_pickerArr objectAtIndex:row];
    if ([[_pickerArr objectAtIndex:0] isEqualToString:@"18"]) {
        txtAge.text = [_pickerArr objectAtIndex:row];
    }
    else{
        txtCountry.text = [_pickerArr objectAtIndex:row];
    }
}

-(void)selectValues : (UITextField *)textField
{
    if (actionSheet == nil)
    {
        // setup actionsheet to contain the UIPicker
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        
        CGRect pickerFrame = CGRectMake(0, 50, 320, 200);
        
        agePickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        agePickerView.showsSelectionIndicator = YES;
        agePickerView.dataSource = self;
        agePickerView.delegate = self;
        
        [agePickerView selectRow:textField.text.length?[_pickerArr indexOfObject:textField.text]:0 inComponent:0 animated:YES];
        
        [actionSheet addSubview:agePickerView];

        UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        
        UIBarButtonItem *cancleBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(pickerCancle:)];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pickerDone:)];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        [barItems addObject:cancleBtn];
        [barItems addObject:flexSpace];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
        
        [actionSheet addSubview:pickerToolbar];
        [actionSheet showInView:self.view];
        [actionSheet setBounds:CGRectMake(0,0,320, 464)];
    }
}

- (void)pickerDone:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    actionSheet = nil;
}

-(void)pickerCancle: (id)sender;
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    actionSheet = nil;
}


#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
    if (Tag == 601) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
//            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[sender valueForKey:@"countries"] forKey:@"countries"];
//            [userDefaults synchronize];
        }
    }
    else{
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:@"Registration successful."];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
