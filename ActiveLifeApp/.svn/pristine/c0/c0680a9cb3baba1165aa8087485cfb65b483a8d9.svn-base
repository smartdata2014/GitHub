//
//  FriendRequestViewController.m
//  Active Life App
//
//  Created by sdnmacmini10 on 03/09/14.
//  Copyright (c) 2014 sdnmacmini10. All rights reserved.
//

#import "FriendRequestViewController.h"

@interface FriendRequestViewController ()
{
    IBOutlet UITableView *tableFriendRequest;
}


@property (nonatomic, strong) NSMutableArray *responseArr;
-(IBAction)btnMenuPressed:(id)sender;
-(IBAction)btnLogOutPressed:(id)sender;
@end

@implementation FriendRequestViewController

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

-(void)viewWillAppear:(BOOL)animated{

    _responseArr = [[NSMutableArray alloc] init];
    NSMutableDictionary *postDict = [[NSMutableDictionary alloc] init];
    
    [postDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"user_id"];
    [postDict setObject:KAPI_KEY forKey:@"api_key"];
    [postDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    [postDict setObject:[AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@",[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]] forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 1011;
    [webserviceCall callWebserviceWithIdentifier:@"FriendRequestList" andArguments:postDict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - General Button Actions

-(IBAction)btnMenuPressed:(id)sender{
//    [txtSearch resignFirstResponder];
    SWRevealViewController *revealController = [self revealViewController];
    [revealController revealToggle:nil];
}

-(IBAction)btnLogOutPressed:(id)sender{
    
    SettingsViewController *settingsViewController = [[AppDelegate storyBoard] instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
    
    //    UINavigationController *navController =(UINavigationController *) [UIApplication sharedApplication].keyWindow.rootViewController;
    //    [navController popViewControllerAnimated:YES];
}


#pragma mark - Table View Datasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_responseArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationCells";
    UITableViewCell *cell;
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//    cell.backgroundColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *labelNotification = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 220, 45)];
    labelNotification.numberOfLines = 3;
    labelNotification.font = [UIFont fontWithName:@"Helvetica Light" size:11.0];
    labelNotification.textColor = [UIColor grayColor];
    labelNotification.text = [NSString stringWithFormat:@"%@ wants to add you as a friend.",[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"name"]];
 /*
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss zz"];
    
    NSDate *date1 = [format dateFromString:[NSString stringWithFormat:@"%@",[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"RecievedDate"]]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                               fromDate:date1
                                                 toDate:[NSDate date]
                                                options:0];
    
    NSLog(@"Difference in date components: %@  %i/%i/%i/%i",date1,components.day,components.hour,components.minute,components.second);
    
    NSString *labelTimeStr;
    
    if (components.day==1) {
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        labelTimeStr = [NSString stringWithFormat:@"Yesterday at %@",[timeFormatter stringFromDate:date1]];
    }
    else if(components.day == 0){
        if (components.hour>0) {
            labelTimeStr = [NSString stringWithFormat:@"%i hours ago",components.hour];
        }
        else if (components.minute>0){
            labelTimeStr = [NSString stringWithFormat:@"%i minutes ago",components.minute];
        }
        else if (components.second>0){
            labelTimeStr = [NSString stringWithFormat:@"%i seconds ago",components.second];
        }
    }
    else{
        NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
        [newDateFormatter setDateFormat:@"dd MMMM 'at' HH:mm"];
        labelTimeStr = [NSString stringWithFormat:@"%@",[newDateFormatter stringFromDate:date1]];
    }
    
    UILabel *labelTime = [[UILabel alloc] initWithFrame:CGRectMake(75, 60, 145, 15)];
    labelTime.numberOfLines = 1;
    labelTime.font = [UIFont fontWithName:@"Helvetica Light" size:9.0];
    labelTime.textColor = [UIColor grayColor];
    labelTime.text = labelTimeStr;
  */
  
  
    UILabel *labelSeparator = [[UILabel alloc]initWithFrame:CGRectMake(20,80,280,1)];
    labelSeparator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    UIImageView *friendImageView = [[UIImageView alloc] initWithFrame: CGRectMake(10, 15, 50, 50)];
    friendImageView.layer.borderColor = [UIColor colorWithRed:19.0/255.0 green:182.0/255.0 blue:241.0/255.0 alpha:1.0].CGColor;
    friendImageView.layer.borderWidth = 1.0;
    friendImageView.layer.cornerRadius = friendImageView.frame.size.height/2;
    friendImageView.layer.masksToBounds = YES;
    NSURL *url = [NSURL URLWithString:[[_responseArr objectAtIndex:indexPath.row] valueForKey:@"profile_picture"]];
    
    [friendImageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"No_image_available.png"]];
    [cell.contentView addSubview:friendImageView];
    
    UIButton *btnCrossMark = [[UIButton alloc] initWithFrame:CGRectMake(275, 45, 30, 30)];
    [btnCrossMark addTarget:self action:@selector(btnDeclineRequest:) forControlEvents:UIControlEventTouchUpInside];
    [btnCrossMark setImage:[UIImage imageNamed:@"crossmark_icon"] forState:UIControlStateNormal];
    btnCrossMark.tag = 100 + indexPath.row;
    
    UIButton *btnCheckMark = [[UIButton alloc] initWithFrame:CGRectMake(240, 45, 30, 30)];
    [btnCheckMark addTarget:self action:@selector(btnAcceptRequest:) forControlEvents:UIControlEventTouchUpInside];
    [btnCheckMark setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
    [btnCheckMark setImage:[UIImage imageNamed:@"checkmark_icon"] forState:UIControlStateSelected];
    btnCheckMark.tag = 200 + indexPath.row;
    
    [cell.contentView addSubview:btnCheckMark];
    [cell.contentView addSubview:btnCrossMark];
    [cell.contentView addSubview:labelNotification];
    [cell.contentView addSubview:labelSeparator];
    return cell;
}


//#pragma mark - Deleting The Table View Cell
//
//-(void)btnRemoveNotificationPressed:(UIButton *)sender{
//    NSLog(@"btnRemoveNotificationPressed");
//    NSLog(@"((UISegmentedControl *)[self.view viewWithTag:1010]).selectedSegmentIndex..%d",((UISegmentedControl *)[self.view viewWithTag:1010]).selectedSegmentIndex);
//    if (((UISegmentedControl *)[self.view viewWithTag:1010]).selectedSegmentIndex == 0) {
//        [[AppDelegate NotificationsArray] removeObjectAtIndex:sender.tag - 100];
//    }
//    else{
//        [[AppDelegate FriendshipReqArray] removeObjectAtIndex:sender.tag - 100];
//    }
//}

#pragma mark - Accepting the friend request

-(void)btnAcceptRequest:(UIButton *)sender{

    [self responseToUser:[[_responseArr objectAtIndex:sender.tag - 200] valueForKey:@"user_id"] withFriendshipStatus:@"1"];
}

-(void)btnDeclineRequest:(UIButton *)sender{
    [self responseToUser:[[_responseArr objectAtIndex:sender.tag - 100] valueForKey:@"user_id"] withFriendshipStatus:@"0"];
}

#pragma mark - Call Webservice for Accepting/Declining Friend Request

-(void)responseToUser :(NSString *)userId withFriendshipStatus :(NSString *)friendshipStatus{
    NSMutableDictionary *acceptReqDict = [[NSMutableDictionary alloc] init];
    [acceptReqDict setObject:userId forKey:@"user_id"];
    [acceptReqDict setObject:[[AppDelegate GloabalInfo] valueForKey:@"user_id"] forKey:@"friend_id"];
    [acceptReqDict setObject:friendshipStatus forKey:@"friendship_status"];
    [acceptReqDict setObject:@"ActiveLifeApp" forKey:@"api_key"];
    [acceptReqDict setObject:[AppDelegate getCurrentTimeStamp] forKey:@"timestamp"];
    
    NSString *signature = [AppDelegate hmacSHA256:KSECRET_KEY forKeyValue:[NSString stringWithFormat:@"%@%@%@%@",userId,[[AppDelegate GloabalInfo] valueForKey:@"user_id"],KAPI_KEY,[AppDelegate getCurrentTimeStamp]]];
    [acceptReqDict setObject:signature forKey:@"signature"];
    
    WebserviceCall *webserviceCall = [[WebserviceCall alloc] init];
    webserviceCall.delegate = self;
    webserviceCall.tag = 1010;
    [webserviceCall callWebserviceWithIdentifier:@"FriendsResponse" andArguments:acceptReqDict];
}

#pragma mark - Webservice Call Delegate Methods

-(void)webRequestFinished:(id)sender forTag:(int)Tag{
    
    if (Tag == 1011) {
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            NSLog(@"users..%@",[sender valueForKey:@"user"]);
            [_responseArr addObjectsFromArray:[sender valueForKey:@"user"]];
            NSLog(@"_responseArr..%@",_responseArr);
        }
//        else{
//            [AlertView showAlertwithTitle:@"Active Life App" message:@"Currently you have no pending friend requests."];
//        }
        [tableFriendRequest reloadData];
    }
    else if(Tag == 1010){
        if ([[sender valueForKey:@"status"] isEqualToString:@"1"]) {
            [AlertView showAlertwithTitle:@"Active Life App" message:[sender valueForKey:@"message"]];
//            [self viewWillAppear:YES];
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
