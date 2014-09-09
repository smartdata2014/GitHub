//
//  InviteFriendsViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 08/08/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface InviteFriendsViewController ()<ABPeoplePickerNavigationControllerDelegate,WebServiceDelegate>
{
    IBOutlet UITableView *tableFriends;
}

@property (nonatomic, strong) NSMutableArray *arrFriends;
@property (nonatomic, strong) NSMutableDictionary *contactDictPost;
@property (nonatomic, strong) NSMutableArray *friendEmailsArray;
@end

@implementation InviteFriendsViewController

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
    
    NSLog(@"isOpen....%d",FBSession.activeSession.isOpen);
    _contactDictPost = [[NSMutableDictionary alloc] init];
    _friendEmailsArray = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBarHidden = YES;
    [self btnSegmentControlPressed:nil];
//    NSString *queryString = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",FBSession.activeSession.accessTokenData.accessToken];
//    
//    NSLog(@"queryString..%@",queryString);
//    
////    NSURL *queryStringURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends?access_token=CAAUWp7LnFYMBALgb3MFriZB0VBKEjTz5YgAa2TsOEfAF9XJfJtpRaZAUFTZCvcEZCyEd4xv3z1WNyZBd5CHfQnhRh6arakRy93juckYTG7YICb5zqBX5ZAkNKwA1CSSbKUDCHIRZAHfZAfaZBUh7bt9vTdaFiQrzXYCnbI51A61jAenTNoTI5H1jdUyHZB2iPtf4uJE4bti2oyYGwHRZCneFK2IEbRNZCYQ5IMnASMMRYP479jYWtwqQnTZCa&limit=5000&offset=5000&__after_id=enc_AeyoKdWKiNkrA1XQNEGNyLmJ2HyY_43Zs0fKB1pxj8sAOdQk4PLWXJ6XZ4zMTO6H6PEwNVeaanFIZ3d2CUBEs8zK"];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:queryString]];
//    
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    
//    NSLog(@"Connection obj - %@", connection);
    
    // get all friends list who are using this app
//    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                  NSDictionary* result,
//                                                  NSError *error) {
//        _arrFriends = [result objectForKey:@"data"];
//        NSLog(@"friends..%@",_arrFriends);
//        NSLog(@"Found: %i friends", _arrFriends.count);
//        
//        for (NSDictionary<FBGraphUser>* friend in _arrFriends) {
//            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
//        }
//    }];

    
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
//    UINavigationController *navController =(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
//    [navController popViewControllerAnimated:YES];
}

-(IBAction)btnMenuPressed:(id)sender{
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}


#pragma mark - Segment Control Action

-(IBAction)btnSegmentControlPressed:(UISegmentedControl *)sender{
    if ([sender selectedSegmentIndex]==0) {
        tableFriends.hidden = YES;

        [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
        [(UIButton *)[self.view viewWithTag:102]setSelected:NO];

        [FBWebDialogs
         presentRequestsDialogModallyWithSession:FBSession.activeSession
         message:@"Hey ! Check out this new event social networking app for creating, publishing and managing your events."
         title:nil
         parameters:nil
         handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or sending the request.
                 NSLog(@"Error sending request.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled request.");
                     
               
                     
                 } else {
                     // Handle the send request callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"request"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled request.");
                     } else {
                         // User clicked the Send button
                         NSString *requestID = [urlParams valueForKey:@"request"];
                         NSLog(@"Request ID: %@", requestID);
                         [AlertView showAlertwithTitle:@"Active Life App" message:@"Application invitation sent successfully."];
                         
                     }
                 }
             }
             ((UISegmentedControl *)[self.view viewWithTag:201]).selectedSegmentIndex = 1;
             [self performSelector:@selector(btnSegmentControlPressed:) withObject:((UISegmentedControl *)[self.view viewWithTag:201]) afterDelay:0.0];
         }];
    }
    else{
        tableFriends.hidden = NO;
        [self getContactFromAddressBook];
        [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
        [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
//        [postDict setObject:[NSString stringWithFormat:@"%f%f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude] forKey:@"lat_long"];
//        txtSearch.placeholder = @"Search by location";
    }
}


#pragma mark Fetching Friends From Address Book

-(void)getContactFromAddressBook
{
    _arrFriends = [[NSMutableArray alloc] init];

    BOOL isAcessed;
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
        
#ifdef DEBUG
        NSLog(@"Fetching contact info ----> ");
#endif
        isAcessed = accessGranted;
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            // The user has previously given access, add the contact
            isAcessed = YES;
            NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            //        CFArrayRef allPeople  = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex count = CFArrayGetCount((__bridge CFArrayRef)(allContacts));
            
            //To generate array of imported data;
            for (int i = 0; i < count; i++)
            {
                Person *person = [[Person alloc] init];
                
                ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                //NSString *phoneNo =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    
                    ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                    {
                        //                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                        //                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                        //                    NSString *phoneLabel = (__bridge NSString *) ABAddressBookCopyLocalizedLabel(locLabel);
                        //                    NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
                        //                    person.phoneNumber = phoneNumber;
                        //                    CFRelease(phoneNumberRef);
                        //                    CFRelease(locLabel);
                        //                    NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
                        
                        
                        //                    CFStringRef locLabel1 = ABMultiValueCopyLabelAtIndex(phones, j);
                        //
                        //                    NSString *phoneLabel1 =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel1);
                        //                    CFRelease(locLabel1);
                        
                        NSString* phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
                        
                        if (phoneNumber != nil || phoneNumber.length >0)
                        {
                            person.phoneNumber = phoneNumber;
                        }
                        
                        NSLog(@"phoneNumber %@ )", phoneNumber);
                    }
                }
                
                NSString *fullName;
                
                if (firstName && lastName )
                {
                    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                }
                else if (firstName)
                {
                    fullName = [NSString stringWithFormat:@"%@", firstName];
                }
                else if (lastName)
                {
                    fullName = [NSString stringWithFormat:@"%@", lastName];
                }
                else
                {
                    fullName = nil;
                }
                
                NSLog(@"person details are  = %@ firstName = %@ lastName=%@", fullName,firstName, lastName);
                
                if (firstName)
                {
                    person.firstName = firstName;
                }
                if (lastName)
                {
                    person.lastName = lastName;
                }
                if (fullName != nil)
                {
                    person.fullName = fullName;
                }
                
                NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                NSLog(@"person.firstName = %@ ", person.firstName);
                NSLog(@"person.lastName = %@ ", person.lastName);
                NSLog(@"person.fullName = %@ ", person.fullName);
                NSLog(@"person.phoneNumber = %@ ", person.phoneNumber);
                
                ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                
                NSUInteger j = 0;
                for (j = 0; j < ABMultiValueGetCount(emails); j++)
                {
                    NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                    if (j == 0)
                    {
                        if (email)
                        {
                            person.homeEmail = email;
                        }
                        NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                    }
                    
                    else if (j==1)
                        person.workEmail = email;
                }
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    if (person.phoneNumber != nil)
                    {
                        if (person.phoneNumber != nil)
                        {
                            if (person.fullName != nil)
                            {
                                [_arrFriends addObject:person];
                            }
                        }
                    }
                }
                else
                {
                    if (person.homeEmail != nil)
                    {
                        if (person.fullName != nil)
                        {
                            [_arrFriends addObject:person];
                        }
                    }
                }
                
                //clientObject = nil;
            }
            NSLog(@"data collection :- %@",_arrFriends);
//            [tableFriends reloadData];
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            isAcessed = YES;
            NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
            
            //        CFArrayRef allPeople  = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex count = CFArrayGetCount((__bridge CFArrayRef)(allContacts));
            
            //To generate array of imported data;
            for (int i = 0; i < count; i++)
            {
                Person *person = [[Person alloc] init];
                
                ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
                
                NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
                NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
                //NSString *phoneNo =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                {
                    
                    ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
                    {
                        //                    CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
                        //                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
                        //                    NSString *phoneLabel = (__bridge NSString *) ABAddressBookCopyLocalizedLabel(locLabel);
                        //                    NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
                        //                    person.phoneNumber = phoneNumber;
                        //                    CFRelease(phoneNumberRef);
                        //                    CFRelease(locLabel);
                        //                    NSLog(@"  - %@ (%@)", phoneNumber, phoneLabel);
                        
                        
                        //                    CFStringRef locLabel1 = ABMultiValueCopyLabelAtIndex(phones, j);
                        //
                        //                    NSString *phoneLabel1 =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel1);
                        //                    CFRelease(locLabel1);
                        
                        
                        NSString* phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, j);
                        
                        if (phoneNumber != nil || phoneNumber.length >0)
                        {
                            person.phoneNumber = phoneNumber;
                        }
                        
                        NSLog(@"phoneNumber %@ )", phoneNumber);
                    }
                }
                
                NSString *fullName;
                
                if (firstName && lastName )
                {
                    fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                }
                else if (firstName)
                {
                    fullName = [NSString stringWithFormat:@"%@", firstName];
                }
                else if (lastName)
                {
                    fullName = [NSString stringWithFormat:@"%@", lastName];
                }
                else
                {
                    fullName = nil;
                }
                
                NSLog(@"person details are  = %@ firstName = %@ lastName=%@", fullName,firstName, lastName);
                
                if (firstName)
                {
                    person.firstName = firstName;
                }
                if (lastName)
                {
                    person.lastName = lastName;
                }
                if (fullName != nil)
                {
                    person.fullName = fullName;
                }
                
                NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                NSLog(@"person.firstName = %@ ", person.firstName);
                NSLog(@"person.lastName = %@ ", person.lastName);
                NSLog(@"person.fullName = %@ ", person.fullName);
                NSLog(@"person.phoneNumber = %@ ", person.phoneNumber);
                
                ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
                
                NSUInteger j = 0;
                for (j = 0; j < ABMultiValueGetCount(emails); j++)
                {
                    NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                    if (j == 0)
                    {
                        if (email)
                        {
                            person.homeEmail = email;
                        }
                        NSLog(@"person.homeEmail = %@ ", person.homeEmail);
                    }
                    
                    else if (j==1)
                        person.workEmail = email;
                }
                [_arrFriends addObject:person];
                
                //                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                //                {
                //                    if (person.phoneNumber != nil)
                //                    {
                //                        if (person.phoneNumber != nil)
                //                        {
                //                            if (person.fullName != nil)
                //                            {
                //                                [_arrFriends addObject:person];
                //                            }
                //                        }
                //                    }
                //
                //                }
                //                else
                //                {
                //                    if (person.homeEmail != nil)
                //                    {
                //                        if (person.fullName != nil)
                //                        {
                //                            [_arrFriends addObject:person];
                //                        }
                //                    }
                //                }
                
                //clientObject = nil;
            }
            NSLog(@"data collection :- %@",_arrFriends);
            if (_arrFriends.count==0) {
                
                [AlertView showAlertwithTitle:@"Active Life App" message:@"No contacts available in the phone's contacts."];
            }
            [tableFriends reloadData];
        }
    }
    else {
#ifdef DEBUG
        //        UIAlertView *accssAlert = [[UIAlertView alloc]initWithTitle:AlertTitle message:@"There is no permession to access contacts. Go to settings -> Privacy -> Enable contacts" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [accssAlert show];
        
        NSLog(@"Cannot fetch Contacts :( ");
#endif
    }
}


#pragma mark Sending Emails to selected contacts

-(IBAction)sendEmailToContacts :(id)sender
{
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:[_friendEmailsArray componentsJoinedByString:@","] forKey:@"emails"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    [webserviceCall callWebserviceWithIdentifier:@"SendAppInvitation" andArguments:postDict];
}

//#import "PeopleCustomCell.h"
#pragma mark UITableView Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_arrFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"%i,%i",indexPath.row,indexPath.section];
    UITableViewCell *cell;
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 14, 190, 16)];
    senderLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    
    UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(270,19,26,26)];
    checkButton.userInteractionEnabled = NO;
    [checkButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [checkButton setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateSelected];
    checkButton.tag = (indexPath.row+1)*100;
    
    Person *person = [_arrFriends objectAtIndex:indexPath.row];
    senderLabel.text = [NSString stringWithFormat:@"%@",person.fullName];
    senderLabel.tag = indexPath.row;
    if ([_contactDictPost objectForKey:[NSString stringWithFormat:@"%i",checkButton.tag]]) {
        checkButton.selected = [[_contactDictPost valueForKey:[NSString stringWithFormat:@"%i",checkButton.tag]]boolValue];
    }
    
    NSLog(@"picture...%@",person.picture);
    
    UIImageView *friendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 40, 40)];
//    NSURL *url = [NSURL URLWithString:[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]];
    NSURL *url = [NSURL URLWithString:@""];
    
    friendImageView.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0].CGColor;
    friendImageView.layer.borderWidth = 1.0;
    friendImageView.layer.cornerRadius = friendImageView.frame.size.height/2;
    friendImageView.layer.masksToBounds = YES;
    [friendImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"No_image_available.png"]];

    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 35, 190, 16)];
    emailLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    NSLog(@"person.homeEmail..%@",person.homeEmail);
    
    if (person.homeEmail != NULL) {
        emailLabel.text = [NSString stringWithFormat:@"%@",person.homeEmail];
    }
    else{
        emailLabel.text = @"No email available";
        cell.userInteractionEnabled = NO;
    }
    
    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(20,64,280,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    [cell.contentView addSubview:labelSeparator];
    
    [cell.contentView addSubview:friendImageView];
    [cell.contentView addSubview:senderLabel];
    [cell.contentView addSubview:emailLabel];
    [cell.contentView addSubview:checkButton];
    
    return cell;
}

#pragma mark - Table View Delagate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [(UIButton *)[self.view viewWithTag:45] setHidden:YES];
    [(UIButton *)[self.view viewWithTag:46] setHidden:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *checkButton1 = (UIButton *)[cell viewWithTag:(indexPath.row+1)*100];
    
    if (checkButton1.selected == YES) {
        [checkButton1 setSelected:NO];
    }
    else{
        [checkButton1 setSelected:YES];
    }
    
    Person *person  = (Person *)[_arrFriends objectAtIndex:indexPath.row];

    [_friendEmailsArray addObject:person.homeEmail];
    [_contactDictPost setObject:[NSString stringWithFormat:@"%d",checkButton1.selected] forKey:[NSString stringWithFormat:@"%i",checkButton1.tag]];
    NSLog(@"_contactDictPost..%@",_contactDictPost);
    NSLog(@"_friendEmailsArray..%@",_friendEmailsArray);
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    NSLog(@"sender..%@",sender);
    if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
        [AlertView showAlertwithTitle:@"Active Life App" message:@"Application invitation sent successfully to selected contacts."];
    }
}

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");
}

#pragma mark - Memory Warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
