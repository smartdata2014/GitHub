//
//  CreateEventViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 23/06/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "CreateEventViewController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
//#import "PeopleCustomCell.h"
//#import "Facebook.h"

@interface CreateEventViewController ()<SWRevealViewControllerDelegate,MFMailComposeViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITextField *txtName, *txtTime, *txtPlace, *txtActivity;
    IBOutlet UILabel *lblHeading;
    IBOutlet UITextView *txtDescription;
    IBOutlet UITableView *tableFriends;
    IBOutlet UIImageView *eventImageView;
    IBOutlet UIView *uploadImageView;
    IBOutlet UIBarButtonItem *menuBarButton;
    IBOutlet UIScrollView *scrollView;
    UIDatePicker *myPicker;
    UIToolbar *toolbar;
    UIActionSheet *actionSheet;
    UIPickerView *activityPickerView;
    UIImageView *checkCrossImage;
}

@property (nonatomic, strong) NSMutableArray *arrFriends;
@property (nonatomic, strong) NSArray *arrActivities;
@property (nonatomic, strong) NSMutableDictionary *postDict;
@property (nonatomic, strong) NSMutableArray *friendIdArray;
@property (nonatomic, strong) ABPeoplePickerNavigationController *addressBookController;

-(IBAction)btnActionSegmentControl:(id)sender;
-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)btnPublishPressed:(id)sender;
-(IBAction)btnUploadImagePressed:(id)sender;
@end

@implementation CreateEventViewController
@synthesize delegate;

@synthesize eventStoreCalendarIdentifier, locSuggetionArray,eventId;
int segmentIndex;
NSDateFormatter *timeFormatter;

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
    name_checkmark.hidden=YES;
    self.navigationController.navigationBarHidden = YES;
    _postDict = [[NSMutableDictionary alloc] init];
    _friendIdArray = [[NSMutableArray alloc] init];
    
    tableFriends.userInteractionEnabled = NO;
    tableFriends.alpha = 0.5;
    
    timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    
    _arrActivities = [[NSArray alloc] initWithObjects:@"Archery",@"Basketball",@"Camel Racing",@"Canoeing",@"Car Rallying",@"Cricket",@"Cycling",@"Diving",@"Football",@"Golf",@"Horse Riding",@"Kayaking",@"Polo",@"Running",@"Sailing",@"Rock Climbing",@"Soccer",@"Swimming",@"Tennis",@"Volleyball",@"Water Skiing",nil];
    
    _arrFriends = [[NSMutableArray alloc] init];
    
    txtDescription.text = @"Description (optional)";
    txtDescription.textColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    tableLocSuggetion.backgroundColor = [UIColor clearColor];
    
    [self btnActionSegmentControl:(UISegmentedControl *)[self.view viewWithTag:501]];
    [self btnActionSegmentControl:(UISegmentedControl *)[self.view viewWithTag:502]];
//    [self btnActionSegmentControl:(UISegmentedControl *)[self.view viewWithTag:503]];
    [self fetchFriendsListForPage:0];
    NSLog(@"_arrFriends...%@",_arrFriends);
    
    for (int i=0; i<3; i++) {
        checkCrossImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_icon.png"] highlightedImage:[UIImage imageNamed:@"crossmark_icon.png"]];
        checkCrossImage.frame = CGRectMake(286, 77 + i*32, 26, 26);
        checkCrossImage.hidden = YES;
        checkCrossImage.tag = 300+i+1;
        [self.view addSubview:checkCrossImage];
    }
    [tableLocSuggetion setHidden:YES];
    
    if (eventId != NULL) {
        lblHeading.text = @"Edit Event";
        
        SWRevealViewController *revealController = [self revealViewController];
        UINavigationController *navController = revealController.navigationController;

        navController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(BackPressed)];
        
        [menuBarButton setImage:[UIImage imageNamed:@"back_arrow_icon"]];
        NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
        [postDict setObject:eventId forKey:@"event_id"];
        [postDict setObject:KAPI_KEY forKey:@"api_key"];
        [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
        [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",eventId,KAPI_KEY,[postDict valueForKey:@"timestamp"]]] forKey:@"signature"];
        
        WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
        webserviceCall.delegate = self;
        webserviceCall.tag = 1002;
        [webserviceCall callWebserviceWithIdentifier:@"EventDetails" andArguments:postDict];
    }
}

-(void)viewWillAppear:(BOOL)animated{
//    [self getFacebookFriends];
}

-(void)reloadTableView{
    NSLog(@"_arrFriends..%@",_arrFriends);
    [tableFriends reloadData];
    //    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark Handling Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

/*
#pragma mark Fetching Friends From Facebook

-(void)getFacebookFriends{
//    [_arrFriends removeAllObjects];
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _arrFriends = [[NSMutableArray alloc] init];
//    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
//    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
//                                                  NSDictionary* result,
//                                                  NSError *error) {
//        _arrFriends = [result objectForKey:@"data"];
//        NSLog(@"friends..%@",_arrFriends);
//        NSLog(@"Found: %i friends", _arrFriends.count);
//        for (NSDictionary<FBGraphUser>* friend in _arrFriends) {
//            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
//            NSLog(@"Result===%@\nfriends===>",result);
//            
//        }
//    }];
    NSLog(@"activeSession..%@",[FBSession activeSession]);
    NSLog(@"Session:%@",[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
                         [FBSession activeSession].accessTokenData.accessToken]);
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@&fields=name,picture,id",FBSession.activeSession.accessTokenData.accessToken];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSDictionary *dict= [self getFBuserProfileDetailsWithURL:url];
    NSLog(@"dict is %@",dict);
//    _arrFriends = [dict valueForKey:@"data"];
    [_arrFriends addObjectsFromArray:[dict valueForKey:@"data"]];
//    if ([FBSession activeSession].isOpen)
//    {
//        NSLog(@"Session:%@",[NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",
//                             [FBSession activeSession].accessTokenData.accessToken]);
//        NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/me/friends?access_token=%@",FBSession.activeSession.accessTokenData.accessToken];
//        
//        NSURL *url = [NSURL URLWithString:urlString];
//        
//        NSDictionary *dict= [self getFBuserProfileDetailsWithURL:url];
//        NSLog(@"dict is %@",dict);
//    }
//    else
//    {
//        // login-needed account UI is shown whenever the session is closed
//    }
    
    [self performSelector:@selector(reloadTableView) withObject:self afterDelay:5.0];
}

-(NSDictionary*)getFBuserProfileDetailsWithURL:(NSURL *)url{
    // NSLog(@"getFBuserProfileDetailsWithURL:%@",url);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    
    
    id jsonResponse = nil;
    NSDictionary *responseDict= nil;
    
    if (response == nil) {
        // Check for problems
        if (error != nil) {
            //
            NSLog(@"curr_lat:%@",[error localizedDescription]);
            return nil;
        }
    }
    else {
        // Data was received.. continue processing
        jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        // NSLog(@"jsonResponse:%@",jsonResponse);
        
        if ([jsonResponse isKindOfClass:[NSDictionary class]]) {
            
            responseDict = (NSDictionary *)jsonResponse;
            
            // messageString = [responseDict objectForKey:@"Message"];
            
            NSLog(@"responseDict:%@",responseDict);
            return responseDict;
        }
        
    }
    return responseDict;
}

#pragma mark Fetching Friends From Address Book

-(void)getContactFromAddressBook
{
//  [_arrFriends removeAllObjects];
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
            [tableFriends reloadData];
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
*/
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

#pragma mark Segment Control Action

-(IBAction)btnActionSegmentControl:(UISegmentedControl *)sender
{
    NSLog(@"Segment..%i",[sender selectedSegmentIndex]);
    if (sender.tag == 501) {
        if ([sender selectedSegmentIndex]==0) {
            tableFriends.userInteractionEnabled = NO;
            tableFriends.alpha = 0.5;
            [_postDict setObject:@"Public" forKey:@"event_privacy"];
            [(UIButton *)[self.view viewWithTag:701] setSelected:YES];
            [(UIButton *)[self.view viewWithTag:702] setSelected:NO];
        }
        else{
            tableFriends.userInteractionEnabled = YES;
            tableFriends.alpha = 1.0;
            [_postDict setObject:@"Private" forKey:@"event_privacy"];
            [(UIButton *)[self.view viewWithTag:701] setSelected:NO];
            [(UIButton *)[self.view viewWithTag:702] setSelected:YES];
        }
    }
    else if (sender.tag == 502) {
        if ([sender selectedSegmentIndex]==0) {
            [(UIButton *)[self.view viewWithTag:601] setSelected:YES];
            [(UIButton *)[self.view viewWithTag:602] setSelected:NO];
            [(UIButton *)[self.view viewWithTag:603] setSelected:NO];
            [_postDict setObject:@"Male" forKey:@"event_gender"];
        }
        else if ([sender selectedSegmentIndex]==1){
            [(UIButton *)[self.view viewWithTag:601] setSelected:NO];
            [(UIButton *)[self.view viewWithTag:602] setSelected:YES];
            [(UIButton *)[self.view viewWithTag:603] setSelected:NO];
            [_postDict setObject:@"Female" forKey:@"event_gender"];
        }
        else if ([sender selectedSegmentIndex]==2){
            [(UIButton *)[self.view viewWithTag:601] setSelected:NO];
            [(UIButton *)[self.view viewWithTag:602] setSelected:NO];
            [(UIButton *)[self.view viewWithTag:603] setSelected:YES];
            [_postDict setObject:@"Both" forKey:@"event_gender"];
        }
    }
    else{
        [_arrFriends removeAllObjects];
        
        if ([sender selectedSegmentIndex]==0) {
            segmentIndex = 0;
            [(UIButton *)[self.view viewWithTag:101]setSelected:YES];
            [(UIButton *)[self.view viewWithTag:102]setSelected:NO];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"] length])
            {
                
//                [self getFacebookFriends];
            }
            else
            {
                [AlertView showAlertwithTitle:@"Active Life App" message:@"Please login with facebook in order to get facebook friends."];
            }
        }
        else{
            segmentIndex = 1;
            [(UIButton *)[self.view viewWithTag:101]setSelected:NO];
            [(UIButton *)[self.view viewWithTag:102]setSelected:YES];
            NSLog(@"Fb id=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"]);
            //        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_id"] length])
            //        {
//            [self getContactFromAddressBook];
            //        }
            //        else
            //        {
            //            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Active life" message:@"you had not logged in with facebook" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            //            [alert show];
            //        }
        }
        [tableFriends reloadData];
    }
}


#pragma mark - General Button Actions

-(IBAction)btnMenuPressed:(id)sender{
    
    if(eventId != NULL){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        SWRevealViewController *revealController = [self revealViewController];
        [revealController revealToggle:nil];
    }
}

-(IBAction)btnPublishPressed:(id)sender
{
    
//    [AlertView showAlertwithTitle:@"Active Life App" message:@"Would you like to upload the image for this event."];
    if ([txtName.text isEqualToString:@""]||[txtTime.text isEqualToString:@""]||[txtPlace.text isEqualToString:@""]||[txtActivity.text isEqualToString:@""]) {
        [AlertView showAlertwithTitle:@"Active Life App" message:@"Please fill all the required fields."];
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Active Life App" message:@"Would you also like to upload the image for this event." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag= 601;
    [alertView show];
    
    /* Facebook* facebook = [[Facebook alloc] initWithAppId:@"690713350939993"];
     
     for (int i=0; i<_arr.count; i++)
     {
     NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"Active Life", @"title",
     @"Test",  @"message",
     [_arr objectAtIndex:i], @"to",
     nil];
     
     [facebook dialog:@"apprequests" andParams:params andDelegate:self];
     }
     
     NSLog(@"_postDict..%@",_postDict);
     [AlertView showAlertwithTitle:@"Success" message:@"Event has been created successfully"];*/
    
  }

-(void)selectDateOrTime{
    
    [txtTime resignFirstResponder];
    myPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,353,0,0)];
    myPicker.backgroundColor = [UIColor lightGrayColor];
    myPicker.datePickerMode = UIDatePickerModeTime;
    [myPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:myPicker];
    
    toolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, 308, myPicker.frame.size.width, 50)];
    [myPicker setDate: txtTime.text.length ? [timeFormatter dateFromString:txtTime.text]:[NSDate date] animated:YES];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStyleBordered target: self action: @selector(donePressed)];
    doneButton.tintColor = [UIColor colorWithRed:14.0/255.0 green:112.0/255.0 blue:220.0 /255.0 alpha:1.0];
    UIBarButtonItem* flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolbar.items = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    [self.view addSubview: toolbar];
}

/*
-(void)synchroniseEventsWithDeviceCalender{
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    [postDict setObject:@"5" forKey:@"month"];
    [postDict setObject:@"2014" forKey:@"year"];
    [postDict setObject:@"14" forKey:@"trainer_id"];
    
    NSDictionary *returnDict = [[NSDictionary alloc] init];
    
    if ([[returnDict objectForKey:@"success"] boolValue]) {
        NSMutableArray *shiftsArray=[[returnDict objectForKey:@"data"] mutableCopy];
        
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        NSArray *cals = [eventStore calendarsForEntityType: EKEntityTypeEvent];
        
        NSError* error = nil;
        for (EKCalendar *cal in cals) {
            if ([cal.title isEqualToString:@"Active Life Calendar"]) {
                BOOL result = [eventStore removeCalendar:cal commit:YES error:&error];
                if (result) {
                    NSLog(@"Deleted calendar from event store.");
                }
            }
        }
        
        EKCalendar *calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
        calendar.title = @"Active Life Calendar";
        EKSource* localSource = nil;
        EKSource* iCloudSource = nil;
        EKSource* mailSource = nil;
        EKSource* subscribedSource = nil;
        
        for (EKSource* source in eventStore.sources){
            if (source.sourceType == EKSourceTypeLocal){
                localSource = source;
            }else if(source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]){
                iCloudSource = source;
            }else if(source.sourceType == EKSourceTypeSubscribed){
                subscribedSource = source;
            }else if(source.sourceType == EKSourceTypeCalDAV){
                mailSource = source;
            }
        }
        
        if (iCloudSource && [iCloudSource.calendars count] != 0) {
            calendar.source = iCloudSource;
            
        }else if(mailSource && [mailSource.calendars count] > 0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Active Life App" message:@"Calendar Sync need the iCloud enabled, Please go to Settings > iCloud and enable Caledar to Sync shifts with Default calendar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
            
        }else if(subscribedSource && [subscribedSource.calendars count] > 0){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Active Life App" message:@"Calendar Sync need the iCloud enabled, Please go to Settings > iCloud and enable Caledar to Sync shifts with Default calendar" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
            
        }else{
            calendar.source = localSource;
        }
        BOOL result = [eventStore saveCalendar:calendar commit:YES error:&error];
        
        if (result) {
            self.eventStoreCalendarIdentifier=calendar.calendarIdentifier;
            //                [eventIdArray addObject:self.eventStoreIdentifier];
            //                [[NSUserDefaults standardUserDefaults] setObject:eventIdArray forKey:@"eventStoreIdentifier"];
            //                [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        for (int i=0; i<[shiftsArray count]; i++)
        {
            NSDictionary *shiftDict = [shiftsArray objectAtIndex:i];
            NSArray *tempArray2 = [shiftDict objectForKey:@"eventData"];
            for (int k=0; k<[tempArray2 count]; k++)
            {
                if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
                    //            // iOS 6 and later
                    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                        if (error)
                        {
                            // display error message here
                            NSLog(@"error is %@",[error description]);
                            //----- codes here when user NOT allow your app to access the calendar.
                        }
                        else if (!granted)
                        {
                            // display access denied error message here
                        }
                        else
                        {
                            // access granted
                            // ***** do the important stuff here *****
                            //---- codes here when user allow your app to access theirs' calendar.
                            
                            NSDictionary *timeDict = [tempArray2 objectAtIndex:k];
                            //                                            EKEventStore *eventStore = [[EKEventStore alloc] init];
                            EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                            EKCalendar *calendar = [eventStore calendarWithIdentifier:self.eventStoreCalendarIdentifier];
                            event.calendar = calendar;
                            
                            NSString *startDateStr = [NSString stringWithFormat:@"%@ %@",[shiftDict objectForKey:@"eventDate"],[timeDict objectForKey:@"time"]];
                            NSDateFormatter *startDateFormatter = [[NSDateFormatter alloc] init];
                            [startDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                            //                                            [startDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
                            NSDate *startDate = [startDateFormatter dateFromString:startDateStr];
                            NSDate *endDate;
                            if ([[timeDict objectForKey:@"time_limit"] isEqualToString:@"30 minutes"]) {
                                
                                endDate = [startDate dateByAddingTimeInterval:30*60];
                            }else{
                                endDate = [startDate dateByAddingTimeInterval:[[[timeDict objectForKey:@"time_limit"] substringToIndex:[[timeDict objectForKey:@"time_limit"] rangeOfString:@" "].location] floatValue]*60*60];
                            }
                            NSLog(@"finalStartDate %@ finalEndDate %@",startDate,endDate);
                            
                            event.startDate = [[NSDate alloc] initWithTimeInterval:0 sinceDate:startDate];
                            //                                event.startDate = strtDate;
                            event.endDate = endDate;
                            event.title = @"Appointment";
                            
                            event.notes = [NSString stringWithFormat:@"Your appointment will start on %@",event.startDate];
                            NSError *error = nil;
                            BOOL result = [eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&error];
                            if (result) {
                                NSLog(@"Saved event to event store.");
                            }
                            
                            NSError *err;
                            if(err)
                                NSLog(@"unable to save event to the calendar!: Error= %@", err);
                        }
                    }];
                }
            }
        }
    }
}
*/
 
-(void)selectActivity{
    [txtActivity resignFirstResponder];
    
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:nil
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    CGRect pickerFrame = CGRectMake(0, 50, 320, 200);
    
    activityPickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
    activityPickerView.showsSelectionIndicator = YES;
    activityPickerView.dataSource = self;
    activityPickerView.delegate = self;
    
    [activityPickerView selectRow:txtActivity.text.length?[_arrActivities indexOfObject:txtActivity.text]:0 inComponent:0 animated:YES];

    //    [activityPickerView selectRow:txtAge.text.length?[_ageArr indexOfObject:txtAge.text]:0 inComponent:0 animated:YES];
    //    txtAge.text =  txtAge.text.length ? txtAge.text : [_ageArr objectAtIndex:0];
    //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    //    button.frame = CGRectMake(260, 320, 50, 50);
    //    [button setTitle:@"Done" forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    //    [button setBackgroundColor:[UIColor redColor]];
    [actionSheet addSubview:activityPickerView];
    [actionSheet showInView:self.view];
    //[[[UIApplication sharedApplication] keyWindow]addSubview:button];
    [actionSheet setBounds:CGRectMake(0,0,320, 400)];
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

-(IBAction)timeAction:(id)sender
{
 
    [txtTime resignFirstResponder];

    [self createActionSheet];
    datePickerType = @"datepicker";
    select = NO;
    chPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    [chPicker setDate:[NSDate date]];
    [chPicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
//    [txtTime setInputView:chPicker];
    chPicker.datePickerMode=UIDatePickerModeDateAndTime;
    [actionSheet addSubview:chPicker];
}

-(void)donePressed:(UIButton *)sender{
    [sender removeFromSuperview];
    //    [activityPickerView removeFromSuperview];
    //[toolbar removeFromSuperview];
    //    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    actionSheet = nil;
    
}

-(void)updateTextField:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    txtTime.text = [dateFormatter stringFromDate:[chPicker date]];
    NSLog(@"avi===>%@",[dateFormatter stringFromDate:[chPicker date]]);
}

-(IBAction)ageAction:(id)sender;
{
    [txtName resignFirstResponder];
    [txtPlace resignFirstResponder];
    [txtActivity resignFirstResponder];
    [txtTime resignFirstResponder];
    [self selectActivity];
    
}

-(IBAction)btnUploadImagePressed:(id)sender{
    actionSheet = [[UIActionSheet alloc] initWithTitle: nil
                                                             delegate: self
                                                    cancelButtonTitle: @"Cancel"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles: @"Take a new image", @"Choose from existing", nil];
    actionSheet.tag = 402;
    [actionSheet showInView:self.view];
}

#pragma mark Uploading Image Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //        if (actionSheet.tag == 401) {
    switch (buttonIndex) {
        case 0:
            [self takeNewPhotoFromCamera];
            break;
        case 1:
            [self choosePhotoFromExistingImages];
        default:
            break;
    }
}
- (void)takeNewPhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

-(void)choosePhotoFromExistingImages
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = NO;
        controller.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        controller.delegate = self;
        [self.navigationController presentViewController: controller animated: YES completion: nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"info..%@",info);
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    eventImageView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark Upload Image View Button Actions

-(IBAction)btnSubmitPressed:(id)sender{
    
    NSLog(@"Imageview...%@",eventImageView.image);
    if (eventImageView.image != nil) {
        [self createEventWebserviceCall];
    }
    else{
        [AlertView showAlertwithTitle:@"Active Life App" message:@"Please upload image."];
    }
}

-(IBAction)btnCancelPressed:(id)sender{
    uploadImageView.hidden = YES;
}

#pragma mark UITableView Datasource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView==tableLocSuggetion){
        return 50.0;
    }
    else
        return 64.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView==tableLocSuggetion){
        return [locSuggetionArray count];
    }
    else
        return [_arrFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"%i,%i",indexPath.row,indexPath.section];
    UITableViewCell *cell;
    
    if (cell==nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 17, 190, 16)];
    senderLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    
    if (tableView==tableLocSuggetion) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        cell.textLabel.text=[NSString stringWithFormat:@"%@",[[locSuggetionArray objectAtIndex:indexPath.row] length]?[locSuggetionArray objectAtIndex:indexPath.row]:@""];
        cell.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:0.7];
        cell.textLabel.textColor = [UIColor whiteColor];
        
    }else{
       
        UIButton *checkButton = [[UIButton alloc] initWithFrame:CGRectMake(270,19,26,26)];
        checkButton.userInteractionEnabled = NO;
        [checkButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [checkButton setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateSelected];
        
        checkButton.tag = [[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"user_id"] integerValue];
        
        if ([_friendIdArray indexOfObject:[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"user_id"]]!=NSNotFound) {
            checkButton.selected = YES;
        }
        
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(70, 12, 165, 20)];
        labelName.font = [UIFont fontWithName:@"Helvetica Light" size:13.0];
        labelName.text = [[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"name"];
        [cell.contentView addSubview:labelName];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"location_icon_small.png"];
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"country"]]];
        [myString insertAttributedString:attachmentString atIndex:0];
        UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 32, 165, 20)];
        locationLabel.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
        locationLabel.attributedText = myString;
        locationLabel.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:locationLabel];
        
        UIImageView *friendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 40, 40)];
        NSURL *url = [NSURL URLWithString:[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]];
        friendImageView.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0].CGColor;
        friendImageView.layer.borderWidth = 1.0;
        friendImageView.layer.cornerRadius = friendImageView.frame.size.height/2;
        friendImageView.layer.masksToBounds = YES;
        [friendImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"No_image_available.png"]];
        [cell.contentView addSubview:friendImageView];
        
        [cell.contentView addSubview:checkButton];
        
    }
    //[MBProgressHUD showHUDAddedTo:profilePic animated:YES];
    return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tableView!=tableLocSuggetion) {
//        [(PeopleCustomCell *)cell showFriendImage];
//    }
//}

#pragma mark - Table View Delagate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==tableLocSuggetion) {
        txtPlace.text=[NSString stringWithFormat:@"%@",locSuggetionArray[indexPath.row]];
        [tableLocSuggetion setHidden:YES];
    }
    else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *checkButton1 = (UIButton *)[cell viewWithTag:[[[_arrFriends objectAtIndex:indexPath.row] valueForKey:@"user_id"] integerValue]];
        if (checkButton1.selected == YES) {
            [checkButton1 setSelected:NO];
        }
        else{
            [checkButton1 setSelected:YES];
        }
        
        if ([_friendIdArray indexOfObject:[NSString stringWithFormat:@"%li",checkButton1.tag]]!=NSNotFound) {
            [_friendIdArray removeObject:[NSString stringWithFormat:@"%li",checkButton1.tag]];
        }
        else
            [_friendIdArray addObject:[NSString stringWithFormat:@"%li",checkButton1.tag]];
            NSLog(@"_friendIdArray..%@",_friendIdArray);
    }
}

#pragma mark Creating Actionshet

- (void)createActionSheet
{
    if (actionSheet == nil)
    {
        // setup actionsheet to contain the UIPicker
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
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
        //[actionSheet setBounds:CGRectMake(0,0,320, 464)];
        [actionSheet setBounds:CGRectMake(0,0,320, 400)];
    }
}

#pragma mark- Picker View Button Actions

- (void)pickerDone:(id)sender
{
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    //    txtTime.text = [dateFormatter stringFromDate:[chPicker date]];
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    actionSheet = nil;
}

-(void)pickerCancle: (id)sender;
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    actionSheet = nil;
}

-(void)pickerChanged:(id)sender{
    NSLog(@"TIme....%@",[timeFormatter stringFromDate:[sender date]]);
    txtTime.text = [timeFormatter stringFromDate:[sender date]];
}

#pragma mark PickerView Datasource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_arrActivities count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_arrActivities objectAtIndex:row];
}

#pragma mark PickerView Delegate Methods

- (void)pickerView:(UIPickerView *)	pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    txtActivity.text = [_arrActivities objectAtIndex:row];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark Textfield delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:txtTime]) {
        [self timeAction:nil];
    }
    else if ([textField isEqual:txtActivity]){
        [self selectActivity];
    }
    else if (textField==txtPlace) {
//        [tableLocSuggetion setHidden:NO];
//        [self.view bringSubviewToFront:tableLocSuggetion];
        locSuggetionArray=[[NSMutableArray alloc] init];
        
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField==txtName)
    {
        if (txtName.text.length < 10)
        {
            name_checkmark.hidden=NO;
            name_checkmark.image=[UIImage imageNamed:@"crossmark_icon.png"];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Active Life App" message:@"Atleast 10 charactar" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        else
        {
            name_checkmark.hidden=NO;
            name_checkmark.image=[UIImage imageNamed:@"checkmark_icon.png"];
            
            [txtName resignFirstResponder];
            
        }
        if (txtName.text.length==0)
        {
            NSLog(@"check===");
            name_checkmark.hidden=YES;
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==txtPlace) {
        [tableLocSuggetion setHidden:YES];
        
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //    if (textField==txtName)
    //    {
    //
    //        if (txtName.text.length < 10)
    //        {
    //            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Active Life" message:@"Atleast 10 charactar" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    //            [alert show];
    //        }
    //        else
    //        {
    //            [txtName resignFirstResponder];
    //
    //        }
    
    // }
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == txtPlace) {
        [tableLocSuggetion setHidden:NO];
        [self.view bringSubviewToFront:tableLocSuggetion];
        [self callLoginWebservice];
    }
    return YES;
}

#pragma mark TextView delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"Description (optional)"]) {
        txtDescription.textColor = [UIColor darkGrayColor];
        txtDescription.text = @"";
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [txtDescription resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        txtDescription.text = @"Description (optional)";
        txtDescription.textColor = [UIColor colorWithWhite:0.7 alpha:0.7];
    }
}

#pragma mark Alert View Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 601) {
        if (buttonIndex==1) {
            NSLog(@"YES");
            uploadImageView.hidden = NO;
            
        }
        else{
            [self createEventWebserviceCall];
        }
    }
}

//-(void)donePressed
//{
////    _scrollView.contentOffset = CGPointMake(0, 0);
////    [_txtTherapistName resignFirstResponder];
//
//    [myPicker removeFromSuperview];
//    [toolbar removeFromSuperview];
////    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
//}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
/*
 #pragma mark Webservice Requests and Delegate
 -(void)requestGoogleWebServices
 {
 //    [appDelegate addChargementLoader];
 NSString *textFieldText = txtPlace.text;
 
 
 //    https://maps.googleapis.com/maps/api/place/autocomplete/output?parameters;
 
 NSString *strURL=[NSString stringWithFormat:@"%@input=%@&types=geocode&sensor=false&key=%@",GOOGLE_AUTOCOMPLETE_SEARCH_URL,textFieldText,kGOOGLE_MAP_SERVER_API_KEY_19JUNE];
 
 strURL = [strURL stringByReplacingOccurrencesOfString:@" " withString:@""];
 NSURL *url = [NSURL URLWithString:strURL];
 //    NSLog(@"Login URL- %@",url);
 
 ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
 
 [request setDelegate:self];
 [request setTag:1];
 [request setRequestMethod:@"GET"];
 [request startAsynchronous];
 }
 
 
 - (void)requestFinished:(ASIHTTPRequest *)request
 {
 if(request.tag == 1)
 {
 NSDictionary *returnDict = [[request responseString] JSONValue];
 
 //        NSLog(@"Return Dict Data : %@",returnDict);
 if (![[returnDict objectForKey:@"status"] isEqualToString:@"INVALID_REQUEST"])
 {
 searchDataList = [[NSArray alloc ]initWithArray:[returnDict objectForKey:@"predictions"]];
 }
 //        NSLog(@"Array Data : %@",searchDataList);
 if ([searchDataList count]!=0) {
 [autocompleteDataTable setHidden:NO];
 [autocompleteDataTable reloadData];
 }
 else;
 
 }
 [appDelegate removeChargementLoader];
 }
 
 - (void)requestFailed:(ASIHTTPRequest *)request
 {
 [appDelegate removeChargementLoader];
 NSDictionary *returnDict = [[request responseString] JSONValue];
 NSLog(@"Return Error Dict = %@",returnDict);
 
 NSError *error = [request error];
 if ([error code]==1) {
 
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Internet connection is required" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
 [alert show ];
 alert = nil;
 }
 else if ([error code]!=4)
 {
 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Occurred" message:@"It seems the Server network is not responding." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
 [alert show];
 alert = nil;
 }
 }
 */

#pragma mark Location Suggestion List Webservice call

-(void)callLoginWebservice
{
    [self.urlConnection cancel];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.receivedData = data;
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[[NSURL URLWithString:GOOGLE_API_AUTOCOMPLETE(txtPlace.text.length?txtPlace.text:@"")] standardizedURL]];
    
    //set http method
    [request setHTTPMethod:@"GET"];
    //initialize a post data
    
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    //initialize a connection from request
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.urlConnection = connection;
    
    //start the connection
    [connection start];
}

/*
 this method might be calling more than one times according to incoming data size
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}
/*
 if there is an error occured, this method will be called by connection
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"%@" , error);
}

/*
 if data is successfully received, this method will be called by connection
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //initialize convert the received data to string with UTF8 encoding
    NSString *htmlSTR = [[NSString alloc] initWithData:self.receivedData
                                              encoding:NSUTF8StringEncoding];
    NSLog(@"htmlSTRhtmlSTRhtmlSTR...%@", htmlSTR);
    
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [htmlSTR dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: nil];
    NSLog(@"Converted Dict value is:%@",JSON);
    locSuggetionArray=[[NSMutableArray alloc] init];
    for (id obj in [JSON objectForKey:@"predictions"]) {
        [locSuggetionArray addObject:[obj objectForKey:@"description"]];
    }
    [tableLocSuggetion reloadData];
    
    //initialize a new webviewcontroller
    //    WebViewController *controller = [[WebViewController alloc] initWithString:htmlSTR];
    //
    //    //show controller with navigation
    //    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark Create Event Webservice Call

-(void)createEventWebserviceCall{
    
    [_postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [_postDict setObject:txtName.text forKey:@"event_name"];
    [_postDict setObject:txtTime.text forKey:@"event_date"];
    [_postDict setObject:txtPlace.text forKey:@"venue"];
    [_postDict setObject:txtActivity.text forKey:@"activity"];

    if ([[_postDict valueForKey:@"event_privacy"] isEqualToString:@"Private"]) {
        [_postDict setObject:[_friendIdArray componentsJoinedByString:@","] forKey:@"friend_Ids"];
    }
    
    if ([txtDescription.text isEqualToString:@"Description (optional)"]) {
        [_postDict setObject:@"" forKey:@"description"];
    }
    else{
        [_postDict setObject:txtDescription.text forKey:@"description"];
    }
    
    [_postDict setObject:KAPI_KEY forKey:@"api_key"];
    [_postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    
    if (eventImageView.image != nil) {
        NSData *imageData = UIImageJPEGRepresentation(eventImageView.image, 0.2);
        NSString *base64 = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        [_postDict setObject:base64 forKey:@"image"];
    }
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 1001;
    
    if (eventId != NULL) {
        [_postDict setObject:eventId forKey:@"event_id"];
        [_postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],eventId,KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
        [webserviceCall callWebserviceWithIdentifier:@"EditEvent" andArguments:_postDict];
        
    }else{
        [_postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
        [webserviceCall callWebserviceWithIdentifier:@"CreateEvent" andArguments:_postDict];
    }

}


#pragma mark - Call Webservice for Fetching Users Friends List

-(void)fetchFriendsListForPage :(int)pageNo{
    
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    
//    [postDict setObject:[NSString stringWithFormat:@"%i",pageNo] forKey:@"page_num"];
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 1011;
    [webserviceCall callWebserviceWithIdentifier:@"UserFriendList" andArguments:postDict];
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    NSLog(@"sender..%@",sender);
    if (Tag == 1001) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:[sender valueForKey:@"message"]];
            uploadImageView.hidden = YES;
        }
    }
    else if (Tag == 1002) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            
            txtName.text = [[sender valueForKey:@"event_details"] valueForKey:@"event_name"];
            txtTime.text = [[sender valueForKey:@"event_details"] valueForKey:@"event_date"];
            txtPlace.text = [[sender valueForKey:@"event_details"] valueForKey:@"event_location"];
            txtActivity.text = [[sender valueForKey:@"event_details"] valueForKey:@"event_activity"];
            
            if ([[[sender valueForKey:@"event_details"] valueForKey:@"event_description"] isEqualToString:@""]) {
                txtDescription.text = @"Description (optional)";
                txtDescription.textColor = [UIColor colorWithWhite:0.7 alpha:0.7];
            }
            else{
                txtDescription.text = [[sender valueForKey:@"event_details"] valueForKey:@"event_description"];
                txtDescription.textColor = [UIColor darkGrayColor];
            }
            
            if ([[[sender valueForKey:@"event_details"] valueForKey:@"event_image"] isEqualToString:@""]) {
                eventImageView.image = [UIImage imageNamed:@"No_image_asvailable"];
                [(UIButton *)[uploadImageView viewWithTag:800] setTitle:@"Add Image" forState:UIControlStateNormal];
            }
            else{
                eventImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[sender valueForKey:@"event_details"] valueForKey:@"event_image"]]]];
                [(UIButton *)[uploadImageView viewWithTag:800] setTitle:@"Edit Image" forState:UIControlStateNormal];
            }
            
            ((UISegmentedControl *)[self.view viewWithTag:501]).selectedSegmentIndex = [[[sender valueForKey:@"event_details"] valueForKey:@"event_privacy"] integerValue];
            
            ((UISegmentedControl *)[self.view viewWithTag:502]).selectedSegmentIndex = [[[sender valueForKey:@"event_details"] valueForKey:@"event_gender"] integerValue];

            [self performSelector:@selector(btnActionSegmentControl:) withObject:((UISegmentedControl *)[self.view viewWithTag:501]) afterDelay:0.0];
            
            [self performSelector:@selector(btnActionSegmentControl:) withObject:((UISegmentedControl *)[self.view viewWithTag:502]) afterDelay:0.0];
        }
    }
    else if (Tag ==1011){
        
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [_arrFriends addObjectsFromArray:[sender valueForKey:@"users"]];
            [tableFriends reloadData];
        }
    }
    else{
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            uploadImageView.hidden = YES;
        }
    }
}

-(void)webRequestFailed:(id)sender{
    NSLog(@"webRequestFailed");
}


#pragma mark Memory Warnings

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
